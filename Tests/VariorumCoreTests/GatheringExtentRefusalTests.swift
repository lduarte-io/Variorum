import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U4 ACT 0 — **THE (c) ARM** (F-U3-1, RULED at the architect's
/// adjudication after U3 — the sitting record §3's letter: *a gathering has NO
/// finish, word target or capacity*). The operations themselves now refuse
/// what the faces stopped offering at U1/U3:
///
/// - `lockReading` on a gathering refuses `wrongReadingKind(expected: .book)`;
/// - a NON-NIL `setReadingWordTarget` / `setReadingMaxPosts` on a gathering
///   refuses the same way (before the finished guard and the positivity
///   check — Reopen would not help, a gathering has no extent at all);
/// - CLEARING an extent (nil) and `unlockReading` stay LEGAL — the pre-13i-d
///   escape, so a legacy gathering finished or capped before this phase (or
///   arriving so from another device) always keeps its way out (the faces'
///   legacy doors, P-13id-U3-3, stand on exactly these).
///
/// Exact state transitions: a refusal leaves the reading row byte-identical
/// and writes no outbox row. The three refusals are RED on the shipped ops
/// (which acted on a gathering); the ways-out and the book controls are green
/// on both sides by design.
@Suite("13i-d U4 ACT 0 — a gathering has no finish, word target or capacity")
struct GatheringExtentRefusalTests {
    private func gathering(_ ops: Operations, name: String = "g") throws -> Reading {
        let tag = try ops.createTag(name: "\(name)-tag")
        return try ops.createReading(
            name: name, kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
    }

    /// The LEGACY state, written raw — exactly how a finished/capped gathering
    /// exists now that the ops refuse it: a pre-13i-d store, or another
    /// device's synced row.
    private func makeLegacy(
        _ db: AppDatabase, _ id: String, locked: Bool, wordTarget: Int?, maxPosts: Int?
    ) throws {
        try db.write { db in
            try db.execute(
                sql: "UPDATE reading SET locked = ?, word_target = ?, max_posts = ? WHERE id = ?",
                arguments: [locked ? 1 : 0, wordTarget, maxPosts, id])
        }
    }

    @Test func finishingAGatheringRefusesAndWritesNothing() throws {
        try withOperations { ops, db in
            let g = try gathering(ops)
            let before = try db.snapshotRow("reading", g.id, excluding: [])
            try db.clearOutbox()
            #expect(throws: OperationError.wrongReadingKind(id: g.id, expected: .book)) {
                try ops.lockReading(g.id)
            }
            #expect(try db.snapshotRow("reading", g.id, excluding: []) == before,
                    "the refusal left the row byte-identical — not finished")
            #expect(try db.outboxContains("reading", g.id) == false)
        }
    }

    @Test func aWordTargetOnAGatheringRefusesAndWritesNothing() throws {
        try withOperations { ops, db in
            let g = try gathering(ops)
            let before = try db.snapshotRow("reading", g.id, excluding: [])
            try db.clearOutbox()
            #expect(throws: OperationError.wrongReadingKind(id: g.id, expected: .book)) {
                try ops.setReadingWordTarget(g.id, wordTarget: 40_000)
            }
            // The kind answers first — even for a value the positivity check
            // would refuse (a gathering has no extent at all).
            #expect(throws: OperationError.wrongReadingKind(id: g.id, expected: .book)) {
                try ops.setReadingWordTarget(g.id, wordTarget: 0)
            }
            #expect(try db.snapshotRow("reading", g.id, excluding: []) == before)
            #expect(try db.outboxContains("reading", g.id) == false)
        }
    }

    @Test func aNoteCapOnAGatheringRefusesAndWritesNothing() throws {
        try withOperations { ops, db in
            let g = try gathering(ops)
            let before = try db.snapshotRow("reading", g.id, excluding: [])
            try db.clearOutbox()
            #expect(throws: OperationError.wrongReadingKind(id: g.id, expected: .book)) {
                try ops.setReadingMaxPosts(g.id, maxPosts: 5)
            }
            #expect(throws: OperationError.wrongReadingKind(id: g.id, expected: .book)) {
                try ops.setReadingMaxPosts(g.id, maxPosts: -1)
            }
            #expect(try db.snapshotRow("reading", g.id, excluding: []) == before)
            #expect(try db.outboxContains("reading", g.id) == false)
        }
    }

    /// A LEGACY finished gathering refuses being finished again — the kind,
    /// not the state, is the answer.
    @Test func aLegacyFinishedGatheringRefusesAnotherFinish() throws {
        try withOperations { ops, db in
            let g = try gathering(ops)
            try makeLegacy(db, g.id, locked: true, wordTarget: nil, maxPosts: nil)
            let before = try db.snapshotRow("reading", g.id, excluding: [])
            #expect(throws: OperationError.wrongReadingKind(id: g.id, expected: .book)) {
                try ops.lockReading(g.id)
            }
            #expect(try db.snapshotRow("reading", g.id, excluding: []) == before)
        }
    }

    /// THE WAYS OUT (control — green on both sides by design): a legacy
    /// gathering finished AND capped AND targeted reopens, then clears both
    /// extents. Clearing while still finished answers the finished road
    /// (`lockedReading`), unchanged — Reopen comes first, as the sheet's
    /// legacy doors offer it.
    @Test func aLegacyGatheringReopensAndClearsItsExtents() throws {
        try withOperations { ops, db in
            let g = try gathering(ops)
            try makeLegacy(db, g.id, locked: true, wordTarget: 40_000, maxPosts: 5)
            #expect(throws: OperationError.lockedReading(id: g.id)) {
                try ops.setReadingMaxPosts(g.id, maxPosts: nil)
            }
            try ops.unlockReading(g.id)
            try ops.setReadingWordTarget(g.id, wordTarget: nil)
            try ops.setReadingMaxPosts(g.id, maxPosts: nil)
            let row = try #require(try db.read { try Queries.reading($0, id: g.id) })
            #expect(row.locked == false)
            #expect(row.wordTarget == nil)
            #expect(row.maxPosts == nil)
            // Clearing what is already clear stays a no-op (no write).
            try db.clearOutbox()
            try ops.setReadingMaxPosts(g.id, maxPosts: nil)
            try ops.setReadingWordTarget(g.id, wordTarget: nil)
            #expect(try db.outboxContains("reading", g.id) == false)
        }
    }

    /// 13i-d U5 RIDER R1 (F-U4-5, RULED at the architect's adjudication after
    /// U4 — the same letter as the (c) arm): THE MINT refuses a gathering
    /// born with an extent, so the door's shape is closed before any face
    /// passes one. Nothing is inserted and no outbox row is written; a
    /// gathering minted WITHOUT extents and a BOOK minted with them both still
    /// mint (controls inside the pin).
    @Test func mintingAGatheringWithAnExtentRefusesAndMintsNothing() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "mint-tag")
            let rule = try RuleGrammar.encode(.tag(tag.id))
            let readingsBefore = try db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM reading") ?? 0
            }
            try db.clearOutbox()
            func refusesAsWrongKind(_ error: any Error) -> Bool {
                if case OperationError.wrongReadingKind(_, expected: .book) = error { return true }
                return false
            }
            #expect(performing: {
                try ops.createReading(
                    name: "capped", kind: .gathering, querySpec: rule, maxPosts: 5)
            }, throws: refusesAsWrongKind)
            #expect(performing: {
                try ops.createReading(
                    name: "targeted", kind: .gathering, querySpec: rule, wordTarget: 40_000)
            }, throws: refusesAsWrongKind)
            let readingsAfter = try db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM reading") ?? 0
            }
            #expect(readingsAfter == readingsBefore, "a refused mint inserts no reading row")
            let outboxReadings = try db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM sync_outbox WHERE table_name = 'reading'") ?? 0
            }
            #expect(outboxReadings == 0, "a refused mint queues nothing")
            // Controls: the extent-free gathering and the extent-bearing book.
            let plain = try ops.createReading(name: "plain", kind: .gathering, querySpec: rule)
            #expect(plain.maxPosts == nil && plain.wordTarget == nil)
            let book = try ops.createReading(
                name: "bounded", kind: .book, maxPosts: 5, wordTarget: 40_000)
            #expect(book.maxPosts == 5 && book.wordTarget == 40_000)
        }
    }

    /// BOOKS are untouched (control): a book still finishes and takes both
    /// extents.
    @Test func aBookStillFinishesAndTakesItsExtents() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "b", kind: .book)
            try ops.setReadingWordTarget(book.id, wordTarget: 40_000)
            try ops.setReadingMaxPosts(book.id, maxPosts: 5)
            try ops.lockReading(book.id)
            let row = try #require(try db.read { try Queries.reading($0, id: book.id) })
            #expect(row.locked)
            #expect(row.wordTarget == 40_000)
            #expect(row.maxPosts == 5)
        }
    }
}
