//
//  FlashSaleRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/17/26.
//

import SwiftUI

struct FlashSaleRowView: View {
    let flashSale: FlashSale

    var body: some View {
        VStack(alignment: .leading, spacing: ListLayout.detailSpacing) {
            HStack {
                Text(flashSale.item)
                    .font(.headline)
                Spacer()
                LiveCountdownText(date: flashSale.expiry)
                ItemWikiLink(itemName: flashSale.item)
            }
            if let discount = flashSale.discount {
                Text(Strings.WorldState.discount(Int(discount)))
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
        .frame(minHeight: ListLayout.minimumRowHeight)
    }
}

#Preview {
    List {
        FlashSaleRowView(
            flashSale: .init(
                activation: .now,
                expiry: .now.addingTimeInterval(3600),
                id: "flashSale",
                discount: 50,
                isFeatured: true,
                isPopular: false,
                isShownInMarket: true,
                item: "Ash Prime Systems",
                premiumOverride: nil,
                regularOverride: nil
            )
        )
    }
}
