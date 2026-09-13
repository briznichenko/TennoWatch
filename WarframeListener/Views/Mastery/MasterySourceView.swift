//
//  MasterySourceView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import SwiftUI

struct MasterySourceView: View {
    let viewModel: MasterySourceViewModel

    private var textColor: Color {
        viewModel.isDimmed ? .labelSecondary : .label
    }

    private var iconStyle: Color {
        viewModel.state == .mastered ? .masteredIcon : .unmasteredIcon
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
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }
}
