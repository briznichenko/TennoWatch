#if os(macOS)
import AppKit
import SwiftUI

enum MenuBarIcon {
    static let image: NSImage = {
        let renderer = ImageRenderer(content:
            LotusMark()
                .stroke(.black, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .frame(width: 22, height: 18)
        )
        renderer.scale = 2
        let image = renderer.nsImage
            ?? NSImage(systemSymbolName: "leaf", accessibilityDescription: "TennoWatch")
            ?? NSImage(size: NSSize(width: 22, height: 18))
        image.isTemplate = true
        return image
    }()
}

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button(Strings.MenuBar.openApp) {
            openWindow(id: AppSceneID.main)
            NSApplication.shared.activate()
        }

        SettingsLink {
            Text(Strings.Settings.title)
        }

        Divider()

        Button(Strings.MenuBar.quit) {
            NSApplication.shared.terminate(nil)
        }
    }
}
#endif
