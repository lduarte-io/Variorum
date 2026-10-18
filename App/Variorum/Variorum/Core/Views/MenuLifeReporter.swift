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

// MARK: - VX-69 — Escape ends a menu's life too (her #188(d): the last gap)

/// **Which key press closes an in-window menu** — pure, so the pins classify a
/// synthesized key without a window. A native menu closes on Esc alone; a
/// chord holding ⌘, ⌥ or ⌃ is someone else's command and passes on (Shift and
/// Caps Lock never change what Esc means).
nonisolated enum MenuEscape {
    /// Esc's virtual key code.
    static let keyCode: UInt16 = 53

    static func closes(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> Bool {
        keyCode == Self.keyCode
            && modifiers.intersection([.command, .option, .control]).isEmpty
    }
}

extension View {
    /// **VX-69 — an in-window popover that lives like a menu takes the Escape
    /// key** (librarywalkpolish #188(d): "there is no Escape key for it yet").
    /// While `open`, an Esc pressed in THIS view's window — wherever the
    /// keyboard is (the quick entry, the board, nothing) — closes it and is
    /// CONSUMED, as a native menu's is: the press closes the menu and does
    /// nothing else. Closed, nothing listens (the catcher is not mounted —
    /// the condition sits INSIDE the background, so the host's own identity
    /// never changes with the menu's state).
    func closesOnEscape(while open: Bool, _ close: @escaping () -> Void) -> some View {
        background {
            if open { MenuEscapeCatcher(onEscape: close) }
        }
    }
}

/// The catcher: an inert AppKit view (never a click target) owning a local
/// `keyDown` monitor for ITS window while it is mounted — `PageTurnKeyMonitor`'s
/// and `WingSwitcherKeyCatcher`'s shape, so a pin's `NSApp.sendEvent` drives it.
struct MenuEscapeCatcher: NSViewRepresentable {
    let onEscape: () -> Void

    func makeNSView(context: Context) -> CatcherView {
        let view = CatcherView()
        view.onEscape = onEscape
        return view
    }

    func updateNSView(_ view: CatcherView, context: Context) {
        view.onEscape = onEscape
    }

    final class CatcherView: NSView {
        var onEscape: (() -> Void)?
        private var monitor: Any?

        /// Never a click target.
        override func hitTest(_ point: NSPoint) -> NSView? { nil }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
            guard window != nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self, let window = self.window, event.window === window,
                      MenuEscape.closes(keyCode: event.keyCode, modifiers: event.modifierFlags)
                else { return event }
                self.onEscape?()
                return nil  // consumed — a menu's Esc closes the menu and nothing else
            }
        }
        // (No `deinit`: the view leaves its window before it dies, and
        // `viewDidMoveToWindow` — called then with a nil window — removes the
        // monitor; `PageTurnKeyMonitor`'s note, same reason.)
    }
}
