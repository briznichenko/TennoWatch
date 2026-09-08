//
//  MasteryViewModel.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/1/26.
//

import Foundation
import Observation

@Observable
final class MasteryViewModel {
    private(set) var statusText: String = ""
    private(set) var catalogs: [CatalogContainer] = []
    private(set) var isLoading: Bool = false
    
    let profileRepository: ProfileRepository
    let catalogRepository: CatalogRepository
    
    init(profileRepository: ProfileRepository, catalogRepository: CatalogRepository) {
        self.profileRepository = profileRepository
        self.catalogRepository = catalogRepository
    }
    
    func fetchCatalog() async {
        do {
            catalogs = try await catalogRepository.getCatalogs()
        } catch {
            statusText = error.localizedDescription
        }
    }
    
    func fetchProfile() async {
        defer {
            isLoading = false
        }
        
        isLoading = true
        statusText = "Loading..."

        do {
            let profile = try await profileRepository.getProfile(withPlayerId: .none)
            catalogs = try await catalogRepository.syncCatalogs(with: profile)
        } catch {
            statusText = error.localizedDescription
        }
    }
}
