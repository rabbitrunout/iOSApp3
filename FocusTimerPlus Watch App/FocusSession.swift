//
//  FocusSession.swift
//  FocusTimerPlus Watch App
//
//  Created by Irina Saf on 2025-10-22.
//

import Foundation

struct FocusSession: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var minutes: Int
    var completed: Bool
}
