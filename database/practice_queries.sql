-- Practice queries for test_data.sql
-- Try writing each one yourself first; the answer is right below the question.
-- Run one at a time by pasting into the MariaDB prompt.

USE PotH;

-- 1. List every table and how many rows it has.
SELECT 'Volume' AS tbl, COUNT(*) FROM Volume
UNION ALL SELECT 'Article', COUNT(*) FROM Article
UNION ALL SELECT 'Paragraph', COUNT(*) FROM Paragraph
UNION ALL SELECT 'People', COUNT(*) FROM People
UNION ALL SELECT 'Name_Entry', COUNT(*) FROM Name_Entry
UNION ALL SELECT 'Places', COUNT(*) FROM Places
UNION ALL SELECT 'Where_Person_Mentioned', COUNT(*) FROM Where_Person_Mentioned
UNION ALL SELECT 'Where_Place_Mentioned', COUNT(*) FROM Where_Place_Mentioned;

-- 2. (one table) Every person, sorted by display name.
SELECT pid, display_name FROM People ORDER BY display_name;

-- 3. (WHERE + LIKE) Everyone whose last name starts with "W".
SELECT pid, raw_name FROM Name_Entry WHERE Last_Name LIKE 'W%';

-- 4. (accent-insensitive search) Find Böhmcker without typing the ö.
SELECT pid, raw_name FROM Name_Entry WHERE Last_Name = 'Bohmcker';

-- 5. (one join) Which place is each article about?
SELECT a.artid, a.title, pl.name AS place
FROM Article a
LEFT JOIN Places pl ON pl.lid = a.lid;

-- 6. (two joins) Every paragraph that mentions Hugo Krack (pid 7701), in order.
SELECT p.artid, p.`position`, p.start_page, p.`text`
FROM Where_Person_Mentioned wpm
JOIN Paragraph p ON p.parid = wpm.parid
WHERE wpm.pid = 7701
ORDER BY p.artid, p.`position`;

-- 7. (GROUP BY) Who is mentioned the most? Top 5.
SELECT pe.display_name, COUNT(*) AS paragraphs
FROM Where_Person_Mentioned wpm
JOIN People pe ON pe.pid = wpm.pid
GROUP BY pe.pid, pe.display_name
ORDER BY paragraphs DESC
LIMIT 5;

-- 8. (one person, many names) Which people have more than one name entry?
SELECT pid, COUNT(*) AS names, GROUP_CONCAT(raw_name SEPARATOR ' | ') AS all_names
FROM Name_Entry
GROUP BY pid
HAVING COUNT(*) > 1;

-- 9. (citation) Build a citation for every mention of Tenhaaf:
--    article title, volume, page(s).
SELECT pe.display_name, a.title, v.vid AS volume,
       CASE WHEN p.start_page = p.end_page THEN CONCAT('p. ', p.start_page)
            ELSE CONCAT('pp. ', p.start_page, '-', p.end_page) END AS pages
FROM Where_Person_Mentioned wpm
JOIN People pe   ON pe.pid  = wpm.pid
JOIN Paragraph p ON p.parid = wpm.parid
JOIN Article a   ON a.artid = p.artid
JOIN Volume v    ON v.vid   = a.vid
WHERE pe.display_name LIKE '%Tenhaaf%';

-- 10. (person -> places) Every place mentioned in the same paragraph as Krack.
SELECT DISTINCT pl.name
FROM Where_Person_Mentioned wpm
JOIN Where_Place_Mentioned wplm ON wplm.parid = wpm.parid
JOIN Places pl                  ON pl.lid     = wplm.lid
WHERE wpm.pid = 7701;

-- 11. (mentioned with) Pairs of people mentioned in the same paragraph, most often first.
SELECT p1.display_name AS person, p2.display_name AS mentioned_with, COUNT(*) AS times
FROM Where_Person_Mentioned a
JOIN Where_Person_Mentioned b ON a.parid = b.parid AND a.pid < b.pid
JOIN People p1 ON p1.pid = a.pid
JOIN People p2 ON p2.pid = b.pid
GROUP BY p1.display_name, p2.display_name
ORDER BY times DESC;

-- 12. (NOT EXISTS) Paragraphs that mention no one at all.
SELECT p.parid, p.artid, p.`position`
FROM Paragraph p
WHERE NOT EXISTS (SELECT 1 FROM Where_Person_Mentioned w WHERE w.parid = p.parid);
