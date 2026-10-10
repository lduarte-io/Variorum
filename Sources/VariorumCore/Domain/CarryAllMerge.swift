//
//  CarryAllMerge.swift
//  VariorumCore (Domain)
//
//  **THE FANNED MERGE'S DEFAULT, as arguments** — her 2026-08-09 ruling at
//  the parity chain's close (J4b's half, untouched by U-2): merging two
//  blocks where either carries a fan is the CARRY-ALL merge — ONE pairing of
//  the two displayed takes plus every other active take carried whole —
//  composed from `Operations.mergeCeremony` (S4-23), zero new operation.
//  The receipts and the rest of the fanned defaults' words stay with the
//  Mac's `FannedDefaults.swift`, which keeps the narrative.
//
//  **MOVED here from the Mac app, byte-unchanged in behaviour** (13n-b U3 —
//  AF-10 (b), the `KeepOnTopDivide` 18c-batch-3 precedent): a CORE caller
//  needs the rule now — the MCP door's `merge_blocks` composes her ⌘⇧M
//  default (the keyboard bar, R-13nb-14) — and a core operation cannot
//  import the app. Two homes of one rule is how a rule drifts, so the rule
//  moved to the home every caller can reach. The app's doors call it by the
//  same unqualified name they always did, and every pre-move pin passes
//  unmodified (AF-10's rider: zero test edits is the parity proof).
//
//  Pure, `nonisolated`, store-free.
//

import Foundation

/// **The carry-all merge, as arguments.** `Operations.mergeCeremony` takes
/// hand-placed pairings and carries; the carry-all is exactly ONE of those
/// arrangements — pair the two takes she is looking at, carry everything
/// else — so the default needs no new operation, only this composition.
///
/// Pure and `nonisolated`: the two surfaces that merge (Write's editor, the
/// Takes board's ⌘-click selection) compose through this one function, and a
/// chain link composes through it too (the previous link's merged block is
/// just another leading side).
public nonisolated enum CarryAllMerge {
    public struct Composition: Equatable, Sendable {
        public let pairing: Operations.MergePairing
        /// Every OTHER live ACTIVE take, leading side first then trailing —
        /// the op re-orders carries mechanically by fan order anyway, so this
        /// order is for the receipt's counting, never for the store.
        public let carries: [String]
    }

    /// Composes one link. Returns nil when either displayed take is no
    /// longer in its live ACTIVE fan — the 13d F-3 guard class: a fallback
    /// would join a take she was never looking at, so the caller refuses and
    /// speaks instead.
    ///
    /// The join is the DOOR rule resolved on the two takes' stored texts —
    /// `merge`'s own rule, through the one join brain — so a carry-all over
    /// two single-take blocks would produce byte-identically what the
    /// instant merge produces. (Since R-13u4-3 that rule is the rendering
    /// join; this line read `MergeJoin.canon` and produced a space before
    /// 13u4 UNIT E3. The equality with the instant road is the point and is
    /// pinned — both are doors.)
    public static func compose(
        leadingDisplayedID: String?, leadingFan: [Variant],
        trailingDisplayedID: String?, trailingFan: [Variant]
    ) -> Composition? {
        guard let head = leadingFan.first(where: { $0.id == leadingDisplayedID }),
              let tail = trailingFan.first(where: { $0.id == trailingDisplayedID })
        else { return nil }
        let carries = (leadingFan + trailingFan)
            .map(\.id)
            .filter { $0 != head.id && $0 != tail.id }
        return Composition(
            pairing: Operations.MergePairing(
                firstVariantID: head.id, secondVariantID: tail.id,
                join: MergeJoinRule.door.join(
                    head: head.workingText, tail: tail.workingText)),
            carries: carries)
    }

    /// **The chain's PRE-COMPOUND validation** (13j ladder A round 1,
    /// finding A5 — fixed by the reviewer, cross-model flow; the batch-4
    /// implementer's recommended shape). A fanned link whose displayed take
    /// no longer resolves in its live fan used to fall to plain `merge`
    /// inside the compound — folding that fan to lineage with no speech,
    /// where the PAIR road refuses (`takesChangedMerge`). Every failure mode
    /// is knowable before the compound opens, from the same one store read
    /// the chain already takes: link 1's leading side, and every link's
    /// trailing side. Later links' leading side is the previous link's own
    /// result (the joined take rides `result.variants`), resolvable by
    /// construction — so validating the read is validating the chain.
    ///
    /// **A side with NO takes at all passes through, deliberately** (the
    /// gap-slot class the flow asked this pass to verify): the plain road's
    /// own op refusal (`noRenderableVariant` / `blockNotFound`, typed and
    /// loud, whole compound rolled back) is the honest diagnosis there —
    /// "takes changed" would misname a block that never synced. This
    /// function refuses only the race class: a displayed take absent from a
    /// NON-EMPTY fan.
    ///
    /// Pure, so the matrix is a unit test — and refusing HERE refuses the
    /// WHOLE run before any row is touched, which is what `withCompound`'s
    /// atomicity means the alternative would have been anyway.
    public static func chainComposes(
        order: [String],
        fans: [String: [Variant]],
        displayed: [String: String?]
    ) -> Bool {
        guard let firstID = order.first else { return true }
        func resolves(_ id: String?, in fan: [Variant]) -> Bool {
            guard let id else { return false }
            return fan.contains { $0.id == id }
        }
        var leadingCount = (fans[firstID] ?? []).count
        var leadingResolves = resolves(displayed[firstID] ?? nil, in: fans[firstID] ?? [])
        for nextID in order.dropFirst() {
            let trailingFan = fans[nextID] ?? []
            if leadingCount > 1 || trailingFan.count > 1 {
                // The link the code would compose. Empty sides pass through
                // (the op speaks); a stale displayed take refuses the run.
                if leadingCount >= 1, !leadingResolves { return false }
                if trailingFan.count >= 1,
                   !resolves(displayed[nextID] ?? nil, in: trailingFan) { return false }
                leadingCount = max(1, leadingCount + trailingFan.count - 1)
            } else {
                leadingCount = 1
            }
            // Either road's result leads the next link with its own take.
            leadingResolves = true
        }
        return true
    }

    /// The merged block's JOINED take — the one minted from the pairing.
    ///
    /// Read off the result's own `sources` correspondence rather than
    /// assumed at index 0: the core's chosen rule is "the rendered×rendered
    /// pairing when it exists, else the first pairing", and a carry-all
    /// always passes exactly that pairing — but a chain link needs the take
    /// ITSELF (to seed the next link and to place the caret), and reading it
    /// from the op's own answer is what keeps this from being an inference.
    public static func joinedTake(of result: Operations.MergeCeremonyResult) -> Variant? {
        guard let i = result.sources.firstIndex(where: {
            if case .pairing = $0 { return true }
            return false
        }), i < result.variants.count else { return nil }
        return result.variants[i]
    }
}
