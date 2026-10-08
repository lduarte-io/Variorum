//
//  SearchPassageLineRhythmTests.swift
//  VariorumTests
//
//  VX-88 (the 13o follow-up run, VX-83) — her report: *"when there are many
//  results in a block the spacing between the results is weird."* The trace
//  (§M5 of `notes/plans/fixes/vx-83-search-followup.md`, SPECULATIVE until
//  this pin): `LibrarySearchLine` renders a passage's snippet as ONE `Text`
//  with `lineLimit(2)`, and a snippet whose window crosses a newline INSIDE
//  its block (I4 — newlines are content; FTS5's snippet copies the raw text)
//  draws two tight visual lines — or a line and a BLANK one, across a blank
//  line — inside one row, while its neighbours draw one. The rhythm breaks
//  exactly where one block holds many matches.
//
//  The CONFIRM (pin-first, the brief's rule): a passage whose snippet holds a
//  newline must stand exactly as tall as a passage whose snippet does not.
//  RED on the pre-fix tree confirms the trace; GREEN there would mean the
//  trace is wrong (record-only, stop). The fix's face rule (D-5) is pinned
//  beside it.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-88 — a passage line keeps one rhythm across its block's newlines", .serialized)
struct SearchPassageLineRhythmTests {
    /// Three notes whose matched take reads the same words, one plain, one
    /// broken by a newline, one by a blank line — searched through the real
    /// composer road, so the snippets are the index's own.
    private func passages() async throws -> (plain: SearchPassage, broken: SearchPassage, blank: SearchPassage) {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 88))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            func note(_ title: String, _ text: String) throws -> String {
                let post = try ops.createPost(title: title)
                _ = try ops.newBlock(in: post.id, text: text)
                return post.id
            }
            let plain = try note("Plain", "we walked along the harbor at night")
            let broken = try note("Broken", "we walked along\nthe harbor at night")
            let blank = try note("Blank", "we walked along\n\nthe harbor at night")
            let query = SearchQueryParser.parse("harbor ", typeAhead: true, visibility: .living)
            let page = try await db.read { db in
                try Queries.searchPassages(db, query: query, scope: SearchScope(wingID: ""))
            }
            func take(_ id: String) throws -> SearchPassage {
                try #require(page.passages.first { $0.noteID == id && $0.kind == .take })
            }
            return (try take(plain), try take(broken), try take(blank))
        }
    }

    private func height(_ passage: SearchPassage, _ tokens: VoiceTokens) -> CGFloat {
        let line = LibrarySearchLine(tokens: tokens, passage: passage, onOpen: {})
        let host = NSHostingView(rootView: line.frame(width: 640))
        host.frame = NSRect(x: 0, y: 0, width: 640, height: 200)
        host.layoutSubtreeIfNeeded()
        return host.fittingSize.height
    }

    @Test(arguments: [ThemeVoice.terminal, .study])
    func aSnippetCrossingANewlineStandsAsTallAsOneThatDoesNot(voice: ThemeVoice) async throws {
        let (plain, broken, blank) = try await passages()
        // The premise: the index's snippet carries the block's own newline.
        #expect(broken.snippet.map(\.text).joined().contains("\n"), "the snippet copies the raw text (I4)")
        #expect(blank.snippet.map(\.text).joined().contains("\n\n"))
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        let one = height(plain, tokens)
        #expect(abs(height(broken, tokens) - one) < 0.5,
                "a newline inside the block must not give its passage a second, tight line: \(height(broken, tokens)) vs \(one)")
        #expect(abs(height(blank, tokens) - one) < 0.5,
                "…nor a blank one: \(height(blank, tokens)) vs \(one)")
    }
}
