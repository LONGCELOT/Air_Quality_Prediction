import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/aqi_data.dart';
import '../services/aqi_api_service.dart';

class HomeWidgetService {
  static const String _groupId = 'group.aqi.prediction.app';
  static const String _androidProviderName = 'AQIWidgetProvider';
  static const String _iOSWidgetName = 'AQIWidget';

  // Initialize home widget
  static Future<void> initialize() async {
    if (kIsWeb) return; // Skip on web platform
    
    try {
      await HomeWidget.setAppGroupId(_groupId);
    } catch (e) {
      print('Error initializing home widget: $e');
    }
  }

  // Update current AQI widget
  static Future<void> updateCurrentAQIWidget(CurrentAQIData? currentAQI) async {
    if (kIsWeb || currentAQI == null) return; // Skip on web platform

    try {
      // Save widget data
      await HomeWidget.saveWidgetData<String>('current_aqi', currentAQI.aqi.toInt().toString());
      await HomeWidget.saveWidgetData<String>('aqi_level', currentAQI.aqiLevel);
      await HomeWidget.saveWidgetData<String>('aqi_color', currentAQI.aqiColorValue.toString());
      await HomeWidget.saveWidgetData<String>('pm25', currentAQI.pm25.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('pm10', currentAQI.pm10.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('co', currentAQI.co.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('o3', currentAQI.o3.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('no2', currentAQI.no2.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('so2', currentAQI.so2.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('last_update', DateTime.now().toIso8601String());

      // Update widgets
      await HomeWidget.updateWidget(
        name: _iOSWidgetName,
        androidName: _androidProviderName,
      );
    } catch (e) {
      print('Error updating current AQI widget: $e');
    }
  }

  // Update prediction widget
  static Future<void> updatePredictionWidget(PredictionData? predictions) async {
    if (kIsWeb || predictions == null) return; // Skip on web platform

    try {
      // Save prediction data
      await HomeWidget.saveWidgetData<String>('aqi_8h', predictions.aqi8h.toInt().toString());
      await HomeWidget.saveWidgetData<String>('aqi_12h', predictions.aqi12h.toInt().toString());
      await HomeWidget.saveWidgetData<String>('aqi_24h', predictions.aqi24h.toInt().toString());
      
      // Save prediction levels and colors
      await HomeWidget.saveWidgetData<String>('aqi_8h_level', AQIApiService.getAQILevel(predictions.aqi8h));
      await HomeWidget.saveWidgetData<String>('aqi_12h_level', AQIApiService.getAQILevel(predictions.aqi12h));
      await HomeWidget.saveWidgetData<String>('aqi_24h_level', AQIApiService.getAQILevel(predictions.aqi24h));
      
      await HomeWidget.saveWidgetData<String>('aqi_8h_color', AQIApiService.getAQIColor(predictions.aqi8h).toString());
      await HomeWidget.saveWidgetData<String>('aqi_12h_color', AQIApiService.getAQIColor(predictions.aqi12h).toString());
      await HomeWidget.saveWidgetData<String>('aqi_24h_color', AQIApiService.getAQIColor(predictions.aqi24h).toString());
      
      await HomeWidget.saveWidgetData<String>('prediction_update', DateTime.now().toIso8601String());

      // Update widgets
      await HomeWidget.updateWidget(
        name: '${_iOSWidgetName}Prediction',
        androidName: '${_androidProviderName}Prediction',
      );
    } catch (e) {
      print('Error updating prediction widget: $e');
    }
  }

  // Background update function for widgets
  static Future<void> backgroundUpdate() async {
    if (kIsWeb) return; // Skip on web platform
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('last_latitude');
      final lng = prefs.getDouble('last_longitude');

      // Fetch current data
      final currentAQI = await AQIApiService.getCurrentAQI(
        latitude: lat,
        longitude: lng,
      );

      // Fetch predictions
      final predictions = await AQIApiService.getPrediction(
        latitude: lat,
        longitude: lng,
      );

      // Update widgets
      if (currentAQI != null) {
        await updateCurrentAQIWidget(currentAQI);
      }

      if (predictions != null) {
        await updatePredictionWidget(predictions);
      }
    } catch (e) {
      print('Error in background update: $e');
    }
  }

  // Save last known location for background updates
  static Future<void> saveLastLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_latitude', latitude);
    await prefs.setDouble('last_longitude', longitude);
  }

  // Check if widgets are enabled
  static Future<bool> areWidgetsEnabled() async {
    if (kIsWeb) return false; // Widgets not supported on web
    
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (e) {
      return false;
    }
  }

  // Request to pin widget to home screen
  static Future<bool> requestPinWidget() async {
    if (kIsWeb) return false; // Widgets not supported on web
    
    try {
      await HomeWidget.requestPinWidget(
        androidName: _androidProviderName,
      );
      return true;
    } catch (e) {
      print('Error requesting pin widget: $e');
      return false;
    }
  }

  // Clear widget data
  static Future<void> clearWidgetData() async {
    if (kIsWeb) return; // Skip on web platform
    
    try {
      await HomeWidget.saveWidgetData<String>('current_aqi', '');
      await HomeWidget.saveWidgetData<String>('aqi_level', '');
      await HomeWidget.saveWidgetData<String>('aqi_8h', '');
      await HomeWidget.saveWidgetData<String>('aqi_12h', '');
      await HomeWidget.saveWidgetData<String>('aqi_24h', '');
      
      await HomeWidget.updateWidget(
        name: _iOSWidgetName,
        androidName: _androidProviderName,
      );
    } catch (e) {
      print('Error clearing widget data: $e');
    }
  }
}
