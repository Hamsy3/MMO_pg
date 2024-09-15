--пятый запрос (3?)
WITH
	event_info AS (SELECT event_id,
				   start_time,
				   DATE_TRUNC('second', now() - start_time) AS duration,
				   "event".event_type_id,
				   event_type.full_name AS event_name
		FROM "event"
		INNER JOIN event_type ON "event".event_type_id = event_type.event_type_id
		WHERE status = 1
	),
	
	team_info AS (SELECT event_info.event_id,
				  event_info.event_type_id,
				  team.team_id,
				  ROW_NUMBER() OVER (PARTITION BY event_info.event_id ORDER BY team_id) AS team_c				  
		FROM event_info
		INNER JOIN team ON team.event_id = event_info.event_id
	),
	
	team_divided AS (SELECT team_info.event_id,
					 team_info.event_type_id AS cur_event_type,
					 MAX(CASE WHEN team_c = 1 THEN team_id END) AS team2_id,
    				 MAX(CASE WHEN team_c = 2 THEN team_id END) AS team1_id
		FROM team_info
		GROUP BY  team_info.event_id, team_info.event_type_id
	),
	team1 AS (SELECT team_divided.event_id,
			 team1_id,
			 ARRAY_AGG("character".full_name) AS team1_names,
			 COALESCE (COUNT("character".full_name) FILTER (WHERE death_flag = false), 0) AS team1_alive
		FROM team_divided
		INNER JOIN character_row ON character_row.team_id = team_divided.team1_id
	 	INNER JOIN "character" USING (character_id)
		GROUP BY team_divided.event_id, team1_id
	),
	team2 AS (SELECT team_divided.event_id,
			 team2_id,
			 array_remove((ARRAY_AGG("character".full_name) || ARRAY_AGG(boss.full_name)), NULL) AS team2_names,
			 (COALESCE (COUNT("character".full_name) FILTER (WHERE character_row.death_flag = false), 0) + COALESCE (COUNT(boss.full_name) FILTER (WHERE boss_row.death_flag = false), 0))
			 AS team2_alive
		FROM team_divided
		LEFT JOIN character_row ON character_row.team_id = team_divided.team2_id
	 	LEFT JOIN "character" USING (character_id)
		LEFT JOIN boss_row ON boss_row.team_id = team_divided.team2_id
	 	LEFT JOIN boss USING (boss_id)
		GROUP BY team_divided.event_id, team2_id
	),
	team_concat AS (SELECT event_info.*,
				   team1_names,
				   team2_names,
				   team1_alive,
				   team2_alive,
				   team1_id,
				   team2_id
		FROM event_info
		INNER JOIN team_divided USING (event_id)
		INNER JOIN team1 USING (team1_id)
		INNER JOIN team2 USING (team2_id)	
	),
	char_team_fcst AS (SELECT character_id,
				   "event".event_type_id AS event_type,
				   (COUNT (character_row.team_id) FILTER (WHERE death_flag = false AND win_flag = true)*100::decimal(5,2) / COUNT(character_row.team_id))::decimal(5,2) AS char_team_fcst
		FROM team_divided
		RIGHT JOIN character_row ON character_row.team_id = team_divided.team1_id
		INNER JOIN team ON team.team_id = character_row.team_id
		INNER JOIN "event" ON "event".event_id = team.event_id
		GROUP BY character_id, event_type
	),
	
	char_team1_fcst_ev AS (SELECT team1_id, COALESCE((SUM(char_team_fcst) FILTER (WHERE death_flag = false) / COUNT(character_row.character_id) FILTER (WHERE death_flag = false)),0)::decimal(5,2) AS team1_fcst
		FROM team_divided
		INNER JOIN character_row ON character_row.team_id = team_divided.team1_id
		INNER JOIN char_team_fcst ON char_team_fcst.event_type = team_divided.cur_event_type AND char_team_fcst.character_id = character_row.character_id
		GROUP BY team1_id			   
	),

	char_team2_fcst_ev AS (SELECT team2_id, COALESCE((SUM(char_team_fcst) FILTER (WHERE death_flag = false) / COUNT(character_row.character_id) FILTER (WHERE death_flag = false)),0)::decimal(5,2) AS team2_fcst
		FROM team_divided
		INNER JOIN character_row ON character_row.team_id = team_divided.team2_id
		INNER JOIN char_team_fcst ON char_team_fcst.event_type = team_divided.cur_event_type AND char_team_fcst.character_id = character_row.character_id
		GROUP BY team2_id			   
	),
	
	boss_team_fcst AS (SELECT boss_id,
				   "event".event_type_id AS event_type,
				   (COUNT (boss_row.team_id) FILTER (WHERE death_flag = false AND win_flag = true)*100::decimal(5,2) / COUNT(boss_row.team_id))::decimal(5,2) AS boss_team_fcst
		FROM team_divided
		RIGHT JOIN boss_row ON boss_row.team_id = team_divided.team2_id
		INNER JOIN team ON team.team_id = boss_row.team_id
		INNER JOIN "event" ON "event".event_id = team.event_id
		GROUP BY boss_id, event_type
	),
	
	boss_team2_fcst_ev AS (SELECT team2_id, COALESCE((SUM(boss_team_fcst) FILTER (WHERE death_flag = false) / COUNT(boss_row.boss_id) FILTER (WHERE death_flag = false)),0)::decimal(5,2) AS team2_fcst
		FROM team_divided
		INNER JOIN boss_row ON boss_row.team_id = team_divided.team2_id
		INNER JOIN boss_team_fcst ON boss_team_fcst.event_type = team_divided.cur_event_type AND boss_team_fcst.boss_id = boss_row.boss_id
		GROUP BY team2_id			   
	),
	
	team_tot AS (SELECT team_concat.event_id,
				 		team_concat.start_time,
				 		team_concat.duration,
				 		team_concat.event_type_id,
				 		team_concat.event_name,
				 		team_concat.team1_names,
				 		team_concat.team2_names,
				 		team_concat.team1_alive,
				 		team_concat.team2_alive,
				(CASE WHEN (team1_fcst + COALESCE(char_team2_fcst_ev.team2_fcst, 0) + COALESCE(boss_team2_fcst_ev.team2_fcst, 0)) = 0 THEN 'Не определено'
				 ELSE (team1_fcst / (team1_fcst + COALESCE(char_team2_fcst_ev.team2_fcst, 0) + COALESCE(boss_team2_fcst_ev.team2_fcst, 0))*100)::decimal(5,2)::text END) AS forecast
		FROM team_concat
		INNER JOIN char_team1_fcst_ev ON char_team1_fcst_ev.team1_id = team_concat.team1_id
		LEFT JOIN char_team2_fcst_ev ON char_team2_fcst_ev.team2_id = team_concat.team2_id
		LEFT JOIN boss_team2_fcst_ev ON boss_team2_fcst_ev.team2_id = team_concat.team2_id		
	)
SELECT * FROM team_tot;
 