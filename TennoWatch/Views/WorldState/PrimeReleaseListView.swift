//
//  PrimeReleaseListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/19/26.
//

import SwiftUI

struct PrimeReleaseListView: View {
    let candidates: [PrimeReleaseOrder.Frame]
    let updatedAt: Date

    var body: some View {
        ThemedList {
            Text(Strings.WorldState.primeReleasesExplanation)
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(candidates) { frame in
                VStack(alignment: .leading, spacing: Layout.detailSpacing) {
                    Text(frame.name + " Prime")
                        .font(.headline)
                        .foregroundStyle(Color.labelPrimary)
                    Text(Strings.WorldState.originalFrameRelease(frame.releaseDate.formatted(Self.dateFormat)))
                        .font(.subheadline)
                        .foregroundStyle(Color.labelSecondary)
                }
                .accessibilityElement(children: .combine)
            }

            Text(Strings.WorldState.primeReleaseDataUpdated(updatedAt.formatted(Self.dateFormat)))
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .listStyle(.plain)
        .navigationTitle(Strings.WorldState.primeReleasesHeader)
        .inlineNavigationTitle()
    }

    private static let dateFormat = Date.FormatStyle(date: .abbreviated, time: .omitted, timeZone: .gmt)
}

private struct Layout {
    static let detailSpacing: CGFloat = 4
}
