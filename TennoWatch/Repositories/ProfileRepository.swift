//
//  ProfileRepository.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/2/26.
//

import Foundation
import SwiftData

protocol ProfileRepository {
    var syncPolicy: SyncPolicy { get }
    var currentAccountID: String? { get }
    func getProfile(withPlayerId playerId: String?, forceRefresh: Bool) async throws -> Profile
    func getSavedProfiles() async throws -> [Profile]
    func selectProfile(accountID: String) async throws -> Profile
    func deleteProfile(accountID: String) async throws
    func createLocalProfile() async throws -> Profile
}

extension ProfileRepository {
    func getProfile(withPlayerId playerId: String? = nil, forceRefresh: Bool = false) async throws -> Profile {
        try await getProfile(withPlayerId: playerId, forceRefresh: forceRefresh)
    }
}

final class PersistentProfileRepository: ProfileRepository {
    enum ProfileError: Error {
        case noData, noPlayerId
    }

    var currentAccountID: String? { accountIDStore.currentAccountID }
    let syncPolicy: SyncPolicy = .daily
    private let profileService: ServiceProtocol
    private let persistencyService: PersistencyService
    private let accountIDStore: AccountIDStoring
    private let catalogRepository: CatalogRepository
    private var selectionRevision = 0

    init(
        profileService: ServiceProtocol = APIManager(),
        persistencyService: PersistencyService,
        accountIDStore: AccountIDStoring = UserDefaultsAccountIDStore(),
        catalogRepository: CatalogRepository? = nil
    ) {
        self.profileService = profileService
        self.persistencyService = persistencyService
        self.accountIDStore = accountIDStore
        self.catalogRepository = catalogRepository ?? PersistentCatalogRepository(
            persistencyService: persistencyService, accountIDStore: accountIDStore
        )
    }

    func getProfile(withPlayerId playerId: String?, forceRefresh: Bool) async throws -> Profile {
        if playerId != nil { selectionRevision += 1 }
        let revision = selectionRevision
        let initialID = accountIDStore.currentAccountID
        let profiles = try await getSavedProfiles()
        let targetID = playerId ?? initialID ?? profiles.first(where: { !$0.isLocal })?.accountID.oid
        let cached = profiles.first { $0.accountID.oid == targetID }
        let profile: Profile
        var didRefresh = false
        if targetID == nil {
            profile = try await persistencyService.perform { context in
                let local = try Self.resolveProfile(in: context, accountID: nil)
                try context.save()
                return local.value
            }
        } else if let cached, cached.isLocal || (!forceRefresh && Calendar.current.isDateInToday(cached.lastUpdated)) {
            profile = cached
        } else {
            guard let targetID, !targetID.isEmpty else { throw ProfileError.noPlayerId }
            let response: ProfileModel = try await profileService.fetch(.profile(playerId: targetID))
            guard let result = response.results.first else { throw ProfileError.noPlayerId }
            try Task.checkCancellation()
            guard revision == selectionRevision, accountIDStore.currentAccountID == initialID else {
                throw CancellationError()
            }
            profile = Profile(
                accountID: result.accountID, displayName: result.displayName,
                playerLevel: result.playerLevel, items: response.stats.weapons,
                playerSkills: result.playerSkills, missions: result.missions,
                accountStats: .init(stats: response.stats), lastUpdated: .now
            )
            try await persistencyService.perform { context in
                do {
                    try Self.upsert(profile, in: context)
                    try context.save()
                } catch {
                    context.rollback()
                    throw error
                }
            }
            didRefresh = true
        }
        if didRefresh {
            _ = try await catalogRepository.syncMasterySummary(with: profile)
        } else {
            try await catalogRepository.prepareCatalog(for: profile)
        }
        try Task.checkCancellation()
        guard revision == selectionRevision, accountIDStore.currentAccountID == initialID else {
            throw CancellationError()
        }
        accountIDStore.currentAccountID = profile.accountID.oid
        return profile
    }

    func getSavedProfiles() async throws -> [Profile] {
        try await persistencyService.fetchModel(by: ProfileDataModel.self)
            .sorted {
                if $0.isLocal != $1.isLocal { return $0.isLocal }
                return $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
            }
    }

    func selectProfile(accountID: String) async throws -> Profile {
        selectionRevision += 1
        let revision = selectionRevision
        let profile = try await persistencyService.perform { context in
            try Self.resolveProfile(in: context, accountID: accountID).value
        }
        try await catalogRepository.prepareCatalog(for: profile)
        try Task.checkCancellation()
        guard revision == selectionRevision else { throw CancellationError() }
        accountIDStore.currentAccountID = accountID
        return profile
    }

    func createLocalProfile() async throws -> Profile {
        let accountID = try await persistencyService.perform { context in
            let profiles = try context.fetch(FetchDescriptor<ProfileDataModel>())
            let profile = try profiles.first(where: { $0.isLocal }) ?? Self.makeLocalProfile(in: context)
            try context.save()
            return profile.accountID
        }
        return try await selectProfile(accountID: accountID)
    }

    func deleteProfile(accountID: String) async throws {
        selectionRevision += 1
        let initialID = accountIDStore.currentAccountID
        let fallbackID = try await persistencyService.perform { context in
            do {
                let descriptor = FetchDescriptor<ProfileDataModel>(predicate: #Predicate { $0.accountID == accountID })
                if let profile = try context.fetch(descriptor).first {
                    context.delete(profile)
                }
                try context.save()
                let remaining = try context.fetch(FetchDescriptor<ProfileDataModel>())
                let fallback = remaining.first(where: { $0.isLocal }) ?? remaining.sorted { $0.accountID < $1.accountID }.first
                let selected = try fallback ?? Self.makeLocalProfile(in: context)
                try context.save()
                return selected.accountID
            } catch {
                context.rollback()
                throw error
            }
        }
        if initialID == accountID, accountIDStore.currentAccountID == initialID {
            accountIDStore.currentAccountID = fallbackID
        }
    }

    static func resolveProfile(in context: ModelContext, accountID: String?) throws -> ProfileDataModel {
        if let accountID {
            let descriptor = FetchDescriptor<ProfileDataModel>(predicate: #Predicate { $0.accountID == accountID })
            guard let profile = try context.fetch(descriptor).first else { throw ProfileError.noData }
            return profile
        }
        let profiles = try context.fetch(FetchDescriptor<ProfileDataModel>())
        if let profile = profiles.sorted(by: { $0.accountID < $1.accountID }).first(where: { !$0.isLocal }) {
            return profile
        }
        return try profiles.first(where: { $0.isLocal }) ?? makeLocalProfile(in: context)
    }

    private static func makeLocalProfile(in context: ModelContext) throws -> ProfileDataModel {
        let profile = Profile(
            accountID: .init(oid: UUID().uuidString), displayName: "", playerLevel: 0,
            items: [], playerSkills: [:], missions: [], accountStats: .empty,
            lastUpdated: .now, isLocal: true
        ).model
        context.insert(profile)
        return profile
    }

    private static func upsert(_ value: Profile, in context: ModelContext) throws {
        let accountID = value.accountID.oid
        let descriptor = FetchDescriptor<ProfileDataModel>(predicate: #Predicate { $0.accountID == accountID })
        let profile: ProfileDataModel
        if let existing = try context.fetch(descriptor).first {
            profile = existing
            for item in profile.items { context.delete(item) }
            for skill in profile.playerSkills { context.delete(skill) }
            for mission in profile.missions { context.delete(mission) }
            Self.apply(value.accountStats, to: profile.accountStats)
            profile.displayName = value.displayName
            profile.playerLevel = value.playerLevel
            profile.lastUpdated = value.lastUpdated
        } else {
            profile = ProfileDataModel(
                accountID: accountID, displayName: value.displayName, playerLevel: value.playerLevel,
                items: [], playerSkills: [], missions: [], accountStats: value.accountStats.model,
                lastUpdated: value.lastUpdated
            )
            context.insert(profile)
        }
        let items = Dictionary(value.items.map { ($0.type, $0) }, uniquingKeysWith: { first, second in
            (first.xp ?? 0) >= (second.xp ?? 0) ? first : second
        })
        profile.items = items.values.map(\.model)
        profile.playerSkills = value.playerSkills.map { IntrinsicsDataModel(name: $0.key, rank: $0.value) }
        profile.missions = value.missions.map { ResultMissionDataModel(from: $0) }
    }
    private static func apply(_ stats: AccountStats, to model: AccountStatsDataModel) {
        model.deaths = stats.deaths
        model.reviveCount = stats.reviveCount
        model.meleeKills = stats.meleeKills
        model.missionsCompleted = stats.missionsCompleted
        model.timePlayedSec = stats.timePlayedSec
        model.healCount = stats.healCount
        model.income = stats.income
        model.pickupCount = stats.pickupCount
        model.fishCount = stats.fishCount
        model.destroyCount = stats.destroyCount
        model.ciphersSolved = stats.ciphersSolved
        model.ciphersFailed = stats.ciphersFailed
    }

}
