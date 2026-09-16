//
//  OpeningsCategoryRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct OpeningsCategoryRowView: View {
    let title: String
    let countText: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.labelPrimary)
            Spacer()
            Text(countText)
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    List {
        OpeningsCategoryRowView(title: "Warframe", countText: "6")
    }
}
