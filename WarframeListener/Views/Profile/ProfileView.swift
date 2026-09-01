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
                Text(viewModel.displayName)
                    .font(.title)
                Text(viewModel.networkText)
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
        List(viewModel.catalogs) { catalog in
            CategoryView(catalog: catalog)
        }
    }
}

#Preview {
    ProfileView(playerId: "")
}
