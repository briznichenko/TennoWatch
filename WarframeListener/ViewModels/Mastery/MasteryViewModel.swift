//
//  MasteryViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import Foundation
import Observation

@Observable
final class MasteryViewModel {
    // MARK: - Object Properties
    private let profileRepository: ProfileRepository
    private let catalogRepository: CatalogRepository
    let errorManager: ErrorManager

    private(set) var isLoading: Bool = false

    // MARK: - Init
    init(profileRepository: ProfileRepository, catalogRepository: CatalogRepository, errorManager: ErrorManager) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func fetchCatalog() async {
        defer {
            isLoading = false
        }
        isLoading = true

        do {
            try await catalogRepository.ensureCatalogAvailable()
            try? await profileRepository.syncProfile()
            try await catalogRepository.syncCatalog()
        } catch {
            errorManager.append(error)
        }
    }
}
