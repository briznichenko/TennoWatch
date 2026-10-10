//
//  ProfileAccountStatsView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct ProfileAccountStatsView: View {
    // MARK: - Object Properties
    let rows: [AccountStatRow]

    // MARK: - Body
    var body: some View {
        ThemedList {
            ForEach(rows) { row in
                LabeledContent(row.label, value: row.value)
                    .foregroundStyle(Color.labelPrimary)
                    .frame(minHeight: ListLayout.minimumRowHeight)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.Profile.statsTitle)
        .inlineNavigationTitle()
    }
}
