//
//  SettingsView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Object Properties
    @AppStorage("themePreference") private var themePreference: ThemePreference = .system
    @AppStorage(AppLanguage.storageKey) private var languagePreference: AppLanguage = .system
    @State private var viewModel: SettingsViewModel

    let displayName: String

    // MARK: - Init
    init(viewModel: SettingsViewModel, displayName: String) {
        self.viewModel = viewModel
        self.displayName = displayName
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(Strings.Settings.themeLabel, selection: $themePreference) {
                        ForEach(ThemePreference.allCases) { preference in
                            Text(preference.label).tag(preference)
                        }
                    }
                } header: {
                    SectionHeaderLabel(Strings.Settings.appearanceHeader)
                }

                Section {
                    Picker(Strings.Settings.languageLabel, selection: $languagePreference) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.label).tag(language)
                        }
                    }
                } header: {
                    SectionHeaderLabel(Strings.Settings.languageHeader)
                }

                Section {
                    HStack {
                        Text(Strings.Settings.accountLabel)
                        Spacer()
                        Text(displayName)
                            .foregroundStyle(Color.labelSecondary)
                    }
                } header: {
                    SectionHeaderLabel(Strings.Settings.accountHeader)
                }

                Section {
                    HStack {
                        Text(Strings.Settings.catalogVersionLabel)
                        Spacer()
                        Text(viewModel.gameVersion ?? Strings.Settings.catalogVersionPlaceholder)
                            .foregroundStyle(Color.labelSecondary)
                    }
                    if let generatedAt = viewModel.catalogGeneratedAt {
                        HStack {
                            Text(Strings.Settings.generatedLabel)
                            Spacer()
                            Text(generatedAt.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(Color.labelSecondary)
                        }
                    }
                    Button {
                        Task { await viewModel.refreshCatalog() }
                    } label: {
                        HStack {
                            Label(Strings.Settings.refreshCatalog, systemImage: "arrow.clockwise")
                            Spacer()
                            if viewModel.isRefreshing {
                                LotusLoaderView(size: 20)
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
                    SectionHeaderLabel(Strings.Settings.catalogHeader)
                }
            }
            .themedList()
            .navigationTitle(Strings.Settings.title)
            .handleErrorAlert(with: viewModel.errorManager)
            .task {
                await viewModel.loadCatalogInfo()
            }
        }
    }
}
