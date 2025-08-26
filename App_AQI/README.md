# AQI Prediction App

A comprehensive Flutter application for real-time Air Quality Index (AQI) monitoring and prediction with home screen widgets.

## Features

### 🌟 Core Features
- **Real-time AQI Monitoring**: Current air quality index and pollutant levels (PM2.5, PM10, CO, O₃, NO₂, SO₂)
- **AI-Powered Predictions**: 8h, 12h, and 24h AQI forecasts using XGBoost machine learning model
- **Location-based Data**: Automatic location detection or manual coordinates input
- **Interactive Charts**: Historical AQI trend visualization
- **Health Recommendations**: Color-coded AQI levels with health advice

### 📱 Home Screen Widgets
- **Current AQI Widget**: Displays real-time AQI and pollutant levels
- **Prediction Widget**: Shows upcoming AQI predictions for different time intervals
- **Auto-refresh**: Background updates for always current information

### 🎨 User Interface
- **Material Design 3**: Modern, clean interface following Flutter's latest design guidelines
- **Responsive Layout**: Adapts to different screen sizes
- **Color-coded AQI Levels**:
  - 🟢 Good (0-50)
  - 🟡 Moderate (51-100)
  - 🟠 Unhealthy for Sensitive Groups (101-150)
  - 🔴 Unhealthy (151-200)
  - 🟣 Very Unhealthy (201-300)
  - 🟤 Hazardous (300+)

## API Integration

The app connects to a FastAPI backend that provides:
- Live air quality data from Open-Meteo API
- XGBoost-based AQI predictions
- Historical data for trending

### Required Endpoints
- `GET /live_data`: Current air quality data
- `POST /predict_live/xgboost`: AQI predictions

## Installation & Setup

### Prerequisites
- Flutter 3.32.2 or higher
- Android SDK (for Android builds)
- Dart 3.8.1 or higher

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  provider: ^6.1.1
  json_annotation: ^4.8.1
  geolocator: ^10.1.0
  permission_handler: ^11.1.0
  home_widget: ^0.6.0
  card_swiper: ^3.0.1
  shimmer: ^3.0.0
  fl_chart: ^0.66.0
  shared_preferences: ^2.2.2
```

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd App_AQI
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate JSON serialization files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure API endpoint**
   Update the `baseUrl` in `lib/services/aqi_api_service.dart`:
   ```dart
   static const String baseUrl = 'YOUR_API_URL_HERE';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── aqi_data.dart        # Data models for AQI information
│   └── aqi_data.g.dart      # Generated serialization code
├── providers/
│   └── aqi_provider.dart    # State management for AQI data
├── screens/
│   └── home_screen.dart     # Main app screen
├── services/
│   ├── aqi_api_service.dart      # API communication
│   ├── location_service.dart     # Location services
│   ├── home_widget_service.dart  # Widget management
│   └── background_service.dart   # Background updates
├── utils/
│   └── constants.dart       # App constants and styling
└── widgets/
    ├── current_aqi_card.dart     # Current AQI display widget
    ├── prediction_card.dart      # Predictions display widget
    └── aqi_chart_card.dart       # Historical chart widget
```

## Android Widget Configuration

The app includes native Android widgets for home screen integration:

### Widget Files
- `android/app/src/main/kotlin/com/example/app_aqi/AQIWidgetProvider.kt`
- `android/app/src/main/kotlin/com/example/app_aqi/AQIWidgetProviderPrediction.kt`
- Widget layouts in `android/app/src/main/res/layout/`

### Adding Widgets to Home Screen
1. Long-press on home screen
2. Select "Widgets"
3. Find "AQI Prediction" widgets
4. Drag to desired location

## Permissions

The app requires the following permissions:
- `ACCESS_FINE_LOCATION`: For precise location-based AQI data
- `ACCESS_COARSE_LOCATION`: For approximate location
- `INTERNET`: For API communication

## Machine Learning Model

The app uses XGBoost (eXtreme Gradient Boosting) for AQI predictions because:
- **High Accuracy**: Superior performance compared to other models
- **Temporal Analysis**: Excellent at capturing time-series patterns
- **Feature Importance**: Understands relationships between weather and air quality
- **Robust**: Handles missing data and outliers effectively

## Data Sources

- **Current Data**: Open-Meteo Air Quality API
- **Weather Data**: Integrated meteorological information
- **Predictions**: Custom-trained XGBoost models

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Troubleshooting

### Common Issues

1. **Location not working**
   - Check location permissions
   - Ensure GPS is enabled
   - Try manual coordinates

2. **API errors**
   - Verify API endpoint URL
   - Check internet connection
   - Confirm API server is running

3. **Widget not updating**
   - Check background app refresh permissions
   - Restart the app
   - Re-add widget to home screen

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Open-Meteo for providing free air quality API
- Flutter team for the excellent framework
- XGBoost developers for the machine learning library
