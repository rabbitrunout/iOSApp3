import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var store: Store
    @StateObject private var timer = TimerManager()

    @State private var minutes: Double = 5
    @State private var crownValue: Double = 5
    @State private var showCongrats = false
    @State private var glowPulse = false

    private var progress: Double {
        guard timer.totalSeconds > 0 else { return 0 }
        return 1 - Double(timer.remainingSeconds) / Double(timer.totalSeconds)
    }

    var body: some View {
        NavigationStack {        // ✅ теперь работает переход по NavigationLink
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.25)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        // ⚙️ Шестерёнка
                        HStack {
                            Spacer()
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundStyle(.cyan)
                                    .shadow(color: .cyan.opacity(0.7), radius: 4)
                                    .padding(.trailing, 6)
                                    .padding(.top, 6)
                            }
                        }

                        // 🕓 Круг таймера
                        ZStack {
                            Circle().stroke(.white.opacity(0.08), lineWidth: 8)

                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    AngularGradient(gradient: Gradient(colors: [.cyan, .blue, .purple]),
                                                    center: .center),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .shadow(color: .cyan.opacity(0.6), radius: glowPulse ? 14 : 6)
                                .animation(glowPulse ?
                                           .easeInOut(duration: 1.4).repeatForever(autoreverses: true)
                                           : .default,
                                           value: glowPulse)
                                .animation(.easeInOut(duration: 0.3), value: progress)

                            VStack(spacing: 3) {
                                Text(timeString(timer.remainingSeconds))
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .monospacedDigit()
                                    .foregroundColor(.white)
                                    .shadow(color: .cyan.opacity(0.7), radius: 5)

                                Text(labelText)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 110, height: 110)
                        .padding(.top, 8)
                        .focusable(true)
                        .digitalCrownRotation(
                            $crownValue,
                            from: 1, through: 60, by: 1,
                            sensitivity: .medium,
                            isContinuous: false,
                            isHapticFeedbackEnabled: true
                        )
                        .onChange(of: crownValue) { _, newVal in
                            guard timer.state == .idle else { return }
                            minutes = newVal.rounded()
                            timer.configure(minutes: Int(minutes))
                        }

                        // ➕➖ Минуты
                        HStack(spacing: 20) {
                            neonIconButton(systemName: "minus.circle.fill", color: .blue) { adjustMinutes(-1) }
                            Text("\(Int(minutes)) min")
                                .font(.headline)
                                .foregroundColor(.white)
                                .shadow(color: .cyan.opacity(0.6), radius: 5)
                            neonIconButton(systemName: "plus.circle.fill", color: .purple) { adjustMinutes(1) }
                        }

                        // ▶️ Управление
                        HStack(spacing: 8) {
                            switch timer.state {
                            case .idle:
                                neonButton("Start", color: .cyan) { start() }
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
                        .padding(.top, 6)

                        // 📜 История
                        NavigationLink("View History") { HistoryView() }
                            .font(.caption2)
                            .foregroundStyle(.cyan.opacity(0.8))
                            .padding(.top, 4)
                            .padding(.bottom, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                }
                .allowsHitTesting(!showCongrats)

                // 🎉 Экран поздравления
                if showCongrats {
                    ZStack {
                        Color.black.opacity(0.85).ignoresSafeArea()
                        VStack(spacing: 10) {
                            Text("🎉 Well done!")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .shadow(color: .cyan.opacity(0.8), radius: 10)
                            Text("+\(Int(minutes)) min added to History")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
            }
            .task {
                await requestNotificationPermission()
                minutes = 5
                crownValue = 5
                timer.allowHaptics = store.hapticsEnabled
                timer.configure(minutes: 5)
            }
            .onChange(of: timer.state) { _, newState in
                if newState == .finished { WKInterfaceDevice.current().play(.notification) }
            }
        }
    }

    // MARK: - Neon Buttons
    private func neonButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 80, height: 32)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.25))
                    .shadow(color: color.opacity(0.7), radius: 8))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.5), lineWidth: 1))
        }
        .foregroundColor(.white)
    }

    private func neonIconButton(systemName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3)
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.8), radius: 8)
        }
    }

    // MARK: - Logic
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

    private func start() {
        timer.configure(minutes: Int(minutes))
        withAnimation(.spring()) { timer.start() }
    }

    private func reset() { withAnimation(.spring()) { timer.reset() } }

    private func doneSession() {
        store.addSession(minutes: Int(minutes), completed: true)
        let todayMinutes = store.sessions
            .filter { Calendar.current.isDateInToday($0.date) }
            .map(\.minutes)
            .reduce(0, +)
        UserDefaults.standard.set(todayMinutes, forKey: "minutesToday")
        WidgetCenter.shared.reloadAllTimelines()
        WKInterfaceDevice.current().play(.success)
        withAnimation(.easeInOut(duration: 0.4)) {
            showCongrats = true; glowPulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.6)) {
                showCongrats = false; glowPulse = false; timer.reset()
            }
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func requestNotificationPermission() async {
        try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
    }
}

#Preview { ContentView().environmentObject(Store()) }
