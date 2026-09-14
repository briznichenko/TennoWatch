//
//  MasterySourceView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import SwiftUI

struct MasterySourceView: View {
    // MARK: - Object Properties
    let source: MasterySourceDataModel

    // MARK: - Computed Properties
    private var textColor: Color {
        source.isDimmed ? .labelSecondary : .label
    }

    private var iconStyle: Color {
        source.masteryState == .mastered ? .masteredIcon : .unmasteredIcon
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: source.iconName)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconStyle)
                .imageScale(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text(source.name)
                    .foregroundStyle(textColor)
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }
}
