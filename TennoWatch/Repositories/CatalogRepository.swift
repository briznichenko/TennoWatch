//
//  CatalogRepository.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

enum SyncPolicy { case daily }

protocol CatalogRepository: Sendable {
    var syncPolicy: SyncPolicy { get }

    func getMasteryCatalog() async throws -> MasteryCatalog
    func syncMasteryCatalog(with profileModel: Profile) async throws -> MasteryCatalog

    func getMasterySummary() async throws -> MasteryCatalogSummary
    func syncMasterySummary(with profileModel: Profile) async throws -> MasteryCatalogSummary

    func getCatalogContainer(for category: CatalogItemModel.Category) async throws -> CatalogContainer
    func getMasterySources(named name: String) async throws -> MasteryCategoryModel
}

// `final` + every stored property `let` + every stored property's type Sendable is what
// makes this safe to state explicitly — the compiler checks the claim, it doesn't just
// take the annotation's word for it.
final class PersistentCatalogRepository: CatalogRepository, Sendable {
    enum CatalogError: Error {
        case wrongFilename
        case noCatalogAvailable
    }

    // MARK: - Object Properties
    let syncPolicy: SyncPolicy
    private let persistencyService: PersistencyService
    private let catalogSyncService: CatalogSyncService

    // MARK: - Init
    init(syncPolicy: SyncPolicy = .daily, persistencyService: PersistencyService, catalogSyncService: CatalogSyncService = DefaultCatalogSyncService()) {
        self.syncPolicy = syncPolicy
        self.persistencyService = persistencyService
        self.catalogSyncService = catalogSyncService
    }

    // MARK: - Functions
    func getMasteryCatalog() async throws -> MasteryCatalog {
        try await ensureCatalogSeeded()
        return try await persistencyService.perform { context in
            try Self.fetchCatalogModel(in: context).value
        }
    }

    func syncMasteryCatalog(with profileModel: Profile) async throws -> MasteryCatalog {
        try await ensureCatalogSeeded()
        let catalogSyncService = self.catalogSyncService
        return try await persistencyService.perform { context in
            try Self.mergeProfile(profileModel, in: context, catalogSyncService: catalogSyncService).value
        }
    }

    func getMasterySummary() async throws -> MasteryCatalogSummary {
        try await ensureCatalogSeeded()
        return try await persistencyService.perform { context in
            try Self.fetchCatalogModel(in: context).summary
        }
    }

    func syncMasterySummary(with profileModel: Profile) async throws -> MasteryCatalogSummary {
        try await ensureCatalogSeeded()
        let catalogSyncService = self.catalogSyncService
        return try await persistencyService.perform { context in
            try Self.mergeProfile(profileModel, in: context, catalogSyncService: catalogSyncService).summary
        }
    }

    func getCatalogContainer(for category: CatalogItemModel.Category) async throws -> CatalogContainer {
        try await persistencyService.perform { context in
            let descriptor = FetchDescriptor<CatalogContainerModel>(
                predicate: #Predicate { $0.category == category }
            )
            guard let container = try context.fetch(descriptor).first else {
                throw CatalogError.noCatalogAvailable
            }
            return container.value
        }
    }

    func getMasterySources(named name: String) async throws -> MasteryCategoryModel {
        try await persistencyService.perform { context in
            let descriptor = FetchDescriptor<MasteryCategoryDataModel>(
                predicate: #Predicate { $0.name == name }
            )
            guard let category = try context.fetch(descriptor).first else {
                throw CatalogError.noCatalogAvailable
            }
            return category.value
        }
    }

    // MARK: - Helper Functions
    private func ensureCatalogSeeded(filename: String = "masterycatalog") async throws {
        let isSeeded = try await persistencyService.perform { context in
            try context.fetchCount(FetchDescriptor<MasteryCatalogDataModel>()) > 0
        }
        guard !isSeeded else { return }
        let container = try Self.loadCatalog(filename: filename)
        try await persistencyService.saveValue(container)
    }

    private static func loadCatalog(filename: String) throws -> MasteryCatalog {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw CatalogError.wrongFilename
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let container = try decoder.decode(MasteryCatalogContainer.self, from: data)
        return .init(container: container)
    }

    private static func fetchCatalogModel(in context: ModelContext) throws -> MasteryCatalogDataModel {
        guard let catalogModel = try context.fetch(FetchDescriptor<MasteryCatalogDataModel>()).first else {
            throw CatalogError.noCatalogAvailable
        }
        return catalogModel
    }

    private static func mergeProfile(
        _ profile: Profile,
        in context: ModelContext,
        catalogSyncService: CatalogSyncService
    ) throws -> MasteryCatalogDataModel {
        let catalogModel = try fetchCatalogModel(in: context)

        catalogModel.items.forEach { container in
            let unmastered = container.masteryItems.filter { !$0.isMastered }
            guard !unmastered.isEmpty else { return }

            let merged = catalogSyncService.mergeProfile(profile, into: unmastered.map(\.value))

            var partialPoints = 0
            for (itemModel, mergedItem) in zip(unmastered, merged) {
                if let profileItemModel = mergedItem.profileItemModel {
                    itemModel.set(profileItemModel: profileItemModel)
                }
                if itemModel.isMastered {
                    container.masteredItemsCount += 1
                    container.fullyMasteredPoints += itemModel.catalogItem.maxRank * itemModel.catalogItem.pointsPerRank
                    if itemModel.catalogItem.obtainable {
                        container.masteredObtainableCount += 1
                    }
                } else {
                    partialPoints += mergedItem.earnedMasteryPoints
                }
            }
            container.partialPoints = partialPoints
        }

        catalogModel.nonItemSources.forEach { category in
            let unmastered = category.sources.filter { !$0.isMastered }
            guard !unmastered.isEmpty else { return }

            let merged = catalogSyncService.mergeProfile(profile, into: unmastered.map(\.value))

            for (sourceModel, mergedSource) in zip(unmastered, merged) {
                guard mergedSource.isMastered == true else { continue }
                sourceModel.isMastered = true
                category.masteredItemsCount += 1
                category.masteredPoints += sourceModel.mastery
            }
        }

        try context.save()
        return catalogModel
    }
}
