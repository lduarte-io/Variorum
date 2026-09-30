//
//  BookNoteTrail.swift
//  Variorum (Mac)
//
//  18o U4 — R-18k-6, her ruling: *"a note edited inside a book should get a
//  savepoint when you open it"*, clarified at once to **"When I move to
//  another note"** — in a book, the note she edited gets its leaving savepoint
//  when she moves into a different note, or leaves the book, exactly as
//  leaving a note on its own already does (13j J11).
//
//  ── WHY A BOOK NEEDS THIS AT ALL ─────────────────────────────────────────
//  The Mac's leaving roads read the workspace's shown set, which holds a
//  pane's OWN note and nothing else — a pane showing a book contributes
//  nothing, so no note inside a book was ever reported as left. Its savepoint
//  came only at ⌘Q, the lock or the idle backstop (18k C1's trace T3 case 2).
//
//  ── THE FACT IT READS (named, not re-derived) ───────────────────────────
//  The book's ONE published answer to "which note is she in": the sidebar
//  note box's state (18d, her U-10), `NoteBoxState`, which `BookView` already
//  computes through `BookNoteBox` from what each mode holds — Outline and
//  Book: the book's single focus authority (`BookViewModel.focusedPostID`);
//  Index: its one live pane's note and its column's selection (which the
//  Index keeps from ever naming two different notes). `.live` is where her
//  CARET is; `.selected` is the note the book points at without a caret;
//  `.empty` is no note (clicked out, Read, an unfocused pane).
//
//  ── THE RULE ─────────────────────────────────────────────────────────────
//  · The trail remembers the note her caret was last IN — `.live` only. A
//    note she only LOOKED at (the Index's arrival seed, a row selected with
//    no caret, a page of the spread) never enters it, so it is never reported:
//    no savepoint for a note her caret never entered. (Every note that does
//    enter holds a registry entry by then, so the notes reported here are
//    exactly the ones the ⌘Q/lock walk would have savepointed — earlier.)
//  · `.live` in a DIFFERENT note: she moved into another note — the one she
//    was in is LEFT.
//  · `.selected` naming a different note: she moved to another note without
//    the caret (the Index's row click, which releases the ring; a leaf turn
//    in Book mode) — the one she was in is LEFT, and forgotten.
//  · `.empty`: nothing. Clicking out is not moving to another note, and
//    neither is Read or a pane losing focus.
//  · The same note again (a mode switch inside one note, a pane regaining
//    focus, a re-render): nothing.
//  · Leaving the book: the note she was in is LEFT.
//
//  Scrolling changes none of the facts above, so it is never a move: the
//  Outline's focus moves only on a click, and the Index's selection does not
//  follow scroll (`BookIndexView`'s "NO SELECTION-FOLLOW HERE").
//
//  PROVISIONAL in its reading of "move to another note" (QUESTIONS #163).
//

import Foundation

nonisolated struct BookNoteTrail: Equatable, Sendable {
    /// The note her caret was last in, while she has not moved on from it.
    private(set) var current: String?

    init() {}

    /// The book's note state changed (or was re-published). Returns the note
    /// she has just LEFT, if this moved her off one.
    mutating func observe(_ state: NoteBoxState) -> String? {
        switch state {
        case .live(let id):
            guard id != current else { return nil }
            defer { current = id }
            return current
        case .selected(let id):
            guard let left = current, id != left else { return nil }
            current = nil
            return left
        case .empty:
            return nil
        }
    }

    /// She left the book: the note she was in, if any.
    mutating func leaveBook() -> String? {
        defer { current = nil }
        return current
    }
}
