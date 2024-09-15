EXPLAIN ANALYZE
WITH 
	server_info AS (SELECT "server".server_id AS serv_id, region.full_name AS region_name, race.full_name AS race_name
		FROM "server"
		INNER JOIN region ON region.region_id = "server".region_id
		LEFT JOIN "character" ON "character".server_id = "server".server_id
		LEFT JOIN combination ON combination.combination_id = "character".combination_id
		LEFT JOIN race ON race.race_id = combination.race_id
	),
	
	server_race AS (SELECT "server".server_id, 
					COUNT(character_id) AS total_pl,
		(COUNT (race.race_id) FILTER (WHERE race.full_name='night elf') * 1.0 / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100) AS "night elf",
		(COUNT (race.race_id) FILTER (WHERE race.full_name='forest elf') * 1.0 / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100) AS "forest elf",
		(COUNT (race.race_id) FILTER (WHERE race.full_name='sky elf') * 1.0 / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100) AS "sky elf",
		(COUNT (race.race_id) FILTER (WHERE race.full_name='cave orc') * 1.0 / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100) AS "cave orc",
		(COUNT (race.race_id) FILTER (WHERE race.full_name='desert orc') * 1.0 / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100) AS "desert orc",
		(COUNT (race.race_id) FILTER (WHERE race.full_name='red orc') * 1.0 / (CASE WHEN COUNT(character_id) = 0 THEN 1 ELSE COUNT(character_id) END) * 100) AS "red orc"
		FROM "server"
		INNER JOIN region ON region.region_id = "server".region_id
		LEFT JOIN "character" ON "character".server_id = "server".server_id
		LEFT JOIN combination ON combination.combination_id = "character".combination_id
		LEFT JOIN race ON race.race_id = combination.race_id
		GROUP BY "server".server_id
	)
	/*server_race_stat AS (SELECT DISTINCT serv_id,
						 region_name,
						 total_pl,
						 "night elf",
						 "forest elf",
						 "sky elf",
						 "cave orc",
						 "desert orc",
						 "red orc"
		FROM server_info
		INNER JOIN server_race ON server_race.server_id = server_info.serv_id
	)*/
SELECT * FROM server_race --ORDER BY serv_id;