DROP TABLE user_of_service CASCADE;
DROP TABLE user_type CASCADE;
DROP TABLE region CASCADE;
DROP TABLE "server" CASCADE;
DROP TABLE "character" CASCADE;
DROP TABLE combination CASCADE;
DROP TABLE profession CASCADE;
DROP TABLE race CASCADE;
DROP TABLE fraction CASCADE;
DROP TABLE event_type CASCADE;
DROP TABLE event CASCADE;
DROP TABLE team CASCADE;
DROP TABLE character_role CASCADE;
DROP TABLE character_row CASCADE;
DROP TABLE boss CASCADE;
DROP TABLE boss_row CASCADE;


CREATE TABLE user_type (
	user_type_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	full_name VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE region (
	region_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	full_name VARCHAR(30) UNIQUE NOT NULL,
	short_name CHAR(2) NOT NULL CHECK (short_name = UPPER(short_name))
);

CREATE TABLE user_of_service (
	user_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	email VARCHAR(255) NOT NULL UNIQUE CHECK (email LIKE '%@%'),
	nickname VARCHAR (60) NOT NULL UNIQUE CHECK (nickname NOT LIKE '%!%'),
	password_hash VARCHAR(255) NOT NULL,
	region_id INT REFERENCES region(region_id),
	user_type_id INT REFERENCES user_type(user_type_id)
);

CREATE TABLE "server" (
	server_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	server_type VARCHAR(3) NOT NULL CHECK (server_type = 'PVP' OR server_type = 'PVE'
												  OR server_type = 'RP'),
	region_id INT REFERENCES region(region_id)
);

CREATE TABLE profession (
	profession_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	full_name VARCHAR(30) UNIQUE NOT NULL,
	description VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE fraction (
	fraction_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	full_name VARCHAR(30) UNIQUE NOT NULL,
	short_description VARCHAR(30) UNIQUE NOT NULL,
	full_description VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE race (
	race_id SERIAL,
	fraction_id INT REFERENCES fraction(fraction_id),
	PRIMARY KEY(race_id, fraction_id),
	full_name VARCHAR(30) UNIQUE NOT NULL,
	description VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE combination (
	combination_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	profession_id INT REFERENCES profession(profession_id),
	race_id INT,
	fraction_id INT,
	FOREIGN KEY (race_id, fraction_id) REFERENCES race(race_id, fraction_id)
);

CREATE TABLE "character" (
	character_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	full_name VARCHAR(30) UNIQUE NOT NULL,
	lvl INT NOT NULL CHECK (lvl > 0),
	image_path VARCHAR(60),
	balance INT NOT NULL CHECK (balance >= 0),
	combination_id INT REFERENCES combination(combination_id),
	server_id INT REFERENCES "server"(server_id),
	user_id INT REFERENCES user_of_service(user_id),
	block_flag BOOLEAN NOT NULL,
	block_reason VARCHAR(60),
	moderator_code INT
);

CREATE TABLE event_type (
	event_type_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	full_name VARCHAR(30) UNIQUE NOT NULL,
	description VARCHAR(60) UNIQUE NOT NULL,
	max_players INT NOT NULL CHECK (max_players > 0)
);

CREATE TABLE "event" (
	event_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	event_type_id INT REFERENCES event_type(event_type_id),
	start_time TIMESTAMP NOT NULL,
	end_time TIMESTAMP NOT NULL,
	map_type VARCHAR(60) NOT NULL,
	status INT NOT NULL CHECK (status >= 0 AND status < 3),
	server_id INT REFERENCES "server"(server_id),
	min_lvl INT NOT NULL CHECK (min_lvl > 0),
	max_lvl INT NOT NULL CHECK (max_lvl > 0),
	difficulty INT NOT NULL CHECK (difficulty >= 0),
	lasting_bound TIME NOT NULL
);

CREATE TABLE team (
	team_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	event_id INT REFERENCES "event"(event_id),
	win_flag BOOLEAN NOT NULL
);

CREATE TABLE character_role (
	character_role_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	full_name VARCHAR(30) UNIQUE NOT NULL,
	description VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE character_row (
	character_id INT REFERENCES "character"(character_id),
	team_id INT REFERENCES team(team_id),
	PRIMARY KEY(character_id, team_id),
	character_role_id INT REFERENCES character_role(character_role_id),
	dealed_damage INT NOT NULL CHECK (dealed_damage >= 0),
	received_damage INT NOT NULL CHECK (received_damage >= 0),
	healed_damage INT NOT NULL CHECK (healed_damage >= 0),
	killed INT NOT NULL CHECK (healed_damage >= 0),
	death_flag BOOLEAN NOT NULL
);

CREATE TABLE boss (
	boss_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	full_name VARCHAR(30) UNIQUE NOT NULL,
	lvl INT NOT NULL CHECK (lvl > 0)
);

CREATE TABLE boss_row (
	boss_id INT REFERENCES boss(boss_id),
	team_id INT REFERENCES team(team_id),
	PRIMARY KEY(boss_id, team_id),
	death_flag BOOLEAN NOT NULL
);

INSERT INTO region (full_name, short_name)
VALUES ('Russia', 'RU'),
		('China', 'CH'),
		('England', 'UK'),
		('France', 'FR'),
		('Germany', 'GR');
		
INSERT INTO user_type (full_name)
VALUES ('User'),
		('VIP'),
		('Moderator'),
		('Admin');

INSERT INTO user_of_service (email, nickname, password_hash, region_id, user_type_id)
VALUES ('gamer2007@mail.ru', 'haccker12', '43758349822097234ab', 1, 4),
		('gamer2013@mail.ru', 'macadress45', '437583498321097234abcedff', 1, 2),
		('aloha1988@mail.ru', 'skuf45', '421421acbdeff', 1, 2),
		('dendi2020@gmail.com', 'zOOmer4', '5412452135acbde', 2, 1),
		('Napoleon@gmail.com', 'Lasniper', '412421241acbdeff', 4, 4);
	
INSERT INTO "server" (server_type, region_id)
VALUES ('PVP', 1),
		('PVE', 1),
		('RP', 1),
		('PVP', 2),
		('PVE', 2),
		('RP', 2),
		('PVP', 3),
		('PVE', 3),
		('RP', 3),
		('PVP', 4),
		('PVE', 4),
		('RP', 4),
		('PVP', 5),
		('PVE', 5),
		('RP', 5);
INSERT INTO profession (full_name, description)
VALUES ('Worker', 'Cool worker');
INSERT INTO fraction (full_name, short_description, full_description)
VALUES ('Elf', 'cool elf', 'really cool elf');
INSERT INTO race (fraction_id, full_name, description)
VALUES (1, 'night elf', 'cool night elf');
INSERT INTO combination (profession_id, race_id, fraction_id)
VALUES(1,1,1);
INSERT INTO "character" (full_name, lvl, image_path, balance, combination_id, server_id, user_id, block_flag, block_reason, moderator_code) 
VALUES ('elf323', 15, '\image.jpeg', 1000, 1, 1, 1, false, '', 0),
		('elf16', 16, '\image1.jpeg', 1000, 1, 1, 1, false, '', 0),
		('elf17', 17, '\image1.jpeg', 1000, 1, 1, 1, false, '', 0),
		('elf18', 18, '\image1.jpeg', 1000, 1, 1, 1, false, '', 0),
		('elf19', 19, '\image1.jpeg', 1000, 1, 1, 1, false, '', 0),
		('elf20', 20, '\image1.jpeg', 1000, 1, 1, 1, false, '', 0),
		('elf19_serv', 19, '\image1.jpeg', 1000, 1, 2, 1, false, '', 0),
		('elf21', 19, '\image1.jpeg', 1000, 1, 1, 1, false, '', 0);
INSERT INTO event_type (full_name, description, max_players)
VALUES ('cave', 'cool', 25),
		('raid', 'really cool', 25),
		('battleground', 'not really cool', 10);
INSERT INTO team DEFAULT VALUES;
INSERT INTO character_row DEFAULT VALUES;
INSERT INTO character_role (full_name, description)
VALUES ('Tank', 'Cool tank'),
		('Healer', 'Cool healer'),
		('Fighter', 'Cool fighter');
INSERT INTO boss (full_name, lvl)
VALUES ('Lich', 30),
		('Murloc', 5),
		('Undead_king', 10),
		('Elf_king', 15),
		('Arthas', 80),
		('Beast_master', 50),
		('Pandaren', 60),
		('Grom', 45),
		('Dragon', 50),
		('Wolf', 3),
		('Bear', 3),
		('Bird', 3);
INSERT INTO boss_row (boss_id, team_id, death_flag)
VALUES(1,1, False);





SELECT * FROM user_type;
SELECT * FROM region;
SELECT * FROM user_of_service;
SELECT * FROM "server";
SELECT * FROM profession;
SELECT * FROM fraction;
SELECT * FROM race;
SELECT * FROM combination;
SELECT * FROM "character";
SELECT * FROM event_type;
SELECT * FROM "event";
SELECT * FROM team;
SELECT * FROM character_role;
SELECT * FROM character_row;
SELECT * FROM boss;
SELECT * FROM boss_row;


CREATE OR REPLACE FUNCTION trigger_pve_func()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
DECLARE
    random_amount INTEGER;
	saved_team_id INTEGER;
BEGIN 
	IF (SELECT server_type FROM "server" WHERE server_id = NEW.server_id) = 'PVE' THEN
		IF (SELECT full_name FROM event_type WHERE event_type_id = NEW.event_type_id) = 'cave' THEN
			random_amount := LEAST((SELECT COUNT(*) FROM boss),(floor(RANDOM() * (5 - 3 + 1)) + 3));
		ELSE
			random_amount := LEAST((SELECT COUNT(*) FROM boss),(floor(RANDOM() * (8 - 4 + 1)) + 4));
		END IF;
		
		INSERT INTO team (event_id, win_flag) VALUES (NEW.event_id, false) RETURNING team_id INTO saved_team_id;
				
		CREATE TEMP TABLE boss_ids AS
		SELECT boss_id FROM boss ORDER BY RANDOM() LIMIT random_amount;
		
		INSERT INTO boss_row (boss_id, team_id, death_flag)
        SELECT boss_id, saved_team_id, false
        FROM boss_ids;

		DROP TABLE boss_ids;
		
	END IF;
	RETURN NEW;
END;
$$;



CREATE TRIGGER trigger_pve
AFTER INSERT ON "event"
FOR EACH ROW
EXECUTE FUNCTION trigger_pve_func();


INSERT INTO "event" (event_type_id, start_time, end_time, map_type, status, server_id, min_lvl, max_lvl, difficulty, lasting_bound)
VALUES (2, '2024-03-27 15:30:00', '2024-03-27 16:30:00', '\map.jpeg', 1, 1, 5, 10, 7, '00:00:00');

SELECT * FROM team;
SELECT * FROM boss_row;
SELECT * FROM "event";

DROP TRIGGER trigger_pve ON "event";
DROP FUNCTION trigger_pve_func();

CREATE OR REPLACE FUNCTION trigger_add_ch_func()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN 
	IF (SELECT status FROM "event" WHERE event_id = (SELECT event_id FROM team WHERE team_id = NEW.team_id)) = 1 THEN
		RAISE NOTICE 'Event has already started';
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END;
$$;

CREATE TRIGGER trigger_add_ch
BEFORE INSERT ON character_row
FOR EACH ROW
EXECUTE FUNCTION trigger_add_ch_func();

INSERT INTO team (event_id, win_flag)
VALUES (17, false);

SELECT * FROM team;
SELECT * FROM "event";

INSERT INTO character_row (character_id, team_id, character_role_id, dealed_damage, received_damage, healed_damage, killed, death_flag)
VALUES (1, 12, 1, 0, 0, 0, 0, false);

/*INSERT INTO character_row (character_id, team_id, character_role_id, dealed_damage, received_damage, healed_damage, killed, death_flag)
VALUES (1, 11, 1, 0, 0, 0, 0, false);*/


SELECT * FROM character_row;

DROP TRIGGER trigger_add_ch ON character_row;
DROP FUNCTION trigger_add_ch_func();

CREATE OR REPLACE PROCEDURE create_cave(nick1 VARCHAR (60), nick2 VARCHAR (60), nick3 VARCHAR (60), nick4 VARCHAR (60), nick5 VARCHAR (60))
LANGUAGE plpgsql
AS $$
DECLARE
	server_id_check INT;
	min_lvl INT;
	max_lvl INT;
	cur_event_id INT;
	rand_map VARCHAR (60);
	boss_team_id INT;
	char_team_id INT;
	random_amount INT;
BEGIN
	SELECT server_id INTO server_id_check FROM "character" WHERE full_name=nick1;
	
	--первая проверка
    IF EXISTS (
        SELECT 1 FROM "character"
        WHERE full_name IN (nick2, nick3, nick4, nick5)
        AND server_id != server_id_check
    ) THEN
		RAISE NOTICE 'Cannot create: different servers';
    	RETURN;
    END IF;
	
	-- вторая проверка
	/*IF (SELECT COUNT(*) FROM (SELECT lvl1.lvl AS lvl1, lvl2.lvl AS lvl2
		FROM "character"
		lvl1 CROSS JOIN "character" lvl2
		WHERE lvl1.full_name IN (nick1, nick2, nick3, nick4, nick5) AND lvl2.full_name IN (nick1, nick2, nick3, nick4, nick5) AND ABS(lvl1.lvl - lvl2.lvl) > 5 LIMIT 1)) > 0
		THEN
		RAISE NOTICE 'Cannot create: lvl difference';
		RETURN;
	END IF;*/ --нерационально

	SELECT MIN(lvl) INTO min_lvl FROM "character" WHERE full_name IN (nick1, nick2, nick3, nick4, nick5);
	SELECT MAX(lvl) INTO max_lvl FROM "character" WHERE full_name IN (nick1, nick2, nick3, nick4, nick5);
	
	-- вторая проверка
	IF (ABS(max_lvl - min_lvl) > 5) THEN
		RAISE NOTICE 'Cannot create: lvl difference';
		RETURN;
	END IF;
	
	CREATE TEMP TABLE maps (
    	map_type VARCHAR(60)
	);
	
	INSERT INTO maps (map_type)
	VALUES ('\map1.jpeg'),
			('\map2.jpeg'),
			('\map3.jpeg'),
			('\map4.jpeg');
			
	SELECT * FROM maps ORDER BY RANDOM() LIMIT 1 INTO rand_map;
	
	INSERT INTO "event" (event_type_id, start_time, end_time, map_type, status, server_id, min_lvl, max_lvl, difficulty, lasting_bound)
	VALUES (1, NOW()::timestamp(0), NOW()::timestamp(0) + '1 hour'::interval, rand_map, 0, server_id_check, min_lvl,
			max_lvl,(max_lvl + min_lvl)/2, '00:00:00') RETURNING event_id INTO cur_event_id;
			
	INSERT INTO team (event_id, win_flag)
	VALUES (cur_event_id, false) RETURNING team_id INTO boss_team_id;
	
	random_amount := LEAST((SELECT COUNT(*) FROM boss),(floor(RANDOM() * (5 - 3 + 1)) + 3));
	
	CREATE TEMP TABLE boss_ids AS
	SELECT boss_id FROM boss ORDER BY RANDOM() LIMIT random_amount;
		
	INSERT INTO boss_row (boss_id, team_id, death_flag)
    SELECT boss_id, boss_team_id, false
    FROM boss_ids;

	INSERT INTO team (event_id, win_flag)
	VALUES (cur_event_id, false) RETURNING team_id INTO char_team_id;
	
	CREATE TEMP TABLE char_ids AS
	SELECT character_id FROM "character" WHERE full_name IN (nick1, nick2, nick3, nick4, nick5);
	
	INSERT INTO character_row (character_id, team_id, character_role_id, dealed_damage, received_damage, healed_damage, killed, death_flag)
	SELECT character_id, char_team_id,
	CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY char_team_id) = 1 THEN 1 
        WHEN ROW_NUMBER() OVER (PARTITION BY char_team_id) = 2 THEN 2  
        ELSE 3 
    END,
	0, 0, 0, 0, false
    FROM char_ids;
	
	DROP TABLE maps;
	DROP TABLE boss_ids;
	DROP TABLE char_ids;
END;	
$$;

SELECT * FROM "character";
SELECT * FROM "event";
SELECT * FROM team;
SELECT * FROM boss_row;
SELECT * FROM character_row;
SELECT * FROM boss_row;

CALL create_cave('elf323', 'elf17', 'elf18', 'elf19', 'elf20');
--dif server example
CALL create_cave('elf323', 'elf17', 'elf18', 'elf19', 'elf19_serv');
--dif level example
CALL create_cave('elf323', 'elf17', 'elf18', 'elf19', 'elf21');

CREATE OR REPLACE PROCEDURE finish_events()
LANGUAGE plpgsql
AS $$
DECLARE
    team1_id INT;
    team2_id INT;
	team1_sum INT;
	team2_sum INT;
	event_row RECORD;
BEGIN
	/*CREATE TEMP TABLE started_events AS
	SELECT event_id FROM "event" WHERE status = 1;*/
	
	/*FOR event_row IN SELECT * FROM "started_events" LOOP
        RAISE NOTICE 'id_event: %', event_row.event_id;
    END LOOP;*/
	
    FOR event_row IN SELECT event_id FROM "event" WHERE status = 1 LOOP
        SELECT team_id INTO team1_id FROM team WHERE event_id = event_row.event_id LIMIT 1;
        SELECT team_id INTO team2_id FROM team WHERE event_id = event_row.event_id OFFSET 1 LIMIT 1;
		
    	IF EXISTS (
        	SELECT 1 FROM character_row
        	WHERE team_id = team1_id
    	) THEN
			SELECT COALESCE(SUM(lvl), 0) FROM (SELECT character_id, lvl FROM "character" WHERE character_id IN (SELECT character_id FROM character_row WHERE team_id = team1_id AND death_flag = false))
			INTO team1_sum;
			RAISE NOTICE 'sum_char1: %, team1_id: %', team1_sum, team1_id;
		ELSE 
			SELECT COALESCE(SUM(lvl), 0) FROM (SELECT boss_id, lvl FROM boss WHERE boss_id IN (SELECT boss_id FROM boss_row WHERE team_id = team1_id AND death_flag = false))
			INTO team1_sum;
			RAISE NOTICE 'sum_mob1: %, team1_id: %', team1_sum, team1_id;
    	END IF;
		
		
		IF EXISTS (
        	SELECT 1 FROM character_row
        	WHERE team_id = team2_id
    	) THEN
			SELECT COALESCE(SUM(lvl), 0) FROM (SELECT character_id, lvl FROM "character" WHERE character_id IN (SELECT character_id FROM character_row WHERE team_id = team2_id AND death_flag = false))
			INTO team2_sum;
			RAISE NOTICE 'sum_char2: %, team2_id: %', team2_sum, team2_id;
		ELSE 
			SELECT COALESCE(SUM(lvl), 0) FROM (SELECT boss_id, lvl FROM boss WHERE boss_id IN (SELECT boss_id FROM boss_row WHERE team_id = team2_id AND death_flag = false))
			INTO team2_sum;
			RAISE NOTICE 'sum_mob2: %, team2_id: %', team2_sum, team2_id;
    	END IF;
		IF (team1_sum > team2_sum) THEN
			UPDATE team
			SET win_flag = true
			WHERE team_id = team1_id;
		END IF;
	
		IF (team1_sum < team2_sum) THEN
			UPDATE team
			SET win_flag = true
			WHERE team_id = team2_id;
		END IF;
		
		/*IF (team1_sum = team2_sum) THEN
			UPDATE team
			SET win_flag = true
			WHERE team_id IN (team1_id, team2_id);
		END IF;*/
		
    END LOOP;
	

	
	UPDATE "event"
	SET status = 0 WHERE status=1;
	
	
END;	
$$;

CALL finish_events(); --44 30 35 39

SELECT * FROM "server";
SELECT * FROM team WHERE team_id IN (34,35,30,31,36,37,39,40,43,44,45,46);
SELECT * FROM team WHERE win_flag = true;
SELECT * FROM "event" WHERE status=1; 

UPDATE "event"
SET status = 1
WHERE status = 0 AND event_id IN (29, 35, 34, 33, 31, 30);

UPDATE team
SET win_flag = false
WHERE event_id IN (29, 35, 34, 33, 31, 30);


SELECT * FROM "character";

SELECT * FROM character_row;

SELECT * FROM boss_row

--менять дез флаг
UPDATE character_row
SET death_flag = true
WHERE team_id = 31 AND character_id IN (5,6);

UPDATE boss_row
SET death_flag = true
WHERE team_id = 34 AND boss_id IN (9,1,4,6);

--проверка сумм
SELECT SUM(lvl) FROM (SELECT character_id, lvl FROM "character" WHERE character_id IN (SELECT character_id FROM character_row WHERE team_id = 35 AND death_flag = false));
SELECT SUM(lvl) FROM (SELECT boss_id, lvl FROM boss WHERE boss_id IN (SELECT boss_id FROM boss_row WHERE team_id = 34 AND death_flag = false));

SELECT full_name AS namee, lvl AS levell, server_type AS "server", SUM(lvl)
FROM "character"
INNER JOIN "server" ON "character".server_id = "server".server_id
WHERE full_name='elf21' OR full_name='elf20'
GROUP BY full_name, server_type;
 
SELECT COUNT(*) FROM "event" WHERE (S)
