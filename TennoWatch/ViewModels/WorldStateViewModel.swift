//
//  WorldStateViewModel.swift
//  TennoWatch
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
    let expiry: Date?
}

struct InvasionPlanetGroup: Identifiable {
    let planet: String
    let invasions: [Invasion]
    var id: String { planet }
}

struct FissureTierGroup: Identifiable {
    let tier: String
    let fissures: [Fissure]
    var id: String { tier }
}

@Observable
final class WorldStateViewModel {
    // MARK: - Object Properties
    private let worldStateRepository: WorldStateRepository
    let errorManager: ErrorManager

    private static let fissureTierOrder = ["Lith", "Meso", "Neo", "Axi", "Requiem", "Omnia"]

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
                timeLeft: worldState.cetusCycle.timeLeft,
                expiry: worldState.cetusCycle.expiry
            ),
            WorldCycleDisplay(
                id: "vallis",
                title: Strings.WorldState.vallisCycle,
                state: worldState.vallisCycle.isWarm ? Strings.WorldState.cycleWarm : Strings.WorldState.cycleCold,
                timeLeft: Self.timeLeft(until: worldState.vallisCycle.expiry),
                expiry: worldState.vallisCycle.expiry
            ),
            WorldCycleDisplay(
                id: "cambion",
                title: Strings.WorldState.cambionCycle,
                state: worldState.cambionCycle.state.capitalized,
                timeLeft: worldState.cambionCycle.timeLeft,
                expiry: worldState.cambionCycle.expiry
            ),
            WorldCycleDisplay(
                id: "zariman",
                title: Strings.WorldState.zarimanCycle,
                state: worldState.zarimanCycle.isCorpus ? Strings.WorldState.cycleCorpus : Strings.WorldState.cycleGrineer,
                timeLeft: worldState.zarimanCycle.timeLeft,
                expiry: worldState.zarimanCycle.expiry
            ),
            WorldCycleDisplay(
                id: "earth",
                title: Strings.WorldState.earthCycle,
                state: worldState.earthCycle.isDay ? Strings.WorldState.cycleDay : Strings.WorldState.cycleNight,
                timeLeft: worldState.earthCycle.timeLeft,
                expiry: worldState.earthCycle.expiry
            )
        ]
    }

    var invasions: [Invasion] {
        (worldState?.invasions ?? []).sorted { $0.node < $1.node }
    }

    var fissures: [Fissure] {
        (worldState?.fissures ?? []).sorted { ($0.expiry ?? .distantFuture) < ($1.expiry ?? .distantFuture) }
    }

    var invasionsByPlanet: [InvasionPlanetGroup] {
        Dictionary(grouping: invasions) { $0.node.nodeNameAndPlanet.planet ?? $0.node }
            .map { InvasionPlanetGroup(planet: $0.key, invasions: $0.value) }
            .sorted { $0.planet < $1.planet }
    }

    var fissuresByTier: [FissureTierGroup] {
        Dictionary(grouping: fissures, by: \.tier)
            .map { FissureTierGroup(tier: $0.key, fissures: $0.value) }
            .sorted { lhs, rhs in
                let lhsOrder = Self.fissureTierOrder.firstIndex(of: lhs.tier) ?? Self.fissureTierOrder.count
                let rhsOrder = Self.fissureTierOrder.firstIndex(of: rhs.tier) ?? Self.fissureTierOrder.count
                return lhsOrder == rhsOrder ? lhs.tier < rhs.tier : lhsOrder < rhsOrder
            }
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
