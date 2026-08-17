//
//  BlockSelection.swift
//  Variorum (Mac)
//
//  Phase 13e, batch 4 (E2 — her A17, verbatim: *"delete several blocks at
//  the same time from a post - highlighting all of the blocks perhaps?
//  block highlight instead of text highlight across blocks?"*).
//
//  THE ONE block-selection brain, shared by the two post surfaces that host
//  one: Write's full-document editor and the Takes board. It is pure — a set
//  of block ids and the anchor a range extends from — because "which blocks
//  are picked" is view state with rules (toggle, extend, prune, order) and
//  those rules must not exist twice. Batch 2 (E3) grew the first copy on
//  `TakesBoardLayout` for her ⌘-click merge selection; E2 needed the same
//  set in Write, and a second copy is exactly the drift class the
//  KnownIssues "six mobile brains are byte-copies" row names. So the board's
//  storage moved HERE and its batch-2 member names stay as thin forwards —
//  the 3C parity pattern, whose proof is that every batch-2 pin compiles and
//  passes UNMODIFIED.
//
//  SESSION-ONLY, always: nothing here is persisted, synced, or projected.
//  It names what the author is pointing at, and it dies with the surface.
//
//  Layer: the Registry (shared, pure, no storage) rather than either
//  feature — the layer-placement rule's other half. It imports nothing but
//  Foundation and the registry walk can evaluate it without mounting a view.
//

import Foundation

nonisolated struct BlockSelection: Equatable, Sendable {
    /// The picked block ids. A SET, not an array: order is never the
    /// selection's to remember — the POST's order is the only order that
    /// means anything, and `inOrder(_:)` reads it from the caller's world
    /// (the store's, never a projection's, wherever an act depends on it).
    private(set) var picked: Set<String> = []

    /// Where a range extension starts: the block the pointer last named,
    /// picked or unpicked. Kept beside `picked` rather than derived,
    /// because "the last one you clicked" is not recoverable from a set.
    private(set) var anchor: String?

    init() {}

    var isEmpty: Bool { picked.isEmpty }
    var count: Int { picked.count }
    func contains(_ blockID: String) -> Bool { picked.contains(blockID) }

    /// The picked blocks in the order the caller's world holds them. Blocks
    /// the order does not hold simply do not appear — a selection can never
    /// make an act address a block the post no longer shows.
    func inOrder(_ order: [String]) -> [String] {
        order.filter { picked.contains($0) }
    }

    /// ⌘-click: pick this block, or unpick it if it was picked. Either way
    /// it becomes the anchor — an unpick is still the pointer naming a
    /// place, and the alternative (keeping a stale anchor) makes the next
    /// ⌘⇧-click extend from somewhere she is no longer looking.
    mutating func toggle(_ blockID: String) {
        if picked.contains(blockID) {
            picked.remove(blockID)
        } else {
            picked.insert(blockID)
        }
        anchor = blockID
    }

    /// ⌘⇧-click: pick everything from the anchor to this block, inclusive.
    /// ADDITIVE — it never unpicks what lies outside the run, so a run can
    /// be assembled out of several stretches.
    ///
    /// With no anchor, or an anchor the order no longer holds (the block
    /// was deleted, moved, or merged away), this degrades to a plain
    /// toggle: extending from nowhere is not a refusal she should have to
    /// read, it is just a first pick.
    mutating func extend(to blockID: String, in order: [String]) {
        guard let anchor,
              let from = order.firstIndex(of: anchor),
              let to = order.firstIndex(of: blockID)
        else {
            toggle(blockID)
            return
        }
        for i in min(from, to)...max(from, to) {
            picked.insert(order[i])
        }
        self.anchor = blockID
    }

    mutating func clear() {
        picked = []
        anchor = nil
    }

    /// Drops picks the world no longer holds — a delete's own victims, a
    /// merge's consumed sources, a block dragged to another note, a sync
    /// arrival. Called wherever the surface adopts a fresh projection, for
    /// the reason batch 2 gave it: a selection that outlives its blocks
    /// offers acts on ghosts, and the count in the banner would be a lie.
    ///
    /// The pick set and the anchor are pruned INDEPENDENTLY: an anchor can
    /// die while every pick survives (she ⌘-clicked a block, unpicked it,
    /// then it was deleted elsewhere), and a guard on the set alone would
    /// leave that anchor to seed a nonsense range.
    mutating func prune(to live: Set<String>) {
        let kept = picked.intersection(live)
        if kept != picked { picked = kept }
        if let anchor, !live.contains(anchor) { self.anchor = nil }
    }

    /// **Do these blocks form ONE unbroken run of the post?** Lives here
    /// beside the selection it describes; `TakesBoardLayout.isContiguousRun`
    /// forwards to it so batch 2's merge pins read unmodified.
    ///
    /// Merge joins NEIGHBOURS (AppSpec §9: `first` immediately before
    /// `second`), so a gapped selection can only ever refuse — and it must
    /// refuse by NAME before anything is minted. Order-driven and pure: the
    /// caller supplies the post's real order.
    static func isContiguousRun(_ picked: Set<String>, in order: [String]) -> Bool {
        guard !picked.isEmpty else { return false }
        let indices = order.enumerated()
            .filter { picked.contains($0.element) }
            .map(\.offset)
        guard indices.count == picked.count, let first = indices.first,
              let last = indices.last
        else { return false }  // a selected block the order doesn't hold
        return last - first + 1 == indices.count
    }
}
