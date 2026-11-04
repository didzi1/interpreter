-- Danielle's testing with MariaDB 11/4
-- PotH schema: empty tables matching the final diagram
--
-- pid   = person ID
-- lid   = location (place) ID
-- vid   = volume ID
-- artid = article ID (the Project MUSE document number, e.g. /document/1261 -> 1261)
-- parid = paragraph ID

USE PotH;

ALTER DATABASE PotH CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Drop everything so this file can be re-run from scratch
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Where_Place_Mentioned, Where_Person_Mentioned,
                     Name_Entry, People, Paragraph, Article, Places, Volume;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------- Encyclopedia text ----------

CREATE TABLE Volume (
  vid       INT PRIMARY KEY,
  title     VARCHAR(255),
  citation  VARCHAR(500),
  url       VARCHAR(500)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- Places ----------
-- (created before Article because Article references it)

CREATE TABLE Places (
  lid                INT PRIMARY KEY,
  name               VARCHAR(255) NOT NULL,
  type               VARCHAR(100),
  subtype            VARCHAR(100),
  current_country    VARCHAR(100),
  latitude           DOUBLE,
  longitude          DOUBLE,
  location_accuracy  VARCHAR(50),
  INDEX idx_places_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Article (
  artid  INT PRIMARY KEY,
  vid    INT NOT NULL,
  lid    INT,                      -- the place this article is about
  title  VARCHAR(255),
  url    VARCHAR(500),
  FOREIGN KEY (vid) REFERENCES Volume(vid),
  FOREIGN KEY (lid) REFERENCES Places(lid) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Paragraph (
  parid       INT AUTO_INCREMENT PRIMARY KEY,
  artid       INT NOT NULL,
  `position`  INT NOT NULL,        -- order within the article
  start_page  INT NOT NULL,        -- from the [End Page N] markers
  end_page    INT NOT NULL,        -- same as start_page unless it crosses a page break
  `text`      TEXT NOT NULL,
  UNIQUE KEY uq_paragraph_artid_position (artid, `position`),
  FOREIGN KEY (artid) REFERENCES Article(artid) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- People ----------

CREATE TABLE People (
  pid           INT PRIMARY KEY,
  kind          ENUM('individual', 'family', 'brothers') NOT NULL DEFAULT 'individual',
  display_name  VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Each name a person is listed under is its own row (e.g. Göth and Goeth -> same pid)
CREATE TABLE Name_Entry (
  entry_id     INT AUTO_INCREMENT PRIMARY KEY,
  pid          INT NOT NULL,
  raw_name     VARCHAR(255) NOT NULL,   -- exactly as in the encyclopedia name index
  First_Name   VARCHAR(100),
  Middle_Name  VARCHAR(100),
  Last_Name    VARCHAR(100),
  Title        VARCHAR(100),
  INDEX idx_name_last (Last_Name),
  INDEX idx_name_first_last (First_Name, Last_Name),
  FOREIGN KEY (pid) REFERENCES People(pid) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- Where each person/place is mentioned ----------
-- One row per person (or place) per paragraph, enforced by the primary key.
-- Citation: paragraph -> article -> volume, plus the paragraph's pages.

CREATE TABLE Where_Person_Mentioned (
  parid  INT NOT NULL,
  pid    INT NOT NULL,
  PRIMARY KEY (parid, pid),
  INDEX idx_wpm_pid (pid),
  FOREIGN KEY (parid) REFERENCES Paragraph(parid) ON DELETE CASCADE,
  FOREIGN KEY (pid)   REFERENCES People(pid)      ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Where_Place_Mentioned (
  parid  INT NOT NULL,
  lid    INT NOT NULL,
  PRIMARY KEY (parid, lid),
  INDEX idx_wplm_lid (lid),
  FOREIGN KEY (parid) REFERENCES Paragraph(parid) ON DELETE CASCADE,
  FOREIGN KEY (lid)   REFERENCES Places(lid)      ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;