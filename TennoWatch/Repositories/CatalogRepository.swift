//
//  CatalogRepository.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

enum SyncPolicy { case daily }

enum MasterySourceType: String {
    case nodes, intrinsics, junctions
}

protocol CatalogRepository {
    var syncPolicy: SyncPolicy { get }

    func prepareCatalog() async throws

    func getMasteryCatalog() async throws -> MasteryCatalog
    func syncMasteryCatalog(with profileModel: Profile) async throws -> MasteryCatalog

    func getMasterySummary() async throws -> MasteryCatalogSummary
    func syncMasterySummary(with profileModel: Profile) async throws -> MasteryCatalogSummary

    func getCatalogContainer(for category: CatalogItemModel.Category) async throws -> CatalogContainer
    func getMasterySources(named source: MasterySourceType?) async throws -> MasteryCategoryModel
}

final class PersistentCatalogRepository: CatalogRepository {
    enum CatalogError: Error {
        case wrongFilename
        case noCatalogAvailable
        case wrongCategory
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
    func prepareCatalog() async throws {
        try await ensureCatalogSeeded()
    }

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

    func getMasterySources(named source: MasterySourceType?) async throws -> MasteryCategoryModel {
        guard let source else { throw CatalogError.wrongCategory }
        let matchString = source.rawValue
        return try await persistencyService.perform { context in
            let descriptor = FetchDescriptor<MasteryCategoryDataModel>(
                predicate: #Predicate { $0.name == matchString }
            )
            guard let category = try context.fetch(descriptor).first else {
                throw CatalogError.noCatalogAvailable
            }
            return category.value
        }
    }

    // MARK: - Helper Functions
    private func ensureCatalogSeeded(filename: String = "masterycatalog") async throws {
        let container = try Self.loadContainer(filename: filename)
        let bundledVersion = container.schemaVersion
        let isCurrent = try await persistencyService.perform { context in
            try context.fetch(FetchDescriptor<MasteryCatalogDataModel>())
                .contains { $0.schemaVersion == bundledVersion }
        }
        guard !isCurrent else { return }

        try await persistencyService.perform { context in
            try Self.deleteAll(MasterySourceDataModel.self, in: context)
            try Self.deleteAll(MasteryCategoryDataModel.self, in: context)
            try Self.deleteAll(MasteryItemDataModel.self, in: context)
            try Self.deleteAll(CatalogItemDataModel.self, in: context)
            try Self.deleteAll(CatalogContainerModel.self, in: context)
            try Self.deleteAll(MasteryCatalogDataModel.self, in: context)
            try context.save()
        }

        try await persistencyService.saveValue(MasteryCatalog(container: container))
    }

    private static func deleteAll<T: PersistentModel>(_ type: T.Type, in context: ModelContext) throws {
        for model in try context.fetch(FetchDescriptor<T>()) {
            context.delete(model)
        }
    }

    private static func loadContainer(filename: String) throws -> MasteryCatalogContainer {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw CatalogError.wrongFilename
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MasteryCatalogContainer.self, from: data)
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
