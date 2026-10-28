//
//  CaretPress.swift
//  Variorum
//
//  **VX-429 + VX-592 — A PRESS ON THE CARET STARTS A SELECTION, AS ANYWHERE
//  ELSE.** Her report (VX-429): in Takes, a drag that starts exactly at the
//  caret's own position does nothing, while a drag started anywhere else
*[removed for publication]*
//  cursor is currently typing, it doesn't work."* One mechanism, measured.
//
//  **THE MECHANISM (macOS 27.0.1, TextKit 2 — the run record's BATCH A2
//  RECORD carries the probe, `notes/plans/fixes/vx-601-run-takes-editor-
//  quick-fixes.md`).** A text view that overrides `mouseDown` runs AppKit's
//  CLASSIC mouse road (a bare TK2 `NSTextView` carries gesture recognizers for
//  selection; an overriding subclass carries none) — and both of this app's
//  writing surfaces override it: `PaneTextView` (every pane) and
//  `EditorTextView` (Write). On that road an EMPTY selection whose caret has
//  settled (a run-loop turn after it was placed) counts as COVERING THE
//  CHARACTER AFTER IT: a press anywhere on that character's glyph is a press
//  "inside the selection", and a press inside the selection that is HELD a
//  moment before moving (measured ≥ ~0.15–0.2 s) begins a text DRAG of the
//  selection. AppKit's own `dragSelection` answers false for an empty one —
//  no image, no pasteboard, no session — and consumes the rest of the
//  gesture: no selection, the caret stays, nothing is reported. A quick
//  press-and-move still selects, which is why it reads as "sometimes". TK1
//  never does it; editable or not, key window or not, the same.
//
//  **THE FIX — ONE RULE, BOTH SURFACES.** Immediately before `super.mouseDown`,
//  on a PLAIN single click (no modifier, `clickCount == 1`, no marked text)
//  while the selection is ONE empty range at `c` and the press lands on either
//  character beside the caret (`c − 1` or `c` — the measured zone is `c`'s
//  glyph; `c − 1` covers the boundary pixel, and firing there is harmless,
//  measured), the caret is moved SILENTLY (`stillSelecting: true` — no
//  notification reaches any delegate) to the far edge of the character at `c`.
//  It no longer covers the pressed character, so AppKit's own tracking does
//  exactly what it does anywhere else: a drag selects, a plain click puts the
//  caret where it always did, with the one notification it always posted.
//
//  What it never touches: a non-empty selection (a drag-out of a real
//  selection is AppKit's, unchanged), a ⇧ / ⌘ / ⌥ / ⌃ click, a double or
//  triple click, a press anywhere else, the characters, any attribute (no
//  stamp of any kind — TEXTKIT2 §3), any liveness (P-3: the move is inside
//  one gesture of the view that already holds the selection). Cost: one
//  `characterIndex(for:)` hit-test where she pressed, on screen by definition
//  (P1).
//
//  A point-release fact (TEXTKIT2_NOTES §5): if a later macOS stops treating
//  a settled caret as covering its next character, this rule becomes a
//  harmless no-op; `CaretPressTests` pins the behaviour it exists for.
//

import AppKit

/// The pure decision — no AppKit state, so it pins as arithmetic.
nonisolated enum CaretPress {
    /// Where to move an EMPTY selection before AppKit's mouse road sees a
    /// press on `pressedCharacter` (the UTF-16 index of the character under
    /// the pointer), or nil to leave the selection alone.
    ///
    /// - `selection` — the view's selected ranges, in order.
    /// - `text` — the view's characters (UTF-16, `NSString` semantics).
    static func caretBeforePress(
        selection: [NSRange], pressedCharacter: Int, text: NSString
    ) -> Int? {
        guard selection.count == 1, let caret = selection.first,
              caret.location != NSNotFound, caret.length == 0
        else { return nil }
        let at = caret.location
        // A caret at the very end covers no character — nothing to press on.
        guard at < text.length else { return nil }
        guard pressedCharacter == at || pressedCharacter == at - 1 else { return nil }
        // The far edge of the character the caret precedes — never inside a
        // composed sequence (an emoji, a combining mark).
        return NSMaxRange(text.rangeOfComposedCharacterSequence(at: at))
    }

    /// The press this rule is for: a plain, single, left mouse-down.
    static func isPlainSingleClick(
        type: NSEvent.EventType, clickCount: Int, modifiers: NSEvent.ModifierFlags
    ) -> Bool {
        type == .leftMouseDown && clickCount == 1
            && modifiers.intersection([.command, .option, .control, .shift]).isEmpty
    }
}

extension CaretPress {
    /// **The wire both `mouseDown` overrides call, immediately before
    /// `super.mouseDown`.** Returns whether the caret was moved (an
    /// observation for the pins; the callers ignore it).
    @discardableResult
    static func clearPressedCharacter(in view: NSTextView, for event: NSEvent) -> Bool {
        guard isPlainSingleClick(
                  type: event.type, clickCount: event.clickCount,
                  modifiers: event.modifierFlags),
              !view.hasMarkedText(), let window = view.window
        else { return false }
        // Only a lone caret can cover a character — anything else pays no
        // hit-test (the rule below re-asks the whole question).
        let selection = view.selectedRanges.map(\.rangeValue)
        guard selection.count == 1, selection[0].length == 0 else { return false }
        let pressed = view.characterIndex(
            for: window.convertPoint(toScreen: event.locationInWindow))
        guard pressed != NSNotFound,
              let target = caretBeforePress(
                  selection: selection, pressedCharacter: pressed,
                  text: view.string as NSString)
        else { return false }
        view.setSelectedRange(
            NSRange(location: target, length: 0),
            affinity: view.selectionAffinity, stillSelecting: true)
        return true
    }
}
