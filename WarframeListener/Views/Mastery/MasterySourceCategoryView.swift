//
//  MasterySourceCategoryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import SwiftUI

struct MasterySourceCategoryView: View {
    let masteryCategory: MasteryCategoryDataModel
    var countOverride: MasterySummary.CategoryCount?

    private var countText: String {
        if let countOverride {
            "\(countOverride.masteredCount) / \(countOverride.itemsCount)"
        } else {
            masteryCategory.countText
        }
    }

    var body: some View {
        HStack {
            Text(masteryCategory.name.sentenceCased)
                .foregroundStyle(Color.label)
            Spacer()
            Text(countText)
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}
