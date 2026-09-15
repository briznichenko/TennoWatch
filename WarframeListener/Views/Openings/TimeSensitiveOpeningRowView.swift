//
//  TimeSensitiveOpeningRowView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct TimeSensitiveOpeningRowView: View {
    // MARK: - Object Properties
    let viewModel: TimeSensitiveOpeningViewModel

    // MARK: - Body
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: viewModel.iconName)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.unmasteredIcon)
                .imageScale(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.name)
                    .foregroundStyle(Color.label)
                Text(viewModel.sourceText)
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer()
        }
        .frame(minHeight: 44)
    }
}
