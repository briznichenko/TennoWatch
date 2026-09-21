//
//  FlashSaleRowView.swift
//  TennoWatch
//

import SwiftUI

struct FlashSaleRowView: View {
    let flashSale: FlashSale

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(flashSale.item)
                    .font(.headline)
                Spacer()
                LiveCountdownText(date: flashSale.expiry)
            }
            if let discount = flashSale.discount {
                Text(Strings.WorldState.discount(Int(discount)))
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
        .frame(minHeight: 44)
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
