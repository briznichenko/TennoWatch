//
//  PersistencyService.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

protocol PersistencyService: Sendable {
    func fetchModel<T: ValueTypeConvertible>(by type: T.Type, with descriptor: FetchDescriptor<T>) async throws -> [T.Value]
    func saveValues<T: PersistentModelConvertible>(_ values: [T]) async throws
    func saveValue<T: PersistentModelConvertible>(_ value: T) async throws
    func perform<T: Sendable>(_ operation: @Sendable (ModelContext) throws -> T) async throws -> T
}

extension PersistencyService {
    func fetchModel<T: ValueTypeConvertible>(by type: T.Type, with descriptor: FetchDescriptor<T> = .init()) async throws -> [T.Value] {
        try await self.fetchModel(by: T.self, with: descriptor)
    }

    func clearAllData() async throws {
        try await perform { context in
            for model in try context.fetch(FetchDescriptor<ProfileDataModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<AccountStatsDataModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<ProfileItemDataModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<ResultMissionDataModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<IntrinsicsDataModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<MasterySourceDataModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<MasteryCategoryDataModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<MasteryItemDataModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<CatalogItemDataModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<CatalogContainerModel>()) {
                context.delete(model)
            }
            for model in try context.fetch(FetchDescriptor<MasteryCatalogDataModel>()) {
                context.delete(model)
            }
            try context.save()
        }
    }
}

@ModelActor
actor DefaultPersistencyService: PersistencyService {
    private var widgetUpdatesEnabled = false

    init(modelContainer: ModelContainer, widgetUpdatesEnabled: Bool) {
        let context = ModelContext(modelContainer)
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.widgetUpdatesEnabled = widgetUpdatesEnabled
    }

    // MARK: - Functions
    func fetchModel<T: ValueTypeConvertible>(by type: T.Type, with descriptor: FetchDescriptor<T>) async throws -> [T.Value] {
        let models = try modelContext.fetch(descriptor)
        var values: [T.Value] = []
        for model in models {
            let convertedValue = model.value
            values.append(convertedValue)
        }
        return values
    }

    func saveValues<T: PersistentModelConvertible>(_ values: [T]) async throws {
        for item in values {
            let model = item.model
            modelContext.insert(model)
        }
        try modelContext.save()
        publishWidgetSnapshots()
    }

    func saveValue<T>(_ value: T) async throws where T: PersistentModelConvertible {
        modelContext.insert(value.model)
        try modelContext.save()
        publishWidgetSnapshots()
    }

    func perform<T: Sendable>(_ operation: @Sendable (ModelContext) throws -> T) async throws -> T {
        let result = try operation(modelContext)
        publishWidgetSnapshots()
        return result
    }

    private func publishWidgetSnapshots() {
        guard widgetUpdatesEnabled,
              let profiles = try? modelContext.fetch(FetchDescriptor<ProfileDataModel>()) else { return }
        let snapshots = profiles.compactMap { profile -> MasterySnapshot? in
            guard let summary = profile.masteryCatalog?.summary else { return nil }
            let earnedXP = summary.categories.reduce(0) { $0 + $1.earnedMasteryPoints }
                + summary.nonItemCategories.reduce(0) { $0 + $1.earnedMasteryPoints }
            return MasterySnapshot(
                accountID: profile.accountID, name: profile.displayName,
                playerRank: profile.isLocal ? nil : profile.playerLevel,
                earnedXP: earnedXP, obtainableMasteryMax: summary.obtainableMasteryMax,
                updatedAt: profile.lastUpdated
            )
        }
        WidgetSnapshotStore().saveMastery(snapshots.sorted { $0.accountID < $1.accountID })
    }
}
