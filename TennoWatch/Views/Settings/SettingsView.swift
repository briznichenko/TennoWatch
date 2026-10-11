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
    @AppStorage(DefaultVoidTraderNotificationScheduler.preferenceKey) private var isVoidTraderNotificationsEnabled = false
    @State private var viewModel: SettingsViewModel
    @State private var isShowingClearCacheConfirmation = false
    @Environment(\.colorScheme) private var colorScheme

    let displayName: String
    let onCacheCleared: () -> Void

    // MARK: - Init
    init(viewModel: SettingsViewModel, displayName: String, onCacheCleared: @escaping () -> Void) {
        self.viewModel = viewModel
        self.displayName = displayName
        self.onCacheCleared = onCacheCleared
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
                    DashboardSectionHeader(title: Strings.Settings.appearanceHeader, icon: "circle.lefthalf.filled")
                }

                Section {
                    Picker(Strings.Settings.languageLabel, selection: $languagePreference) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.label).tag(language)
                        }
                    }
                } header: {
                    DashboardSectionHeader(title: Strings.Settings.languageHeader, icon: "globe")
                }

                Section {
                    Toggle(Strings.Settings.voidTraderNotificationsLabel, isOn: $isVoidTraderNotificationsEnabled)
                } header: {
                    DashboardSectionHeader(title: Strings.Settings.notificationsHeader, icon: "bell")
                }

                Section {
                    HStack {
                        Text(Strings.Settings.accountLabel)
                        Spacer()
                        Text(displayName)
                            .foregroundStyle(Color.labelSecondary)
                    }
                } header: {
                    DashboardSectionHeader(title: Strings.Settings.accountHeader, icon: "person.crop.circle")
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
                                LotusLoaderView(size: LoadingIndicatorSize.compact)
                            }
                        }
                    }
                    .disabled(viewModel.isRefreshing)
                } header: {
                    DashboardSectionHeader(title: Strings.Settings.catalogHeader, icon: "square.stack.3d.up")
                }

                Section {
                    Button(role: .destructive) {
                        isShowingClearCacheConfirmation = true
                    } label: {
                        Label(Strings.Settings.clearCache, systemImage: "trash")
                    }
                    .disabled(viewModel.isClearingCache || viewModel.isRefreshing)
                } header: {
                    DashboardSectionHeader(title: Strings.Settings.storageHeader, icon: "externaldrive")
                }
            }
            .themedList()
            .compactListSections()
            .listStyle(.sidebar)
            .tint(DashboardPalette.accent(in: colorScheme))
            .navigationTitle(Strings.Settings.title)
            .handleErrorAlert(with: viewModel.errorManager)
            .confirmationDialog(
                Strings.Settings.clearCacheConfirmation,
                isPresented: $isShowingClearCacheConfirmation,
                titleVisibility: .visible
            ) {
                Button(Strings.Settings.clearCache, role: .destructive) {
                    Task {
                        if await viewModel.clearCache() {
                            onCacheCleared()
                        }
                    }
                }
            }
            .task {
                await viewModel.loadCatalogInfo()
            }
            .onChange(of: isVoidTraderNotificationsEnabled) { _, isEnabled in
                Task { await viewModel.setVoidTraderNotificationsEnabled(isEnabled) }
            }
        }
    }
}
