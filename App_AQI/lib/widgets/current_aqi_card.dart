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
      elevation: 8,
      shadowColor: aqiColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              aqiColor.withOpacity(0.03),
            ],
          ),
          border: Border.all(
            color: aqiColor.withOpacity(0.2),
            width: 1,
          ),
        ),
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
                    const SizedBox(height: 4),
                    Text(
                      'Air Quality Index',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: aqiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.air,
                    color: aqiColor,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: aqiColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          currentAQI.aqi.toInt().toString(),
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: aqiColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AQI',
                          style: AppTextStyles.body1.copyWith(
                            color: aqiColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: aqiColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: aqiColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      aqiLevel,
                      style: AppTextStyles.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pollutant Levels',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildPollutantGrid(currentAQI),
            const SizedBox(height: 16),
            if (currentAQI.location != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: aqiColor,
                    ),
                    const SizedBox(width: 8),
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: pollutants.length,
      itemBuilder: (context, index) {
        final pollutant = pollutants[index];
        final color = pollutant['color'] as Color;
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pollutant['name'] as String,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(pollutant['value'] as double).toStringAsFixed(1)}',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                pollutant['unit'] as String,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
