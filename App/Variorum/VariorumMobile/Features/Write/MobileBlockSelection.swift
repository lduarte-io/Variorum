//
//  MobileBlockSelection.swift
//  VariorumMobile
//
//  Round 2, batch 7 (PR20 — the 13e E2 twin, phone shape). Her A17 on the
//  Mac, verbatim: *"delete several blocks at the same time from a post -
//  highlighting all of the blocks perhaps?"*
//
//  ── WHAT THIS IS, AND WHAT IT DELIBERATELY IS NOT ───────────────────────
//
//  The picked block ids and nothing else. **P1: ids, never text copies** —
//  a selection over a 10,000-block note costs the ids she pointed at.
//  SESSION-ONLY, always: nothing here is persisted, synced, or projected.
//
//  ── THE FORK, DECLARED ──────────────────────────────────────────────────
//
//  The Mac's `BlockSelection` (`App/Variorum/Variorum/Registry/`) is the same
//  idea and this batch is FENCED out of that target (#94: the four hoists
//  wait for the post-13u merge), so this is a **recorded fork on the
//  KnownIssues forked-brains row**, not an accident — and it is deliberately
//  a STRICT SUBSET rather than a byte-copy, because two of the Mac's members
//  answer questions the phone does not have:
//
//  · **no `extend(to:in:)`** — that is ⌘⇧-click's range, and the phone has
//    no chord culture (#59(c)'s "⌘⇧-click extends the run" has no phone
//    twin). Tap-to-toggle is the whole gesture.
//  · **no `isContiguousRun`** — that is MERGE's precondition, and **Merge
//    Selected is deliberately NOT BUILT** here (batch 9's proposal (A) is
//    PROPOSE-ONLY and awaits her ruling). Shipping the rule with no act
//    would be machinery guarding nothing.
//
//  A hoist that later unifies the two must bring the Mac's members back with
//  the acts that need them, not merely to match a shape.
//

import Foundation

nonisolated struct MobileBlockSelection: Equatable, Sendable {
    /// The picked block ids. A SET, not an array: order is never the
    /// selection's to remember — the NOTE's order is the only order that
    /// means anything, and `inOrder(_:)` reads it from the caller's world.
    private(set) var picked: Set<String> = []

    init() {}

    var isEmpty: Bool { picked.isEmpty }
    var count: Int { picked.count }
    func contains(_ blockID: String) -> Bool { picked.contains(blockID) }

    /// The picked blocks in the order the caller's world holds them. Blocks
    /// the order does not hold simply do not appear — a selection can never
    /// make an act address a block the note no longer shows.
    func inOrder(_ order: [String]) -> [String] {
        order.filter { picked.contains($0) }
    }

    /// A tap: pick this block, or unpick it if it was picked.
    mutating func toggle(_ blockID: String) {
        if picked.contains(blockID) {
            picked.remove(blockID)
        } else {
            picked.insert(blockID)
        }
    }

    mutating func clear() { picked = [] }

    /// Drops picks the world no longer holds — a delete's own victims, a
    /// merge's consumed sources, a sync arrival. Called wherever the surface
    /// adopts a fresh listing, for the Mac's own reason: **a selection that
    /// outlives its blocks offers acts on ghosts, and the count in the
    /// banner would be a lie.**
    mutating func prune(to live: Set<String>) {
        let kept = picked.intersection(live)
        if kept != picked { picked = kept }
    }
}
