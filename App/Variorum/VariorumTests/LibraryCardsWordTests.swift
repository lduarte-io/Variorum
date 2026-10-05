//
//  LibraryCardsWordTests.swift
//  VariorumTests
//
//  17y item (d) — THE LIBRARY'S CARDS VIEW IS CALLED "Cards" (F-U6-5, her
//  pick at the question tool, QUESTIONS #176: two "Notes" sat side by side
//  at the top of the Library — the scope segment, the kind of thing, and
//  the view mode; the view mode renames). 13s may re-voice; the word is hers.
//
//  The mode's word lives in ONE home (`LibraryCatalogModel.Mode.label`, the
//  `Scope.label` precedent beside it) and the picker renders it from there —
//  never a literal in the view body.
//
//  Red-on-old, stated: the pre-fix picker spelled its three words inline
//  (`Text(tokens.chromeLabel("Notes")).tag(LibraryCatalogModel.Mode.notes)`),
//  so the source scan finds three inline mode words and the "Notes" segment.
//

import Foundation
import Testing
@testable import Variorum

@Suite("17y (d) — the Library's cards view is called \"Cards\"")
struct LibraryCardsWordTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static func source(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: relative), encoding: .utf8)
    }

    /// The view picker never spells a mode word inline — it renders each
    /// mode's one word (so "Cards" cannot drift between two sites).
    @Test func thePickerRendersTheModeWordsFromTheirOneHome() throws {
        let view = try Self.source("Variorum/Features/Library/LibraryCatalogView.swift")
        let inline = try Regex(#"chromeLabel\("[^"]*"\)\)\.tag\(LibraryCatalogModel\.Mode\."#)
        #expect(view.matches(of: inline).count == 0,
                "no mode word is a literal in the view body")
        #expect(!view.contains(#"chromeLabel("Notes")).tag(LibraryCatalogModel.Mode.notes)"#),
                "the cards view no longer says Notes")
    }

    /// The words themselves (added with the fix — `Mode.label` is the home
    /// the fix made).
    @Test func theModeWordsAreListCardsTimeline() {
        #expect(LibraryCatalogModel.Mode.allCases.map(\.label) == ["List", "Cards", "Timeline"])
    }
}
