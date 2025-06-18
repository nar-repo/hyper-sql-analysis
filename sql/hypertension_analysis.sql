
--create hypertensive cohort
DROP TABLE IF EXISTS hypertensive_patients;
CREATE TEMP TABLE hypertensive_patients AS
SELECT DISTINCT "PATIENT"
FROM conditions
WHERE LOWER("DESCRIPTION") LIKE '%hypertension%';


--medication patterns
DROP TABLE IF EXISTS med_summary;
CREATE TEMP TABLE med_summary AS
SELECT "DESCRIPTION", COUNT(*) AS num_prescribed
FROM medications
WHERE "PATIENT" IN (SELECT "PATIENT" FROM hypertensive_patients)
GROUP BY "DESCRIPTION"
ORDER BY num_prescribed DESC;


--blood pressure observations
DROP TABLE IF EXISTS bp_observations;
CREATE TEMP TABLE bp_observations AS
SELECT "PATIENT", "DATE", "VALUE", "UNITS", "DESCRIPTION"
FROM observations
WHERE LOWER("DESCRIPTION") LIKE '%blood pressure%'
  AND "PATIENT" IN (SELECT "PATIENT" FROM hypertensive_patients);


--examine health encounter pattern
DROP TABLE IF EXISTS encounter_summary;
CREATE TEMP TABLE encounter_summary AS
SELECT encounterclass, COUNT(*) AS total_encounters
FROM encounters
WHERE patient IN (SELECT "PATIENT" FROM hypertensive_patients)
GROUP BY encounterclass
ORDER BY total_encounters DESC;


--summarize demographic characteristics of hypertensive patients
DROP TABLE IF EXISTS demo_summary;
CREATE TEMP TABLE demo_summary AS
SELECT gender, race, COUNT(*) AS patient_count
FROM patients
WHERE id IN (SELECT "PATIENT" FROM hypertensive_patients)
GROUP BY gender, race
ORDER BY patient_count DESC;


--export results to CSV files
\COPY med_summary TO 'C:/Users/Nari/hyper-sql-analysis/exports/med_summary.csv' CSV HEADER;
\COPY bp_observations TO 'C:/Users/Nari/hyper-sql-analysis/exports/bp_observations.csv' CSV HEADER;
\COPY encounter_summary TO 'C:/Users/Nari/hyper-sql-analysis/exports/encounter_summary.csv' CSV HEADER;
\COPY demo_summary TO 'C:/Users/Nari/hyper-sql-analysis/exports/demo_summary.csv' CSV HEADER;

