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
            Color.black.opacity(Layout.backdropOpacity)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            VStack(spacing: Layout.contentSpacing) {
                Text(Strings.Profile.idHelpTitle)
                    .font(.headline)
                    .foregroundStyle(Color.labelPrimary)

                VStack(alignment: .leading, spacing: Layout.instructionSpacing) {
                    Text(Strings.Profile.idHelpIntro)
                    Link(Strings.Profile.idHelpLinkTitle, destination: URL("https://www.warframe.com/api/user-data"))
                    Text(Strings.Profile.idHelpCredit)
                }
                .font(.footnote)
                .foregroundStyle(Color.labelSecondary)

                Button {
                    dontShowAgain.toggle()
                } label: {
                    HStack(spacing: Layout.instructionSpacing) {
                        Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                            .foregroundStyle(dontShowAgain ? Color.accentColor : .secondary)
                        Text(Strings.Profile.idHelpDontShowAgain)
                            .foregroundStyle(Color.labelPrimary)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: Layout.buttonSpacing) {
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
            .padding(Layout.contentPadding)
            .background(.surface, in: .rect(cornerRadius: Layout.cornerRadius))
            .frame(maxWidth: Layout.maximumWidth)
            .padding(.horizontal, Layout.horizontalMargin)
        }
        .transition(.opacity)
    }
}

private struct Layout {
    static let backdropOpacity = 0.4
    static let contentSpacing: CGFloat = 16
    static let instructionSpacing: CGFloat = 8
    static let buttonSpacing: CGFloat = 12
    static let contentPadding: CGFloat = 20
    static let cornerRadius: CGFloat = 16
    static let maximumWidth: CGFloat = 480
    static let horizontalMargin: CGFloat = 32
}

#Preview {
    PlayerIdHelpAlertView(dontShowAgain: false, onCancel: {}, onConfirm: { _ in })
}
