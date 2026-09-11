//
//  MasteryItemView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryItemView: View {
    let viewModel: MasteryItemViewModel

    private var textColor: Color {
        viewModel.isDimmed ? .labelSecondary : .label
    }

    private var iconStyle: Color {
        switch viewModel.state {
        case .mastered: .masteredIcon
        case .unmastered, .partiallyMastered: .unmasteredIcon
        case .unobtainable: .lockedIcon
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: viewModel.iconName)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconStyle)
                .imageScale(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.name)
                    .foregroundStyle(textColor)
                Text(viewModel.detailText)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }
}
