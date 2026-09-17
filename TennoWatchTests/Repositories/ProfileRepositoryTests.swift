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

private final class StubPersistencyService: PersistencyService {
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

private final class StubAccountIDStore: AccountIDStoring {
    var currentAccountID: String?
}

@Suite("PersistentProfileRepository")
struct ProfileRepositoryTests {
    // MARK: - Teardown

    // MARK: - State Lifecycle

    @Test("forceRefresh reaches the network even though a fresh cached profile exists")
    func forceRefreshBypassesFreshCache() async {
        let persistency = StubPersistencyService()
        persistency.storedProfiles = [.stub(accountID: "already-known-id", lastUpdated: .now)]
        let service = StubAPIService()
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency, accountIDStore: StubAccountIDStore())

        await #expect(throws: StubAPIService.StubError.sentinel) {
            try await sut.getProfile(withPlayerId: "already-known-id", forceRefresh: true)
        }
        #expect(service.fetchCount == 1)
    }

    @Test("No playerId and no cached profile throws .noPlayerId before touching the network")
    func missingPlayerIdThrowsWithoutNetworkCall() async {
        let persistency = StubPersistencyService()
        let service = StubAPIService()
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency, accountIDStore: StubAccountIDStore())

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

    @Test("forceRefresh == false with the requested account's profile last updated today returns the cached value and never calls the network")
    func freshCacheReturnsCachedProfileWithoutNetworkCall() async throws {
        let persistency = StubPersistencyService()
        persistency.storedProfiles = [.stub(accountID: "cached-id", lastUpdated: .now)]
        let service = StubAPIService()
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency, accountIDStore: StubAccountIDStore())

        let result = try await sut.getProfile(withPlayerId: "cached-id", forceRefresh: false)

        #expect(result.accountID.oid == "cached-id")
        #expect(service.fetchCount == 0)
    }

    @Test("Requesting a different account than the one cached ignores the stale cache and fetches that account instead")
    func differentPlayerIdIgnoresOtherAccountsCache() async throws {
        let persistency = StubPersistencyService()
        persistency.storedProfiles = [.stub(accountID: "cached-id", lastUpdated: .now)]
        let service = StubAPIService()
        service.result = .success(ProfileModel.stub(results: [.stub(accountID: "different-id")]))
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency, accountIDStore: StubAccountIDStore())

        let result = try await sut.getProfile(withPlayerId: "different-id", forceRefresh: false)

        #expect(result.accountID.oid == "different-id")
        #expect(service.fetchCount == 1)
        guard case .profile(let playerId)? = service.lastEndpoint else {
            Issue.record("Expected a .profile endpoint")
            return
        }
        #expect(playerId == "different-id")
    }

    @Test("A nil playerId falls back to the cached profile's accountID.oid instead of throwing")
    func nilPlayerIdFallsBackToCachedAccountID() async throws {
        let persistency = StubPersistencyService()
        let staleLastUpdated = try #require(Calendar.current.date(byAdding: .day, value: -1, to: .now))
        persistency.storedProfiles = [.stub(accountID: "cached-id", lastUpdated: staleLastUpdated)]
        let service = StubAPIService()
        service.result = .success(ProfileModel.stub(results: [.stub(accountID: "cached-id")]))
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency, accountIDStore: StubAccountIDStore())

        _ = try await sut.getProfile(withPlayerId: nil, forceRefresh: false)

        guard case .profile(let playerId)? = service.lastEndpoint else {
            Issue.record("Expected a .profile endpoint")
            return
        }
        #expect(playerId == "cached-id")
    }

    @Test("A nil playerId falls back to the account ID store's current account instead of an unrelated stored profile")
    func nilPlayerIdFallsBackToAccountIDStore() async throws {
        let persistency = StubPersistencyService()
        persistency.storedProfiles = [
            .stub(accountID: "other-id", lastUpdated: .now),
            .stub(accountID: "current-id", lastUpdated: .now)
        ]
        let service = StubAPIService()
        let accountIDStore = StubAccountIDStore()
        accountIDStore.currentAccountID = "current-id"
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency, accountIDStore: accountIDStore)

        let result = try await sut.getProfile(withPlayerId: nil, forceRefresh: false)

        #expect(result.accountID.oid == "current-id")
        #expect(service.fetchCount == 0)
    }

    @Test("A successful fetch persists the new profile via persistencyService.saveValue and remembers it as the current account")
    func successfulFetchPersistsProfile() async throws {
        let persistency = StubPersistencyService()
        let service = StubAPIService()
        service.result = .success(ProfileModel.stub(results: [.stub(accountID: "fetched-id")]))
        let accountIDStore = StubAccountIDStore()
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency, accountIDStore: accountIDStore)

        let result = try await sut.getProfile(withPlayerId: "fetched-id", forceRefresh: false)

        #expect(result.accountID.oid == "fetched-id")
        #expect(persistency.savedProfiles.map(\.accountID.oid) == ["fetched-id"])
        #expect(accountIDStore.currentAccountID == "fetched-id")
    }

    @Test("A successful fetch whose results array is empty throws .noPlayerId")
    func emptyResultsThrowsNoPlayerId() async {
        let persistency = StubPersistencyService()
        let service = StubAPIService()
        service.result = .success(ProfileModel.stub(results: []))
        let sut = PersistentProfileRepository(profileService: service, persistencyService: persistency, accountIDStore: StubAccountIDStore())

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
