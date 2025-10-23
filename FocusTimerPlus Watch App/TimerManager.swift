//
//  TimerManager.swift
//  FocusTimerPlus Watch App
//
//  Created by Irina Saf on 2025-10-22.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import WatchKit

final class TimerManager: ObservableObject {
    enum State { case idle, running, paused, finished }

    @Published var state: State = .idle
    @Published var totalSeconds: Int = 5 * 60
    @Published var remainingSeconds: Int = 5 * 60

    @Published var allowHaptics: Bool = true

    private var ticker: AnyCancellable?
    private var startDate: Date?

    func configure(minutes: Int) {
        totalSeconds = max(60, minutes * 60)
        remainingSeconds = totalSeconds
        state = .idle
    }

    func start() {
        guard state != .running else { return }
        startDate = Date()
        state = .running
        playHaptic(.start)
        scheduleFinishNotification()
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.tick()
            }
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        ticker?.cancel()
        playHaptic(.pause)
        cancelFinishNotification()
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        playHaptic(.start)
        scheduleFinishNotification()
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func reset() {
        ticker?.cancel()
        remainingSeconds = totalSeconds
        state = .idle
        cancelFinishNotification()
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            finish()
            return
        }
        remainingSeconds -= 1
    }

    private func finish() {
        ticker?.cancel()
        state = .finished
        playHaptic(.success)
        // оставим уведомление доставленным — пользователь увидит баннер
    }

    // MARK: - Haptics
    enum HType { case start, pause, success }
    private func playHaptic(_ type: HType) {
        guard allowHaptics else { return }
        let device = WKInterfaceDevice.current()
        switch type {
        case .start: device.play(.start)
        case .pause: device.play(.click)
        case .success: device.play(.success)
        }
    }

    // MARK: - Notifications
    private func scheduleFinishNotification() {
        cancelFinishNotification()

        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Focus complete"
        let minutes = totalSeconds / 60
        content.body = "Your \(minutes)-minute session is done."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(remainingSeconds), repeats: false)
        let req = UNNotificationRequest(identifier: "focus.finish", content: content, trigger: trigger)
        center.add(req, withCompletionHandler: nil)
    }

    private func cancelFinishNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["focus.finish"])
    }
}

