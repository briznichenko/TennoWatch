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
    var snapshot: MasterySummary.ItemSnapshot?

    // MARK: - Computed Properties
    private var masteryState: MasteryState { snapshot?.masteryState ?? item.masteryState }
    private var rank: Int { snapshot?.rank ?? item.rank }
    private var remainingMasteryPoints: Int { snapshot?.remainingMasteryPoints ?? item.remainingMasteryPoints }

    private var detailText: String {
        switch masteryState {
        case .mastered: Strings.Mastery.itemStateMastered
        case .unobtainable: Strings.Mastery.itemStateUnobtainable
        case .unmastered, .partiallyMastered:
            Strings.Mastery.itemRankProgress(
                rank: rank,
                maxRank: item.catalogItem.maxRank,
                pointsRemaining: remainingMasteryPoints
            )
        }
    }

    private var iconName: String {
        switch masteryState {
        case .mastered: "checkmark.circle.fill"
        case .partiallyMastered: "circle.lefthalf.filled"
        case .unmastered: "circle.dashed"
        case .unobtainable: "lock.fill"
        }
    }

    private var textColor: Color {
        isDimmed ? .labelSecondary : .label
    }

    private var isDimmed: Bool {
        switch masteryState {
        case .mastered, .unobtainable: true
        case .unmastered, .partiallyMastered: false
        }
    }

    private var iconStyle: Color {
        switch masteryState {
        case .mastered: .masteredIcon
        case .unmastered, .partiallyMastered: .unmasteredIcon
        case .unobtainable: .lockedIcon
        }
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconStyle)
                .imageScale(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.catalogItem.name)
                    .foregroundStyle(textColor)
                Text(detailText)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }
}
