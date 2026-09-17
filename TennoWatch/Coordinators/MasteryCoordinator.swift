//
//  MasteryCoordinator.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

@Observable
final class MasteryCoordinator {
    enum Destination: Hashable {
        case categoryDetail(CatalogItemModel.Category)
        case sourceDetail(name: String)
        case breakdown
    }

    // MARK: - Object Properties
    var path = NavigationPath()

    // MARK: - Functions
    func showCategoryDetail(_ category: CatalogItemModel.Category) {
        path.append(Destination.categoryDetail(category))
    }

    func showSourceDetail(named name: String) {
        path.append(Destination.sourceDetail(name: name))
    }

    func showBreakdown() {
        path.append(Destination.breakdown)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
