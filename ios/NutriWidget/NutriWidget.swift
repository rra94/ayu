import WidgetKit
import SwiftUI

// MARK: - Shared Data

struct NutriData {
    let caloriesConsumed: Int
    let caloriesTarget: Int
    let waterMl: Int
    let waterTarget: Int
    let suppsTaken: Int
    let suppsTotal: Int
    let fastingActive: Bool
    let fastingElapsedMin: Int
    let fastingTargetMin: Int

    var caloriesRemaining: Int { max(0, caloriesTarget - caloriesConsumed) }
    var calorieProgress: Double {
        caloriesTarget > 0 ? Double(caloriesConsumed) / Double(caloriesTarget) : 0
    }
    var waterProgress: Double {
        waterTarget > 0 ? Double(waterMl) / Double(waterTarget) : 0
    }

    static func load() -> NutriData {
        let defaults = UserDefaults(suiteName: "group.com.opennutritracker.ayu")
        return NutriData(
            caloriesConsumed: defaults?.integer(forKey: "calories_consumed") ?? 0,
            caloriesTarget: defaults?.integer(forKey: "calories_target") ?? 2000,
            waterMl: defaults?.integer(forKey: "water_ml") ?? 0,
            waterTarget: defaults?.integer(forKey: "water_target") ?? 2500,
            suppsTaken: defaults?.integer(forKey: "supps_taken") ?? 0,
            suppsTotal: defaults?.integer(forKey: "supps_total") ?? 0,
            fastingActive: defaults?.bool(forKey: "fasting_active") ?? false,
            fastingElapsedMin: defaults?.integer(forKey: "fasting_elapsed_min") ?? 0,
            fastingTargetMin: defaults?.integer(forKey: "fasting_target_min") ?? 960
        )
    }
}

// MARK: - Timeline Provider

struct NutriTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NutriEntry {
        NutriEntry(date: Date(), data: NutriData(
            caloriesConsumed: 1430, caloriesTarget: 2250,
            waterMl: 1500, waterTarget: 2500,
            suppsTaken: 6, suppsTotal: 10,
            fastingActive: false, fastingElapsedMin: 0, fastingTargetMin: 960
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (NutriEntry) -> Void) {
        completion(NutriEntry(date: Date(), data: NutriData.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NutriEntry>) -> Void) {
        let entry = NutriEntry(date: Date(), data: NutriData.load())
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct NutriEntry: TimelineEntry {
    let date: Date
    let data: NutriData
}

// MARK: - Small Widget (Circular Calorie Gauge)

struct NutriWidgetSmall: View {
    let data: NutriData

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 6)
            Circle()
                .trim(from: 0, to: min(data.calorieProgress, 1.0))
                .stroke(
                    data.calorieProgress > 1.0 ? Color.red : Color.green,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(data.caloriesRemaining)")
                    .font(.system(size: 20, weight: .bold))
                    .minimumScaleFactor(0.5)
                Text("kcal left")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
    }
}

// MARK: - Medium Widget (Multi-metric Row)

struct NutriWidgetMedium: View {
    let data: NutriData

    var body: some View {
        HStack(spacing: 16) {
            // Calories
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: min(data.calorieProgress, 1.0))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    Text("\(data.caloriesConsumed)")
                        .font(.system(size: 11, weight: .bold))
                }
                Text("\(data.caloriesTarget) kcal")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            // Water
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: min(data.waterProgress, 1.0))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "drop.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                Text("\(data.waterMl)ml")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            // Supplements
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: data.suppsTotal > 0 ? Double(data.suppsTaken) / Double(data.suppsTotal) : 0)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    Text("\(data.suppsTaken)")
                        .font(.system(size: 14, weight: .bold))
                }
                Text("\(data.suppsTotal) supps")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            // Fasting
            if data.fastingActive {
                VStack(spacing: 4) {
                    let progress = data.fastingTargetMin > 0
                        ? Double(data.fastingElapsedMin) / Double(data.fastingTargetMin) : 0
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            .frame(width: 44, height: 44)
                        Circle()
                            .trim(from: 0, to: min(progress, 1.0))
                            .stroke(Color.purple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))
                        Image(systemName: "timer")
                            .font(.system(size: 14))
                            .foregroundColor(.purple)
                    }
                    Text("\(data.fastingElapsedMin / 60)h")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Widget Configuration

@main
struct NutriWidget: Widget {
    let kind: String = "NutriWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NutriTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                NutriWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NutriWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Ayu Health")
        .description("Track calories, water, supplements, and fasting at a glance.")
        .supportedFamilies([
            .accessoryCircular,
            .systemSmall,
            .systemMedium,
        ])
    }
}

struct NutriWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: NutriEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            NutriWidgetSmall(data: entry.data)
        case .systemSmall:
            NutriWidgetSmall(data: entry.data)
        case .systemMedium:
            NutriWidgetMedium(data: entry.data)
        default:
            NutriWidgetMedium(data: entry.data)
        }
    }
}
