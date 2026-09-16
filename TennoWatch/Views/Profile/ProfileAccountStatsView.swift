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
        List {
            ForEach(rows) { row in
                LabeledContent(row.label, value: row.value)
                    .foregroundStyle(Color.labelPrimary)
                    .frame(minHeight: 44)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.Profile.statsTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
