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
    private let modelContainer: ModelContainer
    private let dependencies: AppDependencies

    init() {
        modelContainer = Self.makeModelContainer()
        dependencies = AppDependencies(modelContainer: modelContainer)
    }

    var body: some Scene {
        WindowGroup {
            MainView(dependencies: dependencies)
                .tint(.accent)
                .foregroundStyle(.label)
        }
        .modelContainer(modelContainer)
    }

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
