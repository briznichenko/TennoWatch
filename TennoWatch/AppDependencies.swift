//
//  AppDependencies.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftData

struct AppDependencies {
    // MARK: - Object Properties
    let persistencyService: PersistencyService
    let profileRepository: ProfileRepository
    let catalogRepository: CatalogRepository
    let worldStateRepository: WorldStateRepository
    let errorManager: ErrorManager
    let notificationService: NotificationService
    let voidTraderNotificationScheduler: VoidTraderNotificationScheduler

    // MARK: - Init
    init(modelContainer: ModelContainer) {
        let persistencyService = DefaultPersistencyService(modelContainer: modelContainer)
        self.persistencyService = persistencyService
        let accountIDStore = UserDefaultsAccountIDStore()
        let catalogRepository = PersistentCatalogRepository(persistencyService: persistencyService, accountIDStore: accountIDStore)
        self.catalogRepository = catalogRepository
        self.profileRepository = PersistentProfileRepository(
            persistencyService: persistencyService, accountIDStore: accountIDStore, catalogRepository: catalogRepository
        )
        self.worldStateRepository = DefaultWorldStateRepository()
        self.errorManager = DefaultErrorManager()
        let notificationService = DefaultNotificationService()
        self.notificationService = notificationService
        self.voidTraderNotificationScheduler = DefaultVoidTraderNotificationScheduler(notificationService: notificationService)
    }
}
