//
//  MergeCeremonySheetTests.swift
//  VariorumTests
//
//  The merge ceremony's door + state machine (13b Stage 4, Batch 4B — the
//  RULED merge addendum, S4-23): ANY fan on either side opens the sheet
//  PRE-PAIRED with the two rendered takes (⏎ = today's exact outcome in a
//  FRESH session / when no join memory is set; with a session memory set
//  the pre-pair joins by the MEMORY — ruling 3's letter; precision per
//  ladder round 1, NIT-4); pairings and carries flow through
//  Operations.mergeCeremony; unfanned pairs and N-ary chains keep their
//  instant paths byte-unchanged; the session remembers the last
//  confirmed join.
//
//  **13j batch 4 (J4b) — A JUSTIFIED EDIT to every ceremony opening below,
//  and the DOOR moved rather than the claims.** Her 2026-08-09 ruling made
//  the CARRY-ALL merge the fanned default on every merge door, so ⌘⇧M no
//  longer summons this sheet; ⌥⌘⇧M does
//  (`invokeGesture(.mergeBlocks, ceremony: true)`). Everything S4-23 ruled
//  about the sheet — the pre-pairing, ⏎'s outcome, 1:1 arity, the join
//  memory, the drift refresh — is pinned here exactly as before, reached by
//  the door that now opens it. Two pins below deliberately keep the DEFAULT
//  door, each saying why: the unfanned instant merge, and the N-ary chain.
//
//  RED-ON-OLD (procedure for the verifier, the locked-session regime):
//  revert = restore the pre-4B `.merge` case body in
//  EditorSurfaceController.applyStructural (a direct call to the instant
//  merge, no arity branch — commit a7da2b6's parent shape). Then
//  `aFannedMergeOpensTheCeremonyPrePaired`,
//  `confirmingThePrePairedSheetReproducesTheInstantOutcome`,
//  `aPairingPlusCarryMintsBothTakes`, `confirmRefusesToJoinDriftedText`,
//  and `theSessionRemembersTheLastConfirmedJoin` all fail on their
//  `mergeCeremony != nil` expectations (the old code merges instantly and
//  no sheet ever exists).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Merge ceremony sheet (13b Stage 4, Batch 4B)")
struct MergeCeremonySheetTests {
    /// Selects across two adjacent blocks by entry index.
    private func selectAcross(_ h: EditorHarness, _ i: Int, _ j: Int) {
        let start = h.model.index.range(ofEntryAt: i).location + 1
        let end = h.model.index.range(ofEntryAt: j).location + 1
        h.textView.setSelectedRange(NSRange(location: start, length: end - start))
        h.model.updateCaretContext()
    }

    /// THE threshold pin (S4-23 ruling 4, red-on-old): a merge landing on
    /// a fanned pair opens the ceremony — pre-paired with the two rendered
    /// takes under the canon join — and touches NO rows.
    @Test func aFannedMergeOpensTheCeremonyPrePaired() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            let state = try #require(h.model.mergeCeremony)
            let untouched = try h.storeSlots()
            #expect(untouched.count == 2, "opening touches no rows")
            #expect(state.firstBlockID == slots[0].blockID)
            #expect(state.secondBlockID == slots[1].blockID)
            #expect(state.firstTakes.count == 1)
            #expect(state.secondTakes.count == 2)
            // Pre-paired: the two RENDERED takes, canon join (bare edges
            // here ⇒ a single space).
            #expect(state.pairings.count == 1)
            #expect(state.pairings[0].firstVariantID == slots[0].variantID)
            #expect(state.pairings[0].secondVariantID == slots[1].variantID)
            #expect(state.pairings[0].join == .space)
            #expect(state.canConfirm, "⏎ works out of the box — the default guarantees I10")
        }
    }

    /// ⏎ reproduces today's exact outcome — in this FRESH session (no
    /// join memory is set, so the pre-pair joins by canon; with a memory
    /// set it would join by the memory, ruling 3's letter — the framing
    /// precision of ladder round 1, NIT-4): one minted take from the
    /// visible pair, the spare take behind in lineage, the road named,
    /// ONE undo entry.
    @Test func confirmingThePrePairedSheetReproducesTheInstantOutcome() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            #expect(h.model.mergeCeremony != nil)
            await h.model.confirmMergeCeremony()

            #expect(h.model.mergeCeremony == nil, "the sheet dismisses on landing")
            let merged = try h.storeSlots()
            #expect(merged.map(\.text) == ["Alpha one. Beta two."])
            #expect(merged[0].activeVariantCount == 1)
            // The spare take stays with its released source, alive.
            let spareCount = try await h.database.read { db in
                try Queries.blockFan(db, blockID: slots[1].blockID)
                    .filter { $0.deletedAt == nil && $0.status == .active }.count
            }
            #expect(spareCount == 2)
            // The lineage-road speech survives on the ceremony path.
            let status = try #require(h.model.statusMessage)
            // 13j J6: the destination moved to the note's own tray; the
            // claim — that the road is named at all — is unchanged.
            #expect(status.contains(TrayPath.originalsPath), "the road stays named: \(status)")
            #expect(h.session.undoStack.topLabel == "Merge Takes")
            try expectStoreMatchesView(h)
        }
    }

    /// A pairing plus a carry mints BOTH takes on the merged block; one
    /// ⌥⌘Z restores the sources whole — takes, choices, placements.
    @Test func aPairingPlusCarryMintsBothTakes() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let spare = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.session.operations.autosave(
                spare.id, text: "Spare beta.", charDelta: 0)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            #expect(h.model.mergeCeremony != nil)
            h.model.toggleMergeCarry(spare.id)
            await h.model.confirmMergeCeremony()

            let merged = try h.storeSlots()
            #expect(merged.count == 1)
            #expect(merged[0].activeVariantCount == 2, "the pairing's take + the carry")
            #expect(merged[0].text == "Alpha one. Beta two.", "chosen = the rendered pairing")
            // No stay-behind takes ⇒ no lineage toast is owed; the board
            // shows both takes right there.

            // ONE structural undo restores the pair.
            let stack = h.session.undoStack
            _ = try await h.session.runner.run { ops in try stack.undo(with: ops) }
            let restored = try h.storeSlots()
            #expect(restored.count == 2)
            #expect(restored.map(\.blockID) == [slots[0].blockID, slots[1].blockID])
            #expect(restored[1].activeVariantCount == 2, "the fan came back whole")
        }
    }

    /// The everyday case is untouched: two single-take blocks merge
    /// instantly — no sheet, the standing caret-at-the-join behavior.
    @Test func anUnfannedMergeStaysInstant() async throws {
        try await withEditor(seedBlocks: ["One two.", "Three four."]) { h in
            selectAcross(h, 0, 1)
            // The DEFAULT door, deliberately: this pin's claim is that the
            // everyday merge is untouched, and 13j J4b keeps it exactly so.
            await h.model.invokeGesture(.mergeBlocks)
            #expect(h.model.mergeCeremony == nil, "no fan, no ceremony")
            let joined = try h.storeSlots()
            #expect(joined.map(\.text) == ["One two. Three four."])
            #expect(h.session.undoStack.topLabel == "Merge")
        }
    }

    /// S4-23 ruling 5: N-ary chains (3+ blocks) BYPASS the pairing sheet.
    ///
    /// **A JUSTIFIED EDIT (13j batch 4, J4b), claim intact.** The ruling
    /// this pins is untouched — a chain never opens the pairing ceremony —
    /// but its links now CARRY ALL where either side has a fan (her
    /// 2026-08-09 ruling reaching the chain the same way it reaches the
    /// pair), so the merged block keeps the spare instead of leaving it in
    /// lineage, and the receipt says which. Asking for the ceremony over a
    /// run of three is a separate act with its own pin in
    /// `FannedDefaultsTests` (it refuses and names this road).
    @Test func aThreeBlockChainBypassesTheCeremony() async throws {
        try await withEditor(seedBlocks: ["One two.", "Three four.", "Five six."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()

            selectAcross(h, 0, 2)
            await h.model.invokeGesture(.mergeBlocks)

            #expect(h.model.mergeCeremony == nil, "chains stay OUT of the ceremony")
            let chained = try h.storeSlots()
            #expect(chained.map(\.text) == ["One two. Three four. Five six."])
            #expect(chained[0].activeVariantCount == 2, "the spare rode the chain")
            let status = try #require(h.model.statusMessage)
            #expect(status.contains("Merged 3 blocks"),
                    "the chain keeps its own receipt: \(status)")
            #expect(status.contains("came along whole"), "and says what became of the spare")
        }
    }

    /// S4-23 ruling 3: the sheet remembers the last CONFIRMED join within
    /// a session (AppSession-scoped = per launch; a fresh launch resets to
    /// the canon default).
    @Test func theSessionRemembersTheLastConfirmedJoin() async throws {
        try await withEditor(seedBlocks: ["line one", "line two"]) { h in
            #expect(h.session.mergeJoinMemory == nil, "a fresh session starts canon")
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let state = try #require(h.model.mergeCeremony)
            h.model.setMergeJoin(pairingID: state.pairings[0].id, join: .newline)
            await h.model.confirmMergeCeremony()
            let newlineJoined = try h.storeSlots()
            #expect(newlineJoined.map(\.text) == ["line one\nline two"])
            #expect(h.session.mergeJoinMemory == .newline)

            // The NEXT ceremony pre-pairs with the remembered join.
            _ = try h.session.operations.newBlock(in: h.postID, text: "alpha beta")
            let tail = try h.session.operations.newBlock(in: h.postID, text: "gamma delta")
            _ = try h.session.operations.branchVariant(tail.block.id, from: tail.variant.id)
            try h.reload()
            let count = h.model.index.entries.count
            selectAcross(h, count - 2, count - 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            let next = try #require(h.model.mergeCeremony)
            #expect(next.pairings[0].join == .newline,
                    "the last confirmed choice seeds the next sheet")
        }
    }

    /// The state machine's arity: pairing is 1:1, paired excludes carried,
    /// removing a pairing returns both takes to their columns, and the
    /// zero-pairing/zero-carry state gates confirm with honest copy.
    @Test func pairingMutationsKeepArityAndCarryExclusive() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let spare = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            var state = try #require(h.model.mergeCeremony)
            #expect(state.pairings.count == 1)

            // The columns list only UNPAIRED takes.
            #expect(state.unpairedFirst.isEmpty)
            #expect(state.unpairedSecond.map(\.id) == [spare.id])

            // A paired take cannot carry.
            h.model.toggleMergeCarry(slots[0].variantID!)
            state = try #require(h.model.mergeCeremony)
            #expect(state.carriedIDs.isEmpty, "paired excludes carried")

            // A second pairing on an already-paired side refuses quietly.
            h.model.pairMergeTakes(firstID: slots[0].variantID!, secondID: spare.id)
            state = try #require(h.model.mergeCeremony)
            #expect(state.pairings.count == 1, "1:1 — the left take is taken")

            // Removing the pairing frees both; carrying then works; the
            // pairing door reopens.
            h.model.removeMergePairing(state.pairings[0].id)
            state = try #require(h.model.mergeCeremony)
            #expect(state.pairings.isEmpty)
            #expect(state.confirmBlocker != nil, "nothing would land — confirm gates, spoken")
            #expect(!state.canConfirm)
            h.model.toggleMergeCarry(spare.id)
            state = try #require(h.model.mergeCeremony)
            #expect(state.canConfirm, "one carry satisfies I10 at birth")
            // A carried take that gets PAIRED stops carrying.
            h.model.pairMergeTakes(firstID: slots[0].variantID!, secondID: spare.id)
            state = try #require(h.model.mergeCeremony)
            #expect(state.pairings.count == 1)
            #expect(state.carriedIDs.isEmpty, "pairing un-carries")
            #expect(state.stayBehindCount == 1, "the un-paired rendered take stays behind")
        }
    }

    /// The W confirm's drift discipline, mirrored: a take edited under the
    /// open sheet (a sync round) REFRESHES the ceremony — pairings kept by
    /// identity, previews re-derived — instead of joining text the author
    /// wasn't shown.
    @Test func confirmRefusesToJoinDriftedText() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let spare = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)
            #expect(h.model.mergeCeremony != nil)

            // The world moves while the sheet is open.
            try await h.session.runner.run { ops in
                try ops.autosave(spare.id, text: "Moved under the sheet.", charDelta: 0)
            }
            await h.model.confirmMergeCeremony()

            // NOT merged; the sheet refreshed with the current texts.
            let unjoined = try h.storeSlots()
            #expect(unjoined.count == 2, "nothing was joined from a drifted snapshot")
            let state = try #require(h.model.mergeCeremony)
            #expect(state.take(spare.id)?.variant.workingText == "Moved under the sheet.")
            #expect(state.pairings.count == 1, "pairings survive by identity")
            #expect(h.model.statusMessage?.contains("changed while the sheet was open") == true)

            // Confirming the refreshed sheet lands.
            await h.model.confirmMergeCeremony()
            let landed = try h.storeSlots()
            #expect(landed.count == 1)
        }
    }
}
