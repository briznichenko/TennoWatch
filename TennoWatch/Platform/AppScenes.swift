import SwiftUI

enum AppSceneID {
    static let main = "main"
}

struct AppScenes<Content: View, SettingsContent: View>: Scene {
    private let content: () -> Content
    private let settings: () -> SettingsContent

    init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder settings: @escaping () -> SettingsContent) {
        self.content = content
        self.settings = settings
    }

    var body: some Scene {
        #if os(macOS)
        Window("TennoWatch", id: AppSceneID.main) {
            content()
                .frame(minWidth: WindowLayout.minimumWidth, minHeight: WindowLayout.minimumHeight)
        }
        .defaultSize(width: WindowLayout.defaultWidth, height: WindowLayout.defaultHeight)

        Settings {
            settings()
        }

        MenuBarExtra {
            MenuBarContent()
        } label: {
            Image(nsImage: MenuBarIcon.image)
                .accessibilityLabel("TennoWatch")
        }
        .menuBarExtraStyle(.menu)
        #else
        WindowGroup {
            content()
        }
        #endif
    }
}

private struct WindowLayout {
    static let minimumWidth: CGFloat = 820
    static let minimumHeight: CGFloat = 600
    static let defaultWidth: CGFloat = 1100
    static let defaultHeight: CGFloat = 760
}
