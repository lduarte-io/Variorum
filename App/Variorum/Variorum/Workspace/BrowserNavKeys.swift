//
//  BrowserNavKeys.swift
//  Variorum (Mac)
//
//  **VX-560 (the VX-439 run, A-439-12) — ⌘← / ⌘→ go back and forward, like a
//  browser, OUTSIDE text.** Her scope call: inside the editor (and any field)
//  ⌘← / ⌘→ stay what they are — the start and the end of the line; anywhere
//  else in a window they are Back and Forward. ⌥⌘[ / ⌥⌘] remain the acts'
//  chords and the labels the menus show; the registry carries these two as
//  each act's `alternateShortcutLabel`.
//
//  WHY NOT A MENU KEY EQUIVALENT: a key equivalent is resolved (the window's
//  `performKeyEquivalent`, then the main menu) BEFORE the first responder's
//  `keyDown`, so a ⌘← menu item would take the line-start key from every text
//  view in the app — the exact class `PageTurnKeys` was built against. So the
//  DOOR is that file's shape: a zero-size view's local key monitor, which sees
//  the key before the window dispatches it, asks the PURE rule below, and
//  consumes it only when it navigates — otherwise the key reaches the text
//  view exactly as if the monitor were not there. "Text holds the keyboard" is
//  `PageTurnKeys.textIsFirstResponder` — the one answer the app already gives
//  (any `NSText`, every field editor, any `NSTextField`, and — since the VX-439
//  ladder's m-1 — a web view holding the keyboard: the reference panel's page
//  may have an input focused).
//
//  A press where the act cannot go (nothing to go back to) SPEAKS the act's
//  declared refusal — a door that did nothing speaks (AppSpec §12; the
//  `OneWingChord` precedent: a grey menu item would swallow the key in
//  silence).
//

import AppKit
import SwiftUI

nonisolated enum BrowserNavKeys {
    enum Direction: Equatable, Sendable {
        case back
        case forward

        /// The act this key is the alternate door of.
        var capability: CapabilityID {
            switch self {
            case .back: .navigateBack
            case .forward: .navigateForward
            }
        }
    }

    /// **The decision**: `.back` for ⌘← and `.forward` for ⌘→ — exactly ⌘,
    /// no ⇧ (⇧⌘← selects to a line's start), no ⌥ (⌥⌘← pages a fan), no ⌃
    /// (⌃⌘← steps takes); nil for every other key, and ALWAYS nil while text
    /// holds the keyboard. (An arrow key's own `.numericPad`/`.function` flags
    /// are not modifiers she pressed, so they are ignored.)
    static func direction(
        keyCode: UInt16, modifiers: NSEvent.ModifierFlags, textIsFirstResponder: Bool
    ) -> Direction? {
        guard !textIsFirstResponder else { return nil }
        guard modifiers.intersection([.command, .option, .control, .shift]) == .command else { return nil }
        switch keyCode {
        case PageTurnKeys.leftArrowKeyCode: return .back
        case PageTurnKeys.rightArrowKeyCode: return .forward
        default: return nil
        }
    }
}

/// **The door**: a zero-size view that owns a local `keyDown` monitor for the
/// window it lives in (`RootView`'s full window), for as long as it lives
/// there. `onNavigate` performs the act — or speaks its refusal — and the key
/// is consumed only then.
struct BrowserNavKeyMonitor: NSViewRepresentable {
    let onNavigate: (BrowserNavKeys.Direction) -> Void

    func makeNSView(context: Context) -> MonitorView {
        let view = MonitorView()
        view.onNavigate = onNavigate
        return view
    }

    func updateNSView(_ nsView: MonitorView, context: Context) {
        nsView.onNavigate = onNavigate
    }

    final class MonitorView: NSView {
        var onNavigate: ((BrowserNavKeys.Direction) -> Void)?
        private var monitor: Any?

        override var isFlipped: Bool { true }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
            guard window != nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self, let window = self.window, event.window === window else { return event }
                guard let direction = BrowserNavKeys.direction(
                    keyCode: event.keyCode, modifiers: event.modifierFlags,
                    textIsFirstResponder: PageTurnKeys.textIsFirstResponder(in: window))
                else { return event }
                self.onNavigate?(direction)
                return nil  // consumed: outside text, Back/Forward is the key's whole meaning
            }
        }
        // (No `deinit`: `viewDidMoveToWindow` with a nil window removes the
        // monitor — `PageTurnKeyMonitor`'s reasoning.)
    }
}
