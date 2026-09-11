//
//  InvasionsViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import Foundation
import Combine

typealias Invasions = [Invasion]

@Observable
final class InvasionsViewModel {
    private(set) var invasions: Invasions = []
    private(set) var networkMessage: String = ""
    private(set) var isLoading = false

    private let apiManager: APIManager

    init(apiManager: APIManager = APIManager()) {
        self.apiManager = apiManager
    }

    func fetchInvasions() async {
        isLoading = true
        networkMessage = "Loading..."

        do {
            let result: Invasions  = try await apiManager.fetch(.invasions)
            invasions = result.sorted(by: { $0.node < $1.node })
        } catch {
            networkMessage = error.localizedDescription
        }
    }
}
