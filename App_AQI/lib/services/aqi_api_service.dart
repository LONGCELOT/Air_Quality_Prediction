import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/aqi_data.dart';

class AQIApiService {
  // Platform-specific base URLs for local development
  static String get baseUrl {
    if (kIsWeb) {
      // For web platforms - direct localhost access
      return 'http://localhost:8000';
    } else if (kDebugMode) {
      // For mobile platforms in debug mode (simulator/emulator)
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      // iOS simulator can use localhost directly
      return 'http://10.0.2.2:8000';
    } else {
      // For release builds, use your actual local IP
      // Replace with your computer's IP address on local network
      return 'http://192.168.1.XXX:8000'; // Update XXX with your IP
    }
  }
  
  static const String model = 'xgboost';
  
  // Default coordinates (Brasília, Brazil as fallback)
  static const double defaultLatitude = -15.7797;
  static const double defaultLongitude = -47.9297;

  // Test API connectivity
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      print('Testing connection to: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      print('Make sure FastAPI server is running on: $baseUrl');
      print('Run: cd aqi_prediction_api && python main.py');
      return false;
    }
  }

  static Future<CurrentAQIData?> getCurrentAQI({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final lat = latitude ?? defaultLatitude;
      final lng = longitude ?? defaultLongitude;
      
      final url = Uri.parse('$baseUrl/live_data?latitude=$lat&longitude=$lng&hours=1');
      print('🌐 Fetching current AQI from: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('📊 Current AQI response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Current AQI data received successfully');
        
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
            location: 'Brasília, Brazil',
          );
        }
      } else {
        print('❌ API returned status ${response.statusCode}: ${response.body}');
      }
      return null;
    } catch (e) {
      print('❌ Error fetching current AQI: $e');
      print('💡 Make sure FastAPI server is running: cd aqi_prediction_api && python main.py');
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
      print('🔮 Fetching predictions from: $url');
      
      final response = await http.post(url, // Changed to POST
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Prediction request timeout');
        },
      );

      print('📈 Prediction response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Prediction data received successfully');
        
        if (data['predictions'] != null) {
          final predictions = data['predictions'];
          
          // Extract predictions using the correct field names from API response
          final aqi8h = (predictions['8_hours']?['aqi'] ?? 0).toDouble();
          final aqi12h = (predictions['12_hours']?['aqi'] ?? 0).toDouble(); 
          final aqi24h = (predictions['24_hours']?['aqi'] ?? 0).toDouble();
          
          print('🎯 Predictions: 8h=$aqi8h, 12h=$aqi12h, 24h=$aqi24h');
          
          return PredictionData(
            aqi8h: aqi8h,
            aqi12h: aqi12h,
            aqi24h: aqi24h,
            timestamp: DateTime.now().toIso8601String(),
            model: model,
          );
        }
      } else {
        print('❌ Prediction API returned status ${response.statusCode}: ${response.body}');
      }
      return null;
    } catch (e) {
      print('❌ Error fetching predictions: $e');
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
    if (aqi <= 100) return 0xFFFF0000; // Yellow
    if (aqi <= 150) return 0xFFFF9800; // Orange
    if (aqi <= 200) return 0xFFE91E63; // Pink/Red
    if (aqi <= 300) return 0xFF9C27B0; // Purple
    return 0xFF795548; // Brown
  }
}
