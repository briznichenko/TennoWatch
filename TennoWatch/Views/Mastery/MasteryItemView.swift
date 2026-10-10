//
//  MasteryItemView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryItemView: View {
    // MARK: - Object Properties
    let viewModel: MasteryItemViewModel

    // MARK: - Computed Properties
    private var textColor: Color {
        viewModel.isDimmed ? .labelSecondary : .labelPrimary
    }

    private var iconStyle: Color {
        switch viewModel.state {
        case .mastered: .masteredIcon
        case .unmastered, .partiallyMastered: .unmasteredIcon
        case .unobtainable: .lockedIcon
        }
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: ListLayout.iconSpacing) {
            Image(systemName: viewModel.iconName)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconStyle)
                .imageScale(.large)
            VStack(alignment: .leading, spacing: ListLayout.compactDetailSpacing) {
                Text(viewModel.name)
                    .foregroundStyle(textColor)
                Text(viewModel.detailText)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer()
        }
        .frame(minHeight: ListLayout.minimumRowHeight)
    }
}
