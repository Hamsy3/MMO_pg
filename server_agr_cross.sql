--EXPLAIN ANALYZE
SELECT * FROM
  CROSSTAB(
    $$
    WITH 
	server_info AS (SELECT "server".server_id AS serv_id, region.full_name AS region_name, race.full_name AS race, character_id --, race.full_name AS race_name --combination.combination_id, 
		FROM "server"
		INNER JOIN region ON region.region_id = "server".region_id	
		CROSS JOIN race
		LEFT JOIN combination USING (race_id)
		LEFT JOIN "character" ON "character".server_id = "server".server_id AND "character".combination_id = combination.combination_id
	),
	
	total_ppl AS (SELECT "server".server_id, 
					COUNT(character_id) AS total_ppl
		FROM "server"
		INNER JOIN region ON region.region_id = "server".region_id
		LEFT JOIN "character" ON "character".server_id = "server".server_id
		LEFT JOIN combination ON combination.combination_id = "character".combination_id
		LEFT JOIN race ON race.race_id = combination.race_id
		GROUP BY "server".server_id
	),
	server_race AS (SELECT serv_id,
					race,
				   	(COUNT(character_id) * 1.0 / (CASE WHEN total_ppl.total_ppl = 0 THEN 1 ELSE total_ppl.total_ppl END)*100) * 1.0 AS race_distr
		FROM server_info
		INNER JOIN total_ppl ON server_info.serv_id = total_ppl.server_id
		GROUP BY serv_id, race, total_ppl
	)
SELECT * FROM server_race $$,
    $$
      VALUES
        ('night elf'),
        ('forest elf'),
	  	('sky elf'),
	  	('cave orc'),
	  	('desert orc'),
	  	('red orc')
    $$
  ) AS (
    serv_id VARCHAR(30),
    "night elf" numeric,
    "forest elf" numeric,
	"sky elf" numeric,
	"cave orc" numeric,
	"desert orc" numeric,
	"red orc" numeric
  )