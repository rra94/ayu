import WidgetKit
import SwiftUI

// MARK: - Brand colours
private extension Color {
    /// Ayu navy background #0D1B2A
    static let ayuNavy = Color(red: 0.051, green: 0.106, blue: 0.165)
    /// Ayu gold accent #D4A843
    static let ayuGold = Color(red: 0.831, green: 0.659, blue: 0.263)
}

// MARK: - Shared Data

struct NutriData {
    let caloriesConsumed: Int
    let caloriesTarget: Int
    let waterMl: Int
    let waterTarget: Int
    let waterPct: Int          // 0-100 pre-computed
    let suppsTaken: Int
    let suppsTotal: Int
    let fastingActive: Bool
    let fastingElapsedMin: Int
    let fastingTargetMin: Int
    let streak: Int            // consecutive clean-eating days

    var caloriesRemaining: Int { max(0, caloriesTarget - caloriesConsumed) }
    var calorieProgress: Double {
        caloriesTarget > 0 ? Double(caloriesConsumed) / Double(caloriesTarget) : 0
    }
    var waterProgress: Double {
        waterTarget > 0 ? Double(waterMl) / Double(waterTarget) : 0
    }

    static func load() -> NutriData {
        let d = UserDefaults(suiteName: "group.com.opennutritracker.ayu")
        return NutriData(
            caloriesConsumed: d?.integer(forKey: "calories_consumed") ?? 0,
            caloriesTarget:   d?.integer(forKey: "calories_target")   ?? 2000,
            waterMl:          d?.integer(forKey: "water_ml")          ?? 0,
            waterTarget:      d?.integer(forKey: "water_target")      ?? 2500,
            waterPct:         d?.integer(forKey: "water_pct")         ?? 0,
            suppsTaken:       d?.integer(forKey: "supps_taken")       ?? 0,
            suppsTotal:       d?.integer(forKey: "supps_total")       ?? 0,
            fastingActive:    d?.bool(forKey:    "fasting_active")    ?? false,
            fastingElapsedMin: d?.integer(forKey: "fasting_elapsed_min") ?? 0,
            fastingTargetMin:  d?.integer(forKey: "fasting_target_min")  ?? 960,
            streak:           d?.integer(forKey: "streak")            ?? 0
        )
    }

    // Placeholder data for Xcode previews / widget gallery
    static let preview = NutriData(
        caloriesConsumed: 1430, caloriesTarget: 2250,
        waterMl: 1600, waterTarget: 2500, waterPct: 64,
        suppsTaken: 6, suppsTotal: 10,
        fastingActive: false, fastingElapsedMin: 0, fastingTargetMin: 960,
        streak: 7
    )
}

// MARK: - Timeline

struct NutriTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NutriEntry {
        NutriEntry(date: Date(), data: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (NutriEntry) -> Void) {
        completion(NutriEntry(date: Date(), data: context.isPreview ? .preview : NutriData.load()))
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

// MARK: - Circular progress ring (reusable)

private struct RingView: View {
    let progress: Double   // 0.0 – 1.0+
    let lineWidth: CGFloat
    let ringColor: Color
    let overColor: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    progress > 1.0 ? overColor : ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Small Widget  (accessoryCircular + systemSmall)
// systemSmall: navy bg + gold calorie ring + kcal remaining + streak badge
// accessoryCircular: minimal ring for Lock Screen

struct NutriWidgetSmall: View {
    let data: NutriData
    @Environment(\.widgetFamily) var family

    var body: some View {
        #if os(iOS)
        if #available(iOSApplicationExtension 16.0, *), family == .accessoryCircular {
            lockScreenCircular
        } else {
            homeScreenSmall
        }
        #else
        homeScreenSmall
        #endif
    }

    /// Lock Screen circular accessory — monochrome ring
    private var lockScreenCircular: some View {
        ZStack {
            RingView(
                progress: data.calorieProgress,
                lineWidth: 5,
                ringColor: .white,
                overColor: .red
            )
            VStack(spacing: 1) {
                Text("\(data.caloriesRemaining)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                Text("kcal")
                    .font(.system(size: 7))
                    .foregroundColor(.secondary)
            }
        }
    }

    /// Home Screen small — navy background
    private var homeScreenSmall: some View {
        ZStack {
            Color.ayuNavy

            VStack(spacing: 6) {
                // Calorie ring
                ZStack {
                    RingView(
                        progress: data.calorieProgress,
                        lineWidth: 7,
                        ringColor: .ayuGold,
                        overColor: Color(red: 0.9, green: 0.2, blue: 0.2)
                    )
                    .frame(width: 68, height: 68)

                    VStack(spacing: 1) {
                        Text("\(data.caloriesRemaining)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                        Text("kcal left")
                            .font(.system(size: 7))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }

                // Streak badge
                if data.streak > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.ayuGold)
                        Text("\(data.streak)d")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.ayuGold)
                    }
                }
            }
            .padding(10)
        }
    }
}

// MARK: - Medium Widget  (systemMedium)
// Navy bg | calorie ring | water bar | supps X/Y | streak

struct NutriWidgetMedium: View {
    let data: NutriData

    var body: some View {
        ZStack {
            Color.ayuNavy

            HStack(spacing: 14) {
                // Left: large calorie ring
                ZStack {
                    RingView(
                        progress: data.calorieProgress,
                        lineWidth: 8,
                        ringColor: .ayuGold,
                        overColor: Color(red: 0.9, green: 0.2, blue: 0.2)
                    )
                    .frame(width: 80, height: 80)

                    VStack(spacing: 2) {
                        Text("\(data.caloriesConsumed)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                        Text("/ \(data.caloriesTarget)")
                            .font(.system(size: 8))
                            .foregroundColor(Color.white.opacity(0.55))
                        Text("kcal")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.ayuGold)
                    }
                }

                // Right: stacked metrics
                VStack(alignment: .leading, spacing: 8) {
                    // Water
                    metricRow(
                        icon: "drop.fill",
                        iconColor: Color(red: 0.3, green: 0.6, blue: 1.0),
                        label: "Water",
                        value: "\(data.waterPct)%",
                        progress: data.waterProgress
                    )

                    // Supplements
                    if data.suppsTotal > 0 {
                        metricRow(
                            icon: "pill.fill",
                            iconColor: Color(red: 0.6, green: 0.85, blue: 0.6),
                            label: "Supps",
                            value: "\(data.suppsTaken)/\(data.suppsTotal)",
                            progress: data.suppsTotal > 0
                                ? Double(data.suppsTaken) / Double(data.suppsTotal)
                                : 0
                        )
                    }

                    // Streak
                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.ayuGold)
                        Text(data.streak > 0 ? "\(data.streak)-day streak" : "Start your streak")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.85))
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }

    @ViewBuilder
    private func metricRow(
        icon: String,
        iconColor: Color,
        label: String,
        value: String,
        progress: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundColor(iconColor)
                Text(label)
                    .font(.system(size: 9))
                    .foregroundColor(Color.white.opacity(0.6))
                Spacer()
                Text(value)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                    Capsule()
                        .fill(iconColor)
                        .frame(width: geo.size.width * min(progress, 1.0), height: 4)
                }
            }
            .frame(height: 4)
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
                    .containerBackground(Color.ayuNavy, for: .widget)
            } else {
                NutriWidgetEntryView(entry: entry)
                    .background(Color.ayuNavy)
            }
        }
        .configurationDisplayName("Ayu Health")
        .description("Track calories, water, supplements, and streak at a glance.")
        .supportedFamilies({
            #if os(iOS)
            if #available(iOSApplicationExtension 16.0, *) {
                return [.accessoryCircular, .systemSmall, .systemMedium]
            }
            #endif
            return [.systemSmall, .systemMedium]
        }())
    }
}
