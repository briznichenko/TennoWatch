//
//  ProfileView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/11/26.
//

import SwiftUI

struct AddProfileSheet: View {
    let viewModel: ProfileViewModel

    @State private var playerID = ""
    @State private var isSubmitting = false
    @State private var isShowingIdHelp = false
    @AppStorage("profileIdHelpDontShowAgain") private var dontShowIdHelpAgain = false
    @FocusState private var isIDInputFocused: Bool
    @Environment(\.dismiss) private var dismiss

    private var canAddProfile: Bool {
        !isSubmitting && !viewModel.isLoading && !playerID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            NavigationStack {
                Form {
                    Section {
                        TextField(Strings.Profile.idPlaceholder, text: $playerID)
                            .font(.body.monospaced())
                            .focused($isIDInputFocused)
                            .autocorrectionDisabled()
                            .onSubmit(submit)
                    } header: {
                        Text(Strings.Profile.id)
                    } footer: {
                        Button {
                            isIDInputFocused = false
                            isShowingIdHelp = true
                        } label: {
                            Label(Strings.Profile.idHelpTrigger, systemImage: "info.circle")
                        }
                    }
                }
                .themedList()
                .disabled(isSubmitting)
                .overlay {
                    if isSubmitting {
                        LotusLoaderView()
                    }
                }
                .navigationTitle(Strings.Profile.addProfile)
                .inlineNavigationTitle()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Strings.Profile.idHelpCancelButton) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: submit) {
                            Label(Strings.Profile.addProfile, systemImage: "plus")
                                .labelStyle(.iconOnly)
                        }
                        .disabled(!canAddProfile)
                    }
                }
            }

            if isShowingIdHelp {
                PlayerIdHelpAlertView(
                    dontShowAgain: dontShowIdHelpAgain,
                    onCancel: { isShowingIdHelp = false },
                    onConfirm: { dontShowAgain in
                        dontShowIdHelpAgain = dontShowAgain
                        isShowingIdHelp = false
                    }
                )
            }
        }
        .handleErrorAlert(with: viewModel.errorManager)
        .task(id: isSubmitting) {
            guard isSubmitting else { return }
            if await viewModel.addProfile(playerID: playerID) {
                dismiss()
            }
            isSubmitting = false
        }
    }

    private func submit() {
        guard canAddProfile else { return }
        isIDInputFocused = false
        isSubmitting = true
    }
}
