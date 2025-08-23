package com.example.app_aqi

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class AQIWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.aqi_widget)

            val currentAqi = widgetData.getString("current_aqi", "--")
            val aqiLevel = widgetData.getString("aqi_level", "Loading...")
            val pm25 = widgetData.getString("pm25", "--")
            val pm10 = widgetData.getString("pm10", "--")
            val co = widgetData.getString("co", "--")
            val o3 = widgetData.getString("o3", "--")
            val no2 = widgetData.getString("no2", "--")
            val so2 = widgetData.getString("so2", "--")
            val lastUpdate = widgetData.getString("last_update", "") ?: ""

            views.setTextViewText(R.id.widget_aqi_value, currentAqi)
            views.setTextViewText(R.id.widget_aqi_level, aqiLevel)
            views.setTextViewText(R.id.widget_pm25, pm25)
            views.setTextViewText(R.id.widget_pm10, pm10)
            views.setTextViewText(R.id.widget_co, co)
            views.setTextViewText(R.id.widget_o3, o3)
            views.setTextViewText(R.id.widget_no2, no2)
            views.setTextViewText(R.id.widget_so2, so2)

            if (lastUpdate.isNotEmpty()) {
                try {
                    val formatter = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", java.util.Locale.getDefault())
                    val updateTime = formatter.parse(lastUpdate)
                    val displayFormatter = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
                    val displayTime = displayFormatter.format(updateTime ?: java.util.Date())
                    views.setTextViewText(R.id.widget_last_update, displayTime)
                } catch (e: Exception) {
                    views.setTextViewText(R.id.widget_last_update, "--:--")
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
