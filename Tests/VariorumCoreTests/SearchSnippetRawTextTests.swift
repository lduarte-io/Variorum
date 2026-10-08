//
//  SearchSnippetRawTextTests.swift
//  VariorumCoreTests
//
//  VX-88 (the 13o follow-up run, VX-83) — the §M5 trace's CORE premise,
//  pinned headlessly: a passage's snippet copies the block's RAW text,
//  newlines included (I4 — a newline inside a block is content), so a window
//  that crosses one hands the face a line break. The face's half (SwiftUI
//  draws it as a second line in the row) is `SearchPassageLineRhythmTests`
//  in the Mac suite; the fix folds at the face (D-5) and leaves this — the
//  index and the composer — byte-untouched, which is why this pin stays green
//  on both sides of the fix.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-88 — a snippet carries its block's own newlines (the trace's core premise)")
struct SearchSnippetRawTextTests {
    @Test func aSnippetCrossingANewlineCarriesIt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Night")
            _ = try ops.newBlock(in: post.id, text: "we walked along\n\nthe harbor at night\nand home")
            let query = SearchQueryParser.parse("harbor ", typeAhead: true, visibility: .living)
            let page = try db.read { db in
                try Queries.searchPassages(db, query: query, scope: SearchScope(wingID: ""))
            }
            let take = try #require(page.passages.first { $0.kind == .take })
            let text = take.snippet.map(\.text).joined()
            #expect(text == "we walked along\n\nthe harbor at night\nand home",
                    "the raw text, both breaks included — the window crosses them")
            #expect(take.snippet.filter(\.isMatch).map(\.text) == ["harbor"])
        }
    }
}
