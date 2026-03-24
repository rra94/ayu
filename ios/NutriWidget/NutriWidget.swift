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

// MARK: - Timeline

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
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct NutriEntry: TimelineEntry {
    let date: Date
    let data: NutriData
}

// MARK: - Small Widget (Calorie Gauge)

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

// MARK: - Medium Widget (Multi-metric)

struct NutriWidgetMedium: View {
    let data: NutriData

    var body: some View {
        HStack(spacing: 16) {
            metricGauge(
                value: data.caloriesConsumed,
                total: data.caloriesTarget,
                label: "kcal",
                color: .green
            )
            metricGauge(
                value: data.waterMl,
                total: data.waterTarget,
                label: "ml",
                color: .blue
            )
            if data.suppsTotal > 0 {
                metricGauge(
                    value: data.suppsTaken,
                    total: data.suppsTotal,
                    label: "supps",
                    color: .orange
                )
            }
            if data.fastingActive {
                metricGauge(
                    value: data.fastingElapsedMin / 60,
                    total: data.fastingTargetMin / 60,
                    label: "fast h",
                    color: .purple
                )
            }
        }
        .padding(.horizontal, 8)
    }

    func metricGauge(value: Int, total: Int, label: String, color: Color) -> some View {
        let progress = total > 0 ? Double(value) / Double(total) : 0
        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .frame(width: 44, height: 44)
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                Text("\(value)")
                    .font(.system(size: 11, weight: .bold))
            }
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Widget Entry View

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

// MARK: - Widget Config

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
