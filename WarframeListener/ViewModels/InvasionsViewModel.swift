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
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    private let apiManager: APIManager
    private var cancellables = Set<AnyCancellable>()

    init(apiManager: APIManager = APIManager()) {
        self.apiManager = apiManager
    }

    func fetchInvasions() {
        isLoading = true
        errorMessage = nil

        apiManager.fetch(.invasions)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] (invasions: Invasions) in
                self?.invasions = invasions
            }
            .store(in: &cancellables)
    }
}
