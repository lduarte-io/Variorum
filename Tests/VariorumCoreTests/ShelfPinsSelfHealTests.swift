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
    @Test func unpinningADeletedBookWorksAndShedsItsID() throws {
        try withOperations { ops, db in
            let kept = try ops.createReading(name: "kept", kind: .curated)
            let doomed = try ops.createReading(name: "doomed", kind: .curated)
            try ops.setShelfPinned(kept.id, pinned: true)
            try ops.setShelfPinned(doomed.id, pinned: true)
            try ops.deleteReading(doomed.id)

            #expect(throws: Never.self, "removal never requires a live row") {
                try ops.setShelfPinned(doomed.id, pinned: false)
            }
            #expect(try db.read { try Queries.shelfPins($0) } == [kept.id],
                    "the stored JSON sheds the dead id")
        }
    }

    /// The self-heal proper: ANY pin write persists the live list, so a
    /// deleted book's id leaves the stored value the next time she pins
    /// anything — order kept for the survivors.
    @Test func theNextPinWriteHealsTheStoredList() throws {
        try withOperations { ops, db in
            let first = try ops.createReading(name: "first", kind: .curated)
            let doomed = try ops.createReading(name: "doomed", kind: .curated)
            let later = try ops.createReading(name: "later", kind: .curated)
            try ops.setShelfPinned(first.id, pinned: true)
            try ops.setShelfPinned(doomed.id, pinned: true)
            try ops.deleteReading(doomed.id)
            // The READ side is unchanged by this fix (a dead id matches no
            // shelf row); the STORED list carries it until a write.
            #expect(try db.read { try Queries.shelfPins($0) } == [first.id, doomed.id])

            try ops.setShelfPinned(later.id, pinned: true)
            #expect(try db.read { try Queries.shelfPins($0) } == [first.id, later.id],
                    "the dead id is gone and pin order holds")
        }
    }

    // MARK: - Guards (green on both trees — the fix must not move them)

    /// Pinning still needs a live book: a dead or absent id refuses, and
    /// nothing is written.
    @Test func pinningADeadOrAbsentBookStillRefuses() throws {
        try withOperations { ops, db in
            let doomed = try ops.createReading(name: "doomed", kind: .curated)
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

    /// The identity-metadata convention `setStarred` keeps: a write that
    /// changes nothing writes nothing — no setting update, no outbox row.
    @Test func aNoOpPinWriteWritesNothing() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .curated)
            let other = try ops.createReading(name: "other", kind: .curated)
            try ops.setShelfPinned(book.id, pinned: true)
            try db.clearOutbox()
            try ops.setShelfPinned(book.id, pinned: true)   // already pinned
            try ops.setShelfPinned(other.id, pinned: false) // never pinned
            #expect(try db.outboxContains("setting", "shelf_pins") == false)
            #expect(try db.read { try Queries.shelfPins($0) } == [book.id])
        }
    }

    /// The in-transaction pinners (the daily Journal's and the quick-note
    /// book's create-and-pin ensures) pin a reading inserted in the SAME
    /// transaction — live by then, so the heal keeps it, and heals the rest.
    @Test func anInTransactionEnsurePinsItsFreshBookAndHealsTheRest() throws {
        try withOperations { ops, db in
            let kept = try ops.createReading(name: "kept", kind: .curated)
            let doomed = try ops.createReading(name: "doomed", kind: .curated)
            try ops.setShelfPinned(kept.id, pinned: true)
            try ops.setShelfPinned(doomed.id, pinned: true)
            try ops.deleteReading(doomed.id)

            let quicknotes = try ops.ensureQuicknotesBook()
            #expect(try db.read { try Queries.shelfPins($0) } == [kept.id, quicknotes])
        }
    }
}
