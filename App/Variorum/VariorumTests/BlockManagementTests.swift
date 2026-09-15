//
//  BlockManagementTests.swift
//  VariorumTests
//
//  Phase 13e, batch 4 — E2, her A17 verbatim:
//
//      "delete several blocks at the same time from a post - highlighting
//       all of the blocks perhaps? block highlight instead of text highlight
//       across blocks?"
//
//  Three claims carry the batch, and each has a behavioral revert recorded
//  in the plan file's batch record:
//
//   1. The delete is ONE undo entry over every picked block, and a leg that
//      refuses rolls the whole gesture back — no partial acts (`withCompound`).
//   2. The selection is PRUNED wherever the surface adopts a fresh
//      projection, so a banner can never count a ghost.
//   3. The HIGHLIGHT draws on the calm default page — seams off, indicator
//      off, no callouts, no comments — because a selection you cannot see is
//      the silent-selection class.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure rule

@Suite("The block selection rule (13e E2)")
struct BlockSelectionRuleTests {
    private let order = ["a", "b", "c", "d", "e"]

    @Test func pickingTogglesAndTheAnchorFollowsThePointer() {
        var selection = BlockSelection()
        #expect(selection.isEmpty)
        #expect(selection.anchor == nil)

        selection.toggle("b")
        #expect(selection.picked == ["b"])
        #expect(selection.anchor == "b")

        selection.toggle("d")
        #expect(selection.picked == ["b", "d"])
        #expect(selection.anchor == "d")

        // Un-picking still names a place: the anchor moves there, so the
        // next extension starts where she is looking.
        selection.toggle("b")
        #expect(selection.picked == ["d"])
        #expect(selection.anchor == "b")
    }

    @Test func extendingPicksTheWholeRunInEitherDirection() {
        var forward = BlockSelection()
        forward.toggle("b")
        forward.extend(to: "d", in: order)
        #expect(forward.picked == ["b", "c", "d"])
        #expect(forward.anchor == "d", "the anchor moves to where the run now ends")

        var backward = BlockSelection()
        backward.toggle("d")
        backward.extend(to: "b", in: order)
        #expect(backward.picked == ["b", "c", "d"], "direction is not a rule")
    }

    @Test func extendingWithNoAnchorIsJustAFirstPick() {
        var selection = BlockSelection()
        selection.extend(to: "c", in: order)
        #expect(selection.picked == ["c"])
        #expect(selection.anchor == "c")

        // …and an anchor the order no longer holds degrades the same way,
        // rather than refusing at a moment she would read as a dead click.
        var stale = BlockSelection()
        stale.toggle("z")           // a block that is not in this post
        stale.extend(to: "c", in: order)
        #expect(stale.picked == ["z", "c"])
    }

    @Test func extendingIsAdditiveSoSeveralRunsCanBeAssembled() {
        var selection = BlockSelection()
        selection.toggle("a")
        selection.extend(to: "b", in: order)
        selection.toggle("d")
        selection.extend(to: "e", in: order)
        #expect(selection.picked == ["a", "b", "d", "e"],
                "the first run survives the second — extension never unpicks")
    }

    @Test func pruningDropsGhostsAndAStaleAnchorIndependently() {
        var selection = BlockSelection()
        selection.toggle("a")
        selection.toggle("c")
        selection.prune(to: ["a", "b"])
        #expect(selection.picked == ["a"])
        #expect(selection.anchor == nil, "the anchor was 'c', which is gone")

        // The dangerous direction: the anchor dies while every PICK
        // survives. A guard on the set alone would leave it to seed a
        // nonsense range.
        var anchorOnly = BlockSelection()
        anchorOnly.toggle("a")
        anchorOnly.toggle("c")
        anchorOnly.toggle("c")      // unpicked; still the anchor
        #expect(anchorOnly.picked == ["a"])
        anchorOnly.prune(to: ["a", "b"])
        #expect(anchorOnly.picked == ["a"], "nothing picked was lost")
        #expect(anchorOnly.anchor == nil, "…and the dead anchor went anyway")
    }

    @Test func theSelectionReadsInThePostsOrderAndNeverOffersABlockTheOrderLacks() {
        var selection = BlockSelection()
        selection.toggle("d")
        selection.toggle("a")
        selection.toggle("zzz")
        #expect(selection.inOrder(order) == ["a", "d"])
    }

    @Test func theContiguityRuleIsTheOneTheBoardWasBuiltOn() {
        // Batch 2's rule now lives on `BlockSelection`; the board's static
        // forwards, and both answers must be the same answer.
        for picked in [["b", "c"], ["a", "c"], ["a"], []] as [[String]] {
            let set = Set(picked)
            #expect(BlockSelection.isContiguousRun(set, in: order)
                    == TakesBoardLayout.isContiguousRun(set, in: order))
        }
        #expect(BlockSelection.isContiguousRun(["b", "c"], in: order))
        #expect(BlockSelection.isContiguousRun(["a", "c"], in: order) == false)
    }
}

// MARK: - Write's door

@MainActor
@Suite("Block multi-select and multi-delete in Write (13e E2, her A17)")
struct WriteBlockSelectionTests {
    /// Picks blocks by their position in the post's order.
    private func pick(_ harness: EditorHarness, entries: [Int], extendingLast: Bool = false) {
        var location = 0
        var offsets: [Int] = []
        for entry in harness.model.index.entries {
            offsets.append(location)
            location += entry.length + 1
        }
        for (n, i) in entries.enumerated() {
            let extending = extendingLast && n == entries.count - 1
            #expect(harness.model.pickBlock(atOffset: offsets[i], extending: extending))
        }
    }

    // MARK: The gesture

    @Test func commandClickPicksTheBlockUnderThePointer() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta", "gamma"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0])
            #expect(h.model.selectedBlocksInOrder == [ids[0]])
            pick(h, entries: [2])
            #expect(h.model.selectedBlocksInOrder == [ids[0], ids[2]],
                    "the selection reads in the POST's order, not click order")

            // A second ⌘-click on a picked block un-picks it.
            pick(h, entries: [0])
            #expect(h.model.selectedBlocksInOrder == [ids[2]])
        }
    }

    @Test func commandShiftClickExtendsTheRun() async throws {
        try await withEditor(seedBlocks: ["a", "b", "c", "d"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0])
            pick(h, entries: [2], extendingLast: true)
            #expect(h.model.selectedBlocksInOrder == [ids[0], ids[1], ids[2]])
        }
    }

    @Test func aClickPastTheLastBlockClaimsNothing() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            // The open tail is not a block; picking nothing is not a gesture
            // worth eating a caret move for, so the door DECLINES and the
            // click falls through to the ordinary one it looked like.
            #expect(h.model.pickBlock(atOffset: 9_999, extending: false) == false)
            #expect(h.model.selectedBlocksInOrder.isEmpty)
        }
    }

    // MARK: The act

    @Test func theDoorDeletesEveryPickedBlockAndClearsTheSelection() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three", "four"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0, 2])
            await h.model.deleteSelectedBlocks()
            try h.reload()

            #expect(try h.storeSlots().compactMap(\.text) == ["two", "four"])
            #expect(try h.storeSlots().map(\.blockID) == [ids[1], ids[3]])
            #expect(h.model.selectedBlocksInOrder.isEmpty, "the selection did its job")
            #expect(h.model.statusMessage == BlockSelectionCopy.deletedNote(2))
        }
    }

    @Test func oneUndoEntryRestoresEveryPickedBlockWithItsIdAndItsPlace() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three", "four"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0, 1, 3])
            await h.model.deleteSelectedBlocks()
            try h.reload()
            #expect(try h.storeSlots().compactMap(\.text) == ["three"])

            let stack = h.session.undoStack
            #expect(stack.depth == 1, "three deletes, ONE entry")
            #expect(stack.topLabel == "Delete Blocks")

            try await h.session.runner.run { ops in _ = try stack.undo(with: ops) }
            try h.reload()
            #expect(try h.storeSlots().map(\.blockID) == ids,
                    "every block is back, with its own id, in its own place")
            #expect(try h.storeSlots().compactMap(\.text) == ["one", "two", "three", "four"])

            // …and redo takes them all again, in one step (13c A10: a
            // compound is redoable exactly when every leg is, and
            // `deleteBlock` always registers its redo).
            try await h.session.runner.run { ops in _ = try stack.redo(with: ops) }
            try h.reload()
            #expect(try h.storeSlots().compactMap(\.text) == ["three"])
        }
    }

    @Test func theCaretLandsBelowTheRunAndFallsBackAbove() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0, 1])
            await h.model.deleteSelectedBlocks()
            #expect(h.model.caretBlockID == ids[2], "the block below the run takes over")
        }

        try await withEditor(seedBlocks: ["one", "two", "three"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [1, 2])
            await h.model.deleteSelectedBlocks()
            #expect(h.model.caretBlockID == ids[0], "nothing below — the block above does")
        }
    }

    /// **THE NON-CONTIGUOUS LANDING, PINNED AT THE MAC DOOR** (13l Act 1,
    /// A1-MINOR-1 — a COVERAGE pin: green on HEAD by design, no red-on-old
    /// owed).
    ///
    /// ⌘-click is the ONLY door in either app that picks a NON-CONTIGUOUS
    /// set, and "nearest surviving" was corrected for exactly this case when
    /// `caretLandingAfterRemoving` was hoisted into the shared brain by the
    /// mobile round — where its only pin lives. The two contiguous cases
    /// above agree under either reading (everything past a contiguous run
    /// survives by definition), so a Mac-suite-only regression run could not
    /// see this one at all: the edge reading answers `b0`, a block being
    /// deleted, while `b1` sits there surviving.
    @Test func aNonContiguousPickLandsTheCaretOnTheBlockThatSurvivedBetweenThem() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0, 2])
            #expect(h.model.index.caretLandingAfterRemoving([ids[0], ids[2]]).blockID == ids[1],
                    "the brain's answer, read through the Mac's own index")
            await h.model.deleteSelectedBlocks()
            #expect(h.model.caretBlockID == ids[1],
                    "b1 survived between the picked pair — the door lands there")
            try h.reload()
            #expect(try h.storeSlots().compactMap(\.text) == ["two"])
        }
    }

    @Test func aSealedNoteRefusesTheWholeGestureAndDeletesNothing() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three"]) { h in
            pick(h, entries: [0, 1])
            try await h.session.runner.run { ops in try ops.lockPost(h.postID) }
            try h.reload()

            await h.model.deleteSelectedBlocks()
            try h.reload()
            #expect(try h.storeSlots().compactMap(\.text) == ["one", "two", "three"],
                    "the seal refuses through the operation itself")
            #expect(h.session.undoStack.depth == 0, "nothing registered")
            #expect(h.model.statusMessage?.contains("sealed") == true)
            #expect(h.model.selectedBlocksInOrder.count == 2, "the picks survive a refusal")
        }
    }

    @Test func aPickedBlockThatVanishedRollsTheWholeGestureBackAndSaysSo() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0, 1, 2])
            // The reachable race: another pane, the other half of a split,
            // or a sync arrival removes a picked block AFTER she picked it.
            // The projection here is deliberately NOT reloaded — that is
            // exactly the window in which the surface still offers it.
            try await h.session.runner.run { ops in try ops.deleteBlock(ids[2]) }
            let outboxBefore = try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
            }

            await h.model.deleteSelectedBlocks()
            try h.reload()
            #expect(try h.storeSlots().compactMap(\.text) == ["one", "two"],
                    "NOTHING the gesture touched was deleted — the compound unwound")
            #expect(h.model.statusMessage == BlockSelectionCopy.blockGone)
            let outboxAfter = try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
            }
            #expect(outboxAfter == outboxBefore,
                    "a rolled-back gesture leaves the same dirty-row set it found")
        }
    }

    @Test func theRefusalArrivesInWordsNotAsAnEnumDump() async throws {
        try await withEditor(seedBlocks: ["one", "two"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0, 1])
            try await h.session.runner.run { ops in try ops.deleteBlock(ids[1]) }
            await h.model.deleteSelectedBlocks()

            let message = try #require(h.model.statusMessage)
            #expect(message.contains("blockNotFound") == false, "no raw enum dump")
            #expect(message == BlockSelectionCopy.blockGone)
            // The Takes board's home says the same sentence, by construction.
            #expect(OpsRefusalCopy.message(for: OperationError.blockNotFound(id: ids[1]))
                    == BlockSelectionCopy.blockGone)
        }
    }

    @Test func anEmptySelectionRefusesInWordsRatherThanActing() async throws {
        try await withEditor(seedBlocks: ["one"]) { h in
            await h.model.deleteSelectedBlocks()
            #expect(h.model.statusMessage == BlockSelectionCopy.nothingPicked)
            let survivors = try h.storeSlots().count
            #expect(survivors == 1)
        }
    }

    // MARK: Pruning

    /// The pin is on the RAW pick set, deliberately: `selectedBlocksInOrder`
    /// filters through the post's order, so a ghost never reaches the banner
    /// through that door whether the prune runs or not — asserting there
    /// would be a pin that cannot fail (found by running it against the
    /// pre-prune code; the hollow-pin case the hallucination guard names).
    /// What the prune actually changes is the set the surface KEEPS.
    @Test func theSelectionIsPrunedWhenTheStoreLosesAPickedBlock() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0, 1, 2])
            #expect(h.model.blockSelection.count == 3)

            try await h.session.runner.run { ops in try ops.deleteBlock(ids[1]) }
            try h.reload()
            #expect(h.model.blockSelection.picked == [ids[0], ids[2]],
                    "the dead block leaves the selection with the store")
        }
    }

    /// …and the consequence that makes the prune load-bearing rather than
    /// tidy: a block that comes BACK (structural undo, a tray restore, a
    /// sync arrival) must not arrive already highlighted. An unpruned
    /// selection remembers picks across a block's whole death and
    /// resurrection, and she would find a block picked that she never
    /// pointed at in this stretch of picking.
    @Test func aResurrectedBlockDoesNotComeBackAlreadyPicked() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0, 1])

            let stack = h.session.undoStack
            try await h.session.runner.run { ops in try ops.deleteBlock(ids[1]) }
            try h.reload()
            #expect(h.model.blockSelection.picked == [ids[0]])

            try await h.session.runner.run { ops in _ = try stack.undo(with: ops) }
            try h.reload()
            #expect(try h.storeSlots().map(\.blockID) == ids, "the block really is back")
            #expect(h.model.blockSelection.picked == [ids[0]],
                    "…and it is NOT picked — the selection did not remember it")
        }
    }

    @Test func theSelectionSurvivesAnUnrelatedProjection() async throws {
        try await withEditor(seedBlocks: ["one", "two"]) { h in
            let ids = try h.storeSlots().map(\.blockID)
            pick(h, entries: [0])
            try h.reload()
            #expect(h.model.selectedBlocksInOrder == [ids[0]],
                    "pruning drops ghosts, never live picks")
        }
    }

    @Test func aDeleteThroughTheDoorLeavesNoStaleHighlight() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three"]) { h in
            pick(h, entries: [0, 1])
            await h.model.deleteSelectedBlocks()
            #expect(h.model.blockSelection.isEmpty)
            #expect(h.model.blockSelection.anchor == nil,
                    "the anchor goes with the picks — the next ⌘⇧-click starts fresh")
        }
    }

    @Test func theClearDoorUnpicksEverything() async throws {
        try await withEditor(seedBlocks: ["one", "two"]) { h in
            pick(h, entries: [0, 1])
            h.model.clearBlockSelection()
            #expect(h.model.selectedBlocksInOrder.isEmpty)
        }
    }

    // MARK: The doors

    @Test func theContextRowRendersOnlyWithAPickAndNamesTheCount() async throws {
        try await withEditor(seedBlocks: ["one", "two", "three"]) { h in
            // "Delete in Every Take" is this menu's OTHER delete row and is
            // always present — the pin names the selection door exactly.
            let titles = { h.model.contextMenuItems().map(\.title) }
            let deleteRows = {
                titles().filter { title in
                    (1...9).contains { BlockSelectionCopy.deleteVerb(picked: $0) == title }
                }
            }
            // **A JUSTIFIED EDIT (the post-13l polish round, ledger row
            // 4(c)).** With no selection the menu now carries the CARET
            // block's own delete row — the walk's P-8 finding: it offered
            // Archive Block and no delete at all. So "no selection, no door"
            // is no longer the fact: what is, and what this test is about, is
            // that there is never MORE THAN ONE delete row, and that with a
            // pick standing it is the SELECTION's row (which the counted
            // wording below proves). `deleteVerb(picked: 1)` is literally
            // "Delete Block", so counting rows is the only honest assertion.
            #expect(deleteRows().count == 1, "exactly one delete row, always")

            pick(h, entries: [0])
            #expect(titles().contains("Delete Block"))
            #expect(deleteRows().count == 1, "the pick's row REPLACES the caret's")

            pick(h, entries: [1])
            #expect(titles().contains("Delete 2 Blocks"),
                    "the row says how much it will remove")
        }
    }
}

// MARK: - The highlight (a real window: the decoration pass needs TK2 geometry)

@MainActor
@Suite("The block highlight draws on the calm page (13e E2)", .serialized)
struct BlockHighlightTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    @Test func theHighlightReachesTheOverlayWithEveryOtherDecorationOff() async throws {
        try await withEditor(seedBlocks: ["alpha block", "beta block", "gamma block"]) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 420, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let scrollView = try #require(h.textView.enclosingScrollView)
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()

            var captured: BlockDecor.State?
            h.model.decorSink = { captured = $0 }
            // THE CALM DEFAULT: seams off, indicator off, no callouts, no
            // comments. Before E2 this state skipped the frame walk
            // entirely, which is why the gate needed the selection arm.
            h.model.appearance = EditorAppearance()
            h.model.refreshDecorations()
            pump()
            #expect(captured?.frames.isEmpty != false,
                    "nothing decorated yet — the calm page costs nothing")

            let ids = try h.storeSlots().map(\.blockID)
            #expect(h.model.pickBlock(atOffset: 0, extending: false))
            pump()
            let state = try #require(captured)
            #expect(state.selectedBlockIDs == [ids[0]])
            #expect(state.frames.contains { $0.blockID == ids[0] },
                    "the picked block has geometry to draw the highlight in")

            // …and unpicking takes it away again.
            #expect(h.model.pickBlock(atOffset: 0, extending: false))
            pump()
            #expect(captured?.selectedBlockIDs.isEmpty == true)
        }
    }

    /// **The chord, through the REAL input path** (the batch-1 rule: a
    /// feature reached by input gets a pin driven through an input path).
    /// A real window is what makes it possible at all — an unclaimed click
    /// falls through to `super.mouseDown`, whose modal selection-tracking
    /// loop only returns when it sees a mouse-UP with the window's own
    /// number (the `TypewriterRoomTests` / `PhantomSpaceTests` recipe;
    /// without it this pin hangs the suite instead of failing it).
    ///
    /// The click POINTS come from the decoration pass's own frames, so the
    /// geometry that draws the highlight and the geometry the pointer hits
    /// are the same geometry.
    @Test func theChordPicksThroughTheRealMouseDownPath() async throws {
        try await withEditor(seedBlocks: ["alpha block", "beta block", "gamma block"]) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 420, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let scrollView = try #require(h.textView.enclosingScrollView)
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()

            // Frames first (the selection arm of the gate is what produces
            // them on the calm page), then a clean slate to click into.
            var captured: BlockDecor.State?
            h.model.decorSink = { captured = $0 }
            h.model.appearance = EditorAppearance()
            #expect(h.model.pickBlock(atOffset: 0, extending: false))
            pump()
            let frames = try #require(captured).frames
            #expect(frames.count == 3, "all three blocks are in view")
            h.model.clearBlockSelection()
            pump()

            @MainActor func click(_ entry: Int, _ flags: NSEvent.ModifierFlags) throws {
                let frame = try #require(frames.first { $0.entryIndex == entry }).frame
                let inWindow = h.textView.convert(
                    NSPoint(x: frame.midX, y: frame.midY), to: nil)
                func event(_ type: NSEvent.EventType) -> NSEvent? {
                    NSEvent.mouseEvent(
                        with: type, location: inWindow, modifierFlags: flags,
                        timestamp: ProcessInfo.processInfo.systemUptime,
                        windowNumber: window.windowNumber, context: nil,
                        eventNumber: 0, clickCount: 1,
                        pressure: type == .leftMouseDown ? 1 : 0)
                }
                let down = try #require(event(.leftMouseDown))
                let up = try #require(event(.leftMouseUp))
                NSApp.postEvent(up, atStart: true)
                h.textView.mouseDown(with: down)
                pump()
            }

            let ids = try h.storeSlots().map(\.blockID)
            try click(0, .command)
            #expect(h.model.selectedBlocksInOrder == [ids[0]], "⌘-click picks")

            try click(2, [.command, .shift])
            #expect(h.model.selectedBlocksInOrder == ids, "⌘⇧-click extends the run")

            // ⇧ ALONE is the TEXT selection's — the very gesture her ask
            // contrasts with, left exactly where it was.
            try click(1, .shift)
            #expect(h.model.selectedBlocksInOrder == ids, "⇧-click picks no block")

            try click(1, [])
            #expect(h.model.selectedBlocksInOrder.isEmpty,
                    "an ordinary click puts the selection down")
        }
    }
}

// MARK: - The Takes board's half (the SAME selection, the second act)

@MainActor
private func withBoard<T>(
    seedBlocks: [String],
    _ body: @MainActor (TakesBoardWorld) async throws -> T
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
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "13e batch 4")
        for text in seedBlocks {
            // A fixture mint is not a gesture (13u1 UNIT 2 — the
            // `withEditor` harness's own rule, stated there).
            _ = try session.operations.newBlock(
                in: post.id, text: text, registeringUndo: false)
        }
        let world = TakesBoardWorld(
            session: session, database: db,
            model: TakesViewModel(session: session, postID: post.id),
            postID: post.id)
        try world.reload()
        return try await body(world)
    }
}

@MainActor
private struct TakesBoardWorld {
    let session: AppSession
    let database: AppDatabase
    let model: TakesViewModel
    let postID: String

    func reload() throws {
        model.adopt(try database.read { try Queries.takesProjection($0, post: postID) })
    }

    func blockIDs() throws -> [String] {
        try database.read { try Queries.renderPost($0, containerID: postID) }.map(\.blockID)
    }

    func texts() throws -> [String] {
        try database.read { try Queries.renderPost($0, containerID: postID) }
            .compactMap(\.text)
    }
}

@MainActor
@Suite("The Takes board deletes the same picked blocks (13e E2)")
struct BoardBlockSelectionTests {
    @Test func theBoardsDeleteDoorRemovesEveryPickedBlockUnderOneEntry() async throws {
        try await withBoard(seedBlocks: ["one", "two", "three", "four"]) { world in
            let ids = try world.blockIDs()
            world.model.toggleMergeSelection(ids[0])
            world.model.toggleMergeSelection(ids[2])
            await world.model.deleteSelectedBlocks()
            try world.reload()

            #expect(try world.texts() == ["two", "four"])
            #expect(world.model.mergeSelection.isEmpty)
            #expect(world.session.undoStack.depth == 1)
            #expect(world.session.undoStack.topLabel == "Delete Blocks")

            let stack = world.session.undoStack
            try await world.session.runner.run { ops in _ = try stack.undo(with: ops) }
            #expect(try world.blockIDs() == ids, "one undo, every block back in place")
        }
    }

    @Test func theBoardsGesturesTogglesAndExtends() async throws {
        try await withBoard(seedBlocks: ["one", "two", "three", "four"]) { world in
            let ids = try world.blockIDs()
            world.model.toggleMergeSelection(ids[0])
            world.model.extendMergeSelection(to: ids[2])
            #expect(world.model.selectedBlocksInOrder == [ids[0], ids[1], ids[2]])
        }
    }

    @Test func theBoardsDeleteRefusesAnEmptyPickInWords() async throws {
        try await withBoard(seedBlocks: ["one"]) { world in
            await world.model.deleteSelectedBlocks()
            #expect(world.model.statusMessage == BlockSelectionCopy.nothingPicked)
            let survivors = try world.texts()
            #expect(survivors == ["one"])
        }
    }

    @Test func theBoardsSealRefusalLeavesEveryBlockAndEveryPick() async throws {
        try await withBoard(seedBlocks: ["one", "two"]) { world in
            let ids = try world.blockIDs()
            world.model.toggleMergeSelection(ids[0])
            world.model.toggleMergeSelection(ids[1])
            try world.session.operations.lockPost(world.postID)

            await world.model.deleteSelectedBlocks()
            #expect(try world.texts() == ["one", "two"])
            #expect(world.model.mergeSelection.count == 2)
            #expect(world.model.statusMessage?.contains("sealed") == true)
        }
    }
}

// MARK: - The declaration

@MainActor
@Suite("The delete-selected act is declared on both post surfaces (13e E2)")
struct BlockSelectionRegistryTests {
    @Test func theActIsDeclaredWithBothDoorFamiliesAndNoChord() {
        let capability = CapabilityRegistry.capability(.deleteSelectedBlocks)
        #expect(capability.verb == "Delete Selected Blocks")
        #expect(capability.scope == .block)
        #expect(capability.doors == [.contextMenu, .surface])
        #expect(capability.shortcutLabel == nil, "⌫ belongs to the caret (QUESTIONS #59(d))")
        #expect(capability.takesAccess == .native)
        #expect(capability.unavailableNote == BlockSelectionCopy.nothingPicked)
    }

    @Test func itActsOnBothPostSurfacesAndNowhereElse() {
        func availability(_ context: CapabilityContext) -> Capability.Availability {
            CapabilityRegistry.capability(.deleteSelectedBlocks).availability(context)
        }
        #expect(availability(CapabilityContext(mode: .write, writeEditorAttached: true)) == .act)
        #expect(availability(CapabilityContext(mode: .takes)) == .act,
                "R118: Write is never the privileged surface")
        #expect(availability(CapabilityContext(takesBoardAttached: true)) == .act,
                "…including a board mounted outside a post detail (13c 2B)")
        #expect(availability(CapabilityContext()) == .unavailable,
                "no note open, no door")
    }

    @Test func bothRenderersDeclareTheOneAct() {
        #expect(TakesBoardView.surfaceCapabilities.contains(.deleteSelectedBlocks))
        #expect(EditorView.surfaceCapabilities.contains(.deleteSelectedBlocks))
        #expect(TakesCellView.contextMenuCapabilities.contains(.deleteSelectedBlocks))
        #expect(EditorViewModel.contextMenuCapabilities.contains(.deleteSelectedBlocks))
    }
}
