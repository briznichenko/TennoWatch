//
//  MasteryItemView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryItemView: View {
    let item: MasteryItemViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                .foregroundStyle(item.isMastered ? .green : .red)
            HStack {
                Text(item.name)
                Spacer()
                Text("\(item.xp)")
                    .foregroundStyle(item.isMastered ? .green : .red)
            }.background(
                in: Rectangle()
            )
        }
    }
}

#Preview {
    MasteryItemView(item: .stub)
}
