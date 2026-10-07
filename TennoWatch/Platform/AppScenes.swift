import SwiftUI

struct AppScenes<Content: View, SettingsContent: View>: Scene {
    private let content: () -> Content
    private let settings: () -> SettingsContent

    init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder settings: @escaping () -> SettingsContent) {
        self.content = content
        self.settings = settings
    }

    var body: some Scene {
        #if os(macOS)
        Window("TennoWatch", id: "main") {
            content()
                .frame(minWidth: 820, minHeight: 600)
        }
        .defaultSize(width: 1100, height: 760)

        Settings {
            settings()
        }
        #else
        WindowGroup {
            content()
        }
        #endif
    }
}
