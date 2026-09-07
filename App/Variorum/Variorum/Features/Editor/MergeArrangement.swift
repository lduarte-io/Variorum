//
//  MergeArrangement.swift
//  Variorum (Mac)
//
//  **THE MERGE'S ARRANGEMENT ROW** — the merge half of her U-5 row and the
//  whole of U-16 (2026-09-06 use-report round, 18f batch 1).
//
//  U-16, verbatim (2026-09-07, at the mockup approval): *"if you're merging
//  several notes together you should be given the choice of bringing every
//  take or only the currently shown ones, but i don't want a super complex
//  ceremony for merging multiple blocks together."*
//
//  So "Merge choosing takes…" asks FIRST, in the divide sheet's own grammar:
//
//    a PAIR  →  Bring every take · Only the two shown · Pair by hand…
//    a RUN   →  Bring every take · Only the shown ones            (U-16)
//
//  and over a run the pairing surface never mounts at all — which is what
//  retires the standing `mergeCeremonyIsPairwise` refusal (a door that could
//  only say no is exactly what P-2 forbids; now it asks).
//
//  Nothing here is a new operation. "Bring every take" is `CarryAllMerge`
//  over `Operations.mergeCeremony` — the shipped J4b default, link by link;
//  "only the shown ones" is plain `Operations.merge`, link by link, with the
//  other takes staying with their released blocks in lineage exactly as merge
//  has always left them; "pair by hand" is the shipped S4-23 sheet.
//
//  Pure and `nonisolated`: the row's words and the chain's body are the same
//  on Write, the Takes board and the Blocks workbench, because all three read
//  them from here (`FannedDefaultsCopy`'s own doctrine — one home, so two
//  surfaces cannot word or run one act two ways).
//

import Foundation
import VariorumCore

// MARK: - The row

nonisolated enum MergeArrangement: String, CaseIterable, Equatable, Sendable, Identifiable {
    /// The carry-all: the shown takes join, every other take rides whole
    /// onto the merged block. Her J4b default, and the one selected on open.
    case bringEveryTake
    /// The plain merge: the shown takes join and nothing else comes — the
    /// others stay with their released blocks in lineage.
    case onlyTheShownOnes
    /// The shipped S4-23 pairing sheet. PAIRS ONLY (U-16).
    case pairByHand

    var id: String { rawValue }

    /// What the row offers for a merge over `blocks` blocks. Three for a
    /// pair; U-16's two for a run.
    static func offered(blocks: Int) -> [MergeArrangement] {
        blocks > 2 ? [.bringEveryTake, .onlyTheShownOnes] : allCases
    }

    func title(blocks: Int) -> String {
        switch self {
        case .bringEveryTake: "Bring every take"
        case .onlyTheShownOnes: blocks > 2 ? "Only the shown ones" : "Only the two shown"
        case .pairByHand: "Pair by hand…"
        }
    }

    /// **The option card's one line** (18f batch 2, mockup figure B —
    /// ADDITIVE: a display string beside `title`, so the row's whole voice
    /// stays in one home, exactly as the divide row's `detail` does).
    func detail(blocks: Int) -> String {
        switch self {
        case .bringEveryTake:
            blocks > 2
                ? "the shown takes join in order; every other take comes along whole"
                : "the two shown join; every other take comes along whole"
        case .onlyTheShownOnes:
            "the others stay with their original blocks, in lineage"
        case .pairByHand:
            "\u{FF0B} pairings, carries, and the join per pair"
        }
    }
}

/// The one sentence under the merge row — the mockup's, in counts, pure so it
/// is pinned rather than read off a screenshot.
nonisolated enum MergeArrangementCopy {
    /// `otherTakes` is what would come along BEYOND the shown ones: the sum
    /// over the run of (live active takes − 1).
    static func sentence(
        _ arrangement: MergeArrangement, blocks: Int, otherTakes: Int
    ) -> String {
        let shown = blocks > 2
            ? "The \(blocks) takes you were looking at join in order."
            : "The two takes you were looking at join with a space."
        // The verb follows the count (18f ladder R1-3): "1 other take comes".
        let takes = otherTakes == 1 ? "1 other take" : "\(otherTakes) other takes"
        let one = otherTakes == 1
        switch arrangement {
        case .bringEveryTake:
            guard otherTakes > 0 else {
                return "\(shown) There are no other takes to bring. "
                    + "Reversible — \u{2325}\u{2318}Z."
            }
            return "\(shown) \(takes) \(one ? "comes" : "come") along whole onto the merged block. "
                + "Reversible — \u{2325}\u{2318}Z."
        case .onlyTheShownOnes:
            guard otherTakes > 0 else {
                return "\(shown) There are no other takes. Reversible — \u{2325}\u{2318}Z."
            }
            return "\(shown) \(takes) \(one ? "stays" : "stay") with the released blocks in lineage "
                + "(\(TrayPath.originalsPath)). Reversible — \u{2325}\u{2318}Z."
        case .pairByHand:
            return "Place a \u{FF0B} between one take on each side to mint a joined take, "
                + "check \u{201C}carry\u{201D} to ride a take over whole, and anything left "
                + "stays with its released block in lineage."
        }
    }

    /// The bulk bars' door (the Takes board's ⌘-click banner, the Blocks
    /// workbench's bulk bar). It names the act, never the verb's scope —
    /// the registry owns the verb.
    static func bannerHelp(blocks: Int) -> String {
        blocks > 2
            ? "Join the picked blocks — choose whether every take comes along or only the shown ones"
            : "Join the picked blocks — choose whether every take comes along or only the two shown"
    }
}

// MARK: - The chain, ONE body

/// **The N-way merge's one loop.** Write's `mergeChain`, the Takes board's
/// ⌘-click merge and the Blocks workbench's bulk merge each carried their own
/// copy of this; U-16 gives all three a second road (plain links), and three
/// copies of a two-road loop is three chances to disagree. One body, three
/// callers, each doing only what it does with the landing (Write moves a
/// caret, the board parks a ring, the workbench speaks).
///
/// Runs INSIDE the caller's `withCompound` — the whole run is ONE undo entry,
/// atomic on partial failure, exactly as it has always been.
nonisolated enum MergeChainRun {
    struct Landing: Equatable, Sendable {
        let blockID: String
        /// The merged block's chosen take: the JOINED one on a carry-all
        /// link (read off the op's own `sources` correspondence), the merged
        /// variant on a plain one.
        let variantID: String
        let takesOnMerged: Int
        let mergedTextLength: Int
    }

    /// `bringEveryTake` = U-16's first choice (carry-all links); false = the
    /// plain chain, every link `Operations.merge`, the other takes left with
    /// their released blocks.
    ///
    /// A link only takes the carry-all road when a fan is actually there —
    /// an unfanned link is byte-identically `merge` either way, which is why
    /// the two roads converge on a fanless run (and why the receipt counts
    /// from the ops' own answers rather than from an assumption).
    static func run(
        _ ops: Operations, order: [String],
        fans: [String: [Variant]], displayed: [String: String?],
        bringEveryTake: Bool
    ) throws -> Landing {
        var mergedID = order[0]
        var mergedVariantID = (displayed[order[0]] ?? nil) ?? ""
        var leadingFan = fans[order[0]] ?? []
        var leadingDisplayedID = displayed[order[0]] ?? nil
        var takesOnMerged = leadingFan.count
        var mergedLength = 0
        for next in order.dropFirst() {
            let trailingFan = fans[next] ?? []
            if bringEveryTake, leadingFan.count > 1 || trailingFan.count > 1,
               let composition = CarryAllMerge.compose(
                leadingDisplayedID: leadingDisplayedID, leadingFan: leadingFan,
                trailingDisplayedID: displayed[next] ?? nil,
                trailingFan: trailingFan) {
                let result = try ops.mergeCeremony(
                    mergedID, next,
                    pairings: [composition.pairing], carries: composition.carries)
                let joined = CarryAllMerge.joinedTake(of: result)
                mergedID = result.block.id
                mergedVariantID = joined?.id ?? result.variants[0].id
                leadingFan = result.variants
                leadingDisplayedID = joined?.id
                takesOnMerged = result.variants.count
                mergedLength = joined?.workingText.utf16.count ?? 0
            } else {
                let result = try ops.merge(mergedID, next)
                mergedID = result.block.id
                mergedVariantID = result.variant.id
                leadingFan = [result.variant]
                leadingDisplayedID = result.variant.id
                takesOnMerged = 1
                mergedLength = result.variant.workingText.utf16.count
            }
        }
        return Landing(
            blockID: mergedID, variantID: mergedVariantID,
            takesOnMerged: takesOnMerged, mergedTextLength: mergedLength)
    }
}
