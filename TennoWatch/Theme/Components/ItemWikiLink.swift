//
//  ItemWikiLink.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/11/26.
//

import SwiftUI

struct ItemWikiLink: View {
    @Environment(\.wikiCoordinator) private var coordinator
    let itemName: String

    var body: some View {
        Button {
            coordinator?.showItem(named: itemName)
        } label: {
            Text(Strings.Common.lookOnWiki)
                .font(.caption)
                .frame(minHeight: ListLayout.minimumRowHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(Strings.Common.openItemWiki(itemName))
        .help(Strings.Common.openItemWiki(itemName))
    }
}
