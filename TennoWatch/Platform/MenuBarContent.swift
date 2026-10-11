#if os(macOS)
import AppKit
import SwiftUI

enum MenuBarIcon {
    static let image: NSImage = {
        let renderer = ImageRenderer(content:
            LotusMark()
                .stroke(.black, style: StrokeStyle(lineWidth: IconLayout.strokeWidth, lineCap: .round, lineJoin: .round))
                .frame(width: IconLayout.width, height: IconLayout.height)
        )
        renderer.scale = IconLayout.renderScale
        let image = renderer.nsImage
            ?? NSImage(systemSymbolName: "leaf", accessibilityDescription: "TennoWatch")
            ?? NSImage(size: NSSize(width: IconLayout.width, height: IconLayout.height))
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
private struct IconLayout {
    static let strokeWidth: CGFloat = 1.5
    static let width: CGFloat = 22
    static let height: CGFloat = 18
    static let renderScale: CGFloat = 2
}
#endif
