import Foundation
import SwiftUI
import Combine

final class Store: ObservableObject {
    // MARK: - App Settings
    @Published var defaultMinutes: Int = UserDefaults.standard.integer(forKey: "defaultMinutes") == 0
        ? 5 : UserDefaults.standard.integer(forKey: "defaultMinutes")

    @Published var hapticsEnabled: Bool = UserDefaults.standard.bool(forKey: "hapticsEnabled")

    @Published var currentTheme: ColorScheme? = nil {
        didSet {
            if let theme = currentTheme {
                UserDefaults.standard.set(theme == .dark ? "dark" : "light", forKey: "theme")
            } else {
                UserDefaults.standard.set("system", forKey: "theme")
            }
        }
    }

    // MARK: - Focus Sessions
    @Published var sessions: [Session] = []

    struct Session: Identifiable, Codable, Equatable {
        let id = UUID()
        let date: Date
        let minutes: Int
        let completed: Bool
        let category: FocusCategory
    }

    init() {
        load()
        let savedTheme = UserDefaults.standard.string(forKey: "theme")
        switch savedTheme {
        case "dark": currentTheme = .dark
        case "light": currentTheme = .light
        default: currentTheme = nil
        }
    }

    // MARK: - Save / Load
    func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: "sessions")
        }
        UserDefaults.standard.set(defaultMinutes, forKey: "defaultMinutes")
        UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled")
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "sessions"),
           let decoded = try? JSONDecoder().decode([Session].self, from: data) {
            sessions = decoded
        }
    }

    func addSession(minutes: Int, completed: Bool, category: FocusCategory) {
        let new = Session(date: Date(), minutes: minutes, completed: completed, category: category)
        sessions.append(new)
        save()
    }

    func clearHistory() {
        sessions.removeAll()
        save()
    }
}
