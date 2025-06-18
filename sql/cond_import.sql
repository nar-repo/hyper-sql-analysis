
--script creates the 'conditions' table and imports data from a
-- CSV file, safely handling potentially missing or inconsistent data.

--CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


CREATE TABLE IF NOT EXISTS conditions (
    id TEXT PRIMARY KEY,
    "START" TIMESTAMP WITH TIME ZONE,
    "STOP" TIMESTAMP WITH TIME ZONE,
    "PATIENT" TEXT,
    "ENCOUNTER" TEXT,
    "CODE" TEXT,
    "DESCRIPTION" TEXT
);



-- temporary staging table for the raw CSV lines.

CREATE TEMP TABLE conditions_staging (line_text TEXT);


-- copy the raw data from the CSV into the staging table.
\copy conditions_staging FROM 'C:/Users/Nari/hyper-sql-analysis/data/conditions_utf8.csv' WITH (FORMAT TEXT, HEADER TRUE);


--parse the raw text and insert it into the final <conditions> table.
INSERT INTO conditions (id, "START", "STOP", "PATIENT", "ENCOUNTER", "CODE", "DESCRIPTION")
SELECT
    'cond-' || uuid_generate_v4(),
    NULLIF(split_part(line_text, ',', 1), '')::TIMESTAMP WITH TIME ZONE,  -- START date
    NULLIF(split_part(line_text, ',', 2), '')::TIMESTAMP WITH TIME ZONE,  -- STOP date
    NULLIF(split_part(line_text, ',', 3), ''),                           -- PATIENT
    NULLIF(split_part(line_text, ',', 4), ''),                           -- ENCOUNTER (becomes NULL if empty)
    NULLIF(split_part(line_text, ',', 5), ''),                           -- CODE
    NULLIF(split_part(line_text, ',', 6), '')                            -- DESCRIPTION
FROM
    conditions_staging;


--clean up the temporary table.
DROP TABLE conditions_staging;


