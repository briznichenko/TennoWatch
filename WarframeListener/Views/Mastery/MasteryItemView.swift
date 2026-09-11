//
//  MasteryItemView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import SwiftUI

struct MasteryItemView: View {
    private struct Constants {
        static let imageHeight = 35.0
        static let padding = 5.0
    }
    
    let viewModel: MasteryItemViewModel
    
    var body: some View {
        HStack {
            Image(systemName: viewModel.iconName)
                .resizable().aspectRatio(1, contentMode: .fit)
                .foregroundStyle(.accent)
                .frame(height: Constants.imageHeight)
                .padding(.vertical, Constants.padding)
            VStack(alignment: .leading) {
                Text(viewModel.name)
                HStack {
                    Text(viewModel.rankText)
                    Divider()
                    Text("\(viewModel.xp) xp")
                }
            }
            Spacer()
        }
    }
}
