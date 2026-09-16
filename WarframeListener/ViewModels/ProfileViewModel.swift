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
    var playerId: String

    private let profileRepository: ProfileRepository
    let errorManager: ErrorManager

    // MARK: - Computed Properties
    var displayName: String {
        profile?.displayName ?? Strings.Profile.displayNameUnknown
    }
    var accountId: String {
        profile?.accountID.oid ?? ""
    }
    var playerLevel: Int {
        profile?.playerLevel ?? 0
    }
    var intrinsicGroups: [IntrinsicGroup] {
        profile?.intrinsicGroups ?? []
    }
    var itemStats: [ProfileItemStat] {
        profile?.itemStats ?? []
    }
    var missionStats: [MissionStat] {
        profile?.missionStats ?? []
    }
    var accountStatRows: [AccountStatRow] {
        profile?.accountStatRows ?? []
    }
    var totalMissionsCompleted: Int {
        missionStats.reduce(0) { $0 + $1.completes }
    }
    var totalKills: Int {
        itemStats.reduce(0) { $0 + $1.kills }
    }
    var intrinsicsSummaryText: String {
        let allIntrinsics = intrinsicGroups.flatMap(\.intrinsics)
        let earned = allIntrinsics.reduce(0) { $0 + $1.rank }
        let maxRank = allIntrinsics.reduce(0) { $0 + $1.maxRank }
        return "\(earned) / \(maxRank)"
    }

    // MARK: - Init
    init(profileRepository: ProfileRepository, errorManager: ErrorManager) {
        self.profileRepository = profileRepository
        self.errorManager = errorManager
        #if DEBUG
        playerId = "523b73b91a4d806878000000"
        #endif
    }

    // MARK: - Functions
    func fetchProfile(forceRefresh: Bool = false) async {
        guard playerId.isEmpty == false else {
            errorManager.append(PersistentProfileRepository.ProfileError.noPlayerId)
            return
        }
        defer {
            isLoading = false
        }
        isLoading = true

        do {
            profile = try await profileRepository.getProfile(withPlayerId: playerId, forceRefresh: forceRefresh)
            isLoading = false
        } catch {
            errorManager.append(error)
        }
    }
}
