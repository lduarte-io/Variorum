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
        func flushFree() {
            guard !freeAnchor.isEmpty || freePeers.contains(where: { !$0.isEmpty })
            else { return }
            segments.append(.free(anchor: freeAnchor, peers: freePeers))
            freeAnchor = []
            freePeers = Array(repeating: [], count: peerCount)
        }
        for p in 0..<peerCount {
            freePeers[p] += orphanRuns[p][String?.none] ?? []
        }
        for anchor in anchorBlocks {
            let kinLists = (0..<peerCount).map { kinByAnchor[$0][anchor] ?? [] }
            if kinLists.allSatisfy(\.isEmpty) {
                freeAnchor.append(anchor)
            } else {
                flushFree()
                segments.append(.aligned(AlignedRow(
                    anchorBlockID: anchor,
                    peerKin: kinLists,
                    peerMoved: (0..<peerCount).map { movedAnchors[$0].contains(anchor) })))
            }
            for p in 0..<peerCount {
                freePeers[p] += orphanRuns[p][anchor] ?? []
            }
        }
        flushFree()
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
