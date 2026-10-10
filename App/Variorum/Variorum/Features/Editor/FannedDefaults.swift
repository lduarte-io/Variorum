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
//  This file is the pure half: every word the two roads speak (the
//  carry-all MERGE composition it held moved to the core Domain at 13n-b
//  U3 — `CarryAllMerge.swift`, beside `KeepOnTopDivide`). No AppKit, no
//  store, no view model — so the copy has ONE home (the
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

// `CarryAllMerge` — the composition this section held — MOVED to the core
// Domain byte-unchanged at 13n-b U3 (`Sources/VariorumCore/Domain/
// CarryAllMerge.swift`; AF-10 (b), the `KeepOnTopDivide` 18c-batch-3
// precedent): the MCP door's `merge_blocks` composes her default too, and a
// core caller cannot import the app. Every door here calls it by the same
// unqualified name, and every pre-move pin passes unmodified.

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

    // (`mergeCeremonyIsPairwise` — "the merge ceremony pairs TWO blocks …
    // ⌘⇧M merges the whole run" — RETIRED at 18f batch 1 by her ruling U-16:
    // *"if you're merging several notes together you should be given the
    // choice of bringing every take or only the currently shown ones."* The
    // door over a run of three or more no longer refuses; it asks the two
    // questions (`MergeArrangement.offered(blocks:)`) and runs the chain
    // either way. A refusal that could only ever say no is the P-2 class the
    // registry exists to kill, and this was the last one in this file.)

    /// Either fanned road, where the store moved under the gesture (the F-3
    /// guard class: the take she was looking at is gone from the live fan).
    static let takesChangedDivide = "This block's takes changed — try the divide again."
    static let takesChangedMerge = "These blocks' takes changed — try the merge again."
    /// A merge road reached with a block no longer on the surface (18f ladder
    /// R1-2 — the sheet sat open while the projection re-tiled; the entries
    /// are resolved by id at act time and this is the refusal when one is
    /// gone). Same grammar as the two above: nothing touched, try again.
    static let blocksChangedMerge = "These blocks changed — try the merge again."
}
