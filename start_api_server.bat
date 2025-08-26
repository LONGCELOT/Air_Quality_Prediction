@echo off
echo Starting AQI Prediction API Server...
echo.
echo Make sure you're in the correct directory with main.py
echo.
cd /d "d:\CamTech\Y3T2\AI_and_its_application\FastAPI\aqi_prediction_api"

echo Activating virtual environment...
if exist ".venv\Scripts\activate.bat" (
    call .venv\Scripts\activate.bat
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo No virtual environment found, using system Python
)

echo.
echo Starting FastAPI server on http://localhost:8000
echo API docs will be available at: http://localhost:8000/docs
echo Health check: http://localhost:8000/health
echo.
echo Press Ctrl+C to stop the server
echo.

python main.py
