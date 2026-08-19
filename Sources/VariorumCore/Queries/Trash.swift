import Foundation
import GRDB

// The TRASH (Phase 13j, J1 — her ruling: everything deleted rides ONE
// uniform 30-day story, sortable/filterable by kind so per-row Delete Now is
// a real option) and the derived state her round-8b ruling asked for: a
// preserved original is permanent while any descendant lives, and MOVES onto
// the family's clock the moment the last one is deleted.
extension Queries {
    /// One row of the Trash: something deleted (or, for a stranded original,
    /// something that will go when its family does).
    public struct TrashItem: Equatable, Sendable, Identifiable {
        public enum Kind: String, Equatable, Sendable, CaseIterable {
            case note, book, block, take
            /// A live-but-unplaced original whose whole descendant family is
            /// in the Trash — her round-8b ruling: it rides the family's
            /// clock rather than promising a permanence it will not keep.
            case preservedOriginal
        }

        public let kind: Kind
        /// The row's own id — container / reading / block / variant.
        public let id: String
        /// The tombstone that starts the clock. For `preservedOriginal` it is
        /// the family's: the latest deletion among its descendants.
        public let deletedAt: String
        /// Notes and books show their name; blocks and takes show text.
        public let title: String?
        public let text: String?
        /// Context for a block/take row: the note it came from.
        public let noteID: String?
        public let noteTitle: String?
        /// True when that note is itself in the Trash (a block deleted first,
        /// its note deleted later — different stamps, so both are listed).
        public let noteIsDeleted: Bool
        /// A take row's block, for the doors that need it.
        public let blockID: String?

        public init(
            kind: Kind, id: String, deletedAt: String, title: String? = nil,
            text: String? = nil, noteID: String? = nil, noteTitle: String? = nil,
            noteIsDeleted: Bool = false, blockID: String? = nil
        ) {
            self.kind = kind
            self.id = id
            self.deletedAt = deletedAt
            self.title = title
            self.text = text
            self.noteID = noteID
            self.noteTitle = noteTitle
            self.noteIsDeleted = noteIsDeleted
            self.blockID = blockID
        }
    }

    /// **The Trash, one listing over every deleted thing** (her round-3
    /// ruling). Newest first by default; `oldestFirst` is the other sort, and
    /// `kinds` is the filter — both hers by ruling ("maybe you can sort the
    /// trash by blocks or note or whatever would be important for that to be
    /// a real option").
    ///
    /// **What it deliberately does NOT list**, each for one reason:
    /// · anything past the 30-day window (`TrashWindow` — the read-side
    ///   clock: it has left every surface);
    /// · a CASCADE VICTIM — a block that died with its note, a take that died
    ///   with its block. A note deleted whole is ONE row, and its blocks come
    ///   back with it; the exact-stamp machinery is the discriminator, and
    ///   listing them separately would offer a Put back that means nothing;
    /// · a stranded original whose note is itself in the Trash — it rides the
    ///   note's ONE row (her round-8b letter, "never double-listed").
    ///
    /// Cost: the four listings are indexed reads bounded by `limit`; the
    /// stranded-originals half walks the derived_from families of unplaced
    /// blocks (`originFamilies`), which is why it is a DELIBERATELY-opened
    /// surface's query and not a held per-keystroke one.
    public static func trash(
        _ db: Database, now: Date, kinds: Set<TrashItem.Kind> = Set(TrashItem.Kind.allCases),
        oldestFirst: Bool = false, limit: Int? = nil
    ) throws -> [TrashItem] {
        let cutoff = TrashWindow.cutoffStamp(now: now)
        var items: [TrashItem] = []

        if kinds.contains(.note) {
            items += try Row.fetchAll(
                db,
                sql: """
                    SELECT id, title, entry_date, deleted_at
                    FROM container
                    WHERE kind = 'post' AND deleted_at IS NOT NULL AND deleted_at >= :cutoff
                    ORDER BY deleted_at DESC, id DESC
                    """,
                arguments: ["cutoff": cutoff]
            ).map { row in
                TrashItem(
                    kind: .note, id: row["id"], deletedAt: row["deleted_at"],
                    title: DisplayTitle.note(
                        title: row["title"], entryDate: row["entry_date"]))
            }
        }

        if kinds.contains(.book) {
            items += try Row.fetchAll(
                db,
                sql: """
                    SELECT id, name, deleted_at FROM reading
                    WHERE deleted_at IS NOT NULL AND deleted_at >= :cutoff
                    ORDER BY deleted_at DESC, id DESC
                    """,
                arguments: ["cutoff": cutoff]
            ).map { row in
                TrashItem(
                    kind: .book, id: row["id"], deletedAt: row["deleted_at"],
                    title: row["name"])
            }
        }

        if kinds.contains(.block) {
            items += try Row.fetchAll(
                db,
                sql: """
                    SELECT b.id AS block_id, b.deleted_at AS deleted_at,
                           dv.working_text AS text,
                           c.id AS note_id, c.title AS note_title,
                           c.entry_date AS note_entry_date,
                           (c.deleted_at IS NOT NULL) AS note_deleted
                    FROM block b
                    LEFT JOIN variant dv
                      ON dv.id = b.default_variant_id
                     AND (dv.deleted_at IS NULL OR dv.deleted_at = b.deleted_at)
                    LEFT JOIN container c ON c.id = b.last_container_id
                    WHERE b.deleted_at IS NOT NULL AND b.deleted_at >= :cutoff
                      AND NOT EXISTS (
                        SELECT 1 FROM container_block cb
                        JOIN container cc ON cc.id = cb.container_id
                        WHERE cb.block_id = b.id
                          AND cb.deleted_at = b.deleted_at
                          AND cc.deleted_at = b.deleted_at)
                    ORDER BY b.deleted_at DESC, b.id DESC
                    """,
                arguments: ["cutoff": cutoff]
            ).map { row in
                TrashItem(
                    kind: .block, id: row["block_id"], deletedAt: row["deleted_at"],
                    text: row["text"], noteID: row["note_id"],
                    noteTitle: (row["note_id"] as String?).map { _ in
                        DisplayTitle.note(
                            title: row["note_title"], entryDate: row["note_entry_date"])
                    },
                    noteIsDeleted: (row["note_deleted"] as Int?) == 1)
            }
        }

        if kinds.contains(.take) {
            // A take listed here is one deleted on its OWN — a take that died
            // with its block carries the block's stamp and comes back with
            // `restoreBlock`, so listing it would offer a door that refuses.
            items += try Row.fetchAll(
                db,
                sql: """
                    SELECT v.id AS variant_id, v.deleted_at AS deleted_at,
                           v.working_text AS text, v.block_id AS block_id,
                           c.id AS note_id, c.title AS note_title,
                           c.entry_date AS note_entry_date,
                           (c.deleted_at IS NOT NULL) AS note_deleted
                    FROM variant v
                    JOIN block b ON b.id = v.block_id
                    LEFT JOIN container c ON c.id = b.last_container_id
                    WHERE v.deleted_at IS NOT NULL AND v.deleted_at >= :cutoff
                      AND b.deleted_at IS NULL
                    ORDER BY v.deleted_at DESC, v.id DESC
                    """,
                arguments: ["cutoff": cutoff]
            ).map { row in
                TrashItem(
                    kind: .take, id: row["variant_id"], deletedAt: row["deleted_at"],
                    text: row["text"], noteID: row["note_id"],
                    noteTitle: (row["note_id"] as String?).map { _ in
                        DisplayTitle.note(
                            title: row["note_title"], entryDate: row["note_entry_date"])
                    },
                    noteIsDeleted: (row["note_deleted"] as Int?) == 1,
                    blockID: row["block_id"])
            }
        }

        if kinds.contains(.preservedOriginal) {
            items += try strandedOriginals(db, now: now)
        }

        items.sort { a, b in
            if a.deletedAt == b.deletedAt {
                return oldestFirst ? a.id < b.id : a.id > b.id
            }
            return oldestFirst ? a.deletedAt < b.deletedAt : a.deletedAt > b.deletedAt
        }
        if let limit { return Array(items.prefix(limit)) }
        return items
    }

    /// **The stranded originals** (her round-8b ruling, the derived half):
    /// live, unplaced, un-archived blocks whose whole descendant family is
    /// deleted. They wear the FAMILY's clock — the latest deletion among
    /// their descendants — and their note must still be live, because a
    /// whole-note deletion carries its original under the note's one row.
    ///
    /// An original with NO descendant family at all is deliberately NOT here:
    /// there is no family clock to ride, so it stays permanent in the note's
    /// tray. Nothing ages out for want of an edge.
    public static func strandedOriginals(_ db: Database, now: Date) throws -> [TrashItem] {
        let cutoff = TrashWindow.cutoffStamp(now: now)
        return try Row.fetchAll(
            db,
            sql: """
                WITH RECURSIVE origins(id) AS (
                  SELECT b.id FROM block b
                  JOIN container c ON c.id = b.last_container_id AND c.deleted_at IS NULL
                  WHERE b.deleted_at IS NULL AND b.archived_at IS NULL
                    AND NOT EXISTS (
                      SELECT 1 FROM container_block placed
                      WHERE placed.block_id = b.id AND placed.deleted_at IS NULL)
                ),
                fam(origin, id) AS (
                  -- The edges are read WITHOUT their tombstones on purpose:
                  -- deleting a block cascade-tombstones its edges, and a
                  -- family whose members are all deleted is precisely the
                  -- state this query exists to find. Lineage is a fact about
                  -- what happened; the tombstone rides the block, not the
                  -- history (`derived_from` has no user-facing delete door).
                  SELECT o.id, e.source_block_id FROM origins o
                  JOIN edge e ON e.target_block_id = o.id AND e.type = 'derived_from'
                  UNION
                  SELECT f.origin, e.source_block_id FROM fam f
                  JOIN edge e ON e.target_block_id = f.id AND e.type = 'derived_from'
                )
                SELECT f.origin AS block_id,
                       MAX(d.deleted_at) AS family_clock,
                       SUM(CASE WHEN d.deleted_at IS NULL THEN 1 ELSE 0 END) AS live_count,
                       dv.working_text AS text,
                       c.id AS note_id, c.title AS note_title, c.entry_date AS note_entry_date
                FROM fam f
                JOIN block d ON d.id = f.id
                JOIN block o ON o.id = f.origin
                LEFT JOIN variant dv ON dv.id = o.default_variant_id AND dv.deleted_at IS NULL
                LEFT JOIN container c ON c.id = o.last_container_id
                GROUP BY f.origin
                HAVING live_count = 0 AND family_clock >= :cutoff
                ORDER BY family_clock DESC, f.origin DESC
                """,
            arguments: ["cutoff": cutoff]
        ).map { row in
            TrashItem(
                kind: .preservedOriginal, id: row["block_id"],
                deletedAt: row["family_clock"], text: row["text"],
                noteID: row["note_id"],
                noteTitle: (row["note_id"] as String?).map { _ in
                    DisplayTitle.note(
                        title: row["note_title"], entryDate: row["note_entry_date"])
                })
        }
    }

    /// One note's originals, split into the two states her round-8b ruling
    /// named — WITHOUT walking the corpus: the recursion is seeded by this
    /// note's own originals, so the cost is those families and nothing else
    /// (the tray holds this observation while a note is open, so its cost is
    /// P1's business).
    ///
    /// `atRisk[blockID]` carries the family clock for an original whose last
    /// live descendant is gone; anything absent from it is permanent.
    public static func originFamilyClocks(
        _ db: Database, postID: String
    ) throws -> [String: String] {
        var clocks: [String: String] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                WITH RECURSIVE origins(id) AS (
                  SELECT b.id FROM block b
                  WHERE b.last_container_id = :post AND b.deleted_at IS NULL
                    AND b.archived_at IS NULL
                    AND NOT EXISTS (
                      SELECT 1 FROM container_block placed
                      WHERE placed.block_id = b.id AND placed.deleted_at IS NULL)
                ),
                fam(origin, id) AS (
                  -- The edges are read WITHOUT their tombstones on purpose:
                  -- deleting a block cascade-tombstones its edges, and a
                  -- family whose members are all deleted is precisely the
                  -- state this query exists to find. Lineage is a fact about
                  -- what happened; the tombstone rides the block, not the
                  -- history (`derived_from` has no user-facing delete door).
                  SELECT o.id, e.source_block_id FROM origins o
                  JOIN edge e ON e.target_block_id = o.id AND e.type = 'derived_from'
                  UNION
                  SELECT f.origin, e.source_block_id FROM fam f
                  JOIN edge e ON e.target_block_id = f.id AND e.type = 'derived_from'
                )
                SELECT f.origin AS block_id,
                       MAX(d.deleted_at) AS family_clock,
                       SUM(CASE WHEN d.deleted_at IS NULL THEN 1 ELSE 0 END) AS live_count
                FROM fam f JOIN block d ON d.id = f.id
                GROUP BY f.origin
                HAVING live_count = 0
                """,
            arguments: ["post": postID]) {
            if let clock: String = row["family_clock"] {
                clocks[row["block_id"] as String] = clock
            }
        }
        return clocks
    }

    /// **Did deleting these blocks strand an original?** (her round-8b
    /// ruling (d): the receipt names it.) Returns the originals whose LAST
    /// live descendant is now gone — read after the delete, so the answer is
    /// the store's, not a guess from the projection.
    public static func originalsStrandedBy(
        _ db: Database, blockIDs: [String]
    ) throws -> [String] {
        guard !blockIDs.isEmpty else { return [] }
        let placeholders = databaseQuestionMarks(count: blockIDs.count)
        return try String.fetchAll(
            db,
            sql: """
                -- Edges read past their tombstones, for `strandedOriginals`'
                -- reason: the delete we are asking about took its own edges
                -- down with it.
                WITH RECURSIVE anc(id) AS (
                  SELECT e.target_block_id FROM edge e
                  WHERE e.source_block_id IN (\(placeholders))
                    AND e.type = 'derived_from'
                  UNION
                  SELECT e.target_block_id FROM edge e
                  JOIN anc a ON e.source_block_id = a.id
                  WHERE e.type = 'derived_from'
                ),
                fam(origin, id) AS (
                  SELECT a.id, e.source_block_id FROM anc a
                  JOIN edge e ON e.target_block_id = a.id AND e.type = 'derived_from'
                  UNION
                  SELECT f.origin, e.source_block_id FROM fam f
                  JOIN edge e ON e.target_block_id = f.id AND e.type = 'derived_from'
                )
                SELECT f.origin FROM fam f
                JOIN block d ON d.id = f.id
                JOIN block o ON o.id = f.origin
                WHERE o.deleted_at IS NULL AND o.archived_at IS NULL
                  AND NOT EXISTS (
                    SELECT 1 FROM container_block placed
                    WHERE placed.block_id = o.id AND placed.deleted_at IS NULL)
                GROUP BY f.origin
                HAVING SUM(CASE WHEN d.deleted_at IS NULL THEN 1 ELSE 0 END) = 0
                """,
            arguments: StatementArguments(blockIDs))
    }

    /// **A note's ARCHIVED blocks** (13j, her round-7 ruling — block-level
    /// archive): live blocks with `archived_at` set, released from this note.
    /// They keep NO clock: archive is kept-forever, the Trash is 30 days, and
    /// the tray's first section says both in one place.
    public static func archivedBlocks(
        _ db: Database, postID: String, limit: Int? = nil
    ) throws -> [TrayItem] {
        var sql = """
            SELECT b.id AS block_id, b.archived_at AS archived_at,
                   dv.working_text AS text
            FROM block b
            LEFT JOIN variant dv ON dv.id = b.default_variant_id AND dv.deleted_at IS NULL
            WHERE b.last_container_id = :post AND b.deleted_at IS NULL
              AND b.archived_at IS NOT NULL
            ORDER BY b.archived_at DESC, b.id
            """
        var arguments: StatementArguments = ["post": postID]
        if let limit {
            sql += " LIMIT :limit"
            arguments += ["limit": limit]
        }
        return try Row.fetchAll(db, sql: sql, arguments: arguments)
            .map {
                TrayItem(
                    blockID: $0["block_id"], deletedAt: $0["archived_at"], text: $0["text"])
            }
    }

    private static func databaseQuestionMarks(count: Int) -> String {
        Array(repeating: "?", count: count).joined(separator: ", ")
    }
}

extension AppDatabase {
    /// The Trash, live (13j J1). Windowed like every other recovery listing.
    public func observeTrash(
        now: Date, kinds: Set<Queries.TrashItem.Kind>, oldestFirst: Bool, limit: Int
    ) -> AsyncValueObservation<[Queries.TrashItem]> {
        observe {
            try Queries.trash(
                $0, now: now, kinds: kinds, oldestFirst: oldestFirst, limit: limit)
        }
    }
}
