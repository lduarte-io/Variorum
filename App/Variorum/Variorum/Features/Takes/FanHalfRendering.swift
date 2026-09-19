//
//  FanHalfRendering.swift
//  Variorum (Mac)
//
//  **Which take does a fresh successor RENDER** — one rule, one home
//  (13u3 UNIT G; the 18f ladder's R3-8).
//
//  A divide mints two blocks, and every road that runs one then has to park
//  the ring (or the caret) on the take she will be looking at. That answer is
//  the op's own: the placement's chosen, else the block's default —
//  `mintFanBlock` sets both from the anchor's index, and `Operations
//  .renderedVariant` is the same rule read from the store. R1-13 ruled the
//  rule and R2-4 made it literal on the sheet's two roads; the board's INSTANT
//  keep-on-top road kept parking on `variants[0]` — the first CONTRIBUTOR in
//  fan order, which is a different question.
//
//  It was provably equivalent THERE (`KeepOnTopDivide.compose` parks every
//  other take at its END, so `second.variants` is exactly the seed's tail and
//  chosen = default = it), so no wrong landing was ever reachable and no pin
//  can tell the two apart — the finding says so itself, and this file claims
//  no red. What it removes is two expressions of one rule on one board, which
//  is how the sheet's roads went wrong before R2-4: parking on `variants[0]`
//  silently parked NOWHERE whenever another take stood ahead of the seed's
//  half, because `parkFocus` is consumed by matching a slot's RENDERED take.
//

import VariorumCore

extension Operations.FanHalf {
    /// The take this successor renders — the op's own answer, and the only
    /// take a `parkFocus` can land on (it is consumed by matching a slot's
    /// rendered take). The final fallback is the half's first contributor,
    /// which only matters for a half the store could not resolve at all.
    var renderedTakeID: String? {
        placement.chosenVariantId ?? block.defaultVariantId ?? variants.first?.id
    }
}
