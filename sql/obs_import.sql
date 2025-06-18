
CREATE TABLE IF NOT EXISTS observations (
    id TEXT PRIMARY KEY,
    "DATE" TIMESTAMP WITH TIME ZONE,
    "PATIENT" TEXT,
    "ENCOUNTER" TEXT,
    "CATEGORY" TEXT,
    "CODE" TEXT,
    "DESCRIPTION" TEXT,
    "VALUE" TEXT,
    "UNITS" TEXT,
    "TYPE" TEXT
);


CREATE TEMP TABLE observations_staging (line_text TEXT);

\copy observations_staging FROM 'C:/Users/Nari/hyper-sql-analysis/data/observations_utf8.csv'  WITH (FORMAT TEXT, HEADER TRUE);


INSERT INTO observations (id, "DATE", "PATIENT", "ENCOUNTER", "CATEGORY", "CODE", "DESCRIPTION", "VALUE", "UNITS", "TYPE")
SELECT
 
    'obs-' || uuid_generate_v4(),
    NULLIF(split_part(line_text, ',', 1), '')::TIMESTAMP WITH TIME ZONE,  -- DATE
    NULLIF(split_part(line_text, ',', 2), ''),                           -- PATIENT
    NULLIF(split_part(line_text, ',', 3), ''),                           -- ENCOUNTER
    NULLIF(split_part(line_text, ',', 4), ''),                           -- CATEGORY
    NULLIF(split_part(line_text, ',', 5), ''),                           -- CODE
    NULLIF(split_part(line_text, ',', 6), ''),                           -- DESCRIPTION
    NULLIF(split_part(line_text, ',', 7), ''),                           -- VALUE
    NULLIF(split_part(line_text, ',', 8), ''),                           -- UNITS
    NULLIF(split_part(line_text, ',', 9), '')                            -- TYPE
FROM
    observations_staging;


DROP TABLE observations_staging;

