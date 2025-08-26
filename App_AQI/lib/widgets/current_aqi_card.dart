import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aqi_provider.dart';
import '../services/aqi_api_services.dart';

class CurrentAQICard extends StatelessWidget {
  const CurrentAQICard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AQIProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Card(
        color: Colors.red[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("❌ ${provider.error}"),
        ),
      );
    }

    final aqi = provider.currentAQI?.aqi ?? 0.0;
    final aqiLevel = AQIApiService.getAQILevel(aqi);
    final aqiColor = AQIApiService.getAQIColor(aqi);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Current Air Quality",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "AQI: ${aqi.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(aqiColor),
                  ),
                ),
                Text(
                  aqiLevel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(aqiColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("Location: ${provider.currentAQI?.location ?? "Unknown"}"),
            Text("PM2.5: ${provider.currentAQI?.pm25 ?? 0} µg/m³"),
            Text("PM10: ${provider.currentAQI?.pm10 ?? 0} µg/m³"),
          ],
        ),
      ),
    );
  }
}
