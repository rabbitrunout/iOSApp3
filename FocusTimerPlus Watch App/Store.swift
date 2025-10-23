import Foundation
import SwiftUI
import Combine

final class Store: ObservableObject {
    // MARK: - App Settings
    @AppStorage("theme") private var themeRawValue: String = Theme.automatic.rawValue {
        didSet { updateTheme() }
    }

    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("defaultMinutes") var defaultMinutes: Int = 5

    @Published var currentTheme: Theme = .automatic

    private func updateTheme() {
        currentTheme = Theme(rawValue: themeRawValue) ?? .automatic
        WKInterfaceDevice.current().play(.click) // тактильный отклик при смене темы
    }

    // MARK: - Sessions
    @Published var sessions: [Session] = []

    struct Session: Identifiable, Codable {
        let id: UUID
        let date: Date
        let minutes: Int
        let completed: Bool
        let category: FocusCategory

        init(minutes: Int, completed: Bool, category: FocusCategory) {
            self.id = UUID()
            self.date = Date()
            self.minutes = minutes
            self.completed = completed
            self.category = category
        }
    }


    enum Theme: String, CaseIterable, Identifiable {
        case automatic = "Automatic"
        case light = "Light"
        case dark = "Dark"
        var id: String { rawValue }
    }

    func addSession(minutes: Int, completed: Bool, category: FocusCategory) {
        let new = Session(minutes: minutes, completed: completed, category: category)
        sessions.append(new)
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
        updateTheme()
    }

    // MARK: - Theme Picker Binding
    var themeRaw: String {
        get { themeRawValue }
        set {
            themeRawValue = newValue
            updateTheme()
        }
    }
}
