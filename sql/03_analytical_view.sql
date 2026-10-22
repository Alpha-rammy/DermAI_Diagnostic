- ============================================================
-- DermAI Diagnostics
-- Analytical Dataset
-- Grain: One row per lesion
-- ============================================================

### Step 1 — Build the Base Join

SELECT
    -- Identifiers
    l.lesion_id,
    p.patient_id,

    -- Patient demographics
    p.age,
    p.gender,
    p.background_father,
    p.background_mother,

    -- Behavioural / environmental factors
    p.smoke,
    p.drink,
    p.pesticide,
    p.has_piped_water,
    p.has_sewage_system,

    -- Clinical history
    p.skin_cancer_history,
    p.cancer_history,

    -- Skin phenotype
    l.fitspatrick,

    -- Lesion characteristics
    l.region,
    l.diameter_1,
    l.diameter_2,
    l.itch,
    l.grew,
    l.hurt,
    l.changed,
    l.bleed,
    l.elevation,

    -- Clinical outcome
    l.diagnostic,
    l.biopsed

FROM patient_info AS p

INNER JOIN lesion_info AS l
    ON p.patient_id = l.patient_id;


### STEP 2 - Validate the Joined Grain (The relational integration preserved the required analytical grain.)

- To ensure that the relational operation has not changed the intended analytical grain and the number of joined rows should correspond to the number of
unique lesion identifiers included in the analytical population.

WITH joined_data AS (

    SELECT
        l.lesion_id,
        p.patient_id

    FROM patient_info AS p

    INNER JOIN lesion_info AS l
        ON p.patient_id = l.patient_id
)

SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT lesion_id) AS unique_lesions,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM joined_data;


### Step 3 — Check for Join-Generated Duplicates
WITH joined_data AS (

    SELECT
        l.lesion_id,
        p.patient_id

    FROM patient_info AS p

    INNER JOIN lesion_info AS l
        ON p.patient_id = l.patient_id
)

SELECT
    lesion_id,
    COUNT(*) AS row_count

FROM joined_data

GROUP BY lesion_id

HAVING COUNT(*) > 1;


### Step 4 — Create the Analytical View

CREATE OR REPLACE VIEW vw_dermai_analytics AS

SELECT
    -- Identifiers
    l.lesion_id,
    p.patient_id,

    -- Patient demographics
    p.age,
    p.gender,
    p.background_father,
    p.background_mother,

    -- Behavioural / environmental factors
    p.smoke,
    p.drink,
    p.pesticide,
    p.has_piped_water,
    p.has_sewage_system,

    -- Clinical history
    p.skin_cancer_history,
    p.cancer_history,

    -- Skin phenotype
    l.fitspatrick,

    -- Lesion characteristics
    l.region,
    l.diameter_1,
    l.diameter_2,
    l.itch,
    l.grew,
    l.hurt,
    l.changed,
    l.bleed,
    l.elevation,

    -- Clinical outcome
    l.diagnostic,
    l.biopsed

FROM patient_info AS p

INNER JOIN lesion_info AS l
    ON p.patient_id = l.patient_id;


### STEP 5 - Validate the View

# inspect

SELECT *
FROM vw_dermai_analytics
LIMIT 10;

# Check unique identifiers

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT lesion_id) AS unique_lesions,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM vw_dermai_analytics;

# check duplicate

SELECT
    lesion_id,
    COUNT(*) AS row_count
FROM vw_dermai_analytics
GROUP BY lesion_id
HAVING COUNT(*) > 1;