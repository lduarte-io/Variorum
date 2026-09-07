//
//  MergeArrangementTests.swift
//  VariorumTests
//
//  **THE MERGE'S ARRANGEMENT ROW** — the merge half of U-5 and the whole of
//  U-16 (2026-09-06 use-report round, 18f batch 1).
//
//  U-16, verbatim: *"if you're merging several notes together you should be
//  given the choice of bringing every take or only the currently shown ones,
//  but i don't want a super complex ceremony for merging multiple blocks
//  together."*
//
//  What the brief asks these to hold: **the run's two roads produce the
//  carry-all chain's rows and the plain chain's rows respectively, and the
//  pairing surface never mounts for a run.** Both are pinned by comparing
//  against the SHIPPED roads on identical fixtures rather than by re-asserting
//  arithmetic — a road that agreed with a hand-written expectation but not
//  with ⌘⇧M would be exactly the drift this batch's one-chain-body exists to
//  prevent.
//
//  RED-ON-OLD (procedure for the verifier): before 18f batch 1 the ⌥⌘⇧M door
//  over a run of three REFUSED (`FannedDefaultsCopy.mergeCeremonyIsPairwise`,
//  retired here) and the pair sheet had no arrangement at all — so every test
//  below fails on the pre-batch tree at its first `#require(mergeCeremony)` or
//  its first `setMergeArrangement`.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The merge sheet's arrangement row (U-5 · U-16)")
struct MergeArrangementTests {
    private func selectAcross(_ h: EditorHarness, _ i: Int, _ j: Int) {
        let start = h.model.index.range(ofEntryAt: i).location + 1
        let end = h.model.index.range(ofEntryAt: j).location + 1
        h.textView.setSelectedRange(NSRange(location: end, length: 0))
        h.textView.setSelectedRange(NSRange(location: start, length: end - start))
        h.model.updateCaretContext()
    }

    private func fan(_ h: EditorHarness, _ blockID: String) throws -> [Variant] {
        try h.database.read { db in
            try Queries.blockFan(db, blockID: blockID)
                .filter { $0.deletedAt == nil && $0.status == .active }
        }
    }

    /// Texts + fan sizes + which take is chosen — everything the author can
    /// see about the store, with the ids (fresh by construction) left out.
    private func shape(_ h: EditorHarness) throws -> [[String]] {
        try h.storeSlots().map { slot in
            try fan(h, slot.blockID).map {
                "\($0.workingText)|\($0.id == slot.variantID ? "chosen" : "")"
            }
        }
    }

    /// Three blocks, the middle one carrying a spare take.
    private func seedRun(_ h: EditorHarness) throws {
        let slots = try h.storeSlots()
        let spare = try h.session.operations.branchVariant(
            slots[1].blockID, from: try #require(slots[1].variantID))
        try h.session.operations.autosave(
            spare.id, text: "The spare take.", charDelta: 0)
        try h.reload()
    }

    // MARK: - The PAIR's three options

    /// The pair sheet opens on the carry-all — her J4b default — so ⏎ still
    /// reproduces exactly what ⌘⇧M does, which is the same promise S4-23's
    /// pre-pairing made and the row now makes one level up.
    @Test func thePairSheetOpensOnBringEveryTakeAndOffersThree() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let state = try #require(h.model.mergeCeremony)
            #expect(!state.isRun)
            #expect(state.arrangement == .bringEveryTake)
            #expect(state.offeredArrangements
                == [.bringEveryTake, .onlyTheShownOnes, .pairByHand])
            #expect(state.otherTakes == 1, "the spare, counted for the sentence")
            #expect(state.confirmBlocker == nil, "a preset is confirmable as it stands")
            // 18f ladder R1-12: "Alpha one." + "Beta two." — no edge carries
            // whitespace, so the canon join is a space and the sentence says
            // so; a head ending in a space would read "join directly".
            #expect(state.canonJoin == .space)
            #expect(state.arrangementSentence.contains("join with a space"))
        }
    }

    /// The sentence follows the operation's join, read off the shown takes'
    /// STORED texts (18f ladder R1-12): a head that already ends in a space
    /// joins directly, and the row says so.
    @Test func thePairSentenceReadsTheCanonJoinOffTheShownTakes() async throws {
        try await withEditor(seedBlocks: ["Alpha one. ", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try h.reload()
            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let state = try #require(h.model.mergeCeremony)
            #expect(state.canonJoin == .nothing, "non-vacuity: the head ends in a space")
            #expect(state.arrangementSentence.contains("join directly"))
            #expect(!state.arrangementSentence.contains("join with a space"))
        }
    }

    /// **Road equivalence, the pair: "bring every take" IS ⌘⇧M.** Two
    /// identical fixtures, one through the instant door and one through the
    /// sheet confirmed unchanged.
    @Test func bringEveryTakeOnAPairIsTheInstantCarryAllMerge() async throws {
        var instant: [[String]] = []
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let spare = try h.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try h.session.operations.autosave(
                spare.id, text: "The spare take.", charDelta: 0)
            try h.reload()
            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks)
            instant = try shape(h)
        }

        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let spare = try h.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try h.session.operations.autosave(
                spare.id, text: "The spare take.", charDelta: 0)
            try h.reload()
            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            await h.model.confirmMergeCeremony()
            #expect(h.model.mergeCeremony == nil, "it landed")
            let viaSheet = try shape(h)
            #expect(viaSheet == instant, "the row's default IS the everyday merge")
        }
        #expect(instant.count == 1)
        #expect(instant[0].count == 2, "non-vacuity: the spare came along")
    }

    /// **"Only the two shown" is the plain merge** — the shown takes join and
    /// the spare stays with its released block in lineage.
    @Test func onlyTheTwoShownOnAPairIsThePlainMerge() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let secondID = slots[1].blockID
            let spare = try h.session.operations.branchVariant(
                secondID, from: try #require(slots[1].variantID))
            try h.session.operations.autosave(
                spare.id, text: "The spare take.", charDelta: 0)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            h.model.setMergeArrangement(.onlyTheShownOnes)
            await h.model.confirmMergeCeremony()

            #expect(h.model.mergeCeremony == nil, "it landed")
            let merged = try h.storeSlots()
            #expect(merged.map(\.text) == ["Alpha one. Beta two."])
            #expect(merged[0].activeVariantCount == 1, "nothing else came along")
            let released = try fan(h, secondID)
            #expect(released.count == 2, "the spare stayed with its released block")
            let status = try #require(h.model.statusMessage)
            #expect(status.contains(TrayPath.originalsPath), "and the road is named")
        }
    }

    // MARK: - U-16: the RUN's two options

    /// **Road equivalence, the run: "bring every take" IS ⌘⇧M over the run.**
    @Test func bringEveryTakeOnARunIsTheCarryAllChain() async throws {
        var instant: [[String]] = []
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            try seedRun(h)
            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks)
            instant = try shape(h)
        }

        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            try seedRun(h)
            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let state = try #require(h.model.mergeCeremony)
            #expect(state.isRun)
            await h.model.confirmMergeCeremony()
            #expect(h.model.mergeCeremony == nil, "it landed")
            let viaSheet = try shape(h)
            #expect(viaSheet == instant, "the run's first road IS the carry-all chain")
        }
        #expect(instant.count == 1)
        #expect(instant[0].count == 2, "non-vacuity: the spare rode the chain")
    }

    /// **"Only the shown ones" is the PLAIN chain** — every link
    /// `Operations.merge`, the spare left with its released block. Compared
    /// against the same chain run link-by-link through the plain op on an
    /// identical fixture, so the road cannot drift from the operation it
    /// claims to be.
    @Test func onlyTheShownOnesOnARunIsThePlainChain() async throws {
        var byHand: [[String]] = []
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            try seedRun(h)
            let ids = try h.storeSlots().map(\.blockID)
            try await h.session.runner.run { ops in
                let first = try ops.merge(ids[0], ids[1])
                _ = try ops.merge(first.block.id, ids[2])
            }
            try h.reload()
            byHand = try shape(h)
        }

        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            try seedRun(h)
            let spareHome = try h.storeSlots()[1].blockID
            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            h.model.setMergeArrangement(.onlyTheShownOnes)
            await h.model.confirmMergeCeremony()

            #expect(h.model.mergeCeremony == nil, "it landed")
            let viaSheet = try shape(h)
            #expect(viaSheet == byHand, "the run's second road IS the plain chain")
            #expect(viaSheet.count == 1)
            #expect(viaSheet[0].count == 1, "one take on the merged block")
            let released = try fan(h, spareHome)
            #expect(released.count == 2, "the spare stayed with its released block")
            #expect(h.session.undoStack.depth == 1, "one run, ONE undo entry")
        }
    }

    /// **The pairing surface never mounts for a run** — the whole of U-16's
    /// second half. `setMergeArrangement(.pairByHand)` is refused because the
    /// option is not offered, and the columns carry nothing to pair anyway.
    @Test func thePairingSurfaceNeverMountsForARun() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            try seedRun(h)
            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            h.model.setMergeArrangement(.pairByHand)
            let state = try #require(h.model.mergeCeremony)
            #expect(state.arrangement == .bringEveryTake,
                    "a run cannot be put on the pairing road at all")
            #expect(!state.offeredArrangements.contains(.pairByHand))
            #expect(state.firstTakes.isEmpty && state.secondTakes.isEmpty)
            #expect(state.pairings.isEmpty)
        }
    }

    /// One run, ONE undo entry, and ⌥⌘Z brings all three blocks back — on
    /// the plain road as much as the carry-all one.
    @Test func eitherRunRoadIsOneUndoEntry() async throws {
        for shown in [true, false] {
            try await withEditor(
                seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]
            ) { h in
                try seedRun(h)
                selectAcross(h, 0, 2)
                await h.model.invokeGesture(.mergeBlocks, ceremony: true)
                if shown { h.model.setMergeArrangement(.onlyTheShownOnes) }
                await h.model.confirmMergeCeremony()
                let mergedCount = try h.storeSlots().count
                #expect(mergedCount == 1)
                #expect(h.session.undoStack.depth == 1)

                _ = try h.session.undoStack.undo(with: h.session.operations)
                let back = try h.storeSlots()
                #expect(back.count == 3, "⌥⌘Z brings the run back (shown-only: \(shown))")
                #expect(back.map(\.text) == ["Alpha one.", "Beta two.", "Gamma three."])
            }
        }
    }

    // MARK: - 18f ladder round 1, R1-2 (fable-reviewer): the roads resolve by id

    /// **RED ON OLD — verified on the pre-fix tree** (the production edit
    /// stashed, this pin run alone): the preset roads acted on the entry
    /// indices captured when the sheet OPENED, and `runInstantMerge` read the
    /// trailing block's length from that stale index — so once the surface
    /// re-tiled under the open sheet, "Only the two shown" placed the caret
    /// by the WRONG entry's length (here: 11, the block below the pair,
    /// instead of 10) and reported a seam at the wrong entry. Every merge
    /// road now resolves its entries by BLOCK ID at act time (`runPlainDivide`'s
    /// rule, applied to the merge family).
    @Test func confirmingAPresetAfterTheSurfaceRetiledActsByBlockID() async throws {
        try await withEditor(
            seedBlocks: ["Alpha one.", "Beta two.", "Gamma three.", "Delta four."]
        ) { h in
            let slots = try h.storeSlots()
            let spare = try h.session.operations.branchVariant(
                slots[2].blockID, from: try #require(slots[2].variantID))
            try h.session.operations.autosave(
                spare.id, text: "The spare take.", charDelta: 0)
            try h.reload()

            selectAcross(h, 1, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let state = try #require(h.model.mergeCeremony)
            #expect(state.blockIDs == [slots[1].blockID, slots[2].blockID])

            // The surface re-tiles under the open sheet: the block ABOVE the
            // pair goes, and every entry index the sheet opened with is now
            // one too high.
            try h.session.operations.deleteBlock(slots[0].blockID)
            try h.reload()
            #expect(h.model.index.entries.count == 3,
                    "non-vacuity: the pair's entries moved by one")

            h.model.setMergeArrangement(.onlyTheShownOnes)
            await h.model.confirmMergeCeremony()
            #expect(h.model.mergeCeremony == nil, "it landed")
            let merged = try h.storeSlots()
            #expect(merged.map(\.text) == ["Beta two. Gamma three.", "Delta four."],
                    "the PAIR merged — by id, not by the open-time index")
            // The caret sits at the JOIN, right where the trailing half
            // begins — the trailing block's own length, resolved by id.
            let join = h.model.index.range(ofEntryAt: 0).location
                + "Beta two. ".utf16.count
            #expect(h.textView.selectedRange() == NSRange(location: join, length: 0),
                    "caret at the join (\(h.textView.selectedRange()) vs \(join))")
        }
    }

    /// The shape her report's mechanism actually reaches — a two-block note
    /// whose leading block dies while the sheet is up. On the pre-fix tree
    /// this TRAPS (`entries[1]` on a one-entry index), which is why the pin
    /// above, not this one, is the red-on-old evidence. Now: the sheet
    /// dismisses in the refresh road's own voice and nothing is touched.
    @Test func confirmingAPresetAfterAPairBlockDiedRefusesInsteadOfTrapping() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try h.reload()
            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            #expect(h.model.mergeCeremony != nil)

            try h.session.operations.deleteBlock(slots[0].blockID)
            try h.reload()
            #expect(h.model.index.entries.count == 1, "non-vacuity: the leading block is gone")

            h.model.setMergeArrangement(.onlyTheShownOnes)
            await h.model.confirmMergeCeremony()
            #expect(h.model.mergeCeremony == nil, "the sheet dismisses — its blocks are not there")
            #expect(h.model.statusMessage == FannedDefaultsCopy.blocksChangedMerge)
            #expect(try h.storeSlots().map(\.text) == ["Beta two."], "nothing was merged")
        }
    }

    // MARK: - The sentence

    @Test func theSentenceUnderTheMergeRowSaysWhatComesAlong() {
        let pairEvery = MergeArrangementCopy.sentence(
            .bringEveryTake, blocks: 2, otherTakes: 3)
        #expect(pairEvery.contains("The two takes you were looking at join with a space."))
        #expect(pairEvery.contains("3 other takes come along whole"))

        // 18f ladder R1-3 (fable-reviewer): the singular is CONJUGATED (this
        // pin used to certify "1 other take stay").
        let pairShown = MergeArrangementCopy.sentence(
            .onlyTheShownOnes, blocks: 2, otherTakes: 1)
        #expect(pairShown.contains("1 other take stays with the released blocks"),
                "singular, conjugated: \(pairShown)")
        #expect(pairShown.contains(TrayPath.originalsPath), "the lineage road, named")
        let pairEveryOne = MergeArrangementCopy.sentence(
            .bringEveryTake, blocks: 2, otherTakes: 1)
        #expect(pairEveryOne.contains("1 other take comes along whole"),
                "singular, conjugated: \(pairEveryOne)")

        let runEvery = MergeArrangementCopy.sentence(
            .bringEveryTake, blocks: 4, otherTakes: 2)
        #expect(runEvery.contains("The 4 takes you were looking at join in order."))

        // 18f ladder R1-12: the pair's join word is the operation's, not the
        // mockup's — `MergeJoin.canon` answers `.nothing` when an edge already
        // carries whitespace.
        let direct = MergeArrangementCopy.sentence(
            .bringEveryTake, blocks: 2, otherTakes: 1, join: .nothing)
        #expect(direct.contains("The two takes you were looking at join directly."))
        let newline = MergeArrangementCopy.sentence(
            .onlyTheShownOnes, blocks: 2, otherTakes: 0, join: .newline)
        #expect(newline.contains("join on a new line"))
        #expect(MergeArrangement.offered(blocks: 2).count == 3)
        #expect(MergeArrangement.offered(blocks: 3) == [.bringEveryTake, .onlyTheShownOnes])
        #expect(MergeArrangement.onlyTheShownOnes.title(blocks: 2) == "Only the two shown")
        #expect(MergeArrangement.onlyTheShownOnes.title(blocks: 5) == "Only the shown ones")
    }
}
