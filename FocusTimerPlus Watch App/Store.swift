//
//  Store.swift
//  FocusTimerPlus Watch App
//
//  Created by Irina Saf on 2025-10-22.
//

import Foundation
import SwiftUI
import Combine

final class Store: ObservableObject {
    // MARK: - Persistent Settings
    @AppStorage("theme") var themeRaw: String = Theme.automatic.rawValue
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("defaultMinutes") var defaultMinutes: Int = 5

    // MARK: - Session History
    @Published var sessions: [Session] = []

    struct Session: Identifiable, Codable, Equatable {
        let id: UUID
        let minutes: Int
        let date: Date
        let completed: Bool

        init(id: UUID = UUID(), minutes: Int, date: Date = .now, completed: Bool) {
            self.id = id
            self.minutes = minutes
            self.date = date
            self.completed = completed
        }
    }

    // MARK: - Theme Enum
    enum Theme: String, CaseIterable, Identifiable {
        case automatic = "Automatic"
        case light = "Light"
        case dark = "Dark"
        var id: String { rawValue }
    }

    var theme: Theme {
        get { Theme(rawValue: themeRaw) ?? .automatic }
        set { themeRaw = newValue.rawValue }
    }

    // MARK: - Session Management
    func addSession(minutes: Int, completed: Bool) {
        sessions.append(Session(minutes: minutes, completed: completed))
        save()
    }

    func clearHistory() {
        sessions.removeAll()
        save()
    }

    func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: "sessions")
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "sessions"),
           let decoded = try? JSONDecoder().decode([Session].self, from: data) {
            sessions = decoded
        }
    }

    init() {
        load()
    }
}
