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
    /// PROVISIONAL (ladder round 3, MINOR-C — recorded in the plan file's
    /// Batch 4C section): in a MIXED multi-peer board, a peer with NO
    /// kinship at all has no row that bounds its run, so its whole post
    /// renders in the TRAILING free segment — below every aligned row. On a
    /// long anchor fully kin to another peer that column reads blank for
    /// many rows. The alternative (special-case an empty `kinships` peer to
    /// flush at the first bound, as the whole-board zero-lineage case does)
    /// is one arm away; the shipped behavior is pinned by
    /// `aPeerWithNoKinshipAtAllTrailsEveryAlignedRow`.
    ///
    /// **13c Batch 2E — this is what `relatedOnly` (C4) answers, and the
    /// placement above is deliberately UNCHANGED.** With the filter ON an
    /// unrelated peer contributes no blocks at all, so the question of where
    /// its run lands does not arise; the column is empty and SAYS so. With
    /// the filter OFF the shipped placement stands byte-for-byte — the
    /// setting is the remedy for "that column reads blank for many rows",
    /// not a second placement rule. Pinned:
    /// `relatedOnlyDropsTheKinLessPeerEntirelyAndMootsThePlacement`.
    /// (QUESTIONS #47 carries both halves for the author.)
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

    /// 13c Batch 2E (committed scope C4 — her request, verbatim: *"we should
    /// have a setting to only show related blocks - that would make the pane
    /// feel more usable"*): the **show-related-blocks-only** filter, as a
    /// PURE pre-pass over exactly the inputs `segments` takes. It drops
    /// every block lineage has nothing to say about, so what survives is
    /// only the material that RELATES across the columns — and, because
    /// every survivor is kin, `segments` then composes nothing but aligned
    /// rows.
    ///
    /// **"Related" is BLOCK-LEVEL LINEAGE — deliberately the SAME notion the
    /// rails and the alignment already use** (`Queries.blockKinship`: the
    /// transitive ancestors/descendants CTE, nearest kin wins, depth-bounded
    /// at 32). ONE kinship brain, and that is the load-bearing reason: a
    /// narrower rule (direct `derived_from` only) would hide blocks that
    /// visibly wear a rail, and a wider one would show blocks with no rail —
    /// either way the surface would contradict itself in the same glance.
    /// The post-level `version_of` LINK is NOT block relatedness: it says
    /// these two posts are versions, never WHICH blocks correspond, so a
    /// version-linked pair with no lineage filters down to nothing and the
    /// column says so (N29's honesty line, composed — never broken).
    ///
    /// Orthogonal to `followAnchorOrder` by construction: this decides WHICH
    /// blocks show, that toggle decides HOW they arrange. Filter on + follow
    /// off = each column's related blocks, flowing in its own order.
    ///
    /// **The invariant callers rely on:** a peer block survives iff its kin
    /// names an anchor block in THIS compare, and an anchor block survives
    /// iff some surviving peer block names it — so the anchor column is
    /// empty exactly when every peer column is. (Pinned:
    /// `relatedOnlyLeavesTheAnchorEmptyExactlyWhenEveryPeerIs`.)
    ///
    /// Cost is one pass over the same blocks `segments` already walks — the
    /// composition's own class, never the corpus's (P1).
    static func relatedOnly(
        anchorBlocks: [String], peerBlocks: [[String]], kinships: [[String: String]]
    ) -> (anchorBlocks: [String], peerBlocks: [[String]]) {
        let anchorSet = Set(anchorBlocks)
        var keptAnchors: Set<String> = []
        var keptPeers: [[String]] = []
        keptPeers.reserveCapacity(peerBlocks.count)
        for (index, blocks) in peerBlocks.enumerated() {
            let kinship = index < kinships.count ? kinships[index] : [:]
            var kept: [String] = []
            for block in blocks {
                // A kinship entry naming a block this compare's anchor column
                // does not show (a gap slot, a stale map mid-observation)
                // relates to nothing HERE — drop it rather than keep a cell
                // with no partner.
                guard let anchor = kinship[block], anchorSet.contains(anchor) else { continue }
                kept.append(block)
                keptAnchors.insert(anchor)
            }
            keptPeers.append(kept)
        }
        return (anchorBlocks.filter(keptAnchors.contains), keptPeers)
    }

    /// **"Related blocks only" for a WIRE LANDING** (VX-298, VX-336 U6a — the
    /// run record's D-298-4, F-9 (a), PROVISIONAL P-VX298-1). Her answers: (2)
    /// *"related blocks only off when they have no history - that's fine"*; (4)
    /// the board shows exactly what the AI named. ON only when EVERY named peer
    /// shares lineage with the anchor — its kinship (`Queries.blockKinship`, the
    /// same map the rails and `relatedOnly` read) is non-empty — else OFF, so no
    /// column the AI named opens filtered empty. A landing always names a peer,
    /// so an empty list is no landing (OFF). Pure: one pass over the peers' maps.
    static func landingShowsRelatedOnly(peerKinships: [[String: String]]) -> Bool {
        !peerKinships.isEmpty && peerKinships.allSatisfy { !$0.isEmpty }
    }
}
