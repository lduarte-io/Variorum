//
//  TakesParkedFollowTests.swift
//  VariorumTests
//
//  VX-227 — THE PARKED FOLLOW's own rules, as state transitions (the
//  architect's F2 ruling and its three riders, in the run record
//  `notes/plans/fixes/vx-214-settings-launch-polish.md`). The mounted
//  behaviour — the follow landing, the words a pane shows, the keystroke —
//  is `TakesStepFollowTests`; these pin the mechanism the mounted pins rely
//  on, at the model, with the cell's render-report played by hand:
//  - a step under the ring PARKS the follow and leaves the ring NIL — never
//    two live panes, never one on a key no cell renders (rider 2);
//  - only the parked key's own render-report re-binds it;
//  - any intervening focus or blur, and an adoption that re-resolves the
//    parked cell to another take, drop the park; an echo adoption, and the
//    adoption that BRINGS the parked take, keep it (rider 1);
//  - a refused lens pick puts the ring back where she was;
//  - a scratch saved as a lens follows back onto the ring's take once the
//    lens's choices arrive (the transient re-point).
//
//  New mechanism, so these are state-transition pins (the mounted pins carry
//  the red-on-old).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private struct ParkWorld {
    let postID: String
    let blockID: String
    let takeA: String
    let takeB: String
    let takeC: String
    let otherBlockID: String
    let otherVariantID: String

    static func make(_ session: AppSession) throws -> ParkWorld {
        let post = try session.operations.createPost(title: "the park post")
        let minted = try session.operations.newBlock(in: post.id, text: "Take A of the paragraph.")
        let b = try session.operations.branchVariant(minted.block.id, from: minted.variant.id)
        try session.operations.autosave(b.id, text: "Take B, quite different.", charDelta: 12)
        // C branches from B: a branch lands beside its source, so the fan reads A, B, C.
        let c = try session.operations.branchVariant(minted.block.id, from: b.id)
        try session.operations.autosave(c.id, text: "Take C, different again.", charDelta: 12)
        let other = try session.operations.newBlock(in: post.id, text: "A second block.")
        return ParkWorld(
            postID: post.id, blockID: minted.block.id,
            takeA: minted.variant.id, takeB: b.id, takeC: c.id,
            otherBlockID: other.block.id, otherVariantID: other.variant.id)
    }
}

@MainActor
private func withParkWorld<T>(
    _ name: String,
    _ body: @MainActor (AppSession, AppDatabase, ParkWorld, TakesViewModel) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 2271))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let suite = "TakesParkedFollowTests-\(name)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let world = try ParkWorld.make(session)
        let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
        model.host = .lenses
        model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
        defer { model.teardown() }
        return try await body(session, db, world, model)
    }
}

@MainActor
private func adoptFresh(_ model: TakesViewModel, _ db: AppDatabase, _ postID: String) async throws {
    model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
}

@MainActor
@Suite("Takes stepping — the parked follow's rules (VX-227)", .serialized)
struct TakesParkedFollowTests {
    private typealias Key = TakesViewModel.PaneKey

    /// ONE scratch column, the ring in its pane on take A.
    private func scratchWithRing(_ model: TakesViewModel, _ world: ParkWorld) throws -> String {
        model.replaceColumnWithNewScratch(try #require(model.columns.first).id)
        let columnID = try #require(model.columns.first).id
        model.focus(Key(columnID: columnID, blockID: world.blockID, variantID: world.takeA))
        return columnID
    }

    @Test func aStepParksAndOnlyItsOwnRenderReportRebindsTheRing() async throws {
        try await withParkWorld("own") { _, _, world, model in
            let columnID = try scratchWithRing(model, world)
            await model.stepTakes(by: 1)
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            #expect(model.parkedFollow == parked, "the step parks the newly picked take's key")
            #expect(model.authority.livePane == nil,
                    "rider 2: while parked the ring is nil — never two, never stranded")

            // A report for any other key (the cell's old key, another block's
            // cell) moves nothing.
            model.paneRendered(Key(columnID: columnID, blockID: world.blockID, variantID: world.takeA))
            model.paneRendered(Key(
                columnID: columnID, blockID: world.otherBlockID, variantID: world.otherVariantID))
            #expect(model.authority.livePane == nil)
            #expect(model.parkedFollow == parked)

            // The parked key's own report: the ring re-binds, the park is spent.
            model.paneRendered(parked)
            #expect(model.authority.livePane == parked)
            #expect(model.parkedFollow == nil)
            // A late duplicate report is inert.
            model.paneRendered(parked)
            #expect(model.authority.livePane == parked)
        }
    }

    @Test func aFocusOrABlurBeforeTheReportDropsThePark() async throws {
        try await withParkWorld("intervene") { _, _, world, model in
            let columnID = try scratchWithRing(model, world)
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeB)

            await model.stepTakes(by: 1)
            let elsewhere = Key(
                columnID: columnID, blockID: world.otherBlockID, variantID: world.otherVariantID)
            model.focus(elsewhere)   // her click on another block
            #expect(model.parkedFollow == nil, "rider 1: a focus drops the park")
            model.paneRendered(parked)
            #expect(model.authority.livePane == elsewhere, "the stale report never steals the ring back")

            model.focus(Key(columnID: columnID, blockID: world.blockID, variantID: world.takeB))
            await model.stepTakes(by: 1)
            #expect(model.parkedFollow != nil)
            model.blur()
            #expect(model.parkedFollow == nil, "rider 1: a blur drops the park")
            model.paneRendered(Key(columnID: columnID, blockID: world.blockID, variantID: world.takeC))
            #expect(model.authority.livePane == nil)
        }
    }

    /// Rider 1's adoption arm, on a NAMED lens (the pick travels by the store).
    @Test func anAdoptionKeepsTheParkUnlessItMovesTheParkedCellElsewhere() async throws {
        try await withParkWorld("adoption") { session, db, world, model in
            let lens = try session.operations.createLens(post: world.postID, name: "parked")
            model.replaceColumnWithLens(try #require(model.columns.first).id, lensID: lens.id)
            try await adoptFresh(model, db, world.postID)
            let columnID = try #require(model.columns.first).id
            model.focus(Key(columnID: columnID, blockID: world.blockID, variantID: world.takeA))

            await model.stepTakes(by: 1)
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            #expect(model.parkedFollow == parked)
            try await adoptFresh(model, db, world.postID)   // the adoption that BRINGS B
            #expect(model.parkedFollow == parked, "the step's own adoption keeps the park")
            try await adoptFresh(model, db, world.postID)   // an echo
            #expect(model.parkedFollow == parked, "an echo keeps the park")
            try await session.runner.run { [world] ops in
                try ops.autosave(world.otherVariantID, text: "Edited elsewhere.", charDelta: 4)
            }
            try await adoptFresh(model, db, world.postID)   // another block's edit
            #expect(model.parkedFollow == parked, "an unrelated adoption keeps the park")

            // The world moves the lens's pick elsewhere before the cell reported.
            _ = try session.operations.setLensChoice(lens: lens.id, block: world.blockID, variant: world.takeC)
            try await adoptFresh(model, db, world.postID)
            #expect(model.parkedFollow == nil, "rider 1: the parked cell now shows C — the park ends")
            model.paneRendered(parked)
            #expect(model.authority.livePane == nil)
        }
    }

    /// A refused lens pick moved nothing — the ring goes back to the pane she
    /// was in (it never stopped showing her take).
    @Test func aRefusedLensPickPutsTheRingBack() async throws {
        try await withParkWorld("refused") { session, db, world, model in
            let lens = try session.operations.createLens(post: world.postID, name: "refusing")
            model.replaceColumnWithLens(try #require(model.columns.first).id, lensID: lens.id)
            try await adoptFresh(model, db, world.postID)
            let columnID = try #require(model.columns.first).id
            let ring = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeA)
            model.focus(ring)
            // B is archived in the store, the board not yet told: the pick
            // reaches `setLensChoice`, which refuses an archived take.
            try session.operations.archiveVariant(world.takeB)
            await model.pick(columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            #expect(model.status?.isRefusal == true, "fixture: the op refused")
            #expect(model.authority.livePane == ring, "the ring is back where she was")
            #expect(model.parkedFollow == nil)
        }
    }

    /// The transient re-point: a scratch saved as a lens reads the chosen
    /// takes until the lens's choices arrive, then shows B again — the ring
    /// parks on its own key and follows back.
    @Test func aScratchSavedAsALensFollowsBackOntoTheRingsTake() async throws {
        try await withParkWorld("savelens") { _, db, world, model in
            model.replaceColumnWithNewScratch(try #require(model.columns.first).id)
            let columnID = try #require(model.columns.first).id
            await model.pick(columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            let ring = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            model.focus(ring)
            await model.saveScratchAsLens(columnID: columnID, name: "kept")
            #expect(model.authority.livePane == nil, "mid-save the ring is parked, not stranded")
            #expect(model.parkedFollow == ring)
            try await adoptFresh(model, db, world.postID)   // the lens's choices arrive
            #expect(model.parkedFollow == ring)
            model.paneRendered(ring)
            #expect(model.authority.livePane == ring, "the ring follows back onto B")
        }
    }

    /// A mint into a column parks unconditionally (F6): the column's cell
    /// shows the mint only after the pick lands, so the ring waits for it.
    @Test func aMintIntoAColumnParksOnTheMint() async throws {
        try await withParkWorld("mint") { _, db, world, model in
            let columnID = try scratchWithRing(model, world)
            let minted = await model.newBlankTakeRevealed(
                blockID: world.blockID, preferredColumnID: columnID)
            let take = try #require(minted)
            let key = Key(columnID: columnID, blockID: world.blockID, variantID: take.id)
            #expect(model.authority.livePane == nil)
            #expect(model.parkedFollow == key)
            try await adoptFresh(model, db, world.postID)
            model.paneRendered(key)
            #expect(model.authority.livePane == key)
        }
    }
}
