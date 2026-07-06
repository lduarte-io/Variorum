//
//  FallbackCanary.swift
//  Variorum
//
//  The TK2→TK1 silent-fallback canary (TEXTKIT2_NOTES §4.3), armed from the
//  first editor commit per the accepted Phase 6 memo. The spike established
//  that fallback is NOT a normal event on this stack — any firing is a
//  regression (a newly-touched API or an OS change), never telemetry noise.
//
//  Posture (author-accepted memo): debug builds assertionFailure (stop the
//  world); release builds os_log fault + a visible in-app diagnostic (the
//  EditorViewModel renders a banner). Any firing is a P1-class bug.
//

import AppKit
import os

@MainActor
final class FallbackCanary {
    private static let log = Logger(subsystem: "io.lduarte.Variorum", category: "tk2-canary")

    private var tokens: [NSObjectProtocol] = []
    private(set) var fired = false

    /// Called on the main actor when the canary fires (release builds reach
    /// this; debug builds stop at the assertion first).
    var onFire: ((String) -> Void)?

    /// Arms for ONE text view (scoped, so multiple editors attribute
    /// correctly).
    func arm(for textView: NSTextView) {
        guard tokens.isEmpty else { return }
        let pairs: [(Notification.Name, String)] = [
            (NSTextView.willSwitchToNSLayoutManagerNotification, "will switch"),
            (NSTextView.didSwitchToNSLayoutManagerNotification, "did switch"),
        ]
        for (name, phase) in pairs {
            tokens.append(NotificationCenter.default.addObserver(
                forName: name, object: textView, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.fire(phase: phase)
                }
            })
        }
    }

    func disarm() {
        for token in tokens { NotificationCenter.default.removeObserver(token) }
        tokens.removeAll()
    }

    private func fire(phase: String) {
        fired = true
        let message = "TextKit 2 -> TextKit 1 fallback (\(phase) NSLayoutManager). "
            + "A TK1 API or OS change downgraded the editor; P1-class bug (TEXTKIT2_NOTES §0/§4)."
        Self.log.fault("\(message, privacy: .public)")
        assertionFailure(message) // debug: stop the world (memo posture)
        onFire?(message)          // release: visible in-app diagnostic
    }

    deinit {
        // Tokens are removed by disarm(), which the editor view's dismantle
        // calls. Note: block-based observer tokens are NOT auto-unregistered
        // by NotificationCenter (only selector-based observers are) — a
        // canary leaked without disarm() would leak its observation blocks.
        // Acceptable for a diagnostic; the teardown path always disarms.
    }
}
