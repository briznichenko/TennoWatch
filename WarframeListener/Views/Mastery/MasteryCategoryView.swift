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
            Text(catalogContainer.category.displayName.sentenceCased)
                .foregroundStyle(Color.label)
            Spacer()
            Text(catalogContainer.countText)
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}
