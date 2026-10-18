//
//  BookOpenDoor.swift
//  Variorum (Mac)
//
//  VX-303 — THE BOOK'S OPEN DOORS carry her place. Her report: *"when you
//  click open in editor it brings you to the top of the option"*; her
//  correction: the door *"doesn't carry your block so it doesn't follow the
//  existing deep-link canon rule, it just doesn't work."* Her ruling
//  (2026-10-13, verbatim): *"I think it can land in Write at the block - more
//  consistent and useful than the note's last used mode."*
//
//  The five doors — Outline's expanded header "open ↗", the collapsed card's
//  body and its "open ↗", Index's "Open in the full editor", the spread
//  page's "open ↗" — used to pass only the note's id through the
//  `.variorumOpenPost` broadcast: a plain note-open, so R-18l-1's first-open
//  rule showed the note's START, in its remembered mode. They now ride the
//  shell's one block-landing road (13o U3's search-hit road: `RootView` →
//  `ShellRouter.adopt(landing:)` → `PostDetailView.jump`, which forces Write)
//  with the place this rule names.
//
//  ── WHAT THIS IS ─────────────────────────────────────────────────────────
//  One pure rule — "where is she in THIS note, right now, in this book" —
//  over facts the book's surfaces already hold (the `BookAnchor` /
//  `BookNoteBox` shape, beside them). It invents no state:
//
//  - Outline and the spread mount the book's ONE full-document editor
//    (`BookViewModel.liveFocusedPostID`); her place is that editor's caret
//    (`EditorRouter.editing` — the editor under the caret, never `active`'s
//    shadow) when it is THIS note's.
//  - Index upgrades one block to a live pane (`BookIndexEditModel`); her
//    place is that block, at the caret the pane last reported — an offset
//    reported from another block is not an offset in this one, so it falls
//    to the block's start.
//  - Read is not editable (her A43): no place.
//  - Nothing live in this note ⇒ nil ⇒ today's plain open (the brief's
//    letter). The collapsed card is always this case: focus implies
//    expansion, so a card's note is never the live one.
//

import Foundation

nonisolated enum BookOpenDoor {
    /// Her place inside a note, as an open door carries it: the block her
    /// caret stands in, and the caret's UTF-16 offset inside that block (nil
    /// ⇒ unknown, which every landing spells "the block's start").
    struct Place: Equatable, Sendable {
        var blockID: String
        var offsetInBlock: Int?
    }

    /// What the book's surfaces know about her caret RIGHT NOW. Assembled by
    /// `BookView` from the book's own reports and the editor under the caret;
    /// synthesized freely by the pins.
    struct Live: Equatable, Sendable {
        /// Outline / the spread: the note the book's one editor is live in
        /// (`liveFocusedPostID` — nil in an unfocused pane).
        var editorPostID: String?
        /// …and where that editor's caret stands — read only from the editor
        /// under the caret, and only when it is that note's.
        var editorCaret: Place?
        /// Index: the note and block of the one live pane.
        var indexPostID: String?
        var indexBlockID: String?
        /// …and the last caret that pane reported, with the block it was in.
        var indexCaret: Place?

        init(
            editorPostID: String? = nil, editorCaret: Place? = nil,
            indexPostID: String? = nil, indexBlockID: String? = nil,
            indexCaret: Place? = nil
        ) {
            self.editorPostID = editorPostID
            self.editorCaret = editorCaret
            self.indexPostID = indexPostID
            self.indexBlockID = indexBlockID
            self.indexCaret = indexCaret
        }
    }

    /// Her place in `postID`, as the door in `mode` should carry it — or nil
    /// for a plain open.
    static func place(
        of postID: String, mode: BookStructureModel.ViewMode, live: Live
    ) -> Place? {
        // A `switch`, not `==`: `ViewMode` is nested in a `@MainActor` model,
        // so its synthesized `Equatable` is isolated (`BookAnchor`'s reason).
        switch mode {
        case .outline, .spread:
            guard live.editorPostID == postID else { return nil }
            return live.editorCaret
        case .index:
            guard live.indexPostID == postID, let block = live.indexBlockID else { return nil }
            let offset = live.indexCaret?.blockID == block ? live.indexCaret?.offsetInBlock : nil
            return Place(blockID: block, offsetInBlock: offset)
        case .read:
            return nil
        }
    }
}
