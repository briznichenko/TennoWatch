//
//  SortieRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct SortieRowView: View {
    let sortie: Sortie
    var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.missionSpacing) {
            Text(sortie.boss)
                .font(.headline)
            if let reward = sortie.archonHuntReward {
                HStack(spacing: ListLayout.detailSpacing) {
                    Image(systemName: "suit.diamond.fill")
                        .foregroundStyle(reward.tint)
                    Text(reward.displayName)
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
            }
            if !sortie.variants.isEmpty {
                ForEach(sortie.variants.filter {
                    [$0.node, $0.nodeKey, $0.missionType, $0.modifier].joined(separator: " ").matchesSearch(searchText)
                }, id: \.nodeKey) { variant in
                    SortieVariantRowView(variant: variant)
                }
            } else {
                ForEach(sortie.missions.filter {
                    [$0.node, $0.nodeKey, $0.type].joined(separator: " ").matchesSearch(searchText)
                }, id: \.nodeKey) { mission in
                    HStack {
                        Text(mission.node)
                        Spacer()
                        Text(mission.type)
                            .font(.caption)
                            .foregroundStyle(Color.labelSecondary)
                    }
                }
            }
        }
    }
}

private extension ArchonHuntReward {
    var tint: Color {
        switch self {
        case .crimson: .archonCrimson
        case .amber: .archonAmber
        case .azure: .archonAzure
        }
    }
}

private struct SortieVariantRowView: View {
    let variant: SortieVariant

    var body: some View {
        VStack(alignment: .leading, spacing: ListLayout.compactDetailSpacing) {
            HStack {
                Text(variant.node)
                Spacer()
                Text(variant.missionType)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Text(variant.modifier)
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
            Text(variant.modifierDescription)
                .font(.caption2)
                .foregroundStyle(Color.labelSecondary)
        }
    }
}

private struct Layout {
    static let missionSpacing: CGFloat = 6
}
