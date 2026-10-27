//
//  PageTurnKeys.swift
//  Variorum (Mac)
//
//  The Act 10 correction round, ladder round 1 (R1-5) — the note's
//  `read ▸ pages` face turned its leaves on UNMODIFIED ← and → bound as
//  SwiftUI `.keyboardShortcut`s, and SwiftUI resolves a key equivalent in
//  the hosting view's `performKeyEquivalent` BEFORE the first responder's
//  `keyDown` — so an arrow typed in the index column's filter field (the
//  same surface, composed together for the first time this round), the
//  masthead's inline tag field or the title's rename field turned a page
//  instead of moving the caret.
//
//  THE RULE (pure, `PageTurnKeys.turn`): an unmodified arrow turns a leaf
//  ONLY while no text-editing view is the window's first responder. The
//  DOOR: a local key monitor installed by a zero-size view while the face is
//  in a window (`PageTurnKeyMonitor`), which sees the key BEFORE the window
//  dispatches it, asks the pure rule, and consumes the event only when it
//  turns — otherwise the key reaches the field exactly as if the face were
//  not there. (Chosen over gating the shortcut's ACTION: a consumed key
//  equivalent never reaches the field, so gating inside the action would
//  have silenced both the turn and the caret.)
//

import AppKit
import SwiftUI
import WebKit

nonisolated enum PageTurnKeys {
    enum Turn: Equatable {
        case back
        case forward
    }

    static let leftArrowKeyCode: UInt16 = 123
    static let rightArrowKeyCode: UInt16 = 124

    /// The decision: `.back` / `.forward` for an unmodified ← / →, and nil
    /// for anything else — every other key, any chord, and ALWAYS while a
    /// text-editing view is first responder.
    static func turn(
        keyCode: UInt16, modifiers: NSEvent.ModifierFlags, textIsFirstResponder: Bool
    ) -> Turn? {
        guard !textIsFirstResponder else { return nil }
        guard modifiers.intersection([.command, .option, .control, .shift]).isEmpty else { return nil }
        switch keyCode {
        case leftArrowKeyCode: return .back
        case rightArrowKeyCode: return .forward
        default: return nil
        }
    }

    /// Whether the window's first responder edits text: an `NSText`
    /// (every `NSTextView`, the field editor a SwiftUI `TextField` writes
    /// through) or an `NSTextField` — or a WEB VIEW (the VX-439 ladder's m-1):
    /// the reference panel's URL pane is an interactive `WKWebView`, and with
    /// an input on the page focused the window's first responder is the web
    /// view itself (or a view inside it), which is neither. Whether the page's
    /// focus sits in an input only the page knows, so a web view holding the
    /// keyboard counts as text holding it — the conservative reading, as a
    /// read-only text view counts. (The app's ONE answer: the page-turn keys
    /// and ⌘←/⌘→'s Back/Forward both read it.)
    @MainActor
    static func textIsFirstResponder(in window: NSWindow?) -> Bool {
        guard let responder = window?.firstResponder else { return false }
        if responder is NSText || responder is NSTextField { return true }
        var view = responder as? NSView
        while let current = view {
            if current is WKWebView { return true }
            view = current.superview
        }
        return false
    }
}

/// The door: a zero-size view that owns a local `keyDown` monitor for the
/// window it lives in, for as long as it lives there.
struct PageTurnKeyMonitor: NSViewRepresentable {
    let onTurn: (PageTurnKeys.Turn) -> Void

    func makeNSView(context: Context) -> MonitorView {
        let view = MonitorView()
        view.onTurn = onTurn
        return view
    }

    func updateNSView(_ nsView: MonitorView, context: Context) {
        nsView.onTurn = onTurn
    }

    final class MonitorView: NSView {
        var onTurn: ((PageTurnKeys.Turn) -> Void)?
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
                guard let turn = PageTurnKeys.turn(
                    keyCode: event.keyCode, modifiers: event.modifierFlags,
                    textIsFirstResponder: PageTurnKeys.textIsFirstResponder(in: window))
                else { return event }
                self.onTurn?(turn)
                return nil  // consumed: the turn is the key's whole meaning here
            }
        }
        // (No `deinit`: the view leaves its window before it dies, and
        // `viewDidMoveToWindow` — called then with a nil window — removes
        // the monitor; a nonisolated deinit may not touch the monitor.)
    }
}
