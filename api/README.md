# AQI Prediction API - Render Deployment

This API provides real-time Air Quality Index (AQI) predictions using machine learning models.

## 🚀 Deployment on Render

### Quick Deploy to Render

1. **Fork/Clone this repository**
2. **Connect to Render:**
   - Go to [Render.com](https://render.com)
   - Create a new Web Service
   - Connect your GitHub repository
   - Select the `api` folder as the root directory

3. **Configure Render Settings:**
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - **Environment:** `Python 3.11`

### Environment Variables (Optional)
- `PORT`: Auto-configured by Render
- `PYTHON_VERSION`: 3.11 (recommended)

## 📋 API Endpoints

### Health Check
- `GET /health` - Service health status

### Data Endpoints
- `GET /live_data` - Fetch live air quality data
  - Parameters: `latitude`, `longitude`, `hours`
  
### Prediction Endpoints
- `GET /predict_live/{model_name}` - Predict AQI from live data
  - Models: `xgboost`, `random_forest`
  - Parameters: `latitude`, `longitude`, `hours`

- `POST /predict_from_current/{model_name}` - Predict from current readings
  - Body: JSON with current pollutant levels

### Model Information
- `GET /models` - List available models

## 📊 Response Format

```json
{
  "predictions": {
    "aqi_8h": 45.2,
    "aqi_12h": 48.7,
    "aqi_24h": 52.1,
    "confidence": 0.85
  },
  "location": {
    "latitude": -15.7797,
    "longitude": -47.9297
  },
  "model_used": "xgboost"
}
```

## 🔧 Local Development

```bash
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Visit: http://localhost:8000/docs

## 📚 API Documentation

Once deployed, access interactive docs at:
- **Swagger UI:** `https://your-app.onrender.com/docs`
- **ReDoc:** `https://your-app.onrender.com/redoc`

## 🌍 CORS Configuration

The API includes CORS middleware for web app integration. In production, update the `allow_origins` list in `main.py` to include your frontend domain.

## ⚡ Performance Notes

- First request may take 10-15 seconds (cold start)
- Subsequent requests are fast (~100-500ms)
- Uses fallback mock data if external APIs fail

## 🔗 Integration Example

```javascript
// Example frontend integration
const response = await fetch('https://your-api.onrender.com/predict_live/xgboost?latitude=-15.7797&longitude=-47.9297');
const data = await response.json();
console.log('AQI Predictions:', data.predictions);
```
