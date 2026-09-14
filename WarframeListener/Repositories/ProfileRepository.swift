//
//  ProfileRepository.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/2/26.
//

import Foundation
import SwiftData

protocol ProfileRepository {
    var syncPolicy: SyncPolicy { get }

    func syncProfile(withPlayerId playerId: String?) async throws
}

extension ProfileRepository {
    func syncProfile(withPlayerId playerId: String? = .none) async throws {
        try await syncProfile(withPlayerId: playerId)
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

    // MARK: - Init
    init(profileService: ServiceProtocol = APIManager(), persistencyService: PersistencyService) {
        self.profileService = profileService
        self.persistencyService = persistencyService
    }

    // MARK: - Functions
    func syncProfile(withPlayerId playerId: String?) async throws {
        let syncPolicy = syncPolicy
        let isFresh = try await persistencyService.perform { context in
            guard let stored = try context.fetch(FetchDescriptor<ProfileDataModel>()).first else { return false }
            return Calendar.current.isDateInToday(stored.lastUpdated) && syncPolicy == .daily
        }
        if isFresh { return }

        guard let playerId else { throw ProfileError.noPlayerId }
        let fetchedProfile: ProfileModel = try await profileService.fetch(.profile(playerId: playerId))
        guard let result = fetchedProfile.results.first else { throw ProfileError.noPlayerId }

        try await persistencyService.perform { context in
            let profile = ProfileDataModel(
                accountID: result.accountID,
                displayName: result.displayName,
                items: fetchedProfile.stats.weapons,
                playerSkills: result.playerSkills,
                missions: result.missions,
                lastUpdated: Date()
            )
            context.insert(profile)
            try context.save()
        }
    }
}
