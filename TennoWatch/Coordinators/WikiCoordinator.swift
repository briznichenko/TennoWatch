//
//  WikiCoordinator.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/11/26.
//

import SwiftUI

@Observable
final class WikiCoordinator {
    struct Destination: Identifiable {
        let name: String

        var id: String { name }

        var url: URL {
            URL("https://wiki.warframe.com/w/Special:Search")
                .appending(queryItems: [
                    URLQueryItem(name: "search", value: name),
                    URLQueryItem(name: "go", value: "Go")
                ])
        }
    }

    var destination: Destination?

    func showItem(named name: String) {
        destination = Destination(name: name)
    }

    func dismiss() {
        destination = nil
    }
}

extension EnvironmentValues {
    @Entry var wikiCoordinator: WikiCoordinator?
}
