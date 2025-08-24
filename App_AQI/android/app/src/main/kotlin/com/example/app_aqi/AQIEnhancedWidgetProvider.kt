package com.example.app_aqi

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews
import android.content.SharedPreferences

/**
 * Enhanced AQI Widget Provider - Weather style widget
 * Shows current AQI and 8h, 12h, 24h predictions
 */
class AQIEnhancedWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    // Get shared preferences data from Flutter
    val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    
    // Current AQI data
    val currentAQI = prefs.getString("flutter.current_aqi", "0") ?: "0"
    val aqiLevel = prefs.getString("flutter.aqi_level", "Unknown") ?: "Unknown"
    val location = prefs.getString("flutter.location", "Unknown") ?: "Unknown"
    
    // Prediction data
    val aqi8h = prefs.getString("flutter.aqi_8h", "0") ?: "0"
    val aqi12h = prefs.getString("flutter.aqi_12h", "0") ?: "0"
    val aqi24h = prefs.getString("flutter.aqi_24h", "0") ?: "0"
    
    val aqi8hLevel = prefs.getString("flutter.aqi_8h_level", "Unknown") ?: "Unknown"
    val aqi12hLevel = prefs.getString("flutter.aqi_12h_level", "Unknown") ?: "Unknown"
    val aqi24hLevel = prefs.getString("flutter.aqi_24h_level", "Unknown") ?: "Unknown"
    
    // Pollutants
    val pm25 = prefs.getString("flutter.pm25", "0") ?: "0"
    val pm10 = prefs.getString("flutter.pm10", "0") ?: "0"
    val co = prefs.getString("flutter.co", "0") ?: "0"
    
    // Get colors
    val currentAQIValue = currentAQI.toDoubleOrNull() ?: 0.0
    val aqi8hValue = aqi8h.toDoubleOrNull() ?: 0.0
    val aqi12hValue = aqi12h.toDoubleOrNull() ?: 0.0
    val aqi24hValue = aqi24h.toDoubleOrNull() ?: 0.0

    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.aqi_enhanced_widget)
    
    // Set location (no widget_title in our layout)
    views.setTextViewText(R.id.widget_location, location)
    
    // Set current AQI
    views.setTextViewText(R.id.current_aqi, currentAQI)
    views.setTextViewText(R.id.current_aqi_level, aqiLevel)
    
    // Set dynamic background color for current AQI section
    val currentAQIColor = getAQIColor(currentAQIValue)
    val gradientDrawable = android.graphics.drawable.GradientDrawable()
    gradientDrawable.shape = android.graphics.drawable.GradientDrawable.RECTANGLE
    gradientDrawable.cornerRadius = 48f // 16dp in pixels
    gradientDrawable.colors = intArrayOf(currentAQIColor, darkenColor(currentAQIColor))
    gradientDrawable.orientation = android.graphics.drawable.GradientDrawable.Orientation.TL_BR
    
    
    // Set predictions
    views.setTextViewText(R.id.aqi_8h, aqi8h)
    views.setTextViewText(R.id.aqi_8h_level, getShortLevel(aqi8hLevel))
    views.setTextColor(R.id.aqi_8h, getAQIColor(aqi8hValue))
    
    views.setTextViewText(R.id.aqi_12h, aqi12h)
    views.setTextViewText(R.id.aqi_12h_level, getShortLevel(aqi12hLevel))
    views.setTextColor(R.id.aqi_12h, getAQIColor(aqi12hValue))
    
    views.setTextViewText(R.id.aqi_24h, aqi24h)
    views.setTextViewText(R.id.aqi_24h_level, getShortLevel(aqi24hLevel))
    views.setTextColor(R.id.aqi_24h, getAQIColor(aqi24hValue))

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun getAQIColor(aqi: Double): Int {
    return when {
        aqi <= 50 -> Color.parseColor("#4CAF50")   // Green
        aqi <= 100 -> Color.parseColor("#FFEB3B")  // Yellow
        aqi <= 150 -> Color.parseColor("#FF9800")  // Orange
        aqi <= 200 -> Color.parseColor("#E91E63")  // Red
        aqi <= 300 -> Color.parseColor("#9C27B0")  // Purple
        else -> Color.parseColor("#795548")        // Brown
    }
}

private fun getShortLevel(level: String): String {
    return when {
        level.contains("Good") -> "Good"
        level.contains("Moderate") -> "Mod"
        level.contains("Unhealthy for Sensitive") -> "USG"
        level.contains("Unhealthy") -> "Unh"
        level.contains("Very Unhealthy") -> "VUh"
        level.contains("Hazardous") -> "Haz"
        else -> "Unk"
    }
}

private fun darkenColor(color: Int): Int {
    val factor = 0.8f
    val red = (Color.red(color) * factor).toInt()
    val green = (Color.green(color) * factor).toInt()
    val blue = (Color.blue(color) * factor).toInt()
    return Color.rgb(red, green, blue)
}
