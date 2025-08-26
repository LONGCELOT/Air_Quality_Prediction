import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/aqi_data.dart';
import '../providers/aqi_provider.dart';
import '../utils/constants.dart';

class AQIChartCard extends StatelessWidget {
  const AQIChartCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AQIProvider>(
      builder: (context, provider, child) {
        final trend = provider.aqiTrend;

        if (provider.isLoading) {
          return _buildLoadingCard();
        }

        if (trend.isEmpty) {
          return _buildEmptyCard();
        }

        return _buildChartCard(context, trend, provider);
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
        height: 250,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        height: 250,
        child: const Center(
          child: Text('No historical data available', style: AppTextStyles.body2),
        ),
      ),
    );
  }

  Widget _buildChartCard(
      BuildContext context, List<HourlyDataPoint> data, AQIProvider provider) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.primary, size: AppDimensions.iconSizeLarge),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text('AQI Trend (24h)', style: AppTextStyles.headline3),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            SizedBox(
              height: 180,
              child: LineChart(_buildLineChartData(data, provider)),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(List<HourlyDataPoint> data, AQIProvider provider) {
    final chartData = data.take(24).toList();

    final spots = chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.aqi);
    }).toList();

    final avgAQI = spots.isEmpty
        ? 0.0
        : spots.map((s) => s.y).reduce((a, b) => a + b) / spots.length;

    final lineColor = provider.getAQIColor(avgAQI);

    double maxY = 0;
    for (final s in spots) {
      if (s.y > maxY) maxY = s.y;
    }
    maxY += 20;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 50,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.divider,
          strokeWidth: 1,
          dashArray: [3, 3],
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 6,
            getTitlesWidget: (value, meta) {
              final hours = (24 - value.toInt());
              if (hours <= 0) return const SizedBox.shrink();
              return Text('${hours}h ago', style: AppTextStyles.caption);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 50,
            reservedSize: 40,
            getTitlesWidget: (value, meta) =>
                Text(value.toInt().toString(), style: AppTextStyles.caption),
          ),
        ),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: AppColors.divider)),
      minX: 0,
      maxX: (chartData.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: [lineColor.withOpacity(0.8), lineColor]),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [lineColor.withOpacity(0.2), lineColor.withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
            final aqi = spot.y.toInt();
            final level = provider.getAQILevel(spot.y);
            return LineTooltipItem(
              'AQI: $aqi\n$level',
              const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            );
          }).toList(),
        ),
      ),
    );
  }
}
