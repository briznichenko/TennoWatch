//
//  ProfileViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Combine
import Foundation
import SwiftUI

struct MasteryItem: Identifiable {
    private(set) var item: Weapon
    let id = UUID()
    
    var itemName: String { item.type.components(separatedBy: "/").last ?? "" }
    var itemXP: Int { item.xp ?? 0 }
    var textColor: Color { itemXP > 0 ? .green : .red }
}

@Observable
final class ProfileViewModel {
    private(set) var profile: ProfileModel?
    private(set) var errorMessage: String?
    private(set) var isLoading = false
    private(set) var items: [MasteryItem] = []

    private let playerId: String
    private let apiManager: APIManager
    private var cancellables = Set<AnyCancellable>()

    init(playerId: String, apiManager: APIManager = APIManager()) {
        self.playerId = playerId
        self.apiManager = apiManager
    }

    func fetchProfile() {
        isLoading = true
        errorMessage = nil

        apiManager.fetch(.profile(playerId: playerId))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] (profile: ProfileModel) in
                self?.profile = profile
                let xpItems = profile.stats.weapons.sorted { ($0.xp ?? 0) < ($1.xp ?? 0) }
                self?.items = xpItems.map { MasteryItem(item: $0) }
            }
            .store(in: &cancellables)
    }
}
