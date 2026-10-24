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
    @State private var isShowingAddProfile = false
    @Environment(\.colorScheme) private var colorScheme

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
        NavigationStack {
            List {
                identityCard
                    .listRowInsets(Layout.identityCardInsets)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                savedProfilesSection
                statsSection
            }
            .profileListStyle()
            .compactListSections()
            .buttonStyle(.plain)
            .foregroundStyle(Color.labelPrimary)
            .scrollContentBackground(.hidden)
            .frame(maxWidth: DashboardLayout.maximumContentWidth)
            .frame(maxWidth: .infinity)
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
            .sheet(isPresented: $isShowingAddProfile) {
                AddProfileSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.load()
            }
            .platformRefreshable(isDisabled: viewModel.isLoading || viewModel.profile?.isLocal == true) {
                if viewModel.profile?.isLocal != true {
                    await viewModel.syncProfile()
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
    }

    // MARK: - Subviews
    private var identityCard: some View {
        ProfileIdentityCard(
            displayName: viewModel.displayName,
            accountID: viewModel.accountId,
            isLocal: viewModel.profile?.isLocal == true,
            rank: viewModel.playerLevel,
            missionsCompleted: viewModel.totalMissionsCompleted,
            totalKills: viewModel.totalKills,
            isSyncing: viewModel.isLoading,
            onSync: { Task { await viewModel.syncProfile() } }
        )
    }
    
    private var savedProfilesSection: some View {
        Section {
            ForEach(viewModel.savedProfiles, id: \.accountID.oid) { profile in
                Button {
                    Task { await viewModel.selectProfile(profile) }
                } label: {
                    ProfileRow(
                        title: viewModel.name(for: profile),
                        icon: profile.isLocal ? "pencil.circle" : "person.crop.circle",
                        isSelected: profile.accountID.oid == viewModel.accountId
                    )
                }
                .accessibilityAddTraits(profile.accountID.oid == viewModel.accountId ? .isSelected : [])
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
            Button {
                isShowingAddProfile = true
            } label: {
                ProfileRow(title: Strings.Profile.addProfile, icon: "plus.circle")
            }
            if !viewModel.savedProfiles.contains(where: \.isLocal) {
                Button {
                    Task { await viewModel.createLocalProfile() }
                } label: {
                    ProfileRow(title: Strings.Profile.manualProfile, icon: "pencil.circle")
                }
            }
        } header: {
            DashboardSectionHeader(title: Strings.Profile.savedProfilesHeader, icon: "person.2")
                .padding(.vertical, Layout.sectionHeaderPadding)
        }
        .listRowInsets(Layout.identityCardInsets)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .disabled(viewModel.isLoading)
    }

    private var statsSection: some View {
        Section {
            if !viewModel.intrinsicGroups.isEmpty {
                NavigationLink {
                    IntrinsicsView(groups: viewModel.intrinsicGroups)
                } label: {
                    ProfileRow(title: Strings.Profile.intrinsicsRow, icon: "sparkles", value: viewModel.intrinsicsSummaryText, showsDisclosure: true)
                }
            }
            if !viewModel.itemStats.isEmpty {
                NavigationLink {
                    ProfileItemsListView(viewModel: .init(items: viewModel.itemStats))
                } label: {
                    ProfileRow(title: Strings.Profile.itemsRow, icon: "square.stack.3d.up", value: viewModel.itemStats.count.formatted(), showsDisclosure: true)
                }
            }
            if !viewModel.missionStats.isEmpty {
                NavigationLink {
                    ProfileMissionsListView(viewModel: .init(missions: viewModel.missionStats))
                } label: {
                    ProfileRow(title: Strings.Profile.missionsRow, icon: "map", value: viewModel.missionStats.count.formatted(), showsDisclosure: true)
                }
            }
            if !viewModel.accountStatRows.isEmpty {
                NavigationLink {
                    ProfileAccountStatsView(rows: viewModel.accountStatRows)
                } label: {
                    ProfileRow(title: Strings.Profile.statsRow, icon: "chart.bar.xaxis", showsDisclosure: true)
                }
            }
        } header: {
            DashboardSectionHeader(title: Strings.Profile.statsHeader, icon: "chart.bar")
                .padding(.vertical, Layout.sectionHeaderPadding)
        }
        .navigationLinkIndicatorVisibility(.hidden)
        .listRowInsets(Layout.identityCardInsets)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

private struct ProfileRow: View {
    let title: String
    let icon: String
    var value: String?
    var isSelected = false
    var showsDisclosure = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: ListLayout.iconSpacing) {
            DashboardIcon(name: icon)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: ListLayout.detailSpacing))
                : AnyLayout(HStackLayout(spacing: ListLayout.iconSpacing))
            layout {
                Text(title)
                    .foregroundStyle(Color.labelPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let value {
                    Text(value)
                        .font(.body)
                        .foregroundStyle(Color.labelSecondary)
                        .monospacedDigit()
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(DashboardPalette.accent(in: colorScheme))
                    .frame(width: Layout.accessoryWidth)
                    .accessibilityHidden(true)
            } else if showsDisclosure {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.labelSecondary)
                    .frame(width: Layout.accessoryWidth)
                    .accessibilityHidden(true)
            }
        }
        .font(.body)
        .frame(maxWidth: .infinity, minHeight: ListLayout.minimumRowHeight, alignment: .leading)
        .padding(Layout.rowInsets)
        .background(DashboardCardBackground())
        .contentShape(.rect(cornerRadius: DashboardLayout.cardCornerRadius))
        .accessibilityElement(children: .combine)
    }
}

private struct Layout {
    static let identityCardInsets = EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
    static let rowInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    static let sectionHeaderPadding: CGFloat = 8
    static let accessoryWidth: CGFloat = 20
}
