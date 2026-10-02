import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U5 — F-U5-2's MEMBERSHIP and DAILY halves.
///
/// - **A book never spans wings** (the sitting record §9; the identity
///   brief's "books never span libraries"): every membership-creating road
///   refuses a note of another wing (`crossWingMembership`). RED on the
///   pre-fix ops — `addPostToReading`, copy in, move in and the arrival seat
///   carried no wing check.
/// - **THE DAILY JOURNAL IS HOME-ONLY** (#169(b), RULED; KnownIssues row 105):
///   the designation refuses another wing's book; ⌘J / Today's Entry open or
///   create the day's entry IN HOME whichever wing they are pressed in. Row
///   105's MECHANISM, traced: ⌘J mints the entry in Home
///   (`createOrOpenJournalEntry` → `insertPost`'s default) and shelves it into
///   the DESIGNATED book; designating a book of another wing therefore made
///   every day's entry a membership across libraries. RED on the pre-fix ops.
@Suite("13i-d U5 — a book never spans wings; the daily Journal is Home-only")
struct WingMembershipAndJournalTests {
    private func membershipCount(_ db: AppDatabase, _ postID: String, _ readingID: String) throws
        -> Int
    {
        try db.fetchInt(
            "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND reading_id = ? AND deleted_at IS NULL",
            [postID, readingID]) ?? 0
    }

    @Test func aNoteOfAnotherWingCannotJoinAHomeBook() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let away = try ops.createPost(title: "away", wingId: wing.id)
            let book = try ops.createReading(name: "home book", kind: .book)
            #expect(throws: OperationError.crossWingMembership(postID: away.id, readingID: book.id)) {
                try ops.addPostToReading(away.id, to: book.id)
            }
            #expect(try membershipCount(db, away.id, book.id) == 0)
            // …and the mirror: a Home note into a book of the other wing.
            let home = try ops.createPost(title: "home")
            let wingBook = try ops.createReading(name: "wing book", kind: .book, wingId: wing.id)
            #expect(throws: OperationError.crossWingMembership(postID: home.id, readingID: wingBook.id)) {
                try ops.addPostToReading(home.id, to: wingBook.id)
            }
            // Same-wing adds stand (controls).
            _ = try ops.addPostToReading(away.id, to: wingBook.id)
            _ = try ops.addPostToReading(home.id, to: book.id)
        }
    }

    @Test func copyInAndMoveInRefuseAcrossWings() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let away = try ops.createPost(title: "away", wingId: wing.id)
            _ = try ops.newBlock(in: away.id, text: "words", at: .end)
            let owned = try ops.createReading(name: "owned", kind: .book)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            #expect(throws: OperationError.crossWingMembership(postID: away.id, readingID: owned.id)) {
                try ops.copyPostIntoReading(away.id, into: owned.id)
            }
            #expect(throws: OperationError.crossWingMembership(postID: away.id, readingID: owned.id)) {
                try ops.movePostIntoReading(away.id, into: owned.id)
            }
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                [owned.id]) == 0)
        }
    }

    /// An arrival across wings cannot be minted by intake (it is wing-scoped),
    /// but a synced or hand-written one must still never seat.
    @Test func aCrossWingArrivalNeverSeats() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let away = try ops.createPost(title: "away", wingId: wing.id)
            let book = try ops.createReading(name: "home book", kind: .book)
            let rowID = UUID().uuidString
            try db.write {
                try $0.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES (?, ?, ?, ?, 'arrival', '2026-07-01T00:00:00.000Z')
                        """,
                    arguments: [rowID, book.id, away.id, FractionalIndex.initial()])
            }
            #expect(throws: OperationError.crossWingMembership(postID: away.id, readingID: book.id)) {
                try ops.seatArrival(rowID)
            }
            #expect(try db.fetchString("SELECT status FROM reading_post WHERE id = ?", [rowID])
                    == "arrival")
        }
    }

    /// ROW 105 — the designation refuses a book of another wing, so the
    /// daily door can never shelve Home's entry across libraries.
    @Test func theDailyJournalCannotBeDesignatedOutsideHome() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let away = try ops.createReading(
                name: "away journal", kind: .book, profile: Queries.journalTraitProfile,
                wingId: wing.id)
            #expect(throws: OperationError.dailyJournalIsHomeOnly(id: away.id)) {
                try ops.setDailyJournalBook(away.id)
            }
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == nil)
            #expect(try db.read { try Queries.reading($0, id: away.id) }?.profile
                    == Queries.journalTraitProfile, "the refused book keeps its trait")
            // ⌘J's composite now mints the Journal in Home and files there —
            // never a membership in the other wing's book.
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01")
            let shelving = ops.shelveInDailyJournalBook(entry.container.id)
            guard case .shelved(let journalID) = shelving else {
                Issue.record("expected the entry shelved into a Home Journal, got \(shelving)")
                return
            }
            #expect(try db.read { try Queries.reading($0, id: journalID) }?.wingId == "")
            #expect(try membershipCount(db, entry.container.id, away.id) == 0)
            // A Home book designates as before (control).
            let home = try ops.createReading(name: "home journal", kind: .book)
            try ops.setDailyJournalBook(home.id)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == home.id)
        }
    }

    /// ⌘J from any wing opens or creates the day's entry IN HOME: a
    /// daily-shaped entry that lives in another wing (moved there) is that
    /// library's, never the day's entry for the daily door.
    @Test func todaysEntryIsHomesWhicheverWingHoldsADailyShape() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let elsewhere = try ops.createPost(
                profile: .journal, entryDate: "2026-07-01", wingId: wing.id)
            let opened = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01")
            #expect(opened.created, "the other wing's daily shape is not Home's day")
            #expect(opened.container.id != elsewhere.id)
            #expect(opened.container.wingId == "")
            // …and the next press opens THAT Home entry (one per day).
            let again = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01")
            #expect(again.created == false && again.container.id == opened.container.id)
        }
    }
}
