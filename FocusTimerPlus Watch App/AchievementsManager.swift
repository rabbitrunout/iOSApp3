import Foundation
import SwiftUI
import Combine   // ← обязательно!

final class AchievementsManager: ObservableObject {
    @Published var streakDays: Int = 0
    @Published var totalMinutes: Int = 0
    @Published var achievements: [String] = []

    private let streakKey = "focus.streak"
    private let totalKey = "focus.totalMinutes"
    private let lastDayKey = "focus.lastDay"

    init() {
        streakDays = UserDefaults.standard.integer(forKey: streakKey)
        totalMinutes = UserDefaults.standard.integer(forKey: totalKey)
    }

    func registerSession(minutes: Int) -> [String] {
        var newAchievements: [String] = []
        let now = Date()
        let lastDate = UserDefaults.standard.object(forKey: lastDayKey) as? Date

        // streak logic
        if let last = lastDate {
            if Calendar.current.isDateInYesterday(last) {
                streakDays += 1
            } else if !Calendar.current.isDateInToday(last) {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        // total minutes
        totalMinutes += minutes

        UserDefaults.standard.set(now, forKey: lastDayKey)
        UserDefaults.standard.set(streakDays, forKey: streakKey)
        UserDefaults.standard.set(totalMinutes, forKey: totalKey)

        // achievements
        if streakDays == 3 { newAchievements.append("🔥 3-Day Streak!") }
        if streakDays == 7 { newAchievements.append("🏆 1-Week Streak!") }
        if totalMinutes >= 100 && totalMinutes - minutes < 100 { newAchievements.append("💯 100 Minutes Focused!") }
        if totalMinutes >= 500 && totalMinutes - minutes < 500 { newAchievements.append("🌟 500 Minutes Master!") }

        achievements.append(contentsOf: newAchievements)
        return newAchievements
    }
}
