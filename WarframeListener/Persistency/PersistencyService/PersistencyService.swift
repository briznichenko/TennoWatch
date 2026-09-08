//
//  PersistencyService.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

protocol PersistencyService {
    func fetchModel<T: ValueTypeConvertible>(by type: T.Type, with descriptor: FetchDescriptor<T>) async throws -> [T.Value]
    func saveValue<T: PersistentModelConvertible>(value: T) async throws
}

extension PersistencyService {
    func fetchModel<T: ValueTypeConvertible>(by type: T.Type, with descriptor: FetchDescriptor<T> = .init()) async throws -> [T.Value] {
        try await self.fetchModel(by: T.self, with: descriptor)
    }
}

@ModelActor
actor DefaultPersistencyService: PersistencyService {
    func fetchModel<T: ValueTypeConvertible>(by type: T.Type, with descriptor: FetchDescriptor<T>) async throws -> [T.Value] {
        let models = try modelContext.fetch(descriptor)
        var values: [T.Value] = []
        for model in models {
            let convertedValue = await model.value
            values.append(convertedValue)
        }
        return values
    }
    
    func saveValue<T: PersistentModelConvertible>(value: T) async throws {
        let model = await value.model
        modelContext.insert(model)
        try modelContext.save()
    }
}
