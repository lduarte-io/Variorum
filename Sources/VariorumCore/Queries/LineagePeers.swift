import Foundation
import GRDB

// VX-827 U1 (VX-817's source; the run record `notes/plans/fixes/vx-827-lineage.md`
// U1 RECORD) — a NOTE's lineage peers: the other notes its blocks are joined to
// by one live edge. The block-level tree (`lineageTree`, LineageTree.swift) is
// its sibling; this one is note-level and one hop.
extension Queries {
    /// **One block pair joining a note to a peer** — a single live edge, read
    /// from the SUBJECT note's side.
    public struct LineageLink: Equatable, Sendable {
        /// How the peer's block stands to the subject's block.
        public enum Relation: String, Equatable, Sendable {
            /// The subject's block is derived from the peer's block
            /// (`derived_from`, the subject block the edge's source): the peer
            /// holds an ORIGINAL of the subject's text.
            case derivedFrom = "derived_from"
            /// The peer's block is derived from the subject's block (the
            /// subject block the edge's target): the peer holds a COPY.
            case derivedInto = "derived_into"
            /// A `version_of` edge — undirected, stored canonically.
            case versionOf = "version_of"
        }

        /// The subject note's block (placed there, live).
        public let blockID: String
        /// The peer note's block (placed there, live).
        public let peerBlockID: String
        public let relation: Relation
        /// The edge's `origin_op` — 'divide' | 'merge' | 'extract' |
        /// 'pool_copy' | 'manual' | nil.
        public let originOp: String?
        public let edgeID: String
        /// When the edge was minted (the canonical ISO-8601 stamp).
        public let at: String

        public init(
            blockID: String, peerBlockID: String, relation: Relation, originOp: String?,
            edgeID: String, at: String
        ) {
            self.blockID = blockID
            self.peerBlockID = peerBlockID
            self.relation = relation
            self.originOp = originOp
            self.edgeID = edgeID
            self.at = at
        }
    }

    /// **One peer note** and every block pair joining it to the subject.
    public struct LineagePeer: Equatable, Sendable {
        public let noteID: String
        /// The peer's own wing (`''` = Home) — a peer may stand in another
        /// wing (Copy to Wing makes exactly that).
        public let wingID: String
        /// The peer's domain archive stamp — an archived note is live and
        /// stays a peer; the caller decides what it shows.
        public let archivedAt: String?
        /// The pairs, in the SUBJECT note's order (its placements' order,
        /// then the peer block id, then the relation).
        public let links: [LineageLink]

        public init(noteID: String, wingID: String, archivedAt: String?, links: [LineageLink]) {
            self.noteID = noteID
            self.wingID = wingID
            self.archivedAt = archivedAt
            self.links = links
        }

        /// The peer holds an original of some of the subject's text.
        public var holdsAnOriginal: Bool { links.contains { $0.relation == .derivedFrom } }
        /// The peer holds a copy of some of the subject's text.
        public var holdsACopy: Bool { links.contains { $0.relation == .derivedInto } }
        /// A `version_of` edge joins the two notes.
        public var isAVersion: Bool { links.contains { $0.relation == .versionOf } }
    }

    /// **A note's lineage peers** (VX-827 U1 — VX-817's "which notes have
    /// copies elsewhere?"): every OTHER live note one of whose live, PLACED
    /// blocks is joined to one of this note's live, placed blocks by ONE live
    /// edge — `derived_from` in either direction, or `version_of`. Peers in
    /// note-id order, each with its block pairs.
    ///
    /// The rule, exactly:
    /// · ONE HOP at the block level: a peer is joined by a single edge, never
    ///   through an intermediate block (a released original between two notes'
    ///   blocks joins neither — transitive chains are `lineageTree`'s);
    /// · both ends LIVE and PLACED: a released original, an archived
    ///   (set-aside) block, a dead block and a dead note are absent — so is a
    ///   tombstoned edge, whatever killed it;
    /// · the peer is a NOTE: a pool (the Snippets) is not a peer, and neither
    ///   is a saved version — a container born archived (`archived_at =
    ///   created_at`, AppSpec §9's version classifier — Note ▸ Versions is its
    ///   one home); a domain-archived note is a peer and says so
    ///   (`archivedAt`);
    /// · the subject's own blocks never peer it with itself.
    ///
    /// It reads every row it names regardless of who may see it: reach is the
    /// CALLER's business (the MCP door applies its both-ends-readable fence on
    /// top; this read knows nothing about grants).
    ///
    /// **Cost ∝ this note's placed blocks and their direct edges, never the
    /// corpus (P1).** `mine` is the note's placements (`idx_cblock_order`),
    /// MATERIALIZED and every join driven from it by `CROSS JOIN` — the VX-654
    /// lesson (`originalsStrandedBy`): left to itself SQLite may flatten a
    /// small set into a scan of a store table. Each edge arm seeks
    /// `idx_edge_source` / `idx_edge_target`, the far block's live placement
    /// `uq_cblock_ownership`, the far block and the peer note their primary
    /// keys. Pinned by `LineagePeersTests` (exact rows over every structural
    /// shape; the library-growth, note-growth and plan pins).
    public static func lineagePeers(_ db: Database, noteID: String) throws -> [LineagePeer] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                WITH mine(block_id, position, placement_id) AS MATERIALIZED (
                  SELECT cb.block_id, cb.position, cb.id FROM container_block cb
                  CROSS JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                  WHERE cb.container_id = :note AND cb.deleted_at IS NULL
                ),
                pairs(block_id, far_id, relation, edge_id, origin_op, at, position, placement_id) AS (
                  SELECT m.block_id, e.target_block_id,
                         CASE e.type WHEN 'version_of' THEN 'version_of' ELSE 'derived_from' END,
                         e.id, e.origin_op, e.created_at, m.position, m.placement_id
                  FROM mine m CROSS JOIN edge e ON e.source_block_id = m.block_id
                  WHERE e.deleted_at IS NULL
                  UNION ALL
                  SELECT m.block_id, e.source_block_id,
                         CASE e.type WHEN 'version_of' THEN 'version_of' ELSE 'derived_into' END,
                         e.id, e.origin_op, e.created_at, m.position, m.placement_id
                  FROM mine m CROSS JOIN edge e ON e.target_block_id = m.block_id
                  WHERE e.deleted_at IS NULL
                )
                SELECT p.block_id, p.far_id, p.relation, p.edge_id, p.origin_op, p.at,
                       peer.id AS peer_id, peer.wing_id AS peer_wing, peer.archived_at AS peer_archived
                FROM pairs p
                CROSS JOIN block far ON far.id = p.far_id AND far.deleted_at IS NULL
                CROSS JOIN container_block theirs
                  ON theirs.block_id = far.id AND theirs.deleted_at IS NULL
                CROSS JOIN container peer
                  ON peer.id = theirs.container_id AND peer.deleted_at IS NULL AND peer.kind = 'post'
                WHERE peer.id <> :note
                  AND NOT (peer.archived_at IS NOT NULL AND peer.archived_at = peer.created_at)
                ORDER BY peer.id, p.position, p.placement_id, p.far_id, p.relation
                """,
            arguments: ["note": noteID])
        var peers: [LineagePeer] = []
        var links: [LineageLink] = []
        var current: (id: String, wing: String, archived: String?)?
        func flush() {
            if let current {
                peers.append(LineagePeer(
                    noteID: current.id, wingID: current.wing, archivedAt: current.archived, links: links))
            }
            links = []
        }
        for row in rows {
            let peerID: String = row["peer_id"]
            if current?.id != peerID {
                flush()
                current = (peerID, row["peer_wing"], row["peer_archived"])
            }
            links.append(LineageLink(
                blockID: row["block_id"], peerBlockID: row["far_id"],
                relation: LineageLink.Relation(rawValue: row["relation"]) ?? .versionOf,
                originOp: row["origin_op"], edgeID: row["edge_id"], at: row["at"]))
        }
        flush()
        return peers
    }
}
