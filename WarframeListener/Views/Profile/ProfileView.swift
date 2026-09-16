//
//  ProfileView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI

struct ProfileView: View {
    // MARK: - Object Properties
    @State private var viewModel: ProfileViewModel
    @State private var isShowingSettings = false
    @FocusState private var isIDInputFocused

    private let dependencies: AppDependencies

    // MARK: - Init
    init(viewModel: ProfileViewModel, dependencies: AppDependencies) {
        self.viewModel = viewModel
        self.dependencies = dependencies
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                identityCard
                    .listRowSeparator(.hidden)
                playerIdSection
                statsSection
            }
            .navigationTitle(Strings.Profile.title)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .handleErrorAlert(with: viewModel.errorManager)
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(
                    viewModel: .init(
                        persistencyService: dependencies.persistencyService,
                        catalogRepository: dependencies.catalogRepository,
                        profileRepository: dependencies.profileRepository,
                        errorManager: dependencies.errorManager
                    ),
                    displayName: viewModel.displayName
                )
            }
            .task {
                await viewModel.fetchProfile()
            }
            .refreshable {
                await viewModel.fetchProfile(forceRefresh: true)
            }
        }
    }

    // MARK: - Subviews
    private var identityCard: some View {
        Surface {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.displayName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.label)
                Text(viewModel.playerId)
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
    
    private var playerIdSection: some View {
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
    }

    private func statPair(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value.formatted())
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.label)
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
                    ProfileItemsListView(items: viewModel.itemStats)
                } label: {
                    LabeledContent(Strings.Profile.itemsRow, value: "\(viewModel.itemStats.count)")
                }
            }
            if !viewModel.missionStats.isEmpty {
                NavigationLink {
                    ProfileMissionsListView(missions: viewModel.missionStats)
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
