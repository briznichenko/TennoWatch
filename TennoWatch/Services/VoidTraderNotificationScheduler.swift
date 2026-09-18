//
//  VoidTraderNotificationScheduler.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/17/26.
//

import Foundation

protocol VoidTraderNotificationScheduler {
    func syncArrivalNotification(for voidTrader: VoidTrader?) async throws
    func cancelArrivalNotification()
}

struct DefaultVoidTraderNotificationScheduler: VoidTraderNotificationScheduler {
    // MARK: - Object Properties
    static let preferenceKey = "voidTraderNotificationsEnabled"
    private static let notificationID = "voidTraderArrival"

    private let notificationService: NotificationService
    private let userDefaults: UserDefaults

    // MARK: - Init
    init(notificationService: NotificationService, userDefaults: UserDefaults = .standard) {
        self.notificationService = notificationService
        self.userDefaults = userDefaults
    }

    // MARK: - Functions
    func syncArrivalNotification(for voidTrader: VoidTrader?) async throws {
        guard userDefaults.bool(forKey: Self.preferenceKey) else { return }
        guard let voidTrader, let activation = voidTrader.activation, activation > .now else { return }

        let notification = ScheduledNotification(
            id: Self.notificationID,
            title: Strings.Notifications.voidTraderTitle,
            body: Strings.Notifications.voidTraderBody(voidTrader.character, location: voidTrader.location),
            fireDate: activation
        )
        try await notificationService.schedule(notification)
    }

    func cancelArrivalNotification() {
        notificationService.cancelNotification(id: Self.notificationID)
    }
}
