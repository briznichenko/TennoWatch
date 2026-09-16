//
//  ProfileMissionsListView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct ProfileMissionsListView: View {
    typealias SortOption = ProfileMissionsListViewModel.SortOption

    // MARK: - Object Properties
    @State private var viewModel: ProfileMissionsListViewModel

    // MARK: - Init
    init(viewModel: ProfileMissionsListViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        List {
            ForEach(viewModel.sortedMissions) { mission in
                ProfileMissionRowView(mission: mission)
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: Strings.Profile.searchPlaceholder)
        .navigationTitle(Strings.Profile.missionsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(Strings.Profile.sortBy, selection: $viewModel.sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }
}
