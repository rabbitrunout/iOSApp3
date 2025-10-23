import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if store.sessions.isEmpty {
                    Text("No sessions yet")
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                } else {
                    // 📊 Тренд по дням
                    Chart(store.sessions.sorted(by: { $0.date < $1.date })) { s in
                        BarMark(
                            x: .value("Date", s.date, unit: .day),
                            y: .value("Minutes", s.minutes)
                        )
                        .foregroundStyle(LinearGradient(
                            colors: s.category.colorGradient,
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    }
                    .frame(height: 110)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 6)

                    // 📜 Список сессий
                    VStack(spacing: 6) {
                        ForEach(store.sessions.sorted(by: { $0.date > $1.date })) { s in
                            HStack {
                                Text(s.category.icon)
                                    .font(.title3)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(s.category.rawValue)")
                                        .font(.caption.bold())
                                    Text(s.date, style: .time)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(s.minutes) min")
                                    .font(.caption.bold())
                                    .foregroundStyle(s.category.colorGradient.first!)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(s.category.colorGradient.first!.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 12)

                    // 📅 Weekly Summary
                    WeeklySummaryView(sessions: store.sessions)
                        .padding(.top, 6)
                }
            }
            .navigationTitle("History")
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    HistoryView().environmentObject(Store())
}

// MARK: - Weekly Summary View

struct WeeklySummaryView: View {
    let sessions: [Store.Session]

    private var lastWeekSessions: [Store.Session] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return sessions.filter { $0.date >= weekAgo }
    }

    private var totalMinutes: Int {
        lastWeekSessions.map(\.minutes).reduce(0, +)
    }

    private var groupedByCategory: [(FocusCategory, Int)] {
        FocusCategory.allCases.map { cat in
            let minutes = lastWeekSessions
                .filter { $0.category == cat }
                .map(\.minutes)
                .reduce(0, +)
            return (cat, minutes)
        }.filter { $0.1 > 0 }
    }

    var body: some View {
        VStack(spacing: 10) {
            Text("🗓 Weekly Summary")
                .font(.headline)
                .foregroundStyle(.primary)

            if groupedByCategory.isEmpty {
                Text("No sessions in the last 7 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                // Кольцевая диаграмма
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    ForEach(Array(groupedByCategory.enumerated()), id: \.offset) { i, entry in
                        let startAngle = startAngle(for: i)
                        let endAngle = endAngle(for: i)
                        Circle()
                            .trim(from: startAngle, to: endAngle)
                            .stroke(
                                AngularGradient(gradient: Gradient(colors: entry.0.colorGradient),
                                                center: .center),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                    }
                    Text("\(totalMinutes) min")
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                }
                .frame(width: 80, height: 80)

                // Легенда
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(groupedByCategory, id: \.0) { cat, minutes in
                        let percent = Double(minutes) / Double(max(totalMinutes, 1)) * 100
                        HStack {
                            Text(cat.icon)
                            Text("\(cat.rawValue)")
                                .font(.caption2)
                            Spacer()
                            Text("\(Int(percent))%")
                                .font(.caption2.bold())
                                .foregroundStyle(cat.colorGradient.first!)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .shadow(radius: 3)
        )
        .padding(.horizontal, 8)
    }

    // MARK: - Angle helpers
    private func startAngle(for index: Int) -> CGFloat {
        let total = groupedByCategory.map(\.1).reduce(0, +)
        guard total > 0 else { return 0 }
        let sumBefore = groupedByCategory.prefix(index).map(\.1).reduce(0, +)
        return CGFloat(sumBefore) / CGFloat(total)
    }

    private func endAngle(for index: Int) -> CGFloat {
        let total = groupedByCategory.map(\.1).reduce(0, +)
        guard total > 0 else { return 0 }
        let sumBefore = groupedByCategory.prefix(index + 1).map(\.1).reduce(0, +)
        return CGFloat(sumBefore) / CGFloat(total)
    }
}


#Preview {
    HistoryView().environmentObject(Store())
}
