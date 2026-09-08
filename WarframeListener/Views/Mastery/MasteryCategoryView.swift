//
//  MasteryCategoryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/29/26.
//

import SwiftUI

struct MasteryCategoryView: View {
    let catalogContainer: CatalogContainer
    
    var body: some View {
        HStack {
            Text(catalogContainer.category.displayName.uppercased())
            Text(catalogContainer.countText)
                .font(.subheadline)
                .foregroundStyle(.accent)
            Spacer()
        }
    }
}
