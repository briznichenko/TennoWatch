//
//  PlayerIdHelpAlertView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/17/26.
//

import SwiftUI

struct PlayerIdHelpAlertView: View {
    // MARK: - Object Properties
    @State private var dontShowAgain: Bool

    let onCancel: () -> Void
    let onConfirm: (Bool) -> Void

    // MARK: - Init
    init(dontShowAgain: Bool, onCancel: @escaping () -> Void, onConfirm: @escaping (Bool) -> Void) {
        self._dontShowAgain = State(initialValue: dontShowAgain)
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            VStack(spacing: 16) {
                Text(Strings.Profile.idHelpTitle)
                    .font(.headline)
                    .foregroundStyle(Color.labelPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    Text(Strings.Profile.idHelpIntro)
                    Link(Strings.Profile.idHelpLinkTitle, destination: URL("https://www.warframe.com/api/user-data"))
                    Text(Strings.Profile.idHelpCredit)
                }
                .font(.footnote)
                .foregroundStyle(Color.labelSecondary)

                Button {
                    dontShowAgain.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                            .foregroundStyle(dontShowAgain ? Color.accentColor : .secondary)
                        Text(Strings.Profile.idHelpDontShowAgain)
                            .foregroundStyle(Color.labelPrimary)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: 12) {
                    Button(Strings.Profile.idHelpCancelButton, role: .cancel, action: onCancel)
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    Button(Strings.Profile.idHelpOkButton) {
                        onConfirm(dontShowAgain)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .background(.surface, in: .rect(cornerRadius: 16))
            .padding(.horizontal, 32)
        }
        .transition(.opacity)
    }
}

#Preview {
    PlayerIdHelpAlertView(dontShowAgain: false, onCancel: {}, onConfirm: { _ in })
}
