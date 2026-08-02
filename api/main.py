import os
import joblib
import uvicorn
import pandas as pd

from fastapi import FastAPI
from pydantic import BaseModel


# PATHS

BASE_DIR = os.path.dirname(
    os.path.dirname(__file__)
)

MODEL_DIR = os.path.join(BASE_DIR, "Models")


# LOAD MODEL

model = joblib.load(
    os.path.join(
        MODEL_DIR,
        "best_model_pipeline.joblib"
    )
)

print("DermAI model loaded successfully!")


# FASTAPI

app = FastAPI(
    title="DermAI Diagnostics API",
    description="Predict whether a skin lesion is benign or malignant",
    version="0.1"
)


# INPUT SCHEMA

class LesionFeatures(BaseModel):

    # Numeric features
    age: float
    fitspatrick: int
    diameter_1: float
    diameter_2: float
    avg_diameter: float

    # Categorical features
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


# ROOT ENDPOINT

@app.get("/")
def welcome_root():

    return {
        "message": "Welcome to DermAI Diagnostics API"
    }


# PREDICTION ENDPOINT

@app.post("/predict")
def predict_lesion(lesion: LesionFeatures):

    # Convert API input to dataframe
    data = pd.DataFrame(
        [lesion.model_dump()]
    )

    # Predict lesion class
    prediction = model.predict(data)[0]

    # Predict malignancy probability
    malignancy_probability = model.predict_proba(data)[0, 1]

    # Convert numeric prediction to label
    prediction_label = (
        "Malignant"
        if prediction == 1
        else "Benign"
    )

    return {
        "prediction": int(prediction),
        "prediction_label": prediction_label,
        "malignancy_probability": round(
            float(malignancy_probability),
            4
        ),
        "malignancy_probability_percent": round(
            float(malignancy_probability) * 100,
            2
        )
    }


# RUN SERVER

if __name__ == "__main__":

    uvicorn.run(
        app,
        host="127.0.0.1",
        port=8000
    )