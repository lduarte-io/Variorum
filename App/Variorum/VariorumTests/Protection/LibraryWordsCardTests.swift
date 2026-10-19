//
//  LibraryWordsCardTests.swift
//  VariorumTests — VX-306 U1b piece 4: THE ONCE-SHOWN WORDS CARD (rule 2; `notes/plans/vx-306-castle-open-road.md`
//  §7c (1), built exactly as drafted; P-VX306-K7 — one button, no Copy, no "later"). The card's model holds the
//  twelve words only until its one button; the face's words are §7c's verbatim. VX-307 U2b (VX-412): the card is the
//  PHONE's only now (P-VX307-U2b-0 — the Mac's first open has nothing in front of it, rules 2–3 as amended); the Mac's
//  face (`LibraryWordsCard.swift`) is retired, and with it its source pin (no copy road, no later door); the phone's
//  face stands unchanged (its model and words pinned here). The Mac's words show only at her look (`WordsBandTests`).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1b — the once-shown words card")
@MainActor
struct LibraryWordsCardTests {
    @Test func theWordsAreNumberedInTwoColumnsAndTheOneButtonForgetsThemAndOpensOnce() throws {
        let words = try RecoveryPhrase.generate()
        var opened = 0
        let card = LibraryWordsCardModel(words: words) { opened += 1 }
        let columns = card.columns
        #expect(columns.count == 2)
        #expect(columns[0].map(\.number) == Array(1...6))
        #expect(columns[1].map(\.number) == Array(7...12))
        #expect((columns[0] + columns[1]).map(\.word) == words)
        card.iveWrittenThemDown()
        #expect(opened == 1)
        #expect(card.words.isEmpty, "the words are forgotten at the button — never stored, never shown again")
        card.iveWrittenThemDown()
        #expect(opened == 1, "a second press does nothing")
    }

    /// §7c (1), verbatim (PROVISIONAL — hers at the bundle, QUESTIONS #233).
    @Test func theCardSaysSection7c1Verbatim() {
        #expect(ProtectionWords.wordsCardTitle == "Your twelve words")
        #expect(ProtectionWords.wordsCardLead == "Your library is encrypted. These twelve words open it — on this Mac, "
            + "on any copy of it, for as long as they are its words. Write them down now and keep them somewhere safe. "
            + "Variorum won't show them again.")
        #expect(ProtectionWords.wordsCardFoot == "You can add a passphrase later, as a convenience over the words. "
            + "Either one can reset the other.")
        #expect(ProtectionWords.wordsCardButton == "I've written them down")
    }
}
