//
//  EditorProjectionEngineTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1a (T3 slice) — the extracted editor text-authority
//  brain's own units: the ledger's echo semantics + word-count caching,
//  and the projection policy's pinned precedence order (previously an
//  if-chain inside EditorViewModel.applyProjection; the behavior is the
//  shipped one, now stated as pure code).
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("EditorSurfaceLedger + projection policy (13b 1a)")
struct EditorProjectionEngineTests {
    private func slot(
        _ blockID: String, variantID: String?, text: String?, locked: Bool = false
    ) -> Queries.RenderedBlock {
        Queries.RenderedBlock(
            blockID: blockID, placementID: "p-\(blockID)", position: "a",
            variantID: variantID, text: text,
            activeVariantCount: variantID == nil ? 0 : 1,
            liveVariantCount: variantID == nil ? 0 : 1, commentCount: 0,
            variantLocked: locked)
    }

    private func index(_ slots: [Queries.RenderedBlock]) -> BlockRangeIndex {
        BlockRangeIndex(slots: slots, tail: nil)
    }

    // MARK: - The echo check

    @Test func anEchoMatchesAndAnyDivergenceDoesNot() {
        var ledger = EditorSurfaceLedger()
        let slots = [
            slot("b1", variantID: "v1", text: "alpha"),
            slot("b2", variantID: "v2", text: "beta"),
        ]
        ledger.adopt(slots)
        let entries = index(slots).entries

        #expect(ledger.matches(slots, entries: entries), "our own echo matches")
        #expect(!ledger.matches(
            [slots[0], slot("b2", variantID: "v2", text: "CHANGED")],
            entries: entries), "a changed text is no echo")
        #expect(!ledger.matches(
            [slots[0], slot("b2", variantID: "v3", text: "beta")],
            entries: entries), "a re-pointed variant is no echo")
        #expect(!ledger.matches(
            [slots[0], slot("b2", variantID: "v2", text: "beta", locked: true)],
            entries: entries), "an editability change is no echo")
        #expect(!ledger.matches([slots[0]], entries: entries),
                "a structure change is no echo")
        // Same length, different bytes — the map, not the length, decides.
        #expect(!ledger.matches(
            [slots[0], slot("b2", variantID: "v2", text: "betA")],
            entries: entries), "same-length different text is no echo")
    }

    @Test func gapSlotsCompareByEmptyLengthAlone() {
        var ledger = EditorSurfaceLedger()
        let slots = [slot("b1", variantID: nil, text: nil)]
        ledger.adopt(slots)
        #expect(ledger.matches(slots, entries: index(slots).entries),
                "a gap slot echo-matches (empty read-only range)")
    }

    @Test func aRecordedEditJoinsTheLedgerImmediately() {
        var ledger = EditorSurfaceLedger()
        let slots = [slot("b1", variantID: "v1", text: "typed text")]
        ledger.adopt([slot("b1", variantID: "v1", text: "old")])
        ledger.recordEdit(variantID: "v1", text: "typed text")
        #expect(ledger.matches(slots, entries: index(slots).entries),
                "the flush's echo matches the recorded edit")
    }

    // MARK: - Word counts (R11 at P1 cost)

    @Test func wordCountsReEnumerateOnlyChangedTexts() {
        var ledger = EditorSurfaceLedger()
        let first = [
            slot("b1", variantID: "v1", text: "three words here"),
            slot("b2", variantID: "v2", text: "two words"),
        ]
        ledger.adopt(first)
        #expect(ledger.totalWords(over: first) == 5)

        // An external edit to one block; the other's count rides the cache.
        let second = [
            slot("b1", variantID: "v1", text: "three words here"),
            slot("b2", variantID: "v2", text: "now four words total"),
        ]
        ledger.adopt(second)
        #expect(ledger.totalWords(over: second) == 7)

        // The caret's live count adjusts the total between projections.
        let moved = ledger.setLiveWordCount(variantID: "v1", count: 10)
        #expect(moved)
        let movedAgain = ledger.setLiveWordCount(variantID: "v1", count: 10)
        #expect(!movedAgain, "an unchanged count reports no movement")
        #expect(ledger.totalWords(over: second) == 14)
    }

    // MARK: - The policy's precedence (the applyProjection contract)

    @Test func thePolicyPrecedenceIsNotLoadedBusyForcedEchoSequenceFull() {
        typealias P = EditorProjectionPolicy
        // Not loaded wins over everything (first render regardless).
        #expect(P.decide(
            loaded: false, busy: true, forceFull: true,
            matchesSurface: true, sameSequence: true) == .initialRender)
        // Busy defers even a forced/echo delivery.
        #expect(P.decide(
            loaded: true, busy: true, forceFull: true,
            matchesSurface: true, sameSequence: true) == .deferUntilClean)
        // Forced beats echo (the heal must rebuild).
        #expect(P.decide(
            loaded: true, busy: false, forceFull: true,
            matchesSurface: true, sameSequence: true) == .forcedFullRender)
        // Echo beats differential (touch nothing in the view).
        #expect(P.decide(
            loaded: true, busy: false, forceFull: false,
            matchesSurface: true, sameSequence: true) == .adoptEcho)
        // Same sequence differs → differential.
        #expect(P.decide(
            loaded: true, busy: false, forceFull: false,
            matchesSurface: false, sameSequence: true) == .differential)
        // Else: full render.
        #expect(P.decide(
            loaded: true, busy: false, forceFull: false,
            matchesSurface: false, sameSequence: false) == .fullRender)
    }

    /// Mobile S3 ladder, MAJOR 3 — the delivery arm: a DELIVERY may never
    /// take a rewrite arm (a photograph of unknown age consumed at a clean
    /// instant regressed surface + ledger to pre-flush bytes — the retired
    /// Phase 8 clean-instant guarantee, restored at the policy).
    @Test func aDeliveryNeverTakesARewriteArm() {
        typealias P = EditorProjectionPolicy
        // Non-matching delivery at a clean instant: a SIGNAL, both shapes.
        #expect(P.decide(
            loaded: true, busy: false, forceFull: false, delivery: true,
            matchesSurface: false, sameSequence: true) == .refetchFresh)
        #expect(P.decide(
            loaded: true, busy: false, forceFull: false, delivery: true,
            matchesSurface: false, sameSequence: false) == .refetchFresh)
        // Echo adoption stays legal for deliveries (byte-identical to the
        // surface — nothing is rewritten).
        #expect(P.decide(
            loaded: true, busy: false, forceFull: false, delivery: true,
            matchesSurface: true, sameSequence: true) == .adoptEcho)
        // Busy still defers deliveries (precedence unchanged above).
        #expect(P.decide(
            loaded: true, busy: true, forceFull: false, delivery: true,
            matchesSurface: false, sameSequence: true) == .deferUntilClean)
        // A forced heal under a delivery keeps its flag armed for the
        // fresh read rather than rebuilding from the photograph.
        #expect(P.decide(
            loaded: true, busy: false, forceFull: true, delivery: true,
            matchesSurface: false, sameSequence: true) == .refetchFresh)
        // Not-loaded initial render stays delivery-legal (nothing local
        // exists to regress before the first render).
        #expect(P.decide(
            loaded: false, busy: false, forceFull: false, delivery: true,
            matchesSurface: false, sameSequence: false) == .initialRender)
    }

    /// The Mac half of MAJOR 3, pinned at the VM (the mechanism is
    /// genuinely SHARED — `observeSlots` applied deliveries directly
    /// through the same policy): a stale photograph consumed after a
    /// flush settles must never rewrite the Mac surface either.
    @Test func aStaleDeliveryAtACleanInstantNeverRewritesTheMacSurface() async throws {
        try await withEditor(seedBlocks: ["Base."]) { harness in
            try harness.reload()

            // The photograph a delivery might carry: fetched BEFORE the edit.
            let stale = try harness.storeSlots()

            harness.type(" Typed", at: 5)
            await harness.flush() // the clean instant; the store holds the typed bytes
            #expect(harness.documentText == "Base. Typed")

            // The stale photograph lands as a DELIVERY after the flush.
            harness.model.applyProjection(stale, fromDelivery: true)
            #expect(harness.documentText == "Base. Typed",
                    "a delivery never rewrites the surface to pre-flush bytes")

            // The signal settles by a fresh read (the flush's own echo).
            for _ in 0..<100 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(harness.documentText == "Base. Typed")
        }
    }
}
