//
//  FissuresSummaryRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct FissuresSummaryRowView: View {
    let count: Int

    var body: some View {
        HStack {
            Text(Strings.WorldState.fissuresHeader)
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
        FissuresSummaryRowView(count: 8)
    }
}
