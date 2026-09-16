//
//  IntrinsicRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct IntrinsicRowView: View {
    // MARK: - Object Properties
    let intrinsic: IntrinsicItem

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(intrinsic.name)
                    .foregroundStyle(Color.labelPrimary)
                Spacer()
                Text(Strings.Profile.intrinsicRankText(rank: intrinsic.rank, maxRank: intrinsic.maxRank))
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            ProgressBar(value: intrinsic.fraction)
        }
        .padding(.vertical, 4)
        .frame(minHeight: 44)
    }
}
