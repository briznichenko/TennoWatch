//
//  AppLanguage.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Hashable {
    case system, english, ukrainian

    static let storageKey = "languagePreference"

    // MARK: - Computed Properties
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: Strings.Language.system
        case .english: "English"
        case .ukrainian: "Українська"
        }
    }

    var locale: Locale? {
        switch self {
        case .system: nil
        case .english: Locale(identifier: "en")
        case .ukrainian: Locale(identifier: "uk")
        }
    }

    static var current: AppLanguage {
        let rawValue = UserDefaults.standard.string(forKey: storageKey) ?? AppLanguage.system.rawValue
        return AppLanguage(rawValue: rawValue) ?? .system
    }
}
