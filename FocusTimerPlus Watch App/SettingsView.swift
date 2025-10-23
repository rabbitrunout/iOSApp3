import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {

                // 🎨 Appearance
                settingCard(icon: "paintpalette.fill", title: "Appearance") {
                    VStack(spacing: 4) {
                        Text("Theme")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Picker("", selection: $store.currentTheme) {
                            Text("System").tag(ColorScheme?.none)
                            Text("Light").tag(ColorScheme?.some(.light))
                            Text("Dark").tag(ColorScheme?.some(.dark))
                        }
                        .pickerStyle(.wheel) // ✅ wheel — оптимально для watchOS
                        .frame(height: 40)
                    }
                }

                // ⏱ Default minutes
                settingCard(icon: "timer", title: "Defaults") {
                    HStack(spacing: 12) {
                        Button(action: {
                            store.defaultMinutes = max(store.defaultMinutes - 1, 1)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.cyan)
                                .font(.title3)
                                .shadow(color: .cyan.opacity(0.8), radius: 4)
                        }

                        Text("\(store.defaultMinutes) min")
                            .font(.footnote.bold())
                            .foregroundColor(.white)

                        Button(action: {
                            store.defaultMinutes = min(store.defaultMinutes + 1, 60)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.purple)
                                .font(.title3)
                                .shadow(color: .purple.opacity(0.8), radius: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }


                // 🔊 Haptics
                settingCard(icon: "waveform", title: "Feedback") {
                    Toggle("Haptics", isOn: $store.hapticsEnabled)
                        .font(.footnote)
                }

                // 🗑 History
                Button(role: .destructive) {
                    store.clearHistory()
                } label: {
                    Label("Clear History", systemImage: "trash.fill")
                        .font(.footnote.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.top, 8)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 12)
        }
        .navigationTitle("Settings")
        .onDisappear { store.save() }
    }

    // MARK: - Reusable Card View
    @ViewBuilder
    private func settingCard<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.footnote.bold())
                .foregroundColor(.cyan)
            content()
        }
        .padding(6)
        .background(.ultraThinMaterial.opacity(0.25))
        .cornerRadius(10)
    }
}

#Preview {
    SettingsView().environmentObject(Store())
}
