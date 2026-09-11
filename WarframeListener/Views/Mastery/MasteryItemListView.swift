//
//  MasteryItemListView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/2/26.
//

import SwiftUI

struct MasteryItemListView: View {
    let catalogContainer: CatalogContainer
    
    var body: some View {
        NavigationStack {
            List(catalogContainer.masteryItems, id: \.self) { item in
                MasteryItemView(viewModel: .init(item: item))
                    .listRowSeparatorTint(.accent)
            }.listStyle(.inset)
                .navigationTitle(catalogContainer.category.displayName.uppercased())
        }
    }
}
