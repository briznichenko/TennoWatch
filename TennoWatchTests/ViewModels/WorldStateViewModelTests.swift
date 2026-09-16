//
//  WorldStateViewModelTests.swift
//  TennoWatchTests
//

import Foundation
import Testing
@testable import TennoWatch

// MARK: - Assemble

private final class StubWorldStateRepository: WorldStateRepository {
    enum StubError: Error, Equatable { case sentinel }

    var result: Result<WorldState, Error> = .failure(StubError.sentinel)

    func getWorldState(platform: Platform) async throws -> WorldState {
        try result.get()
    }
}

private final class ControlledWorldStateRepository: WorldStateRepository {
    private var hasStartedRequest = false
    private var requestStartedContinuation: CheckedContinuation<Void, Never>?
    private var pendingContinuation: CheckedContinuation<WorldState, Error>?

    func getWorldState(platform: Platform) async throws -> WorldState {
        hasStartedRequest = true
        requestStartedContinuation?.resume()
        requestStartedContinuation = nil
        return try await withCheckedThrowingContinuation { continuation in
            pendingContinuation = continuation
        }
    }

    func waitForRequestToStart() async {
        if hasStartedRequest { return }
        await withCheckedContinuation { continuation in
            requestStartedContinuation = continuation
        }
    }

    func resume(with result: Result<WorldState, Error>) {
        pendingContinuation?.resume(with: result)
        pendingContinuation = nil
    }
}

@Suite("WorldStateViewModel")
struct WorldStateViewModelTests {
    // MARK: - Teardown

    // MARK: - State Lifecycle

    @Test("A successful fetch stores the world state and clears isLoading")
    func successfulFetchStoresWorldState() async {
        let repository = StubWorldStateRepository()
        repository.result = .success(.stub(invasions: [.stub(node: "Foo")]))
        let errorManager = DefaultErrorManager()
        let sut = WorldStateViewModel(worldStateRepository: repository, errorManager: errorManager)

        await sut.fetchWorldState()

        #expect(sut.worldState != nil)
        #expect(sut.isLoading == false)
        #expect(errorManager.errorQueue.isEmpty)
    }

    @Test("A failed fetch reports the error to errorManager and leaves worldState nil")
    func failedFetchReportsError() async {
        let repository = StubWorldStateRepository()
        repository.result = .failure(StubWorldStateRepository.StubError.sentinel)
        let errorManager = DefaultErrorManager()
        let sut = WorldStateViewModel(worldStateRepository: repository, errorManager: errorManager)

        await sut.fetchWorldState()

        #expect(sut.worldState == nil)
        #expect(sut.isLoading == false)
        #expect(errorManager.errorQueue.count == 1)
    }

    @Test("cycles maps each WorldState cycle to its expected title, state, and timeLeft")
    func cyclesMapsEachCycle() async throws {
        let vallisExpiry = Date.now.addingTimeInterval(3661)
        let worldState = WorldState.stub(
            cambionCycle: .stub(state: "fass", timeLeft: "10m"),
            cetusCycle: .stub(isDay: true, timeLeft: "1h 30m"),
            earthCycle: .stub(isDay: false, timeLeft: "45m"),
            vallisCycle: .stub(isWarm: false, expiry: vallisExpiry),
            zarimanCycle: .stub(isCorpus: false, timeLeft: "3h")
        )
        let repository = StubWorldStateRepository()
        repository.result = .success(worldState)
        let errorManager = DefaultErrorManager()
        let sut = WorldStateViewModel(worldStateRepository: repository, errorManager: errorManager)

        await sut.fetchWorldState()
        let cycles = sut.cycles

        #expect(cycles.count == 5)

        let cetus = try #require(cycles.first { $0.id == "cetus" })
        #expect(cetus.title == Strings.WorldState.cetusCycle)
        #expect(cetus.state == Strings.WorldState.cycleDay)
        #expect(cetus.timeLeft == "1h 30m")

        let vallis = try #require(cycles.first { $0.id == "vallis" })
        #expect(vallis.title == Strings.WorldState.vallisCycle)
        #expect(vallis.state == Strings.WorldState.cycleCold)
        #expect(vallis.timeLeft == vallisExpiry.timeLeftDescription)

        let cambion = try #require(cycles.first { $0.id == "cambion" })
        #expect(cambion.title == Strings.WorldState.cambionCycle)
        #expect(cambion.state == "Fass")
        #expect(cambion.timeLeft == "10m")

        let zariman = try #require(cycles.first { $0.id == "zariman" })
        #expect(zariman.title == Strings.WorldState.zarimanCycle)
        #expect(zariman.state == Strings.WorldState.cycleGrineer)
        #expect(zariman.timeLeft == "3h")

        let earth = try #require(cycles.first { $0.id == "earth" })
        #expect(earth.title == Strings.WorldState.earthCycle)
        #expect(earth.state == Strings.WorldState.cycleNight)
        #expect(earth.timeLeft == "45m")
    }

    @Test("invasions is sorted by node, and fissures is sorted by expiry with nil treated as .distantFuture")
    func invasionsAndFissuresAreSorted() async {
        let now = Date.now
        let worldState = WorldState.stub(
            invasions: [.stub(node: "Bravo"), .stub(node: "Alpha"), .stub(node: "Charlie")],
            fissures: [
                .stub(node: "Far", expiry: now.addingTimeInterval(3600)),
                .stub(node: "NoExpiry", expiry: nil),
                .stub(node: "Near", expiry: now.addingTimeInterval(60))
            ]
        )
        let repository = StubWorldStateRepository()
        repository.result = .success(worldState)
        let errorManager = DefaultErrorManager()
        let sut = WorldStateViewModel(worldStateRepository: repository, errorManager: errorManager)

        await sut.fetchWorldState()

        #expect(sut.invasions.map(\.node) == ["Alpha", "Bravo", "Charlie"])
        #expect(sut.fissures.map(\.node) == ["Near", "Far", "NoExpiry"])
    }

    @Test("isLoading is true while the fetch is in flight and false once it completes")
    func isLoadingReflectsInFlightFetch() async {
        let repository = ControlledWorldStateRepository()
        let errorManager = DefaultErrorManager()
        let sut = WorldStateViewModel(worldStateRepository: repository, errorManager: errorManager)

        let fetchTask = Task { await sut.fetchWorldState() }
        await repository.waitForRequestToStart()

        #expect(sut.isLoading == true)

        repository.resume(with: .success(.stub()))
        await fetchTask.value

        #expect(sut.isLoading == false)
    }
}
