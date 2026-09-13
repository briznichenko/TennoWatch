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
    private(set) var profile: Profile?
    private(set) var networkText: String = ""
    private(set) var isLoading = false
    var playerId: String = "523b73b91a4d806878000000"
    var displayName: String {
        profile?.displayName ?? "Unknown"
    }

    private let profileRepository: ProfileRepository

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    func fetchProfile() async {
        guard playerId.isEmpty == false else {
            networkText = "No player ID"
            return
        }
        defer {
            isLoading = false
        }
        isLoading = true
        networkText = "Loading..."

        do {
            profile = try await profileRepository.getProfile(withPlayerId: playerId)
            isLoading = false
        } catch {
            networkText = error.localizedDescription
        }
    }
}
