//
//  EditorRouter.swift
//  Variorum (Mac)
//
//  Parent-composition routing for the focused editor: commands address the
//  active editor through this, never feature-to-feature. Mac-only (the TK2
//  editor is the Mac's surface); split out of AppSession when the session
//  became shared with the mobile target (Phase 8).
//

import Observation

@MainActor
@Observable
final class EditorRouter {
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
    /// Top visible text location per post (UTF-16 offset) — content-anchored
    /// reopen restore (accepted memo: never px-anchor).
    @ObservationIgnored var scrollAnchors: [String: Int] = [:]
}
