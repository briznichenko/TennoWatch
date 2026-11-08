//
//  MasteryItemPersistenceTests.swift
//  TennoWatchTests
//
//  Created by Andrii Bryzhnychenko on 9/26/26.
//

import Foundation
import SwiftData
import Testing
@testable import TennoWatch

@MainActor
@Suite("Mastery item persistence")
struct MasteryItemPersistenceTests {
    @Test("Non-founder completion excludes founder XP without changing rank XP", arguments: [0, 9_000, 900_000])
    func founderXPIsSeparateFromCatalogCompletion(founderXP: Int) throws {
        let container = try ModelContainer(
            for: ProfileDataModel.self,
            MasteryCatalogDataModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        func item(obtainable: Bool, xp: Int) -> MasteryItemDataModel {
            let definition = CatalogItemModel.stub(maxRank: 30, pointsPerRank: 200, obtainable: obtainable)
            let profileItem = ProfileItemModel(
                equipTime: nil, headshots: nil, hits: nil, assists: nil, kills: nil,
                xp: xp, type: definition.uniqueName, fired: nil
            )
            return MasteryItemDataModel(profileItemModel: profileItem, catalogItemModel: definition)
        }
        let founder = item(obtainable: false, xp: founderXP)
        let regular = item(obtainable: true, xp: 900_000)
        let category = CatalogContainerModel(category: .suits, masteryItems: [founder, regular])
        category.partialPoints = founder.isMastered ? 0 : founder.value.earnedMasteryPoints
        let context = ModelContext(container)
        context.insert(category)
        try context.save()

        let summary = category.summary
        let expectedFounderPoints = founderXP == 0 ? 0 : (founderXP == 9_000 ? 600 : 6_000)
        #expect(summary.lockedEarnedMasteryPoints == expectedFounderPoints)
        #expect(summary.earnedMasteryPoints == 6_000 + expectedFounderPoints)
        #expect(summary.earnedMasteryPoints - summary.lockedEarnedMasteryPoints == 6_000)
        #expect(summary.excludingLockedItems().earnedMasteryPoints == summary.earnedMasteryPoints)
        #expect(summary.excludingLockedItems().lockedEarnedMasteryPoints == expectedFounderPoints)
    }

    @Test("AX-52 appears mastered in the category after syncing the bundled profile")
    func ax52IsMasteredAfterSync() async throws {
        let container = try ModelContainer(
            for: ProfileDataModel.self,
            MasteryCatalogDataModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let url = try #require(Bundle.main.url(forResource: "ProfileData", withExtension: "json"))
        let response = try JSONDecoder().decode(ProfileModel.self, from: Data(contentsOf: url))
        let result = try #require(response.results.first)
        let profile = Profile(
            accountID: result.accountID,
            displayName: result.displayName,
            playerLevel: result.playerLevel,
            items: response.stats.weapons,
            playerSkills: result.playerSkills,
            missions: result.missions,
            accountStats: .init(stats: response.stats),
            lastUpdated: .now
        )
        let persistency = DefaultPersistencyService(modelContainer: container)
        try await persistency.saveValue(profile)
        let cachedProfile = try #require(await persistency.fetchModel(by: ProfileDataModel.self).first)
        #expect(cachedProfile.items.contains { $0.type == "/Lotus/Weapons/Lasria/AK47/TC2024AK47Weapon" })
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        let accountStore = UserDefaultsAccountIDStore(defaults: defaults)
        accountStore.currentAccountID = profile.accountID.oid
        let repository = PersistentCatalogRepository(persistencyService: persistency, accountIDStore: accountStore)

        let summary = try await repository.syncMasterySummary(with: cachedProfile)
        let category = try await repository.getCatalogContainer(for: .longGuns)
        let item = try #require(category.masteryItems.first { $0.catalogItemModel.name == "AX-52" })
        let cachedAfterSync = try #require(await persistency.fetchModel(by: ProfileDataModel.self).first)

        #expect(summary.categories.first { $0.category == .longGuns }?.masteredItemsCount ?? 0 > 0)
        #expect(item.masteryState == .mastered)
        #expect(cachedAfterSync.items.contains { $0.type == item.catalogItemModel.uniqueName })
    }

    @Test("A mastered item remains mastered when read in a new context")
    func masteredItemSurvivesPersistence() throws {
        let container = try ModelContainer(
            for: ProfileDataModel.self,
            MasteryCatalogDataModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let catalogItem = CatalogItemModel.stub(uniqueName: "/Lotus/MasteredItem")
        let profileItem = ProfileItemModel(
            equipTime: nil, headshots: nil, hits: nil, assists: nil, kills: nil,
            xp: 25_000, type: catalogItem.uniqueName, fired: nil
        )
        let writeContext = ModelContext(container)
        let item = MasteryItemDataModel(profileItemModel: nil, catalogItemModel: catalogItem)
        writeContext.insert(Profile.stub(items: [profileItem]).model)
        writeContext.insert(item)
        item.set(profileItemModel: profileItem)
        try writeContext.save()

        writeContext.insert(Profile.stub(items: [profileItem]).model)
        try writeContext.save()

        let readContext = ModelContext(container)
        let savedItem = try #require(readContext.fetch(FetchDescriptor<MasteryItemDataModel>()).first)
        #expect(savedItem.isMastered)
        #expect(savedItem.value.masteryState == .mastered)
    }
}
