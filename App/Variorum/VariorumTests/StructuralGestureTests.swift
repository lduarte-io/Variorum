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

    /// **A11 (author ruling, 13d sitting 2026-07-28) — her report, at the
    /// surface where she made it:** dividing ON an empty line used to drop
    /// the blank line from both halves, so the cut visibly ATE a line of her
    /// spacing. With the k−1 ownership rule at the seam, the blank belongs to
    /// the first half and the editor's own single-`"\n"` separator re-creates
    /// the rest — so the surface she is looking at does not change at all.
    @Test func aDivideAtABlankLineLeavesTheSurfaceExactlyAsItWas() async throws {
        try await withEditor(seedBlocks: ["Para one.\n\nPara two.", "Anchor."]) { h in
            let surfaceBefore = h.documentText
            h.textView.setSelectedRange(NSRange(location: 11, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["Para one.\n", "Para two.", "Anchor."],
                    "the blank line is the FIRST half's k−1 trailing newline")
            #expect(h.documentText == surfaceBefore,
                    "…and her page is byte-identical — the blank line never went anywhere")
            try expectStoreMatchesView(h)
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
            #expect(slots.map(\.text) == ["One two.\nThree four."])  // the door join
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
        // 13b 4A fixture edit (justified): a one-SENTENCE block divides
        // under the word rule, so the genuinely-empty fixture is a
        // one-WORD block — the pin's point (refusals speak and touch
        // nothing) is unchanged.
        try await withEditor(seedBlocks: ["Onlyword."]) { h in
            let before = h.documentText
            h.textView.setSelectedRange(NSRange(location: 4, length: 0))
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

    /// **A JUSTIFIED EDIT (13j batch 4, J4): the DOOR moved, the claim did
    /// not.** ⌘⇧D on a fanned block now mints the duplicate shape (her
    /// Q-M2 ruling — pinned in `FannedDefaultsTests`); ⌥⌘⇧D routes to the W
    /// ceremony, which is what this pin has always been about, seed cut and
    /// no-rows-touched included.
    @Test func aFannedDivideRoutesToTheWCeremonyAndTouchesNoRows() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[0].blockID, from: slots[0].variantID!)
            try h.reload()

            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)

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

            // All gestures unavailable; the fan door stays open (9d) —
            // VIEWING takes is not authoring, and the seal freezes
            // authoring only (every FanPanel action still refuses at the
            // ops layer with visible copy).
            #expect(h.model.gestureAvailability == .init(takes: true))
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
            // the op must receive the SNAPPED span. 13b 4A pin edit
            // (justified): the sloppy span " sent" settles onto the word
            // edges 38..47 — the word "sentence." extracts (the old
            // sentence-only rule widened it to the whole final sentence).
            h.textView.setSelectedRange(NSRange(location: 37, length: 5))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.extractSelection)

            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["Intro clause. Middle stays here. Tail", "sentence."])
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

    @Test func contextMenuItemsFireAndSpeak() async throws {
        // 9d posture (author 2026-07-09): items stay enabled — a refused
        // invocation surfaces its copy instead of being silently swallowed
        // behind a disabled item.
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            h.textView.setSelectedRange(NSRange(location: 19, length: 0))
            h.model.updateCaretContext()
            let items = h.model.contextMenuItems()
            // 2026-07-13 (#11b): "Delete in Every Take" joins the menu —
            // the deliberate NAMED command of the sitting ruling.
            // 13j batch 4 (J4/J4b) — A JUSTIFIED EDIT: the two CEREMONY rows
            // join the menu beside the verbs whose default they used to be
            // (her sitting round-4 binding names this menu explicitly). The
            // claim is unchanged and is asserted below: every row stays
            // ENABLED and a refused one speaks.
            // 13j batch 6 — A JUSTIFIED EDIT of the same kind: her round-7
            // ruling added block ARCHIVE, and her round-4 binding names the
            // block context menu as one of its two doors. The claim below is
            // untouched: every row stays ENABLED and a refused one speaks.
            // The post-13l polish round (ledger row 4(c)) — A JUSTIFIED EDIT
            // of exactly that kind, and the one this list ITSELF made
            // visible: the menu carried "Archive Block" with no delete
            // beside it, which is the walk's P-8 finding in one line of
            // expected values. `deleteCaretBlock`'s row joins it (no
            // selection standing here, so it is the caret row). The claim
            // below is untouched: every row stays ENABLED and a refused one
            // speaks.
            // 13u4 UNIT S1 (her item 7) — A JUSTIFIED EDIT, and it is the
            // one this list itself made visible: the four PLAIN structural
            // rows were literals here AND in the menu, sitting beside two
            // ceremony rows that carried their chords, so the menu read
            // "Merge choosing takes… (⌥⌘⇧M)" directly under a silent "Merge
            // Blocks". All six rows now come from the registry through the
            // ONE chord formatter — **and so do the six expected values
            // below**, so a key she re-picks moves in the registry alone and
            // this guard follows it instead of going red. The claim below is
            // untouched: every row stays ENABLED and a refused one speaks.
            #expect(items.map(\.title) == [
                CapabilityRegistry.capability(.divide).menuTitle(),
                CapabilityRegistry.capability(.divideWithCeremony).menuTitle(),
                CapabilityRegistry.capability(.extract).menuTitle(),
                CapabilityRegistry.capability(.makeBlock).menuTitle(),
                CapabilityRegistry.capability(.merge).menuTitle(),
                CapabilityRegistry.capability(.mergeWithCeremony).menuTitle(),
                "Delete in Every Take", "Show Takes", "Archive Block",
                "Delete Block",
            ])
            // …and the chords are really there, spelled out once so the
            // registry-driven line above cannot pass vacuously.
            #expect(items.map(\.title).prefix(6) == [
                "Divide Block at Cursor (⌘⇧D)", "Divide choosing takes… (⌥⌘⇧D)",
                "Extract Selection (⌘⇧E)", "Make Block from Selection (⌘⇧K)",
                "Merge Blocks (⌘⇧M)", "Merge choosing takes… (⌥⌘⇧M)",
            ])
            let allEnabled = items.allSatisfy(\.enabled)
            #expect(allEnabled)
            // The refused door speaks: extract with a bare caret (no
            // selection) refuses with copy, never silently.
            await h.model.invokeGesture(.extractSelection)
            #expect(h.model.statusMessage == RefusalCopy.message(for: .nothingToDo))
        }
    }

    @Test func theFanDoorOpensOnAnUnfannedBlock() async throws {
        // 9d red-on-old pin for the first-branch chicken-and-egg: before
        // the fan door, an arity-1 block had NO path to its FanPanel (the
        // badge renders only on fanned blocks).
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            h.textView.setSelectedRange(NSRange(location: 5, length: 0))
            h.model.updateCaretContext()
            #expect(h.model.gestureAvailability.takes)
            let blockID = try #require(h.model.caretBlockID)
            h.model.openFan(blockID: blockID)
            let panel = try #require(h.model.fanPanel)
            #expect(panel.blockID == blockID)
            // The door opened on an ARITY-1 block — the chicken-and-egg this
            // pin exists for. Arity is a store fact (17f/P43: the panel no
            // longer carries the fan it never read).
            let fan = try await h.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            #expect(fan.count == 1)
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
    @Test func aTwoBlockSelectionMergesBinary() async throws {
        try await withEditor(seedBlocks: ["One two.", "Three four.", "Five six."]) { h in
            // Exactly two: the binary gesture, differential seam and all.
            h.textView.setSelectedRange(NSRange(location: 2, length: 9))
            h.model.updateCaretContext()
            #expect(h.model.gestureAvailability.merge)
            await h.model.invokeGesture(.mergeBlocks)
            let slots = try h.storeSlots()
            // The DOOR join (R-13u4-3, 13u4 UNIT E3 — this read "One two.
            // Three four."). `expectStoreMatchesView` below is the ruling's
            // own claim, asserted: the surface still reads byte-identically
            // what it read before the merge, because the block separator
            // the differential edit replaced is the byte it replaced it
            // with.
            #expect(slots.map(\.text) == ["One two.\nThree four.", "Five six."])
            try expectStoreMatchesView(h)
        }
    }

    /// N-way merge (author 2026-07-09, supersedes the binary rule) — the
    /// red-on-old pin: the pre-9d planner REFUSED a three-block selection
    /// (`tooManyBlocksForMerge`), so this test fails on the old code.
    @Test func aThreeBlockSelectionMergesAsAChainUnderOneUndoEntry() async throws {
        try await withEditor(seedBlocks: ["One two.", "Three four.", "Five six."]) { h in
            // Three blocks selected ("One two." | "Three four." | "Five
            // six." — C's chars start at 21).
            h.textView.setSelectedRange(NSRange(location: 2, length: 20))
            h.model.updateCaretContext()
            #expect(h.model.gestureAvailability.merge)
            await h.model.invokeGesture(.mergeBlocks)

            let merged = try h.storeSlots()
            #expect(merged.map(\.text) == ["One two.\nThree four.\nFive six."])
            try expectStoreMatchesView(h)

            // ONE compound entry: a single structural undo restores all
            // three placements and the surface.
            #expect(h.session.undoStack.depth == 1)
            #expect(h.session.undoStack.topLabel == "Merge Blocks")
            let stack = h.session.undoStack
            _ = try await h.session.runner.run { ops in try stack.undo(with: ops) }
            try h.reload()
            let restored = try h.storeSlots()
            #expect(restored.map(\.text) == ["One two.", "Three four.", "Five six."])
            #expect(h.documentText == "One two.\nThree four.\nFive six.")
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
            #expect(slots.map(\.text) == ["One two.\nThree four.", "Five six."])
        }
    }
}


/// **13j batch 4 (J4) — A JUSTIFIED EDIT to this suite's ONE opener, and the
/// DOOR moved rather than any claim.** Her 2026-08-03 ruling flipped ⌘⇧D on
/// a fanned block to the duplicating divide; ⌥⌘⇧D summons this sheet. Every
/// rule Step 6 pinned — the pre-marked seed, the propagated proposals, the
/// confirm's exact cuts, cancel touching nothing, the undo round-trip, the
/// parking positions — is pinned here unchanged, reached by the door that
/// now opens it.
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
        await h.model.invokeGesture(.divideAtCursor, ceremony: true)
        return (slots[0].variantID!, v2.id)
    }

    /// **A JUSTIFIED EDIT (18f batch 1, U-3/U-5).** Its old name was
    /// `theCeremonyPreMarksTheActiveTakeAndSeedsProposals`, and BOTH halves of
    /// that premise are retired by ruling: *"Takes should automatically be
    /// selected … and should automatically have the scissors at the end"*
    /// (U-3), so nothing opens unmarked, and the opening arrangement — not
    /// `CutPropagation` — places every other ✂. What survives unchanged is
    /// the SEED's own cut (the gesture's, snapped) and the other take's legal
    /// set, including the position propagation used to propose.
    @Test func theCeremonyOpensArrangedWithTheSeedsOwnCut() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, v2) = try await openCeremony(h)
            let state = try #require(h.model.divideWCeremony)

            let activeTake = try #require(state.takes.first { $0.id == v1 })
            #expect(activeTake.marked)
            #expect(activeTake.cut == 13)  // the gesture's snapped cut

            let otherTake = try #require(state.takes.first { $0.id == v2 })
            #expect(otherTake.marked, "U-3: every take is checked on open")
            #expect(otherTake.cut == otherTake.variant.workingText.utf16.count,
                    "U-3: …with its ✂ parked at the END")
            #expect(otherTake.parkedAtEnd)
            #expect(otherTake.boundaries.contains(24),
                    "the propagated position is still a legal one to place by hand")
        }
    }

    /// **A JUSTIFIED EDIT (18f batch 1, U-3).** Its old name was
    /// `noUniqueMatchLeavesTheTakeUnseededAndGatesConfirm`, whose premise —
    /// that a take sharing no context with the seed opens with NO cut — the
    /// ruling retires: the arrangement places every ✂, so a wholly unrelated
    /// take parks at its end like any other and the sheet is confirmable as
    /// it stands. What survives is the rest of the road: unchecking under
    /// "Choose per take…" leaves the take on the original block, and a hand
    /// placement anywhere in its legal set is accepted.
    @Test func anUnrelatedTakeStillParksAndCanBePlacedByHand() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, v2) = try await openCeremony(
                h, v2Text: "Wholly different words. Nothing shared.")
            var state = try #require(h.model.divideWCeremony)
            let otherTake = try #require(state.takes.first { $0.id == v2 })
            #expect(otherTake.parkedAtEnd, "no context to match, and none needed")
            #expect(state.canConfirm, "the arrangement placed everything")

            h.model.divideWCeremonyController.setArrangement(.perTake)
            h.model.toggleWTake(v2)
            state = try #require(h.model.divideWCeremony)
            #expect(state.takes.first { $0.id == v2 }?.marked == false)
            #expect(state.canConfirm, "the seed alone still divides")

            h.model.toggleWTake(v2)
            h.model.placeWCut(takeID: v2, cut: 24)  // after "Wholly different words. "
            state = try #require(h.model.divideWCeremony)
            #expect(state.takes.first { $0.id == v2 }?.cut == 24)
            #expect(state.canConfirm)
            _ = v1
        }
    }

    @Test func confirmPassesExactlyTheMarkedCutsToTheOp() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, v2) = try await openCeremony(h)
            // 18f batch 1 (U-3/U-5): the take arrives CHECKED and parked; this
            // pin is about the cuts the op receives, so it places the one it
            // has always placed (24) by hand under "Choose per take…".
            h.model.divideWCeremonyController.setArrangement(.perTake)
            h.model.placeWCut(takeID: v2, cut: 24)
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
            // Caret by identity: C's start — the cut's own position, the one
            // rule every divide shape lands on since the 18f ladder (R1-13; a
            // JUSTIFIED EDIT — this read "B's start", the sheet's former rule).
            #expect(h.textView.selectedRange()
                == NSRange(location: h.model.index.range(ofEntryAt: 1).location, length: 0))
            #expect(h.session.undoStack.topLabel == "Divide choosing takes")
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
            #expect(label == "Divide choosing takes")
            try h.reload()

            let restored = try h.storeSlots().map(\.text)
            #expect(restored == ["First alpha. First omega."])
            try expectStoreMatchesView(h)
        }
    }

    @Test func placeWCutRefusesIllegalPositions() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, _) = try await openCeremony(h)
            h.model.placeWCut(takeID: v1, cut: 7)  // mid-word — not a legal boundary
            let state = try #require(h.model.divideWCeremony)
            let active = try #require(state.takes.first { $0.id == v1 })
            #expect(active.cut == 13, "only click-to-place onto LEGAL boundaries")
        }
    }

    // MARK: 13b 4A — parking (S4-22 ruling 2) + the confirm gate

    @Test func placeWCutAcceptsParkingPositions() async throws {
        // Red-on-old: the old boundary list was interior-only, so placing
        // at 0 or the end silently no-opped and the cut stayed at 13.
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, _) = try await openCeremony(h)
            h.model.placeWCut(takeID: v1, cut: 25)  // the very end
            var state = try #require(h.model.divideWCeremony)
            var active = try #require(state.takes.first { $0.id == v1 })
            #expect(active.cut == 25)
            #expect(active.parkedAtEnd)
            h.model.placeWCut(takeID: v1, cut: 0)   // the very start
            state = try #require(h.model.divideWCeremony)
            active = try #require(state.takes.first { $0.id == v1 })
            #expect(active.cut == 0)
            #expect(active.parkedAtStart)
        }
    }

    @Test func allTakesParkedAtOneEndGateConfirmWithHonestCopy() async throws {
        // The architect's I10 precision: if every checked take parks at
        // one end, the other successor would be born takeless — the sheet
        // refuses the confirm state and SAYS WHY (the op's
        // divideSideWouldBeEmpty is the belt behind this gate).
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, v2) = try await openCeremony(h)
            // 18f batch 1 (U-5): this pin is the HAND-PLACED sheet's own I10
            // gate, so it names that road; the preset's voice for the same
            // refusal is pinned in `DivideArrangementTests`.
            h.model.divideWCeremonyController.setArrangement(.perTake)
            h.model.placeWCut(takeID: v1, cut: 25)   // park at the end
            h.model.placeWCut(takeID: v2, cut: 36)   // park at the end
            var state = try #require(h.model.divideWCeremony)
            #expect(!state.canConfirm)
            #expect(state.confirmBlocker?.contains("first block") == true)

            // Splitting one take anywhere reopens the door.
            h.model.placeWCut(takeID: v2, cut: 24)
            state = try #require(h.model.divideWCeremony)
            #expect(state.canConfirm)
            #expect(state.confirmBlocker == nil)

            // The mirror: everything parked at the start gates too.
            h.model.placeWCut(takeID: v1, cut: 0)
            h.model.placeWCut(takeID: v2, cut: 0)
            state = try #require(h.model.divideWCeremony)
            #expect(!state.canConfirm)
            #expect(state.confirmBlocker?.contains("second block") == true)
        }
    }

    @Test func confirmWithAParkedTakeRidesItWholeIntoOneSuccessor() async throws {
        // End-to-end through the real pipeline: v2 parks at its end — the
        // whole take rides into B; C carries only v1's ending.
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (v1, v2) = try await openCeremony(h)
            // 18f batch 1 (U-3): v2 arrives checked and parked at its end —
            // which IS this pin's setup, now reached by the ruling instead of
            // by two calls.
            let state = try #require(h.model.divideWCeremony)
            #expect(state.canConfirm)
            await h.model.confirmDivideWCeremony()

            #expect(h.model.divideWCeremony == nil, "the cut landed")
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["First alpha.", "First omega."])
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
            #expect(fanTexts[0]
                == ["First alpha.", "Intro pad. First alpha. First omega."])
            #expect(fanTexts[1] == ["First omega."],
                    "the parked take has no say in the second block")
            _ = v1
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
        #expect(RefusalCopy.message(for: .fannedMiddleSpan).contains("Divide choosing takes"),
                "fanned middle span points at the W ceremony's door")
        #expect(RefusalCopy.message(for: .middleSpanNeedsMakeBlock).contains("Make Block"),
                "extract's middle-span refusal points at the composed gesture")
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
            // 13j J4: ⌥⌘⇧D is the ceremony's door now (⌘⇧D duplicates). The
            // discriminator is unchanged — the W CONFIRM is the full path.
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
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
            // 13j J4: the ceremony's door is ⌥⌘⇧D now; the claim below is
            // untouched.
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
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
            // 13j J4: the ceremony's door is ⌥⌘⇧D now; the claim below is
            // untouched.
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
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
