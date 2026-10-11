import SwiftUI

enum AppPresentation {
    #if os(macOS)
    static let worldStateColumns = [GridItem(.adaptive(minimum: Layout.worldStateMinimumColumnWidth))]
    static let masteryCategoryColumns = [GridItem(.adaptive(minimum: Layout.masteryMinimumColumnWidth))]
    static let masteryCategoryHorizontalPadding: CGFloat = 0
    #else
    static let worldStateColumns = [GridItem(.flexible()), GridItem(.flexible())]
    static let masteryCategoryColumns = [GridItem(.flexible()), GridItem(.flexible())]
    static let masteryCategoryHorizontalPadding: CGFloat = -DashboardLayout.contentPadding
    #endif

    static var profileTabRole: TabRole? {
        if #available(anyAppleOS 27.0, *) {
            return .prominent
        }
        return nil
    }
}

private struct Layout {
    static let worldStateMinimumColumnWidth: CGFloat = 260
    static let masteryMinimumColumnWidth: CGFloat = 220
}
