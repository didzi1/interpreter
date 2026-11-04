-- PotH practice data, built from two Volume I articles:
--   https://muse.jhu.edu/document/1261  (Ahrensbök-Holstendorf)
--   https://muse.jhu.edu/document/1330  (Moringen-Solling, men)
--
-- Run PoTH.sql first (it creates empty tables), then this file:
--   source PoTH.sql;
--   source test_data.sql;
--
-- IDs are the real ones from the interpreter's tables:
--   pid = row index in ecg_interpreter/tables/people_table.csv
--   lid = LID in ecg_interpreter/tables/place_table.csv
--   artid = the MUSE document number
-- Paragraph text is a short paraphrase for practice, NOT the encyclopedia's
-- wording. The real pipeline would store each paragraph's full text.
-- Page numbers follow the [End Page N] markers: text after the marker is on page N+1.

USE PotH;

-- Lets this file be re-run: clear old practice rows first (children before parents)
DELETE FROM Where_Place_Mentioned;
DELETE FROM Where_Person_Mentioned;
DELETE FROM Name_Entry;
DELETE FROM People;
DELETE FROM Paragraph;
DELETE FROM Article;
DELETE FROM Places;
DELETE FROM Volume;

-- ---------- Volume ----------

INSERT INTO Volume (vid, title, citation, url) VALUES
(1,
 'Volume I: Early Camps, Youth Camps, and Concentration Camps and Subcamps under the SS-Business Administration Main Office (WVHA)',
 'Megargee, G. P. (Ed.). The United States Holocaust Memorial Museum Encyclopedia of Camps and Ghettos, Volume I. United States Holocaust Memorial Museum, 2009.',
 'https://muse.jhu.edu/resource_group/13');

-- ---------- Places (values copied from place_table.csv) ----------
-- Note: place_table.csv has lat/long 52.6, 11.75 for Moringen-Solling, which is
-- not where Moringen is (about 51.70, 9.87). Copied as-is; worth fixing in the CSV.

INSERT INTO Places (lid, name, type, subtype, current_country, latitude, longitude, location_accuracy) VALUES
(3,   'Ahrensbök-Holstendorf', 'Early Concentration Camp', NULL, 'Germany', 54.0167, 10.5833, 'Exact'),
(182, 'Eutin',                 'Early Concentration Camp', NULL, 'Germany', 54.1333, 10.6167, 'Exact'),
(479, 'Moringen-Solling',      'Early Concentration Camp', NULL, 'Germany', 52.6000, 11.7500, 'Exact'),
(547, 'Oranienburg',           'Early Concentration Camp', NULL, 'Germany', 52.7500, 13.2333, 'Exact'),
(555, 'Papenburg (Elmsland)',  'Early Concentration Camp', NULL, 'Germany', 53.0667, 7.4000,  'Exact');

-- ---------- Articles ----------
-- 1330 is NOT in vol1_article_links.csv: scrape_vol matches the article title to a
-- place name exactly, and "Moringen-Solling (men)" != "Moringen-Solling".
-- Its lid is filled in by hand here.

INSERT INTO Article (artid, vid, lid, title, url) VALUES
(1261, 1, 3,   'AHRENSBÖK-HOLSTENDORF',  'https://muse.jhu.edu/document/1261'),
(1330, 1, 479, 'MORINGEN-SOLLING (men)', 'https://muse.jhu.edu/document/1330');

-- ---------- Paragraphs ----------
-- parid is AUTO_INCREMENT, but we set it by hand (1xx = article 1261, 2xx = 1330)
-- so the mention rows below are easy to read.

INSERT INTO Paragraph (parid, artid, `position`, start_page, end_page, `text`) VALUES
(101, 1261, 1, 17, 17, 'In October 1933 a camp opened in a former sugar mill building at Holstendorf, near Ahrensbök, to take pressure off overcrowded custody sites in Eutin and Bad Schwartau. Johann Heinrich Böhmcker set it up to hold a few dozen prisoners for road work; in December 1933 the prisoners were moved to an old shoe factory in Ahrensbök.'),
(102, 1261, 2, 17, 17, 'Until the camp closed in May 1934, at least 94 people were held at Ahrensbök, most of them Communists, along with Social Democrats, conservative opponents, and even rivals of Böhmcker inside his own party.'),
(103, 1261, 3, 17, 17, 'The Ahrensbök camp grew out of Böhmcker''s personal initiative: it gave work to SA men he made auxiliary police, and he used it to pressure wealthy opponents, until the Oldenburg Gestapo reprimanded him. He also wrote his own rules so prisoners could be used for labor.'),
(104, 1261, 4, 17, 17, 'Böhmcker picked Holstendorf so prisoners could finish an unfinished Labor Service road project. Unlike most early camps, Ahrensbök worked like a forced labor camp, and the Reich paid for the work.'),
(105, 1261, 5, 17, 17, 'Treasury records show Reich payments for the camp, and camp commandant Theodor Christian Tenhaaf''s postmark appears on the paperwork. The Lübeck district, where Böhmcker had held power since 1932, became an early testing ground for persecution; at least 345 residents were taken into custody within a year.'),
(106, 1261, 6, 17, 18, 'No prisoners died at Ahrensbök, but there was mistreatment. After the war, Tenhaaf and some guards were tried in Lübeck, and Tenhaaf received a prison sentence of three and a half years.'),

(201, 1330, 1,  125, 125, 'The Hannover police opened a camp inside the Moringen workhouse in April 1933, with Müller as its first commandant. The institution had long served as an orphanage, prison, and workhouse.'),
(202, 1330, 2,  126, 126, 'In March 1933, Gottschick of Hannover asked workhouse director Hugo Krack about housing a 200-prisoner camp at Moringen. Krack moved the infirmary to make room and set a daily charge per detainee.'),
(203, 1330, 3,  126, 126, 'The men''s camp held about 321 detainees a month, but most were released within weeks, according to medical files studied by Hans Hesse. Most were Communists; Hermann Wenskowski recalled the first Jehovah''s Witness arriving at Moringen in June 1933.'),
(204, 1330, 4,  126, 126, 'Müller arrived with about 50 Hannover police officers plus local SA, SS, and Stahlhelm deputies. He and Krack wrote house rules based on reeducation, and Krack clashed with each commandant over who was in charge.'),
(205, 1330, 5,  126, 126, 'Prisoners were encouraged to attend chapel services. Attendance rose quickly, and Müller later found that prisoners were using the chapel for secret political meetings.'),
(206, 1330, 6,  126, 126, 'On May 1, 1933, the detainees were put on display and made to listen to Nazi radio, and a local paper praised Moringen''s discipline. By the end of May, 300 detainees had been released.'),
(207, 1330, 7,  126, 126, 'In June 1933, Stockhofe became the new commandant, and the first women detainees arrived at Moringen.'),
(208, 1330, 8,  126, 126, 'After guards silenced prisoners singing Communist songs, 28 prisoners began a hunger strike at Moringen, organized by August Baumgarte, Johannes Engelke, Kurt Fröse, August Steffens, August Tünnermann, and Viktor Zudrowitz. Stockhofe blamed newly arrived detainees from Osnabrück.'),
(209, 1330, 9,  126, 126, 'To break the strike, Krack isolated the strikers and ordered their water cut off, despite early objections from Stockhofe and the physician Otto Wolten-Pecksen. Krack told Bergin of the Hannover police he did not care about the consequences. Baumgarte later described the thirst. The strike ended after a few days with a promise of better food.'),
(210, 1330, 10, 126, 126, 'As punishment for the strike, the police sharply limited prisoners'' mail and parcels.'),
(211, 1330, 11, 126, 126, 'In August 1933, Otto Cordes of the SS took command of Moringen, following Heinrich Himmler''s takeover of police authority. Krack had already asked Bergin to replace the police guards with SS men. Few detainees had work.'),
(212, 1330, 12, 126, 127, 'Friedrich Flohr became the last commandant in September and imposed a harsher regime at Moringen. Prisoners were beaten and tortured; Otto Bokelmann died from torture, and August Witte died of injuries from an earlier police prison. Krack complained about the SS violence.'),
(213, 1330, 13, 127, 127, 'In the fall of 1933, Moringen was turned into a women''s camp. Men were sent to Papenburg in exchange for women, and the remaining men went to Oranienburg. Krack ran the women''s camp until 1938.'),
(214, 1330, 14, 127, 127, 'Cordes died in 1944. In 1948, a Göttingen court sentenced Flohr for crimes against humanity, and Krack and Wolter-Pecksen testified against him.');

-- ---------- People ----------
-- display_name is built by us; the CSV only has the name parts.
-- 10184 is the Müller row with no first name. The article never gives Müller's
-- first name, and the CSV has 30+ Müllers, so this is a guess. That ambiguity is
-- exactly what the NLP's is_key() returns -2 for.

INSERT INTO People (pid, kind, display_name) VALUES
(710,   'individual', 'August Baumgarte'),
(946,   'individual', 'Bergin'),
(1350,  'individual', 'Otto Bokelmann'),
(1950,  'individual', 'Johann Heinrich Böhmcker'),
(2295,  'individual', 'Otto Cordes'),
(3222,  'individual', 'Johannes Engelke'),
(3722,  'individual', 'Friedrich Flohr'),
(4020,  'individual', 'Kurt Fröse'),
(4768,  'individual', 'Gottschick'),
(5761,  'individual', 'Hans Hesse'),
(5827,  'individual', 'Heinrich Himmler'),
(7701,  'individual', 'Hugo Krack'),
(10184, 'individual', 'Müller'),
(10916, 'individual', 'Otto Wolten-Pecksen'),
(14130, 'individual', 'August Steffens'),
(14253, 'individual', 'Stockhofe'),
(14784, 'individual', 'Theodor Christian Tenhaaf'),
(15136, 'individual', 'August Tünnermann'),
(15911, 'individual', 'Hermann Wenskowski'),
(16141, 'individual', 'August Witte'),
(16686, 'individual', 'Viktor Zudrowitz');

-- ---------- Name_Entry ----------
-- raw_name is written the way the encyclopedia name index lists it ("Last, First").
-- Title holds the rank/role the article gives (the CSV's Title column is empty for these).
-- Wolten-Pecksen has TWO index entries (see raw_names.csv), so two rows, same pid.

INSERT INTO Name_Entry (pid, raw_name, First_Name, Middle_Name, Last_Name, Title) VALUES
(710,   'Baumgarte, August',              'August',   NULL,        'Baumgarte',      NULL),
(946,   'Bergin',                         NULL,       NULL,        'Bergin',         'Polizeimajor'),
(1350,  'Bokelmann, Otto',                'Otto',     NULL,        'Bokelmann',      NULL),
(1950,  'Böhmcker, Johann Heinrich',      'Johann',   'Heinrich',  'Böhmcker',       'Regierungspräsident'),
(2295,  'Cordes, Otto',                   'Otto',     NULL,        'Cordes',         'SS-Sturmführer'),
(3222,  'Engelke, Johannes',              'Johannes', NULL,        'Engelke',        NULL),
(3722,  'Flohr, Friedrich',               'Friedrich',NULL,        'Flohr',          'SS-Sturmhauptführer'),
(4020,  'Fröse, Kurt',                    'Kurt',     NULL,        'Fröse',          NULL),
(4768,  'Gottschick',                     NULL,       NULL,        'Gottschick',     'Oberinspektor'),
(5761,  'Hesse, Hans',                    'Hans',     NULL,        'Hesse',          NULL),
(5827,  'Himmler, Heinrich',              'Heinrich', NULL,        'Himmler',        NULL),
(7701,  'Krack, Hugo',                    'Hugo',     NULL,        'Krack',          'Lagerdirektor'),
(10184, 'Müller',                         NULL,       NULL,        'Müller',         'Polizeioberleutnant'),
(10916, 'Wolten-Pecksen, Otto',           'Otto',     NULL,        'Wolten-Pecksen', 'Dr.'),
(10916, 'Pecksen: Wolten-Pecksen, Otto',  'Otto',     NULL,        'Wolten-Pecksen', 'Dr.'),
(14130, 'Steffens, August',               'August',   NULL,        'Steffens',       NULL),
(14253, 'Stockhofe',                      NULL,       NULL,        'Stockhofe',      'Polizeihauptmann'),
(14784, 'Tenhaaf, Theodor Christian',     'Theodor',  'Christian', 'Tenhaaf',        NULL),
(15136, 'Tünnermann, August',             'August',   NULL,        'Tünnermann',     NULL),
(15911, 'Wenskowski, Hermann',            'Hermann',  NULL,        'Wenskowski',     NULL),
(16141, 'Witte, August',                  'August',   NULL,        'Witte',          NULL),
(16686, 'Zudrowitz, Viktor',              'Viktor',   NULL,        'Zudrowitz',      NULL);

-- ---------- Where_Person_Mentioned ----------
-- One row per (paragraph, person). This is what the NLP will eventually produce.

INSERT INTO Where_Person_Mentioned (parid, pid) VALUES
-- Ahrensbök
(101, 1950), (102, 1950), (103, 1950), (104, 1950),
(105, 14784), (105, 1950),
(106, 14784),
-- Moringen
(201, 10184),
(202, 4768), (202, 7701),
(203, 5761), (203, 15911),
(204, 10184), (204, 7701),
(205, 10184),
(207, 14253),
(208, 710), (208, 3222), (208, 4020), (208, 14130), (208, 15136), (208, 16686), (208, 14253),
(209, 7701), (209, 14253), (209, 10916), (209, 946), (209, 710),
(211, 2295), (211, 5827), (211, 7701), (211, 946),
(212, 3722), (212, 1350), (212, 16141), (212, 7701),
(213, 7701),
(214, 2295), (214, 3722), (214, 7701), (214, 10916);

-- ---------- Where_Place_Mentioned ----------
-- Only places that have a row in Places. Bad Schwartau, Göttingen and the
-- Leonhardtstrasse prison are not in place_table.csv. "Osnabrück" in paragraph 208
-- is NOT linked: the Osnabrück rows in place_table.csv are later Neuengamme/Buchenwald
-- subcamps, a different place with the same name.

INSERT INTO Where_Place_Mentioned (parid, lid) VALUES
(101, 3), (101, 182),
(102, 3), (103, 3), (104, 3), (105, 3), (106, 3),
(201, 479), (202, 479), (203, 479), (206, 479), (207, 479), (208, 479),
(211, 479), (212, 479), (213, 479), (213, 555), (213, 547);
