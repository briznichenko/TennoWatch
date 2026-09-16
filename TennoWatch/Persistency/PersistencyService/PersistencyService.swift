//
//  PersistencyService.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

// `Sendable` here is what lets a `let persistencyService: PersistencyService` stored
// property be captured into a `@Sendable` closure (e.g. a detached Task) elsewhere.
// Without it, the *existential* `any PersistencyService` isn't provably safe to hand
// across an isolation boundary even when every real conformer (an actor) obviously is.
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
