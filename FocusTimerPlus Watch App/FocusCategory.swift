import SwiftUI

enum FocusCategory: String, CaseIterable, Identifiable, Codable {
    case work = "💻 Work"
    case study = "📚 Study"
    case meditation = "🧘 Meditation"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .work: return ""
        case .study: return ""
        case .meditation: return ""
        }
    }

    var colorGradient: [Color] {
        switch self {
        case .work: return [.cyan, .blue]
        case .study: return [.purple, .pink]
        case .meditation: return [.mint, .teal]
        }
    }
}
