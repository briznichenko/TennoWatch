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

    private let modelContainer: ModelContainer
    private let dependencies: AppDependencies

    // MARK: - Init
    init() {
        modelContainer = Self.makeModelContainer()
        dependencies = AppDependencies(modelContainer: modelContainer)
        AppearanceProxies.configure()
    }

    // MARK: - Body
    var body: some Scene {
        #if os(macOS)
        Window("TennoWatch", id: "main") {
            appContent
                .frame(minWidth: 820, minHeight: 600)
        }
        .defaultSize(width: 1100, height: 760)
        .modelContainer(modelContainer)

        Settings {
            MacSettingsView(dependencies: dependencies) {
                cacheResetID = UUID()
            }
            .id(cacheResetID)
            .tint(.accent)
            .foregroundStyle(Color.labelPrimary)
            .preferredColorScheme(themePreference.colorScheme)
            .environment(\.locale, languagePreference.locale ?? .current)
            .id(languagePreference)
        }
        .modelContainer(modelContainer)
        #else
        WindowGroup {
            appContent
        }
        .modelContainer(modelContainer)
        #endif
    }

    private var appContent: some View {
        RootView(dependencies: dependencies)
            .id(cacheResetID)
            .tint(.accent)
            .foregroundStyle(Color.labelPrimary)
            .preferredColorScheme(themePreference.colorScheme)
            .environment(\.locale, languagePreference.locale ?? .current)
            .id(languagePreference)
    }

    // MARK: - Helper Functions
    private static func makeModelContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: ProfileDataModel.self,
                MasteryCatalogDataModel.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
