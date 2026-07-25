//
//  PaneTextAuthorityTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1a — the P-3 authority's invariants AS TESTS: exactly
//  one live pane; the live pane is buffer-authoritative; read panes are
//  projection-authoritative once caught up; a read pane mirroring a
//  variant with a live buffer never renders staler text than that buffer.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("PaneTextAuthority (13b P-3)")
struct PaneTextAuthorityTests {
    private func key(_ column: String, _ block: String, _ variant: String)
        -> PaneTextAuthority.PaneKey
    {
        .init(columnID: column, blockID: block, variantID: variant)
    }

    private func slot(
        _ blockID: String, variantID: String?, text: String?
    ) -> Queries.RenderedBlock {
        Queries.RenderedBlock(
            blockID: blockID, placementID: "p-\(blockID)", position: "a",
            variantID: variantID, text: text,
            activeVariantCount: variantID == nil ? 0 : 1,
            liveVariantCount: variantID == nil ? 0 : 1, commentCount: 0,
            variantLocked: false)
    }

    // MARK: - Invariant 1: exactly one live pane

    @Test func exactlyOneLivePaneEverExists() {
        var authority = PaneTextAuthority()
        let a = key("main", "b1", "v1")
        let b = key("fan", "b1", "v2")

        #expect(authority.focus(a) == .migrated(from: nil))
        #expect(authority.isLive(a))
        #expect(!authority.isLive(b))

        // The batch-14 two-rings class: focusing a second pane MIGRATES —
        // the first pane's ring is gone the same instant, structurally.
        #expect(authority.focus(b) == .migrated(from: a))
        #expect(!authority.isLive(a))
        #expect(authority.isLive(b))

        // Re-focusing the live pane is a no-op (no spurious flushes).
        #expect(authority.focus(b) == .unchanged)

        authority.blur()
        #expect(!authority.isLive(a) && !authority.isLive(b))
    }

    /// 13b Stage 4 (4C — the compare rework's architect precision): ONE
    /// authority may span several POST contexts (compare's columns are
    /// different posts), pane identity carries its context, and the
    /// one-ring invariant holds over the UNION — focusing a pane in post B
    /// migrates the ring OUT of post A's pane the same instant, and the
    /// migration hands back the leaving pane's context so the caller can
    /// flush THAT post's coordinator.
    @Test func oneRingHoldsAcrossPostContexts() {
        var authority = PaneTextAuthority()
        let inPostA = PaneTextAuthority.PaneKey(
            columnID: "compare-anchor", blockID: "bA", variantID: "vA", context: "postA")
        let inPostB = PaneTextAuthority.PaneKey(
            columnID: "compare-col-1", blockID: "bB", variantID: "vB", context: "postB")

        #expect(authority.focus(inPostA) == .migrated(from: nil))
        #expect(authority.isLive(inPostA))
        #expect(!authority.isLive(inPostB))

        // Cross-context migration: one optional, one ring — structurally.
        let outcome = authority.focus(inPostB)
        guard case .migrated(let leaving) = outcome else {
            Issue.record("cross-context focus must migrate"); return
        }
        #expect(leaving == inPostA)
        #expect(leaving?.context == "postA",
                "the migration names the LEAVING pane's post — its coordinator flushes")
        #expect(!authority.isLive(inPostA))
        #expect(authority.isLive(inPostB))
        #expect(authority.livePane?.context == "postB")
    }

    /// Context is part of pane IDENTITY: the same column/block/variant
    /// triple in different contexts is a different pane (no accidental
    /// two-live-panes via a context-blind equality), and the default
    /// context keeps every single-post key equal to its pre-4C self.
    @Test func contextIsPartOfPaneIdentity() {
        let bare = key("main", "b1", "v1")
        let defaulted = PaneTextAuthority.PaneKey(
            columnID: "main", blockID: "b1", variantID: "v1", context: "")
        #expect(bare == defaulted, "the default context IS the single-post identity")
        let contextual = PaneTextAuthority.PaneKey(
            columnID: "main", blockID: "b1", variantID: "v1", context: "postA")
        #expect(bare != contextual)

        var authority = PaneTextAuthority()
        authority.focus(bare)
        #expect(!authority.isLive(contextual),
                "a context-carrying twin of the live key is NOT live")
    }

    /// Buffers are keyed by VARIANT (globally unique) — the overlay and
    /// settle rules need no per-context split, and a union-pending closure
    /// keeps each post's dirty buffers authoritative independently.
    @Test func settleAcrossContextsDropsOnlyTheFullyLandedBuffers() {
        var authority = PaneTextAuthority()
        authority.bufferEdited(variantID: "vA", text: "typed in post A")
        authority.bufferEdited(variantID: "vB", text: "typed in post B")

        // Post A's coordinator landed; post B's is still pending — the
        // union closure answers per variant.
        authority.settle(isPending: { $0 == "vB" })

        #expect(authority.text(variantID: "vA", storeText: "store A") == "store A")
        #expect(authority.text(variantID: "vB", storeText: "store B") == "typed in post B")
    }

    @Test func aSealedContextHasNoLivePane() {
        var authority = PaneTextAuthority()
        let a = key("main", "b1", "v1")
        authority.focus(a)
        #expect(authority.isLive(a, sealed: false))
        #expect(!authority.isLive(a, sealed: true),
                "the seal freezes authoring — no pane is live under it")
    }

    // MARK: - Invariant 2: the live pane is buffer-authoritative

    @Test func theBufferOverlaysTheStoreWhileUnsettled() {
        var authority = PaneTextAuthority()
        authority.bufferEdited(variantID: "v1", text: "typed, unsettled")
        #expect(authority.text(variantID: "v1", storeText: "stale store")
                == "typed, unsettled")
        // Another variant reads the store — the overlay is per-variant.
        #expect(authority.text(variantID: "v2", storeText: "store text") == "store text")
    }

    // MARK: - Invariant 3: read panes are projection-authoritative once caught up

    @Test func settleDropsExactlyTheLandedBuffers() {
        var authority = PaneTextAuthority()
        authority.bufferEdited(variantID: "landed", text: "old typing")
        authority.bufferEdited(variantID: "pending", text: "newer typing")

        authority.settle(isPending: { $0 == "pending" })

        // The landed buffer converged to the store; the pending one stays
        // authoritative (the dirty half).
        #expect(authority.text(variantID: "landed", storeText: "external edit")
                == "external edit")
        #expect(authority.text(variantID: "pending", storeText: "stale") == "newer typing")
    }

    @Test func catchUpConvergesOneVariant() {
        var authority = PaneTextAuthority()
        authority.bufferEdited(variantID: "v1", text: "typing")
        authority.catchUp(variantID: "v1")
        #expect(authority.text(variantID: "v1", storeText: "the store") == "the store")
        #expect(authority.buffers.isEmpty)
    }

    // MARK: - Invariant 4: a read pane never renders staler than the buffer

    @Test func everyResolverPathOverlaysTheBuffer() {
        // The frozen-article class (incl. the stack-style bypass): ANY pane
        // mirroring a dirty variant — picked or chosen-fallback — resolves
        // to the buffer, never the store's stale text.
        var authority = PaneTextAuthority()
        let take1 = Variant.forTesting(id: "v1", blockID: "b1", workingText: "store one")
        let take2 = Variant.forTesting(id: "v2", blockID: "b1", workingText: "store two")
        authority.bufferEdited(variantID: "v2", text: "buffer two, newer")

        // Picked path.
        let picked = authority.resolvedText(
            pick: "v2", slot: slot("b1", variantID: "v1", text: "store one"),
            fan: [take1, take2])
        #expect(picked?.variantID == "v2")
        #expect(picked?.text == "buffer two, newer")

        // Chosen-fallback path.
        authority.bufferEdited(variantID: "v1", text: "buffer one, newer")
        let fallback = authority.resolvedText(
            pick: nil, slot: slot("b1", variantID: "v1", text: "store one"),
            fan: [take1, take2])
        #expect(fallback?.variantID == "v1")
        #expect(fallback?.text == "buffer one, newer")
    }

    @Test func aDeadPickFallsThroughToChosen() {
        let authority = PaneTextAuthority()
        // The pick names a take that is no longer in the live active fan
        // (archived/deleted remotely): fall through to chosen.
        let resolved = authority.resolvedText(
            pick: "gone", slot: slot("b1", variantID: "v1", text: "chosen text"),
            fan: [Variant.forTesting(id: "v1", blockID: "b1", workingText: "chosen text")])
        #expect(resolved?.variantID == "v1")
        #expect(resolved?.text == "chosen text")
    }

    @Test func aGapSlotResolvesToNothingAndNeverCrashes() {
        let authority = PaneTextAuthority()
        #expect(authority.resolvedText(
            pick: nil, slot: slot("b1", variantID: nil, text: nil), fan: nil) == nil)
    }

    @Test func anEmptyTakeResolvesToItsKeptEmptyText() {
        // R103: an emptied take keeps the block's line — the resolver
        // returns the empty text (a real value, not a gap), so the pane
        // renders and the kept-line note's condition is one equality.
        let authority = PaneTextAuthority()
        let resolved = authority.resolvedText(
            pick: nil, slot: slot("b1", variantID: "v1", text: ""), fan: nil)
        #expect(resolved?.variantID == "v1")
        #expect(resolved?.text == "")
    }
}

// MARK: - Test support

extension Variant {
    /// A minimal in-memory Variant for pure resolver tests (never persisted).
    static func forTesting(id: String, blockID: String, workingText: String) -> Variant {
        Variant(
            id: id, blockId: blockID, parentVariantId: nil,
            workingText: workingText, status: .active, locked: false,
            label: nil, fanPosition: "a",
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0),
            deletedAt: nil)
    }
}
