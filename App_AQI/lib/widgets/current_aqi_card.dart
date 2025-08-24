import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/aqi_data.dart';
import '../providers/aqi_provider.dart';
import '../utils/constants.dart';

class CurrentAQICard extends StatelessWidget {
  const CurrentAQICard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AQIProvider>(
      builder: (context, provider, child) {
        final currentAQI = provider.currentAQI;
        
        if (provider.isLoading) {
          return _buildLoadingCard();
        }
        
        if (currentAQI == null) {
          return _buildErrorCard(provider.error ?? 'No data available');
        }
        
        return _buildAQICard(context, currentAQI, provider);
      },
    );
  }

  Widget _buildLoadingCard() {
    // This card is fine as is.
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    // This card is fine as is.
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: AppDimensions.iconSizeLarge,
                color: AppColors.error,
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                error,
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAQICard(BuildContext context, CurrentAQIData currentAQI, AQIProvider provider) {
    final aqiColor = provider.getAQIColor(currentAQI.aqi);
    final aqiLevel = provider.getAQILevel(currentAQI.aqi);
    
    return Card(
      elevation: AppDimensions.cardElevation,
      shadowColor: aqiColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        side: BorderSide(color: aqiColor, width: 2),
      ),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current AQI',
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      'Air Quality Index',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: aqiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Icon(
                    Icons.air,
                    color: aqiColor,
                    size: AppDimensions.iconSizeLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge, vertical: AppDimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: aqiColor,
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: aqiColor.withOpacity(0.3),
                          blurRadius: AppDimensions.cardElevation,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'AQI ${currentAQI.aqi.toInt().toString()}',
                      style: AppTextStyles.body1.copyWith(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Text(
                    aqiLevel,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Text(
              'Pollutant Levels',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildPollutantGrid(currentAQI),
            const SizedBox(height: AppDimensions.paddingMedium),
            if (currentAQI.location != null)
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: AppDimensions.iconSizeMedium,
                      color: aqiColor,
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: Text(
                        currentAQI.location!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutantGrid(CurrentAQIData currentAQI) {
    final pollutants = [
      {'name': 'PM2.5', 'value': currentAQI.pm25, 'unit': 'μg/m³', 'color': Colors.orange},
      {'name': 'PM10', 'value': currentAQI.pm10, 'unit': 'μg/m³', 'color': Colors.deepOrange},
      {'name': 'CO', 'value': currentAQI.co, 'unit': 'mg/m³', 'color': Colors.red},
      {'name': 'O₃', 'value': currentAQI.o3, 'unit': 'μg/m³', 'color': Colors.blue},
      {'name': 'NO₂', 'value': currentAQI.no2, 'unit': 'μg/m³', 'color': Colors.purple},
      {'name': 'SO₂', 'value': currentAQI.so2, 'unit': 'μg/m³', 'color': Colors.green},
    ];

    return Column(
      children: [
        Row(
          children: List.generate(3, (index) => Expanded(child: _buildPollutantItem(pollutants[index]))),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: List.generate(3, (index) => Expanded(child: _buildPollutantItem(pollutants[index + 3]))),
        ),
      ],
    );
  }

  Widget _buildPollutantItem(Map<String, dynamic> pollutant) {
    final color = pollutant['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pollutant['name'] as String,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            '${(pollutant['value'] as double).toStringAsFixed(1)}',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            pollutant['unit'] as String,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
