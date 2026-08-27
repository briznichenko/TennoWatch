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
            VStack(alignment: .leading) {
                Text(viewModel.networkText)
                if let profile = viewModel.profile?.results.first {
                    makeProfileView(profile)
                } else {
                    ProgressView()
                }
                Text("Catalog").font(.title)
                makeCatalogView()
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .task {
                await viewModel.fetchProfileMock()
                await viewModel.fetchCatalog()
            }.refreshable {
                await viewModel.fetchProfile()
            }
        }
    }
    
    @ViewBuilder
    private func makeCatalogView() -> some View {
        ForEach(viewModel.catalogs) { catalog in
            HStack {
                Text(catalog.category.rawValue)
                Text("\(catalog.items.count)")
                    .font(.subheadline)
                    .foregroundStyle(.cyan)
                Spacer()
                NavigationLink("Expand") {
                    ScrollView {
                        ForEach(catalog.items) {
                            CatalogItemCard(item: $0) }
                    }
                }
            }
        }
    }
        
    @ViewBuilder
    private func makeProfileView(_ profile: ProfileInfoModel) -> some View {
        Text(profile.displayName)
        Spacer()
    }
}

#Preview {
    ProfileView(playerId: "")
}
