//
//  SortieRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct SortieRowView: View {
    let sortie: Sortie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(sortie.boss)
                .font(.headline)
            if let reward = sortie.archonHuntReward {
                HStack(spacing: 4) {
                    Image(systemName: "suit.diamond.fill")
                        .foregroundStyle(reward.tint)
                    Text(reward.displayName)
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
            }
            if !sortie.variants.isEmpty {
                ForEach(sortie.variants, id: \.nodeKey) { variant in
                    SortieVariantRowView(variant: variant)
                }
            } else {
                ForEach(sortie.missions, id: \.nodeKey) { mission in
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
        VStack(alignment: .leading, spacing: 2) {
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
