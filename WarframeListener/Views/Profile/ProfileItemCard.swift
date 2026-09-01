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
            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                .foregroundStyle(item.isMastered ? .green : .red)
            HStack {
                Text(item.itemName)
                Spacer()
                Text("\(item.itemXP)")
                    .foregroundStyle(item.isMastered ? .green : .red)
            }.background(
                in: Rectangle()
            )
        }
    }
}

#Preview {
    ProfileItemCard(item: .stub)
}
