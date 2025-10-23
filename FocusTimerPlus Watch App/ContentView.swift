import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var store: Store
    @StateObject private var timer = TimerManager()
    @StateObject private var achievements = AchievementsManager()

    @State private var minutes: Double = 5
    @State private var category: FocusCategory = .work
    @State private var crownValue: Double = 5
    @State private var showCongrats = false
    @State private var achievedTitles: [String] = []

    private var progress: Double {
        guard timer.totalSeconds > 0 else { return 0 }
        return 1 - Double(timer.remainingSeconds) / Double(timer.totalSeconds)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 🌈 Фон
                LinearGradient(
                    colors: store.currentTheme == .dark
                        ? [category.colorGradient.last!.opacity(0.3), .black]
                        : [category.colorGradient.first!.opacity(0.15), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // 🔽 Весь контент в ScrollView, чтобы не обрезался
                ScrollView {
                    VStack(spacing: 10) {

                        // 🔹 Верхняя панель
                        HStack {
                            NavigationLink(destination: CategoryPickerView(selectedCategory: $category)) {
                                Text(category.icon)
                                    .font(.title2)
                                    .padding(6)
                                    .background(
                                        Circle()
                                            .fill(category.colorGradient.first!.opacity(0.2))
                                            .shadow(color: category.colorGradient.first!.opacity(0.5), radius: 2)
                                    )
                            }

                            Spacer()

                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(category.colorGradient.first!)
                                    .shadow(color: category.colorGradient.last!.opacity(0.6), radius: 3)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 8)

                        // 🕓 Таймер
                        ZStack {
                            Circle()
                                .stroke(.white.opacity(0.08), lineWidth: 8)
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: category.colorGradient),
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .shadow(color: category.colorGradient.first!.opacity(0.6), radius: 8)
                                .animation(.easeInOut(duration: 0.3), value: progress)

                            VStack(spacing: 3) {
                                Text(timeString(timer.remainingSeconds))
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(store.currentTheme == .dark ? .white : .black)
                                Text(labelText)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 120, height: 120)
                        .focusable(true)
                        .digitalCrownRotation($crownValue, from: 1, through: 60, by: 1, sensitivity: .medium)
                        .onChange(of: crownValue) { _, newVal in
                            guard timer.state == .idle else { return }
                            minutes = newVal.rounded()
                            timer.configure(minutes: Int(minutes))
                        }

                        // ➕➖
                        HStack(spacing: 20) {
                            neonIconButton(systemName: "minus.circle.fill", color: category.colorGradient.first!) {
                                adjustMinutes(-1)
                            }
                            Text("\(Int(minutes)) min")
                                .font(.headline)
                                .foregroundColor(store.currentTheme == .dark ? .white : .black)
                            neonIconButton(systemName: "plus.circle.fill", color: category.colorGradient.last!) {
                                adjustMinutes(1)
                            }
                        }

                        // ▶️ Кнопки
                        HStack(spacing: 8) {
                            switch timer.state {
                            case .idle:
                                neonButton("Start", color: category.colorGradient.first!) { start() }
                            case .running:
                                neonButton("Pause", color: .orange) { timer.pause() }
                                neonButton("Reset", color: .red) { reset() }
                            case .paused:
                                neonButton("Resume", color: .green) { timer.resume() }
                                neonButton("Reset", color: .red) { reset() }
                            case .finished:
                                neonButton("✔ Done", color: .green) { doneSession() }
                            }
                        }
                        .padding(.top, 4)

                        // 📜 История
                        NavigationLink("History") { HistoryView() }
                            .font(.caption2)
                            .foregroundStyle(category.colorGradient.first!.opacity(0.8))
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 8)
                }

                // 🎉 Поздравление
                if showCongrats {
                    ZStack {
                        Color.black.opacity(0.85).ignoresSafeArea()
                        VStack(spacing: 10) {
                            Text("🎉 Great job!")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            ForEach(achievedTitles, id: \.self) { title in
                                Text(title)
                                    .font(.footnote)
                                    .foregroundColor(.cyan)
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }

    // MARK: - UI
    private func neonButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 75, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.25))
                        .shadow(color: color.opacity(0.6), radius: 3)
                )
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.5), lineWidth: 1))
        }
        .foregroundColor(.white)
    }

    private func neonIconButton(systemName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.7), radius: 2)
        }
    }

    // MARK: - Логика
    private func adjustMinutes(_ delta: Int) {
        guard timer.state == .idle else { return }
        minutes = min(max(minutes + Double(delta), 1), 60)
        crownValue = minutes
        timer.configure(minutes: Int(minutes))
    }

    private var labelText: String {
        switch timer.state {
        case .idle: "Ready"
        case .running: "Focusing…"
        case .paused: "Paused"
        case .finished: "Done"
        }
    }

    private func start() { timer.configure(minutes: Int(minutes)); timer.start() }
    private func reset() { timer.reset() }

    private func doneSession() {
        store.addSession(minutes: Int(minutes), completed: true, category: category)
        let newAchievements = achievements.registerSession(minutes: Int(minutes))
        achievedTitles = newAchievements
        withAnimation(.easeInOut(duration: 0.4)) { showCongrats = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showCongrats = false }
            timer.reset()
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview { ContentView().environmentObject(Store()) }
