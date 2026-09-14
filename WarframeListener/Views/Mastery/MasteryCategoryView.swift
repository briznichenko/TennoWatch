//
//  MasteryCategoryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/29/26.
//

import SwiftUI

struct MasteryCategoryView: View {
    let catalogContainer: CatalogContainerModel
    var countOverride: MasterySummary.CategoryCount?

    private var countText: String {
        if let countOverride {
            "\(countOverride.masteredCount) / \(countOverride.itemsCount)"
        } else {
            catalogContainer.countText
        }
    }

    var body: some View {
        HStack {
            Text(catalogContainer.category.displayName.sentenceCased)
                .foregroundStyle(Color.label)
            Spacer()
            Text(countText)
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}
