//
//  SettingsViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import Foundation
import Observation

@Observable
final class SettingsViewModel {
    private(set) var gameVersion: String?
    private(set) var catalogGeneratedAt: Date?
    private(set) var isRefreshing = false
    private(set) var statusText: String = ""

    private let persistencyService: PersistencyService
    private let catalogRepository: CatalogRepository
    private let profileRepository: ProfileRepository
    let errorManager: ErrorManager

    init(
        persistencyService: PersistencyService,
        catalogRepository: CatalogRepository,
        profileRepository: ProfileRepository,
        errorManager: ErrorManager
    ) {
        self.persistencyService = persistencyService
        self.catalogRepository = catalogRepository
        self.profileRepository = profileRepository
        self.errorManager = errorManager
    }

    func loadCatalogInfo() async {
        do {
            let catalogs = try await persistencyService.fetchModel(by: MasteryCatalogDataModel.self)
            gameVersion = catalogs.first?.gameVersion
            catalogGeneratedAt = catalogs.first?.generatedAt
        } catch {
            errorManager.append(error)
        }
    }

    func refreshCatalog() async {
        defer { isRefreshing = false }
        isRefreshing = true

        do {
            let profile = try await profileRepository.getProfile()
            _ = try await catalogRepository.syncMasteryCatalog(with: profile)
            await loadCatalogInfo()
        } catch {
            errorManager.append(error)
        }
    }
}
