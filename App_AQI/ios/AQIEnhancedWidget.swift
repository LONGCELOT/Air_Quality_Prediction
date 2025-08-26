//
//  AQIEnhancedWidget.swift
//  Runner
//
//  Enhanced AQI Widget similar to weather widget style
//

import WidgetKit
import SwiftUI

struct AQIEnhancedWidget: Widget {
    let kind: String = "AQIEnhancedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AQIProvider()) { entry in
            AQIEnhancedWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Air Quality")
        .description("Shows current air quality and 8h, 12h, 24h forecasts")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct AQIEntry: TimelineEntry {
    let date: Date
    let currentAQI: String
    let aqiLevel: String
    let aqiColor: Color
    let location: String
    let aqi8h: String
    let aqi12h: String
    let aqi24h: String
    let aqi8hLevel: String
    let aqi12hLevel: String
    let aqi24hLevel: String
    let aqi8hColor: Color
    let aqi12hColor: Color
    let aqi24hColor: Color
    let pm25: String
    let pm10: String
    let co: String
}

struct AQIProvider: TimelineProvider {
    func placeholder(in context: Context) -> AQIEntry {
        AQIEntry(
            date: Date(),
            currentAQI: "42",
            aqiLevel: "Good",
            aqiColor: .green,
            location: "Brasília, Brazil",
            aqi8h: "45",
            aqi12h: "48",
            aqi24h: "52",
            aqi8hLevel: "Good",
            aqi12hLevel: "Good",
            aqi24hLevel: "Moderate",
            aqi8hColor: .green,
            aqi12hColor: .green,
            aqi24hColor: .yellow,
            pm25: "12.5",
            pm10: "18.2",
            co: "0.8"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AQIEntry) -> ()) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Get data from UserDefaults (shared with Flutter app)
        let sharedUserDefaults = UserDefaults(suiteName: "group.aqi.prediction.app")
        
        let currentAQI = sharedUserDefaults?.string(forKey: "current_aqi") ?? "0"
        let aqiLevel = sharedUserDefaults?.string(forKey: "aqi_level") ?? "Unknown"
        let aqiColorValue = sharedUserDefaults?.string(forKey: "aqi_color") ?? "4294967295"
        let location = sharedUserDefaults?.string(forKey: "location") ?? "Unknown"
        
        // Predictions
        let aqi8h = sharedUserDefaults?.string(forKey: "aqi_8h") ?? "0"
        let aqi12h = sharedUserDefaults?.string(forKey: "aqi_12h") ?? "0"
        let aqi24h = sharedUserDefaults?.string(forKey: "aqi_24h") ?? "0"
        
        let aqi8hLevel = sharedUserDefaults?.string(forKey: "aqi_8h_level") ?? "Unknown"
        let aqi12hLevel = sharedUserDefaults?.string(forKey: "aqi_12h_level") ?? "Unknown"
        let aqi24hLevel = sharedUserDefaults?.string(forKey: "aqi_24h_level") ?? "Unknown"
        
        // Pollutants
        let pm25 = sharedUserDefaults?.string(forKey: "pm25") ?? "0"
        let pm10 = sharedUserDefaults?.string(forKey: "pm10") ?? "0"
        let co = sharedUserDefaults?.string(forKey: "co") ?? "0"
        
        let entry = AQIEntry(
            date: Date(),
            currentAQI: currentAQI,
            aqiLevel: aqiLevel,
            aqiColor: colorFromAQI(Double(currentAQI) ?? 0),
            location: location,
            aqi8h: aqi8h,
            aqi12h: aqi12h,
            aqi24h: aqi24h,
            aqi8hLevel: aqi8hLevel,
            aqi12hLevel: aqi12hLevel,
            aqi24hLevel: aqi24hLevel,
            aqi8hColor: colorFromAQI(Double(aqi8h) ?? 0),
            aqi12hColor: colorFromAQI(Double(aqi12h) ?? 0),
            aqi24hColor: colorFromAQI(Double(aqi24h) ?? 0),
            pm25: pm25,
            pm10: pm10,
            co: co
        )

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    private func colorFromAQI(_ aqi: Double) -> Color {
        if aqi <= 50 { return .green }
        else if aqi <= 100 { return .yellow }
        else if aqi <= 150 { return .orange }
        else if aqi <= 200 { return .red }
        else if aqi <= 300 { return .purple }
        else { return .brown }
    }
}

struct AQIEnhancedWidgetEntryView: View {
    var entry: AQIProvider.Entry

    var body: some View {
        VStack(spacing: 8) {
            // Current AQI Section (Main)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "cloud.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        Text("Current AQI")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    HStack(alignment: .bottom, spacing: 8) {
                        Text(entry.currentAQI)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text(entry.aqiLevel)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
                
                Text(entry.location.replacingOccurrences(of: ", Brazil", with: ""))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        entry.aqiColor,
                        entry.aqiColor.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            
            // Forecast Section
            HStack(spacing: 8) {
                ForecastView(time: "8h", aqi: entry.aqi8h, level: entry.aqi8hLevel, color: entry.aqi8hColor)
                
                Divider()
                    .frame(height: 40)
                
                ForecastView(time: "12h", aqi: entry.aqi12h, level: entry.aqi12hLevel, color: entry.aqi12hColor)
                
                Divider()
                    .frame(height: 40)
                
                ForecastView(time: "24h", aqi: entry.aqi24h, level: entry.aqi24hLevel, color: entry.aqi24hColor)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(8)
        .background(Color.clear) // Transparent background
    }
}

struct ForecastView: View {
    let time: String
    let aqi: String
    let level: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "clock.fill")
                .foregroundColor(.gray)
                .font(.caption)
            
            Text(time)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(aqi)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(level)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

struct PollutantView: View {
    let name: String
    let value: String
    
    var body: some View {
        HStack(spacing: 2) {
            Text(name)
            Text(value)
                .fontWeight(.medium)
        }
    }
}

@main
struct AQIWidgets: WidgetBundle {
    var body: some Widget {
        AQIEnhancedWidget()
    }
}
