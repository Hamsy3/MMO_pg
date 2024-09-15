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
INSERT INTO profession DEFAULT VALUES;
INSERT INTO fraction DEFAULT VALUES;
INSERT INTO race (fraction_id)
VALUES (1);
INSERT INTO combination (profession_id, race_id, fraction_id)
VALUES(1,1,2);
INSERT INTO "character" DEFAULT VALUES;
INSERT INTO event_type (full_name, description, max_players)
VALUES ('cave', 'cool', 25),
		('raid', 'really cool', 25),
		('battleground', 'not really cool', 10);
INSERT INTO team DEFAULT VALUES;
INSERT INTO character_role DEFAULT VALUES;
INSERT INTO character_row DEFAULT VALUES;
INSERT INTO boss DEFAULT VALUES;
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
VALUES (2, '2024-03-27 15:30:00', '2024-03-27 16:30:00', '\map.jpeg', 0, 1, 5, 10, 7, '00:00:00');

SELECT * FROM team;
SELECT * FROM boss_row;

DROP TRIGGER trigger_pve ON "event";
DROP FUNCTION trigger_pve_func();