//
//  LibrarySearchFaceTests.swift
//  VariorumTests
//
//  **13o U2 — the answer sheet's FACES** (Direction C, R-13o-15): the band's
//  words (the echo, the honest counts, the chips' words), the snippet's
//  marks in the index's own folding, the "in another take" badge, the kind
//  words — the pure rules the band and the sheet render — plus a mount of
//  the band in both voices, light and dark (the walk is the acceptance; this
//  holds that the face builds and lays out in every room).
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13o U2 — the answer sheet's faces (the band's words, the marks, the badge)")
struct LibrarySearchFaceTests {
    // F-W-3 (the VX-83 walk's W4 oddity): the em-dash is the ECHO's
    // separator — a tag alone leads with the counts bare.
    @Test func theCountsLeadBareWithoutAnEcho() {
        #expect(LibrarySearchFace.countsLead("1 book \u{00B7} 17 notes", afterEcho: false)
                == "1 book \u{00B7} 17 notes")
        #expect(LibrarySearchFace.countsLead("3 books \u{00B7} 29 notes", afterEcho: true)
                == "\u{2014} 3 books \u{00B7} 29 notes")
    }

    @Test func theCountsAreHonestPerKindAndLeaveOutWhatIsNotThere() {
        #expect(LibrarySearchCopy.counts(.init(books: 3, notes: 29, passages: 118, scraps: 6))
                == "3 books \u{00B7} 29 notes \u{00B7} 118 passages \u{00B7} 6 scraps",
                "the mockup's own line")
        #expect(LibrarySearchCopy.counts(.init(books: 0, notes: 1, passages: 1, scraps: 0))
                == "1 note \u{00B7} 1 passage")
        #expect(LibrarySearchCopy.counts(.init(books: 0, notes: 0, passages: 0, scraps: 0))
                == LibrarySearchCopy.nothingFound)
        #expect(LibrarySearchCopy.echo("dream") == "\u{201C}dream\u{201D}")
        #expect(LibrarySearchCopy.wingChip("Home") == "in: Home")
        #expect(LibrarySearchCopy.allLines(7) == "all 7 \u{203A}")
        // JUSTIFIED EDIT (VX-84a): `tagAlone` ("Type a word to search inside
        // #dream #life/goals.") DIED with P-13o-U2-6 — a tag typed alone
        // narrows the Library's own listing now (D-1); the band counts the
        // blocks it names beside the books and notes.
        #expect(LibrarySearchCopy.counts(.init(books: 1, notes: 12, passages: 0, scraps: 0, blocks: 3))
                == "1 book \u{00B7} 12 notes \u{00B7} 3 blocks")
    }

    /// Ladder round 1, NIT-1: ONE words reader for every band's echo
    /// (`SearchFieldWords`, the shared home), speaking the PARSER's letter —
    /// a quoted phrase rides whole, `#path` is a tag (trailing slashes
    /// trimmed), a lone `#` is a word, and `#/` is NEITHER. Both sheets'
    /// models read it (`LibrarySearchQuestion.read`, `BookSearchModel.read`).
    @Test func theOneWordsReaderSpeaksTheParsersLetter() {
        #expect(SearchFieldWords.words(of: "dream  \"old  house\" #life/goals # #/ rain")
                == "dream \"old  house\" # rain",
                "phrases whole, tags and #/ aside, a lone # a word")
        #expect(SearchFieldWords.tagPaths(of: "#a #b/c/ #/ # words") == ["a", "b/c"])
        let question = LibrarySearchQuestion.read("lantern #x/ #/")
        #expect(question?.words == "lantern" && question?.tagPaths == ["x"],
                "the Library's question reads the shared rule")
        let book = BookSearchModel.read("lantern \"two words\" #x", visibility: .living)
        #expect(book?.words == "lantern \"two words\"",
                "the book's echo reads the SAME rule — a phrase no longer splits")
    }

    @Test func theMatchedWordsAreMarkedAndTheRestIsMuted() {
        let tokens = VoiceTokens.resolve(voice: .study, dark: false)
        // The composer's own marked snippet (STX/ETX around the match), read
        // through its one public reader — the segments the sheet is handed.
        let line = LibrarySearchFace.snippet(
            SearchComposer.snippetSegments("…woke with the \u{2}dream\u{3} still wet…"),
            tokens: tokens)
        #expect(String(line.characters) == "…woke with the dream still wet…")
        let runs = line.runs.map { (String(line[$0.range].characters), $0.backgroundColor, $0.foregroundColor) }
        #expect(runs.count == 3)
        #expect(runs[1].0 == "dream" && runs[1].1 == tokens.wash && runs[1].2 == tokens.ink,
                "the match wears the wash, in the ink (the mockup's mark)")
        #expect(runs[0].1 == nil && runs[0].2 == tokens.muted && runs[2].2 == tokens.muted)
    }

    @Test func aHitInAnUnrenderedTakeSaysSoAndOnlyATakeCan() {
        #expect(LibrarySearchFace.isInAnotherTake(kind: .take, rendered: false))
        #expect(!LibrarySearchFace.isInAnotherTake(kind: .take, rendered: true))
        #expect(!LibrarySearchFace.isInAnotherTake(kind: .comment, rendered: false),
                "a comment is not a take")
        #expect(LibrarySearchCopy.kindWord(.take) == nil && LibrarySearchCopy.kindWord(.title) == nil,
                "prose and the head say nothing")
        #expect(LibrarySearchCopy.kindWord(.blockName) == "block name"
                && LibrarySearchCopy.kindWord(.comment) == "comment"
                && LibrarySearchCopy.kindWord(.noteMeta) == "floating notes"
                && LibrarySearchCopy.kindWord(.takeLabel) == "take label")
    }

    @Test(arguments: [ThemeVoice.terminal, .study], [false, true])
    func theBandLaysOutInEveryRoom(voice: ThemeVoice, dark: Bool) throws {
        let tokens = VoiceTokens.resolve(voice: voice, dark: dark)
        let question = try #require(LibrarySearchQuestion.read("dream #journal "))
        let band = LibrarySearchBand(
            tokens: tokens, question: question,
            counts: .init(books: 3, notes: 29, passages: 118, scraps: 6),
            visibility: .living, wingName: "Home",
            dayChip: (label: "edited on Sep 14", help: "", onClear: {}),
            onRemoveTag: { _ in }, onToggleArchived: {})
        let host = NSHostingView(rootView: band.frame(width: 900))
        host.frame = NSRect(x: 0, y: 0, width: 900, height: 60)
        host.layoutSubtreeIfNeeded()
        let fitting = host.fittingSize
        #expect(fitting.height > 16 && fitting.height < 60, "one quiet line: \(fitting)")
    }
}
