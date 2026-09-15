//
//  WorldStateViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation
import Observation

struct WorldCycleDisplay: Identifiable {
    let id: String
    let title: String
    let state: String
    let timeLeft: String
}

@Observable
final class WorldStateViewModel {
    // MARK: - Object Properties
    private let worldStateRepository: WorldStateRepository
    let errorManager: ErrorManager

    private(set) var worldState: WorldState?
    private(set) var isLoading = false

    // MARK: - Computed Properties
    var cycles: [WorldCycleDisplay] {
        guard let worldState else { return [] }
        return [
            WorldCycleDisplay(
                id: "cetus",
                title: Strings.WorldState.cetusCycle,
                state: worldState.cetusCycle.isDay ? Strings.WorldState.cycleDay : Strings.WorldState.cycleNight,
                timeLeft: worldState.cetusCycle.timeLeft
            ),
            WorldCycleDisplay(
                id: "vallis",
                title: Strings.WorldState.vallisCycle,
                state: worldState.vallisCycle.isWarm ? Strings.WorldState.cycleWarm : Strings.WorldState.cycleCold,
                timeLeft: Self.timeLeft(until: worldState.vallisCycle.expiry)
            ),
            WorldCycleDisplay(
                id: "cambion",
                title: Strings.WorldState.cambionCycle,
                state: worldState.cambionCycle.state.capitalized,
                timeLeft: worldState.cambionCycle.timeLeft
            ),
            WorldCycleDisplay(
                id: "zariman",
                title: Strings.WorldState.zarimanCycle,
                state: worldState.zarimanCycle.isCorpus ? Strings.WorldState.cycleCorpus : Strings.WorldState.cycleGrineer,
                timeLeft: worldState.zarimanCycle.timeLeft
            ),
            WorldCycleDisplay(
                id: "earth",
                title: Strings.WorldState.earthCycle,
                state: worldState.earthCycle.isDay ? Strings.WorldState.cycleDay : Strings.WorldState.cycleNight,
                timeLeft: worldState.earthCycle.timeLeft
            )
        ]
    }

    var invasions: [Invasion] {
        (worldState?.invasions ?? []).sorted { $0.node < $1.node }
    }

    var fissures: [Fissure] {
        (worldState?.fissures ?? []).sorted { ($0.expiry ?? .distantFuture) < ($1.expiry ?? .distantFuture) }
    }

    // MARK: - Init
    init(worldStateRepository: WorldStateRepository, errorManager: ErrorManager) {
        self.worldStateRepository = worldStateRepository
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func fetchWorldState() async {
        defer {
            isLoading = false
        }
        isLoading = true

        do {
            worldState = try await worldStateRepository.getWorldState()
        } catch {
            errorManager.append(error)
        }
    }

    // MARK: - Helper Functions
    private static func timeLeft(until date: Date?) -> String {
        date?.timeLeftDescription ?? ""
    }
}
