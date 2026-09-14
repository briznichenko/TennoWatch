//
//  MasteryItemView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryItemView: View {
    // MARK: - Object Properties
    let item: MasteryItemDataModel

    // MARK: - Computed Properties
    private var textColor: Color {
        item.isDimmed ? .labelSecondary : .label
    }

    private var iconStyle: Color {
        switch item.masteryState {
        case .mastered: .masteredIcon
        case .unmastered, .partiallyMastered: .unmasteredIcon
        case .unobtainable: .lockedIcon
        }
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.iconName)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconStyle)
                .imageScale(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.catalogItem.name)
                    .foregroundStyle(textColor)
                Text(item.detailText)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }
}
