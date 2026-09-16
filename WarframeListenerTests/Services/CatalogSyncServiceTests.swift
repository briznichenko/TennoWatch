//
//  CatalogSyncServiceTests.swift
//  WarframeListenerTests
//

import Testing
@testable import WarframeListener

@Suite("DefaultCatalogSyncService")
struct CatalogSyncServiceTests {
    private let sut = DefaultCatalogSyncService()

    @Test("A steel-path source is mastered when the base mission has a steel path tier")
    func steelPathSourceIsMasteredFromBaseTier() {
        let category = MasteryCategoryModel(
            name: "Intrinsics",
            sources: [.init(uniqueName: "/Lotus/Mission#steelPath", name: "Steel Path Mission", mastery: 1, isMastered: nil)]
        )
        let profile = Profile.stub(missions: [.init(completes: 1, tier: 2, tag: "/Lotus/Mission")])
        let catalog = MasteryCatalog.stub(nonItemSources: [category])

        let synced = sut.syncNonItemSources(with: profile, against: catalog)

        #expect(synced.first?.sources.first?.isMastered == true)
    }

    @Test("A regular mission source is mastered once it has at least one completion")
    func missionSourceIsMasteredAfterFirstCompletion() {
        let category = MasteryCategoryModel(
            name: "Intrinsics",
            sources: [.init(uniqueName: "/Lotus/Mission", name: "Mission", mastery: 1, isMastered: nil)]
        )
        let profile = Profile.stub(missions: [.init(completes: 1, tier: nil, tag: "/Lotus/Mission")])
        let catalog = MasteryCatalog.stub(nonItemSources: [category])

        let synced = sut.syncNonItemSources(with: profile, against: catalog)

        #expect(synced.first?.sources.first?.isMastered == true)
    }

    // TODO: - Test the playerSkills branch: a source is mastered once its intrinsic rank reaches maxIntrinsicLevel (10), and not before
    // TODO: - Test that a uniqueName matching nothing (no mission, no skill) resolves to isMastered == false
    // TODO: - Test syncCatalogs: a profile item is attached to the matching mastery item by `type`, and items are sorted by name
    // TODO: - Test syncNonItemSources sorts sources by name within each category
}
