//
//  View+Platform.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/7/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func compactListSections() -> some View {
        #if os(iOS)
        listSectionSpacing(.compact)
        #else
        self
        #endif
    }

    @ViewBuilder
    func profileListStyle() -> some View {
        #if os(iOS)
        listStyle(.insetGrouped)
        #else
        listStyle(.inset)
        #endif
    }

    @ViewBuilder
    func appTabStyle() -> some View {
        #if os(macOS)
        tabViewStyle(.sidebarAdaptable)
        #else
        tabViewStyle(.sidebarAdaptable)
            .toolbarBackground(Color.surface, for: .navigationBar, .tabBar)
            .toolbarBackground(.visible, for: .navigationBar, .tabBar)
        #endif
    }

    @ViewBuilder
    func masteryListStyle() -> some View {
        #if os(macOS)
        listStyle(.plain)
            .scrollContentBackground(.hidden)
        #else
        listStyle(.sidebar)
        #endif
    }

    @ViewBuilder
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func platformRefreshable(isDisabled: Bool, action: @escaping @MainActor @Sendable () async -> Void) -> some View {
        #if os(macOS)
        toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await action() }
                } label: {
                    Label(Strings.Main.refresh, systemImage: "arrow.clockwise")
                }
                .disabled(isDisabled)
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        #else
        refreshable(action: action)
        #endif
    }
}
