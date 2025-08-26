import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/aqi_data.dart';
import 'dart:math';

class AQIApiService {
  /// Mock: Get fake current AQI data for UI testing
  static Future<CurrentAQIData> getMockCurrentAQI() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CurrentAQIData(
      aqi: 35,
      pm25: 12.5,
      pm10: 20.1,
      co: 0.7,
      o3: 18.2,
      no2: 9.3,
      so2: 2.1,
      timestamp: DateTime.now().toIso8601String(),
      location: 'Brasília, Brazil',
    );
  }

  /// Mock: Get fake AQI trend data for UI testing
static Future<List<HourlyDataPoint>> getMockAQITrend() async {
  await Future.delayed(const Duration(milliseconds: 300));
  final now = DateTime.now();
  final random = Random();

  return List.generate(24, (i) {
    final wave = sin(i / 24 * 2 * pi); // smooth up & down
    final baseAqi = 28;
    final amplitude = 20;

    return HourlyDataPoint(
      aqi: baseAqi + amplitude * wave + random.nextInt(5),
      pm25: 15 + 5 * wave + random.nextDouble() * 2,
      pm10: 20 + 7 * wave + random.nextDouble() * 3,
      co: 0.5 + 0.1 * wave,
      o3: 15 + 5 * wave,
      no2: 8 + 2 * wave,
      so2: 2 + 0.5 * wave,
      temperature: 25 + 3 * wave,
      humidity: 60 - 10 * wave,
      pressure: 1010 + 5 * wave,
      windSpeed: 2 + 1 * wave,
      windDirection: 90,
      timestamp: now.subtract(Duration(hours: 23 - i)).toIso8601String(),
    );
  });
}
  // Platform-specific base URLs for local development
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (kDebugMode) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://192.168.1.XXX:8000'; // Update with your LAN IP
    }
  }

  // Default coordinates (Brasília, Brazil as fallback)
  static const double defaultLatitude = -15.7797;
  static const double defaultLongitude = -47.9297;

  /// Test API connectivity
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Connection timeout'),
          );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      return false;
    }
  }

  /// Helper: extract AQI value from either a number or a map like {"aqi": 80}
  static double _extractAqi(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is Map && value['aqi'] is num) {
        return (value['aqi'] as num).toDouble();
      }
    } catch (_) {}
    return 0.0;
  }

  /// Helper: extract double from dynamic (null/num/string)
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Fetch current AQI
  static Future<CurrentAQIData?> getCurrentAQI({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final lat = latitude ?? defaultLatitude;
      final lng = longitude ?? defaultLongitude;

      final url = Uri.parse('$baseUrl/live_data?latitude=$lat&longitude=$lng');
      debugPrint('🌐 Fetching current AQI: $url');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 12),
            onTimeout: () => throw Exception('Request timeout'),
          );

      debugPrint('📝 live_data status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('❌ live_data error body: ${response.body}');
        return null;
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      debugPrint('🌐 live_data raw: $body');

      dynamic current;
      if (body['current'] != null) {
        current = body['current'];
      } else if (body['data'] is List && body['data'].isNotEmpty) {
        current = body['data'][0];
      } else {
        current = body; // fallback: assume flat JSON
      }

      if (current is! Map) return null;

      return CurrentAQIData(
        aqi: _toDouble(current['aqi']),
        pm25: _toDouble(current['pm2_5'] ?? current['PM2.5']),
        pm10: _toDouble(current['pm10'] ?? current['PM10']),
        co: _toDouble(current['co'] ?? current['CO']),
        o3: _toDouble(current['o3'] ?? current['O3']),
        no2: _toDouble(current['no2'] ?? current['NO2']),
        so2: _toDouble(current['so2'] ?? current['SO2']),
        timestamp: current['timestamp'] ?? DateTime.now().toIso8601String(),
        location: body['location'] ?? 'Brasília, Brazil',
      );
    } catch (e) {
      debugPrint('❌ Error fetching current AQI: $e');
      return null;
    }
  }

  /// Fetch AQI predictions
  static Future<PredictionData?> getPrediction({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final lat = latitude ?? defaultLatitude;
      final lng = longitude ?? defaultLongitude;

      final url = Uri.parse(
        '$baseUrl/predict_from_live?latitude=$lat&longitude=$lng',
      );
      debugPrint('🔮 Fetching predictions: $url');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Prediction timeout'),
          );

      debugPrint('📝 predict_from_live status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('❌ predict_from_live error body: ${response.body}');
        return null;
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      debugPrint('🔮 predict_from_live raw: $body');

      final preds = (body['predictions'] ?? body) as Map<String, dynamic>;

      final a8 = _extractAqi(preds['8_hours'] ?? preds['h8'] ?? preds['aqi_8h']);
      final a12 =
          _extractAqi(preds['12_hours'] ?? preds['h12'] ?? preds['aqi_12h']);
      final a24 =
          _extractAqi(preds['24_hours'] ?? preds['h24'] ?? preds['aqi_24h']);

      return PredictionData(
        aqi8h: a8,
        aqi12h: a12,
        aqi24h: a24,
        timestamp: DateTime.now().toIso8601String(),
        model: 'predict_from_live',
      );
    } catch (e) {
      debugPrint('❌ Error fetching predictions: $e');
      return null;
    }
  }

  /// Fetch AQI trend
  static Future<List<HourlyDataPoint>> getAQITrend({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final lat = latitude ?? defaultLatitude;
      final lng = longitude ?? defaultLongitude;

      final url = Uri.parse('$baseUrl/live_data?latitude=$lat&longitude=$lng');
      final response = await http.get(url);

      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      debugPrint('📈 live_data trend raw: $body');

      List list;
      if (body is Map && body['trend'] is List) {
        list = body['trend'];
      } else if (body is Map && body['data'] is List) {
        list = body['data'];
      } else if (body is List) {
        list = body;
      } else {
        return [];
      }

      return list.map<HourlyDataPoint>((item) {
        final m = (item is Map) ? item : <String, dynamic>{};
        return HourlyDataPoint(
          aqi: _extractAqi(m['aqi']),
          pm25: _toDouble(m['pm2_5'] ?? m['PM2.5']),
          pm10: _toDouble(m['pm10'] ?? m['PM10']),
          co: _toDouble(m['co'] ?? m['CO']),
          o3: _toDouble(m['o3'] ?? m['O3']),
          no2: _toDouble(m['no2'] ?? m['NO2']),
          so2: _toDouble(m['so2'] ?? m['SO2']),
          temperature: _toDouble(m['temperature_2m']),
          humidity: _toDouble(m['relative_humidity_2m']),
          pressure: _toDouble(m['surface_pressure']),
          windSpeed: _toDouble(m['wind_speed_10m']),
          windDirection: _toDouble(m['wind_direction_10m']),
          timestamp: m['timestamp'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching AQI trend: $e');
      return [];
    }
  }

  /// Categorize AQI level
  static String getAQILevel(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  /// Return color by AQI level
  static int getAQIColor(double aqi) {
    if (aqi <= 50) return 0xFF4CAF50; // Green
    if (aqi <= 100) return 0xFFFFFF00; // Yellow
    if (aqi <= 150) return 0xFFFF9800; // Orange
    if (aqi <= 200) return 0xFFF44336; // Red
    if (aqi <= 300) return 0xFF9C27B0; // Purple
    return 0xFF795548; // Brown
  }
}
