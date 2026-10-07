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
                        .listRowSeparator(.hidden)
                    savedProfilesSection
                    playerIdSection
                    statsSection
                }
                .navigationTitle(Strings.Profile.title)
                .overlay {
                    if viewModel.isLoading {
                        LotusLoaderView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        #if os(macOS)
                        SettingsLink {
                            Label(Strings.Settings.title, systemImage: "gearshape")
                        }
                        #else
                        Button {
                            isShowingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        #endif
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
        .animation(.easeInOut(duration: 0.2), value: isShowingIdHelp)
    }

    // MARK: - Subviews
    private var identityCard: some View {
        Surface {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.displayName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.labelPrimary)
                Text(viewModel.profile?.isLocal == true ? Strings.Profile.manualProfileDescription : viewModel.accountId)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(Color.secondary)
                HStack(spacing: 20) {
                    statPair(value: viewModel.playerLevel, label: Strings.Profile.masteryRankLabel)
                    statPair(value: viewModel.totalMissionsCompleted, label: Strings.Profile.missionsCompletedLabel)
                    statPair(value: viewModel.totalKills, label: Strings.Profile.totalKillsLabel)
                }
                .padding(.top, 4)
            }
        }
        .padding(.bottom, 8)
    }
    
    private var savedProfilesSection: some View {
        Section {
            ForEach(viewModel.savedProfiles, id: \.accountID.oid) { profile in
                Button {
                    Task { await viewModel.selectProfile(profile) }
                } label: {
                    HStack {
                        Label(viewModel.name(for: profile), systemImage: profile.isLocal ? "pencil.circle" : "person.crop.circle")
                        Spacer()
                        if profile.accountID.oid == viewModel.accountId {
                            Image(systemName: "checkmark")
                        }
                    }
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
            SectionHeaderLabel(Strings.Profile.savedProfilesHeader)
        }
        .disabled(viewModel.isLoading)
    }

    private var playerIdSection: some View {
        Section {
            LabeledContent(Strings.Profile.id) {
                HStack {
                    TextField(Strings.Profile.idPlaceholder, text: $viewModel.playerId)
                        .focused($isIDInputFocused)
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                        .onSubmit {
                            Task { await viewModel.fetchProfile() }
                        }
                    Image(systemName: "pencil")
                        .foregroundStyle(isIDInputFocused ? Color.accentColor : .secondary)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isIDInputFocused ? Color.accentColor : Color.gray.opacity(0.4), lineWidth: 1)
                )
            }
            Button {
                Task { await viewModel.fetchProfile(forceRefresh: true) }
            } label: {
                HStack {
                    Label(Strings.Profile.syncButton, systemImage: "arrow.triangle.2.circlepath")
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
    }

    private func statPair(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value.formatted())
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.labelPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.labelSecondary)
        }
    }

    private var statsSection: some View {
        Section {
            if !viewModel.intrinsicGroups.isEmpty {
                NavigationLink {
                    IntrinsicsView(groups: viewModel.intrinsicGroups)
                } label: {
                    LabeledContent(Strings.Profile.intrinsicsRow, value: viewModel.intrinsicsSummaryText)
                }
            }
            if !viewModel.itemStats.isEmpty {
                NavigationLink {
                    ProfileItemsListView(viewModel: .init(items: viewModel.itemStats))
                } label: {
                    LabeledContent(Strings.Profile.itemsRow, value: "\(viewModel.itemStats.count)")
                }
            }
            if !viewModel.missionStats.isEmpty {
                NavigationLink {
                    ProfileMissionsListView(viewModel: .init(missions: viewModel.missionStats))
                } label: {
                    LabeledContent(Strings.Profile.missionsRow, value: "\(viewModel.missionStats.count)")
                }
            }
            if !viewModel.accountStatRows.isEmpty {
                NavigationLink {
                    ProfileAccountStatsView(rows: viewModel.accountStatRows)
                } label: {
                    Text(Strings.Profile.statsRow)
                }
            }
        } header: {
            SectionHeaderLabel(Strings.Profile.statsHeader)
        }
    }
}
