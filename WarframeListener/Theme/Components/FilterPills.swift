//
//  FilterPills.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

struct FilterPills<Option: Hashable>: View {
    let options: [Option]
    let title: (Option) -> String
    @Binding var selection: Option

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options, id: \.self) { option in
                pill(for: option)
            }
        }
    }

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
                        Capsule().strokeBorder(Color.separator)
                    }
                }
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}
