//
//  AppStartupState.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/24/26.
//

import SwiftData

enum AppStartupState {
    case ready(ModelContainer, AppDependencies)
    case failed(Error)

    init(makeContainer: () throws -> ModelContainer = {
        try ModelContainer(for: ProfileDataModel.self, MasteryCatalogDataModel.self)
    }) {
        do {
            let container = try makeContainer()
            self = .ready(container, AppDependencies(modelContainer: container))
        } catch {
            self = .failed(error)
        }
    }
}
