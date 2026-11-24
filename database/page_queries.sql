-- Everything a website page would need, a few queries per page.
-- Change the SET line at the top of a section to look at a different person/place,
-- then run that section. Tip: end a query with \G instead of ; to show long
-- paragraph text one field per line instead of in a very wide table.

USE PotH;

-- Make the search text use the same character set/collation as the tables
-- (avoids "Illegal mix of collations" and keeps the ö in Böhmcker intact)
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- =====================================================================
-- SEARCH PAGE: what someone typed in the search box
-- =====================================================================
SET @q = 'krack';

-- Matches any name entry (all spellings), accent-insensitive: 'bohm' finds Böhmcker
SELECT DISTINCT pe.pid, pe.display_name, ne.raw_name AS matched_name
FROM Name_Entry ne
JOIN People pe ON pe.pid = ne.pid
WHERE ne.Last_Name  LIKE CONCAT(@q, '%')
   OR ne.First_Name LIKE CONCAT(@q, '%')
   OR ne.raw_name   LIKE CONCAT('%', @q, '%')
ORDER BY pe.display_name;


-- =====================================================================
-- PERSON PAGE
-- =====================================================================
SET @pid = 7701;   -- Hugo Krack. Try 1950 (Böhmcker) or 10916 (two name entries)

-- 1. Header: name, kind, every way they're listed, any titles
SELECT pe.display_name, pe.kind,
       GROUP_CONCAT(DISTINCT ne.raw_name SEPARATOR ' | ') AS listed_as,
       GROUP_CONCAT(DISTINCT ne.Title SEPARATOR ', ')     AS titles
FROM People pe
LEFT JOIN Name_Entry ne ON ne.pid = pe.pid
WHERE pe.pid = @pid
GROUP BY pe.pid, pe.display_name, pe.kind;

-- 2. Every mention, with its citation and the paragraph text
SELECT a.title AS article, v.vid AS volume,
       CASE WHEN p.start_page = p.end_page THEN CONCAT('p. ', p.start_page)
            ELSE CONCAT('pp. ', p.start_page, '-', p.end_page) END AS pages,
       p.`position` AS paragraph, p.`text`, a.url
FROM Where_Person_Mentioned w
JOIN Paragraph p ON p.parid = w.parid
JOIN Article a   ON a.artid = p.artid
JOIN Volume v    ON v.vid   = a.vid
WHERE w.pid = @pid
ORDER BY v.vid, a.title, p.`position`;

-- 3. Connected places (for a map): named next to them, or the subject of an article about them
SELECT pl.lid, pl.name, pl.type, pl.latitude, pl.longitude,
       'named in the same paragraph' AS connection
FROM Where_Person_Mentioned w
JOIN Where_Place_Mentioned wp ON wp.parid = w.parid
JOIN Places pl                ON pl.lid   = wp.lid
WHERE w.pid = @pid
UNION
SELECT pl.lid, pl.name, pl.type, pl.latitude, pl.longitude,
       'its article mentions them'
FROM Where_Person_Mentioned w
JOIN Paragraph p ON p.parid = w.parid
JOIN Article a   ON a.artid = p.artid
JOIN Places pl   ON pl.lid  = a.lid
WHERE w.pid = @pid
ORDER BY name, connection;

-- 4. People mentioned with them, most shared paragraphs first
SELECT other.pid, other.display_name, COUNT(*) AS shared_paragraphs
FROM Where_Person_Mentioned me
JOIN Where_Person_Mentioned o ON o.parid = me.parid AND o.pid <> me.pid
JOIN People other             ON other.pid = o.pid
WHERE me.pid = @pid
GROUP BY other.pid, other.display_name
ORDER BY shared_paragraphs DESC, other.display_name;


-- =====================================================================
-- PLACE PAGE
-- =====================================================================
SET @lid = 479;   -- Moringen-Solling. Try 3 (Ahrensbök) or 555 (Papenburg: no article of its own)

-- 1. Header and map pin
SELECT name, type, subtype, current_country, latitude, longitude, location_accuracy
FROM Places
WHERE lid = @lid;

-- 2. The encyclopedia article(s) about this place
SELECT a.title, v.vid AS volume, v.title AS volume_title, a.url
FROM Article a
JOIN Volume v ON v.vid = a.vid
WHERE a.lid = @lid;

-- 3. The article text, in order
SELECT p.`position` AS paragraph,
       CASE WHEN p.start_page = p.end_page THEN CONCAT('p. ', p.start_page)
            ELSE CONCAT('pp. ', p.start_page, '-', p.end_page) END AS pages,
       p.`text`
FROM Paragraph p
JOIN Article a ON a.artid = p.artid
WHERE a.lid = @lid
ORDER BY a.artid, p.`position`;

-- 4. People in this place's article, and which paragraphs
SELECT pe.pid, pe.display_name, COUNT(*) AS paragraphs,
       GROUP_CONCAT(p.`position` ORDER BY p.`position`) AS in_paragraphs
FROM Article a
JOIN Paragraph p              ON p.artid  = a.artid
JOIN Where_Person_Mentioned w ON w.parid  = p.parid
JOIN People pe                ON pe.pid   = w.pid
WHERE a.lid = @lid
GROUP BY pe.pid, pe.display_name
ORDER BY paragraphs DESC, pe.display_name;

-- 5. Other articles that mention this place
SELECT a.title AS mentioned_in, p.`position` AS paragraph,
       CASE WHEN p.start_page = p.end_page THEN CONCAT('p. ', p.start_page)
            ELSE CONCAT('pp. ', p.start_page, '-', p.end_page) END AS pages
FROM Where_Place_Mentioned wp
JOIN Paragraph p ON p.parid = wp.parid
JOIN Article a   ON a.artid = p.artid
WHERE wp.lid = @lid
  AND (a.lid IS NULL OR a.lid <> @lid)
ORDER BY a.title, p.`position`;
