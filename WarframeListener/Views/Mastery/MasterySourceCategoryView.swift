//
//  MasterySourceCategoryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import SwiftUI

struct MasterySourceCategoryView: View {
    let masteryCategory: MasteryCategoryDataModel

    var body: some View {
        HStack {
            Text(masteryCategory.name.sentenceCased)
                .foregroundStyle(Color.label)
            Spacer()
            Text(masteryCategory.countText)
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}
