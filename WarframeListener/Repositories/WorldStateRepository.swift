//
//  WorldStateRepository.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation

protocol WorldStateRepository {
    func getWorldState(platform: Platform) async throws -> WorldState
}

extension WorldStateRepository {
    func getWorldState(platform: Platform = .pc) async throws -> WorldState {
        try await getWorldState(platform: platform)
    }
}

final class DefaultWorldStateRepository: WorldStateRepository {
    private let worldStateService: ServiceProtocol

    init(worldStateService: ServiceProtocol = APIManager()) {
        self.worldStateService = worldStateService
    }

    func getWorldState(platform: Platform) async throws -> WorldState {
        try await worldStateService.fetch(.worldState(platform: platform))
    }
}
