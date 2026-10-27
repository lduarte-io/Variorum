//
//  TitleQuickfill.swift
//  Variorum (Mac)
//
//  **VX-569 (the VX-439 run, A-439-14) — the title field OFFERS a name, and
//  Tab takes it.** Her two notes:
//  · 10-20: *"auto fill in the first line of the post as the title if you
//    click into it, maybe just tab to complete it and enter."*
//  · 10-21: *"in a fresh note with no words, going to the title and tab should
//    make the title fill-in-able with the date so that you can enter it, as a
//    match to the quickfill title option."*
//
//  THE TRACE (A-439-14's "verify the existing first-line quickfill first"):
//  the note's title field had NO first-line quickfill. Clicking an untitled
//  note's title opened the rename field on its stored name ("") with the
//  note's DATE drawn faintly behind it (17y B2 (n)), and Tab — a SwiftUI
//  field's focus key — moved the keyboard on and filed the empty draft, a
//  no-op. The "first words offered, one tap to adopt" chip exists only on the
//  CAPTURE surfaces (`TitleSuggestionChip` — quick entry, the quick note). So
//  her 10-20 path did not work at all; this builds it, and the 10-21 date arm
//  on it.
//
//  THE OFFER, one rule: on an UNTITLED note, the note's own first words — the
//  capture chip's brain exactly (`NoteCardFace.suggestedTitle`: the first line
//  with words, its markdown rendered, capped at a word edge, no ellipsis — a
//  name, not a truncation); a note with no words is offered the name it
//  already shows, its DATE (the same string the masthead and every untitled
//  daily entry read by — `DisplayTitle`). A titled note is offered nothing.
//  The offer is drawn faint where the date always sat behind the open field
//  (one place, one font — nothing moves); Tab takes it into the field, typing
//  replaces it, ⏎ files it, ⎋ leaves the note untitled. Nothing is ever
//  applied for her (her item 4's law: an offer, never an action).
//

import Foundation
import GRDB
import VariorumCore

nonisolated enum TitleQuickfill {
    /// How many of the note's opening slots the offer may read (the capture
    /// chip reads what was typed; a note's opening is its first few blocks —
    /// one bounded, index-ordered read, P1).
    static let openingBlocks = 3

    /// **What the open title field offers** — nil where it offers nothing (a
    /// titled note, or no words and no shown day).
    static func offer(storedTitle: String?, openingTexts: [String], shownName: String) -> String? {
        guard DisplayTitle.isAbsent(storedTitle) else { return nil }
        if let words = NoteCardFace.suggestedTitle(forTypedText: openingTexts.joined(separator: "\n")) {
            return words
        }
        let day = shownName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !day.isEmpty, day != DisplayTitle.placeholder else { return nil }
        return day
    }

    /// The note's opening, read once when the field opens.
    static func opening(_ db: Database, postID: String) throws -> [String] {
        try Queries.leadingBlockTexts(db, containerID: postID, blocks: openingBlocks)
    }
}
