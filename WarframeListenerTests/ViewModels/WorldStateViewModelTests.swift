//
//  WorldStateViewModelTests.swift
//  WarframeListenerTests
//

import Testing
@testable import WarframeListener

private final class StubWorldStateRepository: WorldStateRepository {
    enum StubError: Error, Equatable { case sentinel }

    var result: Result<WorldState, Error> = .failure(StubError.sentinel)

    func getWorldState(platform: Platform) async throws -> WorldState {
        try result.get()
    }
}

@Suite("WorldStateViewModel")
struct WorldStateViewModelTests {
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

    // TODO: - Test `cycles` maps each WorldState cycle (cetus/vallis/cambion/zariman/earth) to the expected title/state/timeLeft
    // TODO: - Test `invasions` is sorted by node, and `fissures` is sorted by expiry with nil treated as .distantFuture
    // TODO: - Test that `isLoading` is true while the fetch is in flight (drive the repository stub with a continuation you control instead of returning immediately)
}
