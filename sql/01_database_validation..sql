
-- DermAI Diagnostics
-- 01 - Database Validation


### STEP 1 - List tables in the public schema

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;


### STEP 2 - Inspect  Table

# patient info

SELECT
    COUNT(*) AS total_patient_records,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM patient_info;


# Lesion info

SELECT
    COUNT(*) AS total_lesion_records,
    COUNT(DISTINCT lesion_id) AS unique_lesions,
    COUNT(DISTINCT patient_id) AS patients_with_lesions
FROM lesion_info;


### STEP 3 - Check for Duplicate IDs

# Patient IDs

SELECT
    patient_id,
    COUNT(*) AS record_count
FROM patient_info
GROUP BY patient_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


# Lesion IDs

SELECT
    lesion_id,
    COUNT(*) AS record_count
FROM lesion_info
GROUP BY lesion_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


### STEP 4 - Validate the Relationship (Referential Integrity)

# check whether every lesion has a corresponding patient.

SELECT
    COUNT(*) AS unmatched_lesions
FROM lesion_info AS l

LEFT JOIN patient_info AS p
    ON l.patient_id = p.patient_id

WHERE p.patient_id IS NULL;


### STEP 5 - Check Missing Values in Important Patient Fields


SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (WHERE age IS NULL)
        AS missing_age,

    COUNT(*) FILTER (WHERE gender IS NULL)
        AS missing_gender,

    COUNT(*) FILTER (WHERE smoke IS NULL)
        AS missing_smoke,

    COUNT(*) FILTER (WHERE drink IS NULL)
        AS missing_drink,

    COUNT(*) FILTER (WHERE pesticide IS NULL)
        AS missing_pesticide,

    COUNT(*) FILTER (WHERE skin_cancer_history IS NULL)
        AS missing_skin_cancer_history,

    COUNT(*) FILTER (WHERE cancer_history IS NULL)
        AS missing_cancer_history

FROM patient_info;



### STEP 6 — Check Missing Lesion Information

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (WHERE diagnostic IS NULL)
        AS missing_diagnosis,

    COUNT(*) FILTER (WHERE region IS NULL)
        AS missing_region,

    COUNT(*) FILTER (WHERE diameter_1 IS NULL)
        AS missing_diameter_1,

    COUNT(*) FILTER (WHERE diameter_2 IS NULL)
        AS missing_diameter_2,

    COUNT(*) FILTER (WHERE fitspatrick IS NULL)
        AS missing_fitzpatrick,

    COUNT(*) FILTER (WHERE biopsed IS NULL)
        AS missing_biopsy

FROM lesion_info;


### STEP 7 — Validate Numerical Ranges

# Age

SELECT
    MIN(age) AS minimum_age,
    MAX(age) AS maximum_age,
    ROUND(AVG(age), 2) AS average_age
FROM patient_info;

# check impossible values:

SELECT *
FROM patient_info
WHERE age < 0
   OR age > 120;



### STEP 8 Fitzpatrick skin type

# The supplied dictionary defines Fitzpatrick skin type as 1-6.

SELECT
    fitspatrick,
    COUNT(*) AS lesion_count
FROM lesion_info
GROUP BY fitspatrick
ORDER BY fitspatrick;

# Then:

SELECT *
FROM lesion_info
WHERE fitspatrick NOT BETWEEN 1 AND 6;


### STEP 9 — Inspect Diagnosis Categories


SELECT
    diagnostic,
    COUNT(*) AS lesion_count
FROM lesion_info
GROUP BY diagnostic
ORDER BY lesion_count DESC;