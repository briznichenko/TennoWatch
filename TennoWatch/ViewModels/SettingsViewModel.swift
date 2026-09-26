//
//  SettingsViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import Foundation
import Observation

@Observable
final class SettingsViewModel {
    // MARK: - Object Properties
    private(set) var gameVersion: String?
    private(set) var catalogGeneratedAt: Date?
    private(set) var isRefreshing = false
    private(set) var isClearingCache = false

    private let persistencyService: PersistencyService
    private let catalogRepository: CatalogRepository
    private let profileRepository: ProfileRepository
    private let worldStateRepository: WorldStateRepository
    private let notificationService: NotificationService
    private let voidTraderNotificationScheduler: VoidTraderNotificationScheduler
    let errorManager: ErrorManager

    // MARK: - Init
    init(
        persistencyService: PersistencyService,
        catalogRepository: CatalogRepository,
        profileRepository: ProfileRepository,
        worldStateRepository: WorldStateRepository,
        notificationService: NotificationService,
        voidTraderNotificationScheduler: VoidTraderNotificationScheduler,
        errorManager: ErrorManager
    ) {
        self.persistencyService = persistencyService
        self.catalogRepository = catalogRepository
        self.profileRepository = profileRepository
        self.worldStateRepository = worldStateRepository
        self.notificationService = notificationService
        self.voidTraderNotificationScheduler = voidTraderNotificationScheduler
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func loadCatalogInfo() async {
        do {
            let catalogs = try await persistencyService.fetchModel(by: MasteryCatalogDataModel.self)
            gameVersion = "\(catalogs.first?.gameVersion.hash ?? 0)"
            catalogGeneratedAt = catalogs.first?.generatedAt
        } catch {
            errorManager.append(error)
        }
    }

    func refreshCatalog() async {
        defer { isRefreshing = false }
        isRefreshing = true

        do {
            let profile = try await profileRepository.getProfile(forceRefresh: true)
            _ = try await catalogRepository.syncMasteryCatalog(with: profile)
            await loadCatalogInfo()
        } catch {
            errorManager.append(error)
        }
    }

    func setVoidTraderNotificationsEnabled(_ isEnabled: Bool) async {
        guard isEnabled else {
            voidTraderNotificationScheduler.cancelArrivalNotification()
            return
        }

        do {
            let isGranted = try await notificationService.requestAuthorization()
            guard isGranted else { return }
            let voidTrader = try await worldStateRepository.getWorldState().voidTrader
            try await voidTraderNotificationScheduler.syncArrivalNotification(for: voidTrader)
        } catch {
            errorManager.append(error)
        }
    }

    func clearCache() async -> Bool {
        isClearingCache = true
        defer { isClearingCache = false }

        do {
            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                throw ClearCacheError.missingBundleIdentifier
            }
            try await persistencyService.clearAllData()
            voidTraderNotificationScheduler.cancelArrivalNotification()
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            gameVersion = nil
            catalogGeneratedAt = nil
            return true
        } catch {
            errorManager.append(error)
            return false
        }
    }
}

private enum ClearCacheError: Error {
    case missingBundleIdentifier
}
