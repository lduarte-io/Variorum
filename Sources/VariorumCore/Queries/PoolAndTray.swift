import Foundation
import GRDB

// The pool listing, the per-post deleted-blocks tray, and the unplaced-blocks
// safety net (AppSpec §12; OverallModel §3 "a per-post 'deleted blocks' tray
// is the soft net").
extension Queries {
    /// One pool scrap: the rendered slot plus the block's live tag paths
    /// (block tags primarily serve the pool — AppSpec §7).
    public struct PoolItem: Equatable, Sendable {
        public let block: RenderedBlock
        public let tagPaths: [String]
    }

    /// The pool's contents in pointer order — exactly `renderPost` (a pool
    /// is a container; one traversal, never a bespoke subsystem) joined
    /// with each block's live tags.
    public static func poolListing(_ db: Database, poolID: String) throws -> [PoolItem] {
        let rendered = try renderPost(db, containerID: poolID)
        guard !rendered.isEmpty else { return [] }
        let tagRows = try Row.fetchAll(
            db,
            sql: """
                SELECT bt.block_id AS block_id, t.path AS path
                FROM container_block cb
                JOIN block_tag bt ON bt.block_id = cb.block_id AND bt.deleted_at IS NULL
                JOIN tag t ON t.id = bt.tag_id AND t.deleted_at IS NULL
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                ORDER BY bt.block_id, t.path
                """,
            arguments: [poolID])
        var paths: [String: [String]] = [:]
        for row in tagRows {
            paths[row["block_id"], default: []].append(row["path"])
        }
        return rendered.map { PoolItem(block: $0, tagPaths: paths[$0.blockID] ?? []) }
    }

    /// One entry of a post's deleted-blocks tray.
    public struct TrayItem: Equatable, Sendable {
        public let blockID: String
        /// The tombstone stamp (canonical ISO-8601 text), newest first.
        public let deletedAt: String
        /// Preview text: the default variant's buffer — read through its
        /// tombstone only when that tombstone is the block's own stamp (the
        /// cascade victim `restoreBlock` would revive). A default variant
        /// that died independently under a different stamp stays dead on
        /// restore, so it doesn't preview either (review finding).
        public let text: String?
    }

    /// The per-post tray: blocks *individually deleted* from this post —
    /// tombstoned blocks whose `last_container_id` is the post and that
    /// were NOT taken down by a container cascade. Cascade victims are
    /// identified by a same-stamp placement under a same-stamp container
    /// and belong to `restoreContainer`, not the tray (resolves the
    /// KnownIssues "tray semantics" entry — see the Phase 4 closeout).
    /// `restoreBlock` on a tray item lands it back in this post.
    public static func trayBlocks(_ db: Database, postID: String) throws -> [TrayItem] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT b.id AS block_id, b.deleted_at AS deleted_at,
                       dv.working_text AS text
                FROM block b
                LEFT JOIN variant dv
                  ON dv.id = b.default_variant_id
                 AND (dv.deleted_at IS NULL OR dv.deleted_at = b.deleted_at)
                WHERE b.last_container_id = ? AND b.deleted_at IS NOT NULL
                  AND NOT EXISTS (
                    SELECT 1 FROM container_block cb
                    JOIN container cc ON cc.id = cb.container_id
                    WHERE cb.block_id = b.id
                      AND cb.deleted_at = b.deleted_at
                      AND cc.deleted_at = b.deleted_at)
                ORDER BY b.deleted_at DESC, b.id
                """,
            arguments: [postID])
            .map { TrayItem(blockID: $0["block_id"], deletedAt: $0["deleted_at"], text: $0["text"]) }
    }

    /// One live-but-unplaced block (divide-W/merge lineage leftovers).
    public struct UnplacedBlock: Equatable, Sendable {
        public let blockID: String
        public let text: String?
    }

    /// The unplaced-blocks safety net (AppSpec §12): live blocks with no
    /// live placement. Deliberately unfiltered by archive — a safety net
    /// must not hide things. Cost ∝ the block count (an anti-join over the
    /// ownership index); a rare utility view, never a per-keystroke path.
    public static func unplacedBlocks(_ db: Database) throws -> [UnplacedBlock] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT b.id AS block_id, dv.working_text AS text
                FROM block b
                LEFT JOIN variant dv
                  ON dv.id = b.default_variant_id AND dv.deleted_at IS NULL
                WHERE b.deleted_at IS NULL
                  AND NOT EXISTS (
                    SELECT 1 FROM container_block cb
                    WHERE cb.block_id = b.id AND cb.deleted_at IS NULL)
                ORDER BY b.updated_at DESC, b.id
                """)
            .map { UnplacedBlock(blockID: $0["block_id"], text: $0["text"]) }
    }
}
