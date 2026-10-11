//
//  OpeningsSourceCategoryDetailView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct OpeningsSourceCategoryDetailView: View {
    @State private var viewModel: OpeningsSourceCategoryDetailViewModel

    init(viewModel: OpeningsSourceCategoryDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ThemedList {
            if viewModel.isNodeCategory {
                ForEach(viewModel.nodePlanetSections) { section in
                    Section {
                        ForEach(section.items) { group in
                            if let planet = group.planet {
                                Text(planet)
                                    .font(.headline)
                                    .foregroundStyle(Color.labelSecondary)
                                    .listRowSeparator(.hidden)
                            }
                            ForEach(group.sources) { source in
                                MasterySourceView(viewModel: source, showsNodeDetails: true)
                            }
                        }
                    } header: {
                        SectionHeaderLabel(section.mode.title)
                    }
                }
            } else if viewModel.isStarChartCategory {
                ForEach(viewModel.starChartSections) { section in
                    Section {
                        ForEach(section.items) { source in
                            MasterySourceView(viewModel: source, showsNodeDetails: true)
                        }
                    } header: {
                        SectionHeaderLabel(section.mode.title)
                    }
                }
            } else {
                ForEach(viewModel.filteredSources) { source in
                    MasterySourceView(viewModel: source)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: viewModel.isStarChartCategory ? Strings.Common.searchNodes : Strings.Common.search)
        .navigationTitle(viewModel.categoryName.sentenceCased)
        .inlineNavigationTitle()
    }
}
