//
//  NightwaveListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct NightwaveListView: View {
    let nightwave: Nightwave

    var body: some View {
        ThemedList {
            ForEach(Array(nightwave.activeChallenges.enumerated()), id: \.offset) { _, challenge in
                NightwaveChallengeRowView(challenge: challenge)
            }
        }
        .navigationTitle(nightwave.tag)
        .inlineNavigationTitle()
    }
}
