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
    // MARK: - Object Properties
    private(set) var isRefreshing = false
    private(set) var statusText: String = ""

    private let catalogRepository: CatalogRepository
    private let profileRepository: ProfileRepository
    let errorManager: ErrorManager

    // MARK: - Init
    init(
        catalogRepository: CatalogRepository,
        profileRepository: ProfileRepository,
        errorManager: ErrorManager
    ) {
        self.catalogRepository = catalogRepository
        self.profileRepository = profileRepository
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func refreshCatalog() async {
        defer { isRefreshing = false }
        isRefreshing = true

        do {
            try await profileRepository.syncProfile()
            try await catalogRepository.syncCatalog()
        } catch {
            errorManager.append(error)
        }
    }
}
