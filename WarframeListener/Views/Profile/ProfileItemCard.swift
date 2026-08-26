//
//  ProfileItemCard.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/26/26.
//
import SwiftUI

struct ProfileItemCard: View {
    let item: MasteryItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: .init(width: 10, height: 10)).stroke(style: .init())
            HStack {
                Text(item.itemName)
                    .foregroundStyle(item.textColor)
                Spacer()
                Text("\(item.itemXP)")
                    .foregroundStyle(item.textColor)
            }
        }
    }
}

#Preview {
    ProfileItemCard(item: .init(item: .init(equipTime: .none, headshots: .none, hits: .none, assists: .none, kills: .none, xp: 0, type: "Type", fired: 0)))
}
