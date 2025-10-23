//
//  FocusTimerPlusApp.swift
//  FocusTimerPlus Watch App
//
//  Created by Irina Saf on 2025-10-22.
//

import SwiftUI

@main
struct FocusTimerPlusApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

