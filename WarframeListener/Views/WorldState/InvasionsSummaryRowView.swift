//
//  InvasionsSummaryRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct InvasionsSummaryRowView: View {
    let count: Int

    var body: some View {
        HStack {
            Text(Strings.WorldState.invasionsHeader)
                .foregroundStyle(Color.labelPrimary)
            Spacer()
            Text("\(count)")
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    List {
        InvasionsSummaryRowView(count: 12)
    }
}
