//
//  SearchPassageBlockMarkTests.swift
//  VariorumTests
//
//  VX-90 (a rider of VX-819 batch 1) — her 13o idea: *"maybe it should say
//  what block they're in?"* The face half: a passage line quietly wears its
//  block's NAME after its words, inside the snippet's one Text (so the
//  snippet's measure never moves for it); a block-name hit never repeats its
//  own name; an unnamed block's line draws exactly as it always did.
//  PROVISIONAL (the wording "· name", the inline-trailing placement).
//
//  BUILD pins for a new face (a Feature rider, not a bug row): on the
//  pre-change tree they do not compile (`blockMark` did not exist).
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-90 — a passage line says which block it's in")
struct SearchPassageBlockMarkTests {
    @Test func aNamedBlocksLineWearsItsNameAndNothingElseDoes() {
        #expect(LibrarySearchFace.blockMark(kind: .take, blockName: "Lantern") == "\u{00B7} Lantern")
        #expect(LibrarySearchFace.blockMark(kind: .takeLabel, blockName: "Lantern") == "\u{00B7} Lantern")
        #expect(LibrarySearchFace.blockMark(kind: .comment, blockName: "Lantern") == "\u{00B7} Lantern")
        #expect(LibrarySearchFace.blockMark(kind: .savepoint, blockName: "Lantern") == "\u{00B7} Lantern")
        #expect(LibrarySearchFace.blockMark(kind: .blockName, blockName: "Lantern") == nil,
                "a name hit's words ARE the name — never said twice")
        #expect(LibrarySearchFace.blockMark(kind: .take, blockName: nil) == nil, "an unnamed block: no mark")
        #expect(LibrarySearchFace.blockMark(kind: .take, blockName: "  \n ") == nil, "never a blank mark")
        #expect(LibrarySearchFace.blockMark(kind: .take, blockName: "two\nlines") == "\u{00B7} two lines",
                "a name's own newline folds, as the snippet's do (VX-88)")
    }

    @Test func theMarkRidesAfterTheWordsAndAnUnmarkedLineIsByteUnchanged() {
        let tokens = VoiceTokens.resolve(voice: .study, dark: false)
        let segments = SearchComposer.snippetSegments("…the \u{2}harbor\u{3} light…")
        let plain = LibrarySearchFace.snippet(segments, tokens: tokens)
        #expect(LibrarySearchFace.snippet(segments, blockMark: nil, tokens: tokens) == plain,
                "no mark: the very line the sheet always drew")

        let marked = LibrarySearchFace.snippet(segments, blockMark: "\u{00B7} Lantern", tokens: tokens)
        #expect(String(marked.characters) == "…the harbor light…  \u{00B7} Lantern", "after the words")
        #expect(marked.runs.last?.foregroundColor == tokens.faint, "quiet: the faint ink")
        #expect(marked.runs.filter { $0.backgroundColor == tokens.wash }.map { String(marked[$0.range].characters) }
                == ["harbor"], "the match's mark is untouched")
    }
}
