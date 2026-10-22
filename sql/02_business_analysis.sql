

### Question 1 - Which diagnoses have the larger lesions?

WITH lesion_measurements AS (
    SELECT
        lesion_id,
        diagnostic,
        diameter_1,
        diameter_2,
        ROUND(
            (diameter_1 + diameter_2) / 2.0,
            2
        ) AS mean_diameter
    FROM lesion_info
)

SELECT
    diagnostic,
    COUNT(*) AS lesion_count,
    ROUND(AVG(mean_diameter), 2) AS avg_lesion_diameter,
    ROUND(MIN(mean_diameter), 2) AS min_lesion_diameter,
    ROUND(MAX(mean_diameter), 2) AS max_lesion_diameter

FROM lesion_measurements

GROUP BY diagnostic

ORDER BY avg_lesion_diameter DESC;


### Question 2 - Which lesions are larger than the overall average lesion size?

SELECT
    lesion_id,
    patient_id,
    diagnostic,
    diameter_1,
    diameter_2,
    ROUND(
        (diameter_1 + diameter_2) / 2.0,
        2
    ) AS mean_diameter

FROM lesion_info

WHERE
    (diameter_1 + diameter_2) / 2.0
    >
    (
        SELECT
            AVG(
                (diameter_1 + diameter_2) / 2.0
            )
        FROM lesion_info


### Question 3 - Within each gender, what percentage of lesions belongs to each diagnosis?

WITH gender_diagnosis AS (
    SELECT
        p.gender,
        l.diagnostic,
        COUNT(*) AS lesion_count

    FROM patient_info p

    JOIN lesion_info l
        ON p.patient_id = l.patient_id

    GROUP BY
        p.gender,
        l.diagnostic
)

SELECT
    gender,
    diagnostic,
    lesion_count,

    ROUND(
        100.0 * lesion_count
        / SUM(lesion_count) OVER (
            PARTITION BY gender
        ),
        2
    ) AS percentage_within_gender

FROM gender_diagnosis

ORDER BY
    gender,
    percentage_within_gender DESC;


### Question 4 - Within each pesticide exposure, what percentage of lesions belongs to each diagnosis?


WITH pesticide_diagnosis AS (
    SELECT
        p.pesticide,
        l.diagnostic,
        COUNT(*) AS lesion_count

    FROM patient_info p

    JOIN lesion_info l
        ON p.patient_id = l.patient_id

    GROUP BY
        p.pesticide,
        l.diagnostic
)

SELECT
    pesticide,
    diagnostic,
    lesion_count,

    ROUND(
        100.0 * lesion_count
        / SUM(lesion_count) OVER (
            PARTITION BY pesticide
        ),
        2
    ) AS percentage_within_exposure_group

FROM pesticide_diagnosis

ORDER BY
    pesticide,
    percentage_within_exposure_group DESC;


### Question 5 - How are patients distributed across age groups, and which age groups contribute the most lesion records?

SELECT
    CASE
        WHEN p.age < 30 THEN 'Young Adult'
        WHEN p.age < 45 THEN 'Middle Age'
        WHEN p.age < 60 THEN 'Older Adult'
        ELSE 'Elderly'
    END AS age_group,

    COUNT(*) AS lesion_count

FROM patient_info AS p

JOIN lesion_info AS l
    ON p.patient_id = l.patient_id

GROUP BY age_group

ORDER BY lesion_count DESC;


### Question 6 -What proportion of lesion records are classified as cancerous versus non-cancer

WITH lesion_outcome AS (
    SELECT
        lesion_id,
        diagnostic,

        CASE
            WHEN diagnostic IN ('BCC', 'SCC', 'MEL')
                THEN 1
            ELSE 0
        END AS cancerous_flag

    FROM lesion_info
)

SELECT
    cancerous_flag,
    COUNT(*) AS lesion_count,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM lesion_outcome

GROUP BY cancerous_flag

ORDER BY cancerous_flag;