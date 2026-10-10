//
//  OpeningsCategoryRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct OpeningsCategoryRowView: View {
    let title: String
    let countText: String
    var icon: String = "square.stack.3d.up"

    var body: some View {
        HStack(spacing: 12) {
            DashboardIcon(name: icon, size: 36)
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.labelPrimary)
            Spacer()
            Text(countText)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        OpeningsCategoryRowView(title: "Warframe", countText: "6")
    }
}
