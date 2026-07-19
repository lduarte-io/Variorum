//
//  CanvasAndPoolTests.swift
//  VariorumTests
//
//  Phase 11, Steps A7 + A8 — the canvas (blocks-as-cards over
//  canvas_layout; the view emits EXACTLY the layout ops; gaps render
//  tolerantly) and the full pool (block-tag faces: one toggle = one op;
//  the filter matches everythingTagged's block semantics; structural ops
//  legal in pools through the UI-path planner ride the editor suites —
//  the pool opens in the ordinary editor, the ratified shape).
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@Suite("Canvas & full pool (Phase 11, A7 + A8)")
@MainActor
struct CanvasAndPoolTests {
    @Test func aDragEndEmitsExactlyOneLayoutOpAndResetTombstones() async throws {
        try await withWorld { session, db in
            let (poolID, blockID) = try await session.runner.run { ops -> (String, String) in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "card one", at: .end).block
                _ = try ops.newBlock(in: pool.id, text: "card two", at: .end)
                return (pool.id, block.id)
            }
            let model = CanvasViewModel(session: session, containerID: poolID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: poolID) })

            // No layout rows yet: the default stack position is derived,
            // never persisted.
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM canvas_layout")
            } == 0)
            let resting = model.restingPosition(blockID: blockID)

            await model.dragEnded(blockID: blockID, translation: CGSize(width: 130, height: 45))
            #expect(model.statusMessage == nil)

            let rows = try await db.read { db in
                try Row.fetchAll(db, sql: "SELECT block_id, x, y FROM canvas_layout WHERE deleted_at IS NULL")
            }
            #expect(rows.count == 1, "exactly ONE layout row — the drag's op")
            #expect(rows[0]["block_id"] == blockID)
            #expect(rows[0]["x"] == Double(resting.x + 130))
            #expect(rows[0]["y"] == Double(resting.y + 45))

            // A second drag CAS-updates the SAME row.
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: poolID) })
            await model.dragEnded(blockID: blockID, translation: CGSize(width: 10, height: 10))
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM canvas_layout")
            } == 1)

            // Reset tombstones (the card falls back to the derived stack).
            await model.resetPosition(blockID: blockID)
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM canvas_layout WHERE deleted_at IS NULL")
            } == 0)
        }
    }

    @Test func cardsRenderGapsTolerantlyAndStaleLayoutsAreInert() async throws {
        try await withWorld { session, db in
            let (poolID, blockID, postID) = try await session.runner.run { ops -> (String, String, String) in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "roaming card", at: .end).block
                _ = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 200, y: 100)
                let post = try ops.createPost(title: "elsewhere", profile: .generic)
                return (pool.id, block.id, post.id)
            }
            // The block leaves the pool: its layout row goes stale — the
            // canvas walks the POOL's blocks, so the card vanishes and
            // nothing crashes.
            try await session.runner.run { ops in
                try ops.moveBlock(blockID, to: postID, at: .end)
            }
            let projection = try await db.read {
                try Queries.canvasProjection($0, container: poolID)
            }
            #expect(projection.cards.isEmpty, "the departed block's card is gone")
            #expect(projection.positions[blockID] != nil,
                    "the stale layout row is INERT, not destroyed — the position is remembered")

            // The block returns: the remembered position picks right up.
            try await session.runner.run { ops in
                try ops.moveBlock(blockID, to: poolID, at: .end)
            }
            let model = CanvasViewModel(session: session, containerID: poolID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: poolID) })
            #expect(model.restingPosition(blockID: blockID) == CGPoint(x: 200, y: 100))
        }
    }

    @Test func blockTagTogglesEmitExactlyOneOpEach() async throws {
        try await withWorld { session, db in
            let (blockID, tagID) = try await session.runner.run { ops -> (String, String) in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "scrap", at: .end).block
                let tag = try ops.createTag(parent: nil, name: "sparks")
                return (block.id, tag.id)
            }
            let model = BlockTagAssignmentViewModel(session: session, blockID: blockID)
            await model.load()
            #expect(!model.isApplied(tagID))

            await model.toggle(tagID)
            #expect(model.isApplied(tagID))
            let rowCount = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM block_tag WHERE block_id = ? AND tag_id = ?
                    """, arguments: [blockID, tagID])
            }
            #expect(rowCount == 1, "one toggle = one applyTag(toBlock:)")

            await model.toggle(tagID)
            #expect(!model.isApplied(tagID))
            let live = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM block_tag
                    WHERE block_id = ? AND tag_id = ? AND deleted_at IS NULL
                    """, arguments: [blockID, tagID])
            }
            #expect(live == 0, "un-toggle is a TOMBSTONE, never row removal (S2)")
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM block_tag WHERE block_id = ? AND tag_id = ?
                    """, arguments: [blockID, tagID])
            } == 1)
        }
    }

    @Test func thePoolFilterMatchesEverythingTaggedBlockSemantics() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (pool: String, tagged: String, subtree: String, plain: String, root: String) in
                let pool = try ops.createPool(title: "board")
                let tagged = try ops.newBlock(in: pool.id, text: "tagged directly", at: .end).block
                let subtree = try ops.newBlock(in: pool.id, text: "tagged via child", at: .end).block
                let plain = try ops.newBlock(in: pool.id, text: "untagged", at: .end).block
                let root = try ops.createTag(parent: nil, name: "sparks")
                let child = try ops.createTag(parent: root.id, name: "bright")
                _ = try ops.applyTag(root.id, toBlock: tagged.id)
                _ = try ops.applyTag(child.id, toBlock: subtree.id)
                return (pool.id, tagged.id, subtree.id, plain.id, root.id)
            }
            let model = CanvasViewModel(session: session, containerID: world.pool)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.pool) })

            #expect(model.visibleCards.count == 3, "no filter = the pool verbatim")

            await model.applyFilter(tagID: world.root)
            #expect(Set(model.visibleCards.map(\.block.blockID))
                        == Set([world.tagged, world.subtree]),
                    "the filter is everythingTagged's block half — subtree semantics included")
            // Pinned against the query itself.
            let expected = try await db.read { db in
                Set(try Queries.everythingTagged(db, tagID: world.root, includeSubtree: true)
                    .blockIDs)
            }
            #expect(Set(model.visibleCards.map(\.block.blockID)) == expected)

            await model.applyFilter(tagID: nil)
            #expect(model.visibleCards.count == 3)
            _ = world.plain
        }
    }
}

// MARK: - Phase 13, Stage C3 (R40) + the taste checkpoint's R88 (#28e
// ANSWERED the other way): the switcher is VIEW-LOCAL — ‹ › changes what
// the card SHOWS; chosen moves ONLY through the explicit ✓ gesture
// (chooseViewedTake). The canvas's picks are savable as a lens.

@Suite("Canvas takes switcher (Phase 13, C3 — R88 view-local)")
@MainActor
struct CanvasTakesSwitcherTests {
    @Test func theSwitcherMovesTheViewOnlyAndTheCheckIsTheOneChooser() async throws {
        try await withWorld { session, db in
            // A POST's canvas (R40) with one fanned block: [t1 chosen, t2, t3].
            let world = try await session.runner.run { ops -> (post: String, block: String, takes: [String]) in
                let post = try ops.createPost(title: "spatial", profile: .generic)
                let mint = try ops.newBlock(in: post.id, text: "take one", at: .end)
                _ = try ops.newBlock(in: post.id, text: "single", at: .end)
                let t2 = try ops.branchVariant(mint.block.id, from: mint.variant.id)
                try ops.autosave(t2.id, text: "take two", charDelta: 4)
                let t3 = try ops.branchVariant(mint.block.id, from: t2.id)
                try ops.autosave(t3.id, text: "take three", charDelta: 4)
                return (post.id, mint.block.id, [mint.variant.id, t2.id, t3.id])
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.post) })

            func chosenNow() async throws -> String? {
                try await db.read { db in
                    try Queries.renderPost(db, containerID: world.post)
                        .first { $0.blockID == world.block }?.variantID
                }
            }

            // The single-take block offers no switcher; the fanned one does.
            #expect(model.takePosition(blockID: world.block)?.count == 3)
            let single = model.projection.cards.first { $0.block.blockID != world.block }!
            #expect(model.takePosition(blockID: single.block.blockID) == nil)

            // ‹ at the front clamps; stepping moves the VIEW, never chosen
            // (R88: "it's only chosen if chosen very carefully").
            model.switchTake(blockID: world.block, delta: -1)
            #expect(model.viewedDiffersFromChosen(blockID: world.block) == false)
            model.switchTake(blockID: world.block, delta: 1)
            #expect(model.takePosition(blockID: world.block)?.index == 1)
            #expect(try await chosenNow() == world.takes[0], "viewing never writes chosen")
            #expect(model.viewedDiffersFromChosen(blockID: world.block),
                    "the differs-from-chosen marker's condition holds")
            model.switchTake(blockID: world.block, delta: 1)
            model.switchTake(blockID: world.block, delta: 1)
            #expect(model.takePosition(blockID: world.block)?.index == 2, "the end clamps")

            // ✓ — the ONE careful gesture: the viewed take becomes chosen;
            // the pick clears (viewed == chosen again).
            await model.chooseViewedTake(blockID: world.block)
            #expect(try await chosenNow() == world.takes[2])
            #expect(model.viewedDiffersFromChosen(blockID: world.block) == false)
        }
    }

    @Test func viewingIsLegalUnderASealButChoosingRefusesAndSpeaks() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (post: String, block: String, chosen: String) in
                let post = try ops.createPost(title: "sealed", profile: .generic)
                let mint = try ops.newBlock(in: post.id, text: "take one", at: .end)
                let t2 = try ops.branchVariant(mint.block.id, from: mint.variant.id)
                try ops.autosave(t2.id, text: "take two", charDelta: 4)
                try ops.lockPost(post.id)
                return (post.id, mint.block.id, mint.variant.id)
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.post) })

            // Viewing isn't authoring — the seal doesn't stop ‹ › (the 9d
            // Show-Takes doctrine); choosing IS, and refuses speaking.
            model.switchTake(blockID: world.block, delta: 1)
            #expect(model.viewedDiffersFromChosen(blockID: world.block))
            await model.chooseViewedTake(blockID: world.block)
            #expect(model.statusMessage?.contains("sealed") == true,
                    "the seal's refusal speaks (fire-and-speak)")
            let chosen = try await db.read { db in
                try Queries.renderPost(db, containerID: world.post)
                    .first { $0.blockID == world.block }?.variantID
            }
            #expect(chosen == world.chosen, "chosen never moved under the seal")
        }
    }

    @Test func canvasPicksSaveAsALens() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (post: String, block: String, t2: String) in
                let post = try ops.createPost(title: "kept", profile: .generic)
                let mint = try ops.newBlock(in: post.id, text: "take one", at: .end)
                let t2 = try ops.branchVariant(mint.block.id, from: mint.variant.id)
                try ops.autosave(t2.id, text: "take two", charDelta: 4)
                return (post.id, mint.block.id, t2.id)
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.post) })

            model.switchTake(blockID: world.block, delta: 1)
            await model.saveViewPicksAsLens(name: "canvas thread")
            let pick = try await db.read { [post = world.post] db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT lc.variant_id FROM lens_choice lc
                        JOIN lens l ON l.id = lc.lens_id
                        WHERE l.container_id = ? AND l.name = 'canvas thread'
                          AND lc.deleted_at IS NULL
                        """,
                    arguments: [post])
            }
            #expect(pick == world.t2, "the canvas's viewed take became the lens's pick")
        }
    }
}
