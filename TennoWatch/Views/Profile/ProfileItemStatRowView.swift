//
//  ProfileItemStatRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct ProfileItemStatRowView: View {
    // MARK: - Object Properties
    let item: ProfileItemStat

    // MARK: - Body
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: ListLayout.compactDetailSpacing) {
                Text(item.name)
                    .foregroundStyle(Color.labelPrimary)
                Text(Strings.Profile.itemDetailText(kills: item.kills, headshots: item.headshots, assists: item.assists))
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer()
            ItemWikiLink(itemName: item.name)
        }
        .frame(minHeight: ListLayout.minimumRowHeight)
    }
}
