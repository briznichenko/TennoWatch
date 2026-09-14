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
    
    func getProfile(withPlayerId playerId: String?) async throws -> Profile
}

extension ProfileRepository {
    func getProfile(withPlayerId playerId: String? = .none) async throws -> Profile {
        try await getProfile(withPlayerId: playerId)
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
    func getProfile(withPlayerId playerId: String?) async throws -> Profile {
        let storedProfile = try await persistencyService.fetchModel(by: ProfileDataModel.self).first
        if let storedProfile, Calendar.current.isDateInToday(storedProfile.lastUpdated) && syncPolicy == .daily {
            return storedProfile
        }
        
        guard let playerId else { throw ProfileError.noPlayerId }
        let fetchedProfile: ProfileModel = try await profileService.fetch(.profile(playerId: playerId))
        if let result = fetchedProfile.results.first {
            let profile: Profile = .init(
                accountID: result.accountID,
                displayName: result.displayName,
                items: fetchedProfile.stats.weapons,
                playerSkills: result.playerSkills,
                missions: result.missions,
                lastUpdated: Date())
            try await persistencyService.saveValue(profile)
            return profile
        } else {
            throw ProfileError.noPlayerId
        }
    }
}
