//
//  ProfileRepositoryTests.swift
//  WarframeListenerTests
//

import Testing
import Foundation
import SwiftData
@testable import WarframeListener

private final class StubAPIService: ServiceProtocol {
    enum StubError: Error, Equatable { case sentinel }

    private(set) var fetchCount = 0

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        fetchCount += 1
        throw StubError.sentinel
    }
}

private final class StubPersistencyService: PersistencyService {
    var storedProfiles: [Profile] = []

    func fetchModel<T: ValueTypeConvertible>(by type: T.Type, with descriptor: FetchDescriptor<T>) async throws -> [T.Value] {
        storedProfiles as! [T.Value]
    }

    func saveValues<T: PersistentModelConvertible>(_ values: [T]) async throws {}

    func saveValue<T: PersistentModelConvertible>(_ value: T) async throws {}

    func perform<T: Sendable>(_ operation: @Sendable (ModelContext) throws -> T) async throws -> T {
        fatalError("not exercised by these tests")
    }
}

@Suite("PersistentProfileRepository")
struct ProfileRepositoryTests {
    @Test("forceRefresh reaches the network even though a fresh cached profile exists")
    func forceRefreshBypassesFreshCache() async {
        let persistency = StubPersistencyService()
        persistency.storedProfiles = [.stub(lastUpdated: .now)]
        let service = StubAPIService()
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency)

        await #expect(throws: StubAPIService.StubError.sentinel) {
            try await sut.getProfile(withPlayerId: "already-known-id", forceRefresh: true)
        }
        #expect(service.fetchCount == 1)
    }

    @Test("No playerId and no cached profile throws .noPlayerId before touching the network")
    func missingPlayerIdThrowsWithoutNetworkCall() async {
        let persistency = StubPersistencyService()
        let service = StubAPIService()
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency)

        do {
            _ = try await sut.getProfile(withPlayerId: nil, forceRefresh: false)
            Issue.record("Expected PersistentProfileRepository.ProfileError.noPlayerId to be thrown")
        } catch PersistentProfileRepository.ProfileError.noPlayerId {
            // expected
        } catch {
            Issue.record("Expected .noPlayerId, got \(error)")
        }
        #expect(service.fetchCount == 0)
    }

    // TODO: - Test the cache-hit path: forceRefresh == false + a profile last updated today + syncPolicy == .daily returns the cached value and never calls the network
    // TODO: - Test that a nil playerId falls back to the cached profile's accountID.oid instead of throwing
    // TODO: - Test that a successful fetch persists the new profile via persistencyService.saveValue
    // TODO: - Test that a successful fetch whose `results` array is empty throws .noPlayerId (confirm this is the intended error for that case, since the name reads oddly here)
}
