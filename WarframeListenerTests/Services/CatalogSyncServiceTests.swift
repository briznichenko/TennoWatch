//
//  CatalogSyncServiceTests.swift
//  WarframeListenerTests
//

import Testing
@testable import WarframeListener

@Suite("DefaultCatalogSyncService")
struct CatalogSyncServiceTests {
    // MARK: - Assemble

    private let sut = DefaultCatalogSyncService()

    // MARK: - Teardown

    // MARK: - State Lifecycle

    @Test("A steel-path source is mastered when the base mission has a steel path tier")
    func steelPathSourceIsMasteredFromBaseTier() {
        let source = MasterySourceModel(uniqueName: "/Lotus/Mission#steelPath", name: "Steel Path Mission", mastery: 1, isMastered: nil)
        let profile = Profile.stub(missions: [.init(completes: 1, tier: 2, tag: "/Lotus/Mission")])

        let synced = sut.mergeProfile(profile, into: [source])

        #expect(synced.first?.isMastered == true)
    }

    @Test("A regular mission source is mastered once it has at least one completion")
    func missionSourceIsMasteredAfterFirstCompletion() {
        let source = MasterySourceModel(uniqueName: "/Lotus/Mission", name: "Mission", mastery: 1, isMastered: nil)
        let profile = Profile.stub(missions: [.init(completes: 1, tier: nil, tag: "/Lotus/Mission")])

        let synced = sut.mergeProfile(profile, into: [source])

        #expect(synced.first?.isMastered == true)
    }

    @Test("A playerSkills source is mastered once its intrinsic rank reaches maxIntrinsicLevel (10), and not before")
    func playerSkillsSourceIsMasteredAtMaxLevel() {
        let source = MasterySourceModel(uniqueName: "SKILL_INTRINSIC_TACTIC", name: "Tactic", mastery: 1, isMastered: nil)
        let belowMaxProfile = Profile.stub(playerSkills: ["SKILL_INTRINSIC_TACTIC": 9])
        let atMaxProfile = Profile.stub(playerSkills: ["SKILL_INTRINSIC_TACTIC": 10])

        let belowMax = sut.mergeProfile(belowMaxProfile, into: [source])
        let atMax = sut.mergeProfile(atMaxProfile, into: [source])

        #expect(belowMax.first?.isMastered == false)
        #expect(atMax.first?.isMastered == true)
    }

    @Test("A uniqueName matching nothing (no mission, no skill) resolves to isMastered == false")
    func unmatchedSourceIsNotMastered() {
        let source = MasterySourceModel(uniqueName: "/Lotus/Unknown", name: "Unknown", mastery: 1, isMastered: nil)
        let profile = Profile.stub()

        let synced = sut.mergeProfile(profile, into: [source])

        #expect(synced.first?.isMastered == false)
    }

    @Test("mergeProfile attaches a profile item to the matching mastery item by type (catalogItemModel.uniqueName)")
    func mergeProfileAttachesMatchingProfileItemByType() {
        let matchedProfileItem = ProfileItemModel(
            equipTime: nil, headshots: nil, hits: nil, assists: nil, kills: nil,
            xp: 500, type: "/Lotus/MatchedItem", fired: nil
        )
        let matchedItem = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(uniqueName: "/Lotus/MatchedItem"))
        let unmatchedItem = MasteryItem(profileItemModel: nil, catalogItemModel: .stub(uniqueName: "/Lotus/OtherItem"))
        let profile = Profile.stub(items: [matchedProfileItem])

        let merged = sut.mergeProfile(profile, into: [matchedItem, unmatchedItem])

        let mergedMatched = merged.first { $0.catalogItemModel.uniqueName == "/Lotus/MatchedItem" }
        let mergedUnmatched = merged.first { $0.catalogItemModel.uniqueName == "/Lotus/OtherItem" }
        #expect(mergedMatched?.profileItemModel?.xp == 500)
        #expect(mergedUnmatched?.profileItemModel == nil)
    }
}
