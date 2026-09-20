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
            // 18f ladder R1-12 asked the sentence to speak the OPERATION's
            // join rather than the mockup's word, and it still does — the
            // operation's join is just the rendering one now (R-13u4-3,
            // 13u4 UNIT E3; this read `.space` / "join with a space").
            #expect(state.canonJoin == .newline)
            #expect(state.arrangementSentence.contains("join on a new line"))
        }
    }

    /// The sentence follows the operation's join (18f ladder R1-12), and
    /// since **R-13u4-3** the door rule has no conditionals left for it to
    /// follow: the same fixture that used to make the sentence read "join
    /// directly" — a head already ending in a space — now reads the
    /// rendering join like every other door, because nothing is trimmed and
    /// nothing is conditional. *(This test asserted `.nothing` and "join
    /// directly" before 13u4 UNIT E3; it is kept, pointed at the ruling,
    /// because the edge-whitespace fixture is exactly the shape a
    /// re-introduced conditional would break.)*
    @Test func thePairSentenceReadsTheCanonJoinOffTheShownTakes() async throws {
        try await withEditor(seedBlocks: ["Alpha one. ", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try h.reload()
            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let state = try #require(h.model.mergeCeremony)
            #expect(state.canonJoin == .newline, "non-vacuity: the head ends in a space")
            #expect(state.arrangementSentence.contains("join on a new line"))
            #expect(!state.arrangementSentence.contains("join directly"))
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
            #expect(merged.map(\.text) == ["Alpha one.\nBeta two."])
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
            #expect(merged.map(\.text) == ["Beta two.\nGamma three.", "Delta four."],
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

    // MARK: - 18f ladder round 2, R2-2 (fable-reviewer): the preset roads confirm what the sheet SHOWED

    /// **RED ON `19fceb17`.** The sheet marks the two takes it opened on as
    /// the pair that joins (`firstRenderedID`/`secondRenderedID`, *"＋ pairs
    /// with →"*), but the preset roads used to compose from whatever the
    /// SURFACE showed at act time — so a chosen re-point landing under the
    /// open sheet (a sync apply) joined a pair she was never shown, and the
    /// receipt still said "the takes you were looking at joined". The pairing
    /// road's drift check could not see it either: it compared texts and
    /// count only. Now BOTH branches treat a re-pointed shown take as drift
    /// — the sheet refreshes onto what the surface shows, she reviews, and
    /// the confirm joins exactly that; the carry-all composes from the
    /// state's own rendered ids rather than re-reading the projection.
    @Test func aChosenRePointUnderTheOpenSheetRefreshesInsteadOfJoiningWhatSheWasNotShown() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let head = try #require(slots[0].variantID)
            let spare = try h.session.operations.branchVariant(slots[0].blockID, from: head)
            try h.session.operations.autosave(spare.id, text: "Alpha spare.", charDelta: 0)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let opened = try #require(h.model.mergeCeremony)
            #expect(opened.arrangement == .bringEveryTake)
            #expect(opened.firstRenderedID == head, "non-vacuity: the sheet marks the head as shown")

            // A sync apply re-points the leading block's chosen take under
            // the open sheet; the surface adopts it.
            try h.session.operations.chooseVariant(slots[0].blockID, variantID: spare.id)
            try h.reload()
            #expect(h.model.index.entries[0].variantID == spare.id,
                    "non-vacuity: the surface now shows the spare")

            await h.model.confirmMergeCeremony()
            // Refreshed, not joined: what the sheet showed is no longer what
            // the surface shows.
            #expect(try h.storeSlots().count == 2, "nothing joined from a pair she was not shown")
            let refreshed = try #require(h.model.mergeCeremony, "the sheet refreshed")
            #expect(refreshed.firstRenderedID == spare.id, "the sheet now marks what the surface shows")
            #expect(refreshed.arrangement == .bringEveryTake, "the row she chose survives")
            #expect(h.model.statusMessage?.contains("changed while the sheet was open") == true,
                    "\(h.model.statusMessage ?? "nil")")

            // Confirming the refreshed sheet joins exactly what it shows.
            await h.model.confirmMergeCeremony()
            let landed = try h.storeSlots()
            #expect(landed.count == 1, "the pair merged")
            let merged = try fan(h, landed[0].blockID)
            #expect(merged.first { $0.id == landed[0].variantID }?.workingText
                        == "Alpha spare.\nBeta two.",
                    "the shown pair joined")
            #expect(merged.count == 2, "the head came along whole")
        }
    }

    /// **The raise's pin (18f ladder round 2, the implementer's sanity pass —
    /// RED ON `6e14e9e8`).** R2-2's check compared the PROJECTION's rendered
    /// ids against the sheet's, but "Only the two shown" joins through
    /// `ops.merge`, which resolves each side from the STORE's chosen — and
    /// between a store write and the observation's delivery the two disagree.
    /// A chosen re-point landed in the store with the surface not yet caught
    /// up passed the check and joined a take the sheet never showed. The check
    /// reads the store's rendered pair now (the one truth both roads act on).
    @Test func aChosenRePointInTheStoreButNotYetOnTheSurfaceStillRefreshes() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let head = try #require(slots[0].variantID)
            let spare = try h.session.operations.branchVariant(slots[0].blockID, from: head)
            try h.session.operations.autosave(spare.id, text: "Alpha spare.", charDelta: 0)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            #expect(h.model.mergeCeremony?.firstRenderedID == head)
            h.model.setMergeArrangement(.onlyTheShownOnes)

            // The re-point lands in the STORE; the surface has NOT adopted it
            // yet (no reload — the sub-delivery window).
            try h.session.operations.chooseVariant(slots[0].blockID, variantID: spare.id)
            #expect(h.model.index.entries[0].variantID == head,
                    "non-vacuity: the surface still shows the head")
            #expect(try h.storeSlots()[0].variantID == spare.id,
                    "non-vacuity: the store already renders the spare")

            await h.model.confirmMergeCeremony()
            #expect(try h.storeSlots().count == 2, "nothing joined from a pair she was not shown")
            let refreshed = try #require(h.model.mergeCeremony, "the sheet refreshed")
            #expect(refreshed.firstRenderedID == spare.id, "re-marked from the store's truth")
            #expect(refreshed.arrangement == .onlyTheShownOnes)

            // The surface catches up; confirming the refreshed sheet joins
            // what it shows — the plain road, the head left in lineage.
            try h.reload()
            await h.model.confirmMergeCeremony()
            let landed = try h.storeSlots()
            #expect(landed.map(\.text) == ["Alpha spare.\nBeta two."])
            #expect(try fan(h, landed[0].blockID).count == 1, "only the shown ones came")
        }
    }

    // MARK: - The OPEN-time read (13u3 UNIT G — the 18f ladder's R3-6)

    /// **R3-6, RED ON `25638746`.** The pair's rendered ids were captured from
    /// the PROJECTION at open while the drift check compares the STORE — so in
    /// the sub-delivery window AT OPEN (a re-point already landed in the
    /// store, the surface not yet caught up) the first ⏎ refreshed and said
    /// *"The takes changed while the sheet was open"* when nothing had changed
    /// while it was open: the store was ahead when it opened. Honest — a
    /// refresh, never a wrong join — and a one-truth cleanliness point: the
    /// pair's shown ids are read in the same store read as the fans now, which
    /// is the raise's own rule applied at open.
    @Test func openingReadsTheShownPairFromTheStoreSoNothingRefreshesSpuriously() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let head = try #require(slots[0].variantID)
            let spare = try h.session.operations.branchVariant(slots[0].blockID, from: head)
            try h.session.operations.autosave(spare.id, text: "Alpha spare.", charDelta: 0)
            try h.reload()

            // The store moves BEFORE the sheet opens; the surface does not
            // adopt it (no reload) — the open-time lag window.
            try h.session.operations.chooseVariant(slots[0].blockID, variantID: spare.id)
            #expect(h.model.index.entries[0].variantID == head,
                    "non-vacuity: the surface still shows the head")

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let opened = try #require(h.model.mergeCeremony)
            #expect(opened.firstRenderedID == spare.id,
                    "the sheet marks the STORE's shown take (on old: the projection's head)")

            // Nothing changes while it is open — so one press lands it.
            await h.model.confirmMergeCeremony()
            #expect(h.model.mergeCeremony == nil,
                    "one press, landed — no spurious refresh")
            #expect(h.model.statusMessage?.contains("changed while the sheet was open") != true,
                    "…and nothing claimed a change: \(h.model.statusMessage ?? "nil")")
            let landed = try h.storeSlots()
            #expect(landed.count == 1)
            let merged = try fan(h, landed[0].blockID)
            #expect(merged.first { $0.id == landed[0].variantID }?.workingText
                        == "Alpha spare.\nBeta two.",
                    "the pair the sheet marked is the pair that joined")
        }
    }

    // MARK: - The RUN arm's drift check (13u3 UNIT G — the 18f ladder's R3-5)

    /// **R3-5's own pin — RED ON `25638746`.** R2-2 gave the PAIR's preset
    /// roads a drift check and the dispatcher fenced it to a pair
    /// (`if !state.isRun`), on the reading that "a run's sheet marks a list of
    /// blocks, not a pair". Figure B's amendment had already made that false:
    /// the run's list SHOWS each block's shown take, over its text. So the
    /// same promise was open on the rarer surface — `MergeRunBlock` carried
    /// text and no variant id, and "Only the shown ones" resolves each side
    /// through `ops.merge`, i.e. from the STORE's chosen at act time. A
    /// re-point landed under the open sheet and the first ⏎ joined a take the
    /// list never showed.
    ///
    /// On the pre-fix tree this fails at its FIRST assertion: the run is
    /// already merged to one block.
    @Test func aRunsShownTakeRePointedUnderTheOpenSheetRefreshesInsteadOfJoiningIt() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            try seedRun(h)
            let slots = try h.storeSlots()
            let middle = slots[1].blockID
            let shown = try #require(slots[1].variantID)
            let spare = try #require(
                try fan(h, middle).first { $0.id != shown })
            #expect(spare.workingText == "The spare take.", "non-vacuity: the spare is the other one")

            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let opened = try #require(h.model.mergeCeremony)
            #expect(opened.isRun, "non-vacuity: this is the RUN sheet")
            h.model.setMergeArrangement(.onlyTheShownOnes)
            #expect(opened.runBlocks.map(\.shownText) == ["Alpha one.", "Beta two.", "Gamma three."],
                    "non-vacuity: the list shows the middle's ORIGINAL take")

            // A sync apply re-points the middle block's chosen take under the
            // open sheet; the surface adopts it.
            try h.session.operations.chooseVariant(middle, variantID: spare.id)
            try h.reload()

            await h.model.confirmMergeCeremony()

            #expect(try h.storeSlots().count == 3,
                    "nothing joined from a take the list never showed")
            let refreshed = try #require(h.model.mergeCeremony, "the sheet refreshed")
            #expect(refreshed.runBlocks.map(\.shownText)
                        == ["Alpha one.", "The spare take.", "Gamma three."],
                    "the list re-marks what the blocks show now")
            #expect(refreshed.arrangement == .onlyTheShownOnes, "the row she chose survives")
            #expect(refreshed.blockIDs == slots.map(\.blockID), "…and the run's ids")
            #expect(refreshed.id == opened.id, "…and the sheet's identity")
            #expect(h.model.statusMessage?.contains("changed while the sheet was open") == true,
                    "\(h.model.statusMessage ?? "nil")")

            // Confirming the refreshed sheet joins exactly what it shows.
            await h.model.confirmMergeCeremony()
            let landed = try h.storeSlots()
            #expect(landed.map(\.text) == ["Alpha one.\nThe spare take.\nGamma three."],
                    "the chain joined the list's own takes")
            #expect(try fan(h, landed[0].blockID).count == 1, "only the shown ones came")
        }
    }

    /// **The run's OTHER preset, and the `displayed` source** (R3-5's fix
    /// shape's third clause: *"`runMergeChain` takes the state's shown ids as
    /// `displayed`"* — R2-2's pattern on `runCarryAllMerge`). Staged in the
    /// SUB-DELIVERY window, exactly as the pair's raise pin is: the re-point
    /// is in the STORE and the surface has not adopted it. The first ⏎
    /// refreshes; the second — with the surface STILL stale — must seed the
    /// carry-all from what the sheet now marks, not from the projection.
    ///
    /// RED ON `25638746` at the first assertion (no check ran at all, so the
    /// chain landed), and red at the last one if only the check were added
    /// and `displayed` left reading the projection.
    @Test func aRunsCarryAllSeedsFromTheSheetsShownTakesNotTheProjection() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            try seedRun(h)
            let slots = try h.storeSlots()
            let middle = slots[1].blockID
            let shown = try #require(slots[1].variantID)
            let spare = try #require(try fan(h, middle).first { $0.id != shown })

            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            #expect(h.model.mergeCeremony?.arrangement == .bringEveryTake,
                    "non-vacuity: the carry-all is the open row")

            // The re-point lands in the STORE; the surface has NOT adopted it.
            try h.session.operations.chooseVariant(middle, variantID: spare.id)
            #expect(h.model.index.entries[1].variantID == shown,
                    "non-vacuity: the surface still shows the original take")

            await h.model.confirmMergeCeremony()
            #expect(try h.storeSlots().count == 3, "nothing joined from a stale list")
            let refreshed = try #require(h.model.mergeCeremony, "the sheet refreshed")
            #expect(refreshed.runBlocks[1].shownText == "The spare take.",
                    "re-marked from the store's truth")

            // The surface is STILL stale; the confirm must read the sheet.
            #expect(h.model.index.entries[1].variantID == shown, "…still stale")
            await h.model.confirmMergeCeremony()
            let landed = try h.storeSlots()
            #expect(landed.count == 1, "the run merged")
            #expect(landed.map(\.text) == ["Alpha one.\nThe spare take.\nGamma three."],
                    "the carry-all seeded from the sheet's shown takes")
            #expect(try fan(h, landed[0].blockID).count == 2,
                    "…and the other take came along whole")
        }
    }

    /// A run with NO drift confirms on the FIRST ⏎ — the check is a guard,
    /// never a toll. (Green on both trees by construction; it is here so a
    /// future over-eager comparison cannot make every run take two presses.)
    @Test func anUndriftedRunStillConfirmsOnTheFirstPress() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { h in
            try seedRun(h)
            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            h.model.setMergeArrangement(.onlyTheShownOnes)
            await h.model.confirmMergeCeremony()
            #expect(h.model.mergeCeremony == nil, "one press, landed")
            #expect(try h.storeSlots().count == 1)
        }
    }

    // MARK: - The sentence

    @Test func theSentenceUnderTheMergeRowSaysWhatComesAlong() {
        let pairEvery = MergeArrangementCopy.sentence(
            .bringEveryTake, blocks: 2, otherTakes: 3)
        // The DEFAULT join the sentence speaks moved with the ruling
        // (R-13u4-3): this read "join with a space." before 13u4 UNIT E3.
        #expect(pairEvery.contains("The two takes you were looking at join on a new line."))
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
        // mockup's — the rule answered `.nothing` when an edge already
        // carried whitespace, and since R-13u4-3 a door always answers
        // `.newline`. The parameter still carries all three because the
        // ceremony's per-pairing control still offers all three.
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
