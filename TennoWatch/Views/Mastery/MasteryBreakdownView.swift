//
//  MasteryBreakdownView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/17/26.
//

import SwiftUI

struct MasteryBreakdownView: View {
    // MARK: - Object Properties
    @Environment(ManualMasteryStore.self) private var manualMasteryStore
    let viewModel: MasteryViewModel

    // MARK: - Body
    var body: some View {
        ThemedList {
            ForEach(Array(viewModel.breakdownSections.enumerated()), id: \.offset) { _, rows in
                Section {
                    ForEach(rows) { row in
                        HStack {
                            Text(row.name)
                                .foregroundStyle(Color.labelPrimary)
                            Spacer()
                            VStack(alignment: .trailing, spacing: Layout.detailSpacing) {
                                Text(row.earnedPoints, format: .number)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.labelSecondary)
                                if row.remainingPoints > 0 {
                                    Text(Strings.Mastery.sourcePointsRemaining(row.remainingPoints))
                                        .font(.caption)
                                        .foregroundStyle(Color.labelSecondary)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.masteredIcon)
                                        .accessibilityLabel(Strings.Mastery.itemStateMastered)
                                }
                            }
                            .monospacedDigit()
                        }
                        .frame(minHeight: Layout.minimumRowHeight)
                    }
                }
            }
        }
        .navigationTitle(Strings.Mastery.breakdownHeader)
        .inlineNavigationTitle()
        .overlay {
            if viewModel.breakdownSections.isEmpty {
                LotusLoaderView()
            }
        }
        .task(id: manualMasteryStore.revision) {
            await viewModel.loadBreakdown()
        }
    }
}

private struct Layout {
    static let detailSpacing: CGFloat = 4
    static let minimumRowHeight: CGFloat = 32
}
