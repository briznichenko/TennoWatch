//
//  MasterySourceView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import SwiftUI

struct MasterySourceView: View {
    // MARK: - Object Properties
    let viewModel: MasterySourceViewModel

    // MARK: - Computed Properties
    private var textColor: Color {
        viewModel.isDimmed ? .labelSecondary : .labelPrimary
    }

    private var iconStyle: Color {
        viewModel.state == .mastered ? .masteredIcon : .unmasteredIcon
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: viewModel.iconName)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconStyle)
                .imageScale(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.name)
                    .foregroundStyle(textColor)
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }
}
