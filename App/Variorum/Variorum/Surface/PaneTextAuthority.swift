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
//  - EXACTLY ONE live pane across EVERY mounted context of this authority:
//    `livePane` is a single optional — a second live pane is structurally
//    unrepresentable (the batch-14 two-rings defect class, closed by
//    construction instead of by per-surface key conventions). 13b Stage 4
//    (4C — the compare rework's architect precision): a pane's identity
//    CARRIES its post context (`PaneKey.context`), so one authority may
//    span several post contexts (the compare board's columns are different
//    POSTS) and the one-ring invariant holds over the UNION — never a
//    second liveness mechanism beside the authority. Single-post owners
//    leave `context` at its default; every pre-4C call site and pin reads
//    unchanged.
//  - The LIVE pane is BUFFER-AUTHORITATIVE: while an edit is unsettled the
//    buffer overlays the store text (`text(variantID:storeText:)` always
//    prefers the buffer), and surfaces must never clobber a live pane
//    with projection text (`isLive` is the surface's adopt guard). A pane
//    whose BOUND take changes is a pane for ANOTHER take: it adopts that
//    take's text once, by the one surface's re-bind (VX-248, her ruled bend
//    — `PaneSurfaceRepresentable.Coordinator.rebindIfTakeChanged`).
//  - READ panes are PROJECTION-AUTHORITATIVE once caught up: `settle`
//    drops every buffer with no pending autosave record, so external
//    edits (sync, repairs, sibling surfaces) reach the display and
//    resumed typing can never clobber them (the Phase 11 round-2 MAJOR's
//    convergence half, now one tested rule).
//  - A read pane mirroring a variant with a live buffer NEVER renders
//    staler text than that buffer: the overlay applies to every resolver
//    path, not just the live pane (the frozen-article class, closed at
//    the root — including the stack style's bypass, N2's sibling).
//  - A LIVE pane whose OWN take's stored words change from OUTSIDE it stops
//    being live (VX-664 — her ruling, option (a) scoped; the architect's
//    A-677-1): the authority knows what the live pane HOLDS (`liveHeld` —
//    what it showed when it took the ring, then her every keystroke), and a
//    delivery whose stored text for that take differs from it, with nothing
//    of hers pending, names the pane (`settle(isPending:liveIncoming:)`); the
//    owner confirms on a fresh read (`confirmsOutsideWrite`) and runs its own
//    ring-end. The live pane never adopts — it stops being live.
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
        /// The POST CONTEXT the pane belongs to (13b 4C): an authority
        /// spanning several posts (the compare board) keys each pane with
        /// its post, so the caller can route the leaving pane's flush to
        /// THAT post's coordinator on migration. Single-post authorities
        /// leave the default — every pre-4C call site reads unchanged.
        var context: String = ""
    }

    /// The ONE live pane (P3: the live editor migrates on click;
    /// everything else renders read-cheap). A single optional — two live
    /// panes cannot exist, in one post context or across the union of all
    /// mounted contexts (13b 4C).
    private(set) var livePane: PaneKey?

    /// Per-variant buffer while a pane is live and unsettled — the
    /// buffer-authoritative rule in miniature (the editor's discipline).
    private(set) var buffers: [String: String] = [:]

    // MARK: - Focus (the ONE live editor migrates)

    enum FocusOutcome: Equatable {
        /// The pane was already live — nothing to do.
        case unchanged
        /// The ring migrated; `from` is the leaving pane (nil when no pane
        /// was live). The caller flushes the leaving pane's buffer —
        /// through the LEAVING pane's own context's coordinator where the
        /// authority spans several posts (13b 4C: `from.context` names it).
        case migrated(from: PaneKey?)
    }

    /// **What the LIVE pane holds, as far as the authority knows** (VX-664 —
    /// A-677-1): the text the pane SHOWED when it took the ring (`focus`'s
    /// `showing:`), then each of her keystrokes (`bufferEdited`). Nil = not
    /// known (a focus that passed nothing): the next delivery that names the
    /// take is adopted as the baseline, never judged. It is a mirror of the
    /// pane's characters for ONE take, the buffer overlay's own kind — never
    /// a second liveness answer.
    private(set) var liveHeld: String?

    /// `showing` — the text the pane shows as it takes the ring (the owner's
    /// own resolution: the buffer overlay over the stored text). A migration
    /// re-bases what the live pane holds; `.unchanged` keeps it.
    @discardableResult
    mutating func focus(_ pane: PaneKey, showing: String? = nil) -> FocusOutcome {
        guard livePane != pane else { return .unchanged }
        let leaving = livePane
        livePane = pane
        liveHeld = showing
        return .migrated(from: leaving)
    }

    mutating func blur() {
        livePane = nil
        liveHeld = nil
    }

    /// The surface's liveness answer — and its adopt guard: a live pane's
    /// surface is buffer-authoritative and must never be clobbered with
    /// projection text.
    ///
    /// `sealed` is the SUPPRESSION argument, and it has carried more than
    /// one reason since 13d Batch 3: a sealed post has no live pane
    /// (viewing isn't authoring), and a pane whose post is mid-structural-
    /// flight is frozen the same way — a keystroke arriving between a
    /// flush and its operation would autosave pre-operation text back over
    /// the rows the operation just wrote. Callers with more than one
    /// reason compose them into a NAMED local (`let frozen = sealed ||
    /// structuralInFlight`) so no reader mistakes the disjunction for a
    /// seal; `TakesViewModel.isPaneLive` is the worked example. The
    /// parameter keeps its name deliberately — renaming it would churn a
    /// heavily-pinned surface for a comment's worth of clarity.
    func isLive(_ pane: PaneKey, sealed: Bool = false) -> Bool {
        livePane == pane && !sealed
    }

    // MARK: - The buffer overlay

    /// A live pane's keystroke: the buffer is authoritative while dirty.
    mutating func bufferEdited(variantID: String, text: String) {
        buffers[variantID] = text
        if livePane?.variantID == variantID { liveHeld = text }
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
    ///
    /// **"Pending" means UNLANDED** (the VX-849 run, batch 3 — G1): her words
    /// in the debounce OR in the write in flight. A flush takes its batch out
    /// of the coordinator's `pending` before the write lands, so every owner
    /// hands this (and the outside-write rule below) the coordinator's
    /// `isUnlanded` — an owner that adopts a delivery while her write flies
    /// keeps her buffer until the echo, and never reads that delivery as
    /// somebody else's write.
    mutating func settle(isPending: (String) -> Bool) {
        for variantID in buffers.keys where !isPending(variantID) {
            catchUp(variantID: variantID)
        }
    }

    // MARK: - An outside write on the live pane's own take (VX-664 — A-677-1)

    /// **THE ring owners' ONE delivery door** (VX-664 — her ruling, option (a)
    /// scoped: the ring ends ONLY when an outside write lands on the live
    /// pane's OWN take; P-3's buffer authority never bends; no clean-buffer
    /// adoption. The architect's A-677-1: the store's own delivery is the
    /// signal, this rule the decision). Settles exactly as `settle(isPending:)`
    /// does, and answers the live pane when this delivery carries stored words
    /// for ITS take that differ from what it holds while nothing of hers is
    /// pending there — a write that did not come from this pane's typing: a
    /// restore, an AI's `edit_take`, a sync apply, another window, a
    /// structural act that rewrote the take, any road at all, named or not.
    ///
    /// `liveIncoming` is the delivered STORED text of the live pane's take
    /// (nil: this delivery does not carry it — nothing is judged). Her own
    /// pending keystrokes win the race by construction (the buffer is
    /// authoritative while pending — the flush-first rule and the bracket
    /// savepoints insure the roads that meet them; VX-683 is the one road
    /// that cannot flush). Her own words are compared as the store keeps them
    /// (`StoredText.stripped` — the autosave's own transform), so her own
    /// pasted U+0000 never reads as somebody else's write.
    ///
    /// A SUSPICION, never yet the verdict: a delivery may be a photograph
    /// fetched before her own last write landed (the 13e E15 class — consumed
    /// after the settle, it would carry words she has since replaced), so the
    /// owner confirms on a FRESH read of the take (`confirmsOutsideWrite`) and
    /// only then ends the ring with its own blur.
    mutating func settle(
        isPending: (String) -> Bool, liveIncoming: String?
    ) -> PaneKey? {
        let suspect = suspectsOutsideWrite(liveIncoming: liveIncoming, isPending: isPending)
        settle(isPending: isPending)
        return suspect
    }

    private mutating func suspectsOutsideWrite(
        liveIncoming incoming: String?, isPending: (String) -> Bool
    ) -> PaneKey? {
        guard let live = livePane, let incoming, !isPending(live.variantID) else { return nil }
        guard let held = liveHeld else {
            // Not known what the pane holds (a focus that passed nothing):
            // this delivery becomes the baseline — never a verdict.
            liveHeld = incoming
            return nil
        }
        return StoredText.stripped(held) == incoming ? nil : live
    }

    /// The suspicion CONFIRMED on a fresh read of the take: the same pane is
    /// still the live one, nothing of hers is pending for its take, and the
    /// take's stored words — read after the fact, so no photograph can
    /// answer — still differ from what the pane holds. The owner then ends
    /// the ring (VX-222/VX-440's shape: its blur, whose flush is provably
    /// empty; the pane goes read and adopts through the surface's read arm).
    func confirmsOutsideWrite(
        _ suspect: PaneKey, storedText: String, isPending: (String) -> Bool
    ) -> Bool {
        guard livePane == suspect, !isPending(suspect.variantID), let held = liveHeld
        else { return false }
        return StoredText.stripped(held) != storedText
    }

    /// What a pane shows for a variant: the live buffer where one is
    /// unsettled, else the store's text. EVERY pane path resolves through
    /// this — read panes mirroring a dirty variant can never render staler
    /// text than the buffer.
    func text(variantID: String, storeText: String) -> String {
        buffers[variantID] ?? storeText
    }

    /// **The text a pane's NEXT EDIT is built on — what the pane SHOWS right
    /// now** (VX-664 × VX-683 B — the VX-849 run, batch 3, G3; the record
    /// `notes/plans/fixes/vx-849-typed-over-rescue.md`). For the LIVE pane's
    /// take it is what that pane HOLDS (`liveHeld`): a live pane never adopts
    /// projection text (the invariant above), so between a delivery that carried
    /// an outside write and the ring-end its confirmation runs, the owner's
    /// projection — and so `text(variantID:storeText:)`, the settle having
    /// dropped the buffer — already reads the OUTSIDE words while the pane still
    /// shows hers. An edit there built on the projection would hand the guarded
    /// autosave a snapshot the row still holds, and her pre-write words would
    /// land over the outside words unseen. Built on THIS, the row changed under
    /// the edit's snapshot and the autosave rescues: her words keep the row, the
    /// outside words become the `'conflict'` take. The same fact the ring-end
    /// rule judges by, so the two can never disagree about what the pane holds.
    /// Anything else — a read pane, a live pane whose holding is not known — is
    /// the overlay, exactly as before.
    func shownText(variantID: String, storeText: String) -> String {
        if livePane?.variantID == variantID, let liveHeld { return liveHeld }
        return text(variantID: variantID, storeText: storeText)
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
