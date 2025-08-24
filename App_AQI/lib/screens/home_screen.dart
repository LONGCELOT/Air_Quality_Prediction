import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aqi_provider.dart';
import '../widgets/enhanced_aqi_card.dart';
import '../widgets/aqi_chart_card.dart';
import '../services/home_widget_service.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize home widget service
    await HomeWidgetService.initialize();
    
    // Register background callback for widgets
    // HomeWidget.registerBackgroundCallback(backgroundCallback);
    
    // Initialize AQI provider
    final provider = Provider.of<AQIProvider>(context, listen: false);
    await provider.initialize();
    
    // Update widgets with initial data
    await _updateWidgets();
  }

  Future<void> _updateWidgets() async {
    final provider = Provider.of<AQIProvider>(context, listen: false);
    
    // Save Brasília location for background updates (where our data comes from)
    if (provider.currentAQI != null) {
      await HomeWidgetService.saveLastLocation(
        -15.7797, // Brasília latitude
        -47.9297, // Brasília longitude
      );
    }
    
    // Update enhanced widget (weather-like style)
    await HomeWidgetService.updateEnhancedAQIWidget(provider.currentAQI, provider.predictions);
    
    // Update individual widgets for backward compatibility
    await HomeWidgetService.updateCurrentAQIWidget(provider.currentAQI);
    await HomeWidgetService.updatePredictionWidget(provider.predictions);
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<AQIProvider>(context, listen: false);
    await provider.refresh();
    await _updateWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.air,
              size: AppDimensions.iconSizeLarge,
              color: AppColors.textLight,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            const Text(
              'AQI Prediction',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<AQIProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : _refreshData,
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuSelection(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_widget',
                child: ListTile(
                  leading: Icon(Icons.widgets),
                  title: Text('Add Widget'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AQIProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location info
                  if (provider.currentPosition != null)
                    _buildLocationInfo(provider),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  // Enhanced AQI Card (combines current AQI and predictions)
                  const EnhancedAQICard(),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  // Chart Card
                  const AQIChartCard(),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  // Widget info card
                  _buildWidgetInfoCard(),
                  
                  const SizedBox(height: AppDimensions.paddingLarge),
                  
                  // Health recommendation
                  if (provider.currentAQI != null)
                    _buildHealthRecommendation(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppDimensions.iconSizeXLarge * 2,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'Oops! Something went wrong',
              style: AppTextStyles.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              error,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(AQIProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Data source location
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.primary,
                size: AppDimensions.iconSizeMedium,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Air Quality Data for',
                      style: AppTextStyles.body2,
                    ),
                    Text(
                      'Brasília, Brazil',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (provider.currentPosition != null) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            const Divider(),
            const SizedBox(height: AppDimensions.paddingSmall),
            // User's detected location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconSizeSmall,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Location Detected',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        'Lat: ${provider.currentPosition!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${provider.currentPosition!.longitude.toStringAsFixed(4)}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWidgetInfoCard() {
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
                Icon(
                  Icons.widgets,
                  color: AppColors.primary,
                  size: AppDimensions.iconSizeLarge,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text(
                  'Home Screen Widget',
                  style: AppTextStyles.headline3,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'Add AQI widgets to your home screen for quick access to current air quality and predictions.',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addWidgetToHomeScreen,
                icon: const Icon(Icons.add),
                label: const Text('Add Widget'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecommendation(AQIProvider provider) {
    final aqi = provider.currentAQI!.aqi;
    final recommendation = provider.getHealthRecommendation(aqi);
    final color = provider.getAQIColor(aqi);

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
                Icon(
                  Icons.health_and_safety,
                  color: color,
                  size: AppDimensions.iconSizeLarge,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text(
                  'Health Recommendation',
                  style: AppTextStyles.headline3,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              recommendation,
              style: AppTextStyles.body1,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'add_widget':
        _addWidgetToHomeScreen();
        break;
      case 'settings':
        // TODO: Navigate to settings
        break;
      case 'about':
        _showAboutDialog();
        break;
    }
  }

  Future<void> _addWidgetToHomeScreen() async {
    try {
      final isSupported = await HomeWidgetService.areWidgetsEnabled();
      if (!isSupported) {
        _showSnackBar('Widgets are not supported on this device');
        return;
      }

      final success = await HomeWidgetService.requestPinWidget();
      if (success) {
        _showSnackBar('Widget added to home screen!');
      } else {
        _showSnackBar('Failed to add widget. Please add manually from widgets menu.');
      }
    } catch (e) {
      _showSnackBar('Error adding widget: $e');
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About AQI Prediction'),
        content: const Text(
          'This app provides real-time air quality index (AQI) data and predictions using advanced machine learning models. '
          'Stay informed about air quality in your area and plan your activities accordingly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
