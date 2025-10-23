//
//  SettingsView.swift
//  FocusTimerPlus Watch App
//
//  Created by Irina Saf on 2025-10-22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.0, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    Text("⚙ Settings")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .cyan.opacity(0.6), radius: 8)

                    // 🎨 Theme
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Theme")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))

                        Picker("Theme", selection: $store.themeRaw) {
                            ForEach(Store.Theme.allCases) { t in
                                Text(t.rawValue)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .background(.ultraThinMaterial.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .cyan.opacity(0.5), radius: 4)
                    }

                    // ⏱ Default minutes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Default Duration")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))

                        Stepper(value: $store.defaultMinutes, in: 5...60, step: 5) {
                            Text("\(store.defaultMinutes) min")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(6)
                        .background(.ultraThinMaterial.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .purple.opacity(0.5), radius: 4)
                    }

                    // 🔊 Haptics
                    Toggle(isOn: $store.hapticsEnabled) {
                        Text("Haptics")
                            .foregroundColor(.white)
                    }
                    .tint(.cyan)
                    .padding(6)
                    .background(.ultraThinMaterial.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .cyan.opacity(0.4), radius: 4)

                    // 🗑 Clear History
                    Button(role: .destructive) {
                        store.clearHistory()
                    } label: {
                        Label("Clear History", systemImage: "trash.fill")
                            .font(.callout.bold())
                            .foregroundStyle(.white)
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
        .preferredColorScheme(
            store.theme == .dark ? .dark :
            store.theme == .light ? .light : nil
        )
    }
}

#Preview {
    SettingsView().environmentObject(Store())
}
