//
//  WordDelete.swift
//  Variorum
//
//  **VX-1076 — ⌥⌫ NEVER TAKES A WORD FROM ANOTHER LINE.** Her report
//  (2026-11-24): *"sometimes, option backspace at the end of a line will
//  actually remove a word on the line previous."* Her first recording: a
//  checklist in one block, three ⌥⌫ take three words, and the fourth — with
//  only "- [ ] " left before the caret — takes the marker, the line break and
//  the last word of the line above.
//
//  **THE MECHANISM (macOS 27.0.1; the run record's BATCH E IMPLEMENTER
//  RECORD, `notes/plans/fixes/vx-1082-nov-24-fixes.md`).** ⌥⌫ is
//  `deleteWordBackward:` and ⌥⌦ is `deleteWordForward:`, and until this file
//  neither of the app's writing surfaces had a word of its own about them, so
//  the range was AppKit's: EXACTLY `nextWord(from:forward:)` from the caret
//  (probe-measured at every legal caret over URLs, apostrophes, emoji, CJK,
//  markdown punctuation and CRLF). That walk passes over every non-word
//  character — spaces, punctuation, a list marker, A LINE BREAK — before it
//  takes a word, so whenever no word lies between the caret and its line's
//  edge the press crosses the break and takes the other line's word: an empty
//  list item, a dash, an empty line, a line of punctuation. Forward, the
//  twin: `foo|⏎bar` lost `⏎bar`. In Write a press at a BLOCK's start crossed
//  the inter-block separator and the cross-block route's clamp took the
//  previous block's last word.
//
//  **THE RULE (PROVISIONAL — her ticket comment; QUESTIONS #126 (a)(ii) as
//  amended there, (b)(iii) at the seam):** a press never takes a word from
//  another line —
//  · where the system's own range stays on the caret's line, the press IS the
//    system's, byte for byte (`super` runs: the ordinary case is untouched);
//  · where it would leave the line, the press takes only what lies between the
//    caret and the line's edge (a marker, spaces, punctuation) — or, at the
//    line's edge itself, the line break alone (an empty line goes, the caret
//    rejoins the line it came from);
//  · **P-1076-1:** a line break that is a BLOCK SEAM is never taken this way —
//    the press does nothing, as it does at the document's start. Every road
//    that removes a block separator is structural (A7's carve, #34's merge —
//    ⌥⌘Z, never ⌘Z), and this key's undo is one ordinary text edit; ⌫ stays
//    the seam key.
//  Said once: the press behaves as though the caret's line were the whole
//  text, and at the line's edge it removes the break alone.
//
//  **ONE RULE, BOTH SURFACES** (the `CaretPress` precedent): `EditorTextView`
//  (Write and the inline book editor) and `PaneTextView` (every pane — Takes,
//  Compare, Lenses, Read ▸ edit, Blocks, Canvas) wire `press` from their
//  `deleteWordBackward`/`deleteWordForward` overrides. A clamped press is ONE
//  ordinary edit through the one input door (`OrdinaryInputEdit.apply`), so
//  the gate, the block router, autosave, churn, a seal's and a locked take's
//  refusals and ⌘Z all see an ordinary deletion — the shape the system's own
//  word delete takes (probe: one press, one undo step restoring exactly what
//  it took). Nothing here writes an attribute (TEXTKIT2 §3's clamp rule has
//  nothing to clamp) or touches TextKit 1. Cost: `nextWord` (the walk the
//  system itself makes) plus a scan to the caret line's edge — the line, never
//  the document (P1).
//
//  A point-release fact (TEXTKIT2_NOTES §5): if a later macOS stops letting a
//  word delete cross a line break, every press takes the `.system` arm and
//  this rule becomes a pass-through; `WordDeleteKeyTests` pins both sides.
//

import AppKit

/// The pure decision — no AppKit state, so it pins as arithmetic.
nonisolated enum WordDelete {
    enum Direction: Equatable, Sendable {
        /// ⌥⌫ — `deleteWordBackward:`.
        case backward
        /// ⌥⌦ — `deleteWordForward:`.
        case forward
    }

    enum Outcome: Equatable, Sendable {
        /// The system's range stays on the caret's line: let AppKit act.
        case system
        /// The system's range would leave the line: delete this instead.
        case delete(NSRange)
        /// The press would take a block seam: it does nothing (P-1076-1).
        case nothing
    }

    /// What one word-delete press does from a lone caret.
    ///
    /// - `caret` — the caret's UTF-16 offset in `text`.
    /// - `systemBoundary` — where AppKit's own word delete would stop:
    ///   `nextWord(from: caret, forward:)` on the view's storage (the press
    ///   would delete from there to the caret).
    /// - `isBlockSeam` — whether a line break's range is a BLOCK separator
    ///   (only Write has them; a pane answers never).
    static func outcome(
        _ direction: Direction,
        caret: Int,
        systemBoundary: Int,
        text: NSString,
        isBlockSeam: (NSRange) -> Bool
    ) -> Outcome {
        guard caret >= 0, caret <= text.length else { return .system }
        let line = lineBounds(at: caret, in: text)
        switch direction {
        case .backward:
            // The system stays on the line — the ordinary case, untouched.
            guard systemBoundary < line.start else { return .system }
            if caret > line.start {
                return .delete(NSRange(location: line.start, length: caret - line.start))
            }
            // At the line's start: the break before it, alone. (A caret at the
            // document's start never gets here — the system's boundary cannot
            // fall before 0.)
            guard line.start > 0 else { return .system }
            let previous = lineBounds(at: line.start - 1, in: text)
            let lineBreak = NSRange(
                location: previous.contentsEnd, length: line.start - previous.contentsEnd)
            return isBlockSeam(lineBreak) ? .nothing : .delete(lineBreak)
        case .forward:
            guard systemBoundary > line.contentsEnd else { return .system }
            if caret < line.contentsEnd {
                return .delete(NSRange(location: caret, length: line.contentsEnd - caret))
            }
            // At the line's end: the break after it, alone.
            guard line.end > line.contentsEnd else { return .system }
            let lineBreak = NSRange(
                location: line.contentsEnd, length: line.end - line.contentsEnd)
            return isBlockSeam(lineBreak) ? .nothing : .delete(lineBreak)
        }
    }

    /// The hard line holding `offset` — every terminator `NSString` knows
    /// (LF, CR, CRLF, U+2028, U+2029, NEL), never a visual (wrapped) line,
    /// the same unit ⌘⌫ deletes to (`CommandDeleteLineTraceTests`).
    static func lineBounds(at offset: Int, in text: NSString)
        -> (start: Int, end: Int, contentsEnd: Int) {
        var start = 0
        var end = 0
        var contentsEnd = 0
        text.getLineStart(
            &start, end: &end, contentsEnd: &contentsEnd,
            for: NSRange(location: offset, length: 0))
        return (start, end, contentsEnd)
    }
}

extension WordDelete {
    /// **The wire both text views' overrides call.** `system` is the caller's
    /// own `super.deleteWordBackward(_:)` / `super.deleteWordForward(_:)` — the
    /// system's press, invoked unchanged wherever the rule leaves it alone: a
    /// selection (deleting it is the system's), several selections, marked
    /// text (an input method's composition), a surface that cannot be edited,
    /// and every press whose range stays on the caret's line.
    @MainActor
    static func press(
        _ direction: Direction,
        in view: NSTextView,
        isBlockSeam: ((NSRange) -> Bool)? = nil,
        system: () -> Void
    ) {
        guard view.isEditable, !view.hasMarkedText(), let storage = view.textStorage
        else { return system() }
        let selection = view.selectedRanges.map(\.rangeValue)
        guard selection.count == 1, let caret = selection.first,
              caret.location != NSNotFound, caret.length == 0
        else { return system() }
        let boundary = storage.nextWord(
            from: caret.location, forward: direction == .forward)
        switch outcome(
            direction, caret: caret.location, systemBoundary: boundary,
            text: view.string as NSString, isBlockSeam: isBlockSeam ?? { _ in false }) {
        case .system:
            system()
        case .delete(let range):
            // One ordinary edit through the one input door; a refusal (a seal,
            // a locked take) has already spoken in its own words.
            OrdinaryInputEdit.apply("", over: range, in: view)
        case .nothing:
            break
        }
    }
}
