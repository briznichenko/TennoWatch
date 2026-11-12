//
//  ManualMasteryControls.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 11/12/26.
//

import SwiftUI

struct ManualMasteryToolbar: ToolbarContent {
    let store: ManualMasteryStore
    let profileID: String?
    @Binding var isSelecting: Bool
    @Binding var selectedIDs: Set<String>
    let visibleIDs: Set<String>

    var body: some ToolbarContent {
        if profileID != nil {
            ToolbarItem(placement: .primaryAction) {
                Button(isSelecting ? Strings.Mastery.done : Strings.Mastery.selectItems) {
                    isSelecting.toggle()
                    selectedIDs.removeAll()
                }
                .disabled(store.isSaving)
            }
            if isSelecting {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(Strings.Mastery.selectAll) {
                        selectedIDs.formUnion(visibleIDs)
                    }
                    .disabled(store.isSaving || visibleIDs.isEmpty)

                    Menu {
                        Button(Strings.Mastery.markMastered, systemImage: "checkmark.circle") {
                            save(mastered: true)
                        }
                        Button(Strings.Mastery.markUnmastered, systemImage: "circle") {
                            save(mastered: false)
                        }
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                    .accessibilityLabel(Strings.Mastery.markMastered)
                    .disabled(store.isSaving || selectedIDs.isEmpty)
                }
            }
        }
    }

    private func save(mastered: Bool) {
        guard let profileID else { return }
        let itemIDs = selectedIDs
        Task {
            if await store.setMastered(mastered, itemIDs: itemIDs, profileID: profileID) {
                selectedIDs.removeAll()
                isSelecting = false
            }
        }
    }
}

struct ManualMasterySelectionRow<Content: View>: View {
    let id: String
    let name: String
    let isSelecting: Bool
    @Binding var selectedIDs: Set<String>
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: ListLayout.iconSpacing) {
            if isSelecting {
                Button {
                    if !selectedIDs.insert(id).inserted {
                        selectedIDs.remove(id)
                    }
                } label: {
                    Image(systemName: selectedIDs.contains(id) ? "checkmark.circle.fill" : "circle")
                        .imageScale(.large)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(.rect)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(Text(verbatim: "\(Strings.Mastery.selectItems): \(name)"))
                .accessibilityAddTraits(selectedIDs.contains(id) ? .isSelected : [])
            }
            content
        }
    }
}
