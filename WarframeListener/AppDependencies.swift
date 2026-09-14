//
//  AppDependencies.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftData

struct AppDependencies {
    // MARK: - Object Properties
    let profileRepository: ProfileRepository
    let catalogRepository: CatalogRepository
    let worldStateRepository: WorldStateRepository
    let errorManager: ErrorManager

    // MARK: - Init
    init(modelContainer: ModelContainer) {
        let persistencyService = DefaultPersistencyService(modelContainer: modelContainer)
        self.profileRepository = PersistentProfileRepository(persistencyService: persistencyService)
        self.catalogRepository = PersistentCatalogRepository(persistencyService: persistencyService)
        self.worldStateRepository = DefaultWorldStateRepository()
        self.errorManager = DefaultErrorManager()
    }
}
