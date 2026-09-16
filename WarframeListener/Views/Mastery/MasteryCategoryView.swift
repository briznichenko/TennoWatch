//
//  MasteryCategoryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/29/26.
//

import SwiftUI

struct MasteryCategoryView: View {
    let summary: CatalogContainerSummary

    var body: some View {
        HStack {
            Text(summary.category.displayName.sentenceCased)
                .foregroundStyle(Color.labelPrimary)
            Spacer()
            Text(summary.countText)
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}
