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

    /// The live pools, oldest first (Phase 10, additive — the shell's pool
    /// section finds THE inspiration pool through this; CoreDescription
    /// speaks of one pool, the schema deliberately allows several).
    public static func pools(_ db: Database) throws -> [Container] {
        try Container.fetchAll(
            db,
            sql: """
                SELECT * FROM container
                WHERE kind = 'pool' AND deleted_at IS NULL
                ORDER BY created_at, id
                """)
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

        public init(blockID: String, deletedAt: String, text: String?) {
            self.blockID = blockID
            self.deletedAt = deletedAt
            self.text = text
        }
    }

    /// The per-post tray: blocks *individually deleted* from this post —
    /// tombstoned blocks whose `last_container_id` is the post and that
    /// were NOT taken down by a container cascade. Cascade victims are
    /// identified by a same-stamp placement under a same-stamp container
    /// and belong to `restoreContainer`, not the tray (resolves the
    /// KnownIssues "tray semantics" entry — see the Phase 4 closeout).
    /// `restoreBlock` on a tray item lands it back in this post.
    ///
    /// `limit` (13j ladder A round 1, finding A6 — the `preservedOriginals`
    /// shape, retrofitted): a HELD observation over this listing is bounded
    /// in SQL, not in memory — the caller passes `window + 1` so a
    /// truncation marker never false-positives. Defaulting nil keeps the
    /// one-shot callers unchanged.
    ///
    /// `now` (13j J1) is REQUIRED — the 30-day Trash window applies to the
    /// tray too, because "it has left every surface" is what the clock
    /// promises and a tray that kept listing an unrecoverable block would be
    /// the one surface making the promise false.
    public static func trayBlocks(
        _ db: Database, postID: String, now: Date, limit: Int? = nil
    ) throws -> [TrayItem] {
        var sql = """
            SELECT b.id AS block_id, b.deleted_at AS deleted_at,
                   dv.working_text AS text
            FROM block b
            LEFT JOIN variant dv
              ON dv.id = b.default_variant_id
             AND (dv.deleted_at IS NULL OR dv.deleted_at = b.deleted_at)
            WHERE b.last_container_id = :post AND b.deleted_at IS NOT NULL
              AND b.deleted_at >= :cutoff
              AND NOT EXISTS (
                SELECT 1 FROM container_block cb
                JOIN container cc ON cc.id = cb.container_id
                WHERE cb.block_id = b.id
                  AND cb.deleted_at = b.deleted_at
                  AND cc.deleted_at = b.deleted_at)
              AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                WHERE pi.table_name = 'block' AND pi.row_id = b.id)
            ORDER BY b.deleted_at DESC, b.id
            """
        var arguments: StatementArguments = [
            "post": postID, "cutoff": TrashWindow.cutoffStamp(now: now),
        ]
        if let limit {
            sql += " LIMIT :limit"
            arguments += ["limit": limit]
        }
        return try Row.fetchAll(db, sql: sql, arguments: arguments)
            .map { TrayItem(blockID: $0["block_id"], deletedAt: $0["deleted_at"], text: $0["text"]) }
    }

    /// **A note's PRESERVED ORIGINAL** (13j J2, sitting round 2): a block
    /// that is LIVE, has no live placement, and whose `last_container_id`
    /// names this note — i.e. the divide-W's preserved-whole A and the
    /// merge's released B/C, seen from the note they were released FROM.
    ///
    /// This is the per-note half of what the global "Unplaced blocks"
    /// listing used to show, and her round-2 ruling removed that room in
    /// favour of this: the release stamps `last_container_id` exactly so a
    /// released block still knows its home (Phase 3's finding), which is
    /// what makes the scoped read possible at all.
    ///
    /// It deliberately does NOT walk lineage edges. `unplacedOrigins` reads
    /// the same population FROM a successor (the block → its origin map, the
    /// J3 door's source); this reads it from the NOTE, so an original whose
    /// successors were all deleted still lists — the one case the global
    /// listing served uniquely.
    public struct PreservedOriginal: Equatable, Sendable {
        public let blockID: String
        /// Preview text: the default variant's live buffer.
        public let text: String?
        /// When the block was RELEASED — the tombstone on the placement row
        /// this note used to hold (`deleteBlock`'s own stamp shape). Not
        /// `block.updated_at`, which moves whenever anything touches the
        /// block; the release is the event the row is about.
        public let releasedAt: String?
        /// **Where Put back lands it**: immediately after this block, the
        /// LAST live successor of the original still placed in this note —
        /// nil when none survives, and the note's end is then the landing.
        ///
        /// Read here rather than composed by a caller so the SQL does it
        /// once, in the same pass; the face still re-reads at act time,
        /// because a listing is a projection and a landing is an argument.
        public let landAfterBlockID: String?
    }

    /// The per-note preserved-originals listing (newest release first).
    /// `limit` follows the windowed-observation discipline (the
    /// `unplacedBlocks` / `observeLibrary` shape): a held observation over a
    /// corpus-history-shaped set is always bounded, and a caller passes
    /// `window + 1` so a truncation marker never false-positives.
    public static func preservedOriginals(
        _ db: Database, postID: String, limit: Int? = nil
    ) throws -> [PreservedOriginal] {
        var sql = """
            SELECT b.id AS block_id,
                   dv.working_text AS text,
                   (SELECT MAX(rel.deleted_at) FROM container_block rel
                     WHERE rel.block_id = b.id AND rel.container_id = :post
                       AND rel.deleted_at IS NOT NULL) AS released_at,
                   (SELECT cb.block_id FROM edge e
                     JOIN container_block cb
                       ON cb.block_id = e.source_block_id
                      AND cb.container_id = :post AND cb.deleted_at IS NULL
                     WHERE e.target_block_id = b.id
                       AND e.type = 'derived_from' AND e.deleted_at IS NULL
                     ORDER BY cb.position DESC, cb.block_id DESC
                     LIMIT 1) AS land_after
            FROM block b
            LEFT JOIN variant dv
              ON dv.id = b.default_variant_id AND dv.deleted_at IS NULL
            WHERE b.last_container_id = :post AND b.deleted_at IS NULL
              AND b.archived_at IS NULL
              AND NOT EXISTS (
                SELECT 1 FROM container_block placed
                WHERE placed.block_id = b.id AND placed.deleted_at IS NULL)
            ORDER BY released_at DESC, b.id
            """
        var arguments: StatementArguments = ["post": postID]
        if let limit {
            sql += " LIMIT :limit"
            arguments += ["limit": limit]
        }
        return try Row.fetchAll(db, sql: sql, arguments: arguments)
            .map {
                PreservedOriginal(
                    blockID: $0["block_id"], text: $0["text"],
                    releasedAt: $0["released_at"], landAfterBlockID: $0["land_after"])
            }
    }

    /// **What the tray door wears** (13j J2): how many blocks each of the
    /// tray's two sections holds, for one note.
    ///
    /// Its own query rather than `trayBlocks().count + preservedOriginals().count`
    /// for ONE load-bearing reason: it touches `block`, `container_block`
    /// and `container` and **never `variant`**. The door's count is a HELD
    /// observation on an open note, and GRDB tracks the tables a query
    /// reads — so joining the preview text in would re-run this at autosave
    /// rate on the one table autosave writes (P1). The listings pay the
    /// variant join because they are opened deliberately; the badge does
    /// not, because it is always on.
    public struct TrayCounts: Equatable, Sendable {
        /// Blocks individually deleted from this note (`trayBlocks`'
        /// population) — the ONLY number the door shows (13j sitting round
        /// 5: preserved originals must not inflate an urgent-looking count).
        public let deleted: Int
        /// Live-but-unplaced originals released from this note. Archived
        /// blocks are NOT in this number (13j, her round-7 ruling gave them
        /// their own state and their own count below) — an archived block is
        /// unplaced too, and counting it as a preserved original would call
        /// a deliberate set-aside a leftover.
        public let preservedOriginals: Int
        /// Blocks ARCHIVED out of this note (13j round 7). They wear no
        /// clock: archive is kept-forever, which is exactly the distinction
        /// the tray's first section now has to teach.
        public let archived: Int

        public init(deleted: Int, preservedOriginals: Int, archived: Int = 0) {
            self.deleted = deleted
            self.preservedOriginals = preservedOriginals
            self.archived = archived
        }

        /// Nothing to recover at all — the tray panel's empty state.
        public var isEmpty: Bool {
            deleted == 0 && preservedOriginals == 0 && archived == 0
        }
    }

    public static func trayCounts(_ db: Database, postID: String, now: Date) throws -> TrayCounts {
        let row = try Row.fetchOne(
            db,
            sql: """
                SELECT
                  (SELECT COUNT(*) FROM block b
                    WHERE b.last_container_id = :post AND b.deleted_at IS NOT NULL
                      AND b.deleted_at >= :cutoff
                      AND NOT EXISTS (
                        SELECT 1 FROM container_block cb
                        JOIN container cc ON cc.id = cb.container_id
                        WHERE cb.block_id = b.id
                          AND cb.deleted_at = b.deleted_at
                          AND cc.deleted_at = b.deleted_at)
                      AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                        WHERE pi.table_name = 'block' AND pi.row_id = b.id)) AS deleted_count,
                  (SELECT COUNT(*) FROM block b
                    WHERE b.last_container_id = :post AND b.deleted_at IS NULL
                      AND b.archived_at IS NULL
                      AND NOT EXISTS (
                        SELECT 1 FROM container_block placed
                        WHERE placed.block_id = b.id AND placed.deleted_at IS NULL))
                    AS original_count,
                  (SELECT COUNT(*) FROM block b
                    WHERE b.last_container_id = :post AND b.deleted_at IS NULL
                      AND b.archived_at IS NOT NULL) AS archived_count
                """,
            arguments: ["post": postID, "cutoff": TrashWindow.cutoffStamp(now: now)])
        return TrayCounts(
            deleted: row?["deleted_count"] ?? 0,
            preservedOriginals: row?["original_count"] ?? 0,
            archived: row?["archived_count"] ?? 0)
    }

    /// One live-but-unplaced block (divide-W/merge lineage leftovers).
    ///
    /// **13j J6 — the room this fed is GONE.** Her round-2 ruling removed
    /// the global "Unplaced blocks" listing from the Library recovery
    /// surface ("what is that cursed table of lost hopes and dreams?"); the
    /// population now surfaces per-note (`preservedOriginals`, above) and
    /// from a successor (`unplacedOrigins`). The query SURVIVES deliberately
    /// — the sitting's words: it lives on as a debug query, not a room in
    /// the house — because the spec's own rationale for the view was a
    /// developer safety net, and a safety net with no window is still a net.
    public struct UnplacedBlock: Equatable, Sendable {
        public let blockID: String
        public let text: String?
    }

    /// The unplaced-blocks safety net (AppSpec §12): live blocks with no
    /// live placement. Deliberately unfiltered by archive — a safety net
    /// must not hide things. Cost ∝ the block count (an anti-join over the
    /// ownership index); a rare utility view, never a per-keystroke path.
    /// `limit` (Phase 11, review round 1, MINOR 3): the unplaced set is
    /// corpus-history-shaped by construction (every merge releases both
    /// sources; every divide-W releases A), so a HELD observation must be
    /// bounded like every corpus-shaped listing (the observeLibrary
    /// discipline); nil preserves the one-shot full fetch.
    public static func unplacedBlocks(
        _ db: Database, limit: Int? = nil
    ) throws -> [UnplacedBlock] {
        var sql = """
            SELECT b.id AS block_id, dv.working_text AS text
            FROM block b
            LEFT JOIN variant dv
              ON dv.id = b.default_variant_id AND dv.deleted_at IS NULL
            WHERE b.deleted_at IS NULL
              AND NOT EXISTS (
                SELECT 1 FROM container_block cb
                WHERE cb.block_id = b.id AND cb.deleted_at IS NULL)
            ORDER BY b.updated_at DESC, b.id
            """
        var arguments: [(any DatabaseValueConvertible)?] = []
        if let limit {
            sql += " LIMIT ?"
            arguments.append(limit)
        }
        return try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            .map { UnplacedBlock(blockID: $0["block_id"], text: $0["text"]) }
    }
}
