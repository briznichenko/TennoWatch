//
//  ProfileData.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import Foundation
import SwiftData

@Model
final class ProfileDataModel: ValueTypeConvertible {
    typealias Value = Profile
    var value: Value {
        .init(accountID: .init(oid: accountID), displayName: displayName, items: items.map(\.value), lastUpdated: lastUpdated)
    }
    
    @Attribute(.unique) var accountID: String
    @Attribute(.unique) var displayName: String
    var items: [ProfileItemDataModel]
    var lastUpdated: Date
    
    init(accountID: String, displayName: String, items: [ProfileItemDataModel], lastUpdated: Date) {
        self.accountID = accountID
        self.displayName = displayName
        self.items = items
        self.lastUpdated = lastUpdated
    }
}

struct Profile: PersistentModelConvertible {
    typealias Model = ProfileDataModel
    var model: Model {
        .init(
            accountID: accountID.oid,
            displayName: displayName,
            items: items.map(\.model),
            lastUpdated: lastUpdated
        )
    }
    
    let accountID: ID
    let displayName: String
    let items: [ProfileItemModel]
    let lastUpdated: Date
}

struct ProfileItemModel: Codable, Hashable {
    let equipTime: Double?
    let headshots: Int?
    let hits: Int?
    let assists: Int?
    let kills: Int?
    let xp: Int?
    let type: String
    let fired: Int?
    
    static let stub = Self.init(equipTime: 10, headshots: 2, hits: 5, assists: 3, kills: 2, xp: 1000, type: "type", fired: 100)
}

extension ProfileItemModel: PersistentModelConvertible {
    var model: ProfileItemDataModel {
        .init(profileItem: self)
    }
}
