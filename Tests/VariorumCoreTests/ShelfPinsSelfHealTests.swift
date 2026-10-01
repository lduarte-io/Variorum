import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **18o U1 — 17e P35: `shelf_pins` self-heals like its sibling `starred`.**
///
/// The finding (verifier-confirmed): the public `setShelfPinned` ran
/// `liveReading` FIRST, so once a pinned book was deleted every unpin threw
/// `readingNotFound`; the writer only appended or removed the one id it was
/// handed and never pruned; and nothing unpins on delete — so a deleted
/// book's id stayed in the synced list forever (the phone's tutorial
/// seeder unpins its doomed books BEFORE deleting them for exactly this
/// reason). The model is `setStarred` in the same file: every write
/// persists the LIVE list, and a write that changes nothing writes nothing.
@Suite("Shelf pins self-heal (18o U1 — 17e P35)")
struct ShelfPinsSelfHealTests {
    /// The stuck pin: unpinning a deleted book refused on the old tree.
    /// (13i-a: the star is the row's own column now, so the dead book is
    /// out of the listing with or without the unpin — the door still
    /// never throws.)
    @Test func unpinningADeletedBookWorksAndShedsItsID() throws {
        try withOperations { ops, db in
            let kept = try ops.createReading(name: "kept", kind: .book)
            let doomed = try ops.createReading(name: "doomed", kind: .book)
            try ops.setShelfPinned(kept.id, pinned: true)
            try ops.setShelfPinned(doomed.id, pinned: true)
            try ops.deleteReading(doomed.id)

            #expect(throws: Never.self, "removal never requires a live row") {
                try ops.setShelfPinned(doomed.id, pinned: false)
            }
            #expect(try db.read { try Queries.shelfPins($0) } == [kept.id])
        }
    }

    /// 13i-a UPGRADES the heal to by-construction: the star lives ON the
    /// reading row (`reading.starred` — the pin list is retired), so a
    /// deleted book leaves the list THE MOMENT it dies (the listing reads
    /// live rows only) — no write needed — and a RESTORED book comes back
    /// starred, which the old stored-list could not promise.
    @Test func theNextPinWriteHealsTheStoredList() throws {
        try withOperations { ops, db in
            let first = try ops.createReading(name: "first", kind: .book)
            let doomed = try ops.createReading(name: "doomed", kind: .book)
            let later = try ops.createReading(name: "later", kind: .book)
            try ops.setShelfPinned(first.id, pinned: true)
            try ops.setShelfPinned(doomed.id, pinned: true)
            try ops.deleteReading(doomed.id)
            // The flag rides the tombstoned row; the listing is live-only,
            // so the dead book is gone at once.
            #expect(try db.read { try Queries.shelfPins($0) } == [first.id])

            try ops.setShelfPinned(later.id, pinned: true)
            #expect(try db.read { try Queries.shelfPins($0) } == [first.id, later.id])

            // The upgrade the column buys: restore brings the star back.
            try ops.restoreReading(doomed.id)
            #expect(try db.read { try Queries.shelfPins($0) }
                        == [doomed.id, first.id, later.id],
                    "a restored book comes back starred (name order: doomed · first · later)")
        }
    }

    // MARK: - Guards (green on both trees — the fix must not move them)

    /// Pinning still needs a live book: a dead or absent id refuses, and
    /// nothing is written.
    @Test func pinningADeadOrAbsentBookStillRefuses() throws {
        try withOperations { ops, db in
            let doomed = try ops.createReading(name: "doomed", kind: .book)
            try ops.deleteReading(doomed.id)
            #expect(throws: OperationError.readingNotFound(id: doomed.id)) {
                try ops.setShelfPinned(doomed.id, pinned: true)
            }
            #expect(throws: OperationError.readingNotFound(id: "no-such-book")) {
                try ops.setShelfPinned("no-such-book", pinned: true)
            }
            #expect(try db.read { try Queries.shelfPins($0) }.isEmpty)
        }
    }

    /// The identity-metadata convention: a write that changes nothing
    /// writes nothing — since 13i-a that means no READING row update and
    /// no outbox row for it.
    @Test func aNoOpPinWriteWritesNothing() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            let other = try ops.createReading(name: "other", kind: .book)
            try ops.setShelfPinned(book.id, pinned: true)
            try db.clearOutbox()
            try ops.setShelfPinned(book.id, pinned: true)   // already pinned
            try ops.setShelfPinned(other.id, pinned: false) // never pinned
            #expect(try db.outboxContains("reading", book.id) == false)
            #expect(try db.outboxContains("reading", other.id) == false)
            #expect(try db.read { try Queries.shelfPins($0) } == [book.id])
        }
    }

    /// The in-transaction pinners (the daily Journal's and the quick-note
    /// book's create-and-pin ensures) pin a reading inserted in the SAME
    /// transaction — live by then, so the heal keeps it, and heals the rest.
    @Test func anInTransactionEnsurePinsItsFreshBookAndHealsTheRest() throws {
        try withOperations { ops, db in
            let kept = try ops.createReading(name: "kept", kind: .book)
            let doomed = try ops.createReading(name: "doomed", kind: .book)
            try ops.setShelfPinned(kept.id, pinned: true)
            try ops.setShelfPinned(doomed.id, pinned: true)
            try ops.deleteReading(doomed.id)

            let quicknotes = try ops.ensureQuicknotesBook()
            #expect(try db.read { try Queries.shelfPins($0) } == [kept.id, quicknotes])
        }
    }
}
