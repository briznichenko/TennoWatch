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
    var snapshot: MasterySummary.SourceSnapshot?

    // MARK: - Computed Properties
    private var isMastered: Bool { snapshot?.isMastered ?? source.isMastered }
    private var masteryState: MasteryState { isMastered ? .mastered : .unmastered }

    private var iconName: String {
        isMastered ? "checkmark.circle.fill" : "circle.dashed"
    }

    private var textColor: Color {
        isMastered ? .labelSecondary : .label
    }

    private var iconStyle: Color {
        masteryState == .mastered ? .masteredIcon : .unmasteredIcon
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
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
