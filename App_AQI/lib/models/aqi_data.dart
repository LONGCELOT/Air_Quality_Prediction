import 'package:json_annotation/json_annotation.dart';

part 'aqi_data.g.dart';

@JsonSerializable()
class CurrentAQIData {
  final double aqi;
  final double pm25;
  final double pm10;
  final double co;
  final double o3;
  final double no2;
  final double so2;
  final String timestamp;
  final String? location;

  CurrentAQIData({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.co,
    required this.o3,
    required this.no2,
    required this.so2,
    required this.timestamp,
    this.location,
  });

  factory CurrentAQIData.fromJson(Map<String, dynamic> json) =>
      _$CurrentAQIDataFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentAQIDataToJson(this);

  // Get AQI level and color
  String get aqiLevel {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  int get aqiColorValue {
    if (aqi <= 50) return 0xFF4CAF50; // Green
    if (aqi <= 100) return 0xFFFFEB3B; // Yellow
    if (aqi <= 150) return 0xFFFF9800; // Orange
    if (aqi <= 200) return 0xFFE91E63; // Pink/Red
    if (aqi <= 300) return 0xFF9C27B0; // Purple
    return 0xFF795548; // Brown
  }
}

@JsonSerializable()
class PredictionData {
  final double aqi8h;
  final double aqi12h;
  final double aqi24h;
  final String timestamp;
  final String model;

  PredictionData({
    required this.aqi8h,
    required this.aqi12h,
    required this.aqi24h,
    required this.timestamp,
    required this.model,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) =>
      _$PredictionDataFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionDataToJson(this);
}

@JsonSerializable()
class HourlyDataPoint {
  final double aqi;
  final double pm25;
  final double pm10;
  final double co;
  final double o3;
  final double no2;
  final double so2;
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final double windDirection;

  HourlyDataPoint({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.co,
    required this.o3,
    required this.no2,
    required this.so2,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
  });

  factory HourlyDataPoint.fromJson(Map<String, dynamic> json) =>
      _$HourlyDataPointFromJson(json);

  Map<String, dynamic> toJson() => _$HourlyDataPointToJson(this);
}

@JsonSerializable()
class APIResponse {
  final String status;
  final String message;
  final Map<String, dynamic>? data;

  APIResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory APIResponse.fromJson(Map<String, dynamic> json) =>
      _$APIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$APIResponseToJson(this);
}
