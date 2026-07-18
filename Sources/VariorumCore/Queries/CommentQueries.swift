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
    public static func deletedBlockComments(_ db: Database, blockID: String) throws -> [BlockComment] {
        try BlockComment
            .filter(Column("block_id") == blockID && Column("deleted_at") != nil)
            .order(Column("deleted_at").desc, Column("id"))
            .fetchAll(db)
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
