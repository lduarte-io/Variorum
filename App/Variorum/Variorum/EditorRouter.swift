//
//  EditorRouter.swift
//  Variorum (Mac)
//
//  Parent-composition routing for the focused editor: commands address the
//  active editor through this, never feature-to-feature. Mac-only (the TK2
//  editor is the Mac's surface); split out of AppSession when the session
//  became shared with the mobile target (Phase 8).
//

import CoreGraphics
import Observation
import VariorumCore

@MainActor
@Observable
final class EditorRouter {
    /// **WHICH QUESTION EACH FIELD ANSWERS** (the 18d ladder's MINOR-1 — the
    /// rule this file was missing, stated once so no door has to guess):
    ///
    /// - `active` answers *"which text view attached last"*. It is the right
    ///   question for **attachment**: is a full-document editor mounted at
    ///   all, does it own a scroll view, is there anything to tear down.
    /// - `editing` answers *"which editor is she writing in"*. It is the
    ///   right question for any door that acts on the caret — the block she
    ///   is in, the block it exports, the block it jumps from.
    ///
    /// They agree everywhere except the book's Outline, where a second
    /// `InlineEditorSurface` for the focused note attaches ~60 ms after the
    /// real one and takes `active` (the KnownIssues row has the trace). A
    /// caret door reading `active` there acts on a projection-less shadow —
    /// silently, because the shadow answers nil to everything. **A door
    /// about the caret reads `editingOrActive`.**
    weak var active: EditorViewModel?

    /// **THE EDITOR UNDER THE CARET** (18d batch 1, her U-10 — the sidebar's
    /// note box renders this model's bar).
    ///
    /// It is NOT `active`, and the difference is a MEASURED fact about the
    /// book's Outline, not a preference. `active` means "the last text view
    /// to attach", and in the Outline a SECOND `InlineEditorSurface` for the
    /// same note runs `makeNSView` ~60 ms after the real one (traced on the
    /// dev build, 2026-09-08: models `…d215b700` then `…d0b61e00`, both from
    /// `InlineEditorSurface.makeNSView`; only the first ever receives a
    /// projection or a selection change). The second attaches, takes
    /// `active`, and never disappears — so a bar built from `active` renders
    /// a model with no blocks, no caret and no word count: "block —", commit
    /// greyed, an empty footer. That was the first walk's finding, and it is
    /// PRE-EXISTING (it also reaches `ShellActions`' active-editor door, the
    /// lock door and the quit door — recorded in KnownIssues, not fixed here).
    ///
    /// So the box asks a different question, and asks it of the one place
    /// that can only be true of the real editor: the model publishes itself
    /// here when it computes a CARET CONTEXT, which needs a text view that
    /// receives selection changes and a projection that has landed. Assigned
    /// only on a CHANGE, so the write costs one comparison per caret move and
    /// wakes a reader only when the editor itself changes.
    weak var editing: EditorViewModel?

    /// **The editor a CARET DOOR should act on** (the 18d ladder's MINOR-1).
    /// `editing` when a projection has landed and a caret has been computed;
    /// `active` while it has not — a freshly attached editor that has not yet
    /// reported a caret is still the only editor there is, and falling back
    /// keeps every door's behaviour outside the Outline byte-identical.
    var editingOrActive: EditorViewModel? { editing ?? active }
    /// **The page she left, per post — the reading line WITH ITS PLACE** (18l
    /// U0c; `ReadingAnchor` is U0b's). Content-anchored (the accepted memo:
    /// never px-anchored — the line she was reading, by offset), and since U0c
    /// it also carries how far below the viewport's top edge that line sat, so
    /// a re-open (her R-18l-1: *"restores where you were"*) and a mode round
    /// trip put the page back EXACTLY: an offset alone replayed "that line at
    /// the viewport top", which ate a page's 24-pt top air on every re-open and
    /// snapped a wheel-scrolled page by the edge's cut into its line.
    /// Session-only, never persisted, never synced; written at the Write
    /// editor's `teardown`, restored by `renderFull`'s cold mount.
    @ObservationIgnored var scrollPlaces: [String: ReadingAnchor] = [:]

    /// **The OFFSET-ONLY view of `scrollPlaces`** — kept as the pins' seam (the
    /// RAISE-M1 pins seed a session anchor as a bare offset and ride
    /// unmodified). Reading drops the place; writing an offset stores it as the
    /// reading line AT the top (inset 0, not in the top air) — exactly what an
    /// offset anchor always meant. An entry whose offset is unchanged keeps its
    /// place. Nothing in the app writes through here.
    var scrollAnchors: [String: Int] {
        get { scrollPlaces.mapValues(\.offset) }
        set {
            scrollPlaces = scrollPlaces.filter { newValue[$0.key] != nil }
            for (postID, offset) in newValue where scrollPlaces[postID]?.offset != offset {
                scrollPlaces[postID] = ReadingAnchor(offset: offset, inset: 0, inPageTopAir: false)
            }
        }
    }

    /// **Where the TAKES board's article was left, per note** (17p batch a,
    /// ledger row 1 — her ruling R-Q1: *"it should remember your scroll
    /// position"*). Write's twin is `scrollAnchors` above, and this sits
    /// beside it for the same reason that one does: the board's own model
    /// (`TakesViewModel`, and with it `TakesBoardLayout`) is per-MOUNT
    /// `@State`, so a mode round trip destroys it — a memory that is to
    /// survive leaving the page can only live at the session.
    ///
    /// Session-only and never persisted — R-Q1's own letter ("not across
    /// launches"); a cold launch lands on the remembered block instead.
    ///
    /// A PLACE, not a pixel: the row at the top of the viewport — or the top
    /// of the page itself — and deliberately nothing finer (the sub-row
    /// pixels were tried and removed: a relative nudge from a frame one pass
    /// stale doubled its own correction; the measurements are on
    /// `TakesBoardLayout.ArticlePlace`). A raw content offset is not stable
    /// across mounts in a lazy column — the rows above the fold are estimated
    /// until realized, so the same y means a different block on the way back
    /// (measured on her 262-block note: ~390 pt, two blocks, high).
    @ObservationIgnored var takesArticlePlaces: [String: TakesBoardLayout.ArticlePlace] = [:]

    /// **Which block was CURRENT when the Takes board was last shown** — the
    /// row's `placementID`, per note, for the session (17q piece 6, her
    /// ruling R-Q21 on J14: *"the same block"* means the note's current block
    /// did not CHANGE while she was away).
    ///
    /// It rides beside the place above because the two answer one question
    /// together: the place says where the page was, and this says which block
    /// she was in there. A landing outranks the remembered place only when it
    /// names a DIFFERENT block than this one — so a plain mode round trip
    /// (leave, ⌘1, ⌘2, nothing clicked) restores exactly, and only a
    /// deliberate move to another block makes the landing win.
    ///
    /// A PLACEMENT id rather than a block id, so the comparison against a
    /// landing — which is a placement id, the article `ForEach`'s own
    /// identity — needs no map at the moment it is made
    /// (`TakesBoardLayout.landingOutranks`). Session-only, never persisted,
    /// never synced; written by the board whenever its live pane becomes or
    /// changes, read ONCE per mount as a snapshot (the value is about the
    /// PREVIOUS showing, so it must not move under this one).
    @ObservationIgnored var takesArticleCurrentRows: [String: String] = [:]

    /// **The Takes find's session slot** (18l-c U7 — the design brief's
    /// decision 3: the "only chosen takes" toggle is SESSION-remembered, ONE
    /// global slot, PROVISIONAL — per-note is one line; the query rides beside
    /// it, the find pasteboard's own reach in one app). It lives here beside
    /// the article's memories for their reason: the board's model is per-MOUNT
    /// and dies with a mode round trip. Session-only, never persisted, never
    /// synced.
    @ObservationIgnored var takesFind = TakesFindMemory()

    /// **The Takes board's `show ▾` filter, per note** (VX-170 — her ruling
    /// R-VX170-5: *"persistence is session-only, per note (the Takes-row-memory
    /// precedent): survives mode flips within the session, resets on the next
    /// open"*). It sits beside the article's memories for their reason: the
    /// board's model is per-MOUNT and dies with a mode round trip, so a filter
    /// that is to survive leaving the page can only live at the session.
    /// Session-only, never persisted, never synced, never a setting — a
    /// relaunch starts every note at "all takes". Only THE takes board reads or
    /// writes it (`TakesLensFilterController.applies`).
    @ObservationIgnored var takesShowFilters: [String: LensTakeFilter] = [:]

    /// **Which of the Takes board's fans are OPEN, per note** (VX-428 — her
    /// ruling R-601-2, built on the VX-170 road her R-VX170-5 laid: *"session-
    /// only, per note (the Takes-row-memory precedent): survives mode flips
    /// within the session"*). The tester's words: *"I wish my current Takes
    /// stayed open even when I briefly switch to 'Write' to check on
    /// something."* It sits beside the article's memories for their reason:
    /// the board's model is per-MOUNT (`TakesBoardLayout.expandedBlocks` lives
    /// in it), so an open-fan set that is to survive a mode round trip can
    /// only live at the session.
    ///
    /// Block ids, per note id; an empty set is never stored (close-all forgets
    /// the note). Session-only, never persisted, never synced, never a setting
    /// — a relaunch opens every note's board plain. Only THE takes board reads
    /// or writes it (`TakesViewModel.landingEnabled` — Write's take panel and
    /// the Lenses board never do): the board SEEDS its layout from it at
    /// construction, before the first article geometry report, and writes
    /// every change back (`TakesViewModel.openExpansionMemory`).
    @ObservationIgnored var takesExpandedBlocks: [String: Set<String>] = [:]
}
