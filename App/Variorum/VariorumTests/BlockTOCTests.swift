//
//  BlockTOCTests.swift
//  VariorumTests
//
//  Phase 11, Step A6 — the block-TOC's pins: the handle is DERIVED at read
//  time (never stored — review focus 7's class); TOC gestures emit exactly
//  the Phase 2/3 ops (row-level); reorder is a fractional-index move; the
//  tray restore round-trips through the UI path; expansion is session-only
//  and the one-live-editor split holds.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@Suite("Block TOC (Phase 11, A6)")
@MainActor
struct BlockTOCTests {
    @Test func theHandleIsNameElseReadTimeFirstSentenceNeverStored() async throws {
        // The pure derivation.
        #expect(Queries.tocHandle(name: "the thesis", text: "Whatever. Text.") == "the thesis")
        #expect(Queries.tocHandle(name: nil, text: "First sentence. Second one.")
                == "First sentence.")
        #expect(Queries.tocHandle(name: nil, text: "No terminator here") == "No terminator here")
        #expect(Queries.tocHandle(name: nil, text: "") == "(empty block)")
        #expect(Queries.tocHandle(name: nil, text: nil) == "(empty block)")
        #expect(Queries.tocHandle(name: "", text: "Fallback. Text.") == "Fallback.",
                "an empty name falls back to the derivation")

        // NOTHING persists the derivation: the schema has no home for it —
        // block carries exactly `name`; no other text column exists outside
        // variant buffers/commits (structural pin for review focus 7).
        try await withWorld { _, db in
            let blockColumns = try await db.read { db in
                try Row.fetchAll(db, sql: "PRAGMA table_info(block)").map { $0["name"] as String }
            }
            #expect(!blockColumns.contains("handle"))
            #expect(!blockColumns.contains("first_sentence"))
            #expect(blockColumns.contains("name"), "the ONLY stored handle is the explicit name")
        }
    }

    @Test func tocRowsRenderTheTraversalWithNamesJoined() async throws {
        try await withWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "post", profile: .blog)
                let b1 = try ops.newBlock(in: post.id, text: "One. More.", at: .end).block
                _ = try ops.newBlock(in: post.id, text: "Two.", at: .end)
                try ops.setBlockName(b1.id, name: "opener")
                return post.id
            }
            let rows = try await db.read { try Queries.blockTOC($0, post: postID) }
            #expect(rows.count == 2)
            #expect(rows[0].name == "opener")
            #expect(rows[1].name == nil)
            #expect(Queries.tocHandle(name: rows[0].name, text: rows[0].text) == "opener")
            #expect(Queries.tocHandle(name: rows[1].name, text: rows[1].text) == "Two.")
        }
    }

    @Test func reorderEmitsFractionalIndexMovesAndTheOrderFlips() async throws {
        try await withWorld { session, db in
            let (postID, blocks) = try await session.runner.run { ops -> (String, [String]) in
                let post = try ops.createPost(title: "post", profile: .blog)
                var ids: [String] = []
                for i in 1...3 {
                    ids.append(try ops.newBlock(in: post.id, text: "Block \(i).", at: .end).block.id)
                }
                return (post.id, ids)
            }
            let model = BlockTOCViewModel(session: session, postID: postID)
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })

            let positionBefore = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT position FROM container_block WHERE block_id = ?",
                    arguments: [blocks[2]])
            }
            await model.move(blockID: blocks[2], up: true)

            let order = try await db.read { db in
                try Queries.renderPost(db, containerID: postID).map(\.blockID)
            }
            #expect(order == [blocks[0], blocks[2], blocks[1]], "one step up")
            let positionAfter = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT position FROM container_block WHERE block_id = ?",
                    arguments: [blocks[2]])
            }
            #expect(positionAfter != positionBefore,
                    "the move is ONE fractional-index position write")
            // The SAME placement row moved — never delete/recreate.
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL
                    """, arguments: [postID])
            } == 3)

            // Boundary moves no-op quietly.
            model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            await model.move(blockID: blocks[0], up: true)
            #expect(model.statusMessage == nil)
        }
    }

    /// 13b 4D (N39, her ask): positional moves — a typed target position
    /// plus top/bottom doors, all ONE ordinary `reorder` per move (⌥⌘Z
    /// undoes via the op's own inverse). Position math reads as a human
    /// counts: "make me block #k of the post".
    @Test func positionalMovesLandTheBlockAtTheTypedOrdinal() async throws {
        try await withWorld { session, db in
            let (postID, blocks) = try await session.runner.run { ops -> (String, [String]) in
                let post = try ops.createPost(title: "post", profile: .blog)
                var ids: [String] = []
                for i in 1...4 {
                    ids.append(try ops.newBlock(in: post.id, text: "Block \(i).", at: .end).block.id)
                }
                return (post.id, ids)
            }
            let model = BlockTOCViewModel(session: session, postID: postID)
            @MainActor func reload() async throws {
                model.adopt(rows: try await db.read { try Queries.blockTOC($0, post: postID) })
            }
            @MainActor func order() async throws -> [String] {
                try await db.read { try Queries.renderPost($0, containerID: postID).map(\.blockID) }
            }
            try await reload()

            // #4 → #2 (a long-distance move without dragging).
            await model.move(blockID: blocks[3], toOrdinal: 2)
            #expect(try await order() == [blocks[0], blocks[3], blocks[1], blocks[2]])
            #expect(model.statusMessage?.contains("block 2 of 4") == true)

            // Move to top / bottom.
            try await reload()
            await model.moveToBottom(blocks[0])
            #expect(try await order() == [blocks[3], blocks[1], blocks[2], blocks[0]])
            try await reload()
            await model.moveToTop(blocks[2])
            #expect(try await order() == [blocks[2], blocks[3], blocks[1], blocks[0]])

            // Out-of-range clamps (her "out of the total post" is the
            // range); already-there speaks a no-op, writes nothing.
            try await reload()
            await model.move(blockID: blocks[2], toOrdinal: 99)
            #expect(try await order() == [blocks[3], blocks[1], blocks[0], blocks[2]],
                    "99 clamps to the end")
            try await reload()
            let stamp = try await order()
            await model.move(blockID: blocks[2], toOrdinal: 4)
            #expect(try await order() == stamp, "already #4 — nothing written")
            #expect(model.statusMessage?.contains("Already block 4") == true)

            // ⌥⌘Z undoes the last positional move (reorder registers its
            // own inverse — no new undo machinery).
            try await reload()
            await model.move(blockID: blocks[3], toOrdinal: 4)
            let moved = try await order()
            let undoStack = session.undoStack
            _ = try await session.runner.run { ops in
                try undoStack.undo(with: ops)
            }
            #expect(try await order() != moved, "one ⌥⌘Z restores the previous order")
        }
    }

    @Test func deleteAndTrayRestoreRoundTripThroughTheUIPath() async throws {
        try await withWorld { session, db in
            let (postID, doomed) = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "post", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "Keeper.", at: .end)
                let doomed = try ops.newBlock(in: post.id, text: "Doomed block.", at: .end).block
                return (post.id, doomed.id)
            }
            let model = BlockTOCViewModel(session: session, postID: postID)

            await model.deleteBlock(doomed)
            #expect(model.statusMessage == nil)
            let tray = try await db.read { try Queries.trayBlocks($0, postID: postID) }
            #expect(tray.map(\.blockID) == [doomed], "the deleted block trays")
            model.adopt(tray: tray)

            await model.restoreBlock(doomed)
            #expect(model.statusMessage == nil)
            let order = try await db.read { db in
                try Queries.renderPost(db, containerID: postID).map(\.blockID)
            }
            #expect(order.count == 2)
            // 13j F2: `restoreBlock` revives the placement row this deletion
            // tombstoned, so the block comes back in its own place — which
            // for the last block is the end, exactly as before.
            #expect(order.last == doomed, "back in its own place")
            #expect(try await db.read { try Queries.trayBlocks($0, postID: postID) }.isEmpty)
        }
    }

    @Test func namingMovingToPoolAndExpansionBehave() async throws {
        try await withWorld { session, db in
            let (postID, blockID, poolID) = try await session.runner.run { ops -> (String, String, String) in
                let post = try ops.createPost(title: "post", profile: .blog)
                let block = try ops.newBlock(in: post.id, text: "A scrap in waiting.", at: .end).block
                _ = try ops.newBlock(in: post.id, text: "Stays.", at: .end)
                let pool = try ops.createPool(title: "scraps")
                return (post.id, block.id, pool.id)
            }
            let model = BlockTOCViewModel(session: session, postID: postID)

            await model.rename(blockID: blockID, to: "the scrap")
            #expect(try await db.read { db in
                try String.fetchOne(db, sql: "SELECT name FROM block WHERE id = ?",
                                    arguments: [blockID])
            } == "the scrap")

            // Expansion is session-only: a fresh model starts collapsed.
            model.toggleExpanded(blockID)
            #expect(model.expanded.contains(blockID))
            // 13b 1a: makeLive names the take too (the authority's PaneKey).
            model.makeLive(blockID, variantID: "the-block's-take")
            #expect(model.liveBlockID == blockID, "ONE live block (P3's split)")
            let fresh = BlockTOCViewModel(session: session, postID: postID)
            #expect(fresh.expanded.isEmpty, "collapse state persists NOWHERE in v1")

            // 13b 4D (N32(a) — JUSTIFIED EDIT: the door now SPEAKS its
            // consequence on success; her S4-8a confusion was exactly a
            // silent success — the old `== nil` pinned the silence).
            await model.moveToPool(blockID, poolID: poolID, poolTitle: "scraps")
            #expect(model.statusMessage?.contains("LEFT this note") == true,
                    "the move speaks the I2 consequence and the road back")
            let pool = try await db.read { try Queries.poolListing($0, poolID: poolID) }
            #expect(pool.map(\.block.blockID) == [blockID],
                    "move-to-pool is the Phase 2 moveBlock — same block id, new home (I2)")
        }
    }
}
