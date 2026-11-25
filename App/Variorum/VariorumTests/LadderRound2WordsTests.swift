//
//  LadderRound2WordsTests.swift
//  VariorumTests
//
//  **The VX-1036 ladder, round 2 — its two NITs, pinned as words and wiring.**
//
//  R2-3: a capture pick (the new-note box's and the menu-bar pad's ＋ — batch
//  4's `CaptureTagItems`) was drawn as the one tag card, so before any note
//  existed it carried a FILED note's hover words — "Tagged x" on the card,
//  "Take “x” off this note" on its ×. `TagChipCard` now takes its words
//  (defaulted to the filed note's, byte for byte), and the capture items hand
//  a pick's own.
//
//  Words and a source scan, not red-on-old: a copy NIT (no mechanism to
//  revert), the `BookReadMintSourceTests` shape for the wiring (`#filePath`'s
//  symlinks resolved; comment lines ignored).
//

import Foundation
import Testing
@testable import Variorum

private enum Source {
    static var appRoot: URL {
        URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// The file's code lines (comment lines dropped).
    static func codeLines(_ relative: String) throws -> [String] {
        let source = try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
        return source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init).filter {
            !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//")
        }
    }
}

@Suite("VX-1036 ladder R2-3 — a capture pick's card says a pick's words, not a filed note's")
struct CapturePickWordsTests {
    @Test func aFiledNotesCardSaysWhatItAlwaysSaid() {
        let words = TagChipHelp.filed("garden/rhubarb")
        #expect(words.card == "Tagged garden/rhubarb")
        #expect(words.remove == "Take \u{201C}garden/rhubarb\u{201D} off this note")
    }

    @Test func aPicksCardIsTrueOfATagNotYetOnAnyNote() {
        let words = CaptureTagCopy.pickHelp("garden/rhubarb")
        #expect(words.card == "\u{201C}garden/rhubarb\u{201D} goes on when the note is filed")
        #expect(words.remove == "Leave \u{201C}garden/rhubarb\u{201D} off this note")
        for line in [words.card, words.remove] {
            #expect(!line.contains("Tagged") && !line.hasPrefix("Take"),
                    "never a filed note's claim: \(line)")
            #expect(line == line.trimmingCharacters(in: .whitespaces), "no stray space: \(line)")
        }
        // Sentence case: no word but the path's own is capitalized past the first.
        let tail = words.remove.split(separator: " ").dropFirst()
            .filter { !$0.contains("garden") }
        #expect(tail.allSatisfy { $0 == $0.lowercased() }, "sentence case: \(words.remove)")
    }

    /// The wiring: the capture items hand the pick's words to the card, and
    /// the card falls back to the filed note's words only when handed none.
    @Test func theCaptureItemsHandThePicksWordsAndTheCardDefaultsToAFiledNotes() throws {
        let items = try Source.codeLines("Variorum/Core/Views/CaptureTagItems.swift")
        let call = try #require(items.firstIndex { $0.contains("TagChipCard(") }, "the picks' card")
        let callText = items[call..<min(call + 4, items.count)].joined(separator: " ")
        #expect(callText.contains("help: CaptureTagCopy.pickHelp(path)"),
                "the picks' card is handed a pick's words: \(callText)")

        let chips = try Source.codeLines("Variorum/Core/Views/TagChips.swift")
        #expect(chips.contains { $0.contains("let words = help ?? .filed(tag.path)") },
                "the card's words default to a filed note's")
        #expect(chips.contains { $0.contains(".help(words.card)") }
                    && chips.contains { $0.contains(".help(words.remove)") },
                "the card and its × say the words handed")
        #expect(!chips.contains { $0.contains(".help(\"Tagged") || $0.contains(".help(\"Take") },
                "no literal filed-note words left beside the default")
    }
}
