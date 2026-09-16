//
//  MasterySourceCategoryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import SwiftUI

struct MasterySourceCategoryView: View {
    let summary: MasteryCategorySummary

    var body: some View {
        HStack {
            Text(summary.name.sentenceCased)
                .foregroundStyle(Color.labelPrimary)
            Spacer()
            Text(summary.countText)
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}
