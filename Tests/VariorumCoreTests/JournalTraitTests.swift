import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// 13i-a — the journal-trait setter (sitting record §10's ruling: the trait
// is a per-book settings row; the op lands here, the Collecting-pane face
// is 13i-e's) and the 'daily' marker's constitutive refusal (PROVISIONAL,
// the 13i-a plan §9).
@Suite("The journal trait setter (13i-a — sitting record §10)")
struct JournalTraitTests {
    /// Ladder R1 MIN-3 + R2's MINOR, pinned whole with a RAW arrival row
    /// (no door mints one until 13i-b; the repairs can): an ARRIVAL is not
    /// a member anywhere a member is counted, listed, worded or excluded —
    /// the capacity gate, the shelf's postCount, the Pool's bookless
    /// exclusion, the book's word count, its shelf tags, and the note's
    /// membership chip (whether the chip should say "arriving" instead is
    /// 13i-b's named design line).
    @Test func anArrivalIsNotAMemberAnywhereAMemberIsCounted() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "the book", kind: .book, maxPosts: 1)
            let waiting = try ops.createPost(title: "waiting at the door")
            _ = try ops.newBlock(in: waiting.id, text: "Three words here.", at: .end)
            let tag = try ops.createTag(name: "ringing")
            _ = try ops.applyTag(tag.id, toPost: waiting.id)
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('AR000000-0000-4000-8000-00000000BELL', ?, ?, 'a1', 'arrival', ?)
                        """,
                    arguments: [book.id, waiting.id, "2026-10-01T00:00:00.000Z"])
            }
            // The capacity gate counts members only — the arrival does not
            // fill the one-post cap.
            let seated = try ops.createPost(title: "seated")
            #expect(throws: Never.self) {
                _ = try ops.addPostToReading(seated.id, to: book.id)
            }
            // The shelf's count says 1 (the member), not 2.
            let shelf = try db.read { try Queries.bookshelf($0) }
            #expect(shelf.first { $0.reading.id == book.id }?.postCount == 1)
            // The Pool still lists the waiting note — an arrival is not a home.
            let pool = try db.read { try Queries.poolPosts($0, limit: 50) }
            #expect(pool.map(\.postID).contains(waiting.id),
                    "a note whose only row is an arrival is bookless")
            // The book's word count never counts the waiting note's words.
            let words = try db.read { try Queries.bookWordCounts($0) }
            #expect(words[book.id] == 0)
            // The book's shelf tags never surface the arrival's tags.
            let tags = try db.read { try Queries.shelfBookTags($0) }
            #expect(tags[book.id] == nil)
            // The note's membership chip does not claim the book.
            let chip = try db.read { try Queries.readingsContaining($0, postID: waiting.id) }
            #expect(!chip.map(\.id).contains(book.id),
                    "the chip and the Pool must agree: not a member")
        }
    }

    @Test func theTraitFlipsBetweenJournalAndBook() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "field notes", kind: .book)
            try ops.setJournalTrait(book.id, on: true)
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.profile == "journal")
            try ops.setJournalTrait(book.id, on: false)
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.profile == "book")
        }
    }

    @Test func theDailyBookRefusesTheToggleItsMarkerIsConstitutive() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-09-30")
            guard case .shelved(let dailyID) = ops.shelveInDailyJournalBook(entry.container.id)
            else { Issue.record("the daily mint did not shelve"); return }
            #expect(throws: OperationError.dailyJournalTraitIsConstitutive(id: dailyID)) {
                try ops.setJournalTrait(dailyID, on: false)
            }
            #expect(throws: OperationError.dailyJournalTraitIsConstitutive(id: dailyID)) {
                try ops.setJournalTrait(dailyID, on: true)
            }
            #expect(try db.read { try Queries.reading($0, id: dailyID) }?.profile == "daily",
                    "the marker never moves")
        }
    }

    @Test func aFinishedBookRefusesAndANoOpWritesNothing() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "done", kind: .book, profile: "journal")
            try ops.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.setJournalTrait(book.id, on: false)
            }
            try ops.unlockReading(book.id)
            try db.clearOutbox()
            try ops.setJournalTrait(book.id, on: true)  // already the trait
            #expect(try db.outboxContains("reading", book.id) == false,
                    "a no-op writes nothing — the identity-metadata convention")
        }
    }
}
