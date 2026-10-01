import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Step A1 — migration v1_11 `reading.word_target` (bounded-length
/// notebooks in words, §14 item 10) + the first `max_posts` setter (the
/// column shipped v1 with no face at all).
@Suite("Reading extents (Phase 13, A1 — v1_11)")
struct ReadingExtentTests {
    @Test func columnExistsNullableOnReading() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let column = try Row.fetchAll(db, sql: "PRAGMA table_info(reading)")
                .first { $0["name"] == "word_target" }
            #expect(column != nil)
            #expect(column?["notnull"] == 0)
        }
    }

    @Test func setUpdateClearWordTargetAndBirthValue() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(
                name: "dream-journal", kind: .book, wordTarget: 10_000)
            #expect(try db.fetchInt(
                "SELECT word_target FROM reading WHERE id = ?", [book.id]) == 10_000)

            // Extend at the boundary ("extend or start a new notebook").
            try ops.setReadingWordTarget(book.id, wordTarget: 20_000)
            #expect(try db.fetchInt(
                "SELECT word_target FROM reading WHERE id = ?", [book.id]) == 20_000)

            try ops.setReadingWordTarget(book.id, wordTarget: nil)
            #expect(try db.fetchInt(
                "SELECT word_target FROM reading WHERE id = ?", [book.id]) == nil)
        }
    }

    @Test func nonPositiveExtentsRefuseAndLockedReadingsFreeze() throws {
        try withOperations { ops, _ in
            let book = try ops.createReading(name: "orbit", kind: .book)
            #expect(throws: OperationError.invalidExtent(value: 0)) {
                try ops.setReadingWordTarget(book.id, wordTarget: 0)
            }
            #expect(throws: OperationError.invalidExtent(value: -5)) {
                try ops.setReadingMaxPosts(book.id, maxPosts: -5)
            }
            try ops.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.setReadingWordTarget(book.id, wordTarget: 5_000)
            }
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.setReadingMaxPosts(book.id, maxPosts: 30)
            }
        }
    }

    @Test func assertReadingAcceptsPostsMirrorsTheAddGateExactly() throws {
        // Phase 13 round 3: the refuse-BEFORE-mint gate — every refusal
        // `addPostToReading` would throw for a fresh post, thrown without
        // a post: missing reading, wrong kind, locked, at capacity; a
        // willing book passes.
        try withOperations { ops, _ in
            let book = try ops.createReading(name: "orbit", kind: .book, maxPosts: 1)
            try ops.assertReadingAcceptsPosts(book.id)  // willing: no throw

            #expect(throws: OperationError.self) {
                try ops.assertReadingAcceptsPosts("no-such-reading")
            }
            let smart = try ops.createReading(name: "auto", kind: .gathering)
            #expect(throws: OperationError.wrongReadingKind(id: smart.id, expected: .book)) {
                try ops.assertReadingAcceptsPosts(smart.id)
            }
            let filler = try ops.createPost(title: "f", profile: .generic)
            _ = try ops.addPostToReading(filler.id, to: book.id)
            #expect(throws: OperationError.readingAtCapacity(id: book.id)) {
                try ops.assertReadingAcceptsPosts(book.id)
            }
            try ops.setReadingMaxPosts(book.id, maxPosts: nil)
            try ops.assertReadingAcceptsPosts(book.id)  // cap cleared: willing
            try ops.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.assertReadingAcceptsPosts(book.id)
            }
        }
    }

    @Test func wordTargetIsATargetNeverAnAddTimeRefusal() throws {
        try withOperations { ops, _ in
            // A tiny word target, then far more words than it names — every
            // add succeeds: the target is progress display, not a gate
            // (edits change word counts; membership can't enforce them).
            let book = try ops.createReading(
                name: "bounded", kind: .book, wordTarget: 5)
            for index in 0..<3 {
                let post = try ops.createPost(title: "post \(index)", profile: .generic)
                _ = try ops.newBlock(
                    in: post.id,
                    text: "Far more than five words in this single block of prose.",
                    at: .end)
                _ = try ops.addPostToReading(post.id, to: book.id)
            }
        }
    }

    @Test func maxPostsSetterFeedsTheStandingCapacityGate() throws {
        try withOperations { ops, _ in
            let book = try ops.createReading(name: "letters", kind: .book)
            let first = try ops.createPost(title: "one", profile: .generic)
            let second = try ops.createPost(title: "two", profile: .generic)
            _ = try ops.addPostToReading(first.id, to: book.id)

            // Lowering the cap below current membership is legal; the
            // standing gate refuses FURTHER adds.
            try ops.setReadingMaxPosts(book.id, maxPosts: 1)
            #expect(throws: OperationError.readingAtCapacity(id: book.id)) {
                _ = try ops.addPostToReading(second.id, to: book.id)
            }
            // Raising it re-opens the door.
            try ops.setReadingMaxPosts(book.id, maxPosts: 2)
            _ = try ops.addPostToReading(second.id, to: book.id)
        }
    }
}
