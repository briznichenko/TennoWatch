//
//  SteelPathRewardRowView.swift
//  TennoWatch
//

import SwiftUI

struct SteelPathRewardRowView: View {
    let reward: SteelPathReward

    var body: some View {
        HStack {
            Text(reward.name)
                .foregroundStyle(Color.labelPrimary)
            Spacer()
            Text(Strings.WorldState.steelEssence(Int(reward.cost)))
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    List {
        SteelPathRewardRowView(reward: .init(name: "Umbra Forma Blueprint", cost: 150))
    }
}
