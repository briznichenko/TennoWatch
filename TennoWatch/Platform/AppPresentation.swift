import SwiftUI

enum AppPresentation {
    #if os(macOS)
    static let worldStateColumns = [GridItem(.adaptive(minimum: 260))]
    static let masteryCategoryColumns = [GridItem(.adaptive(minimum: 220))]
    static let masteryCategoryHorizontalPadding: CGFloat = 0
    #else
    static let worldStateColumns = [GridItem(.flexible()), GridItem(.flexible())]
    static let masteryCategoryColumns = [GridItem(.flexible()), GridItem(.flexible())]
    static let masteryCategoryHorizontalPadding: CGFloat = -16
    #endif

    static var profileTabRole: TabRole? {
        if #available(anyAppleOS 27.0, *) {
            return .prominent
        }
        return nil
    }
}
