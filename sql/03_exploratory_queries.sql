--02 Business Analysis

- 02a. Diagnosis by patient demographics

SELECT
    p.gender,
    l.diagnostic,
    COUNT(*) AS lesion_count
FROM patient_info p
JOIN lesion_info l
    ON p.patient_id = l.patient_id
GROUP BY p.gender, l.diagnostic
ORDER BY p.gender, lesion_count DESC;

-- 02b. Environmental exposure and diagnosis

SELECT
    p.smoke,
    p.drink,
    p.pesticide,
    l.diagnostic,
    COUNT(*) AS lesion_count
FROM patient_info p
JOIN lesion_info l
    ON p.patient_id = l.patient_id
GROUP BY p.smoke, p.drink, p.pesticide, l.diagnostic
ORDER BY lesion_count DESC;

-- 03a. Most common diagnosis

SELECT
    diagnostic,
    COUNT(*) AS lesion_count
FROM lesion_info
GROUP BY diagnostic
ORDER BY lesion_count DESC;

-- 03b. Average lesion size by diagnosis

SELECT
    diagnostic,
    ROUND(AVG((diameter_1 + diameter_2) / 2)::numeric, 2) AS avg_lesion_size
FROM lesion_info
GROUP BY diagnostic
ORDER BY avg_lesion_size DESC;

-- 03c. Diagnosis by body region

SELECT
    region,
    diagnostic,
    COUNT(*) AS lesion_count
FROM lesion_info
GROUP BY region, diagnostic
ORDER BY region, lesion_count DESC;

