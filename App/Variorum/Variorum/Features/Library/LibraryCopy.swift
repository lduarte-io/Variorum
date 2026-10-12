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
    /// 13n-c UX walk W-UX-3: the pick's row leads with its count; the info
    /// panel says the doors are above (T-12: it named three of four).
    /// PROVISIONAL words, her copy pass.
    static func notesPicked(_ count: Int) -> String { "\(count) notes selected" }
    static func pickedPanelLine(_ count: Int) -> String {
        "\(count) notes selected \u{2014} the doors above the list act on all of them."
    }

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

    // **The cap's sentence LEFT with the cap** (13o U2, R-13o-9): "showing
    // the first 40 — narrow the search" spoke for the block hits' cap, the
    // last capped listing in the Library. The cap is gone — named blocks and
    // scraps page in the search state's answer sheet — so nothing is left
    // for the line to say.

    /// The paged listing's end while the next page is on its way (17y B1 (k)).
    static let loadingMoreNotes = "loading more notes…"

    /// A note with no words in it yet — the Notes card's quiet second line
    /// (13g's own literal, moved here at 13u3 UNIT B when the card's second
    /// line stopped being "whatever the snippet was").
    static let noTextYet = "No text yet"
}
