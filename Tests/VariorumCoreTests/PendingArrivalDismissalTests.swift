import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-c ladder round 1, the MAJOR — **the finish/seal confirm's N is the
/// DISMISSAL's own set** (the sitting record §24: "N waiting at the door will
/// be dismissed"; `dismissPendingArrivals` is the act). The count and the
/// UPDATE share ONE WHERE (`Queries.pendingArrivalRowsWhere`), so the confirm
/// can never promise a different number than the act takes — an ARCHIVED
/// note's waiting row is dismissed by the finish, so it is counted. (The
/// Arrivals LINE hid it while archived under P-13ib-U2-2's display rule — the
/// MAJOR's occasion; 13i-d U4 REVERSED that rule, so the line shows it now and
/// the two numbers agree, asserted below.)
@Suite("13i-c ladder R1 — the finish confirm counts the dismissal's own set")
struct PendingArrivalDismissalTests {
    /// A living book (dial = arrivals) with one waiting note, then the note
    /// ARCHIVED — the row stands live; the door stops showing it.
    private func archivedWaiter(
        _ ops: Operations
    ) throws -> (bookID: String, noteID: String, pairID: String) {
        let tag = try ops.createTag(name: "waiting")
        let book = try ops.createReading(
            name: "guarded", kind: .book,
            querySpec: try #require(try RuleGrammar.encode(.tag(tag.id))),
            intakeSeating: .arrivals)
        let note = try ops.createPost(title: "late")
        try ops.applyTag(tag.id, toPost: note.id)
        try ops.archiveContainer(note.id)
        return (book.id, note.id, "")
    }

    @Test func theConfirmsCountIsTheDismissalsSet_anArchivedWaiterIsCounted() throws {
        try withOperations { ops, db in
            let world = try archivedWaiter(ops)
            let promised = try db.read { try Queries.pendingArrivalCount($0, readingID: world.bookID) }
            #expect(promised == 1, "the finish will dismiss this row, so the confirm counts it")
            let shown = try db.read {
                try Queries.bookArrivals($0, readingID: world.bookID, limit: 10).count
            }
            // 13i-d U4 — P-13ib-U2-2 REVERSED (her #169(a)(2)/(3)): this arm
            // asserted `shown == 0` (the line hid the archived waiter while
            // the confirm counted it). The flip is deliberate, RED on the
            // pre-flip predicate: the archived waiter is VISIBLE at the door,
            // so the line and the confirm now say the same number — "finishing
            // dismisses every waiter, all visible and counted".
            #expect(shown == promised,
                    "the Arrivals LINE shows what the finish will dismiss — one number")
        }
    }

    @Test func sealPreviewCountsTheArchivedWaiter() throws {
        try withOperations { ops, db in
            let world = try archivedWaiter(ops)
            let preview = try db.read { try Queries.sealPreview($0, readingID: world.bookID) }
            #expect(preview.pendingArrivals == 1,
                    "the seal's finish arm dismisses the archived waiter — §24's line counts it")
        }
    }

    @Test func mixedWaiters_theCountEqualsTheRowsTheFinishTombstones() throws {
        try withOperations { ops, db in
            let world = try archivedWaiter(ops)
            // A second, UN-archived waiter beside the archived one.
            let shown = try ops.createPost(title: "shown")
            let tagID = try db.read { db in
                try #require(try String.fetchOne(
                    db, sql: "SELECT id FROM tag WHERE name = 'waiting'"))
            }
            try ops.applyTag(tagID, toPost: shown.id)

            let promised = try db.read { db in
                try Queries.pendingArrivalCount(db, readingID: world.bookID)
            }
            #expect(promised == 2, "both rows wait at the door — the act will take both")

            try ops.lockReading(world.bookID)

            let dismissed = try db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NOT NULL AND status = 'arrival'
                        """,
                    arguments: [world.bookID]) ?? 0
            }
            #expect(dismissed == promised,
                    "the confirm's N and the dismissal's rows are ONE set, by shared WHERE")
            let live = try db.read { db in
                try Queries.pendingArrivalCount(db, readingID: world.bookID)
            }
            #expect(live == 0, "nothing waits after the finish")
        }
    }
}
