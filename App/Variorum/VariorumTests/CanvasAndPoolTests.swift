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

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
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

// MARK: - 13b Stage 4, Batch 4E (N30/S4-7 — built to the Phase-1 ruling)

/// The pure geometry brain: spread-grid defaults + the realized-set
/// culling function (the P1 bound as arithmetic).
@Suite("Canvas board geometry (13b 4E — spread grid + culling)")
struct CanvasBoardGeometryTests {
    /// The 4E realization pin, pure half: the realized set is bounded by
    /// the viewport and INDEPENDENT of post size.
    @Test func theRealizedSetIsViewportBoundedAndPostSizeIndependent() {
        func gridFrames(_ count: Int, columns: Int? = nil) -> [String: CGRect] {
            let columns = columns ?? CanvasBoardGeometry.spreadColumns(count: count)
            let origin = CanvasBoardGeometry.gridOrigin(positionedFrames: [])
            var frames: [String: CGRect] = [:]
            for i in 0..<count {
                frames["b\(i)"] = CGRect(
                    origin: CanvasBoardGeometry.spreadPosition(
                        index: i, columns: columns, origin: origin),
                    size: CanvasBoardGeometry.defaultCardSize)
            }
            return frames
        }
        let viewport = CGRect(x: 0, y: 0, width: 1200, height: 800)
        let margin = CanvasBoardGeometry.cullingMargin
        let pitchX = CanvasBoardGeometry.defaultCardSize.width + CanvasBoardGeometry.gridGutter
        let pitchY = CanvasBoardGeometry.defaultCardSize.height + CanvasBoardGeometry.gridGutter
        // The arithmetic bound: cards per axis the inflated viewport can
        // intersect, plus one for straddle.
        let bound = (Int((viewport.width + 2 * margin) / pitchX) + 2)
            * (Int((viewport.height + 2 * margin) / pitchY) + 2)

        let realized600 = CanvasBoardGeometry.realized(
            frames: gridFrames(600), visible: viewport)
        #expect(!realized600.isEmpty, "the viewport's cards realize")
        #expect(realized600.count <= bound,
                "600 cards: realized \(realized600.count) ≤ the viewport bound \(bound)")
        #expect(realized600.count < 600, "never every card (P1)")

        // Post-size independence, exact: grid 6,000 cards onto the SAME
        // column count — the extra 5,400 only extend the grid downward,
        // past the viewport, so the realized set is IDENTICAL.
        let columns600 = CanvasBoardGeometry.spreadColumns(count: 600)
        let realized6000 = CanvasBoardGeometry.realized(
            frames: gridFrames(6000, columns: columns600), visible: viewport)
        #expect(realized6000 == realized600,
                "10× the cards, the same viewport ⇒ the SAME realized set (P1's letter)")

        // An empty viewport realizes nothing (the pre-geometry mount).
        #expect(CanvasBoardGeometry.realized(frames: gridFrames(50), visible: .zero).isEmpty)
    }

    @Test func theGridStartsBelowThePositionedBoundingBox() {
        // No positioned cards: the board inset.
        #expect(CanvasBoardGeometry.gridOrigin(positionedFrames: [])
                == CGPoint(x: 20, y: 20))
        // Positioned cards: the grid opens below their lowest edge —
        // defaults never hide under her arrangement (the endorsed rider).
        let positioned = [
            CGRect(x: -100, y: 40, width: 240, height: 170),
            CGRect(x: 300, y: 250, width: 240, height: 170),
        ]
        let origin = CanvasBoardGeometry.gridOrigin(positionedFrames: positioned)
        #expect(origin.y == 250 + 170 + 40, "below maxY plus two gutters")
        #expect(origin.x == 20)
    }

    @Test func spreadPositionsTileWithoutOverlap() {
        let columns = CanvasBoardGeometry.spreadColumns(count: 7)
        #expect(columns == 3, "square-ish: ceil(√7)")
        let origin = CGPoint(x: 20, y: 20)
        var frames: [CGRect] = []
        for i in 0..<7 {
            frames.append(CGRect(
                origin: CanvasBoardGeometry.spreadPosition(
                    index: i, columns: columns, origin: origin),
                size: CanvasBoardGeometry.defaultCardSize))
        }
        for (i, a) in frames.enumerated() {
            for b in frames.dropFirst(i + 1) {
                #expect(!a.intersects(b), "spread cards never overlap (the pile is dead)")
            }
        }
    }

    @Test func fitScaleClampsAtTheFloorAndNeverZoomsIn() {
        let viewport = CGSize(width: 1000, height: 800)
        // Fits: never zoom IN past 1:1.
        #expect(CanvasBoardGeometry.fitScale(
            bounds: CGRect(x: 0, y: 0, width: 500, height: 300), viewport: viewport) == 1)
        // Doesn't fit: scale down to fit the wider axis.
        let scale = CanvasBoardGeometry.fitScale(
            bounds: CGRect(x: 0, y: 0, width: 2000, height: 800), viewport: viewport)
        #expect(scale == 0.5)
        // A vast board clamps at the floor (the overview scrolls for the
        // rest — honest, never a lie of fit).
        #expect(CanvasBoardGeometry.fitScale(
            bounds: CGRect(x: 0, y: 0, width: 100_000, height: 100_000), viewport: viewport)
            == CanvasBoardGeometry.overviewScaleFloor)
    }

    @Test func clampedSizeHonorsTheCardRange() {
        #expect(CanvasBoardGeometry.clampedSize(CGSize(width: 10, height: 10))
                == CanvasBoardGeometry.minCardSize)
        #expect(CanvasBoardGeometry.clampedSize(CGSize(width: 10_000, height: 10_000))
                == CanvasBoardGeometry.maxCardSize)
        let free = CGSize(width: 300, height: 200)
        #expect(CanvasBoardGeometry.clampedSize(free) == free)
    }
}

/// The model half: spread defaults replace the pile; realization is
/// bounded; the live pane's card survives derealization; sizes are local.
@Suite("Canvas realization & cards (13b 4E)")
@MainActor
struct CanvasRealizationTests {
    /// RED-ON-OLD (behavioral revert procedure — restore the A7 default
    /// stack `CGPoint(x: 20, y: 20 + index*90)` in `restingPosition`):
    /// the distinct-columns and no-overlap expectations fail on that code
    /// (every unpositioned card sat at x=20, overlapping at 90pt pitch).
    @Test func spreadGridDefaultsReplaceThePileAndNothingPersists() async throws {
        try await withWorld { session, db in
            let poolID = try await session.runner.run { ops -> String in
                let pool = try ops.createPool(title: "board")
                for i in 0..<6 {
                    _ = try ops.newBlock(in: pool.id, text: "scrap \(i)", at: .end)
                }
                return pool.id
            }
            let model = CanvasViewModel(session: session, containerID: poolID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: poolID) })

            let ids = model.projection.cards.map(\.block.blockID)
            let frames = ids.map { CGRect(
                origin: model.restingPosition(blockID: $0),
                size: model.cardSize(blockID: $0)) }
            // The pile is dead: more than one distinct column...
            #expect(Set(frames.map(\.minX)).count > 1,
                    "spread cards occupy several columns (the old stack was all x=20)")
            // ...and no two cards overlap.
            for (i, a) in frames.enumerated() {
                for b in frames.dropFirst(i + 1) {
                    #expect(!a.intersects(b), "spread cards never overlap")
                }
            }
            // Derived, never persisted (the A7 rule stands).
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM canvas_layout")
            } == 0, "nothing persists until the author drags")
        }
    }

    /// The 4E realization pin, model half: an 80-card post's mount-time
    /// realized set is bounded (the pre-4E ForEach rendered every card).
    @Test func aLongPostsMountRealizesABoundedSetNotEveryCard() async throws {
        try await withWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "long", profile: .generic)
                for i in 0..<80 {
                    _ = try ops.newBlock(in: post.id, text: "block \(i) prose.", at: .end)
                }
                return post.id
            }
            let model = CanvasViewModel(session: session, containerID: postID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: postID) })

            // Mount state (no scroll geometry yet): the default window.
            #expect(!model.realizedCards.isEmpty, "the viewport's cards realize")
            #expect(model.realizedCards.count < 80,
                    "a long post's mount never realizes every card (P1)")

            // A scrolled viewport realizes a different bounded set.
            model.noteVisibleRect(CGRect(x: 0, y: 3000, width: 1200, height: 800))
            #expect(model.realizedCards.count < 80)
        }
    }

    @Test func theLivePanesCardSurvivesDerealization() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (post: String, first: String, firstTake: String) in
                let post = try ops.createPost(title: "ring", profile: .generic)
                let mint = try ops.newBlock(in: post.id, text: "the ring's block.", at: .end)
                for i in 0..<40 {
                    _ = try ops.newBlock(in: post.id, text: "filler \(i).", at: .end)
                }
                return (post.id, mint.block.id, mint.variant.id)
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.post) })

            model.focus(blockID: world.first, variantID: world.firstTake)
            #expect(model.authority.livePane?.blockID == world.first)

            // Scroll far away: the culled set loses the card, the
            // exemption keeps it realized (the ring never dies by
            // scrolling).
            model.noteVisibleRect(CGRect(x: 50_000, y: 50_000, width: 1200, height: 800))
            #expect(!model.realizedIDs.contains(world.first),
                    "the culled set left the card behind")
            #expect(model.realizedCards.contains { $0.block.blockID == world.first },
                    "the LIVE pane's card is exempt from derealization")

            model.blur()
            #expect(!model.realizedCards.contains { $0.block.blockID == world.first },
                    "blurred, the card derealizes like any other")
        }
    }

    /// S4-7c: edits land on the take the card DISPLAYS (the R88 view-local
    /// pick) through the per-post autosave; chosen never moves (R88).
    @Test func paneEditsLandOnTheDisplayedTakeThroughAutosave() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (post: String, block: String, t1: String, t2: String) in
                let post = try ops.createPost(title: "editable", profile: .generic)
                let mint = try ops.newBlock(in: post.id, text: "take one", at: .end)
                let t2 = try ops.branchVariant(mint.block.id, from: mint.variant.id)
                try ops.autosave(t2.id, text: "take two", charDelta: 4)
                return (post.id, mint.block.id, mint.variant.id, t2.id)
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.post) })

            // View t2 (never chosen — R88), focus its pane, type.
            model.switchTake(blockID: world.block, delta: 1)
            let item = model.projection.cards.first { $0.block.blockID == world.block }!
            let resolved = try #require(model.resolvedCard(item: item))
            #expect(resolved.variantID == world.t2, "the card resolves its view pick")
            model.focus(blockID: world.block, variantID: resolved.variantID)
            #expect(model.isPaneLive(blockID: world.block, variantID: world.t2))
            model.paneEdited(
                blockID: world.block, variantID: world.t2, newText: "take two, typed on the canvas")
            // Buffer-authoritative while pending.
            #expect(model.resolvedCard(item: item)?.text == "take two, typed on the canvas")

            await session.autosave(forPost: world.post).flushNow()
            let stored = try await db.read { [t2 = world.t2] db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [t2])
            }
            #expect(stored == "take two, typed on the canvas",
                    "the edit landed on the DISPLAYED take")
            let chosen = try await db.read { [post = world.post, block = world.block] db in
                try Queries.renderPost(db, containerID: post)
                    .first { $0.blockID == block }?.variantID
            }
            #expect(chosen == world.t1, "chosen never moved — R88 stands untouched")
        }
    }

    /// #18 ratified + S4-7c's seal half: arrangement stays allowed under
    /// seal; liveness and edits refuse (the ops layer speaks).
    @Test func sealKeepsArrangementAndRefusesEditsSpoken() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (post: String, block: String, take: String) in
                let post = try ops.createPost(title: "sealed", profile: .generic)
                let mint = try ops.newBlock(in: post.id, text: "sealed prose.", at: .end)
                try ops.lockPost(post.id)
                return (post.id, mint.block.id, mint.variant.id)
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(CanvasFace(
                projection: try await db.read { try Queries.canvasProjection($0, container: world.post) },
                sealed: true))

            // Liveness refuses through the authority's sealed gate.
            model.focus(blockID: world.block, variantID: world.take)
            #expect(!model.isPaneLive(blockID: world.block, variantID: world.take),
                    "a sealed post has no live pane (viewing isn't authoring)")

            // Arrangement stays allowed (#18): the drag writes its row.
            await model.dragEnded(blockID: world.block, translation: CGSize(width: 60, height: 40))
            #expect(try await db.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM canvas_layout WHERE deleted_at IS NULL")
            } == 1, "canvas positions allow under seal — #18's ratified letter")

            // An edit that reaches the pipeline refuses at the ops layer,
            // spoken (fire-and-DO's refusal half).
            model.paneEdited(
                blockID: world.block, variantID: world.take, newText: "sealed prose, edited.")
            await session.autosave(forPost: world.post).flushNow()
            #expect(model.statusMessage?.contains("sealed") == true,
                    "the seal's refusal speaks")
        }
    }

    /// S4-7d built to the ruling's (b): size is LOCAL view memory — the
    /// store never learns it (no size home exists on canvas_layout).
    @Test func cardSizePersistsLocallyNeverInTheStore() async throws {
        try await withWorld { session, db in
            let (poolID, blockID) = try await session.runner.run { ops -> (String, String) in
                let pool = try ops.createPool(title: "sized")
                let block = try ops.newBlock(in: pool.id, text: "resize me", at: .end).block
                return (pool.id, block.id)
            }
            let memoryKey = "canvasSizeMemory.\(poolID)"
            UserDefaults.standard.removeObject(forKey: memoryKey)
            defer { UserDefaults.standard.removeObject(forKey: memoryKey) }

            let model = CanvasViewModel(session: session, containerID: poolID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: poolID) })

            #expect(model.cardSize(blockID: blockID) == CanvasBoardGeometry.defaultCardSize)
            model.resizeEnded(blockID: blockID, translation: CGSize(width: 100, height: 60))
            let grown = model.cardSize(blockID: blockID)
            #expect(grown == CGSize(
                width: CanvasBoardGeometry.defaultCardSize.width + 100,
                height: CanvasBoardGeometry.defaultCardSize.height + 60))

            // Local memory has it; the store does NOT.
            #expect(UserDefaults.standard.dictionary(forKey: memoryKey) != nil,
                    "size persists in the view-memory class (the ruling's (b))")
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM canvas_layout")
            } == 0, "the store never learns a size — no schema home exists this batch")

            // A fresh model reloads it; reset clears it.
            let second = CanvasViewModel(session: session, containerID: poolID)
            second.loadViewMemory()
            #expect(second.cardSize(blockID: blockID) == grown)
            second.resetSize(blockID: blockID)
            #expect(second.cardSize(blockID: blockID) == CanvasBoardGeometry.defaultCardSize)

            // Clamps hold at the grip.
            model.resizeEnded(blockID: blockID, translation: CGSize(width: -10_000, height: -10_000))
            #expect(model.cardSize(blockID: blockID) == CanvasBoardGeometry.minCardSize)
        }
    }

    /// 4E: the ring follows the card across a ‹ › step — what the card
    /// shows is what you edit.
    @Test func theRingFollowsTheCardAcrossATakeStep() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (post: String, block: String, t1: String, t2: String) in
                let post = try ops.createPost(title: "stepping", profile: .generic)
                let mint = try ops.newBlock(in: post.id, text: "take one", at: .end)
                let t2 = try ops.branchVariant(mint.block.id, from: mint.variant.id)
                try ops.autosave(t2.id, text: "take two", charDelta: 4)
                return (post.id, mint.block.id, mint.variant.id, t2.id)
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.post) })

            model.focus(blockID: world.block, variantID: world.t1)
            #expect(model.authority.livePane?.variantID == world.t1)
            model.switchTake(blockID: world.block, delta: 1)
            #expect(model.authority.livePane?.variantID == world.t2,
                    "the live ring follows the card onto the newly displayed take")
        }
    }

    /// The ruling's (c)(2): ⌘S in canvas commits the LIVE pane's take
    /// (the 4D compare precedent, third surface); no focus speaks.
    @Test func commitFocusedTakeCommitsTheLiveCanvasTake() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (post: String, block: String, take: String) in
                let post = try ops.createPost(title: "committed", profile: .generic)
                let mint = try ops.newBlock(in: post.id, text: "canvas prose.", at: .end)
                return (post.id, mint.block.id, mint.variant.id)
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.post) })

            // No focus: speaks instead of guessing (the 4D letter).
            await model.commitFocusedTake()
            #expect(model.statusMessage?.contains("Click into a card") == true)

            model.focus(blockID: world.block, variantID: world.take)
            model.paneEdited(
                blockID: world.block, variantID: world.take, newText: "canvas prose, typed.")
            await model.commitFocusedTake()
            let committed = try await db.read { [take = world.take] db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT text FROM commit_point WHERE variant_id = ?
                        ORDER BY created_at DESC LIMIT 1
                        """,
                    arguments: [take])
            }
            #expect(committed == "canvas prose, typed.",
                    "⌘S committed the live pane's flushed text")
        }
    }
}

/// The 4E realization pin, HOSTED half (the ReadingFlow DEBUG-counter
/// precedent): the REAL mounted CanvasView on a 300-card post realizes a
/// bounded set — the hierarchy carries a bounded number of panes and the
/// materialization counter stays far under the card count.
/// RED-ON-OLD (behavioral revert procedure): replace the board's
/// `ForEach(model.realizedCards…)` with `ForEach(model.visibleCards…)` —
/// the pre-4E eager shape — and BOTH expectations fail (300 panes in the
/// hierarchy; the counter ≥ 300 on the first render pass alone).
@Suite("Canvas realization, hosted (13b 4E)", .serialized)
@MainActor
struct CanvasHostedRealizationTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 3) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(15))
        }
    }

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    @Test func aMountedLongPostRealizesABoundedCardSet() async throws {
        try await withWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "the long canvas", profile: .generic)
                for i in 0..<300 {
                    _ = try ops.newBlock(in: post.id, text: "card \(i) prose.", at: .end)
                }
                return post.id
            }
            // Defaults hygiene (the 4G rule): this world's deterministic
            // IDs recur across runs — clean the view-memory keys the
            // view's loadViewMemory would read.
            UserDefaults.standard.removeObject(forKey: "canvasViewMemory.\(postID)")
            UserDefaults.standard.removeObject(forKey: "canvasSizeMemory.\(postID)")

            let model = CanvasViewModel(session: session, containerID: postID)
            CanvasCardMaterialization.count = 0
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 800, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: CanvasView(
                session: session, containerID: postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<60 where model.projection.cards.count < 300 {
                await settle(window, hosting, turns: 1)
            }
            #expect(model.projection.cards.count == 300, "the board mounted")
            await settle(window, hosting)

            // The model's culled set is viewport-bounded...
            #expect(model.realizedCards.count < 80,
                    "realized \(model.realizedCards.count) of 300 — viewport-bounded (P1)")
            // ...the HIERARCHY carries exactly that many panes (the
            // ForEach really renders the culled set)...
            let paneCount = panes(in: hosting).count
            #expect(paneCount <= model.realizedCards.count,
                    "hierarchy panes \(paneCount) ≤ realized \(model.realizedCards.count)")
            #expect(paneCount > 0, "the viewport's cards really did realize")
            // ...and the materialization counter stays far under the
            // eager shape's floor (300 on its first pass).
            #expect(CanvasCardMaterialization.count < 300,
                    "materializations \(CanvasCardMaterialization.count) — the eager mount is dead")
        }
    }
}

/// S4-7f (click-in-order) + S4-7g (fit-all) — the ONE spatial→structural
/// door and the read-only overview.
@Suite("Click-in-order & fit-all (13b 4E — S4-7f/g)")
@MainActor
struct CanvasOrderAndOverviewTests {
    @Test func clickInOrderAppliesOneCompoundAndUndoRestores() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (post: String, blocks: [String]) in
                let post = try ops.createPost(title: "ordered", profile: .generic)
                var blocks: [String] = []
                for i in 1...4 {
                    blocks.append(try ops.newBlock(in: post.id, text: "block \(i).", at: .end).block.id)
                }
                return (post.id, blocks)
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.post) })
            let b = world.blocks

            model.enterOrderMode()
            #expect(model.orderMode)
            model.toggleOrderClick(blockID: b[2])
            model.toggleOrderClick(blockID: b[0])
            #expect(model.pendingOrderNumber(blockID: b[2]) == 1, "the numbered preview")
            #expect(model.pendingOrderNumber(blockID: b[0]) == 2)
            #expect(model.pendingOrderNumber(blockID: b[1]) == nil)
            #expect(model.currentOrdinal(blockID: b[1]) == 2,
                    "unclicked cards keep the read-time ordinal")

            await model.applyOrder()
            #expect(!model.orderMode, "apply closes the mode")
            let after = try await db.read { [post = world.post] db in
                try Queries.renderPost(db, containerID: post).map(\.blockID)
            }
            #expect(after == [b[2], b[0], b[1], b[3]],
                    "clicked prefix in click order; unclicked keep relative order after it")

            // ONE compound: a single ⌥⌘Z restores the old order whole.
            #expect(session.undoStack.topLabel == "Order Blocks")
            let undoStack = session.undoStack
            _ = try await session.runner.run { ops in
                try undoStack.undo(with: ops)
            }
            let restored = try await db.read { [post = world.post] db in
                try Queries.renderPost(db, containerID: post).map(\.blockID)
            }
            #expect(restored == b, "one undo restores the pre-order arrangement")
        }
    }

    @Test func cancelIsInertAndTogglingUnnumbers() async throws {
        try await withWorld { session, db in
            let world = try await session.runner.run { ops -> (post: String, blocks: [String]) in
                let post = try ops.createPost(title: "cancelled", profile: .generic)
                var blocks: [String] = []
                for i in 1...3 {
                    blocks.append(try ops.newBlock(in: post.id, text: "block \(i).", at: .end).block.id)
                }
                return (post.id, blocks)
            }
            let model = CanvasViewModel(session: session, containerID: world.post)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: world.post) })
            let before = try await db.read { [post = world.post] db in
                try Queries.renderPost(db, containerID: post).map { "\($0.blockID)|\($0.position)" }
            }

            model.enterOrderMode()
            model.toggleOrderClick(blockID: world.blocks[1])
            model.toggleOrderClick(blockID: world.blocks[2])
            // Clicking a numbered card again unnumbers it; the rest close up.
            model.toggleOrderClick(blockID: world.blocks[1])
            #expect(model.pendingOrderNumber(blockID: world.blocks[1]) == nil)
            #expect(model.pendingOrderNumber(blockID: world.blocks[2]) == 1, "renumbered")

            model.cancelOrderMode()
            #expect(!model.orderMode)
            let after = try await db.read { [post = world.post] db in
                try Queries.renderPost(db, containerID: post).map { "\($0.blockID)|\($0.position)" }
            }
            #expect(after == before, "cancel is INERT — no op ran, no position moved")
            #expect(session.undoStack.topLabel != "Order Blocks", "no undo entry either")
        }
    }

    @Test func orderModeRefusesUnderSealAtTheDoor() async throws {
        try await withWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "sealed order", profile: .generic)
                _ = try ops.newBlock(in: post.id, text: "frozen.", at: .end)
                try ops.lockPost(post.id)
                return post.id
            }
            let model = CanvasViewModel(session: session, containerID: postID)
            model.adopt(CanvasFace(
                projection: try await db.read { try Queries.canvasProjection($0, container: postID) },
                sealed: true))

            model.enterOrderMode()
            #expect(!model.orderMode, "the door refuses under seal")
            #expect(model.statusMessage?.contains("sealed") == true,
                    "and says so (the reorder op would refuse at apply — said at the entrance)")
        }
    }

    @Test func fitAllScrollsSmallBoardsAndOverviewsLargeOnes() async throws {
        try await withWorld { session, db in
            let (smallID, largeID) = try await session.runner.run { ops -> (String, String) in
                let small = try ops.createPost(title: "small", profile: .generic)
                _ = try ops.newBlock(in: small.id, text: "one.", at: .end)
                _ = try ops.newBlock(in: small.id, text: "two.", at: .end)
                let large = try ops.createPost(title: "large", profile: .generic)
                for i in 0..<60 {
                    _ = try ops.newBlock(in: large.id, text: "card \(i).", at: .end)
                }
                return (small.id, large.id)
            }
            let viewport = CGSize(width: 1200, height: 800)

            let small = CanvasViewModel(session: session, containerID: smallID)
            small.adopt(try await db.read { try Queries.canvasProjection($0, container: smallID) })
            guard case .scroll = small.fitAll(viewport: viewport) else {
                Issue.record("a two-card board fits at 1:1 — fit-all just scrolls")
                return
            }
            #expect(!small.overviewActive)

            let large = CanvasViewModel(session: session, containerID: largeID)
            large.adopt(try await db.read { try Queries.canvasProjection($0, container: largeID) })
            guard case .overview(let scale) = large.fitAll(viewport: viewport) else {
                Issue.record("a 60-card spread exceeds the viewport — the overview engages")
                return
            }
            #expect(scale < 1 && scale >= CanvasBoardGeometry.overviewScaleFloor)
            #expect(large.overviewActive)
            #expect(large.authority.livePane == nil,
                    "the overview is read-only — entering blurs (the α rider)")

            // A plain overview click returns to 1:1 centered on the card.
            let target = large.projection.cards[5].block.blockID
            let center = large.overviewClicked(blockID: target)
            #expect(center != nil)
            #expect(!large.overviewActive, "the click left the overview")

            // The γ rider: while ordering, overview clicks assign numbers
            // instead of returning.
            _ = large.fitAll(viewport: viewport)
            large.enterOrderMode()
            _ = large.fitAll(viewport: viewport)  // order mode survives fit-all
            #expect(large.overviewClicked(blockID: target) == nil,
                    "an ordering click stays in the overview")
            #expect(large.pendingOrderNumber(blockID: target) == 1,
                    "and assigned the sequence number (γ)")
            large.exitOverview()
            large.cancelOrderMode()
        }
    }
}
