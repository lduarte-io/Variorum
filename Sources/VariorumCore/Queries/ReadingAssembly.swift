import Foundation
import GRDB

// Reading assembly (AppSpec §7 reading/reading_post, §10 sort stamps, §12
// book views): a reading is an ordered pointer list over posts — curated
// membership or a smart predicate — with a sort field, an extent cap, and
// optional sectioning by a hierarchical tag root.
extension Queries {
    /// One post's entry in an assembled reading, in reading order.
    public struct ReadingEntry: Equatable, Sendable {
        public let postID: String
        public let title: String?
        public let entryDate: String?
        /// The section this post falls under. Two sources, one field
        /// (Phase 13b, 3B — N13): on a CURATED reading with live chapters
        /// this is the chapter's NAME (`reading_section.name` — chapters
        /// win, mirroring the book view's `chaptersActive` precedence);
        /// otherwise it is the tag-grouping section — the path of the
        /// *immediate child* of the grouping tag whose subtree contains a
        /// tag applied to the post (the lexically smallest such path when
        /// several match — deterministic). `nil` ⇒ ungrouped/unfiled: no
        /// grouping source, a dangling/tombstoned pointer (the AppSpec §7
        /// read-time rule), or a post outside every section.
        public let sectionPath: String?

        /// The CHAPTER id behind `sectionPath` when chapters govern
        /// (Phase 13b, 3B — N13): the live `reading_section.id` the
        /// membership's `section_id` resolved to. `nil` on the tag-grouping
        /// path, on unfiled entries, and on dangling pointers. Carried so
        /// consumers (export) can distinguish same-named chapters and merge
        /// in EMPTY chapters — names have no uniqueness (AppSpec §7).
        public let sectionID: String?

        /// The note's stored `created_at` stamp — carried ONLY so
        /// `displayTitle` can fall back to the day it was written (13g
        /// batch 7, R6-3). Defaults nil, so every caller and test that
        /// builds an entry by hand degrades to exactly the
        /// entry-date-else-"Untitled" behaviour it had before.
        public let createdAt: String?

        /// Public so view layers and tests can build projections directly
        /// (the RenderedBlock precedent). `sectionID` defaults nil so
        /// pre-13b callers construct unchanged.
        public init(
            postID: String, title: String?, entryDate: String?,
            sectionPath: String?, sectionID: String? = nil, createdAt: String? = nil
        ) {
            self.postID = postID
            self.title = title
            self.entryDate = entryDate
            self.sectionPath = sectionPath
            self.sectionID = sectionID
            self.createdAt = createdAt
        }

        /// What this note is CALLED on screen and in an export heading (13g
        /// batch 7, R6-3) — the ONE display brain, asked lazily so a book's
        /// assembly pays only for the rows a face draws.
        public var displayTitle: String {
            DisplayTitle.note(title: title, entryDate: entryDate, createdAt: createdAt)
        }
    }

    /// The v1 smart-reading predicate vocabulary (PROVISIONAL, Phase 4) —
    /// deliberately the smallest useful set: tag paths, profile, entry-date
    /// range. Stored as JSON in `reading.query_spec`; unknown keys are
    /// ignored (extensible later without migration).
    ///
    /// Semantics: conditions AND across fields; `tags` matches ANY of the
    /// listed paths with subtree semantics (a post tagged at or under any
    /// path); `tagsAll` (Phase 13, A1 — ruling R30's AND-joined tag
    /// promotion) requires EVERY listed path to match, subtree semantics
    /// each — the additive vocabulary extension the promote-tags-to-book
    /// gesture implies. A NULL/absent spec matches all posts (no
    /// constraints — plain predicate semantics); a *malformed* spec
    /// assembles empty (fail closed on corrupt data, never crash); unknown
    /// keys are ignored (the ratified v1 rule — old vocabularies decode
    /// unchanged, no migration).
    public struct SmartQuerySpec: Codable, Equatable, Sendable {
        public var tags: [String]?
        /// AND-of-tags (R30): every path must match. nil/empty = no
        /// constraint. Encoded only when present, so pre-13 specs
        /// round-trip byte-identically.
        public var tagsAll: [String]?
        public var profile: String?
        public var entryDateFrom: String?
        public var entryDateTo: String?

        public init(
            tags: [String]? = nil,
            tagsAll: [String]? = nil,
            profile: String? = nil,
            entryDateFrom: String? = nil,
            entryDateTo: String? = nil
        ) {
            self.tags = tags
            self.tagsAll = tagsAll
            self.profile = profile
            self.entryDateFrom = entryDateFrom
            self.entryDateTo = entryDateTo
        }

        /// The canonical JSON encoding for `reading.query_spec`.
        public func encodedJSON() throws -> String {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            return String(decoding: try encoder.encode(self), as: UTF8.self)
        }
    }

    /// A reading order asked for at READ time, overriding the book's own
    /// stored `sort_field`/`sort_dir` for exactly one assembly (13c Batch
    /// 2D — her A31: *"see a book either by its saved custom order or by an
    /// attribute like time to freely change the order of it"*).
    ///
    /// **It is a way of LOOKING, never the book.** The lens doctrine
    /// applies literally: an override changes what this read returns and
    /// nothing else — `reading.sort_field` is untouched, so export and every
    /// other reader keep seeing the book's
    /// own order until she deliberately saves one (`setReadingSort`).
    ///
    /// The override is applied at exactly the point the stored field would
    /// have been read, so `assembleReading(order: X)` returns byte-identical
    /// entries to `setReadingSort(X)` then `assembleReading()` — pinned,
    /// because "browsing shows what saving would show" is the whole promise
    /// of a preview.
    public struct ReadingOrder: Equatable, Hashable, Sendable {
        public var field: SortField
        public var direction: SortDirection

        public init(field: SortField, direction: SortDirection) {
            self.field = field
            self.direction = direction
        }
    }

    /// The live readings, by name then id (a presentation order — readings
    /// are author-scale metadata, cost ∝ reading count). Phase 10
    /// (additive): the readings-management face lists through this.
    public static func readings(_ db: Database) throws -> [Reading] {
        try Reading.fetchAll(
            db,
            sql: "SELECT * FROM reading WHERE deleted_at IS NULL ORDER BY name, id")
    }

    /// pre-13x ladder round 2, F3 (MINOR-N3): whether a book of this EXACT
    /// name was ever deleted — ANY tombstoned `reading` row, regardless of
    /// the Trash's 30-day window or a purge intent (a Delete Now is the
    /// reader's word too). The seeded books' SILENT ensure (the tutorial
    /// door) reads it as the reader's decision and declines; the explicit
    /// restore doors are asks and do not. A physically purged row leaves no
    /// tombstone — the seeding device's own mark is the other evidence.
    public static func readingTombstoneExists(_ db: Database, name: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS(SELECT 1 FROM reading WHERE name = ? AND deleted_at IS NOT NULL)",
            arguments: [name]) ?? false
    }

    /// The deleted-books recovery surface (13b Stage 4, 4F — N37/S4-28.2:
    /// `restoreReading`'s listing; the `deletedPosts` parallel): tombstoned
    /// readings, newest deletion first. Soft-delete is the only delete
    /// (S2), so everything here is one restore away until GC. `limit`: the
    /// tombstone listing grows forever — a held observation bounds it;
    /// one-shot callers omit.
    /// `now` (13j J1): the 30-day window, required for the reason
    /// `deletedPosts` states — a recovery listing must not show what it can
    /// no longer recover.
    public static func deletedReadings(
        _ db: Database, now: Date, limit: Int? = nil
    ) throws -> [Reading] {
        var sql = """
            SELECT * FROM reading WHERE deleted_at IS NOT NULL AND deleted_at >= ?
              AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                WHERE pi.table_name = 'reading' AND pi.row_id = reading.id
                  AND (pi.deleted_at IS NULL OR pi.deleted_at >= reading.deleted_at))
            ORDER BY deleted_at DESC, id DESC
            """
        var arguments: [(any DatabaseValueConvertible)?] = [TrashWindow.cutoffStamp(now: now)]
        if let limit {
            sql += " LIMIT ?"
            arguments.append(limit)
        }
        return try Reading.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
    }

    /// One reading's row, tolerant (nil when missing or tombstoned) —
    /// review round 1 NIT: headers fetch ONE reading, never the listing.
    public static func reading(_ db: Database, id: String) throws -> Reading? {
        guard let reading = try Reading.fetchOne(db, key: id),
              reading.deletedAt == nil else { return nil }
        return reading
    }

    /// Assembles a reading: curated memberships by `(position, id)` or the
    /// smart predicate, ordered by `sort_field`/`sort_dir`, capped by
    /// `max_posts`, sectioned by the book's live CHAPTERS where they exist
    /// (curated only — Phase 13b 3B, N13; the book view's grouped order:
    /// chapters by position, unfiled entries trailing) else by the
    /// grouping tag. A missing or tombstoned
    /// reading assembles empty (tolerant read). Tombstoned posts are
    /// excluded; archived posts are excluded too (domain archive =
    /// kept-but-out-of-view, AppSpec §6 — PROVISIONAL, see phase closeout).
    /// Cost ∝ the reading's own extent, never the corpus (P1): membership
    /// and grouping resolve through indexed per-post probes.
    ///
    /// `limit` (Phase 10, additive): a caller-side window over the ordered
    /// assembly — a HELD observation must bound its standing fetch (the
    /// `observeLibrary` discipline; the book view passes its window). The
    /// effective cap is the smaller of `limit` and the reading's own
    /// `max_posts`. One-shot callers omit it.
    ///
    /// `order` (13c 2D, additive — A31): read this assembly in a DIFFERENT
    /// order than the book's own, without writing anything. See
    /// `ReadingOrder`. nil = the book's stored order, exactly as before.
    public static func assembleReading(
        _ db: Database, readingID: String, limit: Int? = nil,
        order: ReadingOrder? = nil
    ) throws -> [ReadingEntry] {
        guard let reading = try Reading.fetchOne(db, key: readingID),
              reading.deletedAt == nil
        else { return [] }

        // The ONE place the order is decided (A31): the override stands in
        // for the stored pair here and nowhere else, which is what makes
        // "browsing shows what saving would show" true by construction
        // rather than by two code paths agreeing.
        let sortField = order?.field ?? reading.sortField
        let sortDir = order?.direction ?? reading.sortDir

        // N13 (Phase 13b, 3B): REAL CHAPTERS reach the assembly. A curated
        // book with live `reading_section` rows resolves each membership's
        // `section_id` instead of the tag grouping — the book view's
        // shipped presentation semantics mirrored (BookStructureModel
        // .grouped + chaptersActive, BookView/ReadingFlowView render from
        // them): chapters govern in `(position, id)` order, entries keep
        // the reading's own order within their chapter, unfiled entries
        // TRAIL under no section, and a dangling/tombstoned pointer reads
        // as unsectioned (the AppSpec §7 fallback class — nothing repairs
        // or rewrites it). Chapters WIN over a grouping tag exactly where
        // the book view's `chaptersActive` does (curated + any live
        // section); a chapterless curated book — and every smart book
        // (smart readings refuse sections) — assembles exactly as before.
        let hasChapters: Bool
        if reading.kind == .curated {
            hasChapters = try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS(SELECT 1 FROM reading_section
                                  WHERE reading_id = ? AND deleted_at IS NULL)
                    """,
                arguments: [readingID]) ?? false
        } else {
            hasChapters = false
        }

        // Grouping is active only while the tag is live: a dangling
        // `grouping_tag_id` reads as NULL/ungrouped (AppSpec §7; SET NULL
        // never fires under soft delete).
        var groupingRootID: String?
        if let tagID = reading.groupingTagId, !hasChapters {
            groupingRootID = try String.fetchOne(
                db,
                sql: "SELECT id FROM tag WHERE id = ? AND deleted_at IS NULL",
                arguments: [tagID])
        }
        let sectionSelect: String
        var arguments: [(any DatabaseValueConvertible)?] = []
        if let rootID = groupingRootID {
            sectionSelect = """
                (SELECT MIN(child.path)
                   FROM tag child
                   JOIN post_tag pt ON pt.post_id = c.id AND pt.deleted_at IS NULL
                   JOIN tag applied ON applied.id = pt.tag_id AND applied.deleted_at IS NULL
                  WHERE child.parent_id = ? AND child.deleted_at IS NULL
                    AND (applied.path = child.path
                         OR substr(applied.path, 1, length(child.path) + 1) = child.path || '/'))
                """
            arguments.append(rootID)
        } else {
            sectionSelect = "NULL"
        }

        let sql: String
        switch reading.kind {
        case .curated where hasChapters:
            // The chapter path. The LEFT JOIN embodies the dangling rule
            // (`sectionAssignments`' live-section join, inlined): a dead or
            // missing section — or, defensively, a foreign reading's
            // section, unreachable through Operations — resolves NULL and
            // the entry files as unfiled. `(s.id IS NULL)` trails the
            // unfiled entries (the book view's stragglers-trail call);
            // within a chapter the reading's own order rule holds.
            let order = sortField == .manual
                ? "rp.position, rp.id"
                : stampOrder(sortField, sortDir)
            sql = """
                SELECT c.id AS post_id, c.title AS title, c.entry_date AS entry_date,
                       c.created_at AS created_at,
                       s.name AS section_path, s.id AS section_id
                FROM reading_post rp
                JOIN container c
                  ON c.id = rp.post_id
                 AND c.deleted_at IS NULL
                 AND c.archived_at IS NULL
                 AND c.kind = 'post'
                LEFT JOIN reading_section s
                  ON s.id = rp.section_id
                 AND s.reading_id = rp.reading_id
                 AND s.deleted_at IS NULL
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL
                ORDER BY (s.id IS NULL), s.position, s.id, \(order)
                """
            arguments.append(readingID)

        case .curated:
            let order = sortField == .manual
                ? "rp.position, rp.id"
                : stampOrder(sortField, sortDir)
            sql = """
                SELECT c.id AS post_id, c.title AS title, c.entry_date AS entry_date,
                       c.created_at AS created_at,
                       \(sectionSelect) AS section_path, NULL AS section_id
                FROM reading_post rp
                JOIN container c
                  ON c.id = rp.post_id
                 AND c.deleted_at IS NULL
                 AND c.archived_at IS NULL
                 AND c.kind = 'post'
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL
                ORDER BY \(order)
                """
            arguments.append(readingID)

        case .smart:
            var conditions = [
                "c.deleted_at IS NULL", "c.archived_at IS NULL", "c.kind = 'post'",
            ]
            guard let spec = decodeSpec(reading.querySpec) else { return [] }
            let match = smartMatchSQL(spec)
            conditions += match.conditions
            arguments += match.arguments
            // A smart reading has no positions; `manual` is meaningless for
            // it — fall back to created_at ascending (PROVISIONAL, see
            // phase closeout).
            let order = sortField == .manual
                ? "c.created_at ASC, c.id ASC"
                : stampOrder(sortField, sortDir)
            sql = """
                SELECT c.id AS post_id, c.title AS title, c.entry_date AS entry_date,
                       c.created_at AS created_at,
                       \(sectionSelect) AS section_path, NULL AS section_id
                FROM container c
                WHERE \(conditions.joined(separator: " AND "))
                ORDER BY \(order)
                """
        }

        var limited = sql
        let cap: Int? = switch (reading.maxPosts, limit) {
        case let (max?, window?): Swift.min(max, window)
        case let (max?, nil): max
        case let (nil, window?): window
        case (nil, nil): nil
        }
        if let cap {
            limited += " LIMIT ?"
            arguments.append(cap)
        }

        return try Row.fetchAll(db, sql: limited, arguments: StatementArguments(arguments))
            .map { row in
                ReadingEntry(
                    postID: row["post_id"],
                    title: row["title"],
                    entryDate: row["entry_date"],
                    sectionPath: row["section_path"],
                    sectionID: row["section_id"],
                    createdAt: row["created_at"])
            }
    }

    /// ORDER BY fragment for a stamp-sorted reading: rows missing the stamp
    /// sort last in either direction (deterministic; a post that never
    /// crossed the churn threshold shouldn't lead a by-revision book), tie
    /// broken by id.
    private static func stampOrder(_ field: SortField, _ dir: SortDirection) -> String {
        let column: String
        switch field {
        case .manual: return "c.id"  // unreachable; callers special-case manual
        case .entryDate: column = "c.entry_date"
        case .createdAt: column = "c.created_at"
        case .lastTouched: column = "c.last_touched_at"
        case .lastMajorRevision: column = "c.last_major_revision_at"
        }
        let direction = dir == .desc ? "DESC" : "ASC"
        return "(\(column) IS NULL), \(column) \(direction), c.id \(direction)"
    }

    static func decodeSpec(_ json: String?) -> SmartQuerySpec? {
        guard let json else { return SmartQuerySpec() }  // no spec = no constraints
        return try? JSONDecoder().decode(SmartQuerySpec.self, from: Data(json.utf8))
    }

    /// The smart predicate's SQL half over a `container c` scope — ONE
    /// implementation shared by reading assembly, the Pool, and the
    /// membership chip (Stage B review round 2, MAJOR 3: derived membership
    /// must be visible to the drainage surfaces — R29/R30's purpose). The
    /// caller supplies the ambient scoping (live/unarchived/kind); this
    /// returns only the SPEC's own conditions, ANDed. An empty spec returns
    /// no conditions (matches all posts — the ratified NULL-spec rule).
    static func smartMatchSQL(
        _ spec: SmartQuerySpec
    ) -> (conditions: [String], arguments: [(any DatabaseValueConvertible)?]) {
        var conditions: [String] = []
        var arguments: [(any DatabaseValueConvertible)?] = []
        if let profile = spec.profile {
            conditions.append("c.profile = ?")
            arguments.append(profile)
        }
        if let from = spec.entryDateFrom {
            conditions.append("c.entry_date >= ?")
            arguments.append(from)
        }
        if let to = spec.entryDateTo {
            conditions.append("c.entry_date <= ?")
            arguments.append(to)
        }
        let tagMatch = """
            EXISTS (SELECT 1 FROM post_tag pt
                     JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                    WHERE pt.post_id = c.id AND pt.deleted_at IS NULL
                      AND (t.path = ?
                           OR substr(t.path, 1, length(?) + 1) = ? || '/'))
            """
        if let paths = spec.tags, !paths.isEmpty {
            conditions.append(
                "(" + Array(repeating: tagMatch, count: paths.count).joined(separator: " OR ") + ")")
            for path in paths {
                arguments.append(contentsOf: [path, path, path])
            }
        }
        // tagsAll (Phase 13, R30): one conjunct per path — every path
        // must have a live application at or under it.
        if let allPaths = spec.tagsAll, !allPaths.isEmpty {
            for path in allPaths {
                conditions.append(tagMatch)
                arguments.append(contentsOf: [path, path, path])
            }
        }
        return (conditions, arguments)
    }
}
