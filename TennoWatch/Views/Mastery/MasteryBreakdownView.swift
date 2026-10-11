//
//  MasteryBreakdownView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/17/26.
//

import SwiftUI

struct MasteryBreakdownView: View {
    // MARK: - Object Properties
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
                            Text(row.earnedPoints.formatted())
                                .font(.subheadline)
                                .foregroundStyle(Color.labelSecondary)
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
        .task {
            await viewModel.loadBreakdown()
        }
    }
}

private struct Layout {
    static let minimumRowHeight: CGFloat = 32
}
