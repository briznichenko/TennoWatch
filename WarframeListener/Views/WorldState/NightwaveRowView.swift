//
//  NightwaveRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct NightwaveRowView: View {
    let nightwave: Nightwave

    // MARK: - Computed Properties
    private var totalStanding: Int {
        nightwave.activeChallenges.reduce(0) { $0 + Int($1.reputation) }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(nightwave.tag)
                    .font(.headline)
                Text(Strings.WorldState.nightwaveChallengesCount(nightwave.activeChallenges.count))
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer()
            Text(Strings.WorldState.nightwaveStandingAvailable(totalStanding))
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    List {
        NightwaveRowView(
            nightwave: .init(
                activation: .now,
                expiry: .now.addingTimeInterval(3600),
                id: "nightwave",
                activeChallenges: [
                    .init(
                        activation: .now,
                        expiry: .now.addingTimeInterval(3600),
                        id: "challenge",
                        desc: "Complete a mission",
                        isDaily: true,
                        isElite: false,
                        isPermanent: false,
                        reputation: 1000,
                        title: "Complete a mission"
                    )
                ],
                phase: 1,
                possibleChallenges: [],
                season: 1,
                tag: "Nightwave Season"
            )
        )
    }
}
