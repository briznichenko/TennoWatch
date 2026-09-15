//
//  WorldStateListView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct WorldStateListView: View {
    // MARK: - Object Properties
    let viewModel: WorldStateViewModel

    // MARK: - Body
    var body: some View {
        List {
            voidTraderSection
            nightwaveSection
            invasionsSection
            cyclesSection
            fissuresSection
            sortieSection
            archonHuntSection
        }
    }

    // MARK: - Subviews
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
