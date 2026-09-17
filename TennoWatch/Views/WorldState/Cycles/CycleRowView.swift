//
//  CycleRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct CycleRowView: View {
    let cycle: WorldCycleDisplay

    var body: some View {
        HStack {
            Text(cycle.title)
            Spacer()
            Text(cycle.state)
                .foregroundStyle(Color.labelSecondary)
            if cycle.expiry != nil {
                LiveCountdownText(date: cycle.expiry)
                    .frame(minWidth: 56, alignment: .trailing)
            } else if !cycle.timeLeft.isEmpty {
                Text(cycle.timeLeft)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
                    .frame(minWidth: 44, alignment: .trailing)
            }
        }
    }
}

#Preview {
    List {
        CycleRowView(cycle: .init(id: "cetus", title: "Cetus", state: "Day", timeLeft: "45m", expiry: .now.addingTimeInterval(2700)))
    }
}
