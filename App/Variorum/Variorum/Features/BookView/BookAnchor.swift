//
//  BookAnchor.swift
//  Variorum
//
//  Phase 13f, batch 5 — W21: THE BOOK'S PLACE, carried across a mode switch.
//
//  Her round-8 condition, verbatim: *"the remembered mode is fine as long as
//  there's a quick way to get from wherever you are in read to that same
//  point in book or outline - which I think there is? if you click over does
//  it move where you are?"* — CHECKED at the sitting: it did not. The three
//  book modes each kept their own place, and clicking `Outline · Book · Read`
//  landed wherever that surface last was. Round 8's ruling made the carry the
//  DEFAULT behaviour of the click-over, and this is its one brain.
//
//  ── WHAT THIS TYPE IS, AND WHAT IT DELIBERATELY IS NOT ───────────────────
//  It is ONE pure rule — "which post is this mode at" — over facts the modes
//  ALREADY hold. It invents no state: Outline's place is the book's focused
//  post, Book's is its spread, Read ▸ Pages' is its (post, page-in-post)
//  address. The one fact a mode does not hold is Read ▸ Scroll's scroll
//  position: `ReadingFlowView` tracks none, and per-row visibility reporting
//  is precisely the machinery 13c 2A deleted on her A6 ruling ("it seems a
//  bit buggy… remove it fully for now"). So leaving the scroll carries the
//  book's STANDING anchor — where she arrived — rather than re-adding a
//  subsystem she asked to have removed. Recorded, never implied.
//

import Foundation

nonisolated enum BookAnchor {
    /// What the book's surfaces know about where she is. Assembled by
    /// `BookViewModel` from its own state (plus the paged reader's reported
    /// address); synthesized freely by the pins.
    struct Place: Equatable, Sendable {
        /// Outline's live post — and the book's reading position everywhere.
        var focusedPostID: String?
        /// Book's pages, LEFT first (0, 1 or 2 of them).
        var spreadPostIDs: [String] = []
        /// Read ▸ Pages' address, reported by the paginated reader.
        var pagedPostID: String?
        /// Index's selected note, reported by the index column (wave 2c —
        /// the same one-step travel as the paginated reader's address).
        var indexPostID: String?
        /// Where the book was last carried TO — the answer for a surface
        /// that tracks no position of its own.
        var standingPostID: String?
        /// VX-304: Outline's LIVE note and the block her caret stands in —
        /// read from the editor under the caret at the switch (`BookView
        /// .switchMode`), only when it is the book's live note. nil ⇒ no
        /// caret to carry (nothing live, the open tail, any other mode).
        var livePostID: String? = nil
        var liveBlockID: String? = nil
    }

    /// The post `mode` is at, or nil when the book has no place at all
    /// (a cold open at the shelf's "book with nothing focused").
    ///
    /// Every arm falls back to the standing anchor rather than to nil: a
    /// carry that lands nowhere is indistinguishable from a carry that never
    /// happened, and the second is the bug this exists to fix.
    static func currentPost(
        mode: BookStructureModel.ViewMode,
        readForm: BookStructureModel.ReadForm,
        place: Place
    ) -> String? {
        switch mode {
        case .outline:
            return place.focusedPostID ?? place.standingPostID
        case .spread:
            // The page under her hands keeps its claim (the `adopt` anchor
            // rule, restated): a focused post ON the spread is where she is;
            // otherwise the spread's left page is.
            if let focused = place.focusedPostID, place.spreadPostIDs.contains(focused) {
                return focused
            }
            return place.spreadPostIDs.first ?? place.standingPostID
        case .read:
            switch readForm {
            case .pages:
                return place.pagedPostID ?? place.standingPostID
            case .flow:
                // The one surface that knows nothing (see the header).
                return place.standingPostID
            }
        case .index:
            // The index's place is its selected note (reported, like the
            // paginated reader's address).
            return place.indexPostID ?? place.standingPostID
        }
    }

    /// **VX-304 — where the click-over LANDS**: the post `currentPost` names
    /// and, leaving OUTLINE with her caret live in that very note, the BLOCK
    /// her caret stands in — so Outline → Index arrives with that block live
    /// (the Index consumes block landings: `BookIndexView.landOrSeed`, the
    /// Read click's road, row 38). Every other arm carries the note alone,
    /// exactly as before. The caret's OFFSET is not this value's: it travels
    /// on the note's one memory (`CommandRouter.currentBlock`, R-U1a-1), and
    /// the Index's landing enters the remembered block at it
    /// (`PaneCaretLanding.entering`).
    static func landing(
        mode: BookStructureModel.ViewMode,
        readForm: BookStructureModel.ReadForm,
        place: Place
    ) -> LandingTarget? {
        guard let post = currentPost(mode: mode, readForm: readForm, place: place) else {
            return nil
        }
        // A `switch`, not `==`: `ViewMode`'s synthesized `Equatable` is
        // isolated (this file's header names the reason).
        switch mode {
        case .outline:
            guard place.livePostID == post, let block = place.liveBlockID else {
                return LandingTarget(postID: post)
            }
            return LandingTarget(postID: post, blockID: block)
        case .spread, .read, .index:
            return LandingTarget(postID: post)
        }
    }
}
