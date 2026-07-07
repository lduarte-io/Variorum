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

            let request = try #require(h.model.divideWRequest)
            #expect(request.blockID == slots[0].blockID)
            #expect(request.activeCut == 16)  // the active take's snapped cut
            // Routing only: the live editor and the store are untouched.
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
