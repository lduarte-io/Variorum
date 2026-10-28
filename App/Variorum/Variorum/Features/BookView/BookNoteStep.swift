//
//  BookNoteStep.swift
//  Variorum (Mac)
//
//  **VX-563 — ⌘↑ / ⌘↓ step between a book's notes while reading.** Her ask
//  (her 2026-10-26 improvements note): "a shortcut command would be a nice way
//  to navigate when within the 'in note' book view." Her proposal (the ticket's
//  comment, 2026-10-28): "can we just do command up / down arrow when you're
//  scrolling through a book?" — and her kickoff ruling settled the gesture:
//  "⌘↑/⌘↓ step between notes while reading, document start/end while editing"
//  — VX-560's reading-vs-editing rule for ⌘← / ⌘→, exactly.
//
//  THE ARMS (A-648-6 — the orchestrator's rulings on the batch's fork; every
//  one PROVISIONAL for her bundle):
//  (1) MODES — Outline, Read (both forms) and Book (the spread). Index is NOT
//      consumed: it is the book's editing surface (its navigator hidden), and
//      her letter is "while reading".
//  (2) FROM — the mode's own VIEWED note, through ONE named seam
//      (`viewedNote`): Outline's VX-562 viewed pair, the spread's left page,
//      Read ▸ Pages' reported note, and — INTERIM — Read ▸ Scroll's standing
//      anchor (where the book last landed), else its first note. Batch 4
//      (VX-645) wires the follow brain's Read ▸ Scroll viewed note into this
//      seam; nothing here reads the scroll's geometry.
//  (3) THE STEP lands like the navigator's note-row act for the mode — EXCEPT
//      in Outline, where it is REVEAL-ONLY: the navigator's focus+reveal mounts
//      the live editor, which would take the keyboard and turn the next ⌘↓
//      into document-end (VX-560's own rule) — killing the repeated stepping
//      she asked for. The navigator CLICK keeps its focus+reveal.
//  (4) Chapter headings are not stops — a step crosses into the next
//      chapter's first note.
//  (5) At the book's ends the key is consumed and SPEAKS a refusal ("That's
//      the book's first note." / "That's the book's last note.") — a door
//      that did nothing speaks (AppSpec §12). (The recorded alternative: a
//      silent consume.)
//  (6) NO menu item: a ⌘↑ / ⌘↓ menu key equivalent is resolved before the
//      first responder's `keyDown`, so it would take document start/end from
//      every text view in the app — VX-560's exact reason its keys are
//      alternates. The door is VX-560's: a zero-size view's local key
//      monitor, consuming the key only when it steps.
//
//  "Text holds the keyboard" is `PageTurnKeys.textIsFirstResponder` — the
//  app's ONE answer (any `NSText`, a field editor, an `NSTextField`, and an
//  interactive web view), which VX-560 reads too.
//

import AppKit
import SwiftUI
import VariorumCore

nonisolated enum BookNoteStep {
    enum Direction: Equatable, Sendable {
        case previous
        case next

        /// The act this key is the door of.
        var capability: CapabilityID {
            switch self {
            case .previous: .previousNoteInBook
            case .next: .nextNoteInBook
            }
        }
    }

    static let upArrowKeyCode: UInt16 = 126
    static let downArrowKeyCode: UInt16 = 125

    /// **The key rule**: `.previous` for ⌘↑, `.next` for ⌘↓ — exactly ⌘: no ⇧
    /// (⇧⌘↑ selects to a document's start), no ⌥, no ⌃ (⌃⌘↑ / ⌃⌘↓ are Previous /
    /// Next Block); nil while text holds the keyboard, and nil in Index (never
    /// consumed there — A-648-6 (1)). An arrow key's own `.numericPad` /
    /// `.function` flags are not modifiers she pressed, so they are ignored.
    static func direction(
        keyCode: UInt16, modifiers: NSEvent.ModifierFlags, textIsFirstResponder: Bool,
        mode: BookStructureModel.ViewMode
    ) -> Direction? {
        guard !textIsFirstResponder else { return nil }
        guard steps(in: mode) else { return nil }
        guard modifiers.intersection([.command, .option, .control, .shift]) == .command else { return nil }
        switch keyCode {
        case upArrowKeyCode: return .previous
        case downArrowKeyCode: return .next
        default: return nil
        }
    }

    /// The modes the keys step in (A-648-6 (1)). A `switch` rather than `==`:
    /// `ViewMode`'s synthesized Equatable is main-actor isolated.
    static func steps(in mode: BookStructureModel.ViewMode) -> Bool {
        switch mode {
        case .outline, .spread, .read: true
        case .index: false
        }
    }

    /// **THE NAMED SEAM — the note each mode is VIEWING** (A-648-6 (2)), the
    /// step's "from". Each arm reads a fact its mode already reports; nil means
    /// the mode views no note (Outline's title block holds the page; an empty
    /// book).
    ///
    /// The Read ▸ Scroll arm is INTERIM: the flow tracks no position of its own
    /// (`BookAnchor`'s header — 13c 2A removed per-row reporting at her A6
    /// ruling), so it answers the book's STANDING anchor — where it last
    /// landed (a mode switch's carry, a navigator click, a step) — else its
    /// first note. VX-645 (batch 4) replaces this arm with the follow brain's
    /// viewed note.
    struct Facts: Equatable, Sendable {
        var outlineViewed: String?
        var spreadLeft: String?
        var pagedShown: String?
        var standingAnchor: String?
    }

    static func viewedNote(
        mode: BookStructureModel.ViewMode, readForm: BookStructureModel.ReadForm,
        facts: Facts, order: [String]
    ) -> String? {
        let viewed: String?
        switch (mode, readForm) {
        case (.outline, _): viewed = facts.outlineViewed
        case (.spread, _): viewed = facts.spreadLeft
        case (.read, .pages): viewed = facts.pagedShown ?? order.first
        case (.read, .flow): viewed = facts.standingAnchor ?? order.first
        case (.index, _): viewed = nil
        }
        // A note the mode's order no longer holds (a stale report) views
        // nothing — the step then starts from before the first note.
        guard let viewed, order.contains(viewed) else { return nil }
        return viewed
    }

    /// **The step** (pure): from the viewed note through the mode's own page
    /// order. Nothing viewed reads as BEFORE the first note: ⌘↓ lands the
    /// first, ⌘↑ is at the start. nil for an empty book (nothing to say or do —
    /// the key passes on).
    enum Outcome: Equatable, Sendable {
        case land(postID: String)
        case atFirst
        case atLast
    }

    static func step(_ direction: Direction, from viewed: String?, order: [String]) -> Outcome? {
        guard !order.isEmpty else { return nil }
        guard let viewed, let index = order.firstIndex(of: viewed) else {
            return direction == .next ? .land(postID: order[0]) : .atFirst
        }
        switch direction {
        case .previous:
            return index == 0 ? .atFirst : .land(postID: order[index - 1])
        case .next:
            return index == order.count - 1 ? .atLast : .land(postID: order[index + 1])
        }
    }

    /// The ends' words (A-648-6 (5) — PROVISIONAL, her copy pass): said on the
    /// one status seam as a refusal.
    static let firstNoteWords = "That's the book's first note."
    static let lastNoteWords = "That's the book's last note."

    static func words(for outcome: Outcome) -> String? {
        switch outcome {
        case .atFirst: firstNoteWords
        case .atLast: lastNoteWords
        case .land: nil
        }
    }
}

/// **The door**: a zero-size view that owns a local `keyDown` monitor for the
/// window it lives in (the book view, in its pane), for as long as it lives
/// there — `BrowserNavKeyMonitor`'s shape. `onStep` performs the step or speaks
/// its refusal and answers whether it did either; the key is consumed only
/// then. `isActive` is the book's pane focus: a book in the UNFOCUSED pane of a
/// split never steps (only the focused pane is live — P3).
struct BookNoteStepKeyMonitor: NSViewRepresentable {
    let isActive: Bool
    let mode: BookStructureModel.ViewMode
    let onStep: (BookNoteStep.Direction) -> Bool

    func makeNSView(context: Context) -> MonitorView {
        let view = MonitorView()
        update(view)
        return view
    }

    func updateNSView(_ nsView: MonitorView, context: Context) {
        update(nsView)
    }

    private func update(_ view: MonitorView) {
        view.isActive = isActive
        view.mode = mode
        view.onStep = onStep
    }

    final class MonitorView: NSView {
        var isActive = false
        var mode: BookStructureModel.ViewMode = .outline
        var onStep: ((BookNoteStep.Direction) -> Bool)?
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
                guard let self, self.isActive, let window = self.window, event.window === window else {
                    return event
                }
                guard let direction = BookNoteStep.direction(
                    keyCode: event.keyCode, modifiers: event.modifierFlags,
                    textIsFirstResponder: PageTurnKeys.textIsFirstResponder(in: window),
                    mode: self.mode)
                else { return event }
                return self.onStep?(direction) == true ? nil : event
            }
        }
        // (No `deinit`: `viewDidMoveToWindow` with a nil window removes the
        // monitor — `PageTurnKeyMonitor`'s reasoning.)
    }
}
