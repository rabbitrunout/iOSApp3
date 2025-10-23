import WidgetKit
import SwiftUI
import Charts

// MARK: - Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, minutesToday: 25, history: weekData())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: .now, minutesToday: 40, history: weekData()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Читаем минуты из стандартного UserDefaults (или из App Group, если подключишь)
        let minutes = UserDefaults.standard.integer(forKey: "minutesToday")
        let entry = SimpleEntry(date: .now, minutesToday: minutes, history: weekData())
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    // Фейковые данные для мини-графика за 7 дней
    private func weekData() -> [DailyFocus] {
        let cal = Calendar.current
        return (0..<7).map { off in
            DailyFocus(day: cal.date(byAdding: .day, value: -off, to: .now)!, minutes: Int.random(in: 10...60))
        }.reversed()
    }
}

// MARK: - Models
struct SimpleEntry: TimelineEntry {
    let date: Date
    let minutesToday: Int
    let history: [DailyFocus]
}

struct DailyFocus: Identifiable {
    let id = UUID()
    let day: Date
    let minutes: Int
}

// MARK: - Views

/// Корневое представление, выбирает лейаут по типу виджета
struct RootComplicationView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            RectangularComplicationView(entry: entry)
        case .accessoryCorner, .accessoryCircular, .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge, .accessoryInline:
            CircularComplicationView(entry: entry)
        @unknown default:
            CircularComplicationView(entry: entry)
        }
    }
}

/// Круглый вариант — Gauge
struct CircularComplicationView: View {
    var entry: Provider.Entry

    var body: some View {
        Gauge(value: Double(entry.minutesToday), in: 0...120) {
            Text("Focus").font(.footnote)
        } currentValueLabel: {
            Text("\(entry.minutesToday)m").font(.caption2)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(.blue) // важно: без .gradient (это Color?, а не AnyGradient)
    }
}

/// Прямоугольный вариант — мини-график недели
struct RectangularComplicationView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Weekly Focus")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Chart(entry.history) { d in
                BarMark(
                    x: .value("Day", d.day, unit: .day),
                    y: .value("Minutes", d.minutes)
                )
                .foregroundStyle(.blue)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 26)

            HStack(spacing: 4) {
                Image(systemName: "clock").font(.caption2)
                Text("\(entry.minutesToday) min today")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 2)
    }
}

// MARK: - Widget
@main
struct FocusTimerPlusComplication: Widget {
    let kind = "FocusTimerPlusComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RootComplicationView(entry: entry)
        }
        .configurationDisplayName("Focus Minutes")
        .description("Shows today’s focus and weekly progress.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular])
    }
}
