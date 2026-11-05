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
/// - **THE DAILY JOURNAL LIVES IN ANY WING** (VX-435 — the VX-805 run;
///   #169(b)'s Home-only rule, KnownIssues row 105's fix, RETIRED by her
///   2026-11-04 ruling): the designation takes a book of any wing, and ⌘J /
///   Today's Entry open or create the day's entry BESIDE the Journal — in its
///   wing — so the filing never crosses libraries (row 105's mechanism stays
///   closed by the other road). With no Journal living, the entry is born in
///   the wing the author stands in (Home for every caller that names none).
@Suite("13i-d U5 — a book never spans wings; the daily Journal's entries live beside it")
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

    /// ROW 105's class, by the other road (VX-435 — a JUSTIFIED EDIT: the
    /// pin `theDailyJournalCannotBeDesignatedOutsideHome` encoded #169(b)'s
    /// Home-only refusal, which her ruling retired): a book of another wing
    /// DESIGNATES, and the daily door then opens and files the day's entry IN
    /// THAT WING — never a membership across libraries.
    @Test func theDailyJournalDesignatesInAnyWingAndFilesBesideItself() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let away = try ops.createReading(
                name: "away journal", kind: .book, profile: Queries.journalTraitProfile,
                wingId: wing.id)
            try ops.setDailyJournalBook(away.id)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == away.id)
            #expect(try db.read { try Queries.reading($0, id: away.id) }?.profile
                    == Queries.dailyJournalBookProfile, "the designee wears the marker")
            // ⌘J's composite, pressed from Home: the entry is born in the
            // Journal's wing and files there.
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01")
            #expect(entry.created && entry.container.wingId == wing.id,
                    "the day's entry lives beside its Journal")
            #expect(ops.shelveInDailyJournalBook(entry.container.id) == .shelved(readingID: away.id))
            #expect(try membershipCount(db, entry.container.id, away.id) == 1)
            // A Home book designates as before (control) — and the next day's
            // entry follows the marker home.
            let home = try ops.createReading(name: "home journal", kind: .book)
            try ops.setDailyJournalBook(home.id)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == home.id)
            let next = try ops.createOrOpenJournalEntry(entryDate: "2026-07-02")
            #expect(next.container.wingId == "")
        }
    }

    /// With NO Journal living, the daily door pressed from Home opens or
    /// creates the day's entry IN HOME: a daily-shaped entry that lives in
    /// another wing (moved there) is that library's, never Home's day (VX-435
    /// keeps this edge — the lookup reads the wing the entry would be born
    /// in).
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
