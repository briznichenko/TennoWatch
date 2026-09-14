//
//  AppDependencies.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftData

struct AppDependencies {
    let persistencyService: PersistencyService
    let profileRepository: ProfileRepository
    let catalogRepository: CatalogRepository
    let errorManager: ErrorManager

    init(modelContainer: ModelContainer) {
        let persistencyService = DefaultPersistencyService(modelContainer: modelContainer)
        self.persistencyService = persistencyService
        self.profileRepository = PersistentProfileRepository(persistencyService: persistencyService)
        self.catalogRepository = PersistentCatalogRepository(persistencyService: persistencyService)
        self.errorManager = DefaultErrorManager()
    }
}
