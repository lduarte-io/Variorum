//
//  CanvasBankTests.swift
//  VariorumTests
//
//  Phase 13e, batch 5 — E7's canvas BANK (her sitting Round 2 pick; the
//  4E fork recorded verbatim in the 13b plan: *"the BANK returns as a
//  future FACE on top of culling (a listing of never-positioned cards;
//  culling is needed under it anyway)"*, her own S4-7a alternative being
//  *"an explicit drag-in from a scrollable bank of posts when there are
//  many"*).
//
//  The shape needs NO schema: a card the store has no `canvas_layout` row
//  for IS a banked card, dragging one out writes its FIRST position
//  (`setCanvasPosition`), dropping a placed card back clears it
//  (`removeCanvasPosition`) — the standing 11a ops, unchanged.
//
//  The two things these pins hold onto hardest:
//  1. CLOSED (the default), the board is byte-for-byte 4E's — spread grid
//     included. That is what keeps 4E's rejection of the bank MODEL true:
//     a never-arranged post still opens to its cards, never to an empty
//     board.
//  2. The bank is inside the same culling, not outside it: chips realize
//     lazily, and a fully-banked 300-card canvas renders a window of both.
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
private func withBankWorld<T>(
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

@MainActor
private func freshModel(
    session: AppSession, containerID: String, db: AppDatabase
) async throws -> CanvasViewModel {
    UserDefaults.standard.removeObject(forKey: "canvasViewMemory.\(containerID)")
    UserDefaults.standard.removeObject(forKey: "canvasSizeMemory.\(containerID)")
    UserDefaults.standard.removeObject(forKey: "canvasBankOpen.\(containerID)")
    let model = CanvasViewModel(session: session, containerID: containerID)
    model.loadViewMemory()
    model.adopt(try await db.read { try Queries.canvasProjection($0, container: containerID) })
    return model
}

@Suite("Canvas bank — membership & the board it leaves alone (13e E7)")
@MainActor
struct CanvasBankMembershipTests {
    @Test func theBankHoldsExactlyTheCardsTheStoreHasNoPositionFor() async throws {
        try await withBankWorld { session, db in
            let (poolID, placed, unplaced) = try await session.runner.run {
                ops -> (String, String, [String]) in
                let pool = try ops.createPool(title: "board")
                let first = try ops.newBlock(in: pool.id, text: "placed", at: .end).block
                let second = try ops.newBlock(in: pool.id, text: "waiting one", at: .end).block
                let third = try ops.newBlock(in: pool.id, text: "waiting two", at: .end).block
                _ = try ops.setCanvasPosition(container: pool.id, block: first.id, x: 300, y: 120)
                return (pool.id, first.id, [second.id, third.id])
            }
            let model = try await freshModel(session: session, containerID: poolID, db: db)

            #expect(model.bankOpen == false, "the bank starts closed — #61(a)")
            #expect(model.bankCards.map(\.block.blockID) == unplaced)
            #expect(model.boardCards.count == 3,
                    "CLOSED, the board is 4E's byte-for-byte: every card, spread grid and all")

            model.toggleBank()
            #expect(model.boardCards.map(\.block.blockID) == [placed],
                    "OPEN, the never-placed cards are in the strip, not on the board")
            #expect(model.realizedCards.map(\.block.blockID) == [placed])
            #expect(model.cardFrames.keys.sorted() == [placed],
                    "and they shape neither the board's extent nor fit-all's zoom")
            #expect(model.isBanked(blockID: unplaced[0]))
            #expect(model.isBanked(blockID: placed) == false)

            model.toggleBank()
            #expect(model.boardCards.count == 3, "closing puts them back on the board")
        }
    }

    @Test func placingFromTheBankWritesOneRowAndReturningClearsIt() async throws {
        try await withBankWorld { session, db in
            let (poolID, blockID) = try await session.runner.run { ops -> (String, String) in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "waiting", at: .end).block
                return (pool.id, block.id)
            }
            let model = try await freshModel(session: session, containerID: poolID, db: db)
            model.toggleBank()
            #expect(model.bankCards.count == 1)

            await model.placeFromBank(blockID: blockID, at: CGPoint(x: 412, y: -88))
            #expect(model.statusMessage == nil)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: poolID) })
            let rows = try await db.read { db in
                try Row.fetchAll(db, sql: "SELECT x, y FROM canvas_layout WHERE deleted_at IS NULL")
                    .map(CopiedRow.init)
            }
            #expect(rows.count == 1, "one drag out of the bank, one layout row")
            let x: Double? = rows.first?["x"]
            let y: Double? = rows.first?["y"]
            #expect(x == 412)
            #expect(y == -88, "negative coordinates stay legal — movement is FREE (Sitting 9)")
            #expect(model.bankCards.isEmpty, "the placed card left the bank")
            #expect(model.boardCards.count == 1)

            await model.returnToBank(blockID: blockID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: poolID) })
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM canvas_layout WHERE deleted_at IS NULL")
            } == 0, "returning tombstones the position row — the standing 11a op")
            #expect(model.bankCards.map(\.block.blockID) == [blockID])
        }
    }

    /// A card already in the bank is a NO-OP, not a refusal: the gesture
    /// means "be in the bank", and it is. (`removeCanvasPosition` would
    /// throw `canvasPositionNotFound` — a true sentence about rows and a
    /// false one about what she did.)
    @Test func returningACardThatIsAlreadyBankedSaysNothingAndWritesNothing() async throws {
        try await withBankWorld { session, db in
            let (poolID, blockID) = try await session.runner.run { ops -> (String, String) in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "waiting", at: .end).block
                return (pool.id, block.id)
            }
            let model = try await freshModel(session: session, containerID: poolID, db: db)
            model.toggleBank()
            model.dragOffsets[blockID] = CGSize(width: 40, height: 40)

            await model.returnToBank(blockID: blockID)

            #expect(model.statusMessage == nil, "no refusal is spoken")
            #expect(model.dragOffsets[blockID] == .zero, "the in-flight drag is released")
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM canvas_layout")
            } == 0, "no row was written, live or tombstoned")
        }
    }

    /// The 4E rejection's second reason, answered rather than inherited:
    /// the bank must not strand cards outside click-in-order.
    @Test func clickInOrderStillReachesABankedCard() async throws {
        try await withBankWorld { session, db in
            let (poolID, ids) = try await session.runner.run { ops -> (String, [String]) in
                let pool = try ops.createPool(title: "board")
                let a = try ops.newBlock(in: pool.id, text: "one", at: .end).block
                let b = try ops.newBlock(in: pool.id, text: "two", at: .end).block
                _ = try ops.setCanvasPosition(container: pool.id, block: a.id, x: 40, y: 40)
                return (pool.id, [a.id, b.id])
            }
            let model = try await freshModel(session: session, containerID: poolID, db: db)
            model.toggleBank()
            model.enterOrderMode()

            model.toggleOrderClick(blockID: ids[1])  // the BANKED card
            model.toggleOrderClick(blockID: ids[0])  // the placed one

            #expect(model.pendingOrderNumber(blockID: ids[1]) == 1)
            #expect(model.pendingOrderNumber(blockID: ids[0]) == 2)
            await model.applyOrder()
            #expect(model.statusMessage?.hasPrefix("Ordered") == true)
            let order = try await db.read { db in
                try Queries.renderPost(db, containerID: poolID).map(\.blockID)
            }
            #expect(order == [ids[1], ids[0]], "the banked card really led the note")
        }
    }
}

@Suite("Canvas bank — the drop decision (13e E7)")
@MainActor
struct CanvasBankDropTests {
    private func model(_ session: AppSession, _ containerID: String) -> CanvasViewModel {
        CanvasViewModel(session: session, containerID: containerID)
    }

    @Test func aDropIsReadAgainstTheStripFirstThenTheBoard() async throws {
        try await withBankWorld { session, db in
            let poolID = try await session.runner.run { ops -> String in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
                // Placed, so the board has a bounding box for fit-all below.
                _ = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 60, y: 60)
                return pool.id
            }
            let model = try await freshModel(session: session, containerID: poolID, db: db)
            model.noteBoardViewport(CGRect(x: 0, y: 30, width: 900, height: 500))
            model.noteBankRect(CGRect(x: 0, y: 530, width: 900, height: 96))
            model.noteVisibleRect(CGRect(x: -40, y: -40, width: 900, height: 500))

            // Over the board: the surface point becomes a STORED coordinate
            // through the same visible rect the culler reads.
            #expect(model.dropTarget(atSurface: CGPoint(x: 100, y: 130))
                    == .board(CGPoint(x: 60, y: 60)))
            // Over the strip, with the bank CLOSED: the strip isn't there,
            // and the point is outside the board's viewport.
            #expect(model.dropTarget(atSurface: CGPoint(x: 100, y: 560)) == .nowhere)
            // Over the strip with the bank OPEN: unplace.
            model.toggleBank()
            #expect(model.dropTarget(atSurface: CGPoint(x: 100, y: 560)) == .bank)
            // The top strip is neither.
            #expect(model.dropTarget(atSurface: CGPoint(x: 100, y: 10)) == .nowhere)
            // And the OVERVIEW is arrange-inert (4E's α rider): a drop onto
            // a zoomed-out board places nothing, while the strip still
            // answers for itself.
            _ = model.fitAll(viewport: CGSize(width: 200, height: 120))
            #expect(model.overviewActive)
            #expect(model.dropTarget(atSurface: CGPoint(x: 100, y: 130)) == .nowhere)
            #expect(model.dropTarget(atSurface: CGPoint(x: 100, y: 560)) == .bank)
        }
    }

    /// Before any scroll geometry lands, the board's own origin stands in —
    /// so a drop in the first moments still lands where it was dropped.
    @Test func withNoScrollReportYetTheBoardOriginStandsIn() async throws {
        try await withBankWorld { session, db in
            let poolID = try await session.runner.run { ops -> String in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "far left", at: .end).block
                _ = try ops.setCanvasPosition(container: pool.id, block: block.id, x: -300, y: -200)
                return pool.id
            }
            let model = try await freshModel(session: session, containerID: poolID, db: db)
            model.noteBoardViewport(CGRect(x: 0, y: 30, width: 900, height: 500))

            #expect(model.visibleRect.isEmpty)
            #expect(model.boardOrigin == CGPoint(x: -320, y: -220))
            #expect(model.dropTarget(atSurface: CGPoint(x: 50, y: 80))
                    == .board(CGPoint(x: -270, y: -170)))
        }
    }
}

@Suite("Canvas bank, hosted (13e E7)", .serialized)
@MainActor
struct CanvasBankHostedTests {
    /// The brief's bounded-realization rule, measured: with EVERY card
    /// banked, neither half renders the corpus — the board realizes
    /// nothing (there is nothing placed) and the strip's `LazyHStack`
    /// realizes a window of chips.
    @Test func aFullyBankedCanvasRealizesAWindowNotTheCorpus() async throws {
        try await withBankWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "the long canvas", profile: .generic)
                for i in 0..<300 {
                    _ = try ops.newBlock(in: post.id, text: "card \(i) prose.", at: .end)
                }
                return post.id
            }
            UserDefaults.standard.removeObject(forKey: "canvasViewMemory.\(postID)")
            UserDefaults.standard.removeObject(forKey: "canvasSizeMemory.\(postID)")
            UserDefaults.standard.set(true, forKey: "canvasBankOpen.\(postID)")
            defer { UserDefaults.standard.removeObject(forKey: "canvasBankOpen.\(postID)") }

            CanvasCardMaterialization.count = 0
            CanvasBankChipMaterialization.count = 0
            let rig = await CanvasDragRig.mount(session: session, containerID: postID, cards: 300)
            defer { rig.close() }

            #expect(rig.model.projection.cards.count == 300, "the board mounted")
            #expect(rig.model.bankOpen, "the bank opened from its remembered state")
            #expect(rig.model.bankCards.count == 300, "nothing is placed, so everything is banked")
            #expect(rig.model.realizedCards.isEmpty, "the board draws nothing — it holds nothing")
            #expect(CanvasBankChipMaterialization.count < 300,
                    "chips realized \(CanvasBankChipMaterialization.count) of 300 — a window (P1)")
            #expect(CanvasBankChipMaterialization.count > 0, "the visible chips really did realize")
        }
    }

    /// The gesture end to end, through SwiftUI's own machinery: drag a chip
    /// out of the strip onto the board and the card lands where it was
    /// dropped — one row, at the board coordinate under the pointer.
    @Test func draggingAChipOntoTheBoardPlacesItWhereItWasDropped() async throws {
        try await withBankWorld { session, db in
            let (poolID, blockID) = try await session.runner.run { ops -> (String, String) in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "waiting card", at: .end).block
                return (pool.id, block.id)
            }
            UserDefaults.standard.set(true, forKey: "canvasBankOpen.\(poolID)")
            defer { UserDefaults.standard.removeObject(forKey: "canvasBankOpen.\(poolID)") }
            let rig = await CanvasDragRig.mount(session: session, containerID: poolID, cards: 1)
            defer { rig.close() }
            #expect(rig.model.bankOpen)
            #expect(rig.model.bankCards.count == 1)

            // The first chip's centre, in the surface space the strip
            // reported for itself — then into window coordinates.
            let strip = rig.model.bankRect
            #expect(strip.width > 0, "the strip reported its frame")
            let chip = CGPoint(x: strip.minX + 81, y: strip.minY + 52)
            let start = rig.windowPointFromSurface(chip)
            let drop = CGPoint(x: start.x + 220, y: start.y + 260)  // up and right, onto the board
            // The expectation is read BEFORE the drop, against the state
            // the gesture itself will read (placing a card moves the
            // board's origin, so reading it afterwards would compare
            // against a board that the drop had already changed).
            let expected = rig.model.dropTarget(
                atSurface: rig.surfacePointFromWindow(drop))

            // 13j batch 6 — the rig hardening: the sequence runs through the
            // rig's own polling `drag`, and the OUTCOME is polled for rather
            // than assumed after three settle turns. The chip's in-flight
            // state is `CanvasView`'s `@State bankDrag`, invisible from here
            // (product code is untouched by the ruling), so this drag has no
            // gesture-start condition to wait on — the placement it writes
            // is the condition instead.
            await rig.drag(
                from: start, dx: drop.x - start.x, dy: start.y - drop.y, steps: 4,
                midDrag: {})
            await rig.poll(until: { rig.model.bankCards.isEmpty })

            let rows = try await db.read { db in
                try Row.fetchAll(db, sql: "SELECT x, y FROM canvas_layout WHERE deleted_at IS NULL")
                    .map(CopiedRow.init)
            }
            #expect(rows.count == 1, "the drag out of the bank wrote exactly one position")
            guard case .board(let point) = expected else {
                Issue.record("the drop point should read as the board, got \(expected)")
                return
            }
            let x: Double? = rows.first?["x"]
            let y: Double? = rows.first?["y"]
            #expect(x == Double(point.x))
            #expect(y == Double(point.y))
            #expect(rig.model.bankCards.isEmpty, "and the card left the strip")
        }
    }

    /// …and back: a placed card dropped ON the strip unplaces itself.
    @Test func droppingACardOnTheStripReturnsItToTheBank() async throws {
        try await withBankWorld { session, db in
            let (poolID, blockID) = try await session.runner.run { ops -> (String, String) in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "placed card", at: .end).block
                _ = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 40, y: 40)
                return (pool.id, block.id)
            }
            UserDefaults.standard.set(true, forKey: "canvasBankOpen.\(poolID)")
            defer { UserDefaults.standard.removeObject(forKey: "canvasBankOpen.\(poolID)") }
            let rig = await CanvasDragRig.mount(session: session, containerID: poolID, cards: 1)
            defer { rig.close() }
            #expect(rig.model.bankCards.isEmpty, "it starts placed")

            let card = rig.cardOrigin(blockID: blockID)
            let header = try #require(rig.windowPoint(boardX: card.x + 120, boardY: card.y + 17))
            let strip = rig.model.bankRect
            let target = rig.windowPointFromSurface(
                CGPoint(x: strip.midX, y: strip.midY))

            // 13j batch 6 — the rig hardening: this one IS a card-header
            // drag, so it has a real gesture-start condition to poll for
            // (`dragOffsets`, written by the gesture's own `onChanged`), and
            // the unplacement it commits is polled for after the drop.
            await rig.drag(
                from: header, dx: target.x - header.x, dy: header.y - target.y, steps: 4,
                started: { rig.model.dragOffsets[blockID] != nil },
                midDrag: {})
            await rig.poll(until: { !rig.model.bankCards.isEmpty })

            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM canvas_layout WHERE deleted_at IS NULL")
            } == 0, "the card's position row tombstoned — it is parked again")
            #expect(rig.model.bankCards.map(\.block.blockID) == [blockID])
        }
    }
}
