//
//  ProfileItemStatRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct ProfileItemStatRowView: View {
    // MARK: - Object Properties
    let item: ProfileItemStat

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.name)
                .foregroundStyle(Color.label)
            Text(Strings.Profile.itemDetailText(kills: item.kills, headshots: item.headshots, assists: item.assists))
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}
