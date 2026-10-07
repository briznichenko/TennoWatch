import SwiftUI

extension View {
    @ViewBuilder
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func platformRefreshable(isDisabled: Bool, action: @escaping @MainActor @Sendable () async -> Void) -> some View {
        #if os(macOS)
        toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await action() }
                } label: {
                    Label(Strings.Main.refresh, systemImage: "arrow.clockwise")
                }
                .disabled(isDisabled)
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        #else
        refreshable(action: action)
        #endif
    }
}
