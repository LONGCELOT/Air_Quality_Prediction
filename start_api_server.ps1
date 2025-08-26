# AQI Prediction API Startup Script
Write-Host "🚀 Starting AQI Prediction API Server..." -ForegroundColor Green
Write-Host ""

# Navigate to API directory
Set-Location "d:\CamTech\Y3T2\AI_and_its_application\FastAPI\aqi_prediction_api"

# Check if virtual environment exists and activate it
if (Test-Path ".venv\Scripts\Activate.ps1") {
    Write-Host "📦 Activating virtual environment..." -ForegroundColor Yellow
    & ".venv\Scripts\Activate.ps1"
} elseif (Test-Path "venv\Scripts\Activate.ps1") {
    Write-Host "📦 Activating virtual environment..." -ForegroundColor Yellow
    & "venv\Scripts\Activate.ps1"
} else {
    Write-Host "⚠️ No virtual environment found, using system Python" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🌐 Starting FastAPI server on http://localhost:8000" -ForegroundColor Cyan
Write-Host "📚 API docs: http://localhost:8000/docs" -ForegroundColor Blue
Write-Host "❤️ Health check: http://localhost:8000/health" -ForegroundColor Blue
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Red
Write-Host ""

# Start the server
python main.py
