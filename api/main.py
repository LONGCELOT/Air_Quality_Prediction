from fastapi import FastAPI, Query
from pydantic import BaseModel
from typing import List, Dict, Any
import requests
import datetime
import numpy as np

app = FastAPI(title="AQI Live + Prediction API")

# ---------- MODELS ----------
class HourlyData(BaseModel):
    time: List[str]
    pm10: List[float]
    pm2_5: List[float]
    carbon_monoxide: List[float]
    nitrogen_dioxide: List[float]
    sulphur_dioxide: List[float]
    ozone: List[float]

class PredictionInput(BaseModel):
    latitude: float
    longitude: float
    hourly: HourlyData

# ---------- UTILS ----------
def transform_live_to_prediction(live_data: Dict[str, Any]) -> Dict[str, Any]:
    """Transform /live_data raw output into fixed 25-step schema."""
    hourly = live_data["hourly"]

    def pad_or_trim(arr, length=25, fill=0.0):
        arr = arr[:length]
        if len(arr) < length:
            arr = arr + [fill] * (length - len(arr))
        return arr

    times = pad_or_trim(hourly["time"], 25, live_data["hourly"]["time"][-1])
    
    return {
        "latitude": live_data["latitude"],
        "longitude": live_data["longitude"],
        "hourly": {
            "time": times,
            "pm10": pad_or_trim(hourly.get("pm10", []), 25, 0),
            "pm2_5": pad_or_trim(hourly.get("pm2_5", []), 25, 0),
            "carbon_monoxide": pad_or_trim(hourly.get("carbon_monoxide", []), 25, 0),
            "nitrogen_dioxide": pad_or_trim(hourly.get("nitrogen_dioxide", []), 25, 0),
            "sulphur_dioxide": pad_or_trim(hourly.get("sulphur_dioxide", []), 25, 0),
            "ozone": pad_or_trim(hourly.get("ozone", []), 25, 0),
        },
    }

def simple_predict(values: List[float], hours: int) -> float:
    """Dummy predictor: just average + scale."""
    if not values:
        return 0.0
    base = np.mean(values)
    return round(float(base * (1 + hours/100)), 2)

# ---------- ENDPOINTS ----------
@app.get("/live_data")
def get_live_data(latitude: float = Query(...), longitude: float = Query(...)):
    """Fetch 24h past live air quality data from Meteo API"""
    end = datetime.datetime.utcnow().replace(minute=0, second=0, microsecond=0)
    start = end - datetime.timedelta(hours=24)
    
    url = (
        f"https://air-quality-api.open-meteo.com/v1/air-quality?"
        f"latitude={latitude}&longitude={longitude}"
        f"&hourly=pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,"
        f"sulphur_dioxide,ozone,us_aqi&start={start.isoformat()}Z&end={end.isoformat()}Z"
    )
    r = requests.get(url)
    data = r.json()
    return {"latitude": latitude, "longitude": longitude, "hourly": data["hourly"]}

@app.post("/predict_from_data/xgboost")
def predict_from_data(payload: PredictionInput):
    """Take standardized input and return AQI predictions for next 8,12,24 hours"""
    h = payload.hourly

    preds = {
        "8_hours": {"aqi": simple_predict(h.pm2_5, 8)*8},
        "12_hours": {"aqi": simple_predict(h.pm2_5, 12)*8},
        "24_hours": {"aqi": simple_predict(h.pm2_5, 24)*8},
    }

    return {
        "timestamp": datetime.datetime.utcnow().isoformat(),
        "predictions": preds,
        "input_used": payload.dict(),
    }

@app.get("/predict_from_live")
def predict_from_live(latitude: float = Query(...), longitude: float = Query(...)):
    """Shortcut: call live_data, transform, then predict"""
    live = get_live_data(latitude, longitude)
    transformed = transform_live_to_prediction(live)
    return predict_from_data(PredictionInput(**transformed))
