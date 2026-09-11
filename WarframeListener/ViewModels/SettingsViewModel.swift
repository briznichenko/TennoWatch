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

    init(
        persistencyService: PersistencyService,
        catalogRepository: CatalogRepository,
        profileRepository: ProfileRepository
    ) {
        self.persistencyService = persistencyService
        self.catalogRepository = catalogRepository
        self.profileRepository = profileRepository
    }

    func loadCatalogInfo() async {
        do {
            let catalogs = try await persistencyService.fetchModel(by: MasteryCatalogDataModel.self)
            gameVersion = catalogs.first?.gameVersion
            catalogGeneratedAt = catalogs.first?.generatedAt
        } catch {
            statusText = error.localizedDescription
        }
    }

    func refreshCatalog() async {
        defer { isRefreshing = false }
        isRefreshing = true
        statusText = "Refreshing…"

        do {
            let profile = try await profileRepository.getProfile(withPlayerId: .none)
            _ = try await catalogRepository.syncCatalogs(with: profile)
            await loadCatalogInfo()
            statusText = ""
        } catch {
            statusText = error.localizedDescription
        }
    }
}
