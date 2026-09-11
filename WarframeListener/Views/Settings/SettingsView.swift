//
//  SettingsView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("themePreference") private var themePreference: ThemePreference = .system
    @State private var viewModel: SettingsViewModel

    let displayName: String

    init(viewModel: SettingsViewModel, displayName: String) {
        self.viewModel = viewModel
        self.displayName = displayName
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Theme", selection: $themePreference) {
                        ForEach(ThemePreference.allCases) { preference in
                            Text(preference.label).tag(preference)
                        }
                    }
                } header: {
                    SectionHeaderLabel("Appearance")
                }

                Section {
                    HStack {
                        Text("Account")
                        Spacer()
                        Text(displayName)
                            .foregroundStyle(Color.labelSecondary)
                    }
                } header: {
                    SectionHeaderLabel("Account")
                }

                Section {
                    HStack {
                        Text("Catalog version")
                        Spacer()
                        Text(viewModel.gameVersion ?? "—")
                            .foregroundStyle(Color.labelSecondary)
                    }
                    if let generatedAt = viewModel.catalogGeneratedAt {
                        HStack {
                            Text("Generated")
                            Spacer()
                            Text(generatedAt.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(Color.labelSecondary)
                        }
                    }
                    Button {
                        Task { await viewModel.refreshCatalog() }
                    } label: {
                        HStack {
                            Label("Refresh catalog", systemImage: "arrow.clockwise")
                            Spacer()
                            if viewModel.isRefreshing {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.isRefreshing)

                    if !viewModel.statusText.isEmpty {
                        Text(viewModel.statusText)
                            .font(.caption)
                            .foregroundStyle(Color.labelSecondary)
                    }
                } header: {
                    SectionHeaderLabel("Catalog")
                }
            }
            .themedList()
            .navigationTitle("Settings")
            .task {
                await viewModel.loadCatalogInfo()
            }
        }
    }
}
