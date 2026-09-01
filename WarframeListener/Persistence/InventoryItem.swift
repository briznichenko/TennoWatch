//
//  InventoryItem.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/26/26.
//

import Foundation
import SwiftData

@Model
final class InventoryItem {
    private(set) var item: ProfileItem
    
    init(item: ProfileItem) {
        self.item = item
    }
}
