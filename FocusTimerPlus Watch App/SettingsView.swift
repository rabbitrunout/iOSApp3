import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        ZStack {
            // 🌈 Динамический фон
            LinearGradient(
                colors: store.currentTheme == .dark
                    ? [Color.black, Color(red: 0.1, green: 0.0, blue: 0.25)]
                    : [Color(red: 0.85, green: 0.95, blue: 1.0), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: store.currentTheme)

            ScrollView {
                VStack(spacing: 18) {
                    Text("⚙ Settings")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .shadow(color: glowColor.opacity(0.6), radius: 8)

                    // 🎨 Theme Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Theme")
                            .font(.caption)
                            .foregroundColor(textColor.opacity(0.7))

                        Picker("Theme", selection: $store.themeRaw.animation(.easeInOut(duration: 0.4))) {
                            ForEach(Store.Theme.allCases) { t in
                                Text(t.rawValue)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .background(.ultraThinMaterial.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: glowColor.opacity(0.4), radius: 4)
                    }

                    // ⏱ Default Duration
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Default Duration")
                            .font(.caption)
                            .foregroundColor(textColor.opacity(0.7))

                        Stepper(value: $store.defaultMinutes, in: 5...60, step: 5) {
                            Text("\(store.defaultMinutes) min")
                                .font(.headline)
                                .foregroundColor(textColor)
                        }
                        .padding(6)
                        .background(.ultraThinMaterial.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: glowColor.opacity(0.5), radius: 4)
                    }

                    // 🔊 Haptics
                    Toggle(isOn: $store.hapticsEnabled) {
                        Text("Haptics")
                            .foregroundColor(textColor)
                    }
                    .tint(glowColor)
                    .padding(6)
                    .background(.ultraThinMaterial.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: glowColor.opacity(0.4), radius: 4)

                    // 🗑 Clear History
                    Button(role: .destructive) {
                        store.clearHistory()
                    } label: {
                        Label("Clear History", systemImage: "trash.fill")
                            .font(.callout.bold())
                            .foregroundColor(textColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red.opacity(0.25))
                            )
                            .shadow(color: .red.opacity(0.5), radius: 6)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
        }
    }

    private var textColor: Color {
        store.currentTheme == .dark ? .white : .black
    }

    private var glowColor: Color {
        store.currentTheme == .dark ? .cyan : .blue
    }
}

#Preview {
    SettingsView().environmentObject(Store())
}
