//
//  NotificationService.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/17/26.
//

import Foundation
import UserNotifications

struct ScheduledNotification {
    let id: String
    let title: String
    let body: String
    let fireDate: Date
}

protocol NotificationService {
    func requestAuthorization() async throws -> Bool
    func schedule(_ notification: ScheduledNotification) async throws
    func cancelNotification(id: String)
}

final class DefaultNotificationService: NSObject, NotificationService {
    // MARK: - Object Properties
    private let center = UNUserNotificationCenter.current()

    // MARK: - Init
    override init() {
        super.init()
        center.delegate = self
    }

    // MARK: - Functions
    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func schedule(_ notification: ScheduledNotification) async throws {
        center.removePendingNotificationRequests(withIdentifiers: [notification.id])
        guard notification.fireDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: notification.fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

        try await center.add(request)
    }

    func cancelNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
}

extension DefaultNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
