import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U4 — **the starred-notes gathering** (the sitting record §3; P-13ib-4).
/// An ORDINARY gathering on `★`, seeded once per store by a silent ensure that
/// honours her deletion — the seeded books' discipline, and the Quicknotes
/// shape §20 ratified (no special identity, no delete guard). New surface: these
/// pins are its specification (no prior behaviour to be red against).
@Suite("13i-b U4 — the starred-notes gathering (P-13ib-4)")
struct StarredNotesGatheringTests {
    private func mintedID(_ outcome: Operations.StarredGatheringEnsure) -> String? {
        if case .minted(let id) = outcome { return id }
        return nil
    }

    @Test func aFreshStoreGetsAnOrdinaryUnshelvedGatheringOnTheStar() throws {
        try withOperations { ops, db in
            guard let id = mintedID(ops.ensureStarredNotesGathering()) else {
                Issue.record("expected .minted on a fresh store")
                return
            }
            let row = try #require(try db.read { try Reading.fetchOne($0, key: id) })
            #expect(row.name == Operations.starredNotesGatheringName)
            #expect(row.name == "starred notes")
            #expect(row.kind == .gathering)
            #expect(row.querySpec == #"{"star":true}"#)
            #expect(RuleGrammar.read(row.querySpec) == .rule(.star))
            // §19.3: a working object starts UNSHELVED; nothing special about it.
            #expect(row.shelfId == nil)
            #expect(row.shelfPosition == nil)
            #expect(row.starred == false)
            #expect(row.wingId == "")
            #expect(row.locked == false)
            #expect(row.owned == false)
            #expect(row.autoTagId == nil)
            #expect(row.autoTagIDs == [])
            #expect(row.intakeSeating == nil)
            // A gathering holds nothing.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?", [id]) == 0)
        }
    }

    @Test func starringANoteShowsItAndUnstarringLetsItGoAtOnce() throws {
        try withOperations { ops, db in
            let id = try #require(mintedID(ops.ensureStarredNotesGathering()))
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            func shown() throws -> [String] {
                try db.read { try Queries.assembleReading($0, readingID: id).map(\.postID) }
            }
            #expect(try shown().isEmpty)
            try ops.setStarred(.post(a.id), starred: true)
            try ops.setStarred(.post(b.id), starred: true)
            // Newest first — Quicknotes' own order.
            #expect(try shown() == [b.id, a.id])
            try ops.setStarred(.post(a.id), starred: false)
            #expect(try shown() == [b.id])
            // Derived: no row was written for any of it.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?", [id]) == 0)
        }
    }

    @Test func anExistingStoreGetsItTooAndNothingElseMoves() throws {
        try withOperations { ops, db in
            // A store with her writing in it: notes, a tag, a book, members.
            let tag = try ops.createTag(name: "work")
            let book = try ops.createReading(name: "my book", kind: .book)
            let note = try ops.importPost(title: "n", text: "words").container
            _ = try ops.applyTag(tag.id, toPost: note.id)
            try ops.addPostToReading(note.id, to: book.id)
            try ops.setStarred(.post(note.id), starred: true)
            let before = try db.read { db in
                (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post") ?? -1,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM post_tag") ?? -1,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container") ?? -1)
            }
            let id = try #require(mintedID(ops.ensureStarredNotesGathering()))
            let after = try db.read { db in
                (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post") ?? -1,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM post_tag") ?? -1,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container") ?? -1)
            }
            #expect(before == after)
            // Her already-starred note shows from the first read.
            #expect(try db.read {
                try Queries.assembleReading($0, readingID: id).map(\.postID)
            } == [note.id])
        }
    }

    @Test func theEnsureIsIdempotent() throws {
        try withOperations { ops, db in
            let id = try #require(mintedID(ops.ensureStarredNotesGathering()))
            #expect(ops.ensureStarredNotesGathering() == .alreadyPresent(readingID: id))
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 1)
        }
    }

    /// The seeded-books rule: her deletion is her word. No delete guard —
    /// the ordinary door deletes it — and the ensure never puts it back,
    /// whatever she had renamed it to first.
    @Test func aDeletedOneStaysDeletedEvenRenamed() throws {
        try withOperations { ops, db in
            let id = try #require(mintedID(ops.ensureStarredNotesGathering()))
            try ops.renameReading(id, name: "my favourites")
            try ops.deleteReading(id)
            #expect(ops.ensureStarredNotesGathering() == .deletedByTheReader)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 0)
            // An ordinary Trash object: restoring it is the ordinary door.
            try ops.restoreReading(id)
            #expect(ops.ensureStarredNotesGathering() == .alreadyPresent(readingID: id))
        }
    }

    @Test func aDeletedOneByNameStaysDeletedToo() throws {
        try withOperations { ops, db in
            // A tombstone of the reserved NAME alone (its rule since edited) is
            // the readingTombstoneExists class — her deletion of the thing.
            let id = try #require(mintedID(ops.ensureStarredNotesGathering()))
            let tag = try ops.createTag(name: "x")
            try ops.setReadingQuerySpec(id, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            try ops.deleteReading(id)
            #expect(ops.ensureStarredNotesGathering() == .deletedByTheReader)
            _ = db
        }
    }

    /// Hers counts: a ★ gathering she made by hand, renamed, or BOUND into a
    /// book (the bind keeps the row) is the thing — never a twin beside it.
    @Test func herOwnStarGatheringOrItsBoundBookCountsAsPresent() throws {
        try withOperations { ops, db in
            let hers = try ops.createReading(
                name: "the good ones", kind: .gathering,
                querySpec: try RuleGrammar.encode(.star))
            #expect(ops.ensureStarredNotesGathering() == .alreadyPresent(readingID: hers.id))
            try ops.convertSmartReadingToCurated(hers.id)
            #expect(ops.ensureStarredNotesGathering() == .alreadyPresent(readingID: hers.id))
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 1)
        }
    }

    @Test func theReservedNameInUseIsNeverTwinned() throws {
        try withOperations { ops, db in
            // E13's sense: a live book already wearing the name (any case) —
            // the seed never mints a second same-named row.
            let hers = try ops.createReading(name: "Starred Notes", kind: .book)
            #expect(ops.ensureStarredNotesGathering() == .alreadyPresent(readingID: hers.id))
            _ = db
        }
    }

    @Test func onlyHomeCounts() throws {
        try withOperations { ops, db in
            // A ★ gathering in ANOTHER wing is that library's — Home still
            // gets its own.
            _ = try ops.createReading(
                name: "starred notes", kind: .gathering,
                querySpec: try RuleGrammar.encode(.star), wingId: "other-wing")
            let id = try #require(mintedID(ops.ensureStarredNotesGathering()))
            #expect(try db.read { try Reading.fetchOne($0, key: id)?.wingId } == "")
        }
    }
}
