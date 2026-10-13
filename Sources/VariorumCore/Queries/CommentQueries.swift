import Foundation
import GRDB

// Block comments, read side (Phase 13, Step A1). Display order is
// `(created_at, id)` — comments have no position column by design.
extension Queries {
    /// The block's live comments, oldest first.
    public static func blockComments(_ db: Database, blockID: String) throws -> [BlockComment] {
        try BlockComment
            .filter(Column("block_id") == blockID && Column("deleted_at") == nil)
            .order(Column("created_at"), Column("id"))
            .fetchAll(db)
    }

    /// The block's DELETED comments — the recovery surface behind
    /// `restoreBlockComment` ("deleted comments must be visible somewhere
    /// and resurrectable"). Newest deletion first: the accident you want to
    /// undo is the most recent one.
    ///
    /// **The purge FENCE (VX-179 — "Delete forever…", R-VX179-3):** a
    /// comment named by a purge intent leaves this listing the moment the
    /// intent is written, on every device, long before the janitor takes
    /// the bytes. It is the standing STAMP-AWARE arm, copied from the Trash's
    /// (13j ladder B, B1): a LIVE intent fences, and a completed one fences
    /// only the tombstone it actually covered (completed at-or-after the
    /// row's own `deleted_at` — purged stays purged). A VOIDED intent from
    /// before a restore-then-re-delete never hides the fresh tombstone: an
    /// any-state fence would put her re-deleted comment in a limbo no door
    /// reaches.
    public static func deletedBlockComments(_ db: Database, blockID: String) throws -> [BlockComment] {
        try BlockComment.fetchAll(
            db,
            sql: """
                SELECT * FROM block_comment
                WHERE block_id = ? AND deleted_at IS NOT NULL
                  AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                    WHERE pi.table_name = 'block_comment' AND pi.row_id = block_comment.id
                      AND (pi.deleted_at IS NULL OR pi.deleted_at >= block_comment.deleted_at))
                ORDER BY deleted_at DESC, id
                """,
            arguments: [blockID])
    }

    /// The container's live comments per block, display order — the C1
    /// margin/inline surfaces' feed (one indexed pass over the container's
    /// placements; cost ∝ the post's own comments, P1). Blocks with no
    /// comments are absent.
    public static func containerComments(
        _ db: Database, containerID: String
    ) throws -> [String: [BlockComment]] {
        let rows = try BlockComment.fetchAll(
            db,
            sql: """
                SELECT bc.*
                FROM block_comment bc
                JOIN container_block cb
                  ON cb.block_id = bc.block_id AND cb.deleted_at IS NULL
                WHERE cb.container_id = ? AND bc.deleted_at IS NULL
                ORDER BY bc.block_id, bc.created_at, bc.id
                """,
            arguments: [containerID])
        return Dictionary(grouping: rows, by: \.blockId)
    }

    /// The container's callout frames per block (Phase 13 C1 — the R16/R27
    /// rendering feed): live blocks' decoded presentations; plain blocks
    /// and malformed JSON are absent (fail-open, the BlockPresentation
    /// doctrine). Cost ∝ the post (one placement join).
    public static func blockPresentations(
        _ db: Database, containerID: String
    ) throws -> [String: BlockPresentation] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT b.id AS block_id, b.presentation AS presentation
                FROM block b
                JOIN container_block cb
                  ON cb.block_id = b.id AND cb.deleted_at IS NULL
                WHERE cb.container_id = ? AND b.deleted_at IS NULL
                  AND b.presentation IS NOT NULL
                """,
            arguments: [containerID])
        var result: [String: BlockPresentation] = [:]
        for row in rows {
            if let decoded = BlockPresentation.decode(row["presentation"]) {
                result[row["block_id"] as String] = decoded
            }
        }
        return result
    }

    /// Live-comment counts per block for one container — the editor
    /// surface's margin/badge feed (one indexed pass over the container's
    /// placements; cost ∝ the post, P1). Blocks with no comments are absent.
    public static func commentCounts(_ db: Database, containerID: String) throws -> [String: Int] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT bc.block_id AS block_id, COUNT(*) AS n
                FROM block_comment bc
                JOIN container_block cb
                  ON cb.block_id = bc.block_id AND cb.deleted_at IS NULL
                WHERE cb.container_id = ? AND bc.deleted_at IS NULL
                GROUP BY bc.block_id
                """,
            arguments: [containerID])
        return Dictionary(uniqueKeysWithValues: rows.map { ($0["block_id"] as String, $0["n"] as Int) })
    }
}
