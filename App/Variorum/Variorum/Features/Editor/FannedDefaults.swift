//
//  FannedDefaults.swift
//  Variorum (Mac)
//
//  **THE FANNED DEFAULTS.** Dividing or merging a block that carries a fan
//  does not open a ceremony by default; both ceremonies survive as
//  deliberate doors.
//
//  - **Divide — KEEP ON TOP (her ruling U-2, 2026-09-06; the use-report
//    round's 18c batch 1).** Her words: *"I know I said that should be the
//    default, but I honestly believe now that if you divide, the takes
//    should automatically stay on the top block that you divided."* Her
//    follow-up the next night: *"the phone divide should update to match
//    this default divide behavior."* The displayed take is cut into B and C
//    and every OTHER active take rides WHOLE onto B — composed from
//    `Operations.divideW`'s own parking rule (S4-22) by `KeepOnTopDivide`
//    in the core Domain (`Sources/VariorumCore/Domain/`, moved there at 18c
//    batch 3 so `splitBlockAtNewlines` can call it too), so both platforms,
//    all three Mac doors and the newline repair share one brain. **This
//    SUPERSEDES the 13j J4 duplicate default** (Q-M2, her
//    2026-08-03 gate ruling: the other takes were duplicated onto BOTH
//    successors, "those takes are quick to delete"), on the Mac AND on the
//    phone. `Operations.divideDuplicating` stays in core, unchanged, as
//    18f's third preset ("copy the takes to both"); U-5's second preset
//    (they follow the bottom block) is `KeepOnTopDivide.compose(keepBelow:)`.
//  - **Merge (her 2026-08-09 ruling at the parity chain's close) — J4b's
//    half, UNTOUCHED by U-2:** the Mac adopts the CARRY-ALL merge — ONE
//    pairing of the two displayed takes plus every other active take
//    carried whole — composed from the Mac's own `Operations.mergeCeremony`
//    (S4-23), ZERO core change. The phone's parity-C5 implementation is the
//    reference shape.
//
//  Both ceremonies survive as DELIBERATE doors (⌥⌘⇧D / ⌥⌘⇧M — her round-4
//  ruling: "never only a buried menu item"), byte-unchanged behind them.
//
//  This file is the pure half: the carry-all MERGE composition and every
//  word the two roads speak. No AppKit, no store, no view model — so the
//  composition is unit-testable and the copy has ONE home (the
//  `BlockSelectionCopy` / `TrayPath` pattern), which is what keeps two
//  surfaces from wording one act two ways. The divide's composition lives
//  in the core Domain (`Sources/VariorumCore/Domain/KeepOnTopDivide.swift`)
//  because the phone AND a core operation call it; its receipt still speaks
//  from here, since only the Mac speaks one (the phone's divide reports an
//  Undo action and no sentence — M20).
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
    static func chainComposes(
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

    /// The keep-on-top divide's receipt (U-2, 2026-09-06 — it SUPERSEDES
    /// J4's duplicate-shape sentence, which promised copies on both sides).
    /// `kept` is read from the op's OWN result inside the flight (the 13e
    /// batch-3 rule for receipts that count rows), never re-derived from a
    /// projection beside it; `stayedBehind` comes from the composition,
    /// which is the only thing that knows a take could not park.
    ///
    /// An EMPTY take has no legal cut (0 and its end coincide), so it stays
    /// on the original block in lineage with the archived takes. That is
    /// rare and never silent: a take that stopped following the block she
    /// divided is exactly what the J8 copy-truth doctrine says a receipt
    /// must be able to name.
    static func divided(kept: Int, stayedBehind: Int = 0) -> String {
        guard kept > 0 || stayedBehind > 0 else { return "Block divided — ⌥⌘Z undoes it." }
        var clauses: [String] = []
        if kept > 0 {
            clauses.append(kept == 1
                ? "1 other take stayed on the first"
                : "\(kept) other takes stayed on the first")
        }
        if stayedBehind > 0 {
            clauses.append(stayedBehind == 1
                ? "1 empty take stayed with the original block"
                : "\(stayedBehind) empty takes stayed with the original block")
        }
        return "Block divided — the take you were in split across both blocks; "
            + clauses.joined(separator: ", and ") + ". ⌥⌘Z undoes."
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

    // MARK: The fan-fold ROADS (one sentence, two speakers)

    /// **The roads out of "backspace won't fold a fan away", in ONE home**
    /// (13j ladder A round 1, finding A2 — fixed by the reviewer, cross-model
    /// flow). Two refusals make this promise: the texted-seam refusal
    /// (`EditorSurfaceController.seamFanRefusal`) and the empty-looking
    /// seam's diagnosis (`CrossBlockRefusal.roadClause(.seamBesideFan)`) —
    /// different guards, same promise. The J4b flip's copy sweep was
    /// site-directed and caught only the first, so the second went on
    /// teaching "⌘⇧M pairs the takes yourself" after ⌘⇧M stopped pairing.
    /// A second home of one sentence is how copy drifts; both speakers now
    /// compose around this constant, and the pin holds them to it.
    static let fanFoldRoads =
        "Merge Blocks (⌘⇧M) joins them and "
        + "brings every take along; Merge choosing takes (⌥⌘⇧M) lets you arrange them yourself."

    // MARK: The ceremony doors' honest refusals

    /// ⌥⌘⇧D where the block carries no fan. The ceremony genuinely cannot
    /// act — there is nothing to place a cut in but the one take — so the
    /// door speaks its real reason and names the door that CAN (P-2: a real
    /// refusal, never a lecture that redirects to nothing).
    static let divideCeremonyNeedsAFan =
        "This block has one take — ⌘⇧D divides it in place. Divide choosing takes is "
        + "for arranging a fan's takes across the two new blocks."

    /// ⌥⌘⇧M where neither block carries a fan.
    static let mergeCeremonyNeedsAFan =
        "These blocks have one take each — ⌘⇧M joins them. Merge choosing takes is "
        + "for arranging the takes when either side has a fan."

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
