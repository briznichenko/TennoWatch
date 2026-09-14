//
//  ErrorService.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation
import Observation

protocol ErrorManager: Observable {
    var errorQueue: [Error] { get }
    var currentError: Error? { get }
    func append(_ error: Error)
    func beginPresentation()
    func finishPresentation()
}

@Observable
@MainActor
final class DefaultErrorManager: ErrorManager {
    private(set) var errorQueue: [Error] = []
    private(set) var isPresenting = false

    var currentError: Error? {
        errorQueue.last
    }

    func append(_ error: Error) {
        errorQueue.append(error)
    }

    func beginPresentation() {
        isPresenting = true
    }

    func finishPresentation() {
        isPresenting = false
        removeCurrent()
    }

    private func removeCurrent() {
        _ = errorQueue.popLast()
    }
}
