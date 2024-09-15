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
		
	)
	
	/*server_piv AS (SELECT * --region_name, total_pl
		 COALESCE (MAX(distr_night) FILTER (WHERE race_name = 'night elf'), 0) AS "night elf",
		 COALESCE (MAX(distr_forest) FILTER (WHERE race_name = 'forest elf'), 0) AS "forest elf",
		 COALESCE (MAX(distr_sky) FILTER (WHERE race_name = 'sky elf'), 0) AS "sky elf", 
		 COALESCE (MAX(distr_cave) FILTER (WHERE race_name = 'cave orc'), 0) AS "cave orc",
		 COALESCE (MAX(distr_desert) FILTER (WHERE race_name = 'desert orc'), 0) AS "desert orc",
		 COALESCE (MAX(distr_red) FILTER (WHERE race_name = 'red orc'), 0) AS "red orc",
		 COALESCE (MAX(100.00) FILTER (WHERE race_name IS NULL), 0) AS "missing race"
		 FROM cross
		 GROUP BY server_id
	),
	/*server_piv AS (SELECT server_id, --region_name, total_pl
		 COALESCE (MAX(distr_night) FILTER (WHERE race_name = 'night elf'), 0) AS "night elf",
		 COALESCE (MAX(distr_forest) FILTER (WHERE race_name = 'forest elf'), 0) AS "forest elf",
		 COALESCE (MAX(distr_sky) FILTER (WHERE race_name = 'sky elf'), 0) AS "sky elf", 
		 COALESCE (MAX(distr_cave) FILTER (WHERE race_name = 'cave orc'), 0) AS "cave orc",
		 COALESCE (MAX(distr_desert) FILTER (WHERE race_name = 'desert orc'), 0) AS "desert orc",
		 COALESCE (MAX(distr_red) FILTER (WHERE race_name = 'red orc'), 0) AS "red orc",
		 COALESCE (MAX(100.00) FILTER (WHERE race_name IS NULL), 0) AS "missing race"
		 FROM server_stat
		 GROUP BY server_id
	),*/
	
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

	)*/
SELECT * FROM server_race;