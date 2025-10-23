//
//  HistoryView.swift
//  FocusTimerPlus Watch App
//
//  Created by Irina Saf on 2025-10-22.
//

import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var store: Store
    @State private var animateBars = false

    private var weeklyTotal: Int {
        store.sessions
            .filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear) }
            .map(\.minutes)
            .reduce(0, +)
    }

    private var avgSession: Int {
        guard !store.sessions.isEmpty else { return 0 }
        return store.sessions.map(\.minutes).reduce(0, +) / store.sessions.count
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: store.currentTheme == .dark
                    ? [Color.black, Color(red: 0.05, green: 0.05, blue: 0.25)]
                    : [Color(red: 0.95, green: 0.97, blue: 1.0), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    // 📊 Заголовок
                    Text("Weekly Summary")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(store.currentTheme == .dark ? .white : .black)

                    // 💡 Статистика недели
                    HStack {
                        VStack(alignment: .leading) {
                            Text("This Week")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(weeklyTotal) min")
                                .font(.headline.bold())
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Average Session")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(avgSession) min")
                                .font(.headline.bold())
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial.opacity(0.2))
                    .cornerRadius(10)

                    // 📈 График по категориям
                    if !store.sessions.isEmpty {
                        Chart {
                            ForEach(store.sessions.sorted(by: { $0.date < $1.date })) { s in
                                BarMark(
                                    x: .value("Date", s.date, unit: .day),
                                    y: .value("Minutes", animateBars ? s.minutes : 0)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: s.category.colorGradient,
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(3)
                            }
                        }
                        .frame(height: 130)
                        .onAppear { withAnimation(.easeOut(duration: 1)) { animateBars = true } }
                    }

                    // 📜 Список сессий
                    if !store.sessions.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(store.sessions.sorted(by: { $0.date > $1.date })) { s in
                                HStack {
                                    Text(s.category.icon)
                                        .font(.title3)
                                        .shadow(color: s.category.colorGradient.first!.opacity(0.6), radius: 5)
                                    VStack(alignment: .leading) {
                                        Text(s.date, style: .date)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("\(s.minutes) min • \(s.category.rawValue)")
                                            .font(.footnote)
                                            .foregroundStyle(s.category.colorGradient.first!)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(s.category.colorGradient.first!.opacity(store.currentTheme == .dark ? 0.1 : 0.15))
                                )
                            }
                        }
                        .padding(.top, 8)
                    } else {
                        Text("No sessions yet")
                            .foregroundStyle(.secondary)
                            .padding(.top, 20)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    HistoryView().environmentObject(Store())
}
