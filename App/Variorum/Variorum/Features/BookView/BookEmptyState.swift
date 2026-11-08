//
//  BookEmptyState.swift
//  Variorum (Mac)
//
//  VX-45 (the VX-914 run, batch 3 — KnownIssues row 102's 13i-e member,
//  F-U2-3): THE book views' empty state, ONE home for its three faces —
//  Outline, Read ▸ Pages and Book (Index and Read ▸ Scroll draw none). An
//  ARCHIVED gathering assembles empty everywhere (R-13ie-3), and the generic
//  "This book has no notes yet." said nothing true of it; the Archived row
//  already says "gathering · shows nothing while archived". Folded in at the
//  orchestrator's ruling (a batch expansion of VX-611's kind-word class,
//  FLAGGED for her bundle): a LIVE gathering that matches nothing is not a
//  book with no notes either — it speaks its own kind. A book's line is
//  byte-for-byte the shipped one. PROVISIONAL wording, her bundle.
//
//  The VX-914 ladder's N2: the fold-in first said "No note matches this
//  gathering yet." — false when notes DO match the rule but the assembly
//  hides them (a gathering showing no owned notes, by its own toggle or the
//  global default, whose matches are all owned; or matches that are all
//  archived — the assembly reads only un-archived notes). The line says what
//  is true whenever the face draws it — the gathering shows nothing — and
//  claims nothing about why.
//

import VariorumCore

nonisolated enum BookEmptyStateCopy {
    /// A book with no member notes (the shipped line, unchanged).
    static let book = "This book has no notes yet."
    /// An archived gathering — it shows nothing while archived.
    static let archivedGathering =
        "This gathering is archived, so it shows nothing until you unarchive it."
    /// A live gathering that shows nothing (the fold-in) — its rule matching
    /// nothing, or every match hidden (owned notes it hides, archived notes);
    /// the line is true of all of them (the ladder's N2).
    static let gathering = "This gathering shows no notes yet."

    /// The line for the book on screen (nil — not read yet — is a book's).
    static func line(for reading: Reading?) -> String {
        guard let reading, reading.kind == .gathering else { return book }
        return reading.archivedAt != nil ? archivedGathering : gathering
    }
}
