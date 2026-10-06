//
//  MenuLifeReporter.swift
//  Variorum (Mac)
//
//  **librarywalkpolish round 1's MINOR-1 — an in-window popover that lives
//  like a MENU ends where a menu ends.** The Bookcase's order popover (VR-115)
//  is the app's own drawing, not an `NSMenu`, so AppKit never closes it: its
//  only close was a board-local catcher, and ⌘K/⌘N/⌘J or a sidebar click took
//  the board away with the popover still "open" — it greeted her return. A
//  native menu also ends when its window stops being key and when the app
//  stops being active; this reporter says those two moments (the board's own
//  `.onDisappear` says the third).
//
//  An inert AppKit view (never a click target) that observes ITS OWN window's
//  `didResignKey` and the app's `didResignActive` — the notifications AppKit
//  posts, so a pin can post the same ones and drive the whole chain. It
//  decides nothing: the caller's `onEnd` does.
//

import AppKit
import SwiftUI

extension View {
    /// Report the moments a menu's life ends that a SwiftUI view cannot see:
    /// this view's window resigning key, the app resigning active.
    func reportsMenuLifeEnds(_ onEnd: @escaping () -> Void) -> some View {
        background(MenuLifeReporter(onEnd: onEnd))
    }
}

struct MenuLifeReporter: NSViewRepresentable {
    let onEnd: () -> Void

    func makeNSView(context: Context) -> MenuLifeReporterView {
        let view = MenuLifeReporterView()
        view.onEnd = onEnd
        return view
    }

    func updateNSView(_ view: MenuLifeReporterView, context: Context) {
        view.onEnd = onEnd
    }

    static func dismantleNSView(_ view: MenuLifeReporterView, coordinator: ()) {
        view.stopObserving()
    }
}

final class MenuLifeReporterView: NSView {
    var onEnd: (() -> Void)?

    /// Never a click target.
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        stopObserving()
        guard let window else { return }
        NotificationCenter.default.addObserver(
            self, selector: #selector(ended),
            name: NSWindow.didResignKeyNotification, object: window)
        NotificationCenter.default.addObserver(
            self, selector: #selector(ended),
            name: NSApplication.didResignActiveNotification, object: nil)
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func ended() { onEnd?() }
}
