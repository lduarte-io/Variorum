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

    /// Rider 1, the slot-swap arm: replacing the column a follow is parked in
    /// with one that does not show the parked take ends the park.
    @Test func aSlotSwapDropsAFollowParkedInItsColumn() async throws {
        try await withParkWorld("swap") { _, _, world, model in
            let columnID = try scratchWithRing(model, world)
            await model.stepTakes(by: 1)
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            #expect(model.parkedFollow == parked)
            model.replaceColumnWithChosen(columnID)
            #expect(model.parkedFollow == nil, "the Chosen column never shows B — the park is over")
            model.paneRendered(parked)
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

// MARK: - The follow gap's own chords (the fable ladder round 1 — the run
// record's FABLE LADDER ROUND 1 section: the MINOR + NIT 1; expected RED on
// the pre-fix tree except the labelled guard)

@MainActor
extension TakesParkedFollowTests {
    /// ONE named-lens column (no choice yet — it shows the chosen take A),
    /// the ring live in its pane on A.
    fileprivate func lensWithRing(
        _ session: AppSession, _ db: AppDatabase, _ world: ParkWorld, _ model: TakesViewModel
    ) async throws -> (columnID: String, lensID: String, ring: TakesViewModel.PaneKey) {
        let lens = try session.operations.createLens(post: world.postID, name: "the gap lens")
        model.replaceColumnWithLens(try #require(model.columns.first).id, lensID: lens.id)
        try await adoptFresh(model, db, world.postID)
        let columnID = try #require(model.columns.first).id
        let ring = TakesViewModel.PaneKey(
            columnID: columnID, blockID: world.blockID, variantID: world.takeA)
        model.focus(ring)
        return (columnID, lens.id, ring)
    }

    /// **THE MINOR (RED ON THE PRE-FIX TREE).** Mid-follow the ring is
    /// PARKED, not gone: a second ⌃⌘→ before the cell's render-report (a
    /// named lens's gap spans a whole store round) steps ON from the parked
    /// take — it must never speak the click-first refusal at her mid-step
    /// (R-VX214-1's own key-repeat ergonomics; the architect's scope ruling).
    @Test func aSecondKeyStepInTheFollowGapStepsOnFromThePark() async throws {
        try await withParkWorld("gapkeys") { session, db, world, model in
            let (columnID, _, _) = try await lensWithRing(session, db, world, model)

            await model.stepTakes(by: 1)   // parks B; the store writes B; no adoption yet
            #expect(model.parkedFollow?.variantID == world.takeB, "fixture: the first step parked B")

            await model.stepTakes(by: 1)   // the gap: ring nil, projection stale
            #expect(model.status?.isRefusal != true,
                    "mid-follow a step is a STEP, never the click-first refusal (status: \(model.statusMessage ?? "nil"))")
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeC)
            #expect(model.parkedFollow == parked, "the second step steps ON from the parked take")

            try await adoptFresh(model, db, world.postID)   // the adoption that brings C
            #expect(model.parkedFollow == parked, "the adoption that brings C keeps the park")
            model.paneRendered(parked)
            #expect(model.authority.livePane == parked, "the follow lands on C")
        }
    }

    /// The scratch twin (the gap is one render — key repeat can still land in
    /// it under load): the second press steps on, never refuses.
    @Test func aSecondKeyStepInTheFollowGapStepsOnFromTheParkOnAScratchColumn() async throws {
        try await withParkWorld("gapscratch") { _, _, world, model in
            let columnID = try scratchWithRing(model, world)
            await model.stepTakes(by: 1)   // parks B; the scratch pick moves synchronously
            #expect(model.parkedFollow?.variantID == world.takeB, "fixture: the first step parked B")

            await model.stepTakes(by: 1)   // before B's render-report
            #expect(model.status?.isRefusal != true,
                    "mid-follow a step is a STEP, never the click-first refusal (status: \(model.statusMessage ?? "nil"))")
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeC)
            #expect(model.parkedFollow == parked, "the second step steps ON from the parked take")
            model.paneRendered(parked)
            #expect(model.authority.livePane == parked)
        }
    }

    /// **The right-then-left dance (RED ON THE PRE-FIX TREE):** stepping back
    /// to the take the cell is STILL SHOWING re-rings it directly — the cell
    /// already renders that take, so the flip is the refused-pick recovery's
    /// own safe read→live move — and the stale park ends with it.
    @Test func aStepBackToTheShownTakeReRingsItDirectlyAndEndsThePark() async throws {
        try await withParkWorld("gapback") { session, db, world, model in
            let (_, lensID, ring) = try await lensWithRing(session, db, world, model)

            await model.stepTakes(by: 1)   // parks B (the cell still shows A)
            #expect(model.parkedFollow?.variantID == world.takeB, "fixture: parked B")
            await model.stepTakes(by: -1)  // back to A, the shown take
            #expect(model.status?.isRefusal != true,
                    "the back-step is a step, never a refusal (status: \(model.statusMessage ?? "nil"))")
            #expect(model.parkedFollow == nil, "no stale park survives the round trip")
            #expect(model.authority.livePane == ring,
                    "the ring is back on A directly — the cell never stopped showing it")
            // The store records the explicit choice the back-step made.
            let choice = try await db.read { [lensID] db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT variant_id FROM lens_choice
                        WHERE lens_id = ? AND block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [lensID, world.blockID])
            }
            #expect(choice == world.takeA, "the back-step's pick landed (lens choice: A)")
        }
    }

    /// **"Show take ▸" mid-gap (RED ON THE PRE-FIX TREE):** a pick while a
    /// follow is parked moves the park WITH the pick — never strands it on
    /// the overtaken key (where the arriving adoption would drop it and the
    /// follow would be lost).
    @Test func aMidGapPickMovesTheParkWithIt() async throws {
        try await withParkWorld("gappick") { session, db, world, model in
            let (columnID, _, _) = try await lensWithRing(session, db, world, model)

            await model.stepTakes(by: 1)   // parks B
            await model.pick(columnID: columnID, blockID: world.blockID, variantID: world.takeC)
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeC)
            #expect(model.parkedFollow == parked, "the park moved with the pick")

            try await adoptFresh(model, db, world.postID)   // C arrives
            #expect(model.parkedFollow == parked)
            model.paneRendered(parked)
            #expect(model.authority.livePane == parked, "the follow lands on C, not nowhere")
        }
    }

    /// GUARD (green on both sides): a REFUSED mid-gap pick restores the
    /// ORIGINAL park — the first follow is still owed.
    @Test func aRefusedMidGapPickRestoresTheOriginalPark() async throws {
        try await withParkWorld("gaprefused") { session, db, world, model in
            let (columnID, _, _) = try await lensWithRing(session, db, world, model)

            await model.stepTakes(by: 1)   // parks B
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            #expect(model.parkedFollow == parked, "fixture: parked B")
            // C is archived in the store, the board not yet told: the pick
            // reaches `setLensChoice`, which refuses an archived take.
            try session.operations.archiveVariant(world.takeC)
            await model.pick(columnID: columnID, blockID: world.blockID, variantID: world.takeC)
            #expect(model.status?.isRefusal == true, "fixture: the op refused")
            #expect(model.parkedFollow == parked, "the original park is restored — B's follow is still owed")

            try await adoptFresh(model, db, world.postID)   // B arrives
            #expect(model.parkedFollow == parked)
            model.paneRendered(parked)
            #expect(model.authority.livePane == parked)
        }
    }

    /// **NIT 1 (RED ON THE PRE-FIX TREE):** the pick's recovery acts on the
    /// run's OWN outcome, never the shared status line — a refusal another
    /// door speaks while the pick's write is in flight must not steal a
    /// SUCCESSFUL pick's follow back to the outgoing pane. The runner is held
    /// by a gate so the interleave is deterministic.
    @Test func anInterleavedRefusalNeverStealsTheParkAfterASuccessfulPick() async throws {
        try await withParkWorld("gapsteal") { session, db, world, model in
            let (columnID, _, _) = try await lensWithRing(session, db, world, model)

            // Hold the runner: the pick's write queues behind this job, so the
            // suspension window is held open until the gate lifts.
            let gate = DispatchSemaphore(value: 0)
            let entered = LockIsolated(false)
            let blocker = Task {
                try? await session.runner.run { _ in
                    entered.setValue(true)
                    gate.wait()
                }
            }
            var turns = 0
            while !entered.value, turns < 4000 { await Task.yield(); turns += 1 }
            #expect(entered.value, "fixture: the runner is held")

            let pickTask = Task {
                await model.pick(
                    columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            }
            turns = 0
            while model.parkedFollow == nil, turns < 4000 { await Task.yield(); turns += 1 }
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            #expect(model.parkedFollow == parked, "fixture: the pick parked B and is awaiting its write")

            // Another door's refusal lands while the pick is suspended.
            model.setRefusal("an interleaved refusal from another door")
            gate.signal()
            await pickTask.value
            _ = await blocker.value

            #expect(model.parkedFollow == parked,
                    "a successful pick keeps its park — the interleaved refusal is not its outcome")
            #expect(model.authority.livePane == nil,
                    "the ring is not stolen back to the outgoing pane")
        }
    }
}

// MARK: - The transit rule (the sanity pass's one issue, confirmed by the
// reviewer — the run record's ladder section; expected RED on the pre-fix
// tree except the labelled guard)

@MainActor
extension TakesParkedFollowTests {
    /// **THE SANITY-PASS ISSUE (RED ON THE PRE-FIX TREE).** A chained step
    /// replaces the park (B → C) while B's own adoption is still in flight;
    /// that adoption — the board's OWN overtaken pick arriving late, fetched
    /// after B's write and before C's — must read as TRANSIT, never as "the
    /// world moved on": the C park holds, and the follow lands when C renders.
    @Test func theOvertakenStepsOwnAdoptionKeepsTheForwardPark() async throws {
        try await withParkWorld("gaptransit") { session, db, world, model in
            let (columnID, _, _) = try await lensWithRing(session, db, world, model)

            await model.stepTakes(by: 1)   // parks B; writes B
            // The overtaken projection: fetched after B's write, before C's.
            let pB = try await db.read { [world] in
                try Queries.takesProjection($0, post: world.postID)
            }
            await model.stepTakes(by: 1)   // mid-gap: parks C; writes C
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeC)
            #expect(model.parkedFollow == parked, "fixture: the chained step parked C")

            model.adopt(pB)                // B's adoption lands late
            #expect(model.parkedFollow == parked,
                    "the overtaken step's own adoption is transit — the forward park holds")
            try await adoptFresh(model, db, world.postID)   // C arrives
            #expect(model.parkedFollow == parked)
            model.paneRendered(parked)
            #expect(model.authority.livePane == parked, "the follow lands on C")
        }
    }

    /// GUARD (green on both sides): transit never blunts rider 1 — an
    /// adoption moving the cell to a take that is NEITHER the park NOR an
    /// overtaken transit take still drops the park (the world really moved).
    @Test func aTrueWorldMoveStillDropsAChainedPark() async throws {
        try await withParkWorld("gaptruemove") { session, db, world, model in
            let (columnID, lensID, _) = try await lensWithRing(session, db, world, model)

            await model.stepTakes(by: 1)   // parks B; writes B
            let pB = try await db.read { [world] in
                try Queries.takesProjection($0, post: world.postID)
            }
            await model.stepTakes(by: 1)   // parks C (transit carries B)
            model.adopt(pB)                // transit: the park holds
            let parked = Key(columnID: columnID, blockID: world.blockID, variantID: world.takeC)
            #expect(model.parkedFollow == parked, "fixture: the chained park survived B's adoption")

            // The world really moves on: an EXTERNAL write picks A (not the
            // park, not transit — the cell currently shows B).
            _ = try session.operations.setLensChoice(
                lens: lensID, block: world.blockID, variant: world.takeA)
            try await adoptFresh(model, db, world.postID)
            #expect(model.parkedFollow == nil, "rider 1 holds: a true world-move drops the park")
            model.paneRendered(parked)
            #expect(model.authority.livePane == nil, "the spent park cannot land")
        }
    }
}
