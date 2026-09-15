//
//  ProfileMissionRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct ProfileMissionRowView: View {
    // MARK: - Object Properties
    let mission: MissionStat

    // MARK: - Body
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(mission.name)
                    .foregroundStyle(Color.label)
                if let tier = mission.tier {
                    Text(Strings.Profile.missionTierText(tier))
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
            }
            Spacer()
            Text(Strings.Profile.completesCount(mission.completes))
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}
