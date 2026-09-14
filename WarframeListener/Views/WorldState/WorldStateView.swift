//
//  WorldStateView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import SwiftUI

struct WorldStateView: View {
    @State private var viewModel: WorldStateViewModel

    init(viewModel: WorldStateViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List {
                cyclesSection
                invasionsSection
                fissuresSection
                sortieSection
                archonHuntSection
                nightwaveSection
                voidTraderSection
            }
            .themedList()
            .navigationTitle(Strings.WorldState.title)
            .overlay {
                if viewModel.isLoading && viewModel.worldState == nil {
                    ProgressView()
                }
            }
            .handleErrorAlert(with: viewModel.errorManager)
            .task {
                await viewModel.fetchWorldState()
            }
            .refreshable {
                await viewModel.fetchWorldState()
            }
        }
    }

    @ViewBuilder
    private var cyclesSection: some View {
        if !viewModel.cycles.isEmpty {
            Section {
                ForEach(viewModel.cycles) { cycle in
                    CycleRowView(cycle: cycle)
                }
            } header: {
                SectionHeaderLabel(Strings.WorldState.cyclesHeader)
            }
        }
    }

    @ViewBuilder
    private var invasionsSection: some View {
        if !viewModel.invasions.isEmpty {
            Section {
                ForEach(viewModel.invasions) { invasion in
                    InvasionView(invasion: invasion)
                }
            } header: {
                SectionHeaderLabel(Strings.WorldState.invasionsHeader)
            }
        }
    }

    @ViewBuilder
    private var fissuresSection: some View {
        if !viewModel.fissures.isEmpty {
            Section {
                ForEach(viewModel.fissures, id: \.nodeKey) { fissure in
                    FissureRowView(fissure: fissure)
                }
            } header: {
                SectionHeaderLabel(Strings.WorldState.fissuresHeader)
            }
        }
    }

    @ViewBuilder
    private var sortieSection: some View {
        if let sortie = viewModel.worldState?.sortie {
            Section {
                SortieRowView(sortie: sortie)
            } header: {
                SectionHeaderLabel(Strings.WorldState.sortieHeader)
            }
        }
    }

    @ViewBuilder
    private var archonHuntSection: some View {
        if let archonHunt = viewModel.worldState?.archonHunt {
            Section {
                SortieRowView(sortie: archonHunt)
            } header: {
                SectionHeaderLabel(Strings.WorldState.archonHuntHeader)
            }
        }
    }

    @ViewBuilder
    private var nightwaveSection: some View {
        if let nightwave = viewModel.worldState?.nightwave {
            Section {
                NightwaveRowView(nightwave: nightwave)
            } header: {
                SectionHeaderLabel(Strings.WorldState.nightwaveHeader)
            }
        }
    }

    @ViewBuilder
    private var voidTraderSection: some View {
        if let voidTrader = viewModel.worldState?.voidTrader {
            Section {
                VoidTraderRowView(voidTrader: voidTrader)
            } header: {
                SectionHeaderLabel(Strings.WorldState.voidTraderHeader)
            }
        }
    }
}

#Preview {
    WorldStateView(
        viewModel: .init(
            worldStateRepository: DefaultWorldStateRepository(),
            errorManager: DefaultErrorManager()
        )
    )
}
