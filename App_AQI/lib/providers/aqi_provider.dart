import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/aqi_data.dart';
import '../services/aqi_api_services.dart';
import '../services/location_service.dart';

class AQIProvider with ChangeNotifier {
  CurrentAQIData? _currentAQI;
  PredictionData? _predictions;
  List<HourlyDataPoint> _aqiTrend = [];
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  // Getters
  CurrentAQIData? get currentAQI => _currentAQI;
  PredictionData? get predictions => _predictions;
  List<HourlyDataPoint> get aqiTrend => _aqiTrend;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and fetch all data
  Future<void> initialize() async {
    await _getCurrentLocation();
    await fetchAllData();
  }

  // Get current location (non-blocking for AQI since we use Brasília)
  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await LocationService.getCurrentPosition();
      _currentPosition ??= await LocationService.getLastKnownPosition();
    } catch (e) {
      _error = 'Failed to get location: $e';
    }
    notifyListeners();
  }

  // Fetch all (current, predictions, trend)
  Future<void> fetchAllData() async {
    _setLoading(true);
    _error = null;

    try {
      const latitude = -15.7797;
      const longitude = -47.9297;

      final results = await Future.wait([
        AQIApiService.getMockCurrentAQI(),
        AQIApiService.getPrediction(latitude: latitude, longitude: longitude),
        AQIApiService.getMockAQITrend(),
      ]);

      _currentAQI = results[0] as CurrentAQIData?;
      _predictions = results[1] as PredictionData?;
      _aqiTrend = (results[2] as List<HourlyDataPoint>?) ?? [];

      if (_currentAQI == null && _predictions == null) {
        _error = 'No data available from server.';
      }
    } catch (e) {
      _error = 'Error fetching data: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Fetch only current AQI
  Future<void> fetchCurrentAQI() async {
    try {
      _currentAQI = await AQIApiService.getMockCurrentAQI();
      notifyListeners();
    } catch (e) {
      _error = 'Error fetching current AQI: $e';
      notifyListeners();
    }
  }

  // Fetch only predictions
  Future<void> fetchPredictions() async {
    try {
      const latitude = -15.7797;
      const longitude = -47.9297;
      _predictions = await AQIApiService.getPrediction(latitude: latitude, longitude: longitude);
      notifyListeners();
    } catch (e) {
      _error = 'Error fetching predictions: $e';
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refresh() async => fetchAllData();

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Internal
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // UI helpers
  String getAQILevel(double aqi) => AQIApiService.getAQILevel(aqi);
  Color getAQIColor(double aqi) => Color(AQIApiService.getAQIColor(aqi));

  String getHealthRecommendation(double aqi) {
    if (aqi <= 50) {
      return 'Air quality is satisfactory, and air pollution poses little or no risk.';
    } else if (aqi <= 100) {
      return 'Air quality is acceptable. Some people unusually sensitive to air pollution may be at risk.';
    } else if (aqi <= 150) {
      return 'Sensitive groups may experience health effects. The general public is less likely to be affected.';
    } else if (aqi <= 200) {
      return 'Some of the general public may experience health effects; sensitive groups may experience more serious effects.';
    } else if (aqi <= 300) {
      return 'Health alert: everyone may experience more serious health effects.';
    } else {
      return 'Health warnings of emergency conditions: everyone is more likely to be affected.';
    }
  }
}
