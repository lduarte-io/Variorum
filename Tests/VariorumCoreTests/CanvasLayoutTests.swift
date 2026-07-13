import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 11, Step A1 — migration v1_5 (`canvas_layout`) and its two
/// operations. The table is sync-shaped end to end (registry, mirror,
/// repair — pinned in the sync suites); these tests pin the schema itself
/// (live-unique index, both cascade triggers, outbox capture + apply-mode
/// suppression) and the exact op state transitions.
@Suite("canvas_layout schema & operations (Phase 11, A1)")
struct CanvasLayoutTests {
    // MARK: - Schema

    @Test func theLiveUniqueIndexAllowsTombstoneThenRecreate() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block

            let first = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 10, y: 20)
            try ops.removeCanvasPosition(container: pool.id, block: block.id)
            let second = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 30, y: 40)

            // The tombstoned row never blocks re-creation (§6's live-row
            // partial-index rule) — and the re-creation is a FRESH row.
            #expect(first.id != second.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM canvas_layout WHERE container_id = ? AND block_id = ?",
                [pool.id, block.id]) == 2)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM canvas_layout WHERE container_id = ? AND block_id = ? AND deleted_at IS NULL",
                [pool.id, block.id]) == 1)

            // Two LIVE rows for one pair are refused by the index itself.
            #expect(throws: (any Error).self) {
                try db.write { database in
                    try database.execute(sql: """
                        INSERT INTO canvas_layout (id, container_id, block_id, x, y, created_at, updated_at)
                        VALUES ('dup', ?, ?, 0, 0, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z')
                        """, arguments: [pool.id, block.id])
                }
            }
        }
    }

    @Test func aContainerTombstoneCascadesToItsCanvasRowsWithTheExactStamp() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            let layout = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 1, y: 2)

            try ops.deleteContainer(pool.id)

            let containerStamp = try db.deletedAt("container", pool.id)
            let layoutStamp = try db.deletedAt("canvas_layout", layout.id)
            #expect(containerStamp != nil)
            #expect(layoutStamp == containerStamp,
                    "cascade victims carry the parent's exact stamp (restore recognizes them)")
        }
    }

    @Test func aBlockTombstoneCascadesToItsCanvasRow() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            let layout = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 1, y: 2)

            try ops.deleteBlock(block.id)

            let blockStamp = try db.deletedAt("block", block.id)
            #expect(blockStamp != nil)
            #expect(try db.deletedAt("canvas_layout", layout.id) == blockStamp)
        }
    }

    @Test func outboxCaptureFiresForCanvasWritesAndSuppressesDuringApply() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            try db.clearOutbox()

            let layout = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 5, y: 6)
            #expect(try db.outboxContains("canvas_layout", layout.id))

            try db.clearOutbox()
            try db.applyingRemote { database in
                try database.execute(
                    sql: "UPDATE canvas_layout SET x = 99 WHERE id = ?", arguments: [layout.id])
            }
            #expect(!(try db.outboxContains("canvas_layout", layout.id)),
                    "apply-mode writes are echo-suppressed")
        }
    }

    // MARK: - Operations

    @Test func setCanvasPositionMintsThenUpdatesInPlace() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block

            let minted = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 10, y: 20)
            #expect(minted.x == 10 && minted.y == 20)

            let moved = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 33, y: 44)
            #expect(moved.id == minted.id, "re-positioning is metadata CAS on the SAME row")
            #expect(moved.x == 33 && moved.y == 44)
            #expect(moved.updatedAt > minted.updatedAt)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM canvas_layout") == 1)
        }
    }

    @Test func setCanvasPositionStampsTheSignedInOwner() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            let layout = try withDependencies {
                $0.ownerIdentity = OwnerIdentity { "owner-123" }
            } operation: {
                try Operations().setCanvasPosition(container: pool.id, block: block.id, x: 0, y: 0)
            }
            #expect(layout.ownerId == "owner-123")
            _ = db
        }
    }

    @Test func aForeignOrUnplacedBlockRefuses() throws {
        try withOperations { ops, _ in
            let pool = try ops.createPool(title: "board")
            let post = try ops.createPost(title: "elsewhere", profile: .generic)
            let foreign = try ops.newBlock(in: post.id, text: "not a scrap", at: .end).block

            #expect(throws: OperationError.blockNotInContainer(
                blockID: foreign.id, containerID: pool.id)) {
                try ops.setCanvasPosition(container: pool.id, block: foreign.id, x: 0, y: 0)
            }
        }
    }

    @Test func removeCanvasPositionTombstonesAndRefusesWhenAbsent() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            let layout = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 1, y: 1)

            try ops.removeCanvasPosition(container: pool.id, block: block.id)
            #expect(try db.deletedAt("canvas_layout", layout.id) != nil)

            #expect(throws: OperationError.canvasPositionNotFound(
                blockID: block.id, containerID: pool.id)) {
                try ops.removeCanvasPosition(container: pool.id, block: block.id)
            }
        }
    }

    @Test func deadTargetsRefuse() throws {
        try withOperations { ops, _ in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            try ops.deleteBlock(block.id)
            #expect(throws: OperationError.blockNotFound(id: block.id)) {
                try ops.setCanvasPosition(container: pool.id, block: block.id, x: 0, y: 0)
            }
        }
    }
}

// MARK: - Review round 1, MAJOR (the canvas half): restore doors revive
// exact-stamp canvas rows. Red-on-old.

@Suite("Restore doors revive canvas rows (Phase 11, review round 1 MAJOR)")
struct CanvasRestoreTests {
    @Test func restoreBlockRevivesItsCanvasPosition() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            _ = try ops.newBlock(in: pool.id, text: "keeps the pool alive", at: .end)
            let layout = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 44, y: 55)

            try ops.deleteBlock(block.id)
            #expect(try db.deletedAt("canvas_layout", layout.id) != nil)

            try ops.restoreBlock(block.id)
            #expect(try db.deletedAt("canvas_layout", layout.id) == nil,
                    "the exact-stamp victim revives with its block")
            let positions = try db.read { try Queries.canvasLayouts($0, container: pool.id) }
            #expect(positions[block.id] == Queries.CanvasPosition(x: 44, y: 55),
                    "the card lands back where the author placed it")
        }
    }

    @Test func restoreContainerRevivesItsCanvasRows() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            let layout = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 7, y: 9)

            try ops.deleteContainer(pool.id)
            try ops.restoreContainer(pool.id)

            #expect(try db.deletedAt("canvas_layout", layout.id) == nil)
            let positions = try db.read { try Queries.canvasLayouts($0, container: pool.id) }
            #expect(positions[block.id] == Queries.CanvasPosition(x: 7, y: 9))
        }
    }
}

// MARK: - Review round 2, MINOR 2 (the departed-block corner of the
// round-1 MAJOR): the container cascade stamps a DEPARTED block's inert
// canvas row too (WHERE container_id = NEW.id), but restoreContainer only
// revived rows through the per-block loop — an exact-stamp victim whose
// block lives elsewhere stayed dead, and the remembered position was
// silently gone when the block returned. Red-on-current.

extension CanvasRestoreTests {
    @Test func restoreContainerRevivesADepartedBlocksRememberedPosition() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "board")
            let other = try ops.createPool(title: "elsewhere")
            let block = try ops.newBlock(in: pool.id, text: "roams", at: .end).block
            _ = try ops.newBlock(in: pool.id, text: "keeps the pool non-empty", at: .end)
            let layout = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 21, y: 34)

            // The block departs; its layout row stays live BY DESIGN (the
            // A7-pinned remembered position).
            try ops.moveBlock(block.id, to: other.id, at: .end)
            #expect(try db.deletedAt("canvas_layout", layout.id) == nil)

            try ops.deleteContainer(pool.id)
            #expect(try db.deletedAt("canvas_layout", layout.id) != nil,
                    "the container cascade stamps the inert row too")

            try ops.restoreContainer(pool.id)
            #expect(try db.deletedAt("canvas_layout", layout.id) == nil,
                    "an exact-stamp cascade victim revives even when its block lives elsewhere")

            // The remembered position is intact when the block returns.
            try ops.moveBlock(block.id, to: pool.id, at: .end)
            let positions = try db.read { try Queries.canvasLayouts($0, container: pool.id) }
            #expect(positions[block.id] == Queries.CanvasPosition(x: 21, y: 34))
        }
    }
}
