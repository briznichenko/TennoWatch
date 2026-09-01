//
//  MasteryItemViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import Observation
import Foundation

@Observable
final class MasteryItemViewModel: Identifiable {
    private let item: CatalogItem
    private let profileItem: ProfileItem?
    
    init(item: CatalogItem, profileItem: ProfileItem? = .none) {
        self.item = item
        self.profileItem = profileItem
    }
    
    let id = UUID()
    
    var name: String { item.name }
    var type: String { item.category.displayName }
    var xp: Int { profileItem?.xp ?? 0 }
    var isMastered: Bool { xp > 0 }
    
    static let stub = MasteryItemViewModel(item: .stub, profileItem: .stub)
}
