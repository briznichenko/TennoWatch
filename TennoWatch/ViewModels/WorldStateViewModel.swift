//
//  WorldStateViewModel.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation
import Observation
import Combine

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

// This class is MainActor-isolated implicitly, via this target's default actor isolation
// setting (Approachable Concurrency — see the project README), the same as most view
// models in this app. Compare `DefaultErrorManager`, which spells `@MainActor` out
// explicitly: both mean the same thing here. Explicit is only worth adding when a type's
// isolation wouldn't otherwise be obvious from where and how it's used.
@Observable
final class WorldStateViewModel {
    // MARK: - Object Properties
    private let worldStateRepository: WorldStateRepository
    let errorManager: ErrorManager

    private static let fissureTierOrder = ["Lith", "Meso", "Neo", "Axi", "Requiem", "Omnia"]

    private(set) var worldState: WorldState?
    private(set) var isLoading = false

    private var autoRefreshTask: Task<Void, Never>?
    // Coalesces overlapping calls to `fetchWorldState()` — see that function's doc
    // comment for why overlapping calls are possible at all.
    private var inFlightFetch: Task<Void, Never>?

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
        startAutoRefresh()
    }

    deinit {
        autoRefreshTask?.cancel()
        inFlightFetch?.cancel()
    }

    // MARK: - Functions

    // Re-entrancy: `WorldStateView` calls this from `.task` (first appearance),
    // `.refreshable` (pull-to-refresh), and now also from the auto-refresh timer below —
    // potentially all three within the same few seconds. Every call hits an `await`
    // inside `worldStateRepository.getWorldState()`, which is a suspension point: this
    // MainActor-isolated method can be re-entered while an earlier call is still
    // suspended there. MainActor isolation only guarantees that two calls never run their
    // synchronous portions *simultaneously* — it says nothing about a second call
    // starting before the first has finished. Swift 6 does not flag this: every property
    // access here is still correctly MainActor-isolated, so there's no data race for the
    // compiler to catch. What breaks is a *logic* race — two network requests in flight,
    // and whichever response lands second silently overwrites the other, regardless of
    // which one was actually requested more recently (a slow first request can clobber a
    // faster second one, after the second has already resolved). Coalescing into a single
    // in-flight Task fixes it: a second caller just awaits the first call's result instead
    // of starting a redundant fetch.
    func fetchWorldState() async {
        if let inFlightFetch {
            await inFlightFetch.value
            return
        }
        let task = Task { await self.performFetch() }
        inFlightFetch = task
        await task.value
        inFlightFetch = nil
    }

    // MARK: - Helper Functions
    private func performFetch() async {
        defer { isLoading = false }
        isLoading = true

        do {
            worldState = try await worldStateRepository.getWorldState()
        } catch {
            errorManager.append(error)
        }
    }

    // Combine is genuinely the right tool for *this* piece: a periodic tick is exactly
    // what `Timer.publish` + `.autoconnect()` is for, and if this ever grows into
    // "refresh on a timer, but also immediately when the app returns to foreground,
    // debounced so a flurry of both doesn't double-fire" — that's Combine's `.merge`/
    // `.debounce` vocabulary, not something worth hand-rolling with raw Tasks and sleeps.
    //
    // The bridge to AsyncStream exists because the *consumer* is Concurrency-native, not
    // Combine-native: `@Observable` classes aren't `ObservableObject`, so there's no
    // `@Published` property to `.sink` into and no natural place for a `Set<AnyCancellable>`
    // to live in idiomatic modern SwiftUI code. AsyncStream turns the publisher into
    // something a `for await` loop inside a plain `Task` can consume directly instead.
    private func startAutoRefresh() {
        let ticks = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .map { _ in () }

        let stream = AsyncStream<Void> { continuation in
            let cancellable = ticks.sink { _ in continuation.yield() }
            continuation.onTermination = { _ in cancellable.cancel() }
        }

        autoRefreshTask = Task { [weak self] in
            for await _ in stream {
                guard let self, !Task.isCancelled else { return }
                await self.fetchWorldState()
            }
        }
    }

    private static func timeLeft(until date: Date?) -> String {
        date?.timeLeftDescription ?? ""
    }
}
