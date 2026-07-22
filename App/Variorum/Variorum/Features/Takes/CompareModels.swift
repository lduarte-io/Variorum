//
//  CompareModels.swift
//  Variorum
//
//  Phase 13b, Stage 4 (4C — S4-2/S4-3/S4-12, N29): the compare board's
//  PURE composition brain. The one honesty rule, hers: blanks and rails
//  render only where lineage actually speaks — a zero-relationship pair
//  shows the posts plainly side by side in their own orders ("there is no
//  relationship here"), never a gap parade; a partial relationship aligns
//  ONLY the kin rows, and the unrelated stretches between them pack side
//  by side in their own orders.
//
//  Built ON `PostAlignment.rows` (one registration brain — the 11a spike's
//  lineage-keyed, never-order rule and its `moved` marking survive intact;
//  their pins stand untouched). This layer only decides which rows ALIGN
//  and which stretches flow free, up to four columns (the anchor + three
//  peers — S4-2c + the 2026-07-17 N-post intake).
//

import Foundation

nonisolated enum CompareComposition {
    /// A kin row: lineage speaks here — the anchor block and each peer's
    /// kin cells sit side by side, rail-colored by the anchor block.
    struct AlignedRow: Equatable {
        var anchorBlockID: String
        /// Per peer, in column order: the peer's kin blocks for this anchor
        /// (a divide's span is several; empty = this peer has nothing here —
        /// the cell simply does not render, never a "—" blank).
        var peerKin: [[String]]
        /// Per peer: the kin arrived out of the peer's own relative order
        /// (a cross-version reorder — marked, never guessed at).
        var peerMoved: [Bool]
    }

    enum Segment: Equatable {
        /// An unrelated stretch: each column packs its own blocks, in its
        /// own order, side by side — no forced registration, no blanks
        /// (N29/S4-12). `anchor` may be empty while a peer flows, and vice
        /// versa.
        case free(anchor: [String], peers: [[String]])
        /// A row where kinship exists in at least one peer.
        case aligned(AlignedRow)
    }

    /// The board's display composition. `kinships` maps, per peer, that
    /// peer's block → its anchor kin (`Queries.blockKinship`'s shape).
    /// `followAnchorOrder` OFF (S4-3/S4-12's display-only toggle) — or no
    /// kinship anywhere — collapses to ONE free segment: every column in
    /// its own order, side by side.
    ///
    /// PROVISIONAL (ladder round 3, MINOR-C — the author's call at the 13c
    /// kickoff; recorded in the plan file's Batch 4C section): in a MIXED
    /// multi-peer board, a peer with NO kinship at all has no row that
    /// bounds its run, so its whole post renders in the TRAILING free
    /// segment — below every aligned row. On a long anchor fully kin to
    /// another peer that column reads blank for many rows. The alternative
    /// (special-case an empty `kinships` peer to flush at the first bound,
    /// as the whole-board zero-lineage case does) is one arm away; the
    /// shipped behavior is pinned by
    /// `aPeerWithNoKinshipAtAllTrailsEveryAlignedRow`.
    static func segments(
        anchorBlocks: [String],
        peerBlocks: [[String]],
        kinships: [[String: String]],
        followAnchorOrder: Bool
    ) -> [Segment] {
        let peerCount = peerBlocks.count
        func wholeFree() -> [Segment] {
            if anchorBlocks.isEmpty && peerBlocks.allSatisfy(\.isEmpty) { return [] }
            return [.free(anchor: anchorBlocks, peers: peerBlocks)]
        }
        guard followAnchorOrder, peerCount > 0 else { return wholeFree() }

        // Per-peer registration through the ONE row brain (PostAlignment —
        // lineage-keyed, order-anchored, moved-marked; its pins stand).
        var kinByAnchor: [[String: [String]]] = []
        var movedAnchors: [Set<String>] = []
        /// Per peer: kin-less runs, keyed by the anchor row they follow
        /// (nil = before every anchor), in the peer's own order.
        var orphanRuns: [[String?: [String]]] = []
        var anyKin = false
        for p in 0..<peerCount {
            let rows = PostAlignment.rows(
                anchorBlocks: anchorBlocks, otherBlocks: peerBlocks[p],
                kinship: kinships[p])
            var kins: [String: [String]] = [:]
            var moved: Set<String> = []
            var orphans: [String?: [String]] = [:]
            var lastAnchor: String?
            for row in rows {
                if let anchor = row.anchorBlockID {
                    if !row.otherBlockIDs.isEmpty {
                        kins[anchor] = row.otherBlockIDs
                        anyKin = true
                    }
                    if row.moved { moved.insert(anchor) }
                    lastAnchor = anchor
                } else {
                    orphans[lastAnchor, default: []] += row.otherBlockIDs
                }
            }
            kinByAnchor.append(kins)
            movedAnchors.append(moved)
            orphanRuns.append(orphans)
        }
        guard anyKin else { return wholeFree() }

        var segments: [Segment] = []
        var freeAnchor: [String] = []
        var freePeers: [[String]] = Array(repeating: [], count: peerCount)
        /// Flush pending free material AHEAD of an aligned row — but only
        /// what that row actually ORDERS: the anchor's own pending blocks
        /// (they precede this anchor block in the anchor's order) and the
        /// pending runs of peers whose KIN sits in the arriving row (the
        /// run precedes that peer's kin in the peer's own order). A peer
        /// with NO kin in the row keeps its run pending — peers register
        /// against the anchor INDEPENDENTLY (the multi-peer pin's letter),
        /// so another peer's kin row never splits that peer's stretch.
        /// The gate's traced defect was the unconditional flush here —
        /// peer2's kin row force-flushed peer1's trailing run into its own
        /// mostly-empty segment (aligned·free[P1x|—]·aligned·free[—|P2x]
        /// where the record promises aligned·aligned·free[P1x|P2x]).
        ///
        /// THE ASYMMETRY, stated honestly (ladder round 3, MINOR-B — the
        /// behavior is deliberate, the earlier wording was not): the
        /// ANCHOR side still flushes at EVERY aligned row, because it
        /// genuinely IS bounded by every one of them (a pending anchor
        /// block precedes this anchor block in the anchor's own order, and
        /// the anchor's order is the board's spine). Only PEER runs wait.
        /// The accepted consequence: material that would once have shared
        /// one packed segment can split into two sparser ones — anchor
        /// [A,B,C] with peer0 [P1x, C1'] (kin C) and peer1 [B2'] (kin B)
        /// composes `free[A|—|—] · aligned(B) · free[—|P1x|—] ·
        /// aligned(C)`, not one `free[A|P1x|—]`. Pinned exactly:
        /// `theAnchorFlushesAtEveryAlignedRowWhileAPeerRunWaits`.
        func flushFree(forcing: [Bool]) {
            let flushable = (0..<peerCount).filter { forcing[$0] && !freePeers[$0].isEmpty }
            guard !freeAnchor.isEmpty || !flushable.isEmpty else { return }
            var peers: [[String]] = Array(repeating: [], count: peerCount)
            for p in flushable {
                peers[p] = freePeers[p]
                freePeers[p] = []
            }
            segments.append(.free(anchor: freeAnchor, peers: peers))
            freeAnchor = []
        }
        for p in 0..<peerCount {
            freePeers[p] += orphanRuns[p][String?.none] ?? []
        }
        for anchor in anchorBlocks {
            let kinLists = (0..<peerCount).map { kinByAnchor[$0][anchor] ?? [] }
            if kinLists.allSatisfy(\.isEmpty) {
                freeAnchor.append(anchor)
            } else {
                flushFree(forcing: kinLists.map { !$0.isEmpty })
                segments.append(.aligned(AlignedRow(
                    anchorBlockID: anchor,
                    peerKin: kinLists,
                    peerMoved: (0..<peerCount).map { movedAnchors[$0].contains(anchor) })))
            }
            for p in 0..<peerCount {
                freePeers[p] += orphanRuns[p][anchor] ?? []
            }
        }
        flushFree(forcing: Array(repeating: true, count: peerCount))
        return segments
    }

    /// The rail rule's anchor half (S4-12: rails only where lineage
    /// speaks): the anchor blocks some peer's kinship points at. A peer
    /// block rails iff its own kinship entry exists; both sides color by
    /// the ANCHOR kin's ID, so associated blocks literally share a color
    /// (the mockup page-3 rail grammar).
    static func railedAnchors(kinships: [[String: String]]) -> Set<String> {
        Set(kinships.flatMap(\.values))
    }
}
