import SwiftData
import Testing
@testable import TennoWatch

@Suite("Cache clearing")
struct CacheClearingTests {
    @Test("Clear removes profile, related records, and catalog")
    func clearsAllStoredModels() async throws {
        let container = try ModelContainer(
            for: ProfileDataModel.self,
            MasteryCatalogDataModel.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let service = DefaultPersistencyService(modelContainer: container)
        try await service.saveValue(Profile.stub(
            items: [.stub],
            playerSkills: ["Piloting": 2],
            missions: [.init(completes: 1, tier: nil, tag: "test-mission")]
        ))
        try await service.saveValue(MasteryCatalog.stub(
            items: [.init(
                category: .suits,
                masteryItems: [.init(profileItemModel: nil, catalogItemModel: .stub())]
            )],
            nonItemSources: [.init(name: "test-category", sources: [])]
        ))
        try await service.perform { context in
            context.insert(MasterySourceDataModel(uniqueName: "test-source", name: "Test", mastery: 1, isMastered: false))
            try context.save()
        }

        try await service.clearAllData()

        let isEmpty = try await service.perform { context in
            try context.fetchCount(FetchDescriptor<ProfileDataModel>()) == 0
                && context.fetchCount(FetchDescriptor<AccountStatsDataModel>()) == 0
                && context.fetchCount(FetchDescriptor<ProfileItemDataModel>()) == 0
                && context.fetchCount(FetchDescriptor<ResultMissionDataModel>()) == 0
                && context.fetchCount(FetchDescriptor<IntrinsicsDataModel>()) == 0
                && context.fetchCount(FetchDescriptor<MasteryCatalogDataModel>()) == 0
                && context.fetchCount(FetchDescriptor<CatalogContainerModel>()) == 0
                && context.fetchCount(FetchDescriptor<MasteryItemDataModel>()) == 0
                && context.fetchCount(FetchDescriptor<CatalogItemDataModel>()) == 0
                && context.fetchCount(FetchDescriptor<MasteryCategoryDataModel>()) == 0
                && context.fetchCount(FetchDescriptor<MasterySourceDataModel>()) == 0
        }
        #expect(isEmpty)
    }
}
