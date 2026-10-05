import Foundation
import SwiftData
import Testing
@testable import TennoWatch

private final class ProfileIsolationAPI: ServiceProtocol {
    var response = ProfileModel.stub()
    private(set) var fetchCount = 0

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        fetchCount += 1
        return try #require(response as? T)
    }
}

private final class ProfileIsolationAccountStore: AccountIDStoring {
    var currentAccountID: String?
}

private final class CountingCatalogSyncService: CatalogSyncService {
    private(set) var sourceMergeCount = 0
    private let service = DefaultCatalogSyncService()

    func mergeProfile(_ profile: Profile, into items: [MasteryItem]) -> [MasteryItem] {
        service.mergeProfile(profile, into: items)
    }

    func mergeProfile(_ profile: Profile, into sources: [MasterySourceModel]) -> [MasterySourceModel] {
        sourceMergeCount += 1
        return service.mergeProfile(profile, into: sources)
    }
}

private final class DelayedProfileAPI: ServiceProtocol {
    private var request: CheckedContinuation<ProfileModel, Error>?
    private var started: CheckedContinuation<Void, Never>?

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let response = try await withCheckedThrowingContinuation { continuation in
            request = continuation
            started?.resume()
            started = nil
        }
        return try #require(response as? T)
    }

    func waitForRequest() async {
        if request != nil { return }
        await withCheckedContinuation { started = $0 }
    }

    func complete(with response: ProfileModel) {
        request?.resume(returning: response)
        request = nil
    }
}

@Suite("Profile mastery isolation")
struct ProfileIsolationTests {
    private func makeRepositories() throws -> (
        DefaultPersistencyService, PersistentProfileRepository, PersistentCatalogRepository,
        ProfileIsolationAPI, ProfileIsolationAccountStore
    ) {
        let container = try ModelContainer(
            for: ProfileDataModel.self, MasteryCatalogDataModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let persistence = DefaultPersistencyService(modelContainer: container)
        let api = ProfileIsolationAPI()
        let accountStore = ProfileIsolationAccountStore()
        let catalog = PersistentCatalogRepository(persistencyService: persistence, accountIDStore: accountStore)
        let profiles = PersistentProfileRepository(
            profileService: api, persistencyService: persistence,
            accountIDStore: accountStore, catalogRepository: catalog
        )
        return (persistence, profiles, catalog, api, accountStore)
    }

    private func response(accountID: String, xp: Int, completed: Bool = false) -> ProfileModel {
        .stub(
            results: [.stub(
                accountID: accountID, displayName: "Same display name",
                playerSkills: ["RailjackIntrinsicPiloting": completed ? 10 : 0],
                missions: [.init(completes: completed ? 1 : 0, tier: completed ? 1 : nil, tag: "SolNode1")]
            )],
            stats: .stub(weapons: [item(xp: xp)])
        )
    }

    private func item(xp: Int) -> ProfileItemModel {
        .init(equipTime: nil, headshots: nil, hits: nil, assists: nil, kills: nil,
              xp: xp, type: "/Lotus/Weapons/Lasria/AK47/TC2024AK47Weapon", fired: nil)
    }

    private func ax52(in catalog: PersistentCatalogRepository) async throws -> MasteryItem {
        let items = try await catalog.getCatalogContainer(for: .longGuns)
        return try #require(items.masteryItems.first { $0.catalogItemModel.name == "AX-52" })
    }

    @Test("Two profiles with the same item, mission, skill, and display name keep separate progress")
    func overlappingProfilesStayIndependent() async throws {
        let (persistence, profiles, catalog, api, _) = try makeRepositories()
        api.response = response(accountID: "A", xp: 900_000, completed: true)
        _ = try await profiles.getProfile(withPlayerId: "A", forceRefresh: true)
        #expect(try await ax52(in: catalog).isMastered)
        api.response = response(accountID: "B", xp: 0)
        _ = try await profiles.getProfile(withPlayerId: "B", forceRefresh: true)
        #expect(try await ax52(in: catalog).rank == 0)
        _ = try await profiles.selectProfile(accountID: "A")
        #expect(try await ax52(in: catalog).isMastered)
        let saved = try await profiles.getSavedProfiles()
        #expect(saved.count == 2)
        #expect(saved.first { $0.accountID.oid == "A" }?.items.first?.xp == 900_000)
        #expect(saved.first { $0.accountID.oid == "B" }?.items.first?.xp == 0)
        #expect(saved.first { $0.accountID.oid == "A" }?.missions.first?.completes == 1)
        #expect(saved.first { $0.accountID.oid == "B" }?.missions.first?.completes == 0)
        let catalogCount = try await persistence.perform { context in
            try context.fetchCount(FetchDescriptor<MasteryCatalogDataModel>())
        }
        #expect(catalogCount == 2)
        let sourcesA = try await catalog.getMasterySources(named: .nodes)
        _ = try await profiles.selectProfile(accountID: "B")
        let sourcesB = try await catalog.getMasterySources(named: .nodes)
        #expect(sourcesA.sources.first { $0.uniqueName == "SolNode1" }?.isMastered == true)
        #expect(sourcesB.sources.first { $0.uniqueName == "SolNode1" }?.isMastered == false)
    }

    @Test("Refresh replaces profile data and category totals always equal the item rows")
    func refreshRecalculatesTotalsAndRemovesOldLinks() async throws {
        let (persistence, profiles, catalog, api, _) = try makeRepositories()
        for xp in [900_000, 10_000, 0, 900_000] {
            api.response = response(accountID: "A", xp: xp)
            _ = try await profiles.getProfile(withPlayerId: "A", forceRefresh: true)
            let summary = try await catalog.getMasterySummary()
            let category = try await catalog.getCatalogContainer(for: .longGuns)
            let row = try #require(summary.categories.first { $0.category == .longGuns })
            #expect(row.masteredItemsCount == category.masteryItems.filter(\.isMastered).count)
            #expect(row.earnedMasteryPoints == category.masteryItems.reduce(0) { $0 + $1.earnedMasteryPoints })
        }
        api.response = .stub(results: [.stub(accountID: "A")], stats: .stub(weapons: []))
        _ = try await profiles.getProfile(withPlayerId: "A", forceRefresh: true)
        #expect(try await ax52(in: catalog).profileItemModel == nil)
        #expect(try await catalog.getMasterySummary().categories.reduce(0) { $0 + $1.earnedMasteryPoints } == 0)
        let counts = try await persistence.perform { context in
            (try context.fetchCount(FetchDescriptor<ProfileDataModel>()),
             try context.fetchCount(FetchDescriptor<ProfileItemDataModel>()),
             try context.fetchCount(FetchDescriptor<AccountStatsDataModel>()))
        }
        #expect(counts.0 == 1)
        #expect(counts.1 == 0)
        #expect(counts.2 == 1)
    }

    @Test("Local UUID survives remote imports and can be selected without any network access")
    func manualProfileIsStableAndIndependent() async throws {
        let (_, profiles, catalog, api, _) = try makeRepositories()
        let local = try await profiles.getProfile()
        #expect(local.isLocal)
        #expect(UUID(uuidString: local.accountID.oid) != nil)
        api.response = response(accountID: "A", xp: 900_000)
        _ = try await profiles.getProfile(withPlayerId: "A", forceRefresh: true)
        _ = try await profiles.selectProfile(accountID: local.accountID.oid)
        let restored = try await profiles.getProfile(forceRefresh: true)
        #expect(restored.accountID == local.accountID)
        #expect(try await ax52(in: catalog).rank == 0)
        #expect(api.fetchCount == 1)
    }

    @Test("Deleting an active profile cascades its graph and preserves another profile's progress")
    func deleteProfilePreservesOtherGraph() async throws {
        let (persistence, profiles, catalog, api, store) = try makeRepositories()
        api.response = response(accountID: "A", xp: 900_000)
        _ = try await profiles.getProfile(withPlayerId: "A", forceRefresh: true)
        api.response = response(accountID: "B", xp: 0)
        _ = try await profiles.getProfile(withPlayerId: "B", forceRefresh: true)
        try await profiles.deleteProfile(accountID: "B")
        #expect(store.currentAccountID == "A")
        #expect(try await ax52(in: catalog).isMastered)
        let counts = try await persistence.perform { context in
            (try context.fetchCount(FetchDescriptor<MasteryCatalogDataModel>()),
             try context.fetchCount(FetchDescriptor<ProfileItemDataModel>()),
             try context.fetchCount(FetchDescriptor<ResultMissionDataModel>()),
             try context.fetchCount(FetchDescriptor<IntrinsicsDataModel>()))
        }
        #expect(counts.0 == 1)
        #expect(counts.1 == 1)
        #expect(counts.2 == 1)
        #expect(counts.3 == 1)
        try await profiles.deleteProfile(accountID: "A")
        let local = try await profiles.getProfile()
        #expect(local.isLocal)
        #expect(try await ax52(in: catalog).rank == 0)
    }

    @Test("A delayed request cannot reactivate a profile after the user selects another profile")
    func delayedRequestCannotChangeSelection() async throws {
        let (persistence, _, catalog, _, store) = try makeRepositories()
        let api = DelayedProfileAPI()
        let profiles = PersistentProfileRepository(
            profileService: api, persistencyService: persistence,
            accountIDStore: store, catalogRepository: catalog
        )
        let local = try await profiles.getProfile()
        let task = Task { try await profiles.getProfile(withPlayerId: "A", forceRefresh: true) }
        await api.waitForRequest()
        _ = try await profiles.selectProfile(accountID: local.accountID.oid)
        api.complete(with: response(accountID: "A", xp: 900_000))
        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(store.currentAccountID == local.accountID.oid)
        #expect(try await profiles.getSavedProfiles().count == 1)
        #expect(try await ax52(in: catalog).rank == 0)
    }

    @Test("An unowned legacy catalog is rebuilt from the selected profile")
    func legacyCatalogIsRebuilt() async throws {
        let (persistence, profiles, catalog, _, _) = try makeRepositories()
        try await persistence.saveValue(Profile.stub(accountID: "A", items: [item(xp: 900_000)]))
        try await persistence.saveValue(MasteryCatalog.stub())
        _ = try await profiles.selectProfile(accountID: "A")
        #expect(try await ax52(in: catalog).isMastered)
        let counts = try await persistence.perform { context in
            let catalogs = try context.fetch(FetchDescriptor<MasteryCatalogDataModel>())
            return (catalogs.count, catalogs.filter { $0.profile == nil }.count)
        }
        #expect(counts.0 == 1)
        #expect(counts.1 == 0)
        let saved = try await profiles.getSavedProfiles()
        #expect(saved.first?.lastUpdated == .distantPast)
    }

    @Test("Cached profile loads and catalog navigation reuse the synchronized graph")
    func unchangedReadsDoNotMergeAgain() async throws {
        let (persistence, _, _, api, store) = try makeRepositories()
        let sync = CountingCatalogSyncService()
        let catalog = PersistentCatalogRepository(
            persistencyService: persistence, catalogSyncService: sync, accountIDStore: store
        )
        let profiles = PersistentProfileRepository(
            profileService: api, persistencyService: persistence,
            accountIDStore: store, catalogRepository: catalog
        )
        api.response = response(accountID: "A", xp: 900_000, completed: true)
        _ = try await profiles.getProfile(withPlayerId: "A", forceRefresh: true)
        let initialMergeCount = sync.sourceMergeCount
        #expect(initialMergeCount > 0)

        _ = try await profiles.getProfile()
        _ = try await profiles.selectProfile(accountID: "A")
        _ = try await catalog.getMasterySummary()
        _ = try await catalog.getMasteryCatalog()
        #expect(try await ax52(in: catalog).isMastered)
        let sources = try await catalog.getMasterySourceCategories()
        #expect(Set(sources.map(\.name)) == Set(["nodes", "intrinsics", "junctions"]))
        #expect(sync.sourceMergeCount == initialMergeCount)
        #expect(api.fetchCount == 1)
        let hasChanges = try await persistence.perform { $0.hasChanges }
        #expect(!hasChanges)

        api.response = response(accountID: "A", xp: 0)
        _ = try await profiles.getProfile(forceRefresh: true)
        #expect(sync.sourceMergeCount == initialMergeCount * 2)
        #expect(try await ax52(in: catalog).rank == 0)
    }

    @Test("A catalog read recovers a profile update that has not been synchronized yet")
    func changedProfileInvalidatesCatalog() async throws {
        let (persistence, profiles, _, api, store) = try makeRepositories()
        api.response = response(accountID: "A", xp: 900_000)
        _ = try await profiles.getProfile(withPlayerId: "A", forceRefresh: true)
        let context = ModelContext(persistence.modelContainer)
        let profile = try PersistentProfileRepository.resolveProfile(in: context, accountID: "A")
        profile.items.first?.xp = 0
        profile.lastUpdated = profile.lastUpdated.addingTimeInterval(1)
        try context.save()
        let catalog = PersistentCatalogRepository(
            persistencyService: DefaultPersistencyService(modelContainer: persistence.modelContainer),
            accountIDStore: store
        )
        #expect(try await ax52(in: catalog).rank == 0)
        let summary = try await catalog.getMasterySummary()
        #expect(summary.categories.first { $0.category == .longGuns }?.earnedMasteryPoints == 0)
    }

    @Test("An outdated owned catalog is rebuilt and synchronized on read")
    func outdatedCatalogIsRebuilt() async throws {
        let (persistence, profiles, _, api, store) = try makeRepositories()
        api.response = response(accountID: "A", xp: 900_000, completed: true)
        _ = try await profiles.getProfile(withPlayerId: "A", forceRefresh: true)
        let context = ModelContext(persistence.modelContainer)
        let profile = try PersistentProfileRepository.resolveProfile(in: context, accountID: "A")
        profile.masteryCatalog?.schemaVersion = -1
        try context.save()
        let catalog = PersistentCatalogRepository(
            persistencyService: DefaultPersistencyService(modelContainer: persistence.modelContainer),
            accountIDStore: store
        )
        #expect(try await ax52(in: catalog).isMastered)
        let counts = try await persistence.perform { context in
            (try context.fetchCount(FetchDescriptor<MasteryCatalogDataModel>()),
             try context.fetchCount(FetchDescriptor<ProfileDataModel>()))
        }
        #expect(counts.0 == 1)
        #expect(counts.1 == 1)
    }
}
