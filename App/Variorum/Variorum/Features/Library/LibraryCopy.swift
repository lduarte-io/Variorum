//
//  LibraryCopy.swift
//  Variorum (Mac)
//
//  What the LISTING says about ITSELF — the sentences the Library speaks
//  when there is nothing to show, or when it is showing less than it holds.
//  One place, so the List mode and the Notes mode can never word the same
//  fact differently, and so no sentence lives as a literal in a view body
//  (review focus F-0's "no string-as-rule in a view").
//
//  Minted at the 18h ladder's R1-4, which found the second of these missing:
//  the listing has been capped at 40 per kind since 13g and never said so —
//  benign while the answer was inherently top-N ("the 40 most recently
//  edited"), wrong the moment this letter made the order alphabetical and
//  the question a SET. The day's own answer is uncapped (see
//  `LibraryCatalogModel.search`); everything else says what it is doing.
//
//  The DAY's empty answer is not here: it is `LibraryDayFace.emptyAnswer`,
//  because it carries the day's caveat and is the day filter's own face.
//

import Foundation
import SwiftUI

nonisolated enum LibraryCopy {
    /// The List mode's silence — books, notes and blocks all empty.
    static let nothingMatches = "Nothing matches."

    /// The Notes mode's silence (it lists notes only, and says so).
    static let noNotesMatch = "No notes match."

    /// The scope picker's tooltip, in both of its states — named here so the
    /// view chooses between two sentences rather than carrying one and a
    /// placeholder (the ladder's R2-7, closing R1-12's complaint the other
    /// way: a conditional MODIFIER flipped the picker's view identity and
    /// tore the segmented control down on every arm and clear).
    static let scopeDoor = "Scope the listing to books, notes or blocks"
    static let scopeDoorUnderADay =
        "A day names notes \u{2014} clear it to scope books and blocks again"

    /// **The cap, spoken** (P-2's grammar: the app says what it did). Drawn
    /// under a listing that had more rows than it drew.
    static func showingTheFirst(_ page: Int) -> String {
        "showing the first \(page) \u{2014} narrow the search"
    }

    /// The paged listing's end while the next page is on its way (17y B1 (k)).
    static let loadingMoreNotes = "loading more notes…"

    /// A note with no words in it yet — the Notes card's quiet second line
    /// (13g's own literal, moved here at 13u3 UNIT B when the card's second
    /// line stopped being "whatever the snippet was").
    static let noTextYet = "No text yet"
}


/// The quiet line under a capped listing. One view, both modes — the same
/// reason the sentences above live in one place.
struct LibraryTruncationLine: View {
    let tokens: VoiceTokens
    var page: Int = LibraryCatalogModel.blockCap

    var body: some View {
        Text(tokens.chromeLabel(LibraryCopy.showingTheFirst(page)))
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
            .lineLimit(1)
            .fixedSize()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
