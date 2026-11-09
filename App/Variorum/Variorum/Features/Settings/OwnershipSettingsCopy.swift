//
//  OwnershipSettingsCopy.swift
//  Variorum (Mac)
//
//  13i-c U4 — the words of the two OWNERSHIP settings (the sitting record §6;
//  the 13i-c plan §3 — `ownership_badges` "1" by default, P-13ic-10, and
//  `hide_owned_default` "0" = SHOW, badged — "the Welcome lesson depends on
//  it"). Both synced, document semantics (the `arrival_flash` class).
//  PROVISIONAL copy — 13s re-voices it; the truths are ruled.
//
//  **The help copy's job is to not overclaim** (the `ReceiptStyleCopy` bar):
//  the badges only MARK (they change no membership), and hiding owned notes
//  reaches gatherings and tag listings only — the Library always shows
//  everything (R32), and each gathering may choose for itself.
//
//  **VX-934 (her ruling, the VX-914 handoff sitting, #269 — "let's split the
//  'book' related badges setting and if they're shown up completely from the
//  AI one, and move it out of MCP back to where it was")**: the badge switch
//  governs the BOOK marks again — the also-in-other-books mark and the "owned
//  by" chip — and its row is back in Settings ▸ Editor's "Books" section, as
//  it stood before VX-905 (a Toggle and its caption). The Private eye left the
//  family: it and the shared icon have their own switch in Settings ▸ MCP
//  (`MCPPaneCopy.aiMarksTitle`). VX-905's one-line summary for the MCP pane
//  went with the row.
//

import Foundation

nonisolated enum OwnershipSettingsCopy {
    static let section = "Books"

    static let badgesTitle = "Show ownership badges"

    /// VX-934: the eye's sentence (VX-831 / R-878-K3) left with the eye, and
    /// "Off" says what it hides now — these two marks, never every mark in
    /// the app (the AI pair keeps its own switch). PROVISIONAL wording, her
    /// bundle (F-934-B).
    static let badgesHelp =
        "In a book, a small mark on a note that also lives in other books (hover names them "
        + "\u{2014} editing it there edits it here). In gatherings, tag listings and the "
        + "Library, \u{201C}owned by\u{201D} on a note an owned book holds \u{2014} click it to "
        + "open that book at the note. Off: neither mark shows anywhere; nothing else changes. Synced."

    static let hideOwnedTitle = "Hide notes an owned book holds, in gatherings and tag listings"

    static let hideOwnedHelp =
        "Off (the default): gatherings and tag listings show every matching note, and one an "
        + "owned book holds wears its \u{201C}owned by\u{201D} mark. On: they leave such notes "
        + "out \u{2014} each gathering can still choose for itself in its settings. The Library "
        + "always shows everything. Synced."
}
