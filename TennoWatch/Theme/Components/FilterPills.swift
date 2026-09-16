//
//  FilterPills.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

struct FilterPills<Option: Hashable>: View {
    // MARK: - Object Properties
    let options: [Option]
    let title: (Option) -> String
    @Binding var selection: Option

    // MARK: - Body
    var body: some View {
        HStack(spacing: 6) {
            ForEach(options, id: \.self) { option in
                pill(for: option)
            }
        }
    }

    // MARK: - Helper Functions
    private func pill(for option: Option) -> some View {
        let isSelected = option == selection
        return Button {
            selection = option
        } label: {
            Text(title(option))
                .font(.footnote)
                .padding(.horizontal, 11)
                .padding(.vertical, 4)
                .foregroundStyle(isSelected ? Color.bg : Color.labelSecondary)
                .background {
                    Capsule().fill(isSelected ? Color.accent : Color.clear)
                }
                .overlay {
                    if !isSelected {
                        Capsule().strokeBorder(Color.divider)
                    }
                }
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}
