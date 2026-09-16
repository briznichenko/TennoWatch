//
//  SupportMailComposeView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI
import MessageUI

// `MFMailComposeViewController` has no SwiftUI equivalent — SwiftUI's own mail affordance
// is a `mailto:` URL, which hands off to the Mail app and gives no way to know whether the
// user actually sent anything. This wraps the UIKit controller for that one capability;
// everything else in this app stays SwiftUI, per this project's convention.
struct SupportMailComposeView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let composer: SupportMailComposer

    // MARK: - Functions
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.setToRecipients([recipient])
        controller.setSubject(subject)
        controller.mailComposeDelegate = composer
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

// `MFMailComposeViewControllerDelegate` predates Swift Concurrency and only offers a
// "call me back exactly once" delegate method — there's no async alternative to bridge
// to, so this type exists purely to turn that callback into something `await`-able.
// `NSObject` conformance is required because `MFMailComposeViewControllerDelegate`, like
// most pre-Concurrency UIKit delegate protocols, inherits from `NSObjectProtocol`.
final class SupportMailComposer: NSObject, MFMailComposeViewControllerDelegate {
    enum ComposeResult {
        case sent, saved, cancelled
    }

    // MARK: - Object Properties

    // `withCheckedThrowingContinuation`'s single hazard: the closure it hands you must
    // resume the continuation on every path, exactly once. Resume it twice and the
    // runtime traps; never resume it and the awaiting Task suspends forever with no
    // compiler warning either way — this stored continuation, plus the `defer` in
    // `mailComposeController(_:didFinishWith:error:)` below, is what guarantees exactly
    // one resume no matter which branch that delegate method takes.
    private var continuation: CheckedContinuation<ComposeResult, Error>?

    // MARK: - Functions

    // Presentation itself is driven by SwiftUI (`.sheet`), not by this function — it only
    // waits for the result. Attach it as `.task { ... }` on the presented sheet's content.
    func waitForResult() async throws -> ComposeResult {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        defer { continuation = nil }

        if let error {
            continuation?.resume(throwing: error)
            return
        }
        switch result {
        case .sent: continuation?.resume(returning: .sent)
        case .saved: continuation?.resume(returning: .saved)
        case .cancelled, .failed: continuation?.resume(returning: .cancelled)
        @unknown default: continuation?.resume(returning: .cancelled)
        }
    }
}
