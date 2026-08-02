from pydantic import BaseModel


class LesionInput(BaseModel):
    age: float
    fitspatrick: int
    diameter_1: float
    diameter_2: float
    avg_diameter: float
    age_group: str
    gender: str
    smoke: str
    drink: str
    pesticide: str
    skin_cancer_history: str
    cancer_history: str
    has_piped_water: str
    has_sewage_system: str
    background_father: str
    background_mother: str
    region: str
    lesion_size_category: str
    itch: str
    grew: str
    hurt: str
    changed: str
    bleed: str
    elevation: str