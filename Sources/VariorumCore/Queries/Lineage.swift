import Foundation
import GRDB

// Lineage traversals (OverallModel §1: the store is a directed graph; §2
// edge): recursive CTEs over `derived_from` — coarse `(from, to, type)`
// lineage, never word-level — plus `version_of` peers and the diff inputs.
// These feed the outline↔draft mapping, lineage views, and the diff view
// (AppSpec §12).
extension Queries {
    /// One block reached by a lineage walk. `depth` is the shortest edge
    /// distance from the origin (1 = direct parent/child).
    public struct LineageNode: Equatable, Sendable {
        public let blockID: String
        public let depth: Int
    }

    /// Everything the block was derived from, walking `derived_from` edges
    /// source→target (source is derived from target; AppSpec §7). Bounded by
    /// `maxDepth` — cycles are impossible through the operations layer, but
    /// the walk is bounded anyway (sync debris must never hang a view). Only
    /// live blocks are returned: edges may outlive an endpoint (the
    /// documented sweep exception), so the traversal follows live edges
    /// freely but dead endpoints are filtered from the projection.
    public static func ancestors(
        _ db: Database, of blockID: String, maxDepth: Int = 32
    ) throws -> [LineageNode] {
        try lineageWalk(db, from: blockID, follow: "source", reach: "target", maxDepth: maxDepth)
    }

    /// Everything derived from the block, walking `derived_from` edges
    /// target→source. Same bounds and liveness filtering as `ancestors`.
    public static func descendants(
        _ db: Database, of blockID: String, maxDepth: Int = 32
    ) throws -> [LineageNode] {
        try lineageWalk(db, from: blockID, follow: "target", reach: "source", maxDepth: maxDepth)
    }

    /// The outline→draft mapping (AppSpec §12): the live blocks derived from
    /// an outline block that are currently placed in the given container —
    /// the descendants walk, filtered by placement.
    public static func derivedBlocks(
        _ db: Database, fromOutlineBlock blockID: String, inContainer containerID: String,
        maxDepth: Int = 32
    ) throws -> [LineageNode] {
        let all = try descendants(db, of: blockID, maxDepth: maxDepth)
        guard !all.isEmpty else { return [] }
        let placed = try Set(String.fetchAll(
            db,
            sql: """
                SELECT block_id FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL
                """,
            arguments: [containerID]))
        return all.filter { placed.contains($0.blockID) }
    }

    /// **The released originals a post's blocks came from** (13f W11/W10b —
    /// her sitting question: *"it says … it stays whole on the original one,
    /// but how do I even see the original one?"*).
    ///
    /// For every live block placed in `containerID`, the blocks its OWN
    /// `derived_from` edges point at (direct edges only — the block's own
    /// origin, not its whole ancestry) that are live but have **no live
    /// placement**: exactly the divide-W preserved-whole A and the merge's
    /// released B/C, i.e. the `unplacedBlocks` safety-net population reached
    /// FROM the successor that replaced it. Blocks with no such origin are
    /// absent from the map, so a surface renders no door for them (P-2).
    ///
    /// Several origins are possible and normal — a merge releases BOTH
    /// sources, so A′ has two — and the ids come back sorted so the pick is
    /// deterministic on every device.
    ///
    /// Cost: one indexed pass over the post's placements (the `renderPost`
    /// class, and it rides the same projections), never the corpus.
    ///
    /// **13j J3 — the value grew from a bare id to `UnplacedOrigin`.** Her
    /// ruled door says *"See original from divide…"* / *"…from merge…"*, and a
    /// menu builder runs synchronously off a held projection: it cannot ask
    /// the store which act released the block, so the projection has to carry
    /// it. The edge already knows — `origin_op` since Phase 3 — and its
    /// `created_at` is the date the History face's lineage row names.
    public struct UnplacedOrigin: Equatable, Sendable, Identifiable {
        /// The released original's block id.
        public let blockID: String
        /// The `derived_from` edge's `origin_op` — 'divide' | 'merge' |
        /// 'extract' | 'pool_copy' | 'manual' | nil. What the door's words
        /// say happened.
        public let originOp: String?
        /// When the edge was minted, i.e. when the divide or merge happened
        /// (the canonical ISO-8601 stamp). Deliberately the EDGE's stamp
        /// rather than a placement tombstone: it is the same fact seen from
        /// ONE block, so the per-block read below needs no container.
        public let at: String

        public var id: String { blockID }

        public init(blockID: String, originOp: String?, at: String) {
            self.blockID = blockID
            self.originOp = originOp
            self.at = at
        }
    }

    public static func unplacedOrigins(
        _ db: Database, inContainer containerID: String
    ) throws -> [String: [UnplacedOrigin]] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT cb.block_id AS block_id, origin.id AS origin_id,
                       e.origin_op AS origin_op, e.created_at AS created_at
                FROM container_block cb
                JOIN edge e
                  ON e.source_block_id = cb.block_id
                 AND e.type = 'derived_from' AND e.deleted_at IS NULL
                JOIN block origin
                  ON origin.id = e.target_block_id AND origin.deleted_at IS NULL
                WHERE cb.container_id = :post AND cb.deleted_at IS NULL
                  AND NOT EXISTS (
                    SELECT 1 FROM container_block placed
                    WHERE placed.block_id = origin.id AND placed.deleted_at IS NULL)
                ORDER BY cb.block_id, origin.id
                """,
            arguments: ["post": containerID])
        var map: [String: [UnplacedOrigin]] = [:]
        for row in rows {
            let blockID: String = row["block_id"]
            map[blockID, default: []].append(
                UnplacedOrigin(
                    blockID: row["origin_id"], originOp: row["origin_op"],
                    at: row["created_at"]))
        }
        return map
    }

    /// The same population read from ONE block (13j J3 — the History face's
    /// lineage row, and the peek's own re-read at act time). The container
    /// scoping above exists so a whole post's menus can be built from one
    /// projection; this is the single-block door onto the identical fact, so
    /// a surface holding no post-wide projection (a history sheet, a peek)
    /// never has to fake one.
    public static func unplacedOrigins(
        _ db: Database, ofBlock blockID: String
    ) throws -> [UnplacedOrigin] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT origin.id AS origin_id, e.origin_op AS origin_op,
                       e.created_at AS created_at
                FROM edge e
                JOIN block origin
                  ON origin.id = e.target_block_id AND origin.deleted_at IS NULL
                WHERE e.source_block_id = :block
                  AND e.type = 'derived_from' AND e.deleted_at IS NULL
                  AND NOT EXISTS (
                    SELECT 1 FROM container_block placed
                    WHERE placed.block_id = origin.id AND placed.deleted_at IS NULL)
                ORDER BY origin.id
                """,
            arguments: ["block": blockID])
            .map {
                UnplacedOrigin(
                    blockID: $0["origin_id"], originOp: $0["origin_op"],
                    at: $0["created_at"])
            }
    }

    /// The block's `version_of` peers ("two versions of an article", usable
    /// across posts — I8: comparison is a view over edges). Undirected: the
    /// operations layer stores the pair canonically, and the read matches
    /// either side regardless. Live peers only.
    public static func versionPeers(_ db: Database, of blockID: String) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT DISTINCT b.id
                FROM edge e
                JOIN block b
                  ON b.id = CASE WHEN e.source_block_id = ?
                                 THEN e.target_block_id
                                 ELSE e.source_block_id END
                 AND b.deleted_at IS NULL
                WHERE e.type = 'version_of' AND e.deleted_at IS NULL
                  AND (e.source_block_id = ? OR e.target_block_id = ?)
                  AND b.id <> ?
                ORDER BY b.id
                """,
            arguments: [blockID, blockID, blockID, blockID])
    }

    /// The POST-level version peers (Phase 11, A2 — I8: posts are
    /// edges-only across versions, and edges are block-to-block, so the
    /// post relationship RIDES the blocks: two posts are version peers iff
    /// some live `version_of` edge joins a block placed in one to a block
    /// placed in the other). Live posts only; stable order.
    public static func versionPeerPosts(
        _ db: Database, of containerID: String
    ) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT DISTINCT c.id
                FROM edge e
                JOIN container_block mine
                  ON mine.block_id IN (e.source_block_id, e.target_block_id)
                 AND mine.container_id = :post AND mine.deleted_at IS NULL
                JOIN container_block theirs
                  ON theirs.block_id IN (e.source_block_id, e.target_block_id)
                 AND theirs.block_id <> mine.block_id
                 AND theirs.deleted_at IS NULL
                JOIN container c
                  ON c.id = theirs.container_id
                 AND c.deleted_at IS NULL AND c.kind = 'post'
                WHERE e.type = 'version_of' AND e.deleted_at IS NULL
                  AND c.id <> :post
                ORDER BY c.id
                """,
            arguments: ["post": containerID])
    }

    /// The diff view's inputs: the two buffers, verbatim. Whitespace
    /// normalization is a view-side toggle (Phase 11), not a query concern.
    /// `nil` when either variant is missing or tombstoned (tolerant read).
    public static func diffPair(
        _ db: Database, _ variantAID: String, _ variantBID: String
    ) throws -> (a: String, b: String)? {
        func liveText(_ id: String) throws -> String? {
            try String.fetchOne(
                db,
                sql: "SELECT working_text FROM variant WHERE id = ? AND deleted_at IS NULL",
                arguments: [id])
        }
        guard let a = try liveText(variantAID), let b = try liveText(variantBID) else { return nil }
        return (a, b)
    }

    /// The shared recursive walk. `follow`/`reach` name edge columns and are
    /// compile-time constants ("source"/"target"), never user data. UNION
    /// (not UNION ALL) dedupes revisits per depth; MIN(depth) collapses
    /// diamond paths to the shortest route.
    private static func lineageWalk(
        _ db: Database, from blockID: String, follow: String, reach: String, maxDepth: Int
    ) throws -> [LineageNode] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                WITH RECURSIVE walk(block_id, depth) AS (
                  SELECT e.\(reach)_block_id, 1
                  FROM edge e
                  WHERE e.\(follow)_block_id = :origin
                    AND e.type = 'derived_from' AND e.deleted_at IS NULL
                  UNION
                  SELECT e.\(reach)_block_id, w.depth + 1
                  FROM edge e
                  JOIN walk w ON e.\(follow)_block_id = w.block_id
                  WHERE e.type = 'derived_from' AND e.deleted_at IS NULL
                    AND w.depth < :maxDepth
                )
                SELECT w.block_id AS block_id, MIN(w.depth) AS depth
                FROM walk w
                JOIN block b ON b.id = w.block_id AND b.deleted_at IS NULL
                WHERE w.block_id <> :origin
                GROUP BY w.block_id
                ORDER BY depth, block_id
                """,
            arguments: ["origin": blockID, "maxDepth": maxDepth])
        return rows.map { LineageNode(blockID: $0["block_id"], depth: $0["depth"]) }
    }
}
