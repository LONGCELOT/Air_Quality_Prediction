import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/aqi_data.dart';
import '../providers/aqi_provider.dart';
import '../utils/constants.dart';

class EnhancedAQICard extends StatelessWidget {
  const EnhancedAQICard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AQIProvider>(
      builder: (context, provider, child) {
        final currentAQI = provider.currentAQI;
        final predictions = provider.predictions;
        
        if (provider.isLoading) {
          return _buildLoadingCard();
        }
        
        if (currentAQI == null) {
          return _buildErrorCard(provider.error ?? 'No data available');
        }
        
        return _buildEnhancedCard(context, currentAQI, predictions, provider);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        height: 300,
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Text(
                'Error',
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.error,
                ),
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

  Widget _buildEnhancedCard(BuildContext context, CurrentAQIData currentAQI, PredictionData? predictions, AQIProvider provider) {
    final aqiColor = provider.getAQIColor(currentAQI.aqi);
    final aqiLevel = provider.getAQILevel(currentAQI.aqi);
    
    return Card(
      elevation: 8,
      shadowColor: aqiColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              aqiColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeader(currentAQI, aqiColor),
              const SizedBox(height: 24),
              
              // Main current AQI display
              _buildCurrentAQISection(currentAQI, aqiColor, aqiLevel),
              const SizedBox(height: 24),
              
              // Predictions section
              if (predictions != null) ...[
                _buildPredictionsSection(predictions, provider),
                const SizedBox(height: 20),
              ],
              
              // Pollutant levels in a compact grid
              _buildCompactPollutantGrid(currentAQI),
              const SizedBox(height: 16),
              
              // Location info
              if (currentAQI.location != null)
                _buildLocationInfo(currentAQI, aqiColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CurrentAQIData currentAQI, Color aqiColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Air Quality',
              style: AppTextStyles.headline2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Real-time & Forecast',
              style: AppTextStyles.body2.copyWith(
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
    );
  }

  Widget _buildCurrentAQISection(CurrentAQIData currentAQI, Color aqiColor, String aqiLevel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            aqiColor.withOpacity(0.8),
            aqiColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: aqiColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current AQI',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentAQI.aqi.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  aqiLevel,
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Now',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsSection(PredictionData predictions, AQIProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forecast',
          style: AppTextStyles.headline3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildPredictionItem('8h', predictions.aqi8h, provider)),
            const SizedBox(width: 12),
            Expanded(child: _buildPredictionItem('12h', predictions.aqi12h, provider)),
            const SizedBox(width: 12),
            Expanded(child: _buildPredictionItem('24h', predictions.aqi24h, provider)),
          ],
        ),
      ],
    );
  }

  Widget _buildPredictionItem(String timeLabel, double aqi, AQIProvider provider) {
    final color = provider.getAQIColor(aqi);
    final level = provider.getAQILevel(aqi);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            timeLabel,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            aqi.toInt().toString(),
            style: AppTextStyles.headline2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            level.split(' ')[0], // Take first word of level
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPollutantGrid(CurrentAQIData currentAQI) {
    final pollutants = [
      {'name': 'PM2.5', 'value': currentAQI.pm25, 'unit': 'μg/m³', 'color': Colors.orange},
      {'name': 'PM10', 'value': currentAQI.pm10, 'unit': 'μg/m³', 'color': Colors.deepOrange},
      {'name': 'CO', 'value': currentAQI.co, 'unit': 'mg/m³', 'color': Colors.red},
      {'name': 'O₃', 'value': currentAQI.o3, 'unit': 'μg/m³', 'color': Colors.blue},
      {'name': 'NO₂', 'value': currentAQI.no2, 'unit': 'μg/m³', 'color': Colors.purple},
      {'name': 'SO₂', 'value': currentAQI.so2, 'unit': 'μg/m³', 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Air Pollutants',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 3.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: pollutants.length,
          itemBuilder: (context, index) {
            final pollutant = pollutants[index];
            final color = pollutant['color'] as Color;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      pollutant['name'] as String,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 9,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      (pollutant['value'] as double).toStringAsFixed(1),
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationInfo(CurrentAQIData currentAQI, Color aqiColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: aqiColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 18,
            color: aqiColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentAQI.location!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: aqiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Live',
              style: AppTextStyles.caption.copyWith(
                color: aqiColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
