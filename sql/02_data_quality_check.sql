-- Data Quality Checks

-- 01a. Check total records

SELECT COUNT(*) AS total_patients
FROM patient_info;

SELECT COUNT(*) AS total_lesions
FROM lesion_info;

-- 01b. Check duplicate patients

SELECT 
    patient_id,
    COUNT(*) AS duplicate_count
FROM patient_info
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- 01c. Check duplicate lesions

SELECT 
    lesion_id,
    COUNT(*) AS duplicate_count
FROM lesion_info
GROUP BY lesion_id
HAVING COUNT(*) > 1;

-- 01d. Check missing values in key columns

SELECT
    COUNT(*) FILTER (WHERE patient_id IS NULL) AS missing_patient_id,
    COUNT(*) FILTER (WHERE age IS NULL) AS missing_age,
    COUNT(*) FILTER (WHERE gender IS NULL) AS missing_gender,
    COUNT(*) FILTER (WHERE smoke IS NULL) AS missing_smoke,
    COUNT(*) FILTER (WHERE pesticide IS NULL) AS missing_pesticide
FROM patient_info;

-- 01e. Check missing lesion values

SELECT
    COUNT(*) FILTER (WHERE lesion_id IS NULL) AS missing_lesion_id,
    COUNT(*) FILTER (WHERE patient_id IS NULL) AS missing_patient_id,
    COUNT(*) FILTER (WHERE diagnostic IS NULL) AS missing_diagnostic,
    COUNT(*) FILTER (WHERE region IS NULL) AS missing_region,
    COUNT(*) FILTER (WHERE diameter_1 IS NULL) AS missing_diameter_1,
    COUNT(*) FILTER (WHERE diameter_2 IS NULL) AS missing_diameter_2
FROM lesion_info;
