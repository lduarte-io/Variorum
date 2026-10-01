import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U1 — AN ARRIVAL IS NEVER A MEMBER TO THE MEMBERSHIP DOORS.
///
/// The 13i-a schema note binds it ("an ARRIVAL … NEVER counted/listed/worded
/// as membership"), and 13i-a filtered every member-READER (assembly, the
/// shelf counts, the chip, the Pool). The membership OPERATIONS were left
/// asking the old any-status question (`liveMembership`), which no local op
/// could stage before U1 — intake is what makes an arrival row real. So,
/// pinned by a direct arrival row, RED on the pre-U1 tree:
///
/// - remove / reorder / assign-to-chapter / diverge treat a waiting note as
///   NOT IN the book (`postNotInReading`) and leave the arrival untouched —
///   its own doors are seat and dismiss;
/// - a HAND-ADD of a waiting note is her judgment "add it": it SEATS that
///   arrival row (same id, status → member, at the place she asked) instead
///   of refusing "already in this book" — a sentence that would be false
///   (PROVISIONAL P-13ib-U1-2, the record);
/// - and the capacity gate still governs that hand-add.
@Suite("13i-b U1 — arrivals are not members to the membership doors")
struct ArrivalMemberHygieneTests {
    /// A book with one seated member, plus a second note WAITING at its door
    /// (an arrival row written directly — the shape intake mints).
    private func arrivalFixture(
        _ ops: Operations, _ db: AppDatabase, maxPosts: Int? = nil
    ) throws -> (book: Reading, member: Container, waiting: Container, arrivalID: String) {
        let book = try ops.createReading(name: "living", kind: .book, maxPosts: maxPosts)
        let member = try ops.createPost(title: "member")
        try ops.addPostToReading(member.id, to: book.id)
        let waiting = try ops.createPost(title: "waiting")
        try db.write { db in
            let last = try String.fetchOne(
                db, sql: "SELECT MAX(position) FROM reading_post WHERE reading_id = ?",
                arguments: [book.id])
            try db.execute(
                sql: """
                    INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                    VALUES ('arrival-1', ?, ?, ?, 'arrival', '2026-07-01T00:00:00.000Z')
                    """,
                arguments: [book.id, waiting.id, FractionalIndex.between(last, nil)])
        }
        return (book, member, waiting, "arrival-1")
    }

    private func row(_ db: AppDatabase, _ id: String) throws -> ReadingPost? {
        try db.read { try ReadingPost.fetchOne($0, key: id) }
    }

    @Test func removeRefusesAWaitingNoteAndLeavesItsArrivalStanding() throws {
        try withOperations { ops, db in
            let f = try arrivalFixture(ops, db)
            #expect(throws: OperationError.postNotInReading(
                postID: f.waiting.id, readingID: f.book.id)) {
                try ops.removePostFromReading(f.waiting.id, from: f.book.id)
            }
            let arrival = try #require(try row(db, f.arrivalID))
            #expect(arrival.deletedAt == nil)
            #expect(arrival.status == .arrival)
        }
    }

    @Test func reorderRefusesAWaitingNote() throws {
        try withOperations { ops, db in
            let f = try arrivalFixture(ops, db)
            let before = try #require(try row(db, f.arrivalID)).position
            #expect(throws: OperationError.postNotInReading(
                postID: f.waiting.id, readingID: f.book.id)) {
                try ops.reorderReadingPost(f.waiting.id, in: f.book.id, to: .start)
            }
            #expect(try row(db, f.arrivalID)?.position == before)
        }
    }

    @Test func assigningAWaitingNoteToAChapterRefuses() throws {
        try withOperations { ops, db in
            let f = try arrivalFixture(ops, db)
            let chapter = try ops.createSection(in: f.book.id, name: "one")
            #expect(throws: OperationError.postNotInReading(
                postID: f.waiting.id, readingID: f.book.id)) {
                try ops.assignPostToSection(f.waiting.id, in: f.book.id, section: chapter.id)
            }
            #expect(try row(db, f.arrivalID)?.sectionId == nil)
        }
    }

    @Test func divergingAWaitingNoteRefuses() throws {
        try withOperations { ops, db in
            let f = try arrivalFixture(ops, db)
            // Prose to copy, so the only thing that can refuse is the
            // membership question itself (the pre-U1 tree diverged the
            // ARRIVAL: tombstoned it and seated a copy as a member).
            try ops.seedBlock(in: f.waiting.id, text: "waiting at the door")
            #expect(throws: OperationError.postNotInReading(
                postID: f.waiting.id, readingID: f.book.id)) {
                try ops.divergePostForReading(f.waiting.id, in: f.book.id)
            }
            #expect(try row(db, f.arrivalID)?.deletedAt == nil)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                [f.book.id]) == 2)
        }
    }

    @Test func aHandAddOfAWaitingNoteSeatsItsArrivalRow() throws {
        try withOperations { ops, db in
            let f = try arrivalFixture(ops, db)
            let seated = try ops.addPostToReading(f.waiting.id, to: f.book.id, at: .start)
            // The SAME row, promoted — never a second row beside the bell.
            #expect(seated.id == f.arrivalID)
            let arrival = try #require(try row(db, f.arrivalID))
            #expect(arrival.status == .member)
            #expect(arrival.deletedAt == nil)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ?",
                [f.book.id, f.waiting.id]) == 1)
            // …at the place she asked for (a hand-add honours `at:`).
            let order = try db.read {
                try Queries.assembleReading($0, readingID: f.book.id).map(\.postID)
            }
            #expect(order == [f.waiting.id, f.member.id])
        }
    }

    @Test func aHandAddOfAWaitingNoteAtCapacityRefusesAndTheBellKeepsRinging() throws {
        try withOperations { ops, db in
            let f = try arrivalFixture(ops, db, maxPosts: 1)
            #expect(throws: OperationError.readingAtCapacity(id: f.book.id)) {
                try ops.addPostToReading(f.waiting.id, to: f.book.id)
            }
            let arrival = try #require(try row(db, f.arrivalID))
            #expect(arrival.status == .arrival)
            #expect(arrival.deletedAt == nil)
        }
    }
}
