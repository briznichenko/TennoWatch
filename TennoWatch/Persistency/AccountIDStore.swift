//
//  AccountIDStore.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/17/26.
//

import Foundation
import Synchronization

protocol AccountIDStoring: AnyObject, Sendable {
    var currentAccountID: String? { get set }
    func replaceCurrentAccountID(with accountID: String?, ifMatching expectedID: String?) -> Bool
}

final class UserDefaultsAccountIDStore: AccountIDStoring, @unchecked Sendable {
    static let storageKey = "currentAccountID"

    private let defaults: UserDefaults
    private let lock = Mutex(())
    private let widgetUpdatesEnabled: Bool

    init(defaults: UserDefaults = .standard, widgetUpdatesEnabled: Bool = false) {
        self.defaults = defaults
        self.widgetUpdatesEnabled = widgetUpdatesEnabled
    }

    var currentAccountID: String? {
        get { lock.withLock { _ in defaults.string(forKey: Self.storageKey) } }
        set {
            lock.withLock { _ in
                defaults.set(newValue, forKey: Self.storageKey)
                if widgetUpdatesEnabled { WidgetSnapshotStore().selectAccount(newValue) }
            }
        }
    }

    func replaceCurrentAccountID(with accountID: String?, ifMatching expectedID: String?) -> Bool {
        lock.withLock { _ in
            guard defaults.string(forKey: Self.storageKey) == expectedID else { return false }
            defaults.set(accountID, forKey: Self.storageKey)
            if widgetUpdatesEnabled { WidgetSnapshotStore().selectAccount(accountID) }
            return true
        }
    }

}
