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
    private(set) var isLoading = false
    var playerId: String = "523b73b91a4d806878000000"

    private let profileRepository: ProfileRepository
    let errorManager: ErrorManager

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
            try await profileRepository.syncProfile(withPlayerId: playerId)
        } catch {
            errorManager.append(error)
        }
    }
}
