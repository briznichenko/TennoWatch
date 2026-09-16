//
//  WarframeListenerApp.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI
import SwiftData

@main
struct WarframeListenerApp: App {
    // MARK: - Object Properties
    @AppStorage("themePreference") private var themePreference: ThemePreference = .system
    @AppStorage(AppLanguage.storageKey) private var languagePreference: AppLanguage = .system

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
        WindowGroup {
            MainView(dependencies: dependencies)
                .tint(.accent)
                .foregroundStyle(Color.labelPrimary)
                .preferredColorScheme(themePreference.colorScheme)
                .environment(\.locale, languagePreference.locale ?? .current)
                .id(languagePreference)
        }
        .modelContainer(modelContainer)
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
