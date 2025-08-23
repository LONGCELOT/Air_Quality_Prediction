import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/aqi_data.dart';
import '../providers/aqi_provider.dart';
import '../utils/constants.dart';

class PredictionCard extends StatelessWidget {
  const PredictionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AQIProvider>(
      builder: (context, provider, child) {
        final predictions = provider.predictions;
        
        if (provider.isLoading) {
          return _buildLoadingCard();
        }
        
        if (predictions == null) {
          return _buildErrorCard(provider.error ?? 'No prediction data available');
        }
        
        return _buildPredictionCard(context, predictions, provider);
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

  Widget _buildPredictionCard(BuildContext context, PredictionData predictions, AQIProvider provider) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AQI Predictions',
                  style: AppTextStyles.headline3,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: AppDimensions.iconSizeSmall,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(
                        'XGBoost',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            _buildPredictionItem(
              context,
              '8 Hours',
              predictions.aqi8h,
              provider,
              Icons.schedule,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildPredictionItem(
              context,
              '12 Hours',
              predictions.aqi12h,
              provider,
              Icons.access_time,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildPredictionItem(
              context,
              '24 Hours',
              predictions.aqi24h,
              provider,
              Icons.today,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: AppDimensions.iconSizeSmall,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  Expanded(
                    child: Text(
                      'Predictions are based on XGBoost model with historical weather and air quality data.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
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

  Widget _buildPredictionItem(
    BuildContext context,
    String timeLabel,
    double aqiValue,
    AQIProvider provider,
    IconData icon,
  ) {
    final aqiColor = provider.getAQIColor(aqiValue);
    final aqiLevel = provider.getAQILevel(aqiValue);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: aqiColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(
          color: aqiColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: aqiColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: aqiColor,
              size: AppDimensions.iconSizeMedium,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeLabel,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  aqiLevel,
                  style: AppTextStyles.body2.copyWith(
                    color: aqiColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                aqiValue.toInt().toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: aqiColor,
                ),
              ),
              Text(
                'AQI',
                style: AppTextStyles.caption.copyWith(
                  color: aqiColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
