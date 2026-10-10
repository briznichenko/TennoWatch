//
//  ProfileView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI

struct ProfileView: View {
    // MARK: - Object Properties
    @State private var viewModel: ProfileViewModel
    @State private var profileToDelete: Profile?
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingSettings = false
    @State private var isShowingIdHelp = false
    @AppStorage("profileIdHelpDontShowAgain") private var dontShowIdHelpAgain = false
    @FocusState private var isIDInputFocused
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let dependencies: AppDependencies
    private let onCacheCleared: () -> Void

    // MARK: - Init
    init(viewModel: ProfileViewModel, dependencies: AppDependencies, onCacheCleared: @escaping () -> Void) {
        self.viewModel = viewModel
        self.dependencies = dependencies
        self.onCacheCleared = onCacheCleared
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    identityCard
                        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    savedProfilesSection
                    playerIdSection
                    statsSection
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(Color.bg)
                .tint(DashboardPalette.accent(in: colorScheme))
                .navigationTitle(Strings.Profile.title)
                .overlay {
                    if viewModel.isLoading {
                        LotusLoaderView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        AppSettingsButton(isPresented: $isShowingSettings)
                    }
                }
                .handleErrorAlert(with: viewModel.errorManager)
                .sheet(isPresented: $isShowingSettings) {
                    SettingsView(
                        viewModel: .init(
                            persistencyService: dependencies.persistencyService,
                            catalogRepository: dependencies.catalogRepository,
                            profileRepository: dependencies.profileRepository,
                            worldStateRepository: dependencies.worldStateRepository,
                            notificationService: dependencies.notificationService,
                            voidTraderNotificationScheduler: dependencies.voidTraderNotificationScheduler,
                            errorManager: dependencies.errorManager
                        ),
                        displayName: viewModel.displayName,
                        onCacheCleared: onCacheCleared
                    )
                }
                .task {
                    await viewModel.load()
                }
                .platformRefreshable(isDisabled: viewModel.isLoading || viewModel.profile?.isLocal == true) {
                    if viewModel.profile?.isLocal != true {
                        await viewModel.fetchProfile(forceRefresh: true)
                    }
                }
                .confirmationDialog(
                    Strings.Profile.deleteProfileTitle,
                    isPresented: $isShowingDeleteConfirmation,
                    titleVisibility: .visible,
                    presenting: profileToDelete
                ) { profile in
                    Button(Strings.Profile.deleteProfileButton, role: .destructive) {
                        Task { await viewModel.deleteProfile(profile) }
                    }
                } message: { profile in
                    Text(Strings.Profile.deleteProfileMessage(viewModel.name(for: profile)))
                }
            }

            if isShowingIdHelp {
                PlayerIdHelpAlertView(
                    dontShowAgain: dontShowIdHelpAgain,
                    onCancel: { isShowingIdHelp = false },
                    onConfirm: { dontShowAgain in
                        dontShowIdHelpAgain = dontShowAgain
                        isShowingIdHelp = false
                    }
                )
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isShowingIdHelp)
    }

    // MARK: - Subviews
    private var identityCard: some View {
        ProfileIdentityCard(
            displayName: viewModel.displayName,
            accountID: viewModel.accountId,
            isLocal: viewModel.profile?.isLocal == true,
            rank: viewModel.playerLevel,
            missionsCompleted: viewModel.totalMissionsCompleted,
            totalKills: viewModel.totalKills
        )
    }
    
    private var savedProfilesSection: some View {
        Section {
            ForEach(viewModel.savedProfiles, id: \.accountID.oid) { profile in
                Button {
                    Task { await viewModel.selectProfile(profile) }
                } label: {
                    HStack(spacing: 12) {
                        DashboardIcon(name: profile.isLocal ? "pencil.circle" : "person.crop.circle", size: 36)
                        Text(viewModel.name(for: profile))
                            .font(.headline)
                            .foregroundStyle(Color.labelPrimary)
                        Spacer()
                        if profile.accountID.oid == viewModel.accountId {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(DashboardPalette.accent(in: colorScheme))
                        }
                    }
                    .padding(.vertical, 6)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        profileToDelete = profile
                        isShowingDeleteConfirmation = true
                    } label: {
                        Label(Strings.Profile.deleteProfileButton, systemImage: "trash")
                    }
                }
                .contextMenu {
                    Button(role: .destructive) {
                        profileToDelete = profile
                        isShowingDeleteConfirmation = true
                    } label: {
                        Label(Strings.Profile.deleteProfileButton, systemImage: "trash")
                    }
                }
            }
            if !viewModel.savedProfiles.contains(where: \.isLocal) {
                Button {
                    Task { await viewModel.createLocalProfile() }
                } label: {
                    Label(Strings.Profile.manualProfile, systemImage: "plus.circle")
                }
            }
        } header: {
            DashboardSectionHeader(title: Strings.Profile.savedProfilesHeader, icon: "person.2")
        }
        .listRowBackground(Color.surface)
        .listRowSeparatorTint(Color.divider)
        .disabled(viewModel.isLoading)
    }

    private var playerIdSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text(Strings.Profile.id)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.labelSecondary)
                HStack(spacing: 12) {
                    TextField(Strings.Profile.idPlaceholder, text: $viewModel.playerId)
                        .focused($isIDInputFocused)
                        .font(.body.monospaced())
                        .foregroundStyle(Color.labelPrimary)
                        .onSubmit {
                            Task { await viewModel.fetchProfile() }
                        }
                    Image(systemName: "pencil")
                        .foregroundStyle(isIDInputFocused ? Color.accentColor : .secondary)
                        .accessibilityHidden(true)
                }
                .padding(14)
                .background(Color.bg, in: .rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(isIDInputFocused ? Color.accentColor : Color.divider, lineWidth: 1)
                }
            }
            .padding(.vertical, 6)
            Button {
                Task { await viewModel.fetchProfile(forceRefresh: true) }
            } label: {
                HStack {
                    Label(Strings.Profile.syncButton, systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)
                    Spacer()
                    if viewModel.isLoading {
                        LotusLoaderView(size: 20)
                    }
                }
            }
            .disabled(viewModel.isLoading || viewModel.playerId.isEmpty)
        } footer: {
            Button {
                isShowingIdHelp = true
            } label: {
                Label(Strings.Profile.idHelpTrigger, systemImage: "info.circle")
            }
            .font(.caption)
        }
        .listRowBackground(Color.surface)
        .listRowSeparatorTint(Color.divider)
    }

    private var statsSection: some View {
        Section {
            if !viewModel.intrinsicGroups.isEmpty {
                NavigationLink {
                    IntrinsicsView(groups: viewModel.intrinsicGroups)
                } label: {
                    Label {
                        LabeledContent(Strings.Profile.intrinsicsRow, value: viewModel.intrinsicsSummaryText)
                    } icon: {
                        Image(systemName: "sparkles")
                    }
                }
            }
            if !viewModel.itemStats.isEmpty {
                NavigationLink {
                    ProfileItemsListView(viewModel: .init(items: viewModel.itemStats))
                } label: {
                    Label {
                        LabeledContent(Strings.Profile.itemsRow, value: "\(viewModel.itemStats.count)")
                    } icon: {
                        Image(systemName: "square.stack.3d.up")
                    }
                }
            }
            if !viewModel.missionStats.isEmpty {
                NavigationLink {
                    ProfileMissionsListView(viewModel: .init(missions: viewModel.missionStats))
                } label: {
                    Label {
                        LabeledContent(Strings.Profile.missionsRow, value: "\(viewModel.missionStats.count)")
                    } icon: {
                        Image(systemName: "map")
                    }
                }
            }
            if !viewModel.accountStatRows.isEmpty {
                NavigationLink {
                    ProfileAccountStatsView(rows: viewModel.accountStatRows)
                } label: {
                    Label(Strings.Profile.statsRow, systemImage: "chart.bar.xaxis")
                }
            }
        } header: {
            DashboardSectionHeader(title: Strings.Profile.statsHeader, icon: "chart.bar")
        }
        .listRowBackground(Color.surface)
        .listRowSeparatorTint(Color.divider)
    }
}
