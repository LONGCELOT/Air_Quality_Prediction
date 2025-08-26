package com.example.app_aqi

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class AQIWidgetProviderPrediction : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.aqi_prediction_widget)

            val aqi8h = widgetData.getString("aqi_8h", "--")
            val aqi12h = widgetData.getString("aqi_12h", "--")
            val aqi24h = widgetData.getString("aqi_24h", "--")
            
            val aqi8hLevel = widgetData.getString("aqi_8h_level", "Good")
            val aqi12hLevel = widgetData.getString("aqi_12h_level", "Good")
            val aqi24hLevel = widgetData.getString("aqi_24h_level", "Good")
            
            val predictionUpdate = widgetData.getString("prediction_update", "") ?: ""

            views.setTextViewText(R.id.widget_aqi_8h, aqi8h)
            views.setTextViewText(R.id.widget_aqi_12h, aqi12h)
            views.setTextViewText(R.id.widget_aqi_24h, aqi24h)
            
            views.setTextViewText(R.id.widget_aqi_8h_level, aqi8hLevel)
            views.setTextViewText(R.id.widget_aqi_12h_level, aqi12hLevel)
            views.setTextViewText(R.id.widget_aqi_24h_level, aqi24hLevel)

            if (predictionUpdate.isNotEmpty()) {
                try {
                    val formatter = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", java.util.Locale.getDefault())
                    val updateTime = formatter.parse(predictionUpdate)
                    val displayFormatter = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
                    val displayTime = displayFormatter.format(updateTime ?: java.util.Date())
                    views.setTextViewText(R.id.widget_prediction_update, "Updated: $displayTime")
                } catch (e: Exception) {
                    views.setTextViewText(R.id.widget_prediction_update, "Updated: --:--")
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
