//
//  WorldStateGridView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct WorldStateGridView: View {
    // MARK: - Object Properties
    let viewModel: WorldStateViewModel

    private static let columns = [GridItem(.flexible()), GridItem(.flexible())]

    // MARK: - Body
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Self.columns, spacing: 12) {
                cyclesCard
                invasionsCard
                fissuresCard
                sortieCard
                archonHuntCard
                nightwaveCard
                voidTraderCard
                vaultTraderCard
                steelPathCard
                alertsCard
                archimedeaCard
                calendarCard
            }
            .padding(12)
        }
        .buttonStyle(.plain)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Cards
    @ViewBuilder
    private var cyclesCard: some View {
        if !viewModel.cycles.isEmpty {
            NavigationLink {
                CycleListView(cycles: viewModel.cycles)
            } label: {
                CardView(icon: "clock.arrow.2.circlepath", title: Strings.WorldState.cyclesHeader) {
                    Text("\(viewModel.cycles.count)")
                }
            }
        }
    }

    @ViewBuilder
    private var invasionsCard: some View {
        if !viewModel.invasions.isEmpty {
            NavigationLink {
                InvasionListView(groups: viewModel.invasionsByPlanet)
            } label: {
                CardView(icon: "flame.fill", title: Strings.WorldState.invasionsHeader) {
                    Text("\(viewModel.invasions.count)")
                }
            }
        }
    }

    @ViewBuilder
    private var fissuresCard: some View {
        if !viewModel.fissures.isEmpty {
            NavigationLink {
                FissureListView(groups: viewModel.fissuresByTier)
            } label: {
                CardView(icon: "tornado", title: Strings.WorldState.fissuresHeader) {
                    Text("\(viewModel.fissures.count)")
                }
            }
        }
    }

    @ViewBuilder
    private var sortieCard: some View {
        if let sortie = viewModel.worldState?.sortie {
            NavigationLink {
                SortieDetailView(title: Strings.WorldState.sortieHeader, sortie: sortie)
            } label: {
                CardView(icon: "star.circle.fill", title: Strings.WorldState.sortieHeader) {
                    Text(sortie.boss)
                }
            }
        }
    }

    @ViewBuilder
    private var archonHuntCard: some View {
        if let archonHunt = viewModel.worldState?.archonHunt {
            NavigationLink {
                SortieDetailView(title: Strings.WorldState.archonHuntHeader, sortie: archonHunt)
            } label: {
                CardView(icon: "shield.righthalf.filled", title: Strings.WorldState.archonHuntHeader) {
                    Text(archonHunt.boss)
                }
            }
        }
    }

    @ViewBuilder
    private var nightwaveCard: some View {
        if let nightwave = viewModel.worldState?.nightwave {
            NavigationLink {
                NightwaveListView(nightwave: nightwave)
            } label: {
                CardView(icon: "dot.radiowaves.left.and.right", title: Strings.WorldState.nightwaveHeader) {
                    Text(Strings.WorldState.nightwaveChallengesCount(nightwave.activeChallenges.count))
                }
            }
        }
    }

    @ViewBuilder
    private var voidTraderCard: some View {
        if let voidTrader = viewModel.worldState?.voidTrader {
            NavigationLink {
                TraderInventoryListView(trader: voidTrader)
            } label: {
                CardView(icon: "person.fill.questionmark", title: Strings.WorldState.voidTraderHeader) {
                    LiveCountdownText(date: voidTrader.expiry)
                }
            }
        }
    }

    @ViewBuilder
    private var vaultTraderCard: some View {
        if let vaultTrader = viewModel.vaultTrader {
            NavigationLink {
                TraderInventoryListView(trader: vaultTrader)
            } label: {
                CardView(icon: "lock.fill", title: Strings.WorldState.vaultTraderHeader) {
                    LiveCountdownText(date: vaultTrader.expiry)
                }
            }
        }
    }

    @ViewBuilder
    private var steelPathCard: some View {
        if let steelPath = viewModel.steelPath {
            NavigationLink {
                SteelPathDetailView(steelPath: steelPath)
            } label: {
                CardView(icon: "graduationcap.fill", title: Strings.WorldState.steelPathHeader) {
                    Text(steelPath.remaining)
                }
            }
        }
    }

    @ViewBuilder
    private var alertsCard: some View {
        if !viewModel.alerts.isEmpty {
            NavigationLink {
                AlertListView(alerts: viewModel.alerts)
            } label: {
                CardView(icon: "bell.fill", title: Strings.WorldState.alertsHeader) {
                    Text("\(viewModel.alerts.count)")
                }
            }
        }
    }

    @ViewBuilder
    private var archimedeaCard: some View {
        if !viewModel.archimedeas.isEmpty {
            NavigationLink {
                ArchimedeaListView(archimedeas: viewModel.archimedeas)
            } label: {
                CardView(icon: "atom", title: Strings.WorldState.archimedeaHeader) {
                    Text("\(viewModel.archimedeas.count)")
                }
            }
        }
    }

    @ViewBuilder
    private var calendarCard: some View {
        if let calendar = viewModel.calendar {
            NavigationLink {
                CalendarDetailView(calendar: calendar)
            } label: {
                CardView(icon: "calendar", title: Strings.WorldState.calendarHeader) {
                    Text(calendar.season)
                }
            }
        }
    }
}
