--первый запрос (6)
WITH
	b_surv AS (SELECT full_name,
		COUNT(*) AS total_battles,
		COUNT(CASE WHEN team.win_flag = true THEN 1 END) AS win_battles,
		ROUND((COUNT (CASE WHEN boss_row.death_flag = false THEN 1 END)::decimal(5,2) / COUNT(*) * 100), 2) AS survival
		FROM boss
		INNER JOIN boss_row ON boss.boss_id = boss_row.boss_id
		INNER JOIN team ON boss_row.team_id = team.team_id
		GROUP BY boss.full_name 
	),
							  
	enemies AS (SELECT boss.full_name, SUM("character".lvl)::float / COUNT(*) AS en_mean
		FROM boss
		INNER JOIN boss_row ON boss.boss_id = boss_row.boss_id
		INNER JOIN team AS boss_team ON boss_row.team_id = boss_team.team_id
		INNER JOIN team AS enem_team ON boss_team.team_id != enem_team.team_id AND boss_team.event_id = enem_team.event_id
		INNER JOIN character_row ON enem_team.team_id = character_row.team_id
		INNER JOIN "character" ON character_row.character_id = "character".character_id AND enem_team.team_id = character_row.team_id
		GROUP BY boss.full_name
	),
							  
	b_lvl AS (SELECT boss.full_name, SUM(boss.lvl)::float / COUNT(*) AS b_mean
		FROM team
		INNER JOIN boss_row ON team.team_id = boss_row.team_id
		INNER JOIN boss ON boss_row.boss_id = boss.boss_id
		GROUP BY boss.full_name
	),							  
	
	b_surv_en AS (SELECT b_surv.*, enemies.en_mean, b_mean
		FROM b_surv
		INNER JOIN enemies ON b_surv.full_name = enemies.full_name
		INNER JOIN b_lvl ON b_surv.full_name = b_lvl.full_name
		ORDER BY survival DESC
	)
SELECT * FROM b_surv_en;
--второй запрос (8)
WITH 
	char_info AS (SELECT nickname, "character".full_name AS char_name, race.full_name AS race_name
		FROM user_of_service
		INNER JOIN "character" ON "character".user_id = user_of_service.user_id
		INNER JOIN combination ON combination.combination_id = "character".combination_id
		INNER JOIN race ON race.race_id = combination.race_id
	),
	
	char_battle AS (SELECT nickname, "character".full_name,
		SUM(CASE WHEN team.win_flag = true THEN 1 ELSE 0 END)::float / SUM(1) AS win,
		SUM(CASE WHEN character_row.death_flag = false THEN 1 ELSE 0 END)::float / SUM(1) AS surv,
		SUM(CASE WHEN character_row.character_id IS NULL THEN 0 ELSE 1 END) AS bc	  
		FROM user_of_service
		INNER JOIN "character" ON "character".user_id = user_of_service.user_id
		LEFT JOIN character_row ON character_row.character_id = "character".character_id
		LEFT JOIN team ON team.team_id = "character_row".team_id
		GROUP BY nickname, "character".full_name	  
	),
	
	char_stat AS (SELECT char_info.*, win, surv, bc,
		540 * POWER(bc, 0.37) * TANH(0.00163 * (CASE WHEN bc = 0 THEN 0 ELSE POWER(bc, -0.37) END) * (3500/(1 + EXP(16 - 31 * win))) + 1400/(1 + EXP(8 - 27 * surv))) AS RBR
		FROM char_info
		INNER JOIN char_battle ON char_battle.nickname = char_info.nickname AND char_battle.full_name = char_info.char_name 
		ORDER BY RBR
	) 
SELECT * FROM char_stat;

--третий запрос (9)
WITH 
	server_info AS (SELECT "server".server_id AS serv_id, region.full_name AS region_name, race.full_name AS race_name
		FROM "server"
		INNER JOIN region ON region.region_id = "server".region_id
		LEFT JOIN "character" ON "character".server_id = "server".server_id
		LEFT JOIN combination ON combination.combination_id = "character".combination_id
		LEFT JOIN race ON race.race_id = combination.race_id
	),
	
	server_race AS (SELECT "server".server_id, 
					COUNT (race.race_id), 
					COUNT(character_id) AS total_pl,
		ROUND((COUNT (race.race_id) FILTER (WHERE race.full_name='night elf')::decimal(5,2) / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100), 2) AS distr_night,
		ROUND((COUNT (race.race_id) FILTER (WHERE race.full_name='forest elf')::decimal(5,2) / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100), 2) AS distr_forest,
		ROUND((COUNT (race.race_id) FILTER (WHERE race.full_name='sky elf')::decimal(5,2) / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100), 2) AS distr_sky,
		ROUND((COUNT (race.race_id) FILTER (WHERE race.full_name='cave orc')::decimal(5,2) / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100), 2) AS distr_cave,
		ROUND((COUNT (race.race_id) FILTER (WHERE race.full_name='desert orc')::decimal(5,2) / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100), 2) AS distr_desert,
		ROUND((COUNT (race.race_id) FILTER (WHERE race.full_name='red orc')::decimal(5,2) / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100), 2) AS distr_red			
		FROM "server"
		INNER JOIN region ON region.region_id = "server".region_id
		LEFT JOIN "character" ON "character".server_id = "server".server_id
		LEFT JOIN combination ON combination.combination_id = "character".combination_id
		LEFT JOIN race ON race.race_id = combination.race_id
		GROUP BY "server".server_id
	),
	
	server_stat AS (SELECT server_race.*, race_name
		FROM server_race
		INNER JOIN server_info ON server_info.serv_id = server_race.server_id
		
	),
	
	server_piv AS (SELECT server_id, --region_name, total_pl
		 COALESCE (MAX(distr_night) FILTER (WHERE race_name = 'night elf'), 0) AS "night elf",
		 COALESCE (MAX(distr_forest) FILTER (WHERE race_name = 'forest elf'), 0) AS "forest elf",
		 COALESCE (MAX(distr_sky) FILTER (WHERE race_name = 'sky elf'), 0) AS "sky elf", 
		 COALESCE (MAX(distr_cave) FILTER (WHERE race_name = 'cave orc'), 0) AS "cave orc",
		 COALESCE (MAX(distr_desert) FILTER (WHERE race_name = 'desert orc'), 0) AS "desert orc",
		 COALESCE (MAX(distr_red) FILTER (WHERE race_name = 'red orc'), 0) AS "red orc",
		 COALESCE (MAX(100.00) FILTER (WHERE race_name IS NULL), 0) AS "missing race"
		 FROM server_stat
		 GROUP BY server_id
	),
	
	server_race_stat AS (SELECT DISTINCT serv_id,
						 region_name,
						 total_pl,
						 "night elf",
						 "forest elf",
						 "sky elf",
						 "cave orc",
						 "desert orc",
						 "red orc",
						 "missing race" 
		FROM server_info
		INNER JOIN server_race ON server_race.server_id = server_info.serv_id
		INNER JOIN server_piv ON server_piv.server_id = server_info.serv_id

	)
SELECT * FROM server_race_stat;
--четвертый запрос (1)
WITH 
	char_info AS (SELECT nickname,
				  "character".full_name AS char_name,
				  character_id,
				  reg_date,
				  "character".server_id,
				  region.full_name AS region,
				  race.full_name AS race,
				  fraction.full_name AS fraction
		FROM user_of_service
		INNER JOIN "character" ON "character".user_id = user_of_service.user_id
		INNER JOIN "server" ON "server".server_id = "character".server_id
		INNER JOIN region ON region.region_id = "server".region_id
		INNER JOIN combination ON combination.combination_id = "character".combination_id
		INNER JOIN race ON race.race_id = combination.race_id
		INNER JOIN fraction ON fraction.fraction_id = race.fraction_id
		WHERE user_of_service.user_id = 1
	),
	battle_info AS (SELECT char_info.character_id,
					COUNT(character_row.team_id) AS total_battles,
					COUNT(CASE WHEN char_team.win_flag = false AND enem_team.win_flag = true THEN 1 END) AS lose_battles_tot,
					COUNT(CASE WHEN char_team.win_flag = true THEN 1 END) AS win_battles_tot,
					COUNT(CASE WHEN char_team.win_flag = false AND enem_team.win_flag = false THEN 1 END) AS draw_battles_tot,
					ROUND(COUNT(CASE WHEN char_team.win_flag = true THEN 1 END)::decimal(5,2) / GREATEST(COUNT(character_row.team_id), 1) * 100, 2) AS  win_percentage_tot,
					COUNT(character_row.team_id) FILTER (WHERE event_type_id = 1) AS total_battles_cave,
					COUNT(CASE WHEN char_team.win_flag = false AND enem_team.win_flag = true THEN 1 END) FILTER (WHERE event_type_id = 1) AS lose_battles_cave,
					COUNT(CASE WHEN char_team.win_flag = true THEN 1 END) FILTER (WHERE event_type_id = 1) AS win_battles_cave,
					COUNT(CASE WHEN char_team.win_flag = false AND enem_team.win_flag = false THEN 1 END) FILTER (WHERE event_type_id = 1) AS draw_battles_cave,
					ROUND(COUNT(CASE WHEN char_team.win_flag = true THEN 1 END) FILTER (WHERE event_type_id = 1)::decimal(5,2) /
						  GREATEST(COUNT(character_row.team_id) FILTER (WHERE event_type_id = 1), 1) * 100, 2) AS  win_percentage_cave,
					COUNT(character_row.team_id) FILTER (WHERE event_type_id = 2) AS total_battles_raid,
					COUNT(CASE WHEN char_team.win_flag = false AND enem_team.win_flag = true THEN 1 END) FILTER (WHERE event_type_id = 2) AS lose_battles_raid,
					COUNT(CASE WHEN char_team.win_flag = true THEN 1 END) FILTER (WHERE event_type_id = 2) AS win_battles_raid,
					COUNT(CASE WHEN char_team.win_flag = false AND enem_team.win_flag = false THEN 1 END) FILTER (WHERE event_type_id = 2) AS draw_battles_raid,
					ROUND(COUNT(CASE WHEN char_team.win_flag = true THEN 1 END) FILTER (WHERE event_type_id = 2)::decimal(5,2) /
						  GREATEST(COUNT(character_row.team_id) FILTER (WHERE event_type_id = 2), 1) * 100, 2) AS  win_percentage_raid,
					COUNT(char_team.team_id) FILTER (WHERE event_type_id = 3) AS total_battles_bg,
					COUNT(CASE WHEN char_team.win_flag = false AND enem_team.win_flag = true THEN 1 END) FILTER (WHERE event_type_id = 3) AS lose_battles_bg,
					COUNT(CASE WHEN char_team.win_flag = true THEN 1 END) FILTER (WHERE event_type_id = 3) AS win_battles_bg,
					COUNT(CASE WHEN char_team.win_flag = false AND enem_team.win_flag = false THEN 1 END) FILTER (WHERE event_type_id = 3) AS draw_battles_bg,
					ROUND(COUNT(CASE WHEN char_team.win_flag = true THEN 1 END) FILTER (WHERE event_type_id = 3)::decimal(5,2) /
						  GREATEST(COUNT(char_team.team_id) FILTER (WHERE event_type_id = 3), 1) * 100, 2) AS  win_percentage_bg
		FROM char_info
		LEFT JOIN character_row ON character_row.character_id = char_info.character_id
		LEFT JOIN team AS char_team ON char_team.team_id = character_row.team_id
		LEFT JOIN team AS enem_team ON enem_team.team_id != char_team.team_id AND enem_team.event_id = char_team.event_id
		LEFT JOIN "event" ON "event".event_id = char_team.event_id
		GROUP BY char_info.character_id
	),
	char_stat AS (SELECT char_info.*,
				  total_battles,
				  lose_battles_tot,
				  win_battles_tot,
				  draw_battles_tot,
				  win_percentage_tot,
				  total_battles_cave,
				  lose_battles_cave,
				  win_battles_cave,
				  draw_battles_cave,
				  win_percentage_cave,
				  total_battles_raid,
				  lose_battles_raid,
				  win_battles_raid,
				  draw_battles_raid,
				  win_percentage_raid,
				  total_battles_bg,
				  lose_battles_bg,
				  win_battles_bg,
				  draw_battles_bg,
				  win_percentage_bg
		FROM char_info
		INNER JOIN battle_info ON battle_info.character_id = char_info.character_id
	)
SELECT * FROM char_stat;
--пятый запрос (3?)
WITH
	event_info AS (SELECT event_id,
				   start_time,
				   end_time,
				   end_time - start_time AS duration,
				   event_type.full_name AS event_name
		FROM "event"
		INNER JOIN event_type ON "event".event_type_id = event_type.event_type_id
		WHERE status = 1
	),
	
	team_info AS (SELECT event_info.event_id,
				  team.team_id,
				  ROW_NUMBER() OVER (PARTITION BY event_info.event_id ORDER BY team_id) AS team_c				  
		FROM event_info
		INNER JOIN team ON team.event_id = event_info.event_id
	),
	
	team_divided AS (SELECT team_info.event_id,
					 MAX(CASE WHEN team_c = 1 THEN team_id END) AS team2_id,
    				 MAX(CASE WHEN team_c = 2 THEN team_id END) AS team1_id
		FROM team_info
		GROUP BY  team_info.event_id
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
				   team2_alive
		FROM event_info
		INNER JOIN team_divided USING (event_id)
		INNER JOIN team1 USING (team1_id)
		INNER JOIN team2 USING (team2_id)	
	),
	team1_fcst AS (SELECT team1_id,
				   character_id,
				   CASE WHEN COUNT(team_id) = 0 THEN NULL ELSE (COUNT(team_id) FILTER (WHERE death_flag = false AND event_type_id = (SELECT event_type_id FROM "event" WHERE event_id = team_divided.event_id))::decimal(5,2)
				   / COUNT(team_id))::decimal(5,2) END AS forecast
				   --* --team_divided.*
		FROM team_divided
		INNER JOIN character_row ON character_row.team_id = team_divided.team1_id
		RIGHT JOIN "event" ON "event".event_id = team_divided.event_id
		GROUP BY team1_id, character_id
	)
	/*team_tot AS (SELECT team_concat.*,
				forecast
		FROM team_concat
		INNER JOIN team1_fcst ON team1_fcst.team1_id = team_concat.team1_id
	)*/
SELECT * FROM team_concat --WHERE character_id IS NOT NULL;

--SELECT * FROM character_row WHERE team_id IN (30,45,43,39,36,34);
--SELECT * FROM boss_row WHERE team_id IN (31,46,44,40,37,35);
--SELECT  * FROM "event"

SELECT * FROM character_row WHERE character_id = 4
SELECT event_type_id FROM "event" WHERE event_id IN (SELECT event_id FROM team WHERE team_id IN (23,25,27,31,48,35,50,52))
SELECT * FROM event_type