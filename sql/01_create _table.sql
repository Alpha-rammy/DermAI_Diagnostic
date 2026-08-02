- DermAI Diagnostics
--Skin Cancer Intelligence Platform

SELECT table_name
FROM information_schema.tables
WHERE table_schema ='public';

-- Rename Tables 
ALTER TABLE table1 RENAME TO
patient_info;
ALTER TABLE table2 RENAME TO
lesion_info;

-- check column:
SELECT *
FROM patient_info
LIMIT 5;

-- Add Relationship between tables
ALTER TABLE lesion_info
ADD CONSTRAINT fk_patient
FOREIGN KEY (patient_id)
REFERENCES patient_info(patient_id);

CREATE VIEW skin_cancer_analysis AS
SELECT
    p.patient_id,
    p.age,
    p.gender,
    p.smoke,
    p.drink,
    p.pesticide,
    p.background_father,
    p.background_mother,
    p.skin_cancer_history,
    p.cancer_history,
    p.has_piped_water,
    p.has_sewage_system,

    l.lesion_id,
    l.fitspatrick,
    l.region,
    l.diameter_1,
    l.diameter_2,
    ROUND(((l.diameter_1 + l.diameter_2) / 2)::numeric, 2) AS avg_diameter,
    l.diagnostic,
    l.itch,
    l.grew,
    l.hurt,
    l.changed,
    l.bleed,
    l.elevation,
    l.img_id,
    l.biopsed
FROM patient_info p
JOIN lesion_info l
    ON p.patient_id = l.patient_id;

