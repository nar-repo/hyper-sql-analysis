-- =============================================================
-- Complete Script to Import Inconsistent Medications CSV Data
-- ==============================================================
--this script handles CSV files where rows may have a different
-- number of columns by importing each line as raw text and then
-- parsing it safely with SQL functions.

--enable the UUID generation function.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--create the final, permanent 'medications' table.
CREATE TABLE IF NOT EXISTS medications (
    id TEXT PRIMARY KEY,
    "START" TIMESTAMP WITH TIME ZONE,
    "STOP" TIMESTAMP WITH TIME ZONE,
    "PATIENT" TEXT,
    "PAYER" TEXT,
    "ENCOUNTER" TEXT,
    "CODE" TEXT,
    "DESCRIPTION" TEXT,
    "BASE_COST" NUMERIC(10, 2),
    "PAYER_COVERAGE" NUMERIC(10, 2),
    "DISPENSES" INTEGER,
    "TOTALCOST" NUMERIC(10, 2),
    "REASONCODE" TEXT,
    "REASONDESCRIPTION" TEXT
);


-- ===============================================================
-- Main Import Process
-- =================================================================
-- this table has only one column and will store each line from the
-- CSV file as a single piece of text.
CREATE TEMP TABLE csv_import_raw (line_text TEXT);


--copy the raw data from the CSV file into the staging table.
-- ----------------------------------------------------------
-- 'FORMAT TEXT' to force psql to treat each line as a single
-- string, which avoids errors from inconsistent column counts.
\copy csv_import_raw FROM 'C:/Users/Nari/hyper-sql-analysis/data/medications_utf8.csv' WITH (FORMAT TEXT, HEADER TRUE);


--parse the raw text and insert it into the final table.
-- --------------------------------------------------------------
--reads from the temporary table, splits
-- each line by its commas, and inserts the data into the correct
-- columns in the permanent 'medications' table.
INSERT INTO medications (id, "START", "STOP", "PATIENT", "PAYER", "ENCOUNTER", "CODE", "DESCRIPTION", "BASE_COST", "PAYER_COVERAGE", "DISPENSES", "TOTALCOST", "REASONCODE", "REASONDESCRIPTION")
SELECT
    --generate a unique text ID for each medication record
    'med-' || uuid_generate_v4(),

    --parse each column, converting empty strings to NULL and casting to the correct data type.
    NULLIF(split_part(line_text, ',', 1), '')::TIMESTAMP WITH TIME ZONE,    
    NULLIF(split_part(line_text, ',', 2), '')::TIMESTAMP WITH TIME ZONE,    
    split_part(line_text, ',', 3),                                          
    split_part(line_text, ',', 4),                                        
    split_part(line_text, ',', 5),                                        
    split_part(line_text, ',', 6),                                         
    split_part(line_text, ',', 7),                                          
    NULLIF(split_part(line_text, ',', 8), '')::NUMERIC,                     
    NULLIF(split_part(line_text, ',', 9), '')::NUMERIC,                      
    NULLIF(split_part(line_text, ',', 10), '')::INTEGER,                     
    NULLIF(split_part(line_text, ',', 11), '')::NUMERIC,                     
    NULLIF(split_part(line_text, ',', 12), ''),                             --REASONCODE (becomes NULL if missing)
    NULLIF(split_part(line_text, ',', 13), '')                              --REASONDESCRIPTION (becomes NULL if missing)
FROM
    csv_import_raw;


--clean up the temporary table (optional, as it's dropped at session end)
DROP TABLE csv_import_raw;