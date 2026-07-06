import Foundation
import GRDB

// Tag traversals (AppSpec §7 tag/post_tag/block_tag): the hierarchical
// subtree by materialized path, and the "everything tagged X" union across
// the two application tables — post tags drive the main UI, block tags
// primarily serve the pool.
extension Queries {
    /// The live subtree rooted at `rootID` (root included), ordered by
    /// `path`. Empty when the root is missing or tombstoned. Matching is by
    /// path-prefix over the materialized `path` — the one deliberate
    /// denormalization, kept coherent by `renameTag`/`deleteTag`.
    public static func tagSubtree(_ db: Database, rootID: String) throws -> [Tag] {
        guard let root = try Tag.fetchOne(db, key: rootID), root.deletedAt == nil else { return [] }
        return try Tag.fetchAll(
            db,
            sql: """
                SELECT * FROM tag
                WHERE deleted_at IS NULL
                  AND (id = ? OR substr(path, 1, length(?) + 1) = ? || '/')
                ORDER BY path
                """,
            arguments: [rootID, root.path, root.path])
    }

    /// "Everything tagged X" — the two application tables, resolved
    /// together (AppSpec §7: the UNION query; acceptable, and rare outside
    /// the pool). Distinct live targets only; `includeSubtree` widens the
    /// match to the tag's whole live subtree.
    public struct TaggedItems: Equatable, Sendable {
        public let postIDs: [String]
        public let blockIDs: [String]
    }

    public static func everythingTagged(
        _ db: Database, tagID: String, includeSubtree: Bool = false
    ) throws -> TaggedItems {
        let tagCondition: String
        var arguments: [(any DatabaseValueConvertible)?]
        if includeSubtree {
            guard let root = try Tag.fetchOne(db, key: tagID), root.deletedAt == nil else {
                return TaggedItems(postIDs: [], blockIDs: [])
            }
            tagCondition = """
                app.tag_id IN (SELECT id FROM tag
                                WHERE deleted_at IS NULL
                                  AND (id = ? OR substr(path, 1, length(?) + 1) = ? || '/'))
                """
            arguments = [tagID, root.path, root.path]
        } else {
            tagCondition = "app.tag_id = ?"
            arguments = [tagID]
        }
        let postIDs = try String.fetchAll(
            db,
            sql: """
                SELECT DISTINCT c.id FROM post_tag app
                JOIN container c ON c.id = app.post_id AND c.deleted_at IS NULL
                WHERE app.deleted_at IS NULL AND \(tagCondition)
                ORDER BY c.id
                """,
            arguments: StatementArguments(arguments))
        let blockIDs = try String.fetchAll(
            db,
            sql: """
                SELECT DISTINCT b.id FROM block_tag app
                JOIN block b ON b.id = app.block_id AND b.deleted_at IS NULL
                WHERE app.deleted_at IS NULL AND \(tagCondition)
                ORDER BY b.id
                """,
            arguments: StatementArguments(arguments))
        return TaggedItems(postIDs: postIDs, blockIDs: blockIDs)
    }
}
