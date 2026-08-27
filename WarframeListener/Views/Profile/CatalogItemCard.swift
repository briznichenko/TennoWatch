//
//  CatalogItemCard.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/27/26.
//
import SwiftUI

struct CatalogItemCard: View {
    let item: CatalogItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: .init(width: 10, height: 10)).stroke(style: .init())
            HStack {
                Text(item.name)
                Spacer()
            }
        }
    }
}
