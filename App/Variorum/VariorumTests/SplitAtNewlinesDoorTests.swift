//
//  SplitAtNewlinesDoorTests.swift
//  VariorumTests
//
//  **"Make every newline a block" — the DOORS** (her ruling U-6,
//  2026-09-06; the use-report round's 18c batch 3). The operation's rows are
//  pinned in core (`StructuralSplitAtNewlinesTests`); this suite is about
//  what the app does with it: the note ▾ door runs ONE compound over the
//  whole note, the block ▾ door runs one block, the bulk bars run the
//  selection, the receipt may only claim what the operation did (J8), and a
//  note with nothing to repair gets a real refusal rather than a rewrite
//  that says nothing happened (P-2).
//
//  RED-ON-OLD is not the shape here — the act is new, so its pins land WITH
//  it (the brief's item 3). The batch record carries the two behavioural
//  reverts that prove the core suite is not hollow.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("Make every newline a block — the doors (18c batch 3 — U-6)")
struct SplitAtNewlinesDoorTests {
    private func caret(_ h: EditorHarness, entry i: Int, offset: Int) {
        h.textView.setSelectedRange(
            NSRange(location: h.model.index.range(ofEntryAt: i).location + offset, length: 0))
        h.model.updateCaretContext()
    }

    // MARK: - The note ▾ door

    /// HER BUTTON. A note written with the chip off — three blocks, each
    /// carrying several paragraphs — becomes one block per paragraph, in
    /// one press.
    @Test func theNoteDoorSplitsEveryBlockAndSpeaksTheCount() async throws {
        try await withEditor(seedBlocks: [
            "One.\nTwo.", "Already whole.", "Three.\nFour.\nFive.",
        ]) { h in
            await h.model.splitEveryNewlineIntoBlocks()

            let after = try h.storeSlots()
            #expect(after.map(\.text)
                == ["One.", "Two.", "Already whole.", "Three.", "Four.", "Five."])
            let spoken = try #require(h.model.statusMessage)
            #expect(spoken == "5 blocks from 2 blocks. \u{2325}\u{2318}Z undoes.",
                    "the counts are the operations' own: 2 blocks split into 5")
            #expect(!spoken.contains("take"),
                    "no takes rode, so the receipt does not say any did (J8)")
        }
    }

    /// ONE ⌥⌘Z for the whole repair — the point of a button that replaces
    /// *"a lot of divides to run"*.
    @Test func theWholeNoteRepairIsOneUndoEntry() async throws {
        try await withEditor(seedBlocks: ["One.\nTwo.", "Three.\nFour."]) { h in
            await h.model.splitEveryNewlineIntoBlocks()
            #expect(try h.storeSlots().count == 4)
            #expect(h.session.undoStack.depth == 1, "one entry, not one per block")
            #expect(h.session.undoStack.topLabel == "Split at Newlines")

            _ = try h.session.undoStack.undo(with: h.session.operations)
            #expect(try h.storeSlots().map(\.text) == ["One.\nTwo.", "Three.\nFour."])

            _ = try h.session.undoStack.redo(with: h.session.operations)
            #expect(try h.storeSlots().map(\.text) == ["One.", "Two.", "Three.", "Four."])
        }
    }

    /// The receipt's take clause appears only when takes actually rode, and
    /// says where they went (her sentence).
    @Test func theReceiptNamesTheTakesThatStayedOnTop() async throws {
        try await withEditor(seedBlocks: ["One.\nTwo."]) { h in
            let slot = try #require(try h.storeSlots().first)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            try h.reload()

            await h.model.splitEveryNewlineIntoBlocks()

            let spoken = try #require(h.model.statusMessage)
            #expect(spoken == "2 blocks from 1 block — every take stayed with its "
                + "top paragraph. \u{2325}\u{2318}Z undoes.")
            let after = try h.storeSlots()
            #expect(after.map(\.activeVariantCount) == [3, 1],
                    "the top paragraph carries every take; the rest carry one")
        }
    }

    /// **P-2: a real refusal, not a lecture and not a rewrite.** A note that
    /// is already one paragraph per block runs no flight at all.
    @Test func aNoteWithNothingToRepairRefusesAndChangesNothing() async throws {
        try await withEditor(seedBlocks: ["One.", "Two."]) { h in
            let before = try h.storeSlots().map(\.blockID)

            await h.model.splitEveryNewlineIntoBlocks()

            #expect(h.model.statusMessage == SplitAtNewlinesCopy.noteAlreadyWhole)
            #expect(try h.storeSlots().map(\.blockID) == before)
            #expect(h.session.undoStack.depth == 0, "nothing to undo")
        }
    }

    /// A sealed note refuses through the OPERATION, spoken — the structural
    /// door's own grammar, not a door-side guess.
    @Test func aSealedNoteRefusesThroughTheOperation() async throws {
        try await withEditor(seedBlocks: ["One.\nTwo."]) { h in
            try h.session.operations.lockPost(h.postID)
            try h.reload()

            await h.model.splitEveryNewlineIntoBlocks()

            #expect(try h.storeSlots().map(\.text) == ["One.\nTwo."], "nothing moved")
            let spoken = try #require(h.model.statusMessage)
            #expect(spoken != SplitAtNewlinesCopy.noteAlreadyWhole)
            #expect(spoken.count > 0, "the refusal is SPOKEN, never silent")
        }
    }

    /// The caret stays where she was reading: in the first successor of the
    /// block it was in.
    @Test func theCaretLandsInTheFirstSuccessorOfTheBlockItWasIn() async throws {
        try await withEditor(seedBlocks: ["One.\nTwo.", "Three.\nFour."]) { h in
            caret(h, entry: 1, offset: 2)

            await h.model.splitEveryNewlineIntoBlocks()

            let after = try h.storeSlots()
            #expect(h.model.caretBlockID == after[2].blockID,
                    "block two's first paragraph — not the note's first block")
        }
    }

    // MARK: - The block ▾ door

    @Test func theBlockDoorSplitsOnlyTheCaretBlock() async throws {
        try await withEditor(seedBlocks: ["One.\nTwo.", "Three.\nFour."]) { h in
            caret(h, entry: 0, offset: 1)

            await h.model.splitCaretBlockAtNewlines()

            let after = try h.storeSlots()
            #expect(after.map(\.text) == ["One.", "Two.", "Three.\nFour."])
            #expect(h.model.statusMessage
                == "2 blocks from 1 block. \u{2325}\u{2318}Z undoes.")
            #expect(h.session.undoStack.depth == 1)
        }
    }

    @Test func theBlockDoorOnAWholeBlockSaysSoAndWritesNothing() async throws {
        try await withEditor(seedBlocks: ["One.", "Two."]) { h in
            caret(h, entry: 0, offset: 1)

            await h.model.splitCaretBlockAtNewlines()

            #expect(h.model.statusMessage == SplitAtNewlinesCopy.blockAlreadyWhole)
            let after = try h.storeSlots()
            #expect(after.count == 2)
            #expect(h.session.undoStack.depth == 0)
        }
    }

    // MARK: - The copy's own truth (J8)

    @Test func theReceiptOnlyClaimsWhatTheResultsHold() {
        let noOp = Operations.SplitAtNewlinesResult(
            blockIDs: ["b"], takesKeptOnTop: 0, takesLeftBehind: 0)
        #expect(SplitAtNewlinesCopy.receipt([noOp], whenNothingSplit: "nothing") == "nothing",
                "a note where nothing split never claims a number")

        let plain = Operations.SplitAtNewlinesResult(
            blockIDs: ["a", "b", "c"], takesKeptOnTop: 0, takesLeftBehind: 0)
        let plainLine = SplitAtNewlinesCopy.receipt([plain, noOp], whenNothingSplit: "nothing")
        #expect(plainLine == "3 blocks from 1 block. \u{2325}\u{2318}Z undoes.",
                "the no-op leg is not counted — it was not acted on")
        #expect(!plainLine.contains("take"))

        let fanned = Operations.SplitAtNewlinesResult(
            blockIDs: ["a", "b"], takesKeptOnTop: 2, takesLeftBehind: 1)
        let fannedLine = SplitAtNewlinesCopy.receipt([fanned], whenNothingSplit: "nothing")
        #expect(fannedLine.contains("every take stayed with its top paragraph"))
        #expect(fannedLine.contains("1 empty take stayed with the original block"),
                "a take that stopped following the block she split is named, never swallowed")
        #expect(fannedLine.hasSuffix("\u{2325}\u{2318}Z undoes."),
                "every receipt names the road back")
    }

    // MARK: - The registry (P-1)

    @Test func theThreeActsAreDeclaredWithTheirDoors() {
        let note = CapabilityRegistry.capability(.splitEveryNewlineIntoBlocks)
        #expect(note.verb == "Make Every Newline a Block")
        #expect(note.scope == .post)
        #expect(note.doors == [.bottomBar])
        #expect(note.shortcutLabel == nil, "a deliberate repair is not daily chrome")

        let block = CapabilityRegistry.capability(.splitBlockAtNewlines)
        #expect(block.scope == .block)
        #expect(block.doors == [.bottomBar])

        let picked = CapabilityRegistry.capability(.splitSelectedBlocksAtNewlines)
        #expect(picked.scope == .block)
        #expect(picked.doors == [.surface])

        // R118: Takes is never behind Write — all three act natively there.
        let takes = CapabilityContext(mode: .takes)
        for id: CapabilityID in [
            .splitEveryNewlineIntoBlocks, .splitBlockAtNewlines, .splitSelectedBlocksAtNewlines,
        ] {
            #expect(CapabilityRegistry.capability(id).availability(takes) == .act,
                    "\(id) acts on the board too")
            #expect(CapabilityRegistry.capability(id).takesAccess == .native)
        }
    }

    /// Both bars render the note ▾ and block ▾ rows — R6-2's one grammar,
    /// which is what keeps a door from being a Write privilege.
    @Test func bothBarsRenderTheTwoMenuDoors() {
        for id: CapabilityID in [.splitEveryNewlineIntoBlocks, .splitBlockAtNewlines] {
            #expect(CommitBar.renderedCapabilities.contains(id))
            #expect(TakesBottomBar.renderedCapabilities.contains(id))
        }
        #expect(BlocksWorkbenchView.surfaceCapabilities.contains(.splitSelectedBlocksAtNewlines))
        #expect(TakesBoardView.surfaceCapabilities.contains(.splitSelectedBlocksAtNewlines))
    }
}
