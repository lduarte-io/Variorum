//
//  FannedDefaultsTests.swift
//  VariorumTests
//
//  **THE FANNED DEFAULTS.** Dividing a fanned block KEEPS THE TAKES ON THE
//  TOP BLOCK (her ruling U-2, 2026-09-06 — the use-report round's 18c batch
//  1) and merging a fanned pair CARRIES ALL (2026-08-09); both ceremonies
//  survive behind ⌥⌘⇧D / ⌥⌘⇧M, byte-unchanged.
//
//  **THE DIVIDE PINS' PREMISE CHANGED, and the old ones are named rather
//  than deleted** (18c batch 1). These four held 13j J4's DUPLICATE shape
//  (her Q-M2 ruling, 2026-08-03: every other take copied onto BOTH
//  successors, "quick to delete"), which U-2 retires in her own words: *"I
//  know I said that should be the default, but I honestly believe now that
//  if you divide, the takes should automatically stay on the top block that
//  you divided."*
//
//  - `aFannedDivideDuplicatesInsteadOfOpeningTheCeremony`
//        → `aFannedDivideKeepsTheTakesOnTheTopBlock`
//  - `theDuplicatedTakesLandOnBothSuccessorsWithTheirLabels`
//        → `theOtherTakesRideWholeOntoTheTopBlockWithTheirLabels`
//  - `theDuplicatingDivideIsOneStructuralUndoEntry`
//        → `theKeepOnTopDivideIsOneStructuralUndoEntry`
//  - `theDivideReceiptTellsTheDuplicateShapeTruth`
//        → `theDivideReceiptTellsTheKeepOnTopTruth`
//
//  RED-ON-OLD (behavioral revert, run and recorded in the batch record):
//
//  - **Revert A** — both keep-on-top doors' `ops.divideW(cuts:)` swapped
//    back to `ops.divideDuplicating(blockID, displayedVariantID:, cut:)`
//    (`EditorSurfaceController.runKeepOnTopDivide`,
//    `TakesStructureController.runKeepOnTopDivide`; the surrounding code is
//    shape-compatible, so the swap is one call each). RED: every renamed
//    pin above, `theCompositionParksEveryOtherTakeAtItsEnd`'s store half,
//    `theBoardsDivideDoorKeepsTheTakesOnTop`.
//  - **Revert B** — `.merge`'s arm back to `openMergeCeremony` on any fan.
//    RED: `aFannedMergeCarriesEveryTakeOntoTheMergedBlock`,
//    `theCarriedTakesKeepTheirTextAndLabels`,
//    `theMergeReceiptCountsWhatLanded`.
//  - **Revert C** — `CarryAllMerge.compose` returning its carries as `[]`.
//    RED: `theCompositionCarriesEveryOtherActiveTake`,
//    `aFannedMergeCarriesEveryTakeOntoTheMergedBlock`,
//    `aChainWithAFannedLinkCarriesEveryTakeAlong`.
//  - **Revert D** — the two ceremony doors' `guard !ceremony` refusals
//    dropped. RED: `theDivideCeremonyDoorOnAnUnfannedBlockRefusesAndNamesThePlainDoor`,
//    `theMergeCeremonyDoorOnAnUnfannedPairRefuses`,
//    `theMergeCeremonyDoorOnAChainRefusesAndNamesTheChainRoad`.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The fanned defaults (13j batch 4 — J4/J4b)")
struct FannedDefaultsTests {
    // MARK: - Helpers

    /// Selects across two adjacent blocks by entry index (the merge
    /// ceremony suite's own helper, reused so both suites drive one gesture
    /// the same way).
    private func selectAcross(_ h: EditorHarness, _ i: Int, _ j: Int) {
        let start = h.model.index.range(ofEntryAt: i).location + 1
        let end = h.model.index.range(ofEntryAt: j).location + 1
        h.textView.setSelectedRange(NSRange(location: end, length: 0))
        h.textView.setSelectedRange(NSRange(location: start, length: end - start))
        h.model.updateCaretContext()
    }

    private func caret(_ h: EditorHarness, entry i: Int, offset: Int) {
        h.textView.setSelectedRange(
            NSRange(location: h.model.index.range(ofEntryAt: i).location + offset, length: 0))
        h.model.updateCaretContext()
    }

    private func fan(
        _ h: EditorHarness, _ blockID: String
    ) throws -> [Variant] {
        try h.database.read { db in
            try Queries.blockFan(db, blockID: blockID)
                .filter { $0.deletedAt == nil && $0.status == .active }
        }
    }

    // MARK: - U-2: the divide default keeps the takes on the top block

    /// THE U-2 pin (red-on-old, revert A) — the rewrite of J4's
    /// `aFannedDivideDuplicatesInsteadOfOpeningTheCeremony`, whose premise
    /// (every other take copied onto BOTH successors) her 2026-09-06 ruling
    /// retires: ⌘⇧D on a fanned block still opens no sheet, and now the
    /// other takes STAY ON THE FIRST BLOCK.
    @Test func aFannedDivideKeepsTheTakesOnTheTopBlock() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            #expect(h.model.divideWCeremony == nil, "the default no longer asks")
            let after = try h.storeSlots()
            #expect(after.count == 2, "two blocks stand where one stood")
            #expect(after.allSatisfy { $0.blockID != slot.blockID },
                    "A is released preserved — both successors are fresh blocks")
            // The page reads exactly as it did, split in two: each successor
            // renders its half of the take she was in.
            #expect(after[0].text == "Alpha one.")
            #expect(after[1].text == "Alpha two.")
            #expect(after[0].activeVariantCount == 2,
                    "the top block: her cut half plus the other take, whole")
            #expect(after[1].activeVariantCount == 1,
                    "the bottom block carries the second half ALONE — no copies")
        }
    }

    /// The rewrite of `theDuplicatedTakesLandOnBothSuccessorsWithTheirLabels`.
    /// A whole-take ride still keeps its name (the rule survived the flip);
    /// what changed is that it rides ONCE, onto the top block.
    @Test func theOtherTakesRideWholeOntoTheTopBlockWithTheirLabels() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            let other = try h.session.operations.branchVariant(
                slot.blockID, from: slot.variantID!)
            let otherText = "A wholly different second attempt entirely."
            try h.session.operations.autosave(
                other.id, text: otherText, charDelta: otherText.count)
            try h.session.operations.setTakeLabel(other.id, label: "the spare")
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            let after = try h.storeSlots()
            let top = try fan(h, after[0].blockID)
            #expect(top.map(\.workingText) == ["Alpha one.", otherText],
                    "the cut half leads; the other take follows it whole")
            let ride = try #require(top.first { $0.workingText == otherText })
            #expect(ride.label == "the spare", "a whole-take ride keeps its name")
            #expect(ride.id != other.id, "a COPY — the source take stays on A")
            #expect(!ride.locked, "copies are never born locked")

            let bottom = try fan(h, after[1].blockID)
            #expect(bottom.map(\.workingText) == ["Alpha two."],
                    "nothing followed the second half")
            // A itself is preserved WHOLE, off-stage, with its own takes.
            let sourceTakes = try fan(h, slot.blockID)
            #expect(sourceTakes.count == 2, "the original keeps every take it had")
            #expect(sourceTakes.contains { $0.id == other.id })
        }
    }

    /// The rewrite of `theDuplicatingDivideIsOneStructuralUndoEntry`. The
    /// entry is still ONE and still reads "Divide" — the composition wraps
    /// `divideW` (whose own label names the ceremony) in a one-leg compound
    /// so the Edit menu keeps its word.
    @Test func theKeepOnTopDivideIsOneStructuralUndoEntry() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)
            do { let n = try h.storeSlots().count; #expect(n == 2) }
            #expect(h.session.undoStack.topLabel == "Divide")

            _ = try h.session.undoStack.undo(with: h.session.operations)
            let back = try h.storeSlots()
            #expect(back.count == 1, "one ⌥⌘Z puts the block back")
            #expect(back[0].blockID == slot.blockID, "and it is the ORIGINAL block")
            #expect(back[0].activeVariantCount == 2, "with its fan intact")

            // …and the exact-row redo puts the successors back as they were
            // (the 13c rule: `register(redo:)` is required, and a compound
            // is redoable only when every leg is).
            _ = try h.session.undoStack.redo(with: h.session.operations)
            let again = try h.storeSlots()
            #expect(again.count == 2)
            #expect(again.map(\.text) == ["Alpha one.", "Alpha two."])
            #expect(again.map(\.activeVariantCount) == [2, 1])
        }
    }

    /// The receipt may only claim what the operation did (the J8 doctrine).
    /// The rewrite of `theDivideReceiptTellsTheDuplicateShapeTruth`: the old
    /// sentence promised copies on each side and named her "quick to delete"
    /// consequence, which after U-2 would be a lie.
    @Test func theDivideReceiptTellsTheKeepOnTopTruth() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            let spoken = try #require(h.model.statusMessage)
            #expect(spoken == FannedDefaultsCopy.divided(kept: 2))
            #expect(spoken.contains("2 other takes stayed on the first"),
                    "it counts what actually rode, and says where")
            #expect(!spoken.contains("quick to delete"),
                    "the duplicate shape's consequence is gone with the shape")
        }
    }

    /// **The boards' bottom-bar help tells the same truth the receipt does**
    /// (ledger row 46; the 18f ladder's R3-4). The bar's Divide help still
    /// narrated the retired J4 duplicate default — *"the rest are copied
    /// whole onto both halves"* — beside a receipt that already said the
    /// takes stayed on the first block. J8: a door's own words may not name
    /// a behaviour the app no longer has. Pinned beside the receipt's pins
    /// because they are one sentence in two places.
    @Test func theBoardBarsStructuralHelpsTellTheKeepOnTopTruth() {
        let helps = Dictionary(
            uniqueKeysWithValues: TakesBottomBar.structuralBar.map { ($0.act, $0.help) })
        let divide = try? #require(helps[.divide])
        #expect(divide?.contains("stay whole on the top block") == true)
        #expect(divide?.contains("onto both") == false,
                "the duplicate shape is gone from the words too")
        #expect(divide?.contains(CapabilityRegistry.capability(.divideWithCeremony).verb) == true,
                "it names the door that arranges them, not a bare chord")
        #expect(helps[.merge]?.contains("pair takes by hand") == false,
                "pairing is one of the three options on the row below it")
    }

    /// The matrix's wide end: five takes, four of them riding — and the
    /// top block's fan is A's OWN fan order with the divided take swapped
    /// for its first half (the W's letter: contributors are collected in
    /// fan order). The rendered take is still hers wherever it sits.
    @Test func aFiveTakeBlockKeepsFourTakesOnTheTopBlock() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            let chosen = try #require(slot.variantID)
            for i in 1...4 {
                let take = try h.session.operations.branchVariant(slot.blockID, from: chosen)
                let text = "Take number \(i) entirely."
                try h.session.operations.autosave(
                    take.id, text: text, charDelta: text.count)
            }
            let sourceFan = try fan(h, slot.blockID)
            #expect(sourceFan.count == 5)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            let after = try h.storeSlots()
            #expect(after.map(\.activeVariantCount) == [5, 1])
            #expect(after.map(\.text) == ["Alpha one.", "Alpha two."],
                    "the page reads as it did, split in two")
            #expect(try fan(h, after[0].blockID).map(\.workingText)
                == sourceFan.map { $0.id == chosen ? "Alpha one." : $0.workingText },
                    "A's own fan order, the divided take swapped for its first half")
            #expect(try fan(h, after[1].blockID).map(\.workingText) == ["Alpha two."])
            #expect(h.model.statusMessage == FannedDefaultsCopy.divided(kept: 4))
        }
    }

    /// An EMPTY other take has no legal cut at all (0 and its end coincide,
    /// and `divideW` refuses that as `invalidCut`), so it cannot park: it
    /// stays on the released original with the archived takes — and the
    /// receipt SAYS SO rather than letting a take vanish from her page
    /// without a word.
    @Test func anEmptyOtherTakeStaysOnTheOriginalAndTheReceiptSaysSo() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            let blank = try h.session.operations.branchVariant(
                slot.blockID, from: slot.variantID!)
            try h.session.operations.autosave(blank.id, text: "", charDelta: -21)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            let after = try h.storeSlots()
            #expect(after.count == 2, "the divide still happened")
            #expect(after.map(\.activeVariantCount) == [1, 1],
                    "the blank take rode nowhere")
            #expect(try fan(h, slot.blockID).contains { $0.id == blank.id },
                    "it stayed on the original, preserved whole")
            #expect(h.model.statusMessage
                == FannedDefaultsCopy.divided(kept: 0, stayedBehind: 1))
        }
    }

    /// Byte-unchanged where no fan exists: the source keeps its identity as
    /// the first half, and only the second half is minted (AppSpec §9).
    @Test func anUnfannedDivideIsUntouched() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            let after = try h.storeSlots()
            #expect(after.count == 2)
            #expect(after[0].blockID == slot.blockID, "A keeps its identity as the first half")
            #expect(after[0].text == "Alpha one.")
            #expect(after[1].text == "Alpha two.")
            #expect(h.model.divideWCeremony == nil)
        }
    }

    /// A LOCKED take does not refuse the fanned default: the op COPIES
    /// texts and never edits a buffer (the W's own rule, and the ceremony's
    /// reason for allowing locks). The plain in-place divide still refuses a
    /// lock, which is why this is worth stating rather than assuming. The
    /// rewrite of `aLockedTakeDoesNotRefuseTheDuplicatingDivide` — with the
    /// other half stated too, since under keep-on-top a locked OTHER take is
    /// the one that has to PARK.
    @Test func aLockedTakeDoesNotRefuseTheKeepOnTopDivide() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let other = try h.session.operations.branchVariant(slot.blockID, from: chosen)
            try h.session.operations.autosave(
                other.id, text: "A locked spare take.", charDelta: 20)
            try h.session.operations.lockVariant(chosen)
            try h.session.operations.lockVariant(other.id)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            let after = try h.storeSlots()
            #expect(after.count == 2, "the copy road does not care about the lock")
            #expect(after.map(\.text) == ["Alpha one.", "Alpha two."])
            #expect(try fan(h, after[0].blockID).map(\.workingText)
                == ["Alpha one.", "A locked spare take."],
                    "a locked take parks like any other — its buffer is copied, never edited")
            #expect(after.allSatisfy { !$0.variantLocked },
                    "and the halves are not born locked")
            #expect(try fan(h, after[0].blockID).allSatisfy { !$0.locked },
                    "nor is the parked copy")
        }
    }

    /// A is released PRESERVED WHOLE, so re-pointing at it is the way back
    /// that does not go through undo (AppSpec §9's `placeBlock`, the W
    /// resolution's own reversibility).
    @Test func theReleasedOriginalIsStillPlaceable() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            let post = try #require(h.model.postID)
            _ = try h.session.operations.placeBlock(slot.blockID, in: post, at: .end)
            let after = try h.storeSlots()
            #expect(after.count == 3)
            #expect(after.contains { $0.blockID == slot.blockID },
                    "the original stands again, with its whole fan")
            #expect(try fan(h, slot.blockID).count == 2)
        }
    }

    // MARK: - The keep-on-top composition, pure

    @Test func theCompositionParksEveryOtherTakeAtItsEnd() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let other = try h.session.operations.branchVariant(slot.blockID, from: chosen)
            try h.session.operations.autosave(
                other.id, text: "Twelve chars", charDelta: 12)
            let live = try fan(h, slot.blockID)

            let composition = try #require(KeepOnTopDivide.compose(
                displayedID: chosen, cut: 11, fan: live))
            #expect(composition.cuts == [chosen: 11, other.id: 12],
                    "the displayed take's snapped cut; every other take at its own end")
            #expect(composition.displayedID == chosen)
            #expect(composition.parked == 1)
            #expect(composition.unparkable.isEmpty)

            // The mirror preset (U-5's second): they follow the BOTTOM block.
            let below = try #require(KeepOnTopDivide.compose(
                keepBelow: chosen, cut: 11, fan: live))
            #expect(below.cuts == [chosen: 11, other.id: 0])
        }
    }

    @Test func theCompositionLeavesAnEmptyTakeUnparkedAndCountsIt() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let blank = try h.session.operations.branchVariant(slot.blockID, from: chosen)
            try h.session.operations.autosave(blank.id, text: "", charDelta: -21)
            let live = try fan(h, slot.blockID)

            let composition = try #require(KeepOnTopDivide.compose(
                displayedID: chosen, cut: 11, fan: live))
            #expect(composition.cuts == [chosen: 11], "the blank take is not marked")
            #expect(composition.unparkable == [blank.id])
            #expect(composition.parked == 0)
        }
    }

    @Test func theCompositionRefusesWhenTheDisplayedTakeIsGone() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            _ = try h.session.operations.branchVariant(
                slot.blockID, from: slot.variantID!)
            let live = try fan(h, slot.blockID)

            #expect(KeepOnTopDivide.compose(
                displayedID: "vanished", cut: 11, fan: live) == nil,
                    "the F-3 guard: a fallback would divide a take she was never in")
            #expect(KeepOnTopDivide.compose(displayedID: nil, cut: 11, fan: live) == nil)
        }
    }

    // MARK: - J4's ceremony door

    @Test func theDivideCeremonyDoorStillOpensTheSheetUnchanged() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)

            let state = try #require(h.model.divideWCeremony, "⌥⌘⇧D summons the W sheet")
            #expect(state.blockID == slot.blockID)
            #expect(state.takes.count == 2)
            do { let n = try h.storeSlots().count; #expect(n == 1, "opening touches no rows") }
        }
    }

    @Test func theDivideCeremonyDoorOnAnUnfannedBlockRefusesAndNamesThePlainDoor() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)

            #expect(h.model.divideWCeremony == nil)
            do { let n = try h.storeSlots().count; #expect(n == 1, "nothing was divided") }
            let spoken = try #require(h.model.statusMessage)
            #expect(spoken == FannedDefaultsCopy.divideCeremonyNeedsAFan)
            #expect(spoken.contains("⌘⇧D"), "the refusal names the door that CAN act")
        }
    }

    // MARK: - J4b: the merge default

    /// THE J4b pin (red-on-old, reverts B and C): ⌘⇧M on a fanned pair no
    /// longer opens a sheet — every take rides onto the merged block.
    @Test func aFannedMergeCarriesEveryTakeOntoTheMergedBlock() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks)

            #expect(h.model.mergeCeremony == nil, "the default no longer asks")
            let after = try h.storeSlots()
            #expect(after.count == 1, "one block stands where two stood")
            // R-13u4-3 (13u4 UNIT E3): the canon rule IS the rendering
            // join now — this read "Alpha one. Beta two." before it.
            #expect(after[0].text == "Alpha one.\nBeta two.", "the join is the canon rule")
            #expect(after[0].activeVariantCount == 2,
                    "the joined take + the trailing block's other take, carried whole")
        }
    }

    @Test func theCarriedTakesKeepTheirTextAndLabels() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let spare = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            let spareText = "An entirely separate second thought."
            try h.session.operations.autosave(
                spare.id, text: spareText, charDelta: spareText.count)
            try h.session.operations.setTakeLabel(spare.id, label: "spare")
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks)

            let merged = try #require(try h.storeSlots().first)
            let takes = try fan(h, merged.blockID)
            let carried = try #require(takes.first { $0.workingText == spareText })
            #expect(carried.label == "spare", "a carried take rides with its name")
            #expect(carried.id != spare.id, "a fresh row on the merged block")
            let chosen = try #require(takes.first { $0.id == merged.variantID })
            #expect(chosen.workingText == "Alpha one.\nBeta two.",
                    "the CHOSEN take is the joined one — the core's rendered×rendered rule")
        }
    }

    @Test func theMergeReceiptCountsWhatLanded() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[0].blockID, from: slots[0].variantID!)
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks)

            let spoken = try #require(h.model.statusMessage)
            #expect(spoken == FannedDefaultsCopy.merged(carried: 2))
            #expect(spoken.contains("2 other takes"))
            #expect(!spoken.contains("stays with the released"),
                    "nothing stays behind on this road — the old sentence would be a lie")
        }
    }

    @Test func anUnfannedMergeIsUntouched() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks)

            #expect(h.model.mergeCeremony == nil)
            let after = try h.storeSlots()
            #expect(after.count == 1)
            #expect(after[0].text == "Alpha one.\nBeta two.")
            #expect(after[0].activeVariantCount == 1, "one take, exactly as before")
        }
    }

    // MARK: - J4b's ceremony door

    @Test func theMergeCeremonyDoorStillOpensTheSheetPrePaired() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            let state = try #require(h.model.mergeCeremony, "⌥⌘⇧M summons the pairing sheet")
            #expect(state.pairings.count == 1, "pre-paired with the two rendered takes")
            do { let n = try h.storeSlots().count; #expect(n == 2, "opening touches no rows") }
        }
    }

    @Test func theMergeCeremonyDoorOnAnUnfannedPairRefuses() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            #expect(h.model.mergeCeremony == nil)
            do { let n = try h.storeSlots().count; #expect(n == 2, "nothing was merged") }
            #expect(h.model.statusMessage == FannedDefaultsCopy.mergeCeremonyNeedsAFan)
        }
    }

    /// **RETIRED AND REPLACED (18f batch 1, her U-16).** The pin was
    /// `theMergeCeremonyDoorOnAChainRefusesAndNamesTheChainRoad`, whose
    /// premise — that a run of three or more has no ceremony to open — her
    /// ruling retires: *"if you're merging several notes together you should
    /// be given the choice of bringing every take or only the currently shown
    /// ones, but i don't want a super complex ceremony."* The door now ASKS,
    /// with exactly two options and no pairing surface.
    @Test func theMergeCeremonyDoorOnAChainOffersTwoChoicesAndNoPairing() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try h.reload()

            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            let state = try #require(h.model.mergeCeremony, "the door asks now")
            #expect(state.isRun)
            #expect(state.blockIDs.count == 3)
            #expect(state.arrangement == .bringEveryTake, "the carry-all default is selected")
            #expect(state.offeredArrangements == [.bringEveryTake, .onlyTheShownOnes],
                    "U-16: two options, and never the pairing surface")
            #expect(state.firstTakes.isEmpty && state.secondTakes.isEmpty,
                    "…so the pairing columns carry nothing at all")
            #expect(state.otherTakes == 1, "the spare take, counted for the sentence")
            do { let n = try h.storeSlots().count; #expect(n == 3, "opening touched no rows") }
        }
    }

    /// A run with NO fan anywhere has one answer, not two — the door speaks
    /// the standing needs-a-fan refusal rather than asking.
    @Test func theMergeCeremonyDoorOnAFanlessChainStillRefuses() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            #expect(h.model.mergeCeremony == nil)
            do { let n = try h.storeSlots().count; #expect(n == 3, "nothing was merged") }
            let spoken = try #require(h.model.statusMessage)
            #expect(spoken == FannedDefaultsCopy.mergeCeremonyNeedsAFan)
        }
    }

    // MARK: - The N-way chain's carry-all links

    @Test func aChainWithAFannedLinkCarriesEveryTakeAlong() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[0].blockID, from: slots[0].variantID!)
            try h.reload()

            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks)

            let after = try h.storeSlots()
            #expect(after.count == 1, "the whole run became one block")
            #expect(after[0].text == "Alpha one.\nBeta two.\nGamma three.")
            #expect(after[0].activeVariantCount == 2,
                    "the joined take + the first block's other take, carried through the chain")
            #expect(h.session.undoStack.topLabel == "Merge Blocks")
            _ = try h.session.undoStack.undo(with: h.session.operations)
            do { let n = try h.storeSlots().count; #expect(n == 3, "ONE ⌥⌘Z restores the whole run") }
        }
    }

    @Test func anUnfannedChainKeepsItsShippedBehaviour() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks)

            let after = try h.storeSlots()
            #expect(after.count == 1)
            // "Its shipped behaviour" is the CHAIN's shape — one block,
            // one take; the join moved with the ruling on every link.
            #expect(after[0].text == "Alpha one.\nBeta two.\nGamma three.")
            #expect(after[0].activeVariantCount == 1, "one take, as it has always been")
        }
    }

    /// **THE A5 PIN (13j ladder A round 1 — red-on-old by behavioral
    /// revert).** A fanned chain link whose displayed take no longer
    /// resolves in the live fan used to fall to plain `merge` INSIDE the
    /// compound — folding that fan to lineage with no speech, where the pair
    /// road refuses. The whole run now refuses BEFORE the compound opens:
    /// nothing merged, nothing released, the pair road's own words.
    ///
    /// The repro is the frozen-projection property itself, no race needed:
    /// the surface loads, the store's chosen take moves and the old one
    /// dies through ordinary ops, and the un-reloaded chain still names the
    /// dead take as "displayed".
    @Test func aChainWithAStaleDisplayedTakeRefusesWholeAndTouchesNothing() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            let ops = h.session.operations
            let slots = try h.storeSlots()
            let original = try #require(slots[0].variantID)
            let take2 = try ops.branchVariant(slots[0].blockID, from: original)
            _ = try ops.branchVariant(slots[0].blockID, from: original)
            try h.reload()  // the surface shows ORIGINAL as block 0's take

            // The store moves under the frozen projection: the slot now
            // chooses take2 and the once-displayed original is deleted —
            // legal, ordinary ops. The fan stays fanned (2 takes).
            try ops.chooseVariant(slots[0].blockID, variantID: take2.id)
            try ops.deleteVariant(original)

            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks)

            #expect(h.model.statusMessage == FannedDefaultsCopy.takesChangedMerge,
                    "the whole run refuses up front, in the pair road's words")
            let after = try h.storeSlots()
            #expect(after.count == 3, "nothing merged — no row was touched")
            #expect(try fan(h, slots[0].blockID).count == 2,
                    "no fan folded to lineage on the quiet")
        }
    }

    /// A5's validation brain, pure — the matrix a store test cannot reach
    /// deterministically. An EMPTY side passes through deliberately: the
    /// plain road's own op refusal (typed, loud, whole compound rolled
    /// back) is the honest diagnosis for a block with no takes at all (the
    /// gap class), where "takes changed" would misname it.
    @Test func theChainValidationRefusesStaleDisplayedTakesAndPassesGapsThrough() {
        func take(_ id: String) -> Variant {
            Variant(id: id, blockId: "b", fanPosition: id,
                    createdAt: Date(timeIntervalSince1970: 0),
                    updatedAt: Date(timeIntervalSince1970: 0))
        }
        let fanned = [take("x"), take("y")]
        let single = [take("s")]

        // Healthy: every displayed take resolves.
        #expect(CarryAllMerge.chainComposes(
            order: ["a", "b"], fans: ["a": fanned, "b": single],
            displayed: ["a": "x", "b": "s"]))
        // The race class: a fanned link's displayed take is gone.
        #expect(!CarryAllMerge.chainComposes(
            order: ["a", "b"], fans: ["a": fanned, "b": single],
            displayed: ["a": "gone", "b": "s"]))
        #expect(!CarryAllMerge.chainComposes(
            order: ["a", "b"], fans: ["a": single, "b": fanned],
            displayed: ["a": "s", "b": nil]))
        // …anywhere down the run, not only at link 1.
        #expect(!CarryAllMerge.chainComposes(
            order: ["a", "b", "c"],
            fans: ["a": single, "b": single, "c": fanned],
            displayed: ["a": "s", "b": "s", "c": "gone"]))
        // An unfanned link never demands a displayed take.
        #expect(CarryAllMerge.chainComposes(
            order: ["a", "b"], fans: ["a": single, "b": single],
            displayed: ["a": nil, "b": nil]))
        // The gap class passes through: an EMPTY side is the op's to refuse
        // (loudly), never this guard's.
        #expect(CarryAllMerge.chainComposes(
            order: ["a", "b"], fans: ["a": fanned, "b": []],
            displayed: ["a": "x", "b": nil]))
        #expect(CarryAllMerge.chainComposes(
            order: ["a", "b"], fans: ["a": [], "b": fanned],
            displayed: ["a": nil, "b": "x"]))
    }

    // MARK: - The composition brain, pure

    @Test func theCompositionCarriesEveryOtherActiveTake() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let spareA = try h.session.operations.branchVariant(
                slots[0].blockID, from: slots[0].variantID!)
            let spareB = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            let leadingFan = try fan(h, slots[0].blockID)
            let trailingFan = try fan(h, slots[1].blockID)

            let composition = try #require(CarryAllMerge.compose(
                leadingDisplayedID: slots[0].variantID, leadingFan: leadingFan,
                trailingDisplayedID: slots[1].variantID, trailingFan: trailingFan))

            #expect(composition.pairing.firstVariantID == slots[0].variantID)
            #expect(composition.pairing.secondVariantID == slots[1].variantID)
            #expect(composition.pairing.join == MergeJoinRule.door.join(
                head: "Alpha one.", tail: "Beta two."),
                    "the join is merge's own door rule, never a guess")
            // …which is the rendering join since her R-13u4-3 (this pin
            // read `.space` through `MergeJoin.canon` before 13u4 UNIT E3).
            #expect(composition.pairing.join == .newline)
            #expect(Set(composition.carries) == [spareA.id, spareB.id],
                    "every OTHER active take, both sides")
        }
    }

    @Test func theCompositionRefusesWhenADisplayedTakeIsGone() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let leadingFan = try fan(h, slots[0].blockID)
            let trailingFan = try fan(h, slots[1].blockID)

            #expect(CarryAllMerge.compose(
                leadingDisplayedID: "vanished", leadingFan: leadingFan,
                trailingDisplayedID: slots[1].variantID, trailingFan: trailingFan) == nil,
                    "the F-3 guard: a fallback would join a take she never saw")
            #expect(CarryAllMerge.compose(
                leadingDisplayedID: slots[0].variantID, leadingFan: leadingFan,
                trailingDisplayedID: nil, trailingFan: trailingFan) == nil)
        }
    }

    // MARK: - The registry (P-1): both doors declared, keyed and rendered

    /// **A JUSTIFIED EDIT (18f batch 1, her U-4), claim widened not weakened.**
    /// Her round-4 binding (menu · context menu · palette · the chord) is
    /// unchanged and still asserted; what U-4 adds is *"should be a BUTTON,
    /// not just a shortcut"* — so divide's summoned door joins the bottom
    /// bar's block ▾ group beside its plain twin, and merge's joins that AND
    /// the two bulk bars' `.surface` rows beside Merge Selected Blocks.
    @Test func bothCeremonyDoorsAreDeclaredWithTheirThreeDoorsAndKeys() {
        for (id, label, doors) in [
            (CapabilityID.divideWithCeremony, "⌥⌘⇧D",
             Set<Capability.Door>([.menuBar, .contextMenu, .bottomBar, .palette])),
            (CapabilityID.mergeWithCeremony, "⌥⌘⇧M",
             Set<Capability.Door>([.menuBar, .contextMenu, .bottomBar, .surface, .palette])),
        ] {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.doors == doors,
                    "\(id): her round-4 binding plus U-4's button doors")
            #expect(capability.doors.isSuperset(of: [.menuBar, .contextMenu, .palette]),
                    "\(id): round-4's three are still there")
            #expect(capability.shortcutLabel == label)
            #expect(EditorCommands.keyEquivalent(for: id) != nil,
                    "\(id)'s declared chord is wired in the one place keys collide")
            #expect(capability.verb.hasSuffix("choosing takes…"),
                    "\(id) reads as a summoned option, ellipsis and all (U-4, 2026-09-06)")
        }
        // The ceremony acts plan through their twins and diverge at the door.
        #expect(EditorViewModel.plannerCommand(for: .divideWithCeremony) == .divideAtCursor)
        #expect(EditorViewModel.plannerCommand(for: .mergeWithCeremony) == .mergeBlocks)
        #expect(EditorViewModel.requestsCeremony(.divideWithCeremony))
        #expect(EditorViewModel.requestsCeremony(.mergeWithCeremony))
        #expect(!EditorViewModel.requestsCeremony(.divide))
        #expect(!EditorViewModel.requestsCeremony(.merge))
    }

    /// Write's context menu renders BOTH ceremony rows, and their titles
    /// carry the declared chord (the one formatter — a re-picked key moves
    /// in the registry alone).
    @Test func writesContextMenuRendersBothCeremonyRows() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let titles = h.model.contextMenuItems().map(\.title)
            #expect(titles.contains(
                CapabilityRegistry.capability(.divideWithCeremony).menuTitle()))
            #expect(titles.contains(
                CapabilityRegistry.capability(.mergeWithCeremony).menuTitle()))
            #expect(titles.contains { $0.contains("⌥⌘⇧D") })
            #expect(titles.contains { $0.contains("⌥⌘⇧M") })
        }
    }
}

// MARK: - The board's half (R118: no surface is behind another)

@MainActor
@Suite("The fanned defaults on the Takes board (13j batch 4)")
struct FannedDefaultsBoardTests {
    @MainActor
    private struct Board {
        let session: AppSession
        let database: AppDatabase
        let model: TakesViewModel
        let postID: String

        func reload() throws {
            model.adopt(try database.read { try Queries.takesProjection($0, post: postID) })
        }

        func slots() throws -> [Queries.RenderedBlock] {
            try database.read { try Queries.renderPost($0, containerID: postID) }
        }

        func fan(_ blockID: String) throws -> [Variant] {
            try database.read { db in
                try Queries.blockFan(db, blockID: blockID)
                    .filter { $0.deletedAt == nil && $0.status == .active }
            }
        }

        func focus(blockID: String, variantID: String, caret: Int) {
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: blockID, variantID: variantID))
            model.notePaneSelection(
                variantID: variantID, range: NSRange(location: caret, length: 0))
        }
    }

    private func withBoard<T>(
        seedBlocks: [String],
        _ body: @MainActor (Board) async throws -> T
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "13j")
            for text in seedBlocks {
                _ = try session.operations.newBlock(in: post.id, text: text)
            }
            let board = Board(
                session: session, database: db,
                model: TakesViewModel(session: session, postID: post.id),
                postID: post.id)
            try board.reload()
            return try await body(board)
        }
    }

    /// **18f batch 1 (U-3/U-5):** the board mounts the SAME sheet, so it
    /// mounts the same arrangement row — kept on top, every take checked, the
    /// non-seed ✂ at the end. R118's rule read at the sheet: no surface is
    /// behind another.
    @Test func theBoardsCeremonyOpensOnTheArrangementRow() async throws {
        try await withBoard(seedBlocks: ["Alpha one. Alpha two."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            let spare = try board.session.operations.branchVariant(
                slot.blockID, from: chosen)
            try board.session.operations.autosave(
                spare.id, text: "Beta one. Beta two.", charDelta: 0)
            try board.reload()
            board.focus(blockID: slot.blockID, variantID: chosen, caret: 11)

            await board.model.structure.divideFocused(ceremony: true)

            let state = try #require(board.model.ceremony.state)
            #expect(state.arrangement == .keepOnTop)
            #expect(state.takes.allSatisfy { $0.marked }, "U-3 on the board too")
            #expect(state.otherTakes.allSatisfy { $0.parkedAtEnd })
            #expect(state.confirmBlocker == nil)
        }
    }

    /// The board's divide door flips with Write's — 13d Batch 3 made divide
    /// native here, and a native door that kept the OLD default would be
    /// exactly the two-answers-for-one-gesture class the registry exists to
    /// kill. (The rewrite of `theBoardsDivideDoorDuplicatesByDefault`, whose
    /// premise U-2 retires.)
    @Test func theBoardsDivideDoorKeepsTheTakesOnTop() async throws {
        try await withBoard(seedBlocks: ["Alpha one. Alpha two."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.reload()

            board.focus(blockID: slot.blockID, variantID: chosen, caret: 11)
            await board.model.divideFocused()
            try board.reload()

            #expect(board.model.divideWCeremony == nil, "no sheet on the default road")
            let after = try board.slots()
            #expect(after.count == 2)
            #expect(after.map(\.text) == ["Alpha one.", "Alpha two."])
            #expect(after.map(\.activeVariantCount) == [2, 1],
                    "the other take rode whole onto the TOP block, and only there")
            #expect(board.session.commandRouter.pendingWriteIntent == nil,
                    "and it happened HERE — no mode switch")
        }
    }

    /// **The board's own reason for `displayedVariantID`** (QUESTIONS #91):
    /// the caret here sits in ANY take's pane, so the take she divided is
    /// often not the block's chosen one. Both successors must still SHOW the
    /// take she was in — which is what the shipped default has always done —
    /// or the top block would render the other take whole beside the bottom
    /// block's tail of this one.
    @Test func theBoardsDivideFromANonChosenPaneStillShowsThatTake() async throws {
        try await withBoard(seedBlocks: ["Alpha one. Alpha two."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            let spare = try board.session.operations.branchVariant(
                slot.blockID, from: chosen)
            try board.session.operations.autosave(
                spare.id, text: "Spare one. Spare two.", charDelta: 21)
            try board.reload()

            board.focus(blockID: slot.blockID, variantID: spare.id, caret: 11)
            await board.model.divideFocused()
            try board.reload()

            let after = try board.slots()
            #expect(after.map(\.text) == ["Spare one.", "Spare two."],
                    "the page shows the halves of the take she divided")
            #expect(try board.fan(after[0].blockID).map(\.workingText)
                == ["Alpha one. Alpha two.", "Spare one."],
                    "the chosen take rode whole onto the top block, behind her half")
            #expect(after.map(\.activeVariantCount) == [2, 1])
        }
    }

    @Test func theBoardsCeremonyDoorStillOpensTheSheetInPlace() async throws {
        try await withBoard(seedBlocks: ["Alpha one. Alpha two."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.reload()

            board.focus(blockID: slot.blockID, variantID: chosen, caret: 11)
            await board.model.divideFocused(ceremony: true)

            let state = try #require(board.model.divideWCeremony)
            #expect(state.blockID == slot.blockID)
            #expect(state.takes.count == 2)
            do { let n = try board.slots().count; #expect(n == 1, "opening touches no rows") }
        }
    }

    @Test func theBoardsCeremonyDoorOnAnUnfannedBlockRefuses() async throws {
        try await withBoard(seedBlocks: ["Alpha one. Alpha two."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            board.focus(blockID: slot.blockID, variantID: chosen, caret: 11)

            await board.model.divideFocused(ceremony: true)

            #expect(board.model.divideWCeremony == nil)
            do { let n = try board.slots().count; #expect(n == 1, "nothing was divided") }
            #expect(board.model.statusMessage == FannedDefaultsCopy.divideCeremonyNeedsAFan,
                    "Write's answer, word for word")
        }
    }

    /// BOTH divide doors reach this board natively, and the merge ceremony's
    /// carries there (its sheet is Write's) — the R118 declaration.
    @Test func theCeremonyActsRouteAsDeclared() {
        let takes = CapabilityContext(mode: .takes)
        #expect(CapabilityRegistry.availability(.divideWithCeremony, in: takes) == .act,
                "the W sheet mounts on this board — nothing to carry")
        #expect(CapabilityRegistry.availability(.mergeWithCeremony, in: takes)
                == .actElsewhere(.write),
                "the pairing sheet mounts in Write, so the pair travels")
    }
}
