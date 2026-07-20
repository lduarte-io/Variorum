//
//  PaneTextAuthority.swift
//  Variorum
//
//  Phase 13b, Stage 1a (P-3): THE answer to "what text does pane P show,
//  and is it live" — a pure value type absorbing the semantics that were
//  spread across four moving parts (`liveBuffers` / `resolvedTake` /
//  `deferredProjection` / `projectionCaughtUp`; 23 refs over 5 files) and
//  a view-local guard. View models OWN one authority; views never
//  re-derive the decision.
//
//  The invariants, as code (each pinned in PaneTextAuthorityTests):
//  - EXACTLY ONE live pane per context: `livePane` is a single optional —
//    a second live pane is structurally unrepresentable (the batch-14
//    two-rings defect class, closed by construction instead of by
//    per-surface key conventions).
//  - The LIVE pane is BUFFER-AUTHORITATIVE: while an edit is unsettled the
//    buffer overlays the store text (`text(variantID:storeText:)` always
//    prefers the buffer), and surfaces must never clobber a live pane
//    with projection text (`isLive` is the surface's adopt guard).
//  - READ panes are PROJECTION-AUTHORITATIVE once caught up: `settle`
//    drops every buffer with no pending autosave record, so external
//    edits (sync, repairs, sibling surfaces) reach the display and
//    resumed typing can never clobber them (the Phase 11 round-2 MAJOR's
//    convergence half, now one tested rule).
//  - A read pane mirroring a variant with a live buffer NEVER renders
//    staler text than that buffer: the overlay applies to every resolver
//    path, not just the live pane (the frozen-article class, closed at
//    the root — including the stack style's bypass, N2's sibling).
//
//  Pure Swift: no AppKit, no store, no observation machinery — the owning
//  @Observable view model stores one authority value, so every mutation
//  invalidates exactly the views that read it (the batch-14 observation
//  requirement rides the host's stored property, by construction).
//

import Foundation
import VariorumCore

nonisolated struct PaneTextAuthority: Equatable, Sendable {
    /// A pane's identity: which column shows it, which block's slot, and
    /// which take fills it. (Moved here from TakesViewModel — the type the
    /// whole pane family keys on.)
    struct PaneKey: Equatable, Hashable, Sendable {
        var columnID: String
        var blockID: String
        /// The specific take the pane shows (a bloomed fan shows several
        /// panes per block).
        var variantID: String
    }

    /// The ONE live pane (P3: the live editor migrates on click;
    /// everything else renders read-cheap). A single optional — two live
    /// panes cannot exist.
    private(set) var livePane: PaneKey?

    /// Per-variant buffer while a pane is live and unsettled — the
    /// buffer-authoritative rule in miniature (the editor's discipline).
    private(set) var buffers: [String: String] = [:]

    // MARK: - Focus (the ONE live editor migrates)

    enum FocusOutcome: Equatable {
        /// The pane was already live — nothing to do.
        case unchanged
        /// The ring migrated; `from` is the leaving pane (nil when no pane
        /// was live). The caller flushes the leaving pane's buffer.
        case migrated(from: PaneKey?)
    }

    @discardableResult
    mutating func focus(_ pane: PaneKey) -> FocusOutcome {
        guard livePane != pane else { return .unchanged }
        let leaving = livePane
        livePane = pane
        return .migrated(from: leaving)
    }

    mutating func blur() {
        livePane = nil
    }

    /// The surface's liveness answer — and its adopt guard: a live pane's
    /// surface is buffer-authoritative and must never be clobbered with
    /// projection text. A sealed post has no live pane (viewing isn't
    /// authoring).
    func isLive(_ pane: PaneKey, sealed: Bool = false) -> Bool {
        livePane == pane && !sealed
    }

    // MARK: - The buffer overlay

    /// A live pane's keystroke: the buffer is authoritative while dirty.
    mutating func bufferEdited(variantID: String, text: String) {
        buffers[variantID] = text
    }

    /// The projection caught up with this variant (its autosave landed and
    /// the store echoed it back): the buffer drops, the projection is the
    /// truth again.
    mutating func catchUp(variantID: String) {
        buffers.removeValue(forKey: variantID)
    }

    /// Settle-time convergence (the round-2 MAJOR's rule, centralized):
    /// every buffer with NO pending autosave record has fully landed —
    /// drop it so external edits reach the display. Buffers still pending
    /// stay authoritative (the dirty half).
    mutating func settle(isPending: (String) -> Bool) {
        for variantID in buffers.keys where !isPending(variantID) {
            catchUp(variantID: variantID)
        }
    }

    /// What a pane shows for a variant: the live buffer where one is
    /// unsettled, else the store's text. EVERY pane path resolves through
    /// this — read panes mirroring a dirty variant can never render staler
    /// text than the buffer.
    func text(variantID: String, storeText: String) -> String {
        buffers[variantID] ?? storeText
    }

    // MARK: - Slot resolution (the takes family's fall-through)

    /// What a column shows for a slot: the explicit pick where one exists
    /// and is still a live ACTIVE take of the block, else the slot's
    /// ordinary chosen resolution (sparse overrides — the fall-through
    /// class everywhere), with the buffer overlay on whichever wins.
    /// `fan` is the block's live active fan (nil/empty = no fan data).
    func resolvedText(
        pick: String?, slot: Queries.RenderedBlock, fan: [Variant]?
    ) -> (variantID: String, text: String)? {
        if let pick, let take = fan?.first(where: { $0.id == pick }) {
            return (take.id, text(variantID: take.id, storeText: take.workingText))
        }
        guard let variantID = slot.variantID else { return nil }  // gap
        return (variantID, text(variantID: variantID, storeText: slot.text ?? ""))
    }
}
