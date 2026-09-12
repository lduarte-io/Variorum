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
    /// Top visible text location per post (UTF-16 offset) — content-anchored
    /// reopen restore (accepted memo: never px-anchor).
    @ObservationIgnored var scrollAnchors: [String: Int] = [:]

    /// **Where the TAKES board's article was left, per note** (17p batch a,
    /// ledger row 1 — her ruling R-Q1: *"it should remember your scroll
    /// position"*). Write's twin is `scrollAnchors` above, and this sits
    /// beside it for the same reason that one does: the board's own model
    /// (`TakesViewModel`, and with it `TakesBoardLayout`) is per-MOUNT
    /// `@State`, so a mode round trip destroys it — a memory that is to
    /// survive leaving the page can only live at the session.
    ///
    /// Deliberately a PIXEL offset where Write's is a content anchor: the
    /// article is an ordinary SwiftUI `ScrollView` whose rows are the note's
    /// blocks, so its offset means the same thing on re-entry (a note edited
    /// elsewhere re-lays out, and the restore clamps to the content's travel).
    /// Session-only and never persisted — R-Q1's own letter ("not across
    /// launches"); a cold launch lands on the remembered block instead.
    @ObservationIgnored var takesArticleOffsets: [String: CGFloat] = [:]
}
