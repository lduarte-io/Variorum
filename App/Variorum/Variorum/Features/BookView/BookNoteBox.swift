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
    /// **Who speaks a quiet RECEIPT on the book's surfaces** (13i-d U3 —
    /// KnownIssues row 103's book-surface half: under her default `quiet`
    /// style, the Arrivals line's Add/Dismiss, a Remove/Release, a state
    /// door's receipt had NO visible home on Index / Book / Outline while no
    /// note was live). The LIVE box's bar already hosts the one quiet slot, so
    /// the book's own hosts (the Index column's footer, the navigator's foot)
    /// stand EMPTY exactly while the box is live — one receipt never draws
    /// twice (PROVISIONAL P-13id-U3-6). nil (no box — Read, an unfocused
    /// pane) hosts.
    /// The note's 1-based place in the book for the box's identity line — or
    /// 0 (unknown, omitted) while the in-book FILTER narrows the entries
    /// (13i-d U3, the walk's W-3: "1 of 2 in this book" was false there).
    static func position(_ index: Int, filtered: Bool) -> Int {
        filtered ? 0 : index
    }

    static func bookHostsQuietReceipt(_ box: NoteBoxState?) -> Bool {
        if case .live? = box { return false }
        return true
    }

    /// **WHERE the book's quiet receipt sits** (the 13n-a walk, WA-1 — the
    /// orchestrator's ruling: "the quiet receipt belongs on the window's MAIN
    /// bottom bar's trailing end … never the book navigator's narrow bar").
    /// The navigator's foot (P-13id-U3-6's home for Outline · Book · Read)
    /// is ~200 pt wide, so any real receipt truncated there — the import's
    /// "Imported “o ladrão de raios” — 4 notes in 2 chapters · ⌥⌘Z undoes"
    /// read "Imported “o ladrão de…", and so did every restore door that
    /// opens the book it restored. AppSpec §12's letter is "a muted line at
    /// the bottom bar's trailing end", so the receipt sits at the trailing
    /// end of the MAIN column's foot: the mode's own bottom bar where it has
    /// one (Book and Read's pages — their flip bar, before the page line),
    /// the page's foot where it has none (Outline, Read's flow). Index keeps
    /// its column footer (13i-d U3 — a different column, with its counts),
    /// and a LIVE note box still hosts it in the sidebar's bar (one receipt
    /// never draws twice). The navigator never hosts it. PROVISIONAL (the
    /// walk-fix pass; the orchestrator re-walks it).
    enum QuietReceiptHome: Equatable, Sendable {
        /// The sidebar's live note box — its bar hosts the slot.
        case liveNoteBox
        /// Index's column footer (13i-d U3, unchanged).
        case indexColumnFooter
        /// The mode's own bottom bar, trailing (Book · Read's pages).
        case modeBottomBar
        /// The main column's foot, trailing (Outline · Read's flow).
        case pageFoot
    }

    /// `modeBarShown`: whether Book / Read's pages are drawing their flip bar
    /// (an EMPTY book draws none — then the page's foot hosts instead, so a
    /// receipt is never left without a home).
    static func quietReceiptHome(
        mode: BookStructureModel.ViewMode,
        pagedRead: Bool,
        modeBarShown: Bool,
        box: NoteBoxState?
    ) -> QuietReceiptHome {
        guard bookHostsQuietReceipt(box) else { return .liveNoteBox }
        switch mode {
        case .index: return .indexColumnFooter
        case .spread: return modeBarShown ? .modeBottomBar : .pageFoot
        case .read: return pagedRead && modeBarShown ? .modeBottomBar : .pageFoot
        case .outline: return .pageFoot
        }
    }

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
    /// 13i-c U4 — the box's BOOK CONTEXT door (the sitting record §20): take
    /// the box's note out of the book — "Remove from This Book", or "Release
    /// from This Book" on an owned book. nil where the book holds no
    /// membership (a gathering — its honest door is the note's chip).
    var removeFromBook: NoteBoxRemoveDoor?
    /// **VX-304 — the box's "open ↗"**: leave the book for the note's OWN
    /// editor, in Write, at her caret's block — the book's ONE open door
    /// (`BookView.openInWrite`, VX-303's road), handed up for the box's note.
    /// Her report: *"you can't see the "open ↗" next to the note title very
    /// easily if it's a long note even if your carat is in the right place.
    /// can you add it somewhere in this menu on the left?"* nil ⇒ no door.
    var openInWrite: (() -> Void)?
    /// **VX-304 — the Index's "Takes"**: the live block's takes, in place,
    /// over the book (`WriteTakesPanel`). Only the Index hands one: its live
    /// note has no bar (Outline and the spread's bars carry their own Takes
    /// door). nil ⇒ no door.
    var openTakes: (() -> Void)?
}

/// The note box's remove/release door: the book's word and the act.
@MainActor
struct NoteBoxRemoveDoor {
    let verb: String
    let act: () -> Void
}
