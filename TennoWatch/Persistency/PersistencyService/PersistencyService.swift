//
//  PersistencyService.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

protocol PersistencyService {
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
    // MARK: - Functions
    func fetchModel<T: ValueTypeConvertible>(by type: T.Type, with descriptor: FetchDescriptor<T>) async throws -> [T.Value] {
        let models = try modelContext.fetch(descriptor)
        var values: [T.Value] = []
        for model in models {
            let convertedValue = await model.value
            values.append(convertedValue)
        }
        return values
    }

    func saveValues<T: PersistentModelConvertible>(_ values: [T]) async throws {
        for item in values {
            let model = await item.model
            modelContext.insert(model)
        }
        try modelContext.save()
    }

    func saveValue<T>(_ value: T) async throws where T: PersistentModelConvertible {
        await modelContext.insert(value.model)
        try modelContext.save()
    }

    func perform<T: Sendable>(_ operation: @Sendable (ModelContext) throws -> T) async throws -> T {
        try operation(modelContext)
    }
}
