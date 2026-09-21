//
//  AccountIDStore.swift
//  TennoWatch
//

import Foundation

protocol AccountIDStoring {
    var currentAccountID: String? { get set }
}

final class UserDefaultsAccountIDStore: AccountIDStoring {
    static let storageKey = "currentAccountID"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var currentAccountID: String? {
        get { defaults.string(forKey: Self.storageKey) }
        set { defaults.set(newValue, forKey: Self.storageKey) }
    }
}
