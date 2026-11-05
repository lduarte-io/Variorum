import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-436 — R-805-2, THE JOURNAL'S PUT BACK (her kickoff ruling, 2026-11-05:
// "the restoree demotes to the trait — the restored book returns whole but as
// an ordinary 'journal'-trait book; the standing Journal keeps ⌘J and the
// 'daily' marker. A restore with NO standing daily book is untouched: the old
// book simply returns as THE Journal"). Exact state transitions both ways, the
// deleted-Journal mark normalized either way (a live row never wears it), and
// the older-build tombstone (a dead row still wearing 'daily') held to the
// same rule. Red on old: `restoreReadingRows` revived the row with its
// profile untouched — a 'daily_deleted' restoree came back wearing the mark,
// and a 'daily' one beside a standing Journal made TWO live marker-bearers
// (the keeper's race shape, by her own hand).

private func filed(_ ops: Operations, day: String) throws -> (bookID: String, entryID: String) {
    let entry = try ops.createOrOpenJournalEntry(entryDate: day)
    guard case .shelved(let bookID) = ops.shelveInDailyJournalBook(entry.container.id) else {
        throw PutBackFixtureError.didNotShelve
    }
    return (bookID, entry.container.id)
}

private enum PutBackFixtureError: Error { case didNotShelve }

private func profile(_ db: AppDatabase, _ id: String) throws -> String? {
    try db.fetchString("SELECT profile FROM reading WHERE id = ?", [id])
}

private func cachedDesignation(_ db: AppDatabase) throws -> String? {
    try db.fetchString("SELECT value FROM setting WHERE key = 'daily_journal_book'")
}

private func liveMember(_ db: AppDatabase, _ postID: String, of readingID: String) throws -> Bool {
    try db.fetchInt(
        """
        SELECT COUNT(*) FROM reading_post
        WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL AND status = 'member'
        """, [readingID, postID]) == 1
}

@Suite("VX-436 — R-805-2: a Put back of the daily Journal (demote beside a standing one, else THE Journal)")
struct JournalPutBackTests {
    /// Beside a STANDING Journal the restoree comes back WHOLE (its entries'
    /// memberships on the exact stamp) as a journal-TRAIT book; the standing
    /// one keeps the marker, the designation and its own entries. The row
    /// write is exact: only profile, deleted_at and updated_at moved on the
    /// restoree; the standing Journal's row is byte-unchanged.
    @Test func aPutBackBesideAStandingJournalDemotesToTheTrait() throws {
        try withOperations { ops, db in
            let old = try filed(ops, day: "2026-10-01")
            let before = try #require(try db.snapshotRow(
                "reading", old.bookID, excluding: ["updated_at", "profile", "deleted_at"]))
            try ops.deleteReading(old.bookID)
            #expect(try profile(db, old.bookID) == Queries.dailyJournalDeletedProfile)
            let fresh = try filed(ops, day: "2026-10-02")
            #expect(fresh.bookID != old.bookID)
            let standing = try #require(try db.snapshotRow("reading", fresh.bookID, excluding: []))
            try db.clearOutbox()

            try ops.restoreReading(old.bookID)

            #expect(try db.deletedAt("reading", old.bookID) == nil)
            #expect(try profile(db, old.bookID) == Queries.journalTraitProfile, "demoted to the trait")
            #expect(try db.snapshotRow(
                "reading", old.bookID, excluding: ["updated_at", "profile", "deleted_at"]) == before)
            #expect(try liveMember(db, old.entryID, of: old.bookID), "returned whole")
            #expect(try db.snapshotRow("reading", fresh.bookID, excluding: []) == standing,
                    "the standing Journal is untouched")
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == fresh.bookID)
            #expect(try cachedDesignation(db) == fresh.bookID)
            #expect(try db.read { try Queries.dailyJournalBookCandidates($0) } == [fresh.bookID],
                    "ONE live marker-bearer")
            #expect(try db.outboxContains("reading", old.bookID))
            #expect(try !db.outboxContains("reading", fresh.bookID))
            #expect(try !db.outboxContains("setting", "daily_journal_book"), "the cache is not rewritten")
        }
    }

    /// With NO standing Journal the restoree returns as THE Journal — the
    /// mark normalized to the marker, the designation cache refreshed to it,
    /// its entries back; the next ⌘J files into it.
    @Test func aPutBackWithNoStandingJournalReturnsAsTheJournal() throws {
        try withOperations { ops, db in
            let old = try filed(ops, day: "2026-10-01")
            try ops.deleteReading(old.bookID)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == nil)
            try db.clearOutbox()

            try ops.restoreReading(old.bookID)

            #expect(try profile(db, old.bookID) == Queries.dailyJournalBookProfile)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == old.bookID)
            #expect(try cachedDesignation(db) == old.bookID)
            #expect(try liveMember(db, old.entryID, of: old.bookID))
            #expect(try db.outboxContains("reading", old.bookID))
            #expect(try db.outboxContains("setting", "daily_journal_book"))
            let next = try filed(ops, day: "2026-10-02")
            #expect(next.bookID == old.bookID, "⌘J files into the returned Journal")
        }
    }

    /// The same rule holds a dead row still wearing 'daily' — an older
    /// build's delete, or a keeper retirement put back by hand: beside a
    /// standing Journal it demotes; alone it returns as THE Journal.
    @Test func aDailyTombstoneFromAnOlderBuildIsHeldToTheSameRule() throws {
        try withOperations { ops, db in
            let stamp = DateFormatter.variorumISO8601.string(from: harnessNow)
            let elder = try ops.createReading(name: "journal", kind: .book, profile: "daily")
            try db.write {
                try $0.execute(
                    sql: "UPDATE reading SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: [stamp, stamp, elder.id])
            }
            let standing = try filed(ops, day: "2026-10-02")
            try ops.restoreReading(elder.id)
            #expect(try profile(db, elder.id) == Queries.journalTraitProfile)
            #expect(try db.read { try Queries.dailyJournalBookCandidates($0) } == [standing.bookID])

            // Alone: it returns as THE Journal.
            let lone = try ops.createReading(name: "days", kind: .book, profile: "daily")
            try ops.setDailyJournalBook(lone.id)     // demotes the standing one
            try db.write {
                try $0.execute(
                    sql: "UPDATE reading SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: [stamp, stamp, lone.id])
            }
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == nil)
            try ops.restoreReading(lone.id)
            #expect(try profile(db, lone.id) == Queries.dailyJournalBookProfile)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == lone.id)
        }
    }

    /// Nothing else is touched: a deleted journal-TRAIT book and a plain book
    /// come back wearing exactly what they wore.
    @Test func otherBooksPutBackByteForByte() throws {
        try withOperations { ops, db in
            _ = try filed(ops, day: "2026-10-01")
            let trait = try ops.createReading(
                name: "dreams", kind: .book, profile: Queries.journalTraitProfile)
            let plain = try ops.createReading(name: "novel", kind: .book)
            try ops.deleteReading(trait.id)
            try ops.deleteReading(plain.id)
            try ops.restoreReading(trait.id)
            try ops.restoreReading(plain.id)
            #expect(try profile(db, trait.id) == Queries.journalTraitProfile)
            #expect(try profile(db, plain.id) == nil)
        }
    }
}
