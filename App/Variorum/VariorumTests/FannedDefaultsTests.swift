//
//  FannedDefaultsTests.swift
//  VariorumTests
//
//  13j batch 4 (J4 / J4b) — **THE FLIPPED FANNED DEFAULTS.** Two author
//  rulings, one suite: dividing a fanned block DUPLICATES (her Q-M2 shape,
//  2026-08-03) and merging a fanned pair CARRIES ALL (2026-08-09); both
//  ceremonies survive behind ⌥⌘⇧D / ⌥⌘⇧M, byte-unchanged.
//
//  RED-ON-OLD (behavioral revert, run and recorded in the batch record):
//
//  - **Revert A** — `applyStructural`'s `.divideW` arm back to opening the
//    ceremony unconditionally (`await openDivideWCeremony(...)`, no
//    `ceremony` branch). RED: `aFannedDivideDuplicatesInsteadOfOpeningTheCeremony`,
//    `theDuplicatedTakesLandOnBothSuccessorsWithTheirLabels`,
//    `theDuplicatingDivideIsOneStructuralUndoEntry`,
//    `theDivideReceiptTellsTheDuplicateShapeTruth`.
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

    // MARK: - J4: the divide default

    /// THE J4 pin (red-on-old, revert A): ⌘⇧D on a fanned block no longer
    /// opens a sheet — it mints the duplicate shape, one gesture, no
    /// ceremony state anywhere.
    @Test func aFannedDivideDuplicatesInsteadOfOpeningTheCeremony() async throws {
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
            // Each successor: its cut half FIRST (chosen), then the duplicate.
            #expect(after[0].text == "Alpha one.")
            #expect(after[1].text == "Alpha two.")
            for successor in after {
                #expect(successor.activeVariantCount == 2,
                        "the other take rode whole onto this successor")
            }
        }
    }

    @Test func theDuplicatedTakesLandOnBothSuccessorsWithTheirLabels() async throws {
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
            for successor in after {
                let takes = try fan(h, successor.blockID)
                let duplicate = try #require(takes.first { $0.workingText == otherText })
                #expect(duplicate.label == "the spare", "a whole-take ride keeps its name")
                #expect(duplicate.id != other.id, "a COPY — the source take stays on A")
                #expect(!duplicate.locked, "copies are never born locked")
            }
            // A itself is preserved WHOLE, off-stage, with its own takes.
            let sourceTakes = try fan(h, slot.blockID)
            #expect(sourceTakes.count == 2, "the original keeps every take it had")
            #expect(sourceTakes.contains { $0.id == other.id })
        }
    }

    @Test func theDuplicatingDivideIsOneStructuralUndoEntry() async throws {
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
        }
    }

    /// The receipt may only claim what the operation did (the J8 doctrine).
    @Test func theDivideReceiptTellsTheDuplicateShapeTruth() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            _ = try h.session.operations.branchVariant(slot.blockID, from: slot.variantID!)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            let spoken = try #require(h.model.statusMessage)
            #expect(spoken == FannedDefaultsCopy.divided(duplicated: 2))
            #expect(spoken.contains("2 other takes"), "it counts what actually rode")
            #expect(spoken.contains("quick to delete"), "her own words for the consequence")
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
    /// lock, which is why this is worth stating rather than assuming.
    @Test func aLockedTakeDoesNotRefuseTheDuplicatingDivide() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let slot = try #require(try h.storeSlots().first)
            let chosen = try #require(slot.variantID)
            _ = try h.session.operations.branchVariant(slot.blockID, from: chosen)
            try h.session.operations.lockVariant(chosen)
            try h.reload()

            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)

            let after = try h.storeSlots()
            #expect(after.count == 2, "the copy road does not care about the lock")
            #expect(after.map(\.text) == ["Alpha one.", "Alpha two."])
            #expect(after.allSatisfy { !$0.variantLocked },
                    "and the halves are not born locked")
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
            #expect(after[0].text == "Alpha one. Beta two.", "the join is the canon rule")
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
            #expect(chosen.workingText == "Alpha one. Beta two.",
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
            #expect(after[0].text == "Alpha one. Beta two.")
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

    @Test func theMergeCeremonyDoorOnAChainRefusesAndNamesTheChainRoad() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            #expect(h.model.mergeCeremony == nil)
            do { let n = try h.storeSlots().count; #expect(n == 3, "nothing was merged") }
            let spoken = try #require(h.model.statusMessage)
            #expect(spoken == FannedDefaultsCopy.mergeCeremonyIsPairwise(blocks: 3))
            #expect(spoken.contains("⌘⇧M"), "it names the road that takes the run")
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
            #expect(after[0].text == "Alpha one. Beta two. Gamma three.")
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
            #expect(after[0].text == "Alpha one. Beta two. Gamma three.")
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
            #expect(composition.pairing.join == MergeJoin.canon(
                head: "Alpha one.", tail: "Beta two."),
                    "the join is merge's own canon rule, never a guess")
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

    @Test func bothCeremonyDoorsAreDeclaredWithTheirThreeDoorsAndKeys() {
        for (id, label) in [
            (CapabilityID.divideWithCeremony, "⌥⌘⇧D"),
            (CapabilityID.mergeWithCeremony, "⌥⌘⇧M"),
        ] {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.doors == [.menuBar, .contextMenu, .palette],
                    "\(id): her round-4 binding — menu, context menu AND palette")
            #expect(capability.shortcutLabel == label)
            #expect(EditorCommands.keyEquivalent(for: id) != nil,
                    "\(id)'s declared chord is wired in the one place keys collide")
            #expect(capability.verb.hasSuffix("with Ceremony…"),
                    "\(id) reads as a summoned option, ellipsis and all")
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

    /// The board's divide door flips with Write's — 13d Batch 3 made divide
    /// native here, and a native door that kept the OLD default would be
    /// exactly the two-answers-for-one-gesture class the registry exists to
    /// kill.
    @Test func theBoardsDivideDoorDuplicatesByDefault() async throws {
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
            #expect(after.allSatisfy { $0.activeVariantCount == 2 },
                    "the other take rode whole onto both successors")
            #expect(board.session.commandRouter.pendingWriteIntent == nil,
                    "and it happened HERE — no mode switch")
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
