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
        ///
        /// **A note's name here is the FULL display answer** (13l Act 7 — the
        /// 8d walk). Every arm below carries `created_at` into
        /// `DisplayTitle.note`, because the rule's third link is the created
        /// DAY and a caller that omits it degrades to the literal
        /// `"Untitled"` — the placeholder her 13g R6-3 / 13k K1 rulings
        /// retired. The walk met it on the one surface where it costs the
        /// most: a nameless note (every ⌘N and quick-entry note is one) read
        /// **"Untitled"** in the Trash while its own masthead, its Library
        /// row and its shelf card all read its date, so the row that must
        /// answer *"which note am I putting back?"* was the only one that
        /// could not. Same fix in all four arms: the block/take/original
        /// arms name their HOME note through the same rule.
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
        /// **WHICH DELETED BLOCK'S CLOCK THIS ORIGINAL RIDES** — set only on
        /// `preservedOriginal` rows (the post-13l polish round, ledger row 22;
        /// her tenth-sitting ruling: *"those ancestors [go] under the live
        /// block that was most recently deleted — so if you had 30 ancestors
        /// on one live block's history and you delete that one live block,
        /// going to trash shows you what you just deleted rather than
        /// suddenly being overwhelmed by 31 random items"*).
        ///
        /// It is the family member whose tombstone IS `deletedAt` (the family
        /// clock, `MAX(deleted_at)` over the descendants) — i.e. the block she
        /// just deleted. The Trash nests the original under that block's row;
        /// when the anchor is not itself listed (windowed out, or it died as a
        /// cascade victim), the original rows on its own and nothing is lost.
        public let anchorBlockID: String?

        /// **THIS NOTE ROW IS A SAVED VERSION OF ANOTHER NOTE** (the post-13l
        /// polish round, ledger row 23 — FOUND-ITEM 1, ratified: *"agree that
        /// deleting a single version from the listing should go into trash for
        /// 30 days"*).
        ///
        /// A version is a container, so it rides the `.note` arm and the
        /// `.note` doors unchanged — Put back returns it to its note's Versions
        /// listing, Delete Now ends its days, Empty Trash takes it because it
        /// is rowed. What the FACE owes is context: the row says it is a saved
        /// moment rather than a note, and it gathers under the note whose
        /// moment it is (`noteID`/`noteTitle` carry that note, so
        /// `TrashGrouping` needs no second rule).
        ///
        /// nil on every ordinary note row — including a note that HAS versions,
        /// which is the group's head, not one of its members.
        public let versionOfNoteID: String?

        /// True for a saved-version row. The face's one question.
        public var isVersion: Bool { versionOfNoteID != nil }

        public init(
            kind: Kind, id: String, deletedAt: String, title: String? = nil,
            text: String? = nil, noteID: String? = nil, noteTitle: String? = nil,
            noteIsDeleted: Bool = false, blockID: String? = nil,
            anchorBlockID: String? = nil, versionOfNoteID: String? = nil
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
            self.anchorBlockID = anchorBlockID
            self.versionOfNoteID = versionOfNoteID
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
    /// Cost: the four listings are reads bounded IN SQL by `limit` (13j
    /// ladder B, B4 — the A6 limit-into-SQL discipline: each arm carries
    /// its own ORDER BY + LIMIT, in the CALLER'S direction, because the
    /// top-N of the merged union equals the top-N over per-arm top-Ns only
    /// when every arm sorts the same way the merge does; a DESC arm under
    /// an oldest-first merge would hand over its newest rows and present
    /// the oldest of THOSE — silently wrong, not merely slow). The
    /// stranded-originals half walks the derived_from families of unplaced
    /// blocks (`originFamilies`), which is why it is a DELIBERATELY-opened
    /// surface's query and not a held per-keystroke one.
    public static func trash(
        _ db: Database, now: Date, kinds: Set<TrashItem.Kind> = Set(TrashItem.Kind.allCases),
        oldestFirst: Bool = false, limit: Int? = nil
    ) throws -> [TrashItem] {
        let cutoff = TrashWindow.cutoffStamp(now: now)
        // Each arm's second sort key IS the row's own id — the same pair
        // the in-memory merge below compares — so per-arm LIMITs and the
        // merged prefix agree exactly (B4's tiebreak-coherence condition).
        let dir = oldestFirst ? "ASC" : "DESC"
        // :limit BINDS (round-1 residuals, item 3 — batch 6's observation):
        // interpolating the Int was injection-safe but minted one cached
        // statement per distinct window; the direction stays interpolated
        // because an ORDER BY keyword cannot bind.
        let limitClause = limit == nil ? "" : " LIMIT :limit"
        var arguments: StatementArguments = ["cutoff": cutoff]
        if let limit { arguments += ["limit": limit] }
        var items: [TrashItem] = []

        if kinds.contains(.note) {
            let noteRows = try Row.fetchAll(
                db,
                sql: """
                    SELECT id, title, entry_date, created_at, deleted_at,
                           -- Ledger row 23 (FOUND-ITEM 1): the birth fact that
                           -- makes a container version history. Selected rather
                           -- than joined, so the peer lookup below runs ONLY for
                           -- the rows that can possibly be versions.
                           (archived_at IS NOT NULL AND archived_at = created_at)
                             AS born_archived
                    FROM container
                    WHERE kind = 'post' AND deleted_at IS NOT NULL AND deleted_at >= :cutoff
                      -- The fence is STAMP-AWARE (13j ladder B, B1): a LIVE
                      -- intent fences, and a completed one fences only rows
                      -- it actually covered (completed at-or-after the
                      -- row's tombstone — the purged-elsewhere ledger lag).
                      -- A VOIDED intent from before a re-delete never hides
                      -- the fresh tombstone's row.
                      AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                        WHERE pi.table_name = 'container' AND pi.row_id = container.id
                          AND (pi.deleted_at IS NULL OR pi.deleted_at >= container.deleted_at))
                    ORDER BY deleted_at \(dir), id \(dir)\(limitClause)
                    """,
                arguments: arguments
            )
            // A saved version names the note whose moment it is, so the row
            // reads as one and gathers under it (ledger row 23). The lookup
            // is skipped for every ordinary note, which is every row that is
            // not born archived — and it is ONE statement for the whole
            // page, not one per version (pre-13u Act 4, 17c P19: this used
            // to be an N+1 inside the `.map`, each call walking every post
            // in the corpus, inside a held observation that re-fires at
            // autosave rate).
            let peers = try versionsOfNotes(
                db,
                versionIDs: noteRows
                    .filter { ($0["born_archived"] as Int?) == 1 }
                    .map { $0["id"] as String })
            items += noteRows.map { row -> TrashItem in
                let peer = peers[row["id"] as String]
                return TrashItem(
                    kind: .note, id: row["id"], deletedAt: row["deleted_at"],
                    title: DisplayTitle.note(
                        title: row["title"], entryDate: row["entry_date"],
                        createdAt: row["created_at"]),
                    noteID: peer?.id, noteTitle: peer?.title,
                    versionOfNoteID: peer?.id)
            }
        }

        if kinds.contains(.book) {
            items += try Row.fetchAll(
                db,
                sql: """
                    SELECT id, name, deleted_at FROM reading
                    WHERE deleted_at IS NOT NULL AND deleted_at >= :cutoff
                      AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                        WHERE pi.table_name = 'reading' AND pi.row_id = reading.id
                          AND (pi.deleted_at IS NULL OR pi.deleted_at >= reading.deleted_at))
                    ORDER BY deleted_at \(dir), id \(dir)\(limitClause)
                    """,
                arguments: arguments
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
                           c.created_at AS note_created_at,
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
                      AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                        WHERE pi.table_name = 'block' AND pi.row_id = b.id
                          AND (pi.deleted_at IS NULL OR pi.deleted_at >= b.deleted_at))
                    ORDER BY b.deleted_at \(dir), b.id \(dir)\(limitClause)
                    """,
                arguments: arguments
            ).map { row in
                TrashItem(
                    kind: .block, id: row["block_id"], deletedAt: row["deleted_at"],
                    text: row["text"], noteID: row["note_id"],
                    noteTitle: (row["note_id"] as String?).map { _ in
                        DisplayTitle.note(
                            title: row["note_title"], entryDate: row["note_entry_date"],
                            createdAt: row["note_created_at"])
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
                           c.created_at AS note_created_at,
                           (c.deleted_at IS NOT NULL) AS note_deleted
                    FROM variant v
                    JOIN block b ON b.id = v.block_id
                    LEFT JOIN container c ON c.id = b.last_container_id
                    WHERE v.deleted_at IS NOT NULL AND v.deleted_at >= :cutoff
                      AND b.deleted_at IS NULL
                      AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                        WHERE pi.table_name = 'variant' AND pi.row_id = v.id
                          AND (pi.deleted_at IS NULL OR pi.deleted_at >= v.deleted_at))
                    ORDER BY v.deleted_at \(dir), v.id \(dir)\(limitClause)
                    """,
                arguments: arguments
            ).map { row in
                TrashItem(
                    kind: .take, id: row["variant_id"], deletedAt: row["deleted_at"],
                    text: row["text"], noteID: row["note_id"],
                    noteTitle: (row["note_id"] as String?).map { _ in
                        DisplayTitle.note(
                            title: row["note_title"], entryDate: row["note_entry_date"],
                            createdAt: row["note_created_at"])
                    },
                    noteIsDeleted: (row["note_deleted"] as Int?) == 1,
                    blockID: row["block_id"])
            }
        }

        if kinds.contains(.preservedOriginal) {
            items += try strandedOriginals(
                db, now: now, oldestFirst: oldestFirst, limit: limit)
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
    ///
    /// `oldestFirst`/`limit` (13j ladder B, B4 — additive, defaults keep
    /// every existing caller byte-identical): the arm sorts and bounds in
    /// SQL like its four siblings above, in the caller's direction.
    public static func strandedOriginals(
        _ db: Database, now: Date, oldestFirst: Bool = false, limit: Int? = nil
    ) throws -> [TrashItem] {
        let cutoff = TrashWindow.cutoffStamp(now: now)
        let dir = oldestFirst ? "ASC" : "DESC"
        let limitClause = limit == nil ? "" : " LIMIT :limit"  // binds (item 3)
        var arguments: StatementArguments = ["cutoff": cutoff]
        if let limit { arguments += ["limit": limit] }
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
                       -- Ledger row 22 (her tenth-sitting ruling): the family
                       -- member whose tombstone IS the family clock — the
                       -- block she just deleted, which the Trash nests this
                       -- original UNDER. Written as an explicit ordered
                       -- correlated read rather than leaning on SQLite's
                       -- bare-column-beside-MAX() convenience, so the answer
                       -- is deterministic by the statement's own words.
                       (SELECT d2.id FROM fam f2
                          JOIN block d2 ON d2.id = f2.id
                         WHERE f2.origin = f.origin AND d2.deleted_at IS NOT NULL
                         ORDER BY d2.deleted_at DESC, d2.id DESC
                         LIMIT 1) AS anchor_block_id,
                       dv.working_text AS text,
                       c.id AS note_id, c.title AS note_title,
                       c.entry_date AS note_entry_date, c.created_at AS note_created_at
                FROM fam f
                JOIN block d ON d.id = f.id
                JOIN block o ON o.id = f.origin
                LEFT JOIN variant dv ON dv.id = o.default_variant_id AND dv.deleted_at IS NULL
                LEFT JOIN container c ON c.id = o.last_container_id
                GROUP BY f.origin
                HAVING live_count = 0 AND family_clock >= :cutoff
                  -- 13j batch 6b: a family with a standing purge intent has
                  -- left every surface (the doors' promise); its origin
                  -- rides the purge and stops listing with it. Stamp-aware
                  -- (ladder B, B1): a VOIDED intent from before a re-delete
                  -- never fences the fresh tombstone's family.
                  AND SUM(CASE WHEN EXISTS (SELECT 1 FROM purge_intent pi
                    WHERE pi.table_name = 'block' AND pi.row_id = f.id
                      AND (pi.deleted_at IS NULL OR pi.deleted_at >= d.deleted_at))
                    THEN 1 ELSE 0 END) = 0
                ORDER BY family_clock \(dir), f.origin \(dir)\(limitClause)
                """,
            arguments: arguments
        ).map { row in
            TrashItem(
                kind: .preservedOriginal, id: row["block_id"],
                deletedAt: row["family_clock"], text: row["text"],
                noteID: row["note_id"],
                noteTitle: (row["note_id"] as String?).map { _ in
                    DisplayTitle.note(
                        title: row["note_title"], entryDate: row["note_entry_date"],
                        createdAt: row["note_created_at"])
                },
                anchorBlockID: row["anchor_block_id"])
        }
    }

    /// A stranded family's fate, as the tray renders it (13j ladder B, B5).
    public enum OriginFamilyFate: Equatable, Sendable {
        /// The family is in the Trash window: the origin rides this clock
        /// in the tray's clock-bearing section (her round-8b ruling).
        case counting(String)
        /// The family has LEFT every surface — the window expired, or a
        /// purge intent stands. The origin leaves BOTH tray buckets with
        /// it: it rode a visible clock for its 30 days and goes exactly
        /// when the clock said (the uniform Trash story) —
        /// unreachable-until-purge precisely like its family. Returning it
        /// to "Preserved originals" instead would show "permanent" on a row
        /// the janitor's family expansion (memo §4c) still takes — her
        /// round-8b trust violation reborn in the post-window gap.
        case gone
    }

    /// One note's originals' fates — WITHOUT walking the corpus: the
    /// recursion is seeded by this note's own originals, so the cost is
    /// those families and nothing else (the tray holds this observation
    /// while a note is open, so its cost is P1's business).
    ///
    /// An origin ABSENT from the result has a live descendant and is
    /// truthfully permanent; `.counting` rides the tray's clock section;
    /// `.gone` leaves both buckets (above). The window and intent fences
    /// here MIRROR `strandedOriginals`' exactly — two surfaces answering
    /// one state differently was B5's finding.
    public static func originFamilyClocks(
        _ db: Database, postID: String, now: Date
    ) throws -> [String: OriginFamilyFate] {
        var fates: [String: OriginFamilyFate] = [:]
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
                       SUM(CASE WHEN d.deleted_at IS NULL THEN 1 ELSE 0 END) AS live_count,
                       -- The intent fence, stamp-aware (B1/B5 — the exact
                       -- condition `strandedOriginals` applies).
                       SUM(CASE WHEN EXISTS (SELECT 1 FROM purge_intent pi
                         WHERE pi.table_name = 'block' AND pi.row_id = f.id
                           AND (pi.deleted_at IS NULL OR pi.deleted_at >= d.deleted_at))
                         THEN 1 ELSE 0 END) AS fenced_count
                FROM fam f JOIN block d ON d.id = f.id
                GROUP BY f.origin
                HAVING live_count = 0
                """,
            arguments: ["post": postID]) {
            guard let clock: String = row["family_clock"] else { continue }
            let fenced = (row["fenced_count"] as Int? ?? 0) > 0
            let blockID = row["block_id"] as String
            if fenced || !TrashWindow.isInWindow(clock, now: now) {
                fates[blockID] = .gone
            } else {
                fates[blockID] = .counting(clock)
            }
        }
        return fates
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
              -- Belt, not braces: `archiveBlock` always releases the
              -- placement, so an archived block with a live one cannot occur
              -- by any door — and if a future door ever placed one without
              -- clearing the stamp, the tray would rather list nothing than
              -- claim a block she can see in her note is "kept aside".
              AND NOT EXISTS (
                SELECT 1 FROM container_block placed
                WHERE placed.block_id = b.id AND placed.deleted_at IS NULL)
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

    /// The shared `IN (?, ?, …)` builder (internal since pre-13u Act 4:
    /// `activeFans`' batched fetch is the second caller).
    static func databaseQuestionMarks(count: Int) -> String {
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
