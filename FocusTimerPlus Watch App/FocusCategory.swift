import SwiftUI

enum FocusCategory: String, CaseIterable, Identifiable, Codable {
    case work = "Work"
    case study = "Study"
    case meditation = "Meditation"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .work: return "💻"
        case .study: return "📚"
        case .meditation: return "🧘"
        }
    }

    var description: String {
        switch self {
        case .work: return "Concentrate on your projects and tasks"
        case .study: return "Focus on learning and reading"
        case .meditation: return "Relax, breathe, and clear your thoughts"
        }
    }

    var colorGradient: [Color] {
        switch self {
        case .work: return [.cyan, .blue]
        case .study: return [.purple, .pink]
        case .meditation: return [.green, .mint]
        }
    }
}
