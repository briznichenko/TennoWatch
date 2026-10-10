//
//  TimeSensitiveOpeningRowView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct TimeSensitiveOpeningRowView: View {
    // MARK: - Object Properties
    let viewModel: TimeSensitiveOpeningViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            let identityLayout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: Layout.identitySpacing))
                : AnyLayout(HStackLayout(alignment: .top, spacing: Layout.identitySpacing))
            identityLayout {
                DashboardIcon(name: viewModel.iconName)
                VStack(alignment: .leading, spacing: ListLayout.detailSpacing) {
                    Text(viewModel.name)
                        .font(.headline)
                        .foregroundStyle(Color.labelPrimary)
                    Text(viewModel.type.sentenceCased)
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: Layout.sectionSpacing))
                : AnyLayout(HStackLayout(alignment: .bottom, spacing: Layout.identitySpacing))
            layout {
                VStack(alignment: .leading, spacing: ListLayout.detailSpacing) {
                    Text(viewModel.sourceName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DashboardPalette.accent(in: colorScheme))
                    Text(viewModel.location)
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let expiry = viewModel.expiry {
                    HStack(spacing: Layout.countdownIconSpacing) {
                        Image(systemName: "clock")
                        LiveCountdownText(date: expiry, showsSeconds: false)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
                    .padding(.horizontal, Layout.countdownHorizontalPadding)
                    .padding(.vertical, Layout.countdownVerticalPadding)
                    .background(Color.bg, in: .capsule)
                    .fixedSize(horizontal: true, vertical: false)
                } else if let completion = viewModel.completion {
                    Text(completion, format: .percent.precision(.fractionLength(Layout.percentageFractionDigits)))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(Color.labelSecondary)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(Layout.contentPadding)
        .background(DashboardCardBackground(cornerRadius: Layout.cornerRadius))
        .accessibilityElement(children: .combine)
    }
}

private struct Layout {
    static let sectionSpacing: CGFloat = 10
    static let identitySpacing: CGFloat = 12
    static let countdownIconSpacing: CGFloat = 5
    static let countdownHorizontalPadding: CGFloat = 10
    static let countdownVerticalPadding: CGFloat = 5
    static let contentPadding: CGFloat = 12
    static let cornerRadius: CGFloat = 20
    static let percentageFractionDigits = 0
}
