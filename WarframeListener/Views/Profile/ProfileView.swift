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
        NavigationStack {
            VStack {
                if let profile = viewModel.profile?.results.first {
                    Text(profile.displayName)
                    ForEach(MasteryItemType.allCases, id: \.self) { type in
                        HStack {
                            Text(type.rawValue)
                            let items = viewModel.items[type] ?? []
                            Text("\(viewModel.items[type]?.count ?? 0)")
                                    NavigationLink("Expand") {
                                        ScrollView {
                                            ForEach(items) { ProfileItemCard(item: $0) }
                                        }
                            }
                        }
                    }
                    Spacer()
                } else {
                    Text(viewModel.networkText)
                    ProgressView()
                }
            }
            .padding()
            .navigationTitle("Profile")
            .task {
                await viewModel.fetchProfileMock()
            }.refreshable {
                await viewModel.fetchProfile()
            }
        }
    }
}

#Preview {
    ProfileView(playerId: "")
}
