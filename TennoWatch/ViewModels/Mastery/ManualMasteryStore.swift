//
//  ManualMasteryStore.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 11/12/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class ManualMasteryStore {
    private let catalogRepository: CatalogRepository
    private let errorManager: ErrorManager

    private(set) var revision = 0
    private(set) var isSaving = false

    init(catalogRepository: CatalogRepository, errorManager: ErrorManager) {
        self.catalogRepository = catalogRepository
        self.errorManager = errorManager
    }

    func profileID() async -> String? {
        do {
            return try await catalogRepository.getManualProfileID()
        } catch {
            if !Task.isCancelled && !(error is CancellationError) {
                errorManager.append(error)
            }
            return nil
        }
    }

    func setMastered(_ mastered: Bool, itemIDs: Set<String>, profileID: String) async -> Bool {
        guard !isSaving, !itemIDs.isEmpty else { return false }
        isSaving = true
        defer { isSaving = false }
        do {
            try await catalogRepository.setMastered(mastered, itemIDs: itemIDs, profileID: profileID)
            revision += 1
            return true
        } catch {
            if !Task.isCancelled && !(error is CancellationError) {
                errorManager.append(error)
            }
            return false
        }
    }
}

