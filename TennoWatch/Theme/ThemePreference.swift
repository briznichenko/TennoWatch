//
//  ThemePreference.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

enum ThemePreference: String, CaseIterable, Identifiable, Hashable {
    case system, light, dark

    // MARK: - Computed Properties
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: Strings.Theme.system
        case .light: Strings.Theme.light
        case .dark: Strings.Theme.dark
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
