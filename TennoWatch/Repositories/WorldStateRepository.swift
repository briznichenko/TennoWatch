//
//  WorldStateRepository.swift
//  TennoWatch
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
    // MARK: - Object Properties
    private let worldStateService: ServiceProtocol

    // MARK: - Init
    init(worldStateService: ServiceProtocol = APIManager()) {
        self.worldStateService = worldStateService
    }

    // MARK: - Functions
    func getWorldState(platform: Platform) async throws -> WorldState {
        try await worldStateService.fetch(.worldState(platform: platform))
    }
}
