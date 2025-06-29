CREATE OR REPLACE PROCEDURE patient_analysis()
LANGUAGE plpgsql
AS $$
BEGIN
    --join medications and patients to see average prescriptions per race and gender
    --temp table will store aggregated medication data by patient demographics.
    DROP TABLE IF EXISTS med_by_demo;
    CREATE TEMP TABLE med_by_demo AS
    SELECT
        p.gender,
        p.race,
        COUNT(m.*) AS total_meds,
        AVG(CAST(m.quantity AS INTEGER)) AS avg_quantity 
    FROM
        medications m
    JOIN
        patients p ON m."PATIENT" = p.id
    WHERE
        m."PATIENT" IN (SELECT "PATIENT" FROM hypertensive_patients)
    GROUP BY
        p.gender, p.race
    HAVING
        COUNT(m.*) > 5 
    ORDER BY
        total_meds DESC;

    --LEFT JOIN to check patients who have no encounters recorded
    --temporary table identifies hypertensive patients without any recorded encounters.
    DROP TABLE IF EXISTS patients_no_encounters;
    CREATE TEMP TABLE patients_no_encounters AS
    SELECT
        hp."PATIENT",
        COALESCE(e.id, 'No Encounter') AS encounter_id 
    FROM
        hypertensive_patients hp
    LEFT JOIN
        encounters e ON hp."PATIENT" = e.patient
    WHERE
        e.id IS NULL; -

    -- find earliest and latest blood pressure measurement per patient
    --temporary table summarizes the first, last, and duration of blood pressure observations per patient.
    DROP TABLE IF EXISTS bp_date_summary;
    CREATE TEMP TABLE bp_date_summary AS
    SELECT
        bpo."PATIENT",
        MIN(bpo."DATE") AS first_bp_date,
        MAX(bpo."DATE") AS last_bp_date,
        --calculate the duration in full days using epoch difference
        CAST(EXTRACT(EPOCH FROM (MAX(bpo."DATE") - MIN(bpo."DATE"))) / (24 * 60 * 60) AS INTEGER) AS bp_duration_days
    FROM
        bp_observations bpo
    GROUP BY
        bpo."PATIENT";

    --Medication costs over time (example with DATEPART + DATEADD + CURRENT_TIMESTAMP)
    --temporary table aggregates medication costs by year and month for hypertensive patients.
    DROP TABLE IF EXISTS med_cost_summary;
    CREATE TEMP TABLE med_cost_summary AS
    SELECT
        EXTRACT(YEAR FROM m.date) AS year_prescribed,   
        EXTRACT(MONTH FROM m.date) AS month_prescribed, 
        SUM(CAST(m.cost AS DECIMAL(10,2))) AS total_cost,
        AVG(CAST(m.cost AS DECIMAL(10,2))) AS avg_cost
    FROM
        medications m
    WHERE
        m."PATIENT" IN (SELECT "PATIENT" FROM hypertensive_patients)
        --filters for prescriptions within the last 1 year from the current timestamp
        AND m.date >= (CURRENT_TIMESTAMP - INTERVAL '1 year') 
    GROUP BY
        EXTRACT(YEAR FROM m.date),
        EXTRACT(MONTH FROM m.date)
    ORDER BY
        year_prescribed DESC, month_prescribed DESC;

    --count hypertensive patients in each 10-year age group
    DROP TABLE IF EXISTS age_group_summary;
    CREATE TEMP TABLE age_group_summary AS
    SELECT
        -- Calculate age in years, divide by 10, floor, and multiply by 10 to get the age group
        FLOOR(EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, p.birthdate)) / 10) * 10 AS age_group,
        COUNT(*) AS num_patients
    FROM
        patients p
    WHERE
        p.id IN (SELECT "PATIENT" FROM hypertensive_patients)
    GROUP BY
        FLOOR(EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, p.birthdate)) / 10) * 10
    ORDER BY
        age_group;

    --subquery: identify patients with > 3 ER encounters
    DROP TABLE IF EXISTS frequent_er_patients;
    CREATE TEMP TABLE frequent_er_patients AS
    SELECT
        patient,
        COUNT(*) AS er_visits
    FROM
        encounters
    WHERE
        encounterclass = 'emergency'
        AND patient IN (SELECT "PATIENT" FROM hypertensive_patients)
    GROUP BY
        patient
    HAVING
        COUNT(*) > 3;

END;
$$;
