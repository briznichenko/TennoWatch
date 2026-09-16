//
//  ErrorAlertModifier.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation
import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    // MARK: - Object Properties
    var errorManager: ErrorManager

    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .alert(
                Strings.ErrorAlert.title,
                isPresented: Binding(
                    get: { errorManager.currentError != nil },
                    set: { isPresented in
                        if !isPresented {
                            errorManager.finishPresentation()
                        }
                    }
                )
            ) {
                Button(Strings.ErrorAlert.okButton) { }
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
