//
//  StructuralGestureTests.swift
//  VariorumTests
//
//  Phase 9 Steps 2–3 — the structural rewrite door and the divide/extract
//  gestures, driven through the REAL pipeline (planner → flush → op via the
//  runner → fresh projection → the one rewrite path → caret by identity).
//  After every gesture: surface == store projection, per block.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Structural rewrite door (Phase 9, Step 2)")
struct StructuralRewriteDoorTests {
    @Test func divideLandsAndTheCaretSitsAtTheSuccessorsStart() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one.", "Anchor."]) { h in
            // Sloppy caret mid-second-sentence; the planner snaps to 16.
            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["First sentence.", "Second one.", "Anchor."])
            try expectStoreMatchesView(h)
            // Caret by identity: the successor block's start.
            let successorRange = h.model.index.range(ofEntryAt: 1)
            #expect(h.textView.selectedRange() == NSRange(location: successorRange.location, length: 0))
            // The undo stack holds the op's inverse (labels tested below).
            #expect(h.session.undoStack.topLabel == "Divide")
        }
    }

    @Test func extractPrefixMintsBeforeTheSourceAndCaretLandsThere() async throws {
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            // Sloppy prefix selection (mid-word ends): snaps to 0..<14.
            h.textView.setSelectedRange(NSRange(location: 2, length: 8))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.extractSelection)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["Intro clause.", "Middle stays here. Tail sentence."])
            try expectStoreMatchesView(h)
            // The extracted block sits FIRST (prefix-before, Phase 3 rule);
            // caret at its start.
            #expect(h.textView.selectedRange() == NSRange(location: 0, length: 0))
            #expect(h.session.undoStack.topLabel == "Extract")
            // Lineage: extracted derived_from source via 'extract'.
            let edges = try await h.database.read {
                try String.fetchAll($0, sql: "SELECT origin_op FROM edge WHERE deleted_at IS NULL")
            }
            #expect(edges == ["extract"])
        }
    }

    @Test func extractSuffixMintsAfterTheSource() async throws {
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            h.textView.setSelectedRange(NSRange(location: 35, length: 9))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.extractSelection)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["Intro clause. Middle stays here.", "Tail sentence."])
            try expectStoreMatchesView(h)
            let extractedRange = h.model.index.range(ofEntryAt: 1)
            #expect(h.textView.selectedRange() == NSRange(location: extractedRange.location, length: 0))
        }
    }

    @Test func mergeThroughTheDoorJoinsWithTheCaretAtTheJoin() async throws {
        try await withEditor(seedBlocks: ["One two.", "Three four."]) { h in
            // Caret at the seam (end of block 0).
            h.textView.setSelectedRange(NSRange(location: 8, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.mergeBlocks)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["One two. Three four."])  // the space join
            try expectStoreMatchesView(h)
            // Caret at the join: where the trailing half begins.
            #expect(h.textView.selectedRange() == NSRange(location: 9, length: 0))
            #expect(h.session.undoStack.topLabel == "Merge")
        }
    }

    @Test func theObservationEchoOfAStructuralRewriteTouchesNothing() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)
            let text = h.documentText
            let selection = h.textView.selectedRange()

            try h.reload()  // the projection arrives — our own echo

            #expect(h.documentText == text)
            #expect(h.textView.selectedRange() == selection)
            try expectStoreMatchesView(h)
        }
    }

    @Test func refusalsSurfaceVisiblyAndTouchNothing() async throws {
        try await withEditor(seedBlocks: ["Only one sentence here."]) { h in
            let before = h.documentText
            h.textView.setSelectedRange(NSRange(location: 10, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)

            #expect(h.model.statusMessage
                == RefusalCopy.message(for: .nothingToDo))
            #expect(h.documentText == before)
            let slotCount = try h.storeSlots().count
            #expect(slotCount == 1)
            #expect(h.session.undoStack.depth == 0)
        }
    }

    @Test func aFannedDivideRoutesToTheWCeremonyAndTouchesNoRows() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[0].blockID, from: slots[0].variantID!)
            try h.reload()

            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)

            let ceremony = try #require(h.model.divideWCeremony)
            #expect(ceremony.blockID == slots[0].blockID)
            // The active (rendered) take is pre-marked with the snapped cut.
            let active = try #require(ceremony.takes.first { $0.id == slots[0].variantID })
            #expect(active.marked)
            #expect(active.cut == 16)
            // Opening the ceremony touches no rows.
            let untouched = try h.storeSlots().map(\.text)
            #expect(untouched == ["First sentence. Second one."])
            #expect(h.session.undoStack.depth == 0)
        }
    }

    @Test func theGestureFlushesTheBufferFirst() async throws {
        try await withEditor(seedBlocks: ["First part stays. Second part goes."]) { h in
            // Type WITHOUT flushing — the gesture must flush before the op,
            // so the op cuts the text the author sees.
            h.type("!", at: 17)  // "First part stays.!" — end of first sentence
            h.textView.setSelectedRange(NSRange(location: 20, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["First part stays.!", "Second part goes."])
            try expectStoreMatchesView(h)
        }
    }

    @Test func aRefusedFlushAbortsTheGestureAndLosesNothing() async throws {
        try await withEditor(seedBlocks: ["Guarded text here. More of it."]) { h in
            h.type("!", at: 18)  // dirty, debounce pending
            let slots = try h.storeSlots()
            // The lock lands remotely while the buffer is dirty; the stale
            // index still says editable, so the planner plans — the door's
            // flush guard is what must refuse.
            _ = try h.session.operations.lockVariant(slots[0].variantID!)
            h.textView.setSelectedRange(NSRange(location: 21, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)

            // Nothing structural happened; the typed text is still pending
            // (Phase 7 keep-pending posture), nothing lost, message shown.
            let slotCount = try h.storeSlots().count
            #expect(slotCount == 1)
            #expect(h.model.autosave.isDirty)
            #expect(h.model.statusMessage != nil)
            #expect(h.documentText.contains("!"))
            #expect(h.session.undoStack.depth == 0)
        }
    }
}

@MainActor
@Suite("Divide & extract gestures (Phase 9, Step 3)")
struct DivideExtractGestureTests {
    @Test func enablementMirrorsThePlannerVerdictExactly() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one.", "Anchor."]) { h in
            @MainActor func expectMirror(_ location: SourceLocation = #_sourceLocation) {
                let selection = h.textView.selectedRange()
                let world = h.model.gestureWorld()
                func planned(_ c: StructuralGesturePlanner.Command) -> Bool {
                    if case .refusal = StructuralGesturePlanner.plan(
                        c, selection: selection, world: world) { return false }
                    return true
                }
                let a = h.model.gestureAvailability
                #expect(a.divide == planned(.divideAtCursor), sourceLocation: location)
                #expect(a.extract == planned(.extractSelection), sourceLocation: location)
                #expect(a.makeBlock == planned(.makeBlockFromSelection), sourceLocation: location)
                #expect(a.merge == planned(.mergeBlocks), sourceLocation: location)
            }

            // Caret mid-block: divide possible, extract needs a selection.
            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()
            expectMirror()
            #expect(h.model.gestureAvailability.divide)
            #expect(!h.model.gestureAvailability.extract)

            // A suffix selection: extract possible.
            h.textView.setSelectedRange(NSRange(location: 17, length: 10))
            h.model.updateCaretContext()
            expectMirror()
            #expect(h.model.gestureAvailability.extract)

            // Caret at the block seam: merge possible.
            h.textView.setSelectedRange(NSRange(location: 27, length: 0))
            h.model.updateCaretContext()
            expectMirror()
            #expect(h.model.gestureAvailability.merge)
        }
    }

    @Test func aSealedPostDisablesEverythingAndDirectInvocationExplains() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            try h.session.operations.lockPost(h.postID)
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()

            #expect(h.model.gestureAvailability == .init())  // all false
            // The shortcut path re-plans and surfaces the refusal.
            await h.model.invokeGesture(.divideAtCursor)
            #expect(h.model.statusMessage == RefusalCopy.message(for: .sealed))
            let slotCount = try h.storeSlots().count
            #expect(slotCount == 1)
        }
    }

    @Test func aLockedTakeDisablesDivideAndInvocationExplains() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.lockVariant(slots[0].variantID!)
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()

            #expect(!h.model.gestureAvailability.divide)
            await h.model.invokeGesture(.divideAtCursor)
            #expect(h.model.statusMessage == RefusalCopy.message(for: .lockedVariant))
        }
    }

    @Test func theSnappedRangeIsWhatReachesTheOperation() async throws {
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            // A deliberately sloppy selection nowhere near the boundaries:
            // the op must receive the SNAPPED span, so the stored halves
            // split exactly at the sentence marks.
            h.textView.setSelectedRange(NSRange(location: 37, length: 5))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.extractSelection)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["Intro clause. Middle stays here.", "Tail sentence."])
        }
    }

    @Test func theFannedExtractHintAppearsOnlyWithOtherTakes() async throws {
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            // Unfanned: no hint after a successful extract.
            h.textView.setSelectedRange(NSRange(location: 35, length: 9))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.extractSelection)
            #expect(h.model.statusMessage == nil)
        }
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[0].blockID, from: slots[0].variantID!)
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 35, length: 9))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.extractSelection)
            // Passive, non-blocking: a status line, not a modal.
            #expect(h.model.statusMessage?.contains("other take") == true)
            let slotCount = try h.storeSlots().count
            #expect(slotCount == 2)  // the extract still ran
        }
    }

    @Test func undoMenuLabelTracksTheTopEntryThroughDoAndUndo() async throws {
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            let menuState = h.session.undoMenuState
            #expect(EditorCommands.undoMenuTitle(for: menuState.topLabel)
                == "Undo Structural Change")

            h.textView.setSelectedRange(NSRange(location: 35, length: 9))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.extractSelection)
            for _ in 0..<2000 {
                if menuState.topLabel == "Extract" { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(menuState.topLabel == "Extract")
            #expect(EditorCommands.undoMenuTitle(for: menuState.topLabel) == "Undo Extract")

            // Undo pops the entry; the label empties again.
            let stack = h.session.undoStack
            _ = try await h.session.runner.run { ops in try stack.undo(with: ops) }
            for _ in 0..<2000 {
                if menuState.topLabel == nil { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(menuState.topLabel == nil)
            #expect(EditorCommands.undoMenuTitle(for: menuState.topLabel)
                == "Undo Structural Change")
        }
    }

    @Test func contextMenuItemsCarryTheSameBrainsVerdicts() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()
            let items = h.model.contextMenuItems()
            #expect(items.map(\.title) == [
                "Divide Block at Cursor", "Extract Selection",
                "Make Block from Selection", "Merge Blocks",
            ])
            let a = h.model.gestureAvailability
            #expect(items.map(\.enabled) == [a.divide, a.extract, a.makeBlock, a.merge])
        }
    }

    @Test func structuralUndoRestoresTheSurfaceThroughTheProjection() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)
            let divided = try h.storeSlots().count
            #expect(divided == 2)

            let stack = h.session.undoStack
            _ = try await h.session.runner.run { ops in try stack.undo(with: ops) }
            try h.reload()  // the undo's projection arrives

            let restored = try h.storeSlots().map(\.text)
            #expect(restored == ["First sentence. Second one."])
            #expect(h.documentText == "First sentence. Second one.")
            try expectStoreMatchesView(h)
        }
    }
}


@MainActor
@Suite("Make Block from Selection (Phase 9, Step 4)")
struct MakeBlockGestureTests {
    @Test func aMiddleSpanYieldsThreeBlocksWithLineageAndOneUndoEntry() async throws {
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            let sourceID = try h.storeSlots()[0].blockID
            h.textView.setSelectedRange(NSRange(location: 15, length: 15))  // sloppy middle
            h.model.updateCaretContext()
            #expect(h.model.gestureAvailability.makeBlock)
            await h.model.invokeGesture(.makeBlockFromSelection)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text)
                == ["Intro clause.", "Middle stays here.", "Tail sentence."])
            try expectStoreMatchesView(h)
            // Caret by identity: the new middle block's start.
            let middleRange = h.model.index.range(ofEntryAt: 1)
            #expect(h.textView.selectedRange() == NSRange(location: middleRange.location, length: 0))
            // ONE compound entry, labeled for the menu.
            #expect(h.session.undoStack.depth == 1)
            #expect(h.session.undoStack.topLabel == "Make Block")
            // Two divide edges: middle from source, suffix from middle.
            let edges = try await h.database.read {
                try Row.fetchAll(
                    $0,
                    sql: """
                        SELECT source_block_id, target_block_id, origin_op
                        FROM edge WHERE deleted_at IS NULL ORDER BY created_at, id
                        """)
            }
            #expect(edges.count == 2)
            #expect(edges.allSatisfy { $0["origin_op"] == "divide" })
            #expect(edges[0]["target_block_id"] == sourceID)
            #expect(edges[0]["source_block_id"] == slots[1].blockID)
            #expect(edges[1]["target_block_id"] == slots[1].blockID)
            #expect(edges[1]["source_block_id"] == slots[2].blockID)
        }
    }

    @Test func oneUndoRestoresTheSourceExactly() async throws {
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            h.textView.setSelectedRange(NSRange(location: 15, length: 15))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.makeBlockFromSelection)
            let made = try h.storeSlots().count
            #expect(made == 3)

            let stack = h.session.undoStack
            let label = try await h.session.runner.run { ops in try stack.undo(with: ops) }
            #expect(label == "Make Block")
            try h.reload()

            let restored = try h.storeSlots().map(\.text)
            #expect(restored == ["Intro clause. Middle stays here. Tail sentence."])
            #expect(h.documentText == "Intro clause. Middle stays here. Tail sentence.")
            #expect(stack.depth == 0)
            try expectStoreMatchesView(h)
        }
    }

    @Test func aFannedBlockRefusesTowardTheWCeremony() async throws {
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[0].blockID, from: slots[0].variantID!)
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 15, length: 15))
            h.model.updateCaretContext()

            #expect(!h.model.gestureAvailability.makeBlock)
            await h.model.invokeGesture(.makeBlockFromSelection)
            #expect(h.model.statusMessage == RefusalCopy.message(for: .fannedMiddleSpan))
            let untouched = try h.storeSlots().count
            #expect(untouched == 1)
        }
    }

    @Test func aBoundaryTouchingSpanRunsOneExtractInstead() async throws {
        try await withEditor(seedBlocks: ["Intro clause. Middle stays here. Tail sentence."]) { h in
            // The planner degrades the edge-touching span to extract (one op
            // beats two): ONE op, ONE "Extract" entry, one lineage edge.
            h.textView.setSelectedRange(NSRange(location: 2, length: 8))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.makeBlockFromSelection)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text)
                == ["Intro clause.", "Middle stays here. Tail sentence."])
            #expect(h.session.undoStack.depth == 1)
            #expect(h.session.undoStack.topLabel == "Extract")
            let ops = try await h.database.read {
                try String.fetchAll($0, sql: "SELECT origin_op FROM edge WHERE deleted_at IS NULL")
            }
            #expect(ops == ["extract"])
        }
    }
}

@MainActor
@Suite("Merge gesture (Phase 9, Step 5)")
struct MergeGestureTests {
    @Test func aTwoBlockSelectionMergesAndAThreeBlockOneRefuses() async throws {
        try await withEditor(seedBlocks: ["One two.", "Three four.", "Five six."]) { h in
            // Three blocks selected ("One two." | "Three four." | "Five
            // six." — C's chars start at 21): the binary rule refuses.
            h.textView.setSelectedRange(NSRange(location: 2, length: 20))
            h.model.updateCaretContext()
            #expect(!h.model.gestureAvailability.merge)
            await h.model.invokeGesture(.mergeBlocks)
            #expect(h.model.statusMessage == RefusalCopy.message(for: .tooManyBlocksForMerge))
            let untouched = try h.storeSlots().count
            #expect(untouched == 3)

            // Exactly two: merges.
            h.textView.setSelectedRange(NSRange(location: 2, length: 9))
            h.model.updateCaretContext()
            #expect(h.model.gestureAvailability.merge)
            await h.model.invokeGesture(.mergeBlocks)
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["One two. Three four.", "Five six."])
            try expectStoreMatchesView(h)
        }
    }

    @Test func undoRestoresBothPlacementsAndTheSurface() async throws {
        try await withEditor(seedBlocks: ["One two.", "Three four."]) { h in
            h.textView.setSelectedRange(NSRange(location: 8, length: 0))  // the seam
            h.model.updateCaretContext()
            await h.model.invokeGesture(.mergeBlocks)
            let merged = try h.storeSlots().count
            #expect(merged == 1)

            let stack = h.session.undoStack
            _ = try await h.session.runner.run { ops in try stack.undo(with: ops) }
            try h.reload()

            let restored = try h.storeSlots().map(\.text)
            #expect(restored == ["One two.", "Three four."])
            #expect(h.documentText == "One two.\nThree four.")
            try expectStoreMatchesView(h)
        }
    }

    @Test func anEndpointGrazeStillMergesTheTwoSelectedBlocks() async throws {
        // The gate-review case, end to end: the selection ends exactly at
        // the third block's start — the two blocks with selected text merge.
        try await withEditor(seedBlocks: ["One two.", "Three four.", "Five six."]) { h in
            let thirdStart = h.model.index.range(ofEntryAt: 2).location
            h.textView.setSelectedRange(NSRange(location: 2, length: thirdStart - 2))
            h.model.updateCaretContext()
            #expect(h.model.gestureAvailability.merge)
            await h.model.invokeGesture(.mergeBlocks)
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["One two. Three four.", "Five six."])
        }
    }
}


@MainActor
@Suite("The W ceremony (Phase 9, Step 6)")
struct DivideWCeremonyTests {
    /// v1 (rendered): cut snaps to 13. v2 shares the cut's string context,
    /// shifted by an 11-unit prefix — the unique match proposes 24.
    private func openCeremony(
        _ h: EditorHarness, v2Text: String = "Intro pad. First alpha. First omega."
    ) async throws -> (v1: String, v2: String) {
        let slots = try h.storeSlots()
        let v2 = try h.session.operations.branchVariant(
            slots[0].blockID, from: slots[0].variantID!)
        try h.session.operations.autosave(v2.id, text: v2Text, charDelta: 0)
        try h.reload()
        h.textView.setSelectedRange(NSRange(location: 15, length: 0))
        h.model.updateCaretContext()
        await h.model.invokeGesture(.divideAtCursor)
        return (slots[0].variantID!, v2.id)
    }

    @Test func theCeremonyPreMarksTheActiveTakeAndSeedsProposals() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, v2) = try await openCeremony(h)
            let state = try #require(h.model.divideWCeremony)

            let activeTake = try #require(state.takes.first { $0.id == v1 })
            #expect(activeTake.marked)
            #expect(activeTake.cut == 13)  // the gesture's snapped cut

            let otherTake = try #require(state.takes.first { $0.id == v2 })
            #expect(!otherTake.marked, "only the active take is pre-marked")
            #expect(otherTake.cut == 24, "string-context match, snapped to a legal boundary")
            #expect(otherTake.boundaries.contains(24))
        }
    }

    @Test func noUniqueMatchLeavesTheTakeUnseededAndGatesConfirm() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            // v2 shares no context with the active cut: no proposal.
            let (v1, v2) = try await openCeremony(
                h, v2Text: "Wholly different words. Nothing shared.")
            var state = try #require(h.model.divideWCeremony)
            let otherTake = try #require(state.takes.first { $0.id == v2 })
            #expect(otherTake.cut == nil, "zero matches: unseeded, never a guess")

            // Marking the unseeded take gates Confirm until a cut is placed.
            #expect(state.canConfirm)  // active take alone, cut in place
            h.model.toggleWTake(v2)
            state = try #require(h.model.divideWCeremony)
            #expect(!state.canConfirm, "a marked take without a cut blocks Confirm")
            h.model.placeWCut(takeID: v2, cut: 24)  // after "Wholly different words. "
            state = try #require(h.model.divideWCeremony)
            #expect(state.canConfirm)
            _ = v1
        }
    }

    @Test func confirmPassesExactlyTheMarkedCutsToTheOp() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, v2) = try await openCeremony(h)
            h.model.toggleWTake(v2)  // mark the second take; its cut is the proposal (24)
            await h.model.confirmDivideWCeremony()

            // The op received {v1: 13, v2: 24}: B's fan = first halves in
            // fan order, C's fan = second halves; A released to lineage.
            let slots = try h.storeSlots()
            #expect(slots.count == 2)
            #expect(slots.map(\.text) == ["First alpha.", "First omega."])  // rendered = v1's halves
            try expectStoreMatchesView(h)
            let fanTexts = try await h.database.read { db in
                try slots.map { slot in
                    try String.fetchAll(
                        db,
                        sql: """
                            SELECT working_text FROM variant
                            WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                            ORDER BY fan_position, id
                            """,
                        arguments: [slot.blockID])
                }
            }
            // v1's cut (13) and v2's proposed cut (24) both carried through:
            // first halves on B in fan order, second halves on C.
            #expect(fanTexts[0] == ["First alpha.", "Intro pad. First alpha."])
            #expect(fanTexts[1] == ["First omega.", "First omega."])
            // Caret by identity: B's start.
            #expect(h.textView.selectedRange() == NSRange(location: 0, length: 0))
            #expect(h.session.undoStack.topLabel == "Divide into Variants")
            #expect(h.model.divideWCeremony == nil)
            _ = v1
        }
    }

    @Test func cancelTouchesNothing() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            _ = try await openCeremony(h)
            #expect(h.model.divideWCeremony != nil)
            h.model.cancelDivideW()
            #expect(h.model.divideWCeremony == nil)
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["First alpha. First omega."])
            #expect(h.session.undoStack.depth == 0)
            #expect(h.documentText == "First alpha. First omega.")
        }
    }

    @Test func undoAfterConfirmRestoresTheOriginalReading() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            _ = try await openCeremony(h)
            await h.model.confirmDivideWCeremony()  // active take only
            let divided = try h.storeSlots().count
            #expect(divided == 2)

            let stack = h.session.undoStack
            let label = try await h.session.runner.run { ops in try stack.undo(with: ops) }
            #expect(label == "Divide into Variants")
            try h.reload()

            let restored = try h.storeSlots().map(\.text)
            #expect(restored == ["First alpha. First omega."])
            try expectStoreMatchesView(h)
        }
    }

    @Test func placeWCutRefusesIllegalPositions() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, _) = try await openCeremony(h)
            h.model.placeWCut(takeID: v1, cut: 7)  // not a legal boundary
            let state = try #require(h.model.divideWCeremony)
            let active = try #require(state.takes.first { $0.id == v1 })
            #expect(active.cut == 13, "only click-to-place onto LEGAL boundaries")
        }
    }
}


@MainActor
@Suite("Drops & refusal copy (Phase 9, Step 7)")
struct DropAndRefusalCopyTests {
    // Drops ride the same bulk-entry flag as paste (performDragOperation
    // wraps super in withPasteFlag — AppKit plumbing; the ROUTING is the
    // flag + verdict, driven here through the shared seam).

    @Test func aDropIntoTheOpenTailIsBulkEntry_segmentsAndClosesTheTail() async throws {
        try await withEditor(seedBlocks: ["Existing block."]) { h in
            h.type("\n", at: 15)                    // open the tail
            h.type("already typed ")                 // tail has typed text
            // The drop lands MID-tail (drops aren't caret-bound).
            let tailStart = h.model.index.tailRange!.location
            h.textView.withPasteFlag {
                h.type("Alpha para.\nBeta para.\nGamma tail", at: tailStart + 8)
            }
            await h.settle()
            let slots = try h.storeSlots()
            #expect(slots.count > 1, "the drop segmented on entry")
            #expect(!h.model.hasOpenTail, "bulk entry closes the tail")
            try expectStoreMatchesView(h)
        }
    }

    @Test func aDropIntoABlockIsAContentEditAtTheDropPoint() async throws {
        try await withEditor(seedBlocks: ["Target block.", "Anchor."]) { h in
            h.textView.withPasteFlag {
                h.type("dropped\ntext ", at: 7)      // mid-block, with a newline
            }
            await h.flush()
            let slots = try h.storeSlots()
            #expect(slots.count == 2, "no mints: a drop into a block is a content edit")
            #expect(slots[0].text == "Target dropped\ntext block.",
                    "the newline stays content (I4)")
            try expectStoreMatchesView(h)
            // And the flag armed nothing: a later tail keystroke is typing.
            let end = (h.documentText as NSString).length
            h.type("\n", at: end)
            h.type("x")
            await h.settle()
            #expect(h.model.hasOpenTail, "typing semantics — no bulk mint")
        }
    }

    @Test func aDropAtTheExactSeamExtendsTheLeadingBlock() async throws {
        try await withEditor(seedBlocks: ["Lead.", "Trail."]) { h in
            // Boundary-adjacent drop: offset 5 is the leading block's exact
            // end (the separator's position) — content lands in that block.
            h.textView.withPasteFlag {
                h.type(" dropped", at: 5)
            }
            await h.flush()
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["Lead. dropped", "Trail."])
            try expectStoreMatchesView(h)
        }
    }

    @Test func everyRefusalReasonHasHonestCopy() {
        for reason in StructuralGesturePlanner.Refusal.allCases {
            let message = RefusalCopy.message(for: reason)
            #expect(!message.isEmpty, "\(reason) must have visible copy")
        }
        // The ratified specifics: the workaround, the pointers, the rule.
        let crossBlock = RefusalCopy.message(for: .crossBlockSpan)
        #expect(crossBlock.contains("Divide") && crossBlock.contains("merge"),
                "cross-block names the divide-then-merge workaround")
        #expect(RefusalCopy.message(for: .fannedMiddleSpan).contains("Divide Block at Cursor"),
                "fanned middle span points at the W ceremony's door")
        #expect(RefusalCopy.message(for: .middleSpanNeedsMakeBlock).contains("Make Block"),
                "extract's middle-span refusal points at the composed gesture")
        #expect(RefusalCopy.message(for: .tooManyBlocksForMerge).contains("two"),
                "the binary rule is named")
    }
}


@MainActor
@Suite("Differential structural apply (Phase 9 — author decision 2026-07-07)")
struct DifferentialApplyTests {
    /// The differential path's defining property, pinned with a spy on the
    /// storage's edit notifications: a gesture edits ONLY the seam region.
    /// The same spy proves it can DETECT a full rewrite (the W confirm's
    /// full-path edit covers the document) — so a regression to full
    /// re-render on the everyday gestures fails this test, red-on-old style.
    @Test func everydayGesturesEditOnlyTheSeamRegion() async throws {
        let blocks = (0..<30).map { "Block \($0) first sentence. Block \($0) second one." }
        try await withEditor(seedBlocks: blocks) { h in
            let storage = try #require(h.textView.textStorage)
            let docLength = (h.documentText as NSString).length
            let edited = LockIsolated<[Int]>([])
            let token = NotificationCenter.default.addObserver(
                forName: NSTextStorage.didProcessEditingNotification,
                object: storage, queue: nil
            ) { note in
                guard let s = note.object as? NSTextStorage else { return }
                edited.withValue { $0.append(s.editedRange.length) }
            }
            defer { NotificationCenter.default.removeObserver(token) }

            // Differential divide mid-document: the edit stays block-scale.
            let mid = h.model.index.range(ofEntryAt: 15).location + 30
            h.textView.setSelectedRange(NSRange(location: mid, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)
            let divideMax = edited.value.max() ?? 0
            #expect(divideMax > 0, "the spy must have seen the edit")
            #expect(divideMax < docLength / 4,
                    "differential divide edited \(divideMax) of \(docLength) — must never rewrite the document")
            try expectStoreMatchesView(h)
            #expect(h.model.differentialOracleMisses == 0)

            // Merge at a seam: a 1-char text edit + block-scale re-bracket.
            edited.setValue([])
            let seam = h.model.index.range(ofEntryAt: 5).upperBound
            h.textView.setSelectedRange(NSRange(location: seam, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.mergeBlocks)
            let mergeMax = edited.value.max() ?? 0
            #expect(mergeMax > 0)
            #expect(mergeMax < docLength / 4,
                    "differential merge edited \(mergeMax) of \(docLength)")
            try expectStoreMatchesView(h)

            // The discriminator: the W confirm is the FULL path by design —
            // the same spy sees a document-scale rewrite, proving a
            // full-render regression on the everyday gestures could not
            // hide from the assertions above.
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[20].blockID, from: slots[20].variantID!)
            try h.reload()
            h.textView.setSelectedRange(NSRange(
                location: h.model.index.range(ofEntryAt: 20).location + 30, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)   // fanned -> ceremony
            edited.setValue([])
            await h.model.confirmDivideWCeremony()
            let fullMax = edited.value.max() ?? 0
            let freshLength = (h.documentText as NSString).length
            #expect(fullMax >= freshLength * 3 / 4,
                    "the W confirm rebuilds from the store (full path): saw \(fullMax) of \(freshLength)")
            try expectStoreMatchesView(h)
            #expect(h.model.differentialOracleMisses == 0)
        }
    }

    @Test func extractAndMakeBlockApplyDifferentiallyToo() async throws {
        let blocks = (0..<20).map { "Extract \($0) alpha piece. Extract \($0) beta piece. Extract \($0) tail." }
        try await withEditor(seedBlocks: blocks) { h in
            let storage = try #require(h.textView.textStorage)
            let docLength = (h.documentText as NSString).length
            let edited = LockIsolated<[Int]>([])
            let token = NotificationCenter.default.addObserver(
                forName: NSTextStorage.didProcessEditingNotification,
                object: storage, queue: nil
            ) { note in
                guard let s = note.object as? NSTextStorage else { return }
                edited.withValue { $0.append(s.editedRange.length) }
            }
            defer { NotificationCenter.default.removeObserver(token) }

            // Suffix extract on block 10.
            let r10 = h.model.index.range(ofEntryAt: 10)
            h.textView.setSelectedRange(NSRange(
                location: r10.location + r10.length - 10, length: 10))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.extractSelection)
            #expect((edited.value.max() ?? 0) < docLength / 4)
            try expectStoreMatchesView(h)

            // Make Block (middle span) on block 3.
            edited.setValue([])
            let r3 = h.model.index.range(ofEntryAt: 3)
            h.textView.setSelectedRange(NSRange(location: r3.location + 25, length: 20))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.makeBlockFromSelection)
            #expect((edited.value.max() ?? 0) < docLength / 4)
            try expectStoreMatchesView(h)
            #expect(h.model.differentialOracleMisses == 0)
            #expect(h.model.desyncRecoveryCount == 0)
        }
    }
}


@MainActor
@Suite("Review round 1 fixes (Phase 9)")
struct ReviewRound1FixTests {
    /// Stages the mid-flight window deterministically: the gesture task is
    /// suspended inside the door (structuralInFlight true) and cannot
    /// advance while the test holds the main actor synchronously.
    private func stageMidFlight(
        _ h: EditorHarness
    ) async -> Task<Void, Never> {
        h.textView.setSelectedRange(NSRange(location: 19, length: 0))
        h.model.updateCaretContext()
        let gesture = Task { await h.model.invokeGesture(.divideAtCursor) }
        for _ in 0..<200 {
            if h.model.structuralInFlight { break }
            await Task.yield()
        }
        return gesture
    }

    // MAJOR: the idle-mint clock must not birth a NEW mint mid-structural-
    // flight. Traced consequence on the old code: the mint's row can reach
    // the gesture's fresh fetch (+2 fails the +1 shape guard → renderFull
    // materializes the minted block AND the still-unconsumed tail = the
    // author's words visibly duplicated), and the late finishMint
    // crystallizes a DUPLICATE index entry (index != store; nothing heals
    // it headless). The corrupting ordering is a fetch-vs-commit race, so
    // THE PIN targets the mechanism, deterministically: with the gesture
    // provably mid-flight (structuralInFlight true, gesture suspended), the
    // idle clock fires — a mint must NOT be born. Red on the old code
    // (idleMintTail started one unconditionally); green with the flight
    // holding the clock. The post-settle consistency checks stay as the
    // belt for the traced consequence.
    @Test func anIdleMintIsNeverBornMidStructuralFlight() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one.", "Anchor."]) { h in
            let end = (h.documentText as NSString).length
            h.type("\n", at: end)
            h.type("tail paragraph waiting")
            await h.flush()

            let gesture = await stageMidFlight(h)
            #expect(h.model.structuralInFlight, "staging must reach the window")
            h.model.idleMintTail()  // the 2 s clock fires mid-flight
            #expect(!h.model.mintInFlight,
                    "a mint must not be born while a structural gesture is in flight")
            await gesture.value
            await h.settle()
            for _ in 0..<200 {
                if !h.model.mintInFlight { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            await h.settle()

            // The consequence belt: no duplicate identity, three-way agreement.
            let ids = h.model.index.entries.map(\.blockID)
            #expect(Set(ids).count == ids.count)
            try expectStoreMatchesView(h)
            #expect(h.model.desyncRecoveryCount == 0)
            #expect(h.model.differentialOracleMisses == 0)

            // The held tail still mints once the flight is over (the fix
            // re-arms the clock; nothing typed is ever lost).
            h.model.idleMintTail()
            await h.settle()
            let texts = try h.storeSlots().map(\.text)
            #expect(texts.contains("tail paragraph waiting"))
        }
    }

    // MINOR 2: the non-editable fence must hold for the WHOLE flight — a
    // header observation delivering mid-flight (the op's own touch stamp
    // triggers one) must not re-enable editing, or a keystroke in the
    // window records an autosave against pre-rewrite geometry (the
    // forbidden duplication class the fence exists for). Red on the old
    // code (adoptHeader set isEditable unconditionally).
    @Test func aMidFlightHeaderDeliveryCannotReopenTheKeystrokeFence() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one.", "Anchor."]) { h in
            let gesture = await stageMidFlight(h)
            #expect(h.model.structuralInFlight, "staging must reach the window")
            #expect(h.textView.isEditable == false, "the fence is up mid-flight")

            // The header observation delivers mid-flight, post unsealed.
            let header = try await h.database.read { [postID = h.postID] in
                try Queries.containerHeader($0, containerID: postID)
            }
            h.model.adoptHeader(header)
            #expect(h.textView.isEditable == false,
                    "a mid-flight header delivery must not reopen the fence")

            await gesture.value
            // After the flight the freshest header applies: editable again.
            #expect(h.textView.isEditable == true)
            try expectStoreMatchesView(h)
        }
    }
}

@MainActor
@Suite("Review round 2 fixes (Phase 9)")
struct ReviewRound2FixTests {
    // MINOR: cuts placed against text that drifted while the sheet sat open
    // (a sync round editing a marked take) must not reach the op — the
    // ceremony refreshes (marks kept, cuts re-seeded) instead of cutting at
    // stale offsets. Red on the old code: confirm cut the CURRENT store
    // text at the stale offset (a well-formed wrong-position cut, silent).
    @Test func aStaleCeremonyRefreshesInsteadOfCutting() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let slots = try h.storeSlots()
            let v1 = slots[0].variantID!
            let v2 = try h.session.operations.branchVariant(slots[0].blockID, from: v1)
            try h.session.operations.autosave(
                v2.id, text: "Intro pad. First alpha. First omega.", charDelta: 0)
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 15, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)
            #expect(h.model.divideWCeremony != nil)

            // A sync round lands an edit to the ACTIVE (marked) take while
            // the sheet is open — same shape, different words.
            try h.session.operations.autosave(
                v1, text: "XXXXX alpha. XXXXX omega.", charDelta: 0)

            await h.model.confirmDivideWCeremony()

            // No cut ran; the ceremony refreshed with a visible status.
            let untouched = try h.storeSlots().count
            #expect(untouched == 1, "a stale ceremony must never cut")
            let refreshed = try #require(h.model.divideWCeremony)
            #expect(h.model.statusMessage?.contains("changed") == true)
            // The refreshed active take carries the CURRENT text and a
            // re-seeded legal cut, marks preserved.
            let active = try #require(refreshed.takes.first { $0.id == v1 })
            #expect(active.marked)
            #expect(active.variant.workingText == "XXXXX alpha. XXXXX omega.")
            #expect(active.cut == 13)  // re-snapped into the current text

            // Confirming the REFRESHED ceremony cuts for real.
            await h.model.confirmDivideWCeremony()
            let divided = try h.storeSlots().map(\.text)
            #expect(divided == ["XXXXX alpha.", "XXXXX omega."])
            try expectStoreMatchesView(h)
        }
    }
}


@MainActor
@Suite("Review round 3 fixes (Phase 9)")
struct ReviewRound3FixTests {
    // MINOR: the one-gesture-at-a-time door must be self-guarding from
    // EVERY entrance — the W confirm called runStructural directly, so a
    // shortcut-invoked gesture (key equivalents stay live under a window-
    // modal sheet) could overlap a Confirm: two flights sharing one flag,
    // the first finisher's defer reopening the keystroke fence while the
    // other was still between op and rewrite (the forbidden duplication
    // class). Deterministic pin: with flight A provably suspended
    // mid-flight, a Confirm must refuse and KEEP the ceremony — on the old
    // code both operations ran to completion regardless of interleaving.
    @Test func aConfirmDuringAnotherFlightRefusesAndKeepsTheCeremony() async throws {
        try await withEditor(seedBlocks: [
            "First alpha. First omega.", "Second block. More here.",
        ]) { h in
            // A fanned block 0 with an open ceremony.
            let slots = try h.storeSlots()
            let v2 = try h.session.operations.branchVariant(
                slots[0].blockID, from: slots[0].variantID!)
            try h.session.operations.autosave(
                v2.id, text: "Intro pad. First alpha. First omega.", charDelta: 0)
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 15, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)
            #expect(h.model.divideWCeremony != nil)

            // Flight A: a shortcut divide on block 1, suspended mid-flight.
            let block1 = h.model.index.range(ofEntryAt: 1)
            h.textView.setSelectedRange(NSRange(location: block1.location + 15, length: 0))
            h.model.updateCaretContext()
            let flightA = Task { await h.model.invokeGesture(.divideAtCursor) }
            for _ in 0..<200 {
                if h.model.structuralInFlight { break }
                await Task.yield()
            }
            #expect(h.model.structuralInFlight, "staging must reach the window")

            // The Confirm lands mid-flight: it must refuse — visibly — and
            // keep the ceremony (cuts preserved), never fly a second flight.
            await h.model.confirmDivideWCeremony()
            #expect(h.model.divideWCeremony != nil,
                    "a busy refusal keeps the ceremony and its cuts")

            await flightA.value
            await h.settle()
            let texts = try h.storeSlots().map(\.text)
            // Flight A's divide landed; the W did NOT (block 0 intact).
            #expect(texts == [
                "First alpha. First omega.", "Second block.", "More here.",
            ], "the W must not have run mid-flight")
            try expectStoreMatchesView(h)

            // The refused ceremony still confirms cleanly afterwards.
            await h.model.confirmDivideWCeremony()
            let after = try h.storeSlots().map(\.text)
            #expect(after == ["First alpha.", "First omega.", "Second block.", "More here."])
            #expect(h.model.divideWCeremony == nil)
            try expectStoreMatchesView(h)
        }
    }

    // NIT (round 3, taken with its pin): external projection deliveries are
    // DEFERRED during a structural flight — the flight's surface must never
    // be rewritten under it mid-flight (geometry-safe post-round-2, but a
    // mid-flight full render clears text-undo and double-rewrites); the
    // deferred value applies through the existing settle machinery at
    // flight end. Red on the old code: applyProjection mid-flight rewrote
    // the surface immediately.
    @Test func externalDeliveriesDeferDuringAStructuralFlight() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one.", "Anchor."]) { h in
            let slots = try h.storeSlots()
            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()
            let gesture = Task { await h.model.invokeGesture(.divideAtCursor) }
            for _ in 0..<200 {
                if h.model.structuralInFlight { break }
                await Task.yield()
            }
            #expect(h.model.structuralInFlight, "staging must reach the window")

            // An external delivery lands mid-flight (its projection carries
            // a remote rewrite of the OTHER block).
            var doctored = try h.storeSlots()
            doctored[1] = slot(doctored[1].blockID, variant: doctored[1].variantID,
                               text: "Anchor, rewritten remotely.")
            let before = h.documentText
            h.model.applyProjection(doctored)
            #expect(h.documentText == before,
                    "a mid-flight delivery must defer, never rewrite the flight's surface")

            await gesture.value
            await h.settle()
            // The flight landed its divide; the deferred delivery then
            // applied through the settle re-fetch (which reads the STORE —
            // the doctored text isn't in it, so the store's truth shows).
            try expectStoreMatchesView(h)
            #expect(h.model.desyncRecoveryCount == 0)
        }
    }
}
