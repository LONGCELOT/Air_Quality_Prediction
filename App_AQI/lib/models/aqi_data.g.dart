// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aqi_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentAQIData _$CurrentAQIDataFromJson(Map<String, dynamic> json) =>
    CurrentAQIData(
      aqi: (json['aqi'] as num).toDouble(),
      pm25: (json['pm25'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      co: (json['co'] as num).toDouble(),
      o3: (json['o3'] as num).toDouble(),
      no2: (json['no2'] as num).toDouble(),
      so2: (json['so2'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$CurrentAQIDataToJson(CurrentAQIData instance) =>
    <String, dynamic>{
      'aqi': instance.aqi,
      'pm25': instance.pm25,
      'pm10': instance.pm10,
      'co': instance.co,
      'o3': instance.o3,
      'no2': instance.no2,
      'so2': instance.so2,
      'timestamp': instance.timestamp,
      'location': instance.location,
    };

PredictionData _$PredictionDataFromJson(Map<String, dynamic> json) =>
    PredictionData(
      aqi8h: (json['aqi8h'] as num).toDouble(),
      aqi12h: (json['aqi12h'] as num).toDouble(),
      aqi24h: (json['aqi24h'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
      model: json['model'] as String,
    );

Map<String, dynamic> _$PredictionDataToJson(PredictionData instance) =>
    <String, dynamic>{
      'aqi8h': instance.aqi8h,
      'aqi12h': instance.aqi12h,
      'aqi24h': instance.aqi24h,
      'timestamp': instance.timestamp,
      'model': instance.model,
    };

HourlyDataPoint _$HourlyDataPointFromJson(Map<String, dynamic> json) =>
    HourlyDataPoint(
      aqi: (json['aqi'] as num).toDouble(),
      pm25: (json['pm25'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      co: (json['co'] as num).toDouble(),
      o3: (json['o3'] as num).toDouble(),
      no2: (json['no2'] as num).toDouble(),
      so2: (json['so2'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windDirection: (json['windDirection'] as num).toDouble(),
    );

Map<String, dynamic> _$HourlyDataPointToJson(HourlyDataPoint instance) =>
    <String, dynamic>{
      'aqi': instance.aqi,
      'pm25': instance.pm25,
      'pm10': instance.pm10,
      'co': instance.co,
      'o3': instance.o3,
      'no2': instance.no2,
      'so2': instance.so2,
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'pressure': instance.pressure,
      'windSpeed': instance.windSpeed,
      'windDirection': instance.windDirection,
    };

APIResponse _$APIResponseFromJson(Map<String, dynamic> json) => APIResponse(
  status: json['status'] as String,
  message: json['message'] as String,
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$APIResponseToJson(APIResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };
