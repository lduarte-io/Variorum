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
//  address. Read ▸ Scroll's place was, until VX-645, the one fact no mode
//  held: `ReadingFlowView` tracked no position (13c 2A's per-row visibility
//  brain was deleted on her A6 ruling — "it seems a bit buggy… remove it
//  fully for now"), so leaving the scroll carried the book's STANDING anchor
//  — where she arrived. VX-645 gave the flow VX-562's follow-highlight (the
//  note its page SHOWS — `BookViewModel.viewedFlowPair`, derived from the
//  geometry the flow's landing already takes; no bar, no progress number —
//  A6 is not re-opened), and **VX-681 (B4-P4, ruled in at #248) carries from
//  it**: leaving Read ▸ Scroll lands the next mode on the story on screen.
//  With nothing viewed — she never scrolled and nothing has reported, the
//  flow's title holds the page, or an empty chapter's heading names no note
//  — the standing anchor answers, exactly as before.
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
        /// **VX-681 — Read ▸ Scroll's viewed note**: the story its page shows
        /// (VX-645's follower — `BookViewModel.viewedFlowPair.postID`), nil
        /// when nothing is viewed.
        var flowViewedPostID: String? = nil
        /// VX-304: Outline's LIVE note and the block her caret stands in —
        /// read from the editor under the caret at the switch (`BookView
        /// .switchMode`), only when it is the book's live note. VX-630: the
        /// INDEX's live note and block when the departing mode is Index (its
        /// one live pane is the block her caret stands in — reported to the
        /// book as `indexLivePostID` / `indexLiveBlockID`). nil ⇒ no caret to
        /// carry (nothing live, the open tail, any other mode).
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
                // VX-681: the story its page shows (VX-645's follower); with
                // nothing viewed, where she arrived (see the header).
                return place.flowViewedPostID ?? place.standingPostID
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
    /// Read click's road, row 38). **VX-630 — and the way back:** leaving
    /// INDEX with its live pane in that very note names the pane's block, so
    /// Index → Outline reopens at her block rather than the note's start (the
    /// Outline consumes it as a focus at the block — `BookViewModel
    /// .carryPlace`). The spread and Read arms carry the note alone, exactly
    /// as before. The caret's OFFSET is not this value's: it travels on the
    /// note's one memory (`CommandRouter.currentBlock`, R-U1a-1), and each
    /// landing enters the remembered block at it (`PaneCaretLanding.entering`
    /// in the Index; `EditorViewModel.rememberedArrivalLanding` in the
    /// Outline's editor).
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
        case .outline, .index:
            guard place.livePostID == post, let block = place.liveBlockID else {
                return LandingTarget(postID: post)
            }
            return LandingTarget(postID: post, blockID: block)
        case .spread, .read:
            return LandingTarget(postID: post)
        }
    }
}
