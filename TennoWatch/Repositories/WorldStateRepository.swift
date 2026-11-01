//
//  WorldStateRepository.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation

protocol WorldStateRepository: Sendable {
    func getWorldState(platform: Platform) async throws -> WorldState
    func clearCache() async
}

extension WorldStateRepository {
    func clearCache() async {}

    func getWorldState(platform: Platform = .pc) async throws -> WorldState {
        try await getWorldState(platform: platform)
    }
}

struct DefaultWorldStateRepository: WorldStateRepository {
    // MARK: - Object Properties
    private let worldStateService: ServiceProtocol

    // MARK: - Init
    init(worldStateService: ServiceProtocol = APIManager()) {
        self.worldStateService = worldStateService
    }

    func clearCache() async {
        await worldStateService.clearCache()
    }

    // MARK: - Functions
    func getWorldState(platform: Platform) async throws -> WorldState {
        try await worldStateService.fetch(.worldState(platform: platform))
    }
}
