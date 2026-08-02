-- 08a. Create final analytics view

CREATE OR REPLACE VIEW dermai_analytics_view AS
SELECT
    p.patient_id,
    p.age,
    CASE
        WHEN p.age < 30 THEN 'Young Adult'
        WHEN p.age BETWEEN 30 AND 49 THEN 'Middle Age'
        WHEN p.age BETWEEN 50 AND 69 THEN 'Older Adult'
        ELSE 'Elderly'
    END AS age_group,
    p.gender,
    p.smoke,
    p.drink,
    p.pesticide,
    p.skin_cancer_history,
    p.cancer_history,
    p.has_piped_water,
    p.has_sewage_system,
    p.background_father,
    p.background_mother,

    l.lesion_id,
    l.fitspatrick,
    l.region,
    l.diameter_1,
    l.diameter_2,
    ROUND(((l.diameter_1 + l.diameter_2) / 2)::numeric, 2) AS avg_diameter,

    CASE
        WHEN ((l.diameter_1 + l.diameter_2) / 2) < 5 THEN 'Small'
        WHEN ((l.diameter_1 + l.diameter_2) / 2) BETWEEN 5 AND 10 THEN 'Medium'
        ELSE 'Large'
    END AS lesion_size_category,

    l.itch,
    l.grew,
    l.hurt,
    l.changed,
    l.bleed,
    l.elevation,
    l.biopsed,
    l.diagnostic,

    CASE
        WHEN l.diagnostic IN ('BCC', 'MEL', 'SCC') THEN 1
        ELSE 0
    END AS cancerous_flag

FROM patient_info p
JOIN lesion_info l
    ON p.patient_id = l.patient_id;

-- 08b. Dashboard summary by diagnosis

SELECT
    diagnostic,
    COUNT(*) AS total_lesions,
    SUM(cancerous_flag) AS cancerous_cases,
    ROUND(AVG(avg_diameter), 2) AS avg_lesion_size,
    ROUND(AVG(age), 2) AS avg_patient_age
FROM dermai_analytics_view
GROUP BY diagnostic
ORDER BY total_lesions DESC;


-- 08c. ML-ready table

CREATE TABLE dermai_ml_ready AS
SELECT *
FROM dermai_analytics_view;

SELECT
    cancerous_flag,
    COUNT(*) AS total_cases,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM dermai_modelling_view
GROUP BY cancerous_flag
ORDER BY cancerous_flag;

