//
//  PersistencyService.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

protocol PersistencyService: Sendable {
    func perform<T: Sendable>(_ operation: @Sendable (ModelContext) throws -> T) async throws -> T
}

@ModelActor
actor DefaultPersistencyService: PersistencyService {
    // MARK: - Functions
    func perform<T: Sendable>(_ operation: @Sendable (ModelContext) throws -> T) async throws -> T {
        try operation(modelContext)
    }
}
