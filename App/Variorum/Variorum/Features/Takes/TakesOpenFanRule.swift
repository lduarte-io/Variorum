//
//  TakesOpenFanRule.swift
//  Variorum (Mac)
//
//  **VX-733 (VX-770 batch 3) — when an open fan has COLLAPSED.** Her
//  recording: in slot split, ⌥⌘Z removed an AI's second takes from two open
//  blocks; the board went to one column, but both blocks kept the open-fan
//  wash — through a trip to Write and back — until she pressed "close all".
//  The traced mechanism (the run record's BATCH 3 trace): the wash IS the open
//  set's membership (`TakesBoardLayout.isBloomed`), and the open set was only
//  ever reconciled against which blocks the note still HOLDS (VX-428's
//  first-projection prune) — never against whether an open block still has
//  takes to open.
//
//  By state alone the board cannot tell a fan that collapsed from a block whose
//  first-take door (⑂+, R72) she opened on purpose: both are open with one
//  take. So the rule hears the TRANSITION — an open block that held more than
//  one take at the board's last sight and now holds exactly its one. Its open
//  state belonged to takes that are gone; it closes. Everything else stays as
//  she left it:
//  - a block that still holds two or more takes stays open (her R-770-1 — the
//    stay-open behaviour stays);
//  - a block she opened through its first-take door never held two, so
//    nothing collapsed;
//  - a block the note no longer holds is not "collapsed" (VX-428's in-showing
//    precedent: its open state stands, so a ⌥⌘Z that puts it back brings it
//    back open);
//  - a gap slot (a sync race's missing row) is no evidence of anything.
//
//  "Takes" here counts ARCHIVED takes too (`liveVariantCount`) — PROVISIONAL
//  B3-P1 (a): an archived take stays on its block and the open block shows it
//  ("archived · n", the road back the archive receipt names), so archiving a
//  fan's second take keeps the block open exactly as before.
//
//  Pure: the conductor hands over the open set and the slots; the layout
//  closes what this returns through its one door for it. Cost: one pass over
//  the slots, and none at all while nothing is open.
//

import Foundation
import VariorumCore

enum TakesOpenFanRule {
    /// The open blocks that hold MORE than one take in `slots` (active or
    /// archived) — what the board must remember having seen, so a collapse it
    /// did not watch (the board was down) can still be told from a first-take
    /// door. Empty, and no pass at all, when nothing is open.
    nonisolated static func holdingTakes(
        _ open: Set<String>, in slots: [Queries.RenderedBlock]
    ) -> Set<String> {
        guard !open.isEmpty else { return [] }
        var held: Set<String> = []
        for slot in slots where !slot.isGap && slot.liveVariantCount > 1 && open.contains(slot.blockID) {
            held.insert(slot.blockID)
        }
        return held
    }

    /// The open blocks whose fans COLLAPSED: open, holding more than one take
    /// at the last sight (`heldBefore`), and standing in `slots` now — not a
    /// gap — holding exactly their one take.
    nonisolated static func collapsed(
        open: Set<String>, heldBefore: Set<String>, in slots: [Queries.RenderedBlock]
    ) -> Set<String> {
        let candidates = open.intersection(heldBefore)
        guard !candidates.isEmpty else { return [] }
        var gone: Set<String> = []
        for slot in slots where !slot.isGap && slot.liveVariantCount <= 1 && candidates.contains(slot.blockID) {
            gone.insert(slot.blockID)
        }
        return gone
    }
}
