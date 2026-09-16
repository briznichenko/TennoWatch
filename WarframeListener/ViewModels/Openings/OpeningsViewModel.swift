//
//  OpeningsViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import Foundation
import Observation

@Observable
final class OpeningsViewModel {
    // MARK: - Object Properties
    private let profileRepository: ProfileRepository
    private let catalogRepository: CatalogRepository
    private let worldStateRepository: WorldStateRepository
    private let matchingService: OpeningsMatchingService
    let errorManager: ErrorManager

    private(set) var catalog: MasteryCatalog?
    private(set) var worldState: WorldState?
    private(set) var isLoading = false

    // MARK: - Computed Properties
    private var unmasteredItems: [MasteryItem] {
        (catalog?.items.flatMap(\.masteryItems) ?? []).filter { $0.obtainable && !$0.isMastered }
    }

    private var unmasteredSources: [MasterySourceModel] {
        (catalog?.nonItemSources.flatMap(\.sources) ?? []).filter { $0.isMastered != true }
    }

    private var matchedOpenings: [TimeSensitiveOpening] {
        guard let worldState else { return [] }
        return matchingService.timeSensitiveOpenings(for: unmasteredItems, in: worldState)
    }

    var timeSensitiveOpenings: [TimeSensitiveOpeningViewModel] {
        matchedOpenings
            .sorted { $0.item.catalogItemModel.name < $1.item.catalogItemModel.name }
            .map { TimeSensitiveOpeningViewModel(opening: $0) }
    }

    var permanentItems: [MasteryItemViewModel] {
        let timeSensitiveIDs = Set(matchedOpenings.map(\.id))
        return unmasteredItems
            .filter { !timeSensitiveIDs.contains($0.catalogItemModel.uniqueName) }
            .sorted { $0.catalogItemModel.name < $1.catalogItemModel.name }
            .map { MasteryItemViewModel(item: $0) }
    }

    var permanentSources: [MasterySourceViewModel] {
        unmasteredSources
            .sorted { $0.name < $1.name }
            .map { MasterySourceViewModel(source: $0) }
    }

    // MARK: - Init
    init(
        profileRepository: ProfileRepository,
        catalogRepository: CatalogRepository,
        worldStateRepository: WorldStateRepository,
        matchingService: OpeningsMatchingService = DefaultOpeningsMatchingService(),
        errorManager: ErrorManager
    ) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
        self.worldStateRepository = worldStateRepository
        self.matchingService = matchingService
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func fetchOpenings() async {
        isLoading = true
        defer { isLoading = false }

        async let fetchedCatalog = fetchCatalog()
        async let fetchedWorldState = fetchWorldState()
        catalog = await fetchedCatalog
        worldState = await fetchedWorldState
    }

    // MARK: - Helper Functions
    private func fetchCatalog() async -> MasteryCatalog? {
        do {
            if let profile = try? await profileRepository.getProfile() {
                return try await catalogRepository.syncMasteryCatalog(with: profile)
            }
            return try await catalogRepository.getMasteryCatalog()
        } catch {
            errorManager.append(error)
            return nil
        }
    }

    private func fetchWorldState() async -> WorldState? {
        do {
            return try await worldStateRepository.getWorldState()
        } catch {
            errorManager.append(error)
            return nil
        }
    }
}
