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
    private(set) var profile: ProfileModel?
    private(set) var networkText: String = ""
    private(set) var isLoading = false
    private(set) var items: [MasteryItemType: [ProfileItem]] = [:]
    
    var displayName: String {
        profile?.results.first?.displayName ?? "Unknown"
    }

    private let playerId: String
    private let apiManager: APIManager

    init(playerId: String, apiManager: APIManager = APIManager()) {
        self.playerId = playerId
        self.apiManager = apiManager
    }

    func fetchProfile(isMock: Bool = false) async {
        guard isMock == false else {
            return await fetchProfileMock()
        }
        isLoading = true
        networkText = "Loading..."

        do {
            profile = try await apiManager.fetch(.profile(playerId: playerId))
            filterItems()
            isLoading = false
        } catch {
            networkText = error.localizedDescription
        }
    }
    
    private func fetchProfileMock(filename: String = "ProfileData") async {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                profile = try decoder.decode(ProfileModel.self, from: data)
                filterItems()
            } catch {
                networkText = error.localizedDescription
            }
    }
    
    private func filterItems() {
//        let xpItems = profile?.stats.weapons
//            .sorted { ($0.xp ?? 0) < ($1.xp ?? 0) }
//            .map { MasteryItem(item: $0) } ?? []
//        var weapons: [Weapon] = []
//        var warframes: [Weapon] = []
//        var other: [Weapon] = []
//        
//        xpItems.forEach { item in
//            let comps = item.itemType.components(separatedBy: "/")
//            if comps.indices.contains(2) {
//                switch MasteryItemType(rawValue: comps[2]) {
//                case .weapon: weapons.append(item)
//                case .warframe: warframes.append(item)
//                case .other, .none: other.append(item)
//                }
//            }
//        }
//        items = [
//            .other: other,
//            .warframe: warframes,
//            .weapon: weapons
//        ]
    }
}
