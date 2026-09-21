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

    func getProfile(withPlayerId playerId: String?, forceRefresh: Bool) async throws -> Profile
}

extension ProfileRepository {
    func getProfile(withPlayerId playerId: String? = .none, forceRefresh: Bool = false) async throws -> Profile {
        try await getProfile(withPlayerId: playerId, forceRefresh: forceRefresh)
    }
}

final class PersistentProfileRepository: ProfileRepository {
    enum ProfileError: Error {
        case noData, noPlayerId
    }
    
    // MARK: - Object Properties
    let syncPolicy: SyncPolicy = .daily

    private let profileService: ServiceProtocol
    private let persistencyService: PersistencyService
    private var accountIDStore: AccountIDStoring

    // MARK: - Init
    init(
        profileService: ServiceProtocol = APIManager(),
        persistencyService: PersistencyService,
        accountIDStore: AccountIDStoring = UserDefaultsAccountIDStore()
    ) {
        self.profileService = profileService
        self.persistencyService = persistencyService
        self.accountIDStore = accountIDStore
    }

    // MARK: - Functions
    func getProfile(withPlayerId playerId: String?, forceRefresh: Bool) async throws -> Profile {
        let storedProfiles = try await persistencyService.fetchModel(by: ProfileDataModel.self)
        let targetAccountID = playerId ?? accountIDStore.currentAccountID
        // With no requested account, fall back to whatever's on disk. Once a target is known,
        // a stored profile for a *different* account must never stand in for it (that returned
        // the wrong Tenno's data when a second account's profile was already cached).
        let storedProfile = targetAccountID.map { id in storedProfiles.first { $0.accountID.oid == id } } ?? storedProfiles.first

        if !forceRefresh, let storedProfile, Calendar.current.isDateInToday(storedProfile.lastUpdated) && syncPolicy == .daily {
            return storedProfile
        }

        guard let playerId = targetAccountID ?? storedProfile?.accountID.oid else { throw ProfileError.noPlayerId }
        let fetchedProfile: ProfileModel = try await profileService.fetch(.profile(playerId: playerId))
        if let result = fetchedProfile.results.first {
            let profile: Profile = .init(
                accountID: result.accountID,
                displayName: result.displayName,
                playerLevel: result.playerLevel,
                items: fetchedProfile.stats.weapons,
                playerSkills: result.playerSkills,
                missions: result.missions,
                accountStats: .init(stats: fetchedProfile.stats),
                lastUpdated: Date())
            try await persistencyService.saveValue(profile)
            accountIDStore.currentAccountID = profile.accountID.oid
            return profile
        } else {
            throw ProfileError.noPlayerId
        }
    }
}
