//
//  ProfileRepositoryTests.swift
//  TennoWatchTests
//

import Testing
import Foundation
import SwiftData
@testable import TennoWatch

// MARK: - Assemble

private final class StubAPIService: ServiceProtocol {
    enum StubError: Error, Equatable { case sentinel }

    private(set) var fetchCount = 0
    private(set) var lastEndpoint: Endpoint?
    var result: Result<Any, Error> = .failure(StubError.sentinel)

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        fetchCount += 1
        lastEndpoint = endpoint
        switch result {
        case .success(let value):
            guard let typed = value as? T else {
                fatalError("StubAPIService result type mismatch")
            }
            return typed
        case .failure(let error):
            throw error
        }
    }
}

// `PersistencyService` now requires `Sendable` (see PersistencyService.swift), so any
// conformer has to state a Sendable story. This stub genuinely isn't thread-safe — its
// `var` properties are mutated with no synchronization — but it's also never shared
// across a concurrency domain: each test constructs its own instance and only touches it
// within that one test's sequential `await` chain. `@unchecked Sendable` is the honest
// way to say "the compiler can't verify this, but the usage pattern makes it safe" rather
// than restructuring a test double into an actor for no real benefit.
private final class StubPersistencyService: PersistencyService, @unchecked Sendable {
    var storedProfiles: [Profile] = []
    private(set) var savedProfiles: [Profile] = []

    func fetchModel<T: ValueTypeConvertible>(by type: T.Type, with descriptor: FetchDescriptor<T>) async throws -> [T.Value] {
        guard let result = storedProfiles as? [T.Value] else {
            fatalError("StubPersistencyService only supports fetching Profile")
        }
        return result
    }

    func saveValues<T: PersistentModelConvertible>(_ values: [T]) async throws {}

    func saveValue<T: PersistentModelConvertible>(_ value: T) async throws {
        if let profile = value as? Profile {
            savedProfiles.append(profile)
        }
    }

    func perform<T: Sendable>(_ operation: @Sendable (ModelContext) throws -> T) async throws -> T {
        fatalError("not exercised by these tests")
    }
}

@Suite("PersistentProfileRepository")
struct ProfileRepositoryTests {
    // MARK: - Teardown

    // MARK: - State Lifecycle

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

    @Test("forceRefresh == false with a profile last updated today returns the cached value and never calls the network")
    func freshCacheReturnsCachedProfileWithoutNetworkCall() async throws {
        let persistency = StubPersistencyService()
        persistency.storedProfiles = [.stub(accountID: "cached-id", lastUpdated: .now)]
        let service = StubAPIService()
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency)

        let result = try await sut.getProfile(withPlayerId: "different-id", forceRefresh: false)

        #expect(result.accountID.oid == "cached-id")
        #expect(service.fetchCount == 0)
    }

    @Test("A nil playerId falls back to the cached profile's accountID.oid instead of throwing")
    func nilPlayerIdFallsBackToCachedAccountID() async throws {
        let persistency = StubPersistencyService()
        let staleLastUpdated = try #require(Calendar.current.date(byAdding: .day, value: -1, to: .now))
        persistency.storedProfiles = [.stub(accountID: "cached-id", lastUpdated: staleLastUpdated)]
        let service = StubAPIService()
        service.result = .success(ProfileModel.stub(results: [.stub(accountID: "cached-id")]))
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency)

        _ = try await sut.getProfile(withPlayerId: nil, forceRefresh: false)

        guard case .profile(let playerId)? = service.lastEndpoint else {
            Issue.record("Expected a .profile endpoint")
            return
        }
        #expect(playerId == "cached-id")
    }

    @Test("A successful fetch persists the new profile via persistencyService.saveValue")
    func successfulFetchPersistsProfile() async throws {
        let persistency = StubPersistencyService()
        let service = StubAPIService()
        service.result = .success(ProfileModel.stub(results: [.stub(accountID: "fetched-id")]))
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency)

        let result = try await sut.getProfile(withPlayerId: "fetched-id", forceRefresh: false)

        #expect(result.accountID.oid == "fetched-id")
        #expect(persistency.savedProfiles.map(\.accountID.oid) == ["fetched-id"])
    }

    @Test("A successful fetch whose results array is empty throws .noPlayerId")
    func emptyResultsThrowsNoPlayerId() async {
        let persistency = StubPersistencyService()
        let service = StubAPIService()
        service.result = .success(ProfileModel.stub(results: []))
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency)

        do {
            _ = try await sut.getProfile(withPlayerId: "some-id", forceRefresh: false)
            Issue.record("Expected PersistentProfileRepository.ProfileError.noPlayerId to be thrown")
        } catch PersistentProfileRepository.ProfileError.noPlayerId {
            // expected
        } catch {
            Issue.record("Expected .noPlayerId, got \(error)")
        }
    }
}
