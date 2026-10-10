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
        HStack(spacing: Layout.pillSpacing) {
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
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.vertical, Layout.verticalPadding)
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
        .frame(minHeight: ListLayout.minimumRowHeight)
        .contentShape(Rectangle())
    }
}

private struct Layout {
    static let pillSpacing: CGFloat = 6
    static let horizontalPadding: CGFloat = 11
    static let verticalPadding: CGFloat = 4
}

#Preview {
    FilterPills(options: MasteryCategoryDetailViewModel.Filter.allCases,
                title: \.title,
                selection: .constant(.locked))
}
