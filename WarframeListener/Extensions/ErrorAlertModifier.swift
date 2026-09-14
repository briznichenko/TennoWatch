//
//  ErrorAlertModifier.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation
import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    var errorManager: ErrorManager
    
    func body(content: Content) -> some View {
        content
            .alert(
                "An Error Occurred",
                isPresented: Binding(
                    get: { errorManager.currentError != nil },
                    set: { isPresented in
                        if !isPresented {
                            errorManager.removeCurrent()
                        }
                    }
                )
            ) {
                Button("OK") { }
            } message: {
                if let error = errorManager.currentError {
                    Text(error.localizedDescription)
                }
            }
    }
}

extension View {
    func handleErrorAlert(with manager: ErrorManager) -> some View {
        self.modifier(ErrorAlertModifier(errorManager: manager))
    }
}
