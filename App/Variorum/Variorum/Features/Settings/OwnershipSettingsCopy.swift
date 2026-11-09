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

import Foundation

nonisolated enum OwnershipSettingsCopy {
    static let section = "Books"

    static let badgesTitle = "Show ownership badges"

    /// **VX-905 (the VX-914 run, batch 1 — her #264 word: "ticket moving 'show
    /// ownership badges' into the mcp part of settings - it makes more sense
    /// there")**: the row's ONE line in Settings ▸ MCP, its whole text
    /// (`badgesHelp`, unchanged) behind the (i) — the pane's idiom
    /// (`ExplainerLine`). It names exactly what the switch governs today: the
    /// in-book "also in other books" mark, the "owned by" chip and the Private
    /// eye — NOT the shared icon, which draws without it. PROVISIONAL F-905,
    /// flagged for her wording bundle.
    static let badgesSummary = "One switch for the marks on notes in other books, owned notes and Private ones."

    static let badgesHelp =
        "In a book, a small mark on a note that also lives in other books (hover names them "
        + "\u{2014} editing it there edits it here). In gatherings, tag listings and the "
        + "Library, \u{201C}owned by\u{201D} on a note an owned book holds \u{2014} click it to "
        + "open that book at the note. "
        // VX-831 (PROVISIONAL wording, her bundle): the Private mark joins the
        // family's one switch, so the switch says it governs it — and, since
        // her R-878-K3, WHEN it shows (only while a client is approved).
        + "While an AI client is approved, a Private note or book wears a closed eye "
        + "\u{2014} hover it to see why. "
        + "Off: no marks anywhere; nothing else changes. Synced."

    static let hideOwnedTitle = "Hide notes an owned book holds, in gatherings and tag listings"

    static let hideOwnedHelp =
        "Off (the default): gatherings and tag listings show every matching note, and one an "
        + "owned book holds wears its \u{201C}owned by\u{201D} mark. On: they leave such notes "
        + "out \u{2014} each gathering can still choose for itself in its settings. The Library "
        + "always shows everything. Synced."
}
