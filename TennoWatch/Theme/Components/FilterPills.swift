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
        GlassEffectContainer(spacing: Layout.pillSpacing) {
            HStack(spacing: Layout.pillSpacing) {
                ForEach(options, id: \.self) { option in
                    pill(for: option)
                }
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
                .font(.footnote.weight(isSelected ? .semibold : .regular))
                .contentShape(.capsule)
        }
        .buttonStyle(AppGlassButtonStyle(isProminent: isSelected))
        .controlSize(.small)
        .frame(minHeight: ListLayout.minimumRowHeight)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct Layout {
    static let pillSpacing: CGFloat = 6
}

#Preview {
    FilterPills(options: MasteryCategoryDetailViewModel.Filter.allCases,
                title: \.title,
                selection: .constant(.locked))
}
