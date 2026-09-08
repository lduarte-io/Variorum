//
//  BookNoteBox.swift
//  Variorum (Mac)
//
//  18d batch 1 — the BOOK's half of the sidebar's note box (her U-10): which
//  modes show it, and which note it points at. Pure, beside `BookAnchor`,
//  because it is the same kind of thing — one rule over facts the modes
//  already hold, inventing no state.
//
//  ── WHY THIS IS NOT `BookAnchor` ─────────────────────────────────────────
//  They answer different questions and must be allowed to disagree.
//  `BookAnchor.currentPost` answers *"if you clicked over to another mode,
//  where would you land"* — so every arm falls back to the STANDING anchor,
//  because a carry that lands nowhere is indistinguishable from a carry that
//  never happened. The box answers *"is a note selected RIGHT NOW"*, and her
//  ruling names the negative case outright: *"should show 'no note selected'
//  when you haven't clicked into anything or you've clicked out of
//  something."* Under the standing fallback there is no such state — a book
//  she has ever put anywhere would point at that note forever, and clicking
//  out would change nothing on screen. So: no fallback here, deliberately.
//

import Foundation

nonisolated enum BookNoteBox {
    /// The box stands in the sidebar while a book is open in an EDITING mode
    /// — Outline, Index, Book — and never in Read (§5.4: Read is a place to
    /// read, and its surfaces are not editable by her A43 ruling).
    static func shows(mode: BookStructureModel.ViewMode) -> Bool {
        // A `switch`, not `!=`: `ViewMode` is nested in a `@MainActor` model,
        // so its synthesized `Equatable` is isolated and unavailable here —
        // the same reason `BookAnchor` switches (its own file's shape).
        switch mode {
        case .outline, .index, .spread: return true
        case .read: return false
        }
    }

    /// The note this mode POINTS AT, or nil — see the header for why there
    /// is no standing fallback.
    ///
    /// - Outline: the book's focused note. Several notes may be EXPANDED at
    ///   once, so expansion cannot be the answer; focus is the one thing
    ///   Outline has exactly one of.
    /// - Index: the index column's own selection, as it reports it.
    /// - Book (the spread): the page under her hands — a focused note ON the
    ///   spread keeps its claim (the `BookAnchor` rule, restated), else the
    ///   left page, which is the page the spread opened at.
    static func selectedPost(
        mode: BookStructureModel.ViewMode,
        focusedPostID: String?,
        spreadPostIDs: [String],
        indexPostID: String?
    ) -> String? {
        switch mode {
        case .outline:
            return focusedPostID
        case .index:
            return indexPostID
        case .spread:
            if let focusedPostID, spreadPostIDs.contains(focusedPostID) { return focusedPostID }
            return spreadPostIDs.first
        case .read:
            return nil
        }
    }

    /// The note the caret is IN, or nil.
    ///
    /// Outline and the spread mount the one full-document editor through the
    /// book's own focus authority (`liveFocusedPostID` — nil in an unfocused
    /// pane, which is exactly the read-cheap state the box's second state
    /// describes). INDEX has no full editor by design: it is a projection
    /// tier that upgrades ONE BLOCK to a live pane (`BookIndexEditModel`,
    /// P-3), so its live note is that pane's, reported the way the index
    /// already reports its selection.
    static func livePost(
        mode: BookStructureModel.ViewMode,
        liveFocusedPostID: String?,
        indexLivePostID: String?
    ) -> String? {
        switch mode {
        case .outline, .spread: return liveFocusedPostID
        case .index: return indexLivePostID
        case .read: return nil
        }
    }
}

// MARK: - What the book publishes to the shell

/// The book's publication for the sidebar's note box (18d batch 1).
///
/// **A VALUE, deliberately.** The sidebar never constructs or holds the
/// book's `BookViewModel` or the editor's `EditorViewModel` (CLAUDE.md's P39
/// refinement): the book publishes ids and strings, `RootView` composes the
/// box from them and from the registered live editor, and the sidebar renders
/// a view it is handed.
nonisolated struct NoteBoxReport: Equatable, Sendable {
    /// The book publishing this — carried so the shell can tell a stale
    /// report from a live one when a pane changes what it is showing.
    var readingID: String
    var selected: String?
    var live: String?
    /// What the BOOK knows about that note: its title, its chapter, and its
    /// place in the reading order. nil ⇒ the entries have not arrived yet.
    var identity: NoteBoxIdentity?

    var state: NoteBoxState { .from(selected: selected, live: live) }
}

/// The box's ONE act, handed up as a closure beside the report — the shape
/// the cross-feature rule sanctions ("features receive view models, values,
/// and closures"). Not `Equatable`: it is stored and called, never compared.
@MainActor
struct NoteBoxDoor {
    /// Make the selected note live, at the block she was last in — mode
    /// shaped, because "live" means a different thing in each editing mode.
    let editHere: () -> Void
}
