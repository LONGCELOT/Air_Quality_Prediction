import 'aqi_api_services.dart';
import '../services/home_widget_service.dart';

@pragma('vm:entry-point')
void backgroundCallback(Uri data) {
  _updateWidgets();
}

void _updateWidgets() async {
  try {
    // Get current AQI data
    final currentAQI = await AQIApiService.getCurrentAQI();
    
    // Get predictions
    final predictions = await AQIApiService.getPrediction();
    
    // Update widgets
    if (currentAQI != null) {
      await HomeWidgetService.updateCurrentAQIWidget(currentAQI);
    }
    
    if (predictions != null) {
      await HomeWidgetService.updatePredictionWidget(predictions);
    }
  } catch (e) {
    print('Error in background widget update: $e');
  }
}
