//
//  KeepOnTopDivide.swift
//  VariorumCore (Domain)
//
//  **THE FANNED DIVIDE'S DEFAULT, as arguments** — the 2026-09-06 ruling
//  U-2, her words: *"I know I said that should be the default, but I
//  honestly believe now that if you divide, the takes should automatically
//  stay on the top block that you divided."* Her follow-up the next night
//  extended it to the phone: *"the phone divide should update to match this
//  default divide behavior."* This SUPERSEDES the 13j J4 duplicate default
//  (Q-M2) on BOTH platforms; J4's carry-all MERGE half is untouched.
//
//  Zero new operation. `Operations.divideW` already does exactly this shape
//  through S4-22's PARKING rule — a cut at a take's very END means the take
//  doesn't split: all of it rides into B, and C's fan simply omits it. So
//  the default is one arrangement of the W's own arguments:
//
//      the displayed take  → cut at the gesture's snapped position (split)
//      every OTHER take    → cut at its UTF-16 length (parked, rides whole)
//
//  and its mirror, `keepBelow` (every other take parked at 0), which is
//  U-5's second preset. The THIRD preset is the shipped
//  `Operations.divideDuplicating`, which stays in core as "copy the takes to
//  both". The presets' FACES are 18f's; this file is the brain all three
//  doors — Write, the Takes board, the phone — compose through, so one
//  gesture cannot grow two answers (`CarryAllMerge`'s pattern, beside which
//  this sits in spirit even though that one lives in the Mac's Editor
//  feature).
//
//  Pure, `nonisolated`, store-free: no AppKit, no UIKit, no view model, so
//  the matrix is a unit test and the phone can call it unchanged.
//
//  **It lives in the DOMAIN, not in the app** (moved there at 18c batch 3):
//  the fourth caller is `Operations.splitBlockAtNewlines`, whose fanned arm
//  is this same arrangement — the displayed take cut at the first paragraph
//  break, every other take parked at its end — and a core operation cannot
//  import the app. Two homes of one rule is how a rule drifts, so the rule
//  moved to the home every caller can reach. The three app doors call it by
//  the same unqualified name they always did.
//

import Foundation

public nonisolated enum KeepOnTopDivide {
    /// Which end the OTHER takes park at — and therefore which successor
    /// they ride into. `.end` is her ruled default (they stay on TOP);
    /// `.start` is the mirror preset (they follow the BOTTOM block).
    public enum Parking: Equatable, Sendable {
        case end
        case start
    }

    public struct Composition: Equatable, Sendable {
        /// Handed straight to `Operations.divideW(_:cuts:displayedVariantID:)`.
        public let cuts: [String: Int]
        /// The take the gesture was placed in — the one that actually
        /// SPLITS, and the anchor for both successors' chosen/default.
        public let displayedID: String
        /// Where the other takes went.
        public let parking: Parking
        /// Live ACTIVE takes deliberately left OUT of `cuts`: an EMPTY take
        /// has no legal cut at all (0 and its end coincide, and `divideW`
        /// refuses that as `invalidCut` — which block would get the blank
        /// is a guess), so it cannot park and stays on A in lineage with
        /// the archived takes. Reported rather than swallowed so the
        /// receipt can say so — a take that quietly stopped following the
        /// block she divided is exactly the class the J8 copy-truth
        /// doctrine exists to keep out of a receipt.
        public let unparkable: [String]

        /// How many other takes ride WHOLE onto the kept side. The receipt
        /// still counts from the op's OWN result (the 13e rule); this is
        /// the composition's own arithmetic, used where no result exists
        /// yet (a preview, a refusal that must name the shape).
        public var parked: Int { cuts.count - 1 }
    }

    /// **Her ruled default: the takes stay on the top block.**
    ///
    /// `fan` must be the block's LIVE ACTIVE fan, read from the STORE (the
    /// 13d discipline — a projection-read fan is an enablement hint, never
    /// an authorization). Archived takes are not in it and stay on A
    /// exactly as they do today.
    ///
    /// Returns nil when the displayed take is not in that fan — the 13d
    /// F-3 guard class: a fallback would divide a take she was never in, at
    /// an offset taken from the one that died. The caller refuses and
    /// speaks (`FannedDefaultsCopy.takesChangedDivide`).
    ///
    /// The displayed take's own `cut` is passed through untouched: snapping
    /// is the editor's contract (`BoundarySnapping`, S4-22), one rule for
    /// every door, and this function never second-guesses it. A cut at the
    /// displayed take's very start or end is left for the op to refuse —
    /// nil here would misname a race.
    public static func compose(displayedID: String?, cut: Int, fan: [Variant]) -> Composition? {
        compose(displayedID: displayedID, cut: cut, fan: fan, parking: .end)
    }

    /// The mirror (U-5's second preset): every other take parks at its
    /// START and rides whole into the BOTTOM block.
    public static func compose(keepBelow displayedID: String?, cut: Int, fan: [Variant]) -> Composition? {
        compose(displayedID: displayedID, cut: cut, fan: fan, parking: .start)
    }

    private static func compose(
        displayedID: String?, cut: Int, fan: [Variant], parking: Parking
    ) -> Composition? {
        guard let displayedID,
              fan.contains(where: { $0.id == displayedID })
        else { return nil }

        var cuts: [String: Int] = [displayedID: cut]
        var unparkable: [String] = []
        for take in fan where take.id != displayedID {
            let length = take.workingText.utf16.count
            guard length > 0 else {
                unparkable.append(take.id)
                continue
            }
            cuts[take.id] = parking == .end ? length : 0
        }
        return Composition(
            cuts: cuts, displayedID: displayedID,
            parking: parking, unparkable: unparkable)
    }
}
