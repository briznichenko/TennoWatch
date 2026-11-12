//
//  OpeningsItemCategoryDetailView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct OpeningsItemCategoryDetailView: View {
    @Environment(ManualMasteryStore.self) private var manualMasteryStore
    @State private var profileID: String?
    @State private var isSelecting = false
    @State private var selectedIDs: Set<String> = []
    @State private var viewModel: OpeningsItemCategoryDetailViewModel

    init(viewModel: OpeningsItemCategoryDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ThemedList {
            ForEach(viewModel.filteredItems) { item in
                ManualMasterySelectionRow(id: item.id, name: item.name, isSelecting: isSelecting, selectedIDs: $selectedIDs) {
                    MasteryItemView(viewModel: item)
                }
            }
        }
        .disabled(manualMasteryStore.isSaving)
        .onChange(of: viewModel.searchText) { selectedIDs = [] }
        .toolbar {
            ManualMasteryToolbar(
                store: manualMasteryStore, profileID: profileID,
                isSelecting: $isSelecting, selectedIDs: $selectedIDs,
                visibleIDs: Set(viewModel.filteredItems.map(\.id))
            )
        }
        .task(id: manualMasteryStore.revision) {
            await viewModel.load()
            profileID = await manualMasteryStore.profileID()
            selectedIDs.formIntersection(Set(viewModel.filteredItems.map(\.id)))
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: Strings.Common.searchItems)
        .navigationTitle(viewModel.categoryTitle)
        .inlineNavigationTitle()
    }
}
