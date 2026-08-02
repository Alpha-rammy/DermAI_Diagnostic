-- 04a. Create age groups

SELECT
    patient_id,
    age,
    CASE
        WHEN age < 30 THEN 'Young Adult'
        WHEN age BETWEEN 30 AND 49 THEN 'Middle Age'
        WHEN age BETWEEN 50 AND 69 THEN 'Older Adult'
        ELSE 'Elderly'
    END AS age_group
FROM patient_info;

-- 04b. Create lesion size category

SELECT
    lesion_id,
    diagnostic,
    ROUND(((diameter_1 + diameter_2) / 2)::numeric, 2) AS avg_diameter,
    CASE
        WHEN ((diameter_1 + diameter_2) / 2) < 5 THEN 'Small'
        WHEN ((diameter_1 + diameter_2) / 2) BETWEEN 5 AND 10 THEN 'Medium'
        ELSE 'Large'
    END AS lesion_size_category
FROM lesion_info;

-- 04c. Cancerous vs non-cancerous flag

SELECT
    lesion_id,
    diagnostic,
    CASE
        WHEN diagnostic IN ('BCC', 'MEL', 'SCC') THEN 'Cancerous'
        ELSE 'Benign_or_Other'
    END AS lesion_category
FROM lesion_info;


-- 05a. Patients with lesions larger than the overall average

SELECT
    p.patient_id,
    p.age,
    p.gender,
    l.lesion_id,
    l.diagnostic,
    ROUND(((l.diameter_1 + l.diameter_2) / 2)::numeric, 2) AS avg_diameter
FROM patient_info p
JOIN lesion_info l
    ON p.patient_id = l.patient_id
WHERE ((l.diameter_1 + l.diameter_2) / 2) >
    (
        SELECT AVG((diameter_1 + diameter_2) / 2)
        FROM lesion_info
    )
ORDER BY avg_diameter DESC;

-- 05b. Diagnoses with above-average number of lesions

SELECT
    diagnostic,
    COUNT(*) AS lesion_count
FROM lesion_info
GROUP BY diagnostic
HAVING COUNT(*) >
    (
        SELECT AVG(diagnosis_count)
        FROM (
            SELECT COUNT(*) AS diagnosis_count
            FROM lesion_info
            GROUP BY diagnostic
        ) sub
    )
ORDER BY lesion_count DESC;


-- 06a. Patient lesion summary

WITH patient_lesion_summary AS (
    SELECT
        patient_id,
        COUNT(*) AS total_lesions,
        ROUND(AVG((diameter_1 + diameter_2) / 2)::numeric, 2) AS avg_lesion_size
    FROM lesion_info
    GROUP BY patient_id
)

SELECT
    p.patient_id,
    p.age,
    p.gender,
    s.total_lesions,
    s.avg_lesion_size
FROM patient_info p
JOIN patient_lesion_summary s
    ON p.patient_id = s.patient_id
ORDER BY s.total_lesions DESC;

-- 06b. Cancer rate by gender

WITH cancer_flag AS (
    SELECT
        p.gender,
        CASE
            WHEN l.diagnostic IN ('BCC', 'MEL', 'SCC') THEN 1
            ELSE 0
        END AS cancerous_flag
    FROM patient_info p
    JOIN lesion_info l
        ON p.patient_id = l.patient_id
)

SELECT
    gender,
    COUNT(*) AS total_lesions,
    SUM(cancerous_flag) AS cancerous_lesions,
    ROUND((SUM(cancerous_flag)::numeric / COUNT(*)) * 100, 2) AS cancer_rate_percent
FROM cancer_flag
GROUP BY gender
ORDER BY cancer_rate_percent DESC;


-- 07a. Rank largest lesions within each diagnosis

SELECT
    lesion_id,
    diagnostic,
    region,
    ROUND(((diameter_1 + diameter_2) / 2)::numeric, 2) AS avg_diameter,
    RANK() OVER (
        PARTITION BY diagnostic
        ORDER BY ((diameter_1 + diameter_2) / 2) DESC
    ) AS lesion_size_rank
FROM lesion_info;

-- 07b. Diagnosis percentage contribution

SELECT
    diagnostic,
    COUNT(*) AS lesion_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percent_of_total
FROM lesion_info
GROUP BY diagnostic
ORDER BY lesion_count DESC;

-- 07c. Divide patients into age quartiles
SELECT
    patient_id,
    age,
    gender,
    NTILE(4) OVER (ORDER BY age) AS age_quartile
FROM patient_info;
