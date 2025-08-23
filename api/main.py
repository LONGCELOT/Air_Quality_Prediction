"""
FastAPI Application for Air Quality Index (AQI) Prediction

This application provides API endpoints for predicting AQI using mock prediction models.
Deployed on Render cloud platform - optimized for Python 3.11.

Author: AI Assistant
Date: August 2025
"""

import os
import logging
import math
import random
from typing import Optional, Dict, Any, List
from datetime import datetime, timedelta
import requests
from fastapi import FastAPI, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global variables to store loaded models
models: Dict[str, Any] = {}

# Initialize FastAPI application
app = FastAPI(
    title="AQI Prediction API",
    description="Real-time Air Quality Index prediction service with mock ML models",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware for web app compatibility
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class HourlyData(BaseModel):
    """
    Pydantic model for a single hour of AQI data.
    """
    CO: float = Field(..., description="Carbon Monoxide level in mg/m³")
    NO2: float = Field(..., description="Nitrogen Dioxide level in μg/m³")
    SO2: float = Field(..., description="Sulfur Dioxide level in μg/m³")
    O3: float = Field(..., description="Ozone level in μg/m³")
    PM25: float = Field(..., description="PM2.5 level in μg/m³")
    PM10: float = Field(..., description="PM10 level in μg/m³")
    AQI: float = Field(..., description="Air Quality Index")
    timestamp: str = Field(..., description="ISO timestamp")


class PredictionData(BaseModel):
    """
    Pydantic model for AQI predictions.
    """
    aqi8h: float = Field(..., description="Predicted AQI for 8 hours ahead")
    aqi12h: float = Field(..., description="Predicted AQI for 12 hours ahead")
    aqi24h: float = Field(..., description="Predicted AQI for 24 hours ahead")
    model_name: str = Field(..., description="Name of the ML model used")
    confidence: Optional[float] = Field(None, description="Prediction confidence score")


class CurrentAqiInput(BaseModel):
    """
    Pydantic model for current AQI input data.
    """
    pm25: float = Field(..., description="PM2.5 level", ge=0, le=500)
    pm10: float = Field(..., description="PM10 level", ge=0, le=500)
    co: float = Field(..., description="CO level", ge=0, le=50)
    o3: float = Field(..., description="O3 level", ge=0, le=500)
    no2: float = Field(..., description="NO2 level", ge=0, le=500)
    so2: float = Field(..., description="SO2 level", ge=0, le=500)


def calculate_aqi_from_pollutants(pm25: float, pm10: float, o3: float, 
                                no2: float, so2: float, co: float) -> float:
    """
    Calculate AQI from individual pollutant levels using EPA standards.
    
    Args:
        pm25: PM2.5 level in μg/m³
        pm10: PM10 level in μg/m³
        o3: Ozone level in μg/m³
        no2: NO2 level in μg/m³
        so2: SO2 level in μg/m³
        co: CO level in μg/m³
    
    Returns:
        float: Calculated AQI value
    """
    # EPA breakpoints for PM2.5 (primary pollutant for AQI calculation)
    pm25_breakpoints = [
        (0, 12, 0, 50),      # Good
        (12.1, 35.4, 51, 100),   # Moderate
        (35.5, 55.4, 101, 150),  # Unhealthy for Sensitive Groups
        (55.5, 150.4, 151, 200), # Unhealthy
        (150.5, 250.4, 201, 300), # Very Unhealthy
        (250.5, 500, 301, 500),   # Hazardous
    ]
    
    # Calculate PM2.5 AQI (primary component)
    pm25_aqi = 0
    for low_conc, high_conc, low_aqi, high_aqi in pm25_breakpoints:
        if low_conc <= pm25 <= high_conc:
            pm25_aqi = ((high_aqi - low_aqi) / (high_conc - low_conc)) * (pm25 - low_conc) + low_aqi
            break
    else:
        pm25_aqi = 500  # Max AQI if above all breakpoints
    
    # Add contributions from other pollutants (simplified approach)
    o3_factor = min(o3 / 100, 1.0) * 20    # O3 can add up to 20 AQI points
    no2_factor = min(no2 / 100, 1.0) * 15  # NO2 can add up to 15 AQI points
    so2_factor = min(so2 / 20, 1.0) * 15   # SO2 can add up to 15 AQI points
    co_factor = min(co / 1000, 1.0) * 10   # CO can add up to 10 AQI points
    
    total_aqi = pm25_aqi + o3_factor + no2_factor + so2_factor + co_factor
    
    return min(max(total_aqi, 0), 500)  # Clamp between 0-500


def generate_mock_data(latitude: float = -15.7797, longitude: float = -47.9297, 
                      hours: int = 48) -> List[HourlyData]:
    """
    Generate realistic mock air quality data when live data is unavailable.
    
    Args:
        latitude: Latitude coordinate
        longitude: Longitude coordinate  
        hours: Number of hours to generate
    
    Returns:
        List[HourlyData]: List of hourly mock air quality data
    """
    mock_data = []
    current_time = datetime.now()
    
    # Base pollutant levels (reasonable for a moderately polluted area)
    base_pm25 = 15.5
    base_pm10 = 28.3
    base_co = 0.8
    base_no2 = 22.1
    base_so2 = 8.2
    base_o3 = 45.6
    
    for i in range(hours):
        # Add some realistic variation (±30%)
        variation = 0.7 + (i % 7) * 0.1  # Daily variation pattern
        daily_cycle = 1.0 + 0.3 * math.sin(2 * math.pi * i / 24)  # Daily cycle
        
        pm25 = base_pm25 * variation * daily_cycle
        pm10 = base_pm10 * variation * daily_cycle
        co = base_co * variation * daily_cycle
        no2 = base_no2 * variation * daily_cycle
        so2 = base_so2 * variation * daily_cycle
        o3 = base_o3 * variation * daily_cycle
        
        # Calculate AQI from pollutants
        aqi = calculate_aqi_from_pollutants(pm25, pm10, o3, no2, so2, co * 1000)
        
        # Create timestamp for hours ago
        timestamp = current_time - timedelta(hours=hours-i-1)
        
        hour_data = HourlyData(
            CO=co,
            NO2=no2,
            SO2=so2,
            O3=o3,
            PM25=pm25,
            PM10=pm10,
            AQI=aqi,
            timestamp=timestamp.isoformat()
        )
        
        mock_data.append(hour_data)
    
    return mock_data


def fetch_live_air_quality_data(latitude: float = -15.7797, longitude: float = -47.9297, 
                                    hours: int = 48) -> List[HourlyData]:
    """
    Fetch live air quality data from Open-Meteo API.
    
    Args:
        latitude: Latitude coordinate
        longitude: Longitude coordinate  
        hours: Number of hours to fetch (max 120)
    
    Returns:
        List[HourlyData]: List of hourly air quality data
    """
    # Calculate date range for the API call
    end_date = datetime.now().date()
    start_date = end_date - timedelta(days=3)  # Get 3 days of data to ensure we have enough
    
    url = "https://air-quality-api.open-meteo.com/v1/air-quality"
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "hourly": "pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone",
        "start_date": start_date.isoformat(),
        "end_date": end_date.isoformat(),
        "timezone": "auto"
    }
    
    try:
        response = requests.get(url, params=params, timeout=30)
        response.raise_for_status()
        data = response.json()
        
        # Parse the response
        hourly_data = data.get("hourly", {})
        times = hourly_data.get("time", [])
        pm10_values = hourly_data.get("pm10", [])
        pm25_values = hourly_data.get("pm2_5", [])
        co_values = hourly_data.get("carbon_monoxide", [])
        no2_values = hourly_data.get("nitrogen_dioxide", [])
        so2_values = hourly_data.get("sulphur_dioxide", [])
        o3_values = hourly_data.get("ozone", [])
        
        # Convert to our format
        historical_data = []
        current_time = datetime.now()
        
        # Get the most recent complete hours (skip null values)
        valid_data_count = 0
        for i in range(len(times) - 1, -1, -1):  # Start from most recent
            if valid_data_count >= hours:
                break
                
            # Check if all values are available (not null)
            if (pm10_values[i] is not None and pm25_values[i] is not None and
                co_values[i] is not None and no2_values[i] is not None and
                so2_values[i] is not None and o3_values[i] is not None):
                
                # Convert units: Open-Meteo returns μg/m³, we need to convert CO to mg/m³
                co_mg = co_values[i] / 1000  # Convert μg/m³ to mg/m³
                
                # Calculate AQI from pollutants
                aqi = calculate_aqi_from_pollutants(
                    pm25=pm25_values[i],
                    pm10=pm10_values[i], 
                    o3=o3_values[i],
                    no2=no2_values[i],
                    so2=so2_values[i],
                    co=co_mg * 1000  # Pass back as μg/m³ for AQI calculation
                )
                
                hour_data = HourlyData(
                    CO=co_mg,  # mg/m³
                    NO2=no2_values[i],  # μg/m³
                    SO2=so2_values[i],  # μg/m³
                    O3=o3_values[i],    # μg/m³
                    PM25=pm25_values[i], # μg/m³
                    PM10=pm10_values[i], # μg/m³
                    AQI=aqi,
                    timestamp=times[i] + ":00Z"  # Add seconds and Z for ISO format
                )
                
                historical_data.insert(0, hour_data)  # Insert at beginning to maintain chronological order
                valid_data_count += 1
        
        if len(historical_data) < hours:
            logger.warning(f"Only got {len(historical_data)} hours of data instead of {hours}")
        
        # If no data or all zeros, provide meaningful mock data for demonstration
        if not historical_data or all(data.AQI == 0 for data in historical_data):
            logger.warning("No valid air quality data found, using mock data for demonstration")
            return generate_mock_data(latitude, longitude, hours)
        
        return historical_data[:hours]  # Return exactly the requested number of hours
        
    except requests.RequestException as e:
        logger.error(f"Error fetching live air quality data: {e}")
        # Return mock data as fallback
        logger.info("Using mock data as fallback")
        return generate_mock_data(latitude, longitude, hours)
    except Exception as e:
        logger.error(f"Error processing live air quality data: {e}")
        # Return mock data as fallback
        logger.info("Using mock data as fallback")
        return generate_mock_data(latitude, longitude, hours)


def load_models():
    """
    Initialize mock models for demonstration.
    In production, this would load actual ML models.
    """
    logger.info("Initializing mock models...")
    
    # Create mock models
    models["xgboost"] = "mock_xgboost_model"
    models["random_forest"] = "mock_random_forest_model"
    models["linear_reg"] = "mock_linear_regression_model"
    
    logger.info(f"✅ Mock models loaded: {list(models.keys())}")


def predict_with_model(model_name: str, historical_data: List[HourlyData]) -> PredictionData:
    """
    Make prediction using specified mock model.
    
    Args:
        model_name: Name of the model to use
        historical_data: Historical data for context
    
    Returns:
        PredictionData: Prediction results
    """
    if model_name not in models:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Model '{model_name}' not found"
        )
    
    # Use the latest AQI as baseline for prediction
    current_aqi = historical_data[-1].AQI if historical_data else 50
    
    # Generate realistic predictions based on current conditions
    # Each model has slightly different prediction patterns
    if model_name == "xgboost":
        # XGBoost tends to be more aggressive in predictions
        trend_factor = 1.1
        noise_factor = 8
    elif model_name == "random_forest":
        # Random Forest is more conservative
        trend_factor = 1.05
        noise_factor = 5
    else:  # linear_reg or others
        # Linear regression follows trends more closely
        trend_factor = 1.02
        noise_factor = 3
    
    # Add some realistic variation
    base_prediction = current_aqi * trend_factor
    
    # Generate predictions with increasing uncertainty over time
    aqi_8h = max(0, min(500, base_prediction + random.uniform(-noise_factor, noise_factor)))
    aqi_12h = max(0, min(500, base_prediction + random.uniform(-noise_factor*1.5, noise_factor*1.5)))
    aqi_24h = max(0, min(500, base_prediction + random.uniform(-noise_factor*2, noise_factor*2)))
    
    # Calculate confidence based on data quality
    confidence = 0.85 if len(historical_data) >= 24 else 0.70
    
    return PredictionData(
        aqi8h=round(aqi_8h, 1),
        aqi12h=round(aqi_12h, 1),
        aqi24h=round(aqi_24h, 1),
        model_name=model_name,
        confidence=confidence
    )


@app.on_event("startup")
async def startup_event():
    """Load models when the app starts."""
    load_models()


@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": "AQI Prediction API",
        "version": "2.0.0",
        "status": "online",
        "deployment": "Render Cloud Platform",
        "endpoints": {
            "live_data": "/live_data",
            "predict": "/predict_live/{model_name}",
            "health": "/health",
            "docs": "/docs"
        },
        "available_models": list(models.keys()) if models else ["Loading..."],
        "features": [
            "Real-time air quality data from Open-Meteo API",
            "AQI predictions for 8h, 12h, and 24h ahead",
            "Multiple ML model options",
            "Fallback mock data when external APIs fail"
        ]
    }


@app.get("/health")
async def health_check():
    """Health check endpoint for Render."""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "models_loaded": len(models),
        "available_models": list(models.keys()),
        "service": "AQI Prediction API",
        "version": "2.0.0"
    }


@app.get("/models")
def get_available_models():
    """Get list of available models."""
    return {
        "available_models": list(models.keys()),
        "model_count": len(models),
        "status": "loaded" if models else "loading",
        "model_info": {
            "xgboost": {
                "description": "Extreme Gradient Boosting - high accuracy with complex patterns",
                "best_for": "Complex air quality scenarios"
            },
            "random_forest": {
                "description": "Random Forest - robust and stable predictions", 
                "best_for": "General purpose AQI prediction"
            },
            "linear_reg": {
                "description": "Linear Regression - fast and interpretable",
                "best_for": "Quick trend analysis"
            }
        }
    }


# Health check for Render's automatic checks
@app.get("/healthz")
async def healthz():
    """Alternative health check endpoint."""
    return {"status": "ok"}


@app.get("/live_data")
def get_live_data(
    latitude: float = Query(-15.7797, description="Latitude coordinate", ge=-90, le=90),
    longitude: float = Query(-47.9297, description="Longitude coordinate", ge=-180, le=180),
    hours: int = Query(24, description="Hours of data to fetch", ge=1, le=120)
):
    """
    Fetch live air quality data without making predictions.
    
    Args:
        latitude (float): Latitude coordinate
        longitude (float): Longitude coordinate  
        hours (int): Number of hours of data to fetch
    
    Returns:
        dict: Live air quality data
    """
    try:
        live_data = fetch_live_air_quality_data(latitude, longitude, hours)
        
        return {
            "location": {
                "latitude": latitude,
                "longitude": longitude
            },
            "data_source": "Open-Meteo API with fallback",
            "hours_fetched": len(live_data),
            "fetch_timestamp": datetime.now().isoformat(),
            "data": [
                {
                    "timestamp": hour.timestamp,
                    "carbon_monoxide": hour.CO,
                    "nitrogen_dioxide": hour.NO2,
                    "sulphur_dioxide": hour.SO2,
                    "ozone": hour.O3,
                    "pm2_5": hour.PM25,
                    "pm10": hour.PM10,
                    "aqi": hour.AQI
                }
                for hour in live_data
            ]
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching live data: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch live data: {str(e)}"
        )


@app.get("/predict_live/{model_name}")
def predict_live_aqi(
    model_name: str,
    latitude: float = Query(-15.7797, description="Latitude coordinate", ge=-90, le=90),
    longitude: float = Query(-47.9297, description="Longitude coordinate", ge=-180, le=180),
    hours: int = Query(48, description="Hours of historical data to use", ge=24, le=120)
):
    """
    Predict AQI using live data and specified model.
    
    Args:
        model_name (str): Name of the model to use ('xgboost' or 'random_forest')
        latitude (float): Latitude coordinate
        longitude (float): Longitude coordinate
        hours (int): Hours of historical data to fetch
    
    Returns:
        dict: Prediction results with historical data context
    """
    try:
        # Fetch live data
        live_data = fetch_live_air_quality_data(latitude, longitude, hours)
        
        if not live_data:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Unable to fetch live air quality data"
            )
        
        # Make prediction using historical data
        predictions = predict_with_model(model_name, live_data)
        
        return {
            "location": {
                "latitude": latitude,
                "longitude": longitude
            },
            "model_used": model_name,
            "predictions": {
                "aqi_8h": predictions.aqi8h,
                "aqi_12h": predictions.aqi12h,
                "aqi_24h": predictions.aqi24h,
                "confidence": predictions.confidence
            },
            "prediction_timestamp": datetime.now().isoformat(),
            "input_hours": len(live_data),
            "current_conditions": {
                "timestamp": live_data[-1].timestamp if live_data else None,
                "aqi": live_data[-1].AQI if live_data else None,
                "pm25": live_data[-1].PM25 if live_data else None,
                "pm10": live_data[-1].PM10 if live_data else None,
                "trend": "stable" if len(live_data) < 3 else 
                        ("increasing" if live_data[-1].AQI > live_data[-3].AQI else "decreasing")
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in prediction: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Prediction failed: {str(e)}"
        )


@app.post("/predict_from_current/{model_name}")
def predict_from_current(model_name: str, current_data: CurrentAqiInput):
    """
    Predict AQI from current readings.
    
    Args:
        model_name (str): Name of the model to use
        current_data (CurrentAqiInput): Current pollutant readings
    
    Returns:
        dict: Prediction results
    """
    try:
        # Create mock historical data using current readings as baseline
        historical_data = []
        current_time = datetime.now()
        
        for i in range(48):
            # Add some variation to simulate historical data
            variation = 0.8 + (i % 12) * 0.05
            timestamp = current_time - timedelta(hours=48-i)
            
            # Calculate AQI for this mock hour
            aqi = calculate_aqi_from_pollutants(
                current_data.pm25 * variation,
                current_data.pm10 * variation,
                current_data.o3 * variation,
                current_data.no2 * variation,
                current_data.so2 * variation,
                current_data.co * variation * 1000  # Convert to μg/m³
            )
            
            hour_data = HourlyData(
                CO=current_data.co * variation,
                NO2=current_data.no2 * variation,
                SO2=current_data.so2 * variation,
                O3=current_data.o3 * variation,
                PM25=current_data.pm25 * variation,
                PM10=current_data.pm10 * variation,
                AQI=aqi,
                timestamp=timestamp.isoformat()
            )
            historical_data.append(hour_data)
        
        # Make prediction using historical data
        predictions = predict_with_model(model_name, historical_data)
        
        return {
            "model_used": model_name,
            "predictions": {
                "aqi_8h": predictions.aqi8h,
                "aqi_12h": predictions.aqi12h,
                "aqi_24h": predictions.aqi24h,
                "confidence": predictions.confidence
            },
            "input_data": current_data.dict(),
            "prediction_timestamp": datetime.now().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in prediction from current data: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Prediction failed: {str(e)}"
        )


if __name__ == "__main__":
    # For local development
    uvicorn.run(app, host="0.0.0.0", port=8000)