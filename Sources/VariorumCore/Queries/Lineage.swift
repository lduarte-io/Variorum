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
