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
                .padding(.horizontal, Layout.horizontalPadding)
                .frame(minHeight: ListLayout.minimumRowHeight)
                .contentShape(.capsule)
        }
        .buttonStyle(FilterPillStyle(isSelected: isSelected))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct FilterPillStyle: PrimitiveButtonStyle {
    let isSelected: Bool

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        if isSelected {
            GlassProminentButtonStyle().makeBody(configuration: configuration)
        } else {
            GlassButtonStyle().makeBody(configuration: configuration)
        }
    }
}

private struct Layout {
    static let pillSpacing: CGFloat = 6
    static let horizontalPadding: CGFloat = 11
}

#Preview {
    FilterPills(options: MasteryCategoryDetailViewModel.Filter.allCases,
                title: \.title,
                selection: .constant(.locked))
}
