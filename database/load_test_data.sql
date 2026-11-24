-- Load the test_data CSV files into PotH.
--
-- LOAD DATA LOCAL reads files from the folder you were in when you started
-- mariadb, so start it from ~/database with LOCAL INFILE turned on:
--   cd ~/database
--   mariadb --local-infile=1 -u poth -p
--   source PoTH.sql;          -- only if the tables don't exist yet
--   source load_test_data.sql;

USE PotH;

-- Start clean so this script can be re-run (children before parents)
DELETE FROM Where_Place_Mentioned;
DELETE FROM Where_Person_Mentioned;
DELETE FROM Name_Entry;
DELETE FROM People;
DELETE FROM Paragraph;
DELETE FROM Article;
DELETE FROM Places;
DELETE FROM Volume;

-- ---------- Step 1: reference tables (loaded once, not from the NLP) ----------

LOAD DATA LOCAL INFILE 'test_data/volumes.csv'
INTO TABLE Volume CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(vid, title, citation, url);

LOAD DATA LOCAL INFILE 'test_data/places.csv'
INTO TABLE Places CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(lid, name, type, subtype, current_country, latitude, longitude, location_accuracy);

LOAD DATA LOCAL INFILE 'test_data/people.csv'
INTO TABLE People CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(pid, kind, display_name);

-- entry_id is left out, so MariaDB numbers the rows itself
LOAD DATA LOCAL INFILE 'test_data/name_entries.csv'
INTO TABLE Name_Entry CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(pid, raw_name, First_Name, Middle_Name, Last_Name, Title);

-- ---------- Step 2: NLP output ----------

LOAD DATA LOCAL INFILE 'test_data/articles.csv'
INTO TABLE Article CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artid, vid, lid, title, url);

-- parid is left out, so MariaDB assigns it
LOAD DATA LOCAL INFILE 'test_data/paragraphs.csv'
INTO TABLE Paragraph CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artid, `position`, start_page, end_page, `text`);

-- ---------- Step 3: mentions ----------
-- The NLP names a paragraph by (artid, position) because it never sees parid.
-- Load each file into a temporary "staging" table, then look up parid with a join.
-- Temporary tables disappear when you log out.

CREATE TEMPORARY TABLE stage_person_mentions (artid INT, `position` INT, pid INT);
CREATE TEMPORARY TABLE stage_place_mentions  (artid INT, `position` INT, lid INT);

LOAD DATA LOCAL INFILE 'test_data/person_mentions.csv'
INTO TABLE stage_person_mentions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artid, `position`, pid);

LOAD DATA LOCAL INFILE 'test_data/place_mentions.csv'
INTO TABLE stage_place_mentions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(artid, `position`, lid);

INSERT INTO Where_Person_Mentioned (parid, pid)
SELECT p.parid, s.pid
FROM stage_person_mentions s
JOIN Paragraph p ON p.artid = s.artid AND p.`position` = s.`position`;

INSERT INTO Where_Place_Mentioned (parid, lid)
SELECT p.parid, s.lid
FROM stage_place_mentions s
JOIN Paragraph p ON p.artid = s.artid AND p.`position` = s.`position`;

-- ---------- Step 4: check the load ----------

-- Mentions whose (artid, position) matched no paragraph. Should return nothing.
SELECT 'person' AS kind, s.artid, s.`position`, s.pid AS id
FROM stage_person_mentions s
LEFT JOIN Paragraph p ON p.artid = s.artid AND p.`position` = s.`position`
WHERE p.parid IS NULL
UNION ALL
SELECT 'place', s.artid, s.`position`, s.lid
FROM stage_place_mentions s
LEFT JOIN Paragraph p ON p.artid = s.artid AND p.`position` = s.`position`
WHERE p.parid IS NULL;

-- Row counts. Expected: 1, 5, 21, 22, 2, 20, 41, 18
SELECT 'Volume' AS tbl, COUNT(*) AS n FROM Volume
UNION ALL SELECT 'Places', COUNT(*) FROM Places
UNION ALL SELECT 'People', COUNT(*) FROM People
UNION ALL SELECT 'Name_Entry', COUNT(*) FROM Name_Entry
UNION ALL SELECT 'Article', COUNT(*) FROM Article
UNION ALL SELECT 'Paragraph', COUNT(*) FROM Paragraph
UNION ALL SELECT 'Where_Person_Mentioned', COUNT(*) FROM Where_Person_Mentioned
UNION ALL SELECT 'Where_Place_Mentioned', COUNT(*) FROM Where_Place_Mentioned;

DROP TEMPORARY TABLE stage_person_mentions;
DROP TEMPORARY TABLE stage_place_mentions;
