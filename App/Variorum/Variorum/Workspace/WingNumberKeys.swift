//
//  WingNumberKeys.swift
//  Variorum (Mac) — Workspace
//
//  **VX-824 (the VX-828 run, batch B) — ⌘1–⌘9: wings from the keyboard.**
//  Her ask (2026-11-04): *"map the Command1, command2, command3, etc. to
//  moving between different wings when you aren't in a note - i know they're
//  editing modes when you're in the editor, but i'm often not in a particular
//  note, and that would make them more useful and make having many wings
//  easier to manage."* Her ruling, shape (a): ⌘digit is CONTEXTUAL — inside a
//  note it stays the mode row (⌘1–⌘7 Debug, ⌘1–⌘6 Release, untouched);
//  anywhere else ⌘N goes to wing N in the switcher's order, Home first, and
//  lands on its Bookcase (VX-833 — `WingsModel.goTo`, the deliberate road).
//
//  WHO HOLDS THE KEYS (the fork's ruling, Q-B1 (a) — flagged for her morning,
//  it interprets her "text input" family): the chord passes on when the
//  focused pane shows a note (the mode row's own gate — the registry's
//  `.goToWing` availability is its mirror) or when a WRITING surface holds the
//  keyboard anywhere in the window — note or snippet prose (`EditorTextView`,
//  `PaneTextView`: a book's live note, Read's edit face, the Pool, Snippets) or
//  a block comment's text. Any other holder — the capture box (where VX-332
//  rests the caret on every Bookcase arrival), a search field, the tag field —
//  is not a note, and ⌘digit means nothing in it, so the chord is the wing's.
//  The literal VX-560 rule (any text input) would have killed the chord on the
//  Bookcase, the second press after a ⌘digit landing included.
//
//  THE DOOR is the `BrowserNavKeyMonitor` shape: a zero-size view in the full
//  window owns a local `keyDown` monitor, which sees the key BEFORE the menu
//  (a grey mode item would swallow it in silence — `OneWingChord`'s finding),
//  asks the pure rule below, and consumes the key only when it is the chord's:
//  a wing, or a number no wing answers — which SPEAKS its refusal (P-828-1 (i):
//  a door that did nothing speaks, AppSpec §12). Every other key reaches the
//  menu and the responder chain exactly as if the monitor were not there: in a
//  note the mode row takes ⌘1; in a book's live note the grey mode item
//  swallows it, as it always has. Note-only windows and the quick-note pad
//  carry no monitor — untouched.
//

import AppKit
import SwiftUI

nonisolated enum WingNumberKeys {
    /// Who holds the window's keyboard, as far as the chord cares.
    enum Holder: Equatable, Sendable {
        /// A note's (or a snippet's, or a comment's) text — the chord passes on.
        case writingSurface
        /// Anything else, nothing included — the chord is the wing's.
        case other
    }

    /// What one ⌘digit press means here.
    enum Decision: Equatable, Sendable {
        /// Not the chord's key here — it reaches the menu / responder chain.
        case passOn
        /// Wing N exists: go there (the deliberate road — it lands).
        case goTo(String)
        /// No wing answers N: say so (the key is consumed).
        case refuse(String)
    }

    /// The number a key names: exactly ⌘ (no ⇧ — ⌘⇧1–9 is the Open list; no ⌥,
    /// no ⌃) on a single digit 1–9. A key's own `.numericPad` / `.function`
    /// flags are not modifiers she pressed, so they are ignored (VX-560's rule).
    static func number(
        charactersIgnoringModifiers characters: String?, modifiers: NSEvent.ModifierFlags
    ) -> Int? {
        guard modifiers.intersection([.command, .option, .control, .shift]) == .command,
              let characters, characters.count == 1,
              let digit = Int(characters), (1...9).contains(digit)
        else { return nil }
        return digit
    }

    /// **THE RULE** (pure, pinned): `available` is the registry's answer for
    /// `.goToWing` — false while the focused pane shows a note (the mode row's
    /// place); `wings` is the switcher's order, Home first.
    static func decide(
        number: Int?, available: Bool, holder: Holder, wings: [WingSwitcherBrain.Row]
    ) -> Decision {
        guard let number, available, holder != .writingSurface else { return .passOn }
        guard number <= wings.count else {
            return .refuse(WingCopy.noWingAtNumber(number, wingCount: wings.count))
        }
        return .goTo(wings[number - 1].id)
    }

    /// The window's first responder, classified. The note-prose surfaces and
    /// the comment text area are writing surfaces (a comment's display twin
    /// never takes the keyboard — `acceptsFirstResponder` false); a field
    /// editor, the capture box (`CaptureNSTextView`), a web view or nothing
    /// are not.
    @MainActor
    static func holder(_ responder: NSResponder?) -> Holder {
        switch responder {
        case is EditorTextView, is PaneTextView, is CommentNSTextView:
            .writingSurface
        default:
            .other
        }
    }

    /// The monitor's ONE road from a real event to a decision — a keyDown
    /// only (a flagsChanged event has no characters; reading them raises —
    /// the 13n-c D-W4 lesson).
    @MainActor
    static func decision(
        for event: NSEvent, available: Bool, responder: NSResponder?, wings: [WingSwitcherBrain.Row]
    ) -> Decision {
        guard event.type == .keyDown else { return .passOn }
        return decide(
            number: number(
                charactersIgnoringModifiers: event.charactersIgnoringModifiers,
                modifiers: event.modifierFlags),
            available: available, holder: holder(responder), wings: wings)
    }
}

/// **The door**: a zero-size view that owns a local `keyDown` monitor for the
/// window it lives in (`RootView`'s full window). `onKey` answers whether the
/// key was the chord's — consumed only then.
struct WingNumberKeyMonitor: NSViewRepresentable {
    let onKey: (NSEvent, NSWindow) -> Bool

    func makeNSView(context: Context) -> MonitorView {
        let view = MonitorView()
        view.onKey = onKey
        return view
    }

    func updateNSView(_ nsView: MonitorView, context: Context) {
        nsView.onKey = onKey
    }

    final class MonitorView: NSView {
        var onKey: ((NSEvent, NSWindow) -> Bool)?
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
                return self.onKey?(event, window) == true ? nil : event
            }
        }
        // (No `deinit`: `viewDidMoveToWindow` with a nil window removes the
        // monitor — `BrowserNavKeyMonitor`'s reasoning.)
    }
}
