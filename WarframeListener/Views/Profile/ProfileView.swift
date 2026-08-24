//
//  ProfileView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel

    init(playerId: String = "523b73b91a4d806878000000") {
        _viewModel = State(initialValue: ProfileViewModel(playerId: playerId))
    }

    var body: some View {
        VStack {
            if let profile = viewModel.profile?.results.first {
                Text(profile.displayName)
                Text("\(profile.playerLevel)")
                ScrollView {
                    ForEach(viewModel.items) { item in
                        HStack {
                            Text(item.itemName).foregroundStyle(item.textColor)
                            Spacer()
                            Text("\(item.itemXP)").foregroundStyle(item.textColor)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            viewModel.fetchProfile()
        }
    }
}

#Preview {
    ProfileView(playerId: "")
}
