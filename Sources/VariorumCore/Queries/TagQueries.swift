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
        // 13i-d U5 (F-U5-2): the subtree is the ROOT's wing's (R-13ia-1).
        return try Tag.fetchAll(
            db,
            sql: """
                SELECT * FROM tag
                WHERE deleted_at IS NULL
                  AND (id = ? OR (wing_id = ? AND substr(path, 1, length(?) + 1) = ? || '/'))
                ORDER BY path
                """,
            arguments: [rootID, root.wingId, root.path, root.path])
    }

    /// The whole live taxonomy, ordered by `path` (parents sort before
    /// children by construction of the materialized path). The tag tree is
    /// author-scale metadata — cost ∝ tag count, never the corpus.
    /// Phase 10 (additive): the tag-management face lists through this.
    ///
    /// `wingID` (13i-d U5, additive): one WING's vocabulary (R-13ia-1 — tags
    /// are per-wing; `Queries.wingScope`, so Home also lists a dangling
    /// wing's). nil = every wing — byte-identical for every existing caller.
    public static func allTags(_ db: Database, wingID: String? = nil) throws -> [Tag] {
        guard let wingID else {
            return try Tag.fetchAll(
                db,
                sql: "SELECT * FROM tag WHERE deleted_at IS NULL ORDER BY path")
        }
        let scope = wingScope(column: "wing_id", wingID: wingID)
        return try Tag.fetchAll(
            db,
            sql: "SELECT * FROM tag WHERE deleted_at IS NULL AND \(scope.sql) ORDER BY path, id",
            arguments: StatementArguments(scope.arguments))
    }

    /// **The paths of NAMED tags only** (17o batch d, ledger row 18): the
    /// bounded twin of `allTags`, for chrome that must name the handful of
    /// tags currently on screen. `allTags` is fine for a one-shot read at
    /// navigation rate, and wrong inside a HELD observation — which re-runs
    /// on every `container` write, so its fetch must be viewport-shaped
    /// (`AppDatabase.observe`'s own rule). Missing and tombstoned ids are
    /// simply absent from the result, which is how the chrome's per-kind
    /// fallback already reads a name it cannot resolve.
    public static func tagPaths(_ db: Database, ids: [String]) throws -> [String: String] {
        guard !ids.isEmpty else { return [:] }
        let places = databaseQuestionMarks(count: ids.count)
        let rows = try Row.fetchAll(
            db,
            sql: "SELECT id, path FROM tag WHERE deleted_at IS NULL AND id IN (\(places))",
            arguments: StatementArguments(ids))
        return Dictionary(
            rows.map { ($0["id"] as String, $0["path"] as String) },
            uniquingKeysWith: { first, _ in first })
    }

    /// "Everything tagged X" — the two application tables, resolved
    /// together (AppSpec §7: the UNION query; acceptable, and rare outside
    /// the pool). Distinct live targets only; `includeSubtree` widens the
    /// match to the tag's whole live subtree.
    public struct TaggedItems: Equatable, Sendable {
        public let postIDs: [String]
        public let blockIDs: [String]
    }

    /// The folder view's listing (Phase 10, additive): posts tagged at or
    /// under a tag, with display metadata, most recently touched first (a
    /// presentation ordering; the membership semantics are
    /// `everythingTagged`'s). **Archived posts are INCLUDED** — the Phase 4
    /// ratification keeps archived containers out of *ambient* view while
    /// tag lookups still find them; the folder view is a tag lookup.
    /// Tombstoned rows never appear.
    /// `limit` (review round 1): a HELD observation over this listing must
    /// bound its standing fetch — the folder listing is corpus-shaped (one
    /// broad tag approaches the library) and re-fetches at container-write
    /// rate; the `observeLibrary` discipline applies. One-shot callers omit.
    public static func taggedPostItems(
        _ db: Database, tagID: String, includeSubtree: Bool = true, limit: Int? = nil
    ) throws -> [TimelineItem] {
        let tagCondition: String
        var arguments: [(any DatabaseValueConvertible)?]
        if includeSubtree {
            guard let root = try Tag.fetchOne(db, key: tagID), root.deletedAt == nil else {
                return []
            }
            // 13i-d U5 (F-U5-2): the root's wing's subtree only.
            tagCondition = """
                app.tag_id IN (SELECT id FROM tag
                                WHERE deleted_at IS NULL
                                  AND (id = ? OR (wing_id = ?
                                       AND substr(path, 1, length(?) + 1) = ? || '/')))
                """
            arguments = [tagID, root.wingId, root.path, root.path]
        } else {
            tagCondition = "app.tag_id = ?"
            arguments = [tagID]
        }
        // 13i-c U2 — HIDE-OWNED's tag-listing scope (the sitting record §6):
        // when the GLOBAL default hides, a tag listing composes the one
        // exclusion fragment. (The Library is exempt — R32; it never reads
        // this.)
        let hide = try Queries.hideOwnedDefault(db)
            ? " AND " + Queries.ownedElsewhereExclusion(alias: "c") : ""
        var sql = """
            SELECT DISTINCT c.id AS post_id, c.title AS title,
                   c.entry_date AS entry_date, c.created_at AS created_at,
                   COALESCE(c.last_touched_at, c.created_at) AS stamp
            FROM post_tag app
            JOIN container c ON c.id = app.post_id AND c.deleted_at IS NULL
            WHERE app.deleted_at IS NULL AND \(tagCondition)\(hide)
            ORDER BY stamp DESC, c.id DESC
            """
        if let limit {
            sql += " LIMIT ?"
            arguments.append(limit)
        }
        return try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            .map { row in
                TimelineItem(
                    postID: row["post_id"], title: row["title"],
                    entryDate: row["entry_date"], createdAt: row["created_at"],
                    stamp: row["stamp"])
            }
    }

    /// The live tags applied to one post, by path — the per-post tag
    /// editor's listing (Phase 10, additive). Cost ∝ the post's own tags.
    public static func postTags(_ db: Database, postID: String) throws -> [Tag] {
        try Tag.fetchAll(
            db,
            sql: """
                SELECT t.* FROM tag t
                JOIN post_tag pt ON pt.tag_id = t.id AND pt.deleted_at IS NULL
                WHERE pt.post_id = ? AND t.deleted_at IS NULL
                ORDER BY t.path
                """,
            arguments: [postID])
    }

    /// One block's live applied tags (Phase 11, A8 — `postTags`' block
    /// twin; block tags primarily serve the pool, AppSpec §7).
    public static func blockTags(_ db: Database, blockID: String) throws -> [Tag] {
        try Tag.fetchAll(
            db,
            sql: """
                SELECT t.* FROM tag t
                JOIN block_tag bt ON bt.tag_id = t.id AND bt.deleted_at IS NULL
                WHERE bt.block_id = ? AND t.deleted_at IS NULL
                ORDER BY t.path
                """,
            arguments: [blockID])
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
            // 13i-d U5 (F-U5-2): the root's wing's subtree only.
            tagCondition = """
                app.tag_id IN (SELECT id FROM tag
                                WHERE deleted_at IS NULL
                                  AND (id = ? OR (wing_id = ?
                                       AND substr(path, 1, length(?) + 1) = ? || '/')))
                """
            arguments = [tagID, root.wingId, root.path, root.path]
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

    /// Whether a tag is LIVE in a wing (13i-b, the morning sitting's spawn
    /// ruling): the spawn door derives an auto-tag only from a rule's sole
    /// tag, and a dead or foreign-wing reference must never become an
    /// outflow (U1's `applyAutoTag` would no-op it silently forever).
    public static func tagIsLive(_ db: Database, id: String, wingID: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS(SELECT 1 FROM tag
                  WHERE id = ? AND wing_id = ? AND deleted_at IS NULL)
                """,
            arguments: [id, wingID]) ?? false
    }
}
