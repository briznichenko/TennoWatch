//
//  TraderInventoryItemRowView.swift
//  TennoWatch
//

import SwiftUI

struct TraderInventoryItemRowView: View {
    let item: VoidTraderItem

    var body: some View {
        HStack {
            Text(item.item)
                .foregroundStyle(Color.labelPrimary)
            Spacer()
            if let ducats = item.ducats {
                Text(Strings.WorldState.ducats(Int(ducats)))
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            if let credits = item.credits {
                Text(Strings.WorldState.credits(Int(credits)))
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    List {
        TraderInventoryItemRowView(item: .init(credits: nil, ducats: 350, item: "Banshee Prime Systems", uniqueName: "item"))
    }
}
