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

    var body: some View {
        ZStack {
            // 🌌 Неоновый фон
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0.0, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // 🔷 Заголовок
                    Text("History")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .cyan.opacity(0.7), radius: 8)
                        .padding(.bottom, 4)

                    if store.sessions.isEmpty {
                        Text("No sessions yet")
                            .foregroundStyle(.secondary)
                            .padding(.top, 20)
                    } else {
                        // 📊 Диаграмма с плавным появлением
                        Chart(store.sessions) { s in
                            BarMark(
                                x: .value("Date", s.date, unit: .day),
                                y: .value("Minutes", animateBars ? s.minutes : 0)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .purple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(4)
                            .shadow(color: .cyan.opacity(0.4), radius: 3, y: 1)
                        }
                        .frame(height: 80)
                        .padding(.bottom, 8)
                        .chartYAxis(.hidden)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { _ in
                                AxisValueLabel(format: .dateTime.day().weekday(), centered: true)
                            }
                        }
                        .onAppear {
                            // 🚀 Анимация появления столбиков
                            withAnimation(.easeOut(duration: 0.9)) {
                                animateBars = true
                            }
                        }

                        // 📅 Список сессий
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(store.sessions.sorted(by: { $0.date > $1.date })) { s in
                                HStack {
                                    Text(s.date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.8))
                                    Spacer()
                                    Text("\(s.minutes) min")
                                        .font(.caption2.bold())
                                        .foregroundStyle(s.completed ? .green : .secondary)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }

                        // 🧮 Итого за сегодня
                        let todayTotal = store.sessions
                            .filter { Calendar.current.isDateInToday($0.date) }
                            .map(\.minutes)
                            .reduce(0, +)

                        if todayTotal > 0 {
                            Text("Total today: \(todayTotal) min")
                                .font(.caption2.bold())
                                .foregroundStyle(.cyan)
                                .padding(.top, 6)
                        }

                        // 🗑 Кнопка очистки
                        Button(role: .destructive) {
                            store.clearHistory()
                        } label: {
                            Label("Clear History", systemImage: "trash.fill")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.25))
                                )
                                .shadow(color: .red.opacity(0.5), radius: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
            }
        }
        .preferredColorScheme(
            store.theme == .dark ? .dark :
            store.theme == .light ? .light : nil
        )
    }
}

#Preview {
    HistoryView().environmentObject(Store())
}
