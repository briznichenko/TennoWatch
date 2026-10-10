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
        VStack(alignment: .leading, spacing: 14) {
            let identityLayout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
            identityLayout {
                DashboardIcon(name: viewModel.iconName)
                VStack(alignment: .leading, spacing: 4) {
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
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
                : AnyLayout(HStackLayout(alignment: .bottom, spacing: 12))
            layout {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.sourceName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DashboardPalette.accent(in: colorScheme))
                    Text(viewModel.location)
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let expiry = viewModel.expiry {
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                        LiveCountdownText(date: expiry, showsSeconds: false)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.bg, in: .capsule)
                    .fixedSize(horizontal: true, vertical: false)
                } else if let completion = viewModel.completion {
                    Text(completion, format: .percent.precision(.fractionLength(0)))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(Color.labelSecondary)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .background(DashboardCardBackground(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
}
