//
//  MasterySourceView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import SwiftUI

struct MasterySourceView: View {
    // MARK: - Object Properties
    let viewModel: MasterySourceViewModel
    private let showsNodeDetails: Bool

    init(viewModel: MasterySourceViewModel, showsNodeDetails: Bool = false) {
        self.viewModel = viewModel
        self.showsNodeDetails = showsNodeDetails
    }

    // MARK: - Computed Properties
    private var textColor: Color {
        viewModel.isDimmed ? .labelSecondary : .labelPrimary
    }

    private var iconStyle: Color {
        viewModel.state == .mastered ? .masteredIcon : .unmasteredIcon
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
                if showsNodeDetails, let details = viewModel.nodeDetails {
                    Text(details)
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
                Text(viewModel.detailText)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer()
        }
        .frame(minHeight: ListLayout.minimumRowHeight)
    }
}
