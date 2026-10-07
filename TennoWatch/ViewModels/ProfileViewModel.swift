//
//  ProfileViewModel.swift
//  TennoWatch
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
    private(set) var savedProfiles: [Profile] = []
    var playerId: String = ""

    private let profileRepository: ProfileRepository
    let errorManager: ErrorManager

    // MARK: - Computed Properties
    var displayName: String {
        profile.map { $0.isLocal ? Strings.Profile.manualProfile : $0.displayName } ?? Strings.Profile.displayNameUnknown
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
    }

    // MARK: - Functions
    func load() async {
        await perform {
            try await self.restoreSelection()
        }
    }

    func fetchProfile(forceRefresh: Bool = false) async {
        let requestedID = playerId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !requestedID.isEmpty else { return }
        await perform {
            self.profile = try await self.profileRepository.getProfile(withPlayerId: requestedID, forceRefresh: forceRefresh)
            self.playerId = self.accountId
        }
    }

    func selectProfile(_ saved: Profile) async {
        await perform {
            self.profile = try await self.profileRepository.selectProfile(accountID: saved.accountID.oid)
            self.playerId = saved.isLocal ? "" : self.accountId
        }
    }

    func createLocalProfile() async {
        await perform {
            self.profile = try await self.profileRepository.createLocalProfile()
            self.playerId = ""
        }
    }

    func deleteProfile(_ saved: Profile) async {
        await perform {
            try await self.profileRepository.deleteProfile(accountID: saved.accountID.oid)
            try await self.restoreSelection()
        }
    }

    func name(for profile: Profile) -> String {
        profile.isLocal ? Strings.Profile.manualProfile : profile.displayName
    }

    private func restoreSelection() async throws {
        savedProfiles = try await profileRepository.getSavedProfiles()
        let selected = savedProfiles.first { $0.accountID.oid == profileRepository.currentAccountID } ?? savedProfiles.first
        if let selected {
            profile = try await profileRepository.selectProfile(accountID: selected.accountID.oid)
        } else {
            profile = try await profileRepository.getProfile()
        }
        playerId = profile?.isLocal == true ? "" : accountId
    }

    private func perform(_ action: () async throws -> Void) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await action()
            savedProfiles = try await profileRepository.getSavedProfiles()
        } catch is CancellationError {
        } catch {
            errorManager.append(error)
        }
    }
}
