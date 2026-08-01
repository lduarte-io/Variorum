//
//  MorningListTests.swift
//  VariorumTests
//
//  13g batch 6 — the pins for her morning ruling set (round 5): the block
//  line's wording (R5-4), the note cards' read-time snippet + books (R5-6),
//  and the un-live pane's takes routing (R5-1). The comment margin's move
//  (R5-3) is pinned beside its neighbours in `Phase13SurfaceTests`, where
//  the decor suite already lives.
//

import ConcurrencyExtras
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

/// The store prologue the editor harness uses, without an editor (these pins
/// need rows and a read, not a text surface).
@MainActor
private func withStore<T>(
    _ body: @MainActor (AppDatabase, AppSession) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        try await body(db, AppSession(database: db))
    }
}

@MainActor
@Suite("Her morning list (13g batch 6)", .serialized)
struct MorningListTests {

    // MARK: R5-4 — "block 1/16", no raw ID, no "blk"

    /// Her ruling: *"stop showing the actual ID of the block (1R3D9145 as an
    /// example), and rather than blk, show 'block 1/1'."*
    ///
    /// DISCRIMINATING REVERT: restore `CommitBar.caretLabel`'s old body
    /// (`"blk \(ordinal) · \(shortID(model.caretBlockID))"`, which is what
    /// `BlockLineLabel` replaced) and this fails on all three expectations —
    /// the prefix, the absent ID, and the em-dash case.
    @Test func theBlockLineNamesItsPlaceAndNothingElse() {
        #expect(BlockLineLabel.caret(ordinal: 1, of: 1) == "block 1/1")
        #expect(BlockLineLabel.caret(ordinal: 6, of: 23) == "block 6/23")
        // No raw identity anywhere in the rendered string — the ordinal is
        // read-time, the id stays the identity (9d's rule, unchanged).
        let label = BlockLineLabel.caret(ordinal: 3, of: 16)
        #expect(!label.contains("blk"))
        #expect(label.allSatisfy { $0.isLetter || $0.isNumber || $0 == "/" || $0 == " " })
        // A surface that knows the block but not its place says so, rather
        // than printing a wrong number.
        #expect(BlockLineLabel.caret(ordinal: nil, of: 9) == "block —")
    }

    // MARK: R5-6 — the Apple-Notes list's read-time extras

    /// Her ask: a Library view *"more similar to the apple notes view where
    /// you can see the first little bit of text."* The snippet is DERIVED
    /// (never stored), the books come from real membership rows, and the
    /// walk is bounded to the note's first few blocks so a long note costs
    /// what a short one does.
    ///
    /// DISCRIMINATING REVERT: drop `NoteCards.load`'s
    /// `guard result[postID]?.snippet.isEmpty ?? true` (the first-non-empty
    /// rule) and `theSnippetIsTheFirstBLOCKWithText` fails — the third
    /// block's text overwrites the first's.
    @Test func noteCardsCarryTheFirstTextAndTheBooksItIsIn() async throws {
      try await withStore { db, session in
        let post = try session.operations.createPost(title: "Orbit day")
        _ = try session.operations.newBlock(in: post.id, text: "First words here.")
        _ = try session.operations.newBlock(in: post.id, text: "Second block.")
        let book = try session.operations.createReading(name: "Orbit", kind: .curated)
        _ = try session.operations.addPostToReading(post.id, to: book.id)

        let cards = try await db.read { db in
            try NoteCards.load(db, postIDs: [post.id])
        }
        let card = try #require(cards[post.id])
        #expect(card.snippet == "First words here.")
        #expect(card.books == ["Orbit"])

        // A note in NO book carries none — the row simply shows nothing
        // there, which is the honest empty.
        let loose = try session.operations.createPost(title: "Loose")
        _ = try session.operations.newBlock(in: loose.id, text: "Alone.")
        let both = try await db.read { db in
            try NoteCards.load(db, postIDs: [post.id, loose.id])
        }
        #expect(both[loose.id]?.books.isEmpty == true)
        #expect(both[loose.id]?.snippet == "Alone.")
      }
    }

    /// The snippet SKIPS a leading empty block (a note that starts with a
    /// blank line is ordinary), and it is bounded twice — by characters and
    /// by how many blocks it will consult.
    @Test func theSnippetIsTheFirstBLOCKWithText() async throws {
      try await withStore { db, session in
        let post = try session.operations.createPost(title: "Starts blank")
        _ = try session.operations.newBlock(in: post.id, text: "")
        _ = try session.operations.newBlock(in: post.id, text: "The real opening.")
        _ = try session.operations.newBlock(in: post.id, text: "Later.")

        let cards = try await db.read { db in try NoteCards.load(db, postIDs: [post.id]) }
        #expect(cards[post.id]?.snippet == "The real opening.")

        // The character bound: a long block is cut, never carried whole.
        let long = try session.operations.createPost(title: "Long")
        _ = try session.operations.newBlock(
            in: long.id, text: String(repeating: "a", count: 5_000))
        let bounded = try await db.read { db in try NoteCards.load(db, postIDs: [long.id]) }
        #expect(bounded[long.id]?.snippet.count == NoteCards.snippetLimit)

        // The BLOCK bound: text that only appears past the window is not
        // hunted for — cost stays flat in note size (P1).
        let deep = try session.operations.createPost(title: "Deep")
        for _ in 0..<NoteCards.blockWindow {
            _ = try session.operations.newBlock(in: deep.id, text: "")
        }
        _ = try session.operations.newBlock(in: deep.id, text: "Way down here.")
        let capped = try await db.read { db in try NoteCards.load(db, postIDs: [deep.id]) }
        #expect(capped[deep.id]?.snippet.isEmpty == true,
                "the walk stops at \(NoteCards.blockWindow) blocks rather than scanning the note")
      }
    }

    // MARK: R5-1 — an un-live pane keeps TAKES, and only takes

    /// Her L5 word: *"having a takes projection first would be fine - i
    /// honestly don't think that lenses or compare need to be a side by side
    /// mode option for now or potentially ever."* So exactly one mode routes
    /// to the projection and the rest keep plain read prose.
    ///
    /// DISCRIMINATING REVERT: widen `ReadTakesView.holdsTakes` to
    /// `!= .write` and the lenses/compare/canvas expectations fail.
    @Test func onlyATakesPaneRendersTheTakesProjection() throws {
        let defaults = try #require(UserDefaults(suiteName: "13g-r5-1-\(UUID().uuidString)"))
        defer { defaults.removeSuite(named: defaults.description) }

        // First open = Write (S4-20), so an untouched note is prose.
        #expect(!ReadTakesView.holdsTakes(postID: "p1", defaults: defaults))

        defaults.set(PostMode.takes.rawValue, forKey: "postMode.p1")
        #expect(ReadTakesView.holdsTakes(postID: "p1", defaults: defaults))

        for other in [PostMode.write, .lenses, .compare, .blocks, .canvas] {
            defaults.set(other.rawValue, forKey: "postMode.p1")
            #expect(!ReadTakesView.holdsTakes(postID: "p1", defaults: defaults),
                    "\(other.rawValue) keeps read prose — deliberately not built")
        }
    }
}
