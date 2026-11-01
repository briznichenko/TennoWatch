//
//  TennoWatchApp.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI
import SwiftData

@main
struct TennoWatchApp: App {
    // MARK: - Object Properties
    @AppStorage("themePreference") private var themePreference: ThemePreference = .system
    @AppStorage(AppLanguage.storageKey) private var languagePreference: AppLanguage = .system

    @State private var cacheResetID = UUID()

    private let startupState: AppStartupState

    // MARK: - Init
    init() {
        startupState = AppStartupState()
        AppearanceProxies.configure()
    }

    // MARK: - Body
    var body: some Scene {
        AppScenes {
            appContent
                .tint(.accent)
                .foregroundStyle(Color.labelPrimary)
                .preferredColorScheme(themePreference.colorScheme)
                .environment(\.locale, languagePreference.locale ?? .current)
                .id(languagePreference)
        } settings: {
            settingsContent
                .tint(.accent)
                .foregroundStyle(Color.labelPrimary)
                .preferredColorScheme(themePreference.colorScheme)
                .environment(\.locale, languagePreference.locale ?? .current)
                .id(languagePreference)
        }
    }

    @ViewBuilder
    private var appContent: some View {
        switch startupState {
        case .ready(let container, let dependencies):
            RootView(dependencies: dependencies)
                .id(cacheResetID)
                .modelContainer(container)
        case .failed:
            startupErrorView
        }
    }

    @ViewBuilder
    private var settingsContent: some View {
        switch startupState {
        case .ready(let container, let dependencies):
            SettingsSceneContent(dependencies: dependencies) {
                cacheResetID = UUID()
            }
            .id(cacheResetID)
            .modelContainer(container)
        case .failed:
            startupErrorView
        }
    }

    private var startupErrorView: some View {
        ContentUnavailableView(
            Strings.Errors.startupTitle,
            systemImage: "externaldrive.badge.exclamationmark",
            description: Text(Strings.Errors.databaseStartup)
        )
    }
}
