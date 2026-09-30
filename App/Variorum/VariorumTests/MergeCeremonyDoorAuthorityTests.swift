//
//  MergeCeremonyDoorAuthorityTests.swift
//  VariorumTests
//
//  18o U3 — KnownIssues row 79: ⌥⌘⇧M ("Merge choosing takes…") decides
//  from the STORE, never from the frozen `slots` projection.
//
//  THE DEFECT (18k UNIT C5's NOTICED 1, beside P27's fix `dee61938`): the
//  `.merge` arm's CEREMONY branch gated on `model.slots[i].activeVariantCount`,
//  an array `EditorProjectionPolicy` deliberately freezes while she is typing
//  (every delivery defers while the buffer is dirty). Two wrong outcomes,
//  one per direction:
//
//  (a) a take BORN mid-burst on either block (sync, or her own Takes
//      surface) still read as "no fan", so the door REFUSED with "These
//      blocks have one take each…" while a fan stood in the store;
//  (b) a take ARCHIVED elsewhere mid-burst still read as "fanned", so the
//      door reached `openMergeCeremony`, whose own truth read found the pair
//      unfanned and FELL THROUGH to the INSTANT merge — the ceremony door
//      merging on its own, where its ruled answer for an unfanned pair is the
//      needs-a-fan refusal (`theMergeCeremonyDoorOnAnUnfannedPairRefuses`).
//
//  Both pins drive the frozen projection on purpose (P27's pin shape,
//  `FannedDefaultsTests.aFanArrivingWhileSheIsTypingIsCarriedByTheMerge`):
//  type, change the fan in the store, deliver the projection so the engine
//  DEFERS it, then press the door — never `reload()` after the change.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("⌥⌘⇧M decides from the store, never the frozen slots (18o U3 — KnownIssues row 79)")
struct MergeCeremonyDoorAuthorityTests {
    /// `FannedDefaultsTests`' own helper, copied so that suite rides
    /// unmodified.
    private func selectAcross(_ h: EditorHarness, _ i: Int, _ j: Int) {
        let start = h.model.index.range(ofEntryAt: i).location + 1
        let end = h.model.index.range(ofEntryAt: j).location + 1
        h.textView.setSelectedRange(NSRange(location: end, length: 0))
        h.textView.setSelectedRange(NSRange(location: start, length: end - start))
        h.model.updateCaretContext()
    }

    /// **Direction (a) — RED ON OLD.** A take born on the block below while
    /// she types: the store has a fan, the frozen slots do not, and the door
    /// must OPEN the ceremony rather than refuse "needs a fan".
    @Test func aTakeBornMidBurstOpensTheCeremonyInsteadOfRefusing() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let trailing = try h.storeSlots()[1]
            let trailingVariant = try #require(trailing.variantID)

            h.type("X", at: 0)
            #expect(h.model.autosave.isDirty, "the burst — this pin's precondition")

            _ = try h.session.operations.branchVariant(trailing.blockID, from: trailingVariant)
            let fresh = try h.storeSlots()
            #expect(fresh[1].activeVariantCount == 2, "the STORE knows about the take")
            h.model.applyProjection(fresh)
            #expect(h.model.slots[1].activeVariantCount == 1,
                    "…and the editor's projection deliberately does not — the freeze, reproduced")

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            #expect(h.model.statusMessage != FannedDefaultsCopy.mergeCeremonyNeedsAFan,
                    "no false 'one take each' refusal while a fan stands")
            let state = try #require(h.model.mergeCeremony,
                                     "the door opens the ceremony — the store has a fan")
            #expect(state.secondTakes.count == 2, "the sheet shows the take that arrived mid-burst")
            #expect(state.pairings.count == 1, "pre-paired with the two rendered takes, as ever")
            #expect(state.firstTakes.first?.variant.workingText == "XAlpha one.",
                    "her typing reached the store before the sheet read it")
            let n = try h.storeSlots().count
            #expect(n == 2, "opening touches no rows")
        }
    }

    /// **Direction (b) — RED ON OLD.** A take archived elsewhere while she
    /// types: the frozen slots still say "fanned", the store says one take
    /// each. The ceremony door must speak its ruled refusal — and NEVER
    /// merge on its own.
    @Test func aTakeArchivedMidBurstRefusesInsteadOfMergingInstantly() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            let spare = try h.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try h.reload()
            #expect(h.model.slots[1].activeVariantCount == 2, "the editor knows the fan")

            h.type("X", at: 0)
            #expect(h.model.autosave.isDirty, "the burst — this pin's precondition")

            // Meanwhile the spare take is archived — on her Takes surface, or
            // on another device and synced here.
            try h.session.operations.archiveVariant(spare.id)
            let fresh = try h.storeSlots()
            #expect(fresh[1].activeVariantCount == 1, "the STORE says one take each now")
            h.model.applyProjection(fresh)
            #expect(h.model.slots[1].activeVariantCount == 2,
                    "…and the editor's projection still says fanned — the freeze")

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            let after = try h.storeSlots()
            #expect(after.count == 2, "NOTHING was merged — the ceremony door never merges on its own")
            #expect(h.model.mergeCeremony == nil, "and no sheet for a pair with nothing to arrange")
            #expect(h.model.statusMessage == FannedDefaultsCopy.mergeCeremonyNeedsAFan,
                    "the door's ruled refusal for an unfanned pair, in its own words")
        }
    }

    /// The guard (green on both sides): a fanned pair whose fan did NOT move
    /// still opens the sheet mid-burst.
    @Test func aStandingFanStillOpensTheCeremonyMidBurst() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try h.reload()

            h.type("X", at: 0)
            #expect(h.model.autosave.isDirty)

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            let state = try #require(h.model.mergeCeremony)
            #expect(state.secondTakes.count == 2)
            let n = try h.storeSlots().count
            #expect(n == 2, "opening touches no rows")
        }
    }

    /// The guard (green on both sides): an unfanned pair mid-burst still
    /// refuses, merges nothing, and loses none of her typing.
    @Test func anUnfannedPairMidBurstStillRefusesAndKeepsHerTyping() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            h.type("X", at: 0)
            #expect(h.model.autosave.isDirty)

            selectAcross(h, 0, 1)
            await h.model.invokeGesture(.mergeBlocks, ceremony: true)

            #expect(h.model.mergeCeremony == nil)
            #expect(h.model.statusMessage == FannedDefaultsCopy.mergeCeremonyNeedsAFan)
            await h.flush()
            let after = try h.storeSlots()
            #expect(after.count == 2, "nothing was merged")
            #expect(after.first?.text == "XAlpha one.", "her typing is kept")
        }
    }
}
