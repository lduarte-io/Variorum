//
//  LibraryWordsCardTests.swift
//  VariorumTests — VX-306 U1b piece 4: THE ONCE-SHOWN WORDS CARD (rule 2; `notes/plans/vx-306-castle-open-road.md`
//  §7c (1), built exactly as drafted; P-VX306-K7 — one button, no Copy, no "later"). The card's model holds the
//  twelve words only until its one button; the face's words are §7c's verbatim; the face carries no copy road.
//  (The creation itself — `createLibrary(passphrase: nil)` on the new road, the card, then the open — is
//  `ProtectionRoadRouteTests`'.)
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

    /// K7: no Copy door, no "later", and the words are never selectable — the clipboard never holds them.
    @Test func theFaceHasNoCopyRoadAndNoLaterDoor() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/Protection/LibraryWordsCard.swift"),
            encoding: .utf8)
        let code = source.split(separator: "\n").filter {
            let line = $0.trimmingCharacters(in: .whitespaces)
            return !line.hasPrefix("//") && !line.hasPrefix("///")
        }.joined(separator: "\n")
        for road in ["NSPasteboard", "UIPasteboard", "Copy", ".textSelection(.enabled)", "Later", "later"] {
            #expect(!code.contains(road), "no copy road and no later door (\(road))")
        }
        #expect(code.contains(".textSelection(.disabled)"))
        #expect(code.components(separatedBy: "Button(").count == 2, "exactly one button")
    }
}
