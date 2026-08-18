//
//  FanHandsTests.swift
//  VariorumTests
//
//  Phase 13e, batch 2 — "the fan's hands": E4 (reorder takes, her A19), E15
//  (the board joins the ONE projection-delivery policy) and E3 (⌘-click merge
//  selection in Takes, her A18).
//
//  The pins that carry the batch:
//
//  1. `aDeliveryFetchedBeforeAFlushNeverRegressesTheBoard` and
//     `aStaleDeliveryArrivingCleanIsRefetchedRatherThanAdopted` — E15's
//     red-on-old pair. The board used to adopt observation values directly
//     (its KnownIssues row): a value fetched BEFORE a flush, consumed after
//     it settles, put pre-flush text back on screen with the buffer cleared,
//     and a keystroke in that window flushed stale-based text over the newer
//     store text. Both roads — the settle path and the clean-instant
//     delivery — are pinned.
//  2. `aFannedPairCarriesToWriteForTheCeremony` — E3's canon fence: the ruled
//     merge-ceremony threshold (S4-23(4)) is UNTOUCHED by the new door; a
//     fanned pair reaches the ceremony, and the quick/ceremony default flip
//     stays 13j's row 4b.
//  3. `aGappedSelectionRefusesByNameAndMintsNothing` — merge joins
//     neighbours (AppSpec §9), and the door says so BEFORE anything is minted
//     rather than half-merging and rolling back.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withBoardWorld<T>(
    seedBlocks: [String],
    _ body: @MainActor (BoardWorld) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "13e")
        for text in seedBlocks {
            _ = try session.operations.newBlock(in: post.id, text: text)
        }
        let world = BoardWorld(
            session: session, database: db,
            model: TakesViewModel(session: session, postID: post.id),
            postID: post.id)
        try world.reload()
        return try await body(world)
    }
}

@MainActor
private struct BoardWorld {
    let session: AppSession
    let database: AppDatabase
    let model: TakesViewModel
    let postID: String

    /// The store's truth, adopted by hand (the observation never fires under
    /// the test host).
    func reload() throws {
        model.adopt(try storeProjection())
    }

    func storeProjection() throws -> Queries.TakesProjection {
        try database.read { try Queries.takesProjection($0, post: postID) }
    }

    func storeSlots() throws -> [Queries.RenderedBlock] {
        try database.read { try Queries.renderPost($0, containerID: postID) }
    }

    func fan(of blockID: String) throws -> [Variant] {
        try database.read { try Queries.blockFan($0, blockID: blockID) }
    }

    func focus(blockID: String, variantID: String) {
        model.focus(TakesViewModel.PaneKey(
            columnID: TakesViewModel.takesMainColumnID,
            blockID: blockID, variantID: variantID))
    }
}

@MainActor
private func poll(_ condition: @MainActor () -> Bool, turns: Int = 400) async {
    for _ in 0..<turns {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(5))
    }
}

// MARK: - E15: the board's projection deliveries

@MainActor
@Suite("The board's projection deliveries (13e E15)")
struct BoardDeliveryPolicyTests {
    @Test func aDeliveryFetchedBeforeAFlushNeverRegressesTheBoard() async throws {
        // RED-ON-OLD (the settle road): the old rule HELD the photograph and
        // adopted it at settle, so the board showed pre-flush text with the
        // buffer already cleared.
        try await withBoardWorld(seedBlocks: ["Original."]) { world in
            let slot = try #require(world.model.projection.slots.first)
            let variantID = try #require(slot.variantID)
            let stale = world.model.projection

            world.focus(blockID: slot.blockID, variantID: variantID)
            world.model.paneEdited(variantID: variantID, newText: "Typed while in flight.")
            #expect(world.model.autosave.isDirty)

            world.model.deliver(stale)  // the busy arm: held, not adopted
            #expect(world.model.projection.slots.first?.text == "Original.")

            await world.model.autosave.flushNow()
            await poll { world.model.projection.slots.first?.text == "Typed while in flight." }

            #expect(world.model.projection.slots.first?.text == "Typed while in flight.")
            #expect(try world.storeSlots().first?.text == "Typed while in flight.")
        }
    }

    @Test func aStaleDeliveryArrivingCleanIsRefetchedRatherThanAdopted() async throws {
        // RED-ON-OLD (the clean-instant road): a value fetched before the
        // flush can be CONSUMED after it settles, and the old rule adopted
        // any delivery that arrived clean.
        try await withBoardWorld(seedBlocks: ["Original."]) { world in
            let slot = try #require(world.model.projection.slots.first)
            let variantID = try #require(slot.variantID)
            let stale = world.model.projection

            world.focus(blockID: slot.blockID, variantID: variantID)
            world.model.paneEdited(variantID: variantID, newText: "Newer text.")
            await world.model.autosave.flushNow()
            await poll { !world.model.autosave.isDirty }
            try world.reload()
            #expect(world.model.projection.slots.first?.text == "Newer text.")

            world.model.deliver(stale)
            await poll { world.model.projection.slots.first?.text == "Newer text." }

            #expect(world.model.projection.slots.first?.text == "Newer text.",
                    "a stale photograph never rewrites the board")
        }
    }

    @Test func anIdenticalDeliveryIsAdoptedOnTheSpotWithNoRefetch() async throws {
        // The echo arm: with no live buffer the display IS the projection, so
        // a byte-identical delivery adopts synchronously and nothing is read.
        try await withBoardWorld(seedBlocks: ["Steady."]) { world in
            let same = world.model.projection
            #expect(world.model.displayMatches(same))
            world.model.deliver(same)
            #expect(world.model.projection == same)
        }
    }

    @Test func aDeliveryWhileDirtyStillDefersAndTheSettleReadsTheStore() async throws {
        // The board's standing defer condition is preserved exactly (a dirty
        // buffer is authoritative), and the settle path now reads the store.
        try await withBoardWorld(seedBlocks: ["One.", "Two."]) { world in
            let slot = try #require(world.model.projection.slots.first)
            let variantID = try #require(slot.variantID)
            world.focus(blockID: slot.blockID, variantID: variantID)
            world.model.paneEdited(variantID: variantID, newText: "One, edited.")

            // A REAL external change lands in the store while she types.
            let second = try #require(world.model.projection.slots.last)
            let secondVariant = try #require(second.variantID)
            try await world.session.runner.run { ops in
                try ops.autosave(secondVariant, text: "Two, from elsewhere.", charDelta: 0)
            }
            world.model.deliver(try world.storeProjection())
            #expect(world.model.projection.slots.last?.text == "Two.",
                    "held while the buffer is authoritative")

            await world.model.autosave.flushNow()
            await poll { world.model.projection.slots.last?.text == "Two, from elsewhere." }
            #expect(world.model.projection.slots.first?.text == "One, edited.")
            #expect(world.model.projection.slots.last?.text == "Two, from elsewhere.")
        }
    }
}

// MARK: - E4: reordering takes from the board

@MainActor
@Suite("Reordering takes on the board (13e E4, A19)")
struct FanReorderDoorTests {
    /// A one-block post whose block carries three takes.
    private func fanned(_ world: BoardWorld) async throws -> (blockID: String, takes: [Variant]) {
        let slot = try #require(world.model.projection.slots.first)
        let chosen = try #require(slot.variantID)
        let second = try #require(await world.model.branchTake(blockID: slot.blockID, from: chosen))
        let third = try #require(await world.model.newBlankTake(blockID: slot.blockID))
        try world.reload()
        let first = try #require(try world.fan(of: slot.blockID).first { $0.id == chosen })
        return (slot.blockID, [first, second, third])
    }

    @Test func theCardsArrowMovesTheTakeAndTheFanReorders() async throws {
        try await withBoardWorld(seedBlocks: ["Take one."]) { world in
            let (blockID, takes) = try await fanned(world)
            #expect(try world.fan(of: blockID).map(\.id) == takes.map(\.id))

            await world.model.moveTake(takes[0].id, in: blockID, by: 1)

            #expect(try world.fan(of: blockID).map(\.id)
                == [takes[1].id, takes[0].id, takes[2].id])
            #expect(world.model.statusMessage?.contains("Take moved later") == true)
            // …and the projection carries the new order once it re-reads.
            try world.reload()
            #expect(world.model.projection.fans[blockID]?.map(\.id)
                == [takes[1].id, takes[0].id, takes[2].id])
        }
    }

    @Test func theFirstTakeCannotMoveEarlierAndTheDoorSaysSo() async throws {
        try await withBoardWorld(seedBlocks: ["Take one."]) { world in
            let (blockID, takes) = try await fanned(world)

            await world.model.moveTake(takes[0].id, in: blockID, by: -1)

            #expect(world.model.statusMessage == "This take is already first in the fan.")
            #expect(try world.fan(of: blockID).map(\.id) == takes.map(\.id))
        }
    }

    @Test func theLastTakeCannotMoveLaterAndTheDoorSaysSo() async throws {
        try await withBoardWorld(seedBlocks: ["Take one."]) { world in
            let (blockID, takes) = try await fanned(world)

            await world.model.moveTake(takes[2].id, in: blockID, by: 1)

            #expect(world.model.statusMessage == "This take is already last in the fan.")
            #expect(try world.fan(of: blockID).map(\.id) == takes.map(\.id))
        }
    }

    @Test func aMoveFlushesPendingTextFirst() async throws {
        // 13c R2-6's one-act-one-contract rule on this surface: the act
        // reads the fan from the STORE, so the buffer must land there first.
        try await withBoardWorld(seedBlocks: ["Take one."]) { world in
            let (blockID, takes) = try await fanned(world)
            world.focus(blockID: blockID, variantID: takes[1].id)
            world.model.paneEdited(variantID: takes[1].id, newText: "Second take, edited.")
            #expect(world.model.autosave.isDirty)

            await world.model.moveTake(takes[1].id, in: blockID, by: -1)

            #expect(world.model.autosave.isDirty == false)
            #expect(try world.fan(of: blockID).first { $0.id == takes[1].id }?.workingText
                == "Second take, edited.")
            #expect(try world.fan(of: blockID).map(\.id)
                == [takes[1].id, takes[0].id, takes[2].id])
        }
    }

    @Test func aTakeThatLeftTheFanRefusesInsteadOfMovingBesideTheWrongCard() async throws {
        try await withBoardWorld(seedBlocks: ["Take one."]) { world in
            let (blockID, takes) = try await fanned(world)
            // It leaves the FAN (archived) without leaving the store — the
            // frozen-projection hazard the store read exists for.
            try await world.session.runner.run { ops in
                try ops.archiveVariant(takes[2].id)
            }

            await world.model.moveTake(takes[2].id, in: blockID, by: -1)

            #expect(world.model.statusMessage == "This block's takes changed — try the move again.")
            #expect(try world.fan(of: blockID).map(\.id) == takes.map(\.id))
        }
    }

    @Test func theFanOrderActsAreDeclaredWhereTheCardsAre() {
        for id in [CapabilityID.moveTakeEarlier, .moveTakeLater] {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.doors == [.surface])
            #expect(capability.shortcutLabel == nil, "keyless: no chord was ruled")
            #expect(capability.takesAccess == .native)
            #expect(TakesBoardView.surfaceCapabilities.contains(id))
            #expect(capability.availability(CapabilityContext(mode: .takes)) == .act)
            #expect(capability.availability(
                CapabilityContext(mode: nil, takesBoardAttached: true)) == .act)
            #expect(capability.availability(
                CapabilityContext(mode: .write, writeEditorAttached: true)) == .unavailable)
        }
    }
}

// MARK: - E3: the ⌘-click merge selection

@MainActor
@Suite("⌘-click merge selection in Takes (13e E3, A18)")
struct MergeSelectionTests {
    @Test func theContiguityRuleIsPureAndOrderDriven() {
        let order = ["a", "b", "c", "d"]
        #expect(TakesBoardLayout.isContiguousRun(["b", "c"], in: order))
        #expect(TakesBoardLayout.isContiguousRun(["a", "b", "c"], in: order))
        #expect(TakesBoardLayout.isContiguousRun(["a", "c"], in: order) == false)
        #expect(TakesBoardLayout.isContiguousRun(["a"], in: order))
        #expect(TakesBoardLayout.isContiguousRun([], in: order) == false)
        // A picked block the order doesn't hold can never be a run.
        #expect(TakesBoardLayout.isContiguousRun(["c", "z"], in: order) == false)
    }

    @Test func commandClickingTwoNeighboursMergesThemRightHere() async throws {
        try await withBoardWorld(seedBlocks: ["First half.", "Second half.", "Untouched."]) { world in
            let slots = world.model.projection.slots
            world.model.toggleMergeSelection(slots[0].blockID)
            world.model.toggleMergeSelection(slots[1].blockID)
            #expect(world.model.selectedBlocksInOrder
                == [slots[0].blockID, slots[1].blockID])

            await world.model.mergeSelectedBlocks()

            let after = try world.storeSlots()
            #expect(after.count == 2)
            #expect(after.map(\.text) == ["First half. Second half.", "Untouched."])
            #expect(after[0].blockID != slots[0].blockID, "merge mints a fresh block")
            #expect(world.model.mergeSelection.isEmpty, "the selection did its job")
            #expect(world.session.undoStack.depth == 1)
            #expect(world.session.undoStack.topLabel == "Merge Blocks")
            #expect(world.model.statusMessage?.contains("Merged 2 blocks") == true)
        }
    }

    @Test func severalFanlessBlocksMergeInOneGoUnderOneUndoEntry() async throws {
        // Her A18's second half, literally: "merge several when they have no
        // takes."
        try await withBoardWorld(seedBlocks: ["One.", "Two.", "Three."]) { world in
            for slot in world.model.projection.slots {
                world.model.toggleMergeSelection(slot.blockID)
            }

            await world.model.mergeSelectedBlocks()

            #expect(try world.storeSlots().map(\.text) == ["One. Two. Three."])
            #expect(world.session.undoStack.depth == 1)
            #expect(world.model.statusMessage?.contains("Merged 3 blocks") == true)

            // ONE undo entry puts all three back, whole.
            let stack = world.session.undoStack
            try await world.session.runner.run { ops in
                _ = try stack.undo(with: ops)
            }
            #expect(try world.storeSlots().map(\.text) == ["One.", "Two.", "Three."])
        }
    }

    @Test func aGappedSelectionRefusesByNameAndMintsNothing() async throws {
        try await withBoardWorld(seedBlocks: ["One.", "Two.", "Three."]) { world in
            let slots = world.model.projection.slots
            world.model.toggleMergeSelection(slots[0].blockID)
            world.model.toggleMergeSelection(slots[2].blockID)

            await world.model.mergeSelectedBlocks()

            let untouched = try world.storeSlots().map(\.text)
            #expect(world.model.statusMessage?.contains("aren't next to each other") == true)
            #expect(untouched == ["One.", "Two.", "Three."])
            #expect(world.session.undoStack.depth == 0)
            #expect(world.model.mergeSelection.count == 2, "the picks survive a refusal")
        }
    }

    @Test func onePickedBlockRefusesAndNamesTheGesture() async throws {
        try await withBoardWorld(seedBlocks: ["One.", "Two."]) { world in
            world.model.toggleMergeSelection(world.model.projection.slots[0].blockID)

            await world.model.mergeSelectedBlocks()

            let intact = try world.storeSlots().count
            #expect(world.model.statusMessage?.contains("⌘-click a second block") == true)
            #expect(intact == 2)
        }
    }

    @Test func aFannedPairCarriesToWriteForTheCeremony() async throws {
        // THE CANON FENCE: the ruled threshold (S4-23(4) — any fan on either
        // side opens the merge ceremony) is untouched by this door, and the
        // ceremony mounts in Write, so the PAIR travels there. The
        // quick/ceremony default flip is 13j's row 4b, not this batch's.
        try await withBoardWorld(seedBlocks: ["First half.", "Second half."]) { world in
            let slots = world.model.projection.slots
            let secondVariant = try #require(slots[1].variantID)
            _ = try await world.session.runner.run { ops in
                try ops.branchVariant(slots[1].blockID, from: secondVariant)
            }
            try world.reload()
            var modes: [PostMode] = []
            _ = world.session.commandRouter.registerDetail(
                postID: world.postID, mode: .takes
            ) { modes.append($0) }

            world.model.toggleMergeSelection(slots[0].blockID)
            world.model.toggleMergeSelection(slots[1].blockID)
            await world.model.mergeSelectedBlocks()
            await poll { world.session.commandRouter.pendingWriteIntent != nil }

            let intent = try #require(world.session.commandRouter.pendingWriteIntent)
            #expect(intent.blockID == slots[1].blockID,
                    "the seam the pair means: above the SECOND block")
            #expect(intent.offsetInBlock == 0)
            #expect(intent.followUp == .structural(.merge))
            #expect(modes == [.write], "the choreography moved, visibly (P-2)")
            #expect(world.model.statusMessage?.contains("merge ceremony") == true)
            // Nothing merged here — the ceremony has not been confirmed.
            #expect(try world.storeSlots().count == 2)
            #expect(world.session.undoStack.depth == 0)
        }
    }

    @Test func aFannedRunOfThreeMergesHereAndSaysWhatBecameOfTheOtherTakes() async throws {
        // Write's own multi-block road has never consulted fan arity (its
        // `.mergeChain` merges and SPEAKS), so neither does this one — R118:
        // no surface is behind another. What must never happen is a fan
        // folding away silently.
        try await withBoardWorld(seedBlocks: ["One.", "Two.", "Three."]) { world in
            let slots = world.model.projection.slots
            let secondVariant = try #require(slots[1].variantID)
            _ = try await world.session.runner.run { ops in
                try ops.branchVariant(slots[1].blockID, from: secondVariant)
            }
            try world.reload()
            for slot in slots { world.model.toggleMergeSelection(slot.blockID) }

            await world.model.mergeSelectedBlocks()

            #expect(try world.storeSlots().map(\.text) == ["One. Two. Three."])
            let spoken = try #require(world.model.statusMessage)
            #expect(spoken.contains("1 other take stays with the released blocks"))
            #expect(spoken.contains(TrayPath.originalsPath))
        }
    }

    @Test func theSelectionPrunesWhenABlockLeavesThePost() async throws {
        try await withBoardWorld(seedBlocks: ["One.", "Two."]) { world in
            let slots = world.model.projection.slots
            world.model.toggleMergeSelection(slots[0].blockID)
            world.model.toggleMergeSelection(slots[1].blockID)

            try await world.session.runner.run { ops in
                try ops.deleteBlock(slots[1].blockID)
            }
            try world.reload()

            #expect(world.model.mergeSelection == [slots[0].blockID])
        }
    }

    @Test func theMergeDoorIsDeclaredWithBothOfItsDoorFamilies() {
        let capability = CapabilityRegistry.capability(.mergeSelectedBlocks)
        #expect(capability.doors == [.contextMenu, .surface])
        #expect(capability.scope == .block)
        #expect(capability.takesAccess == .native)
        #expect(capability.shortcutLabel == nil)
        #expect(TakesBoardView.surfaceCapabilities.contains(.mergeSelectedBlocks))
        #expect(TakesCellView.contextMenuCapabilities.contains(.mergeSelectedBlocks))
        #expect(capability.availability(CapabilityContext(mode: .takes)) == .act)
        #expect(capability.availability(
            CapabilityContext(mode: .lenses)) == .unavailable)
    }
}
