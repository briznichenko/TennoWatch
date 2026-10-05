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
    func prepareCatalog(for profile: Profile) async throws
    func getMasteryCatalog() async throws -> MasteryCatalog
    func syncMasteryCatalog(with profileModel: Profile) async throws -> MasteryCatalog
    func getMasterySummary() async throws -> MasteryCatalogSummary
    func syncMasterySummary(with profileModel: Profile) async throws -> MasteryCatalogSummary
    func getCatalogContainer(for category: CatalogItemModel.Category) async throws -> CatalogContainer
    func getMasterySources(named source: MasterySourceType?) async throws -> MasteryCategoryModel
    func getMasterySourceCategories() async throws -> [MasteryCategoryModel]
}

final class PersistentCatalogRepository: CatalogRepository {
    enum CatalogError: Error {
        case wrongFilename, noCatalogAvailable, wrongCategory
    }

    let syncPolicy: SyncPolicy
    private let persistencyService: PersistencyService
    private let catalogSyncService: CatalogSyncService
    private let accountIDStore: AccountIDStoring
    private static let bundledContainer = Result { try loadContainer() }

    init(
        syncPolicy: SyncPolicy = .daily,
        persistencyService: PersistencyService,
        catalogSyncService: CatalogSyncService = DefaultCatalogSyncService(),
        accountIDStore: AccountIDStoring = UserDefaultsAccountIDStore()
    ) {
        self.syncPolicy = syncPolicy
        self.persistencyService = persistencyService
        self.catalogSyncService = catalogSyncService
        self.accountIDStore = accountIDStore
    }

    func prepareCatalog() async throws {
        try await readCatalog { _ in () }
    }

    func prepareCatalog(for profile: Profile) async throws {
        try await readCatalog(profileID: profile.accountID.oid) { _ in () }
    }

    func getMasteryCatalog() async throws -> MasteryCatalog {
        try await readCatalog { $0.value }
    }

    func syncMasteryCatalog(with profileModel: Profile) async throws -> MasteryCatalog {
        try await readCatalog(profileID: profileModel.accountID.oid, synchronize: true) { $0.value }
    }

    func getMasterySummary() async throws -> MasteryCatalogSummary {
        try await readCatalog { $0.summary }
    }

    func syncMasterySummary(with profileModel: Profile) async throws -> MasteryCatalogSummary {
        try await readCatalog(profileID: profileModel.accountID.oid, synchronize: true) { $0.summary }
    }

    func getCatalogContainer(for category: CatalogItemModel.Category) async throws -> CatalogContainer {
        try await readCatalog { catalog in
            guard let container = catalog.items.first(where: { $0.category == category }) else {
                throw CatalogError.wrongCategory
            }
            return container.value
        }
    }

    func getMasterySources(named source: MasterySourceType?) async throws -> MasteryCategoryModel {
        guard let source else { throw CatalogError.wrongCategory }
        let name = source.rawValue
        return try await readCatalog { catalog in
            guard let category = catalog.nonItemSources.first(where: { $0.name == name }) else {
                throw CatalogError.wrongCategory
            }
            return category.value
        }
    }

    func getMasterySourceCategories() async throws -> [MasteryCategoryModel] {
        try await readCatalog { $0.nonItemSources.map(\.value) }
    }

    private func readCatalog<T: Sendable>(
        profileID: String? = nil,
        synchronize: Bool = false,
        transform: @escaping @Sendable (MasteryCatalogDataModel) throws -> T
    ) async throws -> T {
        let bundle = try Self.bundledContainer.get()
        let activeID = accountIDStore.currentAccountID
        let selectedID = profileID ?? activeID
        let syncService = catalogSyncService
        let result = try await persistencyService.perform { context in
            do {
                let profile = try PersistentProfileRepository.resolveProfile(in: context, accountID: selectedID)
                let (catalog, wasCreated) = try Self.prepareCatalog(for: profile, bundle: bundle, in: context)
                if synchronize || wasCreated || catalog.syncedProfileLastUpdated != profile.lastUpdated {
                    Self.mergeProfile(profile, into: catalog, catalogSyncService: syncService)
                    catalog.syncedProfileLastUpdated = profile.lastUpdated
                }
                if context.hasChanges {
                    try context.save()
                }
                return (profile.accountID, try transform(catalog))
            } catch {
                context.rollback()
                throw error
            }
        }
        if profileID == nil, accountIDStore.currentAccountID == activeID {
            accountIDStore.currentAccountID = result.0
        }
        return result.1
    }

    private static func loadContainer() throws -> MasteryCatalogContainer {
        guard let url = Bundle.main.url(forResource: "masterycatalog", withExtension: "json") else {
            throw CatalogError.wrongFilename
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MasteryCatalogContainer.self, from: Data(contentsOf: url))
    }

    private static func prepareCatalog(
        for profile: ProfileDataModel,
        bundle: MasteryCatalogContainer,
        in context: ModelContext
    ) throws -> (MasteryCatalogDataModel, Bool) {
        if let existing = profile.masteryCatalog,
           existing.schemaVersion == bundle.schemaVersion,
           existing.generatedAt == bundle.generatedAt {
            return (existing, false)
        }
        let catalogs = try context.fetch(FetchDescriptor<MasteryCatalogDataModel>())
        let legacyCatalogs = catalogs.filter { $0.profile == nil }
        if !legacyCatalogs.isEmpty {
            for cached in try context.fetch(FetchDescriptor<ProfileDataModel>()) where !cached.isLocal {
                cached.lastUpdated = .distantPast
            }
            for legacy in legacyCatalogs { Self.deleteCatalog(legacy, in: context) }
        }
        if let old = profile.masteryCatalog {
            profile.masteryCatalog = nil
            Self.deleteCatalog(old, in: context)
        }
        var definitions = Dictionary(
            try context.fetch(FetchDescriptor<CatalogItemDataModel>()).map { ($0.uniqueName, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let catalog = MasteryCatalogDataModel(
            schemaVersion: bundle.schemaVersion, gameVersion: bundle.gameVersion,
            generatedAt: bundle.generatedAt, totalMasteryMax: bundle.totalMasteryMax,
            obtainableMasteryMax: bundle.obtainableMasteryMax, items: [], nonItemSources: []
        )
        context.insert(catalog)
        profile.masteryCatalog = catalog
        let items = bundle.items.map { item in
            let definition: CatalogItemDataModel
            if let stored = definitions[item.uniqueName] {
                definition = stored
                definition.name = item.name
                definition.category = item.category
                definition.maxRank = item.maxRank
                definition.pointsPerRank = item.pointsPerRank
                definition.xpPerRankSq = item.xpPerRankSq
                definition.icon = item.icon
                definition.obtainable = item.obtainable
                definition.requiresGilding = item.requiresGilding
            } else {
                definition = CatalogItemDataModel(catalogItem: item)
                context.insert(definition)
                definitions[item.uniqueName] = definition
            }
            return MasteryItemDataModel(catalogItem: definition, profileItem: nil)
        }
        catalog.items = CatalogItemModel.Category.allCases.map { category in
            CatalogContainerModel(category: category, masteryItems: items.filter { $0.catalogItem.category == category })
        }
        catalog.nonItemSources = bundle.nonItemSources.map { name, sources in
            MasteryCategoryDataModel(name: name, sources: sources.map(\.model))
        }
        return (catalog, true)
    }

    private static func deleteCatalog(_ catalog: MasteryCatalogDataModel, in context: ModelContext) {
        for container in catalog.items {
            for item in container.masteryItems where item.profileItem != nil {
                item.profileItem = nil
            }
        }
        context.delete(catalog)
    }

    private static func mergeProfile(
        _ profile: ProfileDataModel,
        into catalog: MasteryCatalogDataModel,
        catalogSyncService: CatalogSyncService
    ) {
        if profile.isLocal { return }
        let profileItems = Dictionary(profile.items.map { ($0.type, $0) }, uniquingKeysWith: { first, second in
            (first.xp ?? 0) >= (second.xp ?? 0) ? first : second
        })
        for container in catalog.items {
            for item in container.masteryItems {
                item.profileItem = profileItems[item.catalogItem.uniqueName]
                item.isMastered = item.value.isMastered
            }
            container.itemsCount = container.masteryItems.count
            container.obtainableItemsCount = container.masteryItems.filter { $0.catalogItem.obtainable }.count
            container.masteredItemsCount = container.masteryItems.filter(\.isMastered).count
            container.masteredObtainableCount = container.masteryItems.filter { $0.isMastered && $0.catalogItem.obtainable }.count
            container.fullyMasteredPoints = container.masteryItems.filter(\.isMastered).reduce(0) { $0 + $1.value.earnedMasteryPoints }
            container.partialPoints = container.masteryItems.filter { !$0.isMastered }.reduce(0) { $0 + $1.value.earnedMasteryPoints }
        }
        let profileValue = profile.value
        for category in catalog.nonItemSources {
            let merged = catalogSyncService.mergeProfile(profileValue, into: category.sources.map(\.value))
            for (source, value) in zip(category.sources, merged) {
                source.isMastered = value.isMastered == true
            }
            category.itemsCount = category.sources.count
            category.masteredItemsCount = category.sources.filter(\.isMastered).count
            category.masteredPoints = category.sources.filter(\.isMastered).reduce(0) { $0 + $1.mastery }
        }
    }
}
