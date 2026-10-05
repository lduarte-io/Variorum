//
//  LibraryCardName.swift
//  Variorum (Mac)
//
//  **13u3 UNIT B — note-list skimmability (her item 4, RULED 2026-08-21).**
//  Her words: *"that's exactly the right suggestion. I think that's what
//  should show on the library - a little snippet of what the post starts
//  with."*
//
//  Two small things live here, one theme, and deliberately NOT inside
//  `LibraryCatalogView.swift` — the file the 18h batch already refused to
//  grow (P-9, and `LibraryTimeFace`'s own reason):
//
//  1. `LibraryCardName` — the COMPOSITION over the core brain
//     (`NoteCardFace`): one function, both note renderers, so the List row
//     and the Notes card can never call a note two different things. The
//     rule itself is core's; this only hands it the facts a catalog hit
//     carries.
//  2. `LibraryCardRead` — WHICH rows need the words read for them, and
//     whether the books come with. A pure plan rather than an `if` inside an
//     `async` loader, so the cost claim (P1: one bounded read for the window
//     on screen, and nothing at all for a listing that draws no words) is a
//     claim a pin can hold.
//

import Foundation
import VariorumCore

/// What a Library row leads with, and what it previews.
nonisolated enum LibraryCardName {
    /// The one call both renderers make.
    ///
    /// `leadingTexts` is what the card read returned for this note — empty
    /// for a row nothing was read for (the List mode's titled rows), which is
    /// exactly right: a named row never needed its words.
    static func card(
        for hit: Queries.CatalogHit, leadingTexts: [String], now: Date = Date()
    ) -> NoteCardFace.Card {
        NoteCardFace.card(
            storedTitle: hit.storedTitle,
            leadingTexts: leadingTexts,
            isJournal: hit.isJournalEntry,
            // `detail` on a note hit IS `entry_date` (`LibrarySortFace`'s own
            // note says so); `createdAt` is carried raw since 18h.
            entryDate: hit.kind == .post ? hit.detail : nil,
            createdAt: hit.createdAt)
    }

    /// **Does this row need its own words read for it?** A note with no name
    /// of its own that is not a daily entry — the rows item 4 is about. Book
    /// and block hits are never notes, and a named row already says what it
    /// is.
    static func leadsWithItsWords(_ hit: Queries.CatalogHit) -> Bool {
        hit.kind == .post && hit.storedTitle == nil && !hit.isJournalEntry
    }

    /// **What the Notes card's SECOND line says.**
    ///
    /// The preview where there is one; the empty-note line where the note has
    /// no words at all; and **nothing** where the card already LEADS with the
    /// note's words and there is nothing after them — a card that has said
    /// the whole note does not then announce that the note is empty, and it
    /// certainly does not say the same words twice.
    static func previewLine(_ card: NoteCardFace.Card) -> String? {
        if !card.preview.isEmpty { return card.preview }
        if case .words = card.lead { return nil }
        return LibraryCopy.noTextYet
    }
}

/// The card read's PLAN: which notes, and whether the books ride along.
nonisolated struct LibraryCardRead: Equatable {
    let ids: [String]
    let books: Bool

    /// **What each mode actually draws** (P1 — a listing pays for what it
    /// shows and nothing else):
    ///
    /// - **Notes** draws the whole card — a lead, a preview line and the book
    ///   names — so every listed note is read, books included (13g R5-6's
    ///   shape, unchanged).
    /// - **List** draws ONE line per note and no preview at all, so it reads
    ///   the words only for the rows that would otherwise be a wall of bare
    ///   dates, and never the memberships. In a library of named notes it
    ///   therefore costs nothing at all.
    /// - **Timeline** runs its own listing and draws neither.
    static func plan(
        mode: LibraryCatalogModel.Mode, hits: [Queries.CatalogHit]
    ) -> LibraryCardRead {
        switch mode {
        case .notes:
            return LibraryCardRead(ids: hits.filter { $0.kind == .post }.map(\.id), books: true)
        case .list:
            return LibraryCardRead(
                ids: hits.filter(LibraryCardName.leadsWithItsWords).map(\.id), books: false)
        case .timeline:
            return LibraryCardRead(ids: [], books: false)
        }
    }
}
