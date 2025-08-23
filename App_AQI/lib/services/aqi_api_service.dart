import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/aqi_data.dart';

class AQIApiService {
  // Platform-specific base URLs
  static String get baseUrl {
    if (kIsWeb) {
      // For web platforms (Chrome, Firefox, etc.)
      return 'http://localhost:8000';
    } else {
      // For mobile platforms (Android emulator needs 10.0.2.2, real device needs actual IP)
      return 'http://10.0.2.2:8000';
    }
  }
  
  static const String model = 'xgboost';
  
  // Default coordinates (Brasília, Brazil as fallback)
  static const double defaultLatitude = -15.7797;
  static const double defaultLongitude = -47.9297;

  static Future<CurrentAQIData?> getCurrentAQI({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final lat = latitude ?? defaultLatitude;
      final lng = longitude ?? defaultLongitude;
      
      final url = Uri.parse('$baseUrl/live_data?latitude=$lat&longitude=$lng&hours=1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract current data from the API response
        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          final currentData = data['data'][0];
          return CurrentAQIData(
            aqi: (currentData['aqi'] ?? 0).toDouble(),
            pm25: (currentData['pm2_5'] ?? 0).toDouble(),
            pm10: (currentData['pm10'] ?? 0).toDouble(),
            co: (currentData['carbon_monoxide'] ?? 0).toDouble(),
            o3: (currentData['ozone'] ?? 0).toDouble(),
            no2: (currentData['nitrogen_dioxide'] ?? 0).toDouble(),
            so2: (currentData['sulphur_dioxide'] ?? 0).toDouble(),
            timestamp: DateTime.now().toIso8601String(),
            location: 'Lat: ${lat.toStringAsFixed(2)}, Lng: ${lng.toStringAsFixed(2)}',
          );
        }
      }
      return null;
    } catch (e) {
      print('Error fetching current AQI: $e');
      return null;
    }
  }

  static Future<PredictionData?> getPrediction({
    double? latitude,
    double? longitude,
    int hours = 48,
  }) async {
    try {
      final lat = latitude ?? defaultLatitude;
      final lng = longitude ?? defaultLongitude;
      
      final url = Uri.parse('$baseUrl/predict_live/$model?latitude=$lat&longitude=$lng&hours=$hours');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['predictions'] != null) {
          final predictions = data['predictions'];
          
          // The API returns predictions for 8h, 12h, and 24h
          double aqi8h = 0, aqi12h = 0, aqi24h = 0;
          
          // Extract the specific hour predictions
          aqi8h = (predictions['8h_prediction'] ?? 0).toDouble();
          aqi12h = (predictions['12h_prediction'] ?? 0).toDouble();
          aqi24h = (predictions['24h_prediction'] ?? 0).toDouble();
          
          return PredictionData(
            aqi8h: aqi8h,
            aqi12h: aqi12h,
            aqi24h: aqi24h,
            timestamp: DateTime.now().toIso8601String(),
            model: model,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error fetching predictions: $e');
      return null;
    }
  }

  static Future<List<HourlyDataPoint>> getHistoricalData({
    double? latitude,
    double? longitude,
    int hours = 48,
  }) async {
    try {
      final lat = latitude ?? defaultLatitude;
      final lng = longitude ?? defaultLongitude;
      
      final url = Uri.parse('$baseUrl/live_data?latitude=$lat&longitude=$lng&hours=$hours');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<HourlyDataPoint> historicalData = [];
        
        if (data['data'] != null) {
          final dataList = data['data'] as List;
          
          for (var item in dataList) {
            historicalData.add(HourlyDataPoint(
              aqi: (item['aqi'] ?? 0).toDouble(),
              pm25: (item['pm2_5'] ?? 0).toDouble(),
              pm10: (item['pm10'] ?? 0).toDouble(),
              co: (item['carbon_monoxide'] ?? 0).toDouble(),
              o3: (item['ozone'] ?? 0).toDouble(),
              no2: (item['nitrogen_dioxide'] ?? 0).toDouble(),
              so2: (item['sulphur_dioxide'] ?? 0).toDouble(),
              temperature: (item['temperature_2m'] ?? 0).toDouble(),
              humidity: (item['relative_humidity_2m'] ?? 0).toDouble(),
              pressure: (item['surface_pressure'] ?? 0).toDouble(),
              windSpeed: (item['wind_speed_10m'] ?? 0).toDouble(),
              windDirection: (item['wind_direction_10m'] ?? 0).toDouble(),
            ));
          }
        }
        
        return historicalData;
      }
      return [];
    } catch (e) {
      print('Error fetching historical data: $e');
      return [];
    }
  }

  static String getAQILevel(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  static int getAQIColor(double aqi) {
    if (aqi <= 50) return 0xFF4CAF50; // Green
    if (aqi <= 100) return 0xFFFFEB3B; // Yellow
    if (aqi <= 150) return 0xFFFF9800; // Orange
    if (aqi <= 200) return 0xFFE91E63; // Pink/Red
    if (aqi <= 300) return 0xFF9C27B0; // Purple
    return 0xFF795548; // Brown
  }
}
