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
        List {
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
                        .frame(minHeight: 32)
                    }
                }
            }
        }
        .navigationTitle(Strings.Mastery.breakdownHeader)
        .navigationBarTitleDisplayMode(.inline)
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
