import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/aqi_data.dart';
import '../services/aqi_api_service.dart';
import '../services/location_service.dart';

class AQIProvider with ChangeNotifier {
  CurrentAQIData? _currentAQI;
  PredictionData? _predictions;
  List<HourlyDataPoint> _historicalData = [];
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  // Getters
  CurrentAQIData? get currentAQI => _currentAQI;
  PredictionData? get predictions => _predictions;
  List<HourlyDataPoint> get historicalData => _historicalData;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and fetch all data
  Future<void> initialize() async {
    await _getCurrentLocation();
    await fetchAllData();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await LocationService.getCurrentPosition();
      if (_currentPosition == null) {
        _currentPosition = await LocationService.getLastKnownPosition();
      }
    } catch (e) {
      _error = 'Failed to get location: $e';
    }
    notifyListeners();
  }

  // Fetch all AQI data
  Future<void> fetchAllData() async {
    _setLoading(true);
    _error = null;

    try {
      // Always use Brasilia coordinates for API calls, ignore user location
      const latitude = -15.7797;  // Brasilia latitude
      const longitude = -47.9297; // Brasilia longitude

      // Fetch current AQI data and predictions in parallel
      final futures = await Future.wait([
        AQIApiService.getCurrentAQI(latitude: latitude, longitude: longitude),
        AQIApiService.getPrediction(latitude: latitude, longitude: longitude),
        AQIApiService.getHistoricalData(latitude: latitude, longitude: longitude),
      ]);

      _currentAQI = futures[0] as CurrentAQIData?;
      _predictions = futures[1] as PredictionData?;
      _historicalData = futures[2] as List<HourlyDataPoint>;

      if (_currentAQI == null && _predictions == null) {
        _error = 'Failed to fetch AQI data';
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
      // Always use Brasilia coordinates
      const latitude = -15.7797;
      const longitude = -47.9297;
      
      _currentAQI = await AQIApiService.getCurrentAQI(
        latitude: latitude,
        longitude: longitude,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Error fetching current AQI: $e';
      notifyListeners();
    }
  }

  // Fetch only predictions
  Future<void> fetchPredictions() async {
    try {
      // Always use Brasilia coordinates
      const latitude = -15.7797;
      const longitude = -47.9297;
      
      _predictions = await AQIApiService.getPrediction(
        latitude: latitude,
        longitude: longitude,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Error fetching predictions: $e';
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await fetchAllData();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get AQI level description
  String getAQILevel(double aqi) {
    return AQIApiService.getAQILevel(aqi);
  }

  // Get AQI color
  Color getAQIColor(double aqi) {
    return Color(AQIApiService.getAQIColor(aqi));
  }

  // Get health recommendation based on AQI
  String getHealthRecommendation(double aqi) {
    if (aqi <= 50) {
      return 'Air quality is satisfactory, and air pollution poses little or no risk.';
    } else if (aqi <= 100) {
      return 'Air quality is acceptable. However, there may be a risk for some people, particularly those who are unusually sensitive to air pollution.';
    } else if (aqi <= 150) {
      return 'Members of sensitive groups may experience health effects. The general public is less likely to be affected.';
    } else if (aqi <= 200) {
      return 'Some members of the general public may experience health effects; members of sensitive groups may experience more serious health effects.';
    } else if (aqi <= 300) {
      return 'Health alert: The risk of health effects is increased for everyone.';
    } else {
      return 'Health warning of emergency conditions: everyone is more likely to be affected.';
    }
  }
}
