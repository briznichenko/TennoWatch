//
//  ArchimedeaMissionRowView.swift
//  TennoWatch
//

import SwiftUI

struct ArchimedeaMissionRowView: View {
    let mission: ArchimedeaMission

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(mission.missionType)
                    .font(.headline)
                Spacer()
                Text(mission.faction)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Text(mission.deviation.name)
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
            ForEach(mission.risks, id: \.key) { risk in
                Text(risk.name)
                    .font(.caption2)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    List {
        ArchimedeaMissionRowView(
            mission: .init(
                deviation: .init(description: "Deviation", key: "dev", name: "Vampire Rock"),
                faction: "Scaldra",
                factionKey: "scaldra",
                missionType: "Defense",
                missionTypeKey: "defense",
                risks: [.init(description: "Risk", isHard: true, key: "risk", name: "Dense Fog")]
            )
        )
    }
}
