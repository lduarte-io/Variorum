//
//  FannedDefaults.swift
//  Variorum (Mac)
//
//  13j batch 4 (J4 / J4b) — **THE FANNED DEFAULTS.** Two author rulings,
//  one shape: dividing or merging a block that carries a fan no longer
//  opens a ceremony by default. It DUPLICATES.
//
//  - **Divide (Q-M2, her 2026-08-03 gate ruling; the Mac half is 13j's):**
//    the displayed take is cut into B and C and every OTHER active take is
//    duplicated WHOLE onto both — "those takes are quick to delete… this is
//    quicker than dividing, realizing that you lost something you want, and
//    going on some kind of hunt for it." The core op
//    (`Operations.divideDuplicating`) shipped at mobile parity Stage A and
//    has been DORMANT on the Mac since; this batch is its routing.
//  - **Merge (her 2026-08-09 ruling at the parity chain's close):** the Mac
//    adopts the CARRY-ALL merge — ONE pairing of the two displayed takes
//    plus every other active take carried whole — composed from the Mac's
//    own `Operations.mergeCeremony` (S4-23), ZERO core change. The phone's
//    parity-C5 implementation is the reference shape.
//
//  Both ceremonies survive as DELIBERATE doors (⌥⌘⇧D / ⌥⌘⇧M — her round-4
//  ruling: "never only a buried menu item"), byte-unchanged behind them.
//
//  This file is the pure half: the carry-all composition and every word the
//  two roads speak. No AppKit, no store, no view model — so the composition
//  is unit-testable and the copy has ONE home (the `BlockSelectionCopy` /
//  `TrayPath` pattern), which is what keeps two surfaces from wording one
//  act two ways.
//

import Foundation
import VariorumCore

// MARK: - The carry-all merge's composition

/// **The carry-all merge, as arguments.** `Operations.mergeCeremony` takes
/// hand-placed pairings and carries; the carry-all is exactly ONE of those
/// arrangements — pair the two takes she is looking at, carry everything
/// else — so the default needs no new operation, only this composition.
///
/// Pure and `nonisolated`: the two surfaces that merge (Write's editor, the
/// Takes board's ⌘-click selection) compose through this one function, and a
/// chain link composes through it too (the previous link's merged block is
/// just another leading side).
nonisolated enum CarryAllMerge {
    struct Composition: Equatable, Sendable {
        let pairing: Operations.MergePairing
        /// Every OTHER live ACTIVE take, leading side first then trailing —
        /// the op re-orders carries mechanically by fan order anyway, so this
        /// order is for the receipt's counting, never for the store.
        let carries: [String]
    }

    /// Composes one link. Returns nil when either displayed take is no
    /// longer in its live ACTIVE fan — the 13d F-3 guard class: a fallback
    /// would join a take she was never looking at, so the caller refuses and
    /// speaks instead.
    ///
    /// The join is the CANON rule resolved on the two takes' stored texts —
    /// `merge`'s own rule, through the one join brain — so a carry-all over
    /// two single-take blocks would produce byte-identically what the
    /// instant merge produces.
    static func compose(
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
                join: MergeJoin.canon(head: head.workingText, tail: tail.workingText)),
            carries: carries)
    }

    /// The merged block's JOINED take — the one minted from the pairing.
    ///
    /// Read off the result's own `sources` correspondence rather than
    /// assumed at index 0: the core's chosen rule is "the rendered×rendered
    /// pairing when it exists, else the first pairing", and a carry-all
    /// always passes exactly that pairing — but a chain link needs the take
    /// ITSELF (to seed the next link and to place the caret), and reading it
    /// from the op's own answer is what keeps this from being an inference.
    static func joinedTake(of result: Operations.MergeCeremonyResult) -> Variant? {
        guard let i = result.sources.firstIndex(where: {
            if case .pairing = $0 { return true }
            return false
        }), i < result.variants.count else { return nil }
        return result.variants[i]
    }
}

// MARK: - The words

/// Every sentence the two flipped defaults and their ceremony doors speak.
/// One home so Write and the Takes board cannot word one act two ways, and
/// so a pin can hold the receipt's promise (the J8 copy-truth doctrine: a
/// receipt may only claim what the operation actually did).
nonisolated enum FannedDefaultsCopy {
    // MARK: Receipts

    /// The duplicate-shape divide's receipt. `duplicated` is read from the
    /// op's OWN result inside the flight (the 13e batch-3 rule for receipts
    /// that count rows), never re-derived from a projection beside it.
    ///
    /// Her accepted consequence is stated calmly and in her own words: a
    /// duplicated take chosen on both successors reads twice, and the extras
    /// are "quick to delete".
    static func divided(duplicated: Int) -> String {
        guard duplicated > 0 else { return "Block divided — ⌥⌘Z undoes it." }
        let takes = duplicated == 1 ? "1 other take" : "\(duplicated) other takes"
        return "Block divided — the take you were in split across both blocks, and "
            + "\(takes) rode whole onto each. Extra copies are quick to delete; ⌥⌘Z undoes."
    }

    /// The carry-all merge's receipt. `carried` counts what LANDED on the
    /// merged block beside the joined take — again from the op's own result.
    static func merged(carried: Int) -> String {
        guard carried > 0 else { return "Blocks merged — ⌥⌘Z undoes it." }
        let takes = carried == 1 ? "1 other take" : "\(carried) other takes"
        return "Blocks merged — the takes you were looking at joined, and "
            + "\(takes) came along whole. Extra copies are quick to delete; ⌥⌘Z undoes."
    }

    /// The chain's edition of the same sentence (the N-way road, 9d's
    /// supersession — its links carry all the same way).
    static func mergedChain(blocks: Int, carried: Int) -> String {
        guard carried > 0 else { return "Merged \(blocks) blocks — ⌥⌘Z undoes it." }
        let takes = carried == 1 ? "1 other take" : "\(carried) other takes"
        return "Merged \(blocks) blocks — the takes you were looking at joined, and "
            + "\(takes) came along whole. Extra copies are quick to delete; ⌥⌘Z undoes."
    }

    // MARK: The ceremony doors' honest refusals

    /// ⌥⌘⇧D where the block carries no fan. The ceremony genuinely cannot
    /// act — there is nothing to place a cut in but the one take — so the
    /// door speaks its real reason and names the door that CAN (P-2: a real
    /// refusal, never a lecture that redirects to nothing).
    static let divideCeremonyNeedsAFan =
        "This block has one take — ⌘⇧D divides it in place. The ceremony is for "
        + "placing a cut in each take of a fan."

    /// ⌥⌘⇧M where neither block carries a fan.
    static let mergeCeremonyNeedsAFan =
        "These blocks have one take each — ⌘⇧M joins them. The ceremony is for "
        + "pairing takes by hand when either side has a fan."

    /// ⌥⌘⇧M over a run of three or more. The pairing ceremony is pairwise by
    /// construction (S4-23), so this names the road that takes the run.
    static func mergeCeremonyIsPairwise(blocks: Int) -> String {
        "The merge ceremony pairs TWO blocks — this selection covers \(blocks). "
            + "⌘⇧M merges the whole run, carrying every take along."
    }

    /// Either fanned road, where the store moved under the gesture (the F-3
    /// guard class: the take she was looking at is gone from the live fan).
    static let takesChangedDivide = "This block's takes changed — try the divide again."
    static let takesChangedMerge = "These blocks' takes changed — try the merge again."
}
