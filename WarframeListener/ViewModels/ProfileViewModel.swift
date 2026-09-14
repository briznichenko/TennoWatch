//
//  ProfileViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation
import Observation

@Observable
final class ProfileViewModel {
    // MARK: - Object Properties
    private(set) var profile: Profile?
    private(set) var isLoading = false
    var playerId: String = "523b73b91a4d806878000000"

    private let profileRepository: ProfileRepository
    let errorManager: ErrorManager

    // MARK: - Computed Properties
    var displayName: String {
        profile?.displayName ?? Strings.Profile.displayNameUnknown
    }

    // MARK: - Init
    init(profileRepository: ProfileRepository, errorManager: ErrorManager) {
        self.profileRepository = profileRepository
        self.errorManager = errorManager
    }

    // MARK: - Functions
    func fetchProfile() async {
        guard playerId.isEmpty == false else {
            errorManager.append(PersistentProfileRepository.ProfileError.noPlayerId)
            return
        }
        defer {
            isLoading = false
        }
        isLoading = true

        do {
            profile = try await profileRepository.getProfile(withPlayerId: playerId)
            isLoading = false
        } catch {
            errorManager.append(error)
        }
    }
}
