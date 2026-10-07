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
    ///
    /// `wingID` (13i-d U5, additive): one wing's readings (a book never spans
    /// wings — the choosers list the note's own wing's books); nil = every
    /// wing, byte-identical for every existing caller.
    ///
    /// 13i-e: ARCHIVED readings are INCLUDED — this is the choosers' and
    /// pickers' feed (her second rider: the add selectors mark an archived
    /// book "(archived)" and the add lands on a plain click) and the seeders'
    /// existence read (a seeded book she archived must never be re-minted).
    /// The Bookcase's listing excludes them at its own choke point
    /// (`bookcaseReadings`); the Archived surface reads `archivedReadings`.
    public static func readings(_ db: Database, wingID: String? = nil) throws -> [Reading] {
        guard let wingID else {
            return try Reading.fetchAll(
                db,
                sql: "SELECT * FROM reading WHERE deleted_at IS NULL ORDER BY name, id")
        }
        let scope = wingScope(column: "wing_id", wingID: wingID)
        return try Reading.fetchAll(
            db,
            sql: "SELECT * FROM reading WHERE deleted_at IS NULL AND \(scope.sql) ORDER BY name, id",
            arguments: StatementArguments(scope.arguments))
    }

    /// **THE ARCHIVED SURFACE'S BOOKS** (13i-e — R-13ie-1: "it should be under
    /// archived"): the live, ARCHIVED readings — books and gatherings alike —
    /// newest archive first (`archivedPosts`' own order: `archived_at DESC,
    /// id DESC`). `wingID` scopes to one wing as surfaces read wings (a
    /// dangling pointer is Home's — her per-library Archived ruling); nil =
    /// every wing. `limit` bounds a held observation; one-shot callers omit.
    /// Cost ∝ the readings (author-scale metadata), never the corpus.
    public static func archivedReadings(
        _ db: Database, wingID: String? = nil, limit: Int? = nil
    ) throws -> [Reading] {
        let scope = wingID.map { wingScope(column: "wing_id", wingID: $0) }
        var sql = """
            SELECT * FROM reading
            WHERE deleted_at IS NULL AND archived_at IS NOT NULL\(
                scope.map { " AND \($0.sql)" } ?? "")
            ORDER BY archived_at DESC, id DESC
            """
        var arguments: [(any DatabaseValueConvertible)?] = scope?.arguments ?? []
        if let limit {
            sql += " LIMIT ?"
            arguments.append(limit)
        }
        return try Reading.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
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
    ///
    /// `filter` (13i-b U4 — the sitting record §18.1, her ORIGINAL sitting
    /// ask: "being able to filter a book within itself for a subset of the
    /// tags"; mechanics here, the filter bar's FACE 13i-d's): a VIEW-LOCAL
    /// tag/star rule over this reading's ASSEMBLY — a read, never membership
    /// (nothing is written; a member the filter hides is still a member). The
    /// grammar is the gathering rule's own (`RuleTerm`, the ★ context read
    /// lazily, wing-scoped to the reading), so "Save this filter as a
    /// gathering" (`Operations.saveFilterAsGathering`) mints exactly the
    /// predicate she was looking through. It filters what the reader SEES:
    /// after the reading's own cap (`max_posts` — a capped book's filtered
    /// view never reaches past its cap), before the caller's `limit` window.
    /// nil = unfiltered, byte-identical to before.
    public static func assembleReading(
        _ db: Database, readingID: String, limit: Int? = nil,
        order: ReadingOrder? = nil, filter: RuleTerm? = nil
    ) throws -> [ReadingEntry] {
        guard let reading = try Reading.fetchOne(db, key: readingID),
              reading.deletedAt == nil
        else { return [] }

        // A CAPPED reading's filter applies to the capped assembly — the
        // set she sees — so it runs over the unfiltered read's ids (bounded
        // by the cap) rather than inside the arm, where it would fill the cap
        // from members past it.
        if let filter, reading.maxPosts != nil {
            let capped = try assembleReading(db, readingID: readingID, order: order)
            let kept = try filteredIDs(
                db, capped.map(\.postID), filter: filter, wingID: reading.wingId)
            let entries = capped.filter { kept.contains($0.postID) }
            return limit.map { Array(entries.prefix($0)) } ?? entries
        }
        var filterClause = ""
        var filterArguments: [(any DatabaseValueConvertible)?] = []
        if let filter {
            var stars = StarContext()
            let match = ruleMatchSQL(
                filter, wingID: reading.wingId, starredNoteIDs: try stars.ids(db, for: filter))
            filterClause = " AND " + match.conditions.joined(separator: " AND ")
            filterArguments = match.arguments
        }

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
        if reading.kind == .book {
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
            sectionSelect = tagFamilySectionSelect(postID: "c.id")
            arguments.append(rootID)
        } else {
            sectionSelect = "NULL"
        }

        let sql: String
        switch reading.kind {
        case .book where hasChapters:
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
                  AND rp.status = 'member'\(filterClause)
                ORDER BY (s.id IS NULL), s.position, s.id, \(order)
                """
            arguments.append(readingID)
            arguments += filterArguments

        case .book:
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
                  AND rp.status = 'member'\(filterClause)
                ORDER BY \(order)
                """
            arguments.append(readingID)
            arguments += filterArguments

        case .gathering:
            // 13o U3 (ruling B): WHO IS A MEMBER is the ONE function the
            // search composer reads too (`gatheringMembership`) — the two can
            // never drift. nil = this gathering assembles EMPTY (archived; no
            // rule; a malformed one).
            guard let membership = try gatheringMembership(db, reading) else { return [] }
            let conditions = membership.conditions
            arguments += membership.arguments
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
                WHERE \(conditions.joined(separator: " AND "))\(filterClause)
                ORDER BY \(order)
                """
            arguments += filterArguments
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

    /// **THE TAG-FAMILY SECTION RULE — one SQL fragment, two readers** (13i-d
    /// U3 extracted it, byte-identical, from the grouping-tag arm above): the
    /// path of the IMMEDIATE CHILD of the family root (`?`, bound by the
    /// caller) whose subtree holds a tag applied to the post named by
    /// `postID` — the lexically smallest such child when several match, so a
    /// note lands under exactly ONE heading. Read by `assembleReading`'s
    /// stored grouping tag and by `tagFamilySections` (the Index's view-local
    /// grouped-by control), so the two can never disagree about where a note
    /// sits.
    static func tagFamilySectionSelect(postID: String) -> String {
        """
        (SELECT MIN(child.path)
           FROM tag child
           JOIN post_tag pt ON pt.post_id = \(postID) AND pt.deleted_at IS NULL
           JOIN tag applied ON applied.id = pt.tag_id AND applied.deleted_at IS NULL
          WHERE child.parent_id = ? AND child.deleted_at IS NULL
            AND (applied.path = child.path
                 OR substr(applied.path, 1, length(child.path) + 1) = child.path || '/'))
        """
    }

    /// **Where each note sits under a tag family** (13i-d U3 — the sitting
    /// record §3/§17(f): the book Index's grouped-by control, a VIEW-LOCAL
    /// grouped DISPLAY — never a `reading_section` row, never a write). For
    /// each of `postIDs`, the family child it files under
    /// (`tagFamilySectionSelect`'s rule); a note under no child is absent.
    ///
    /// P1: ONE statement, the id list driving through `json_each` — ∝ the ids
    /// handed in (the Index's window), never the corpus — and it reads
    /// `post_tag` and `tag` ONLY (no `container`), so a HELD observation of it
    /// never wakes on a keystroke's autosave (pinned by region).
    public static func tagFamilySections(
        _ db: Database, rootID: String, postIDs: [String]
    ) throws -> [String: String] {
        guard !postIDs.isEmpty else { return [:] }
        let json = String(decoding: try JSONEncoder().encode(postIDs), as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT j.value AS post_id,
                       \(tagFamilySectionSelect(postID: "j.value")) AS section_path
                FROM json_each(?) j
                """,
            arguments: [rootID, json])
        var result: [String: String] = [:]
        for row in rows {
            if let path: String = row["section_path"] { result[row["post_id"]] = path }
        }
        return result
    }

    /// **The live tags these notes wear** (13i-d U3 — the Index's grouped-by
    /// families and the filter bar's tag menu read it): every live tag applied
    /// to one of `postIDs`, by path. ∝ the ids handed in; `post_tag` + `tag`
    /// only, like `tagFamilySections`.
    public static func tagsWorn(_ db: Database, postIDs: [String]) throws -> [Tag] {
        guard !postIDs.isEmpty else { return [] }
        let json = String(decoding: try JSONEncoder().encode(postIDs), as: UTF8.self)
        return try Tag.fetchAll(
            db,
            sql: """
                SELECT DISTINCT t.* FROM json_each(?) j
                JOIN post_tag pt ON pt.post_id = j.value AND pt.deleted_at IS NULL
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                ORDER BY t.path, t.id
                """,
            arguments: [json])
    }

    /// The ids among `postIDs` the filter keeps (a capped reading's filter —
    /// see `assembleReading`). ONE statement, the page-driven `CROSS JOIN`
    /// shape (`smartMembershipSQL`'s measured reason): the id list drives and
    /// each note is a primary-key seek — ∝ the capped assembly, never the
    /// corpus.
    private static func filteredIDs(
        _ db: Database, _ postIDs: [String], filter: RuleTerm, wingID: String
    ) throws -> Set<String> {
        guard !postIDs.isEmpty else { return [] }
        var stars = StarContext()
        let match = ruleMatchSQL(
            filter, wingID: wingID, starredNoteIDs: try stars.ids(db, for: filter))
        let json = String(decoding: try JSONEncoder().encode(postIDs), as: UTF8.self)
        return Set(try String.fetchAll(
            db,
            sql: """
                SELECT j.value FROM json_each(?) j
                CROSS JOIN container c ON c.id = j.value
                  AND \(match.conditions.joined(separator: " AND "))
                """,
            arguments: StatementArguments([json] + match.arguments)))
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

    /// LEGACY (pre-v1_18) spec decoding. Production storage is v2
    /// (`RuleGrammar`) since 13i-a; this survives as the v1_18 migration's
    /// reader. (Two DOORS still hand the write choke point a v1 draft — the
    /// tag manager's Promote to Book and the phone's create-book — and the
    /// operation converts it to v2 at the write; the rule EDITOR no longer
    /// does, since 13i-b U3.)
    static func decodeSpec(_ json: String?) -> SmartQuerySpec? {
        guard let json else { return SmartQuerySpec() }  // no spec = no constraints
        return try? JSONDecoder().decode(SmartQuerySpec.self, from: Data(json.utf8))
    }

    /// Every live gathering's rule tags as LIVE PATHS, keyed by reading id
    /// (13i-a — the shelf faces' tag chips; rules hold IDs since v1_18, so
    /// the display paths are a read, refreshed wherever the faces' other
    /// aggregates are). Order: bare (AND) conjunct paths first, then any
    /// OR group's — "tagsAll then tags", the shipped chip order. Dead
    /// terms simply don't list (the chip row is display, never the rule).
    public static func ruleTagPaths(_ db: Database) throws -> [String: [String]] {
        var result: [String: [String]] = [:]
        for reading in try readings(db) where reading.kind == .gathering {
            guard case .rule(let term) = RuleGrammar.read(reading.querySpec) else { continue }
            let conjuncts: [RuleTerm] = switch term {
            case .and(let terms): terms
            default: [term]
            }
            var bare: [String] = []
            var grouped: [String] = []
            func livePath(_ id: String) throws -> String? {
                try String.fetchOne(
                    db, sql: "SELECT path FROM tag WHERE id = ? AND deleted_at IS NULL",
                    arguments: [id])
            }
            for conjunct in conjuncts {
                switch conjunct {
                case .tag(let id):
                    if let path = try livePath(id) { bare.append(path) }
                case .or(let options):
                    for option in options {
                        if case .tag(let id) = option, let path = try livePath(id) {
                            grouped.append(path)
                        }
                    }
                default: break
                }
            }
            result[reading.id] = bare + grouped
        }
        return result
    }

    // (13i-b U3: `legacyDraft` — the v2 rule read back as the v1 DRAFT shape,
    // for the interim rule faces — RETIRED with its last consumer, the v1
    // `SmartSpecSheet`. It was best-effort by design and flagged what it
    // could not spell as `undraftable`; the hazard it guarded (a save
    // through the draft silently dropping a term) is gone by construction
    // now: the rule editor's state IS the v2 grammar (`Domain/RuleEditing`).)

    /// **A GATHERING's MEMBERSHIP — the ONE predicate** (13o U3, the
    /// architect's ruling B: *"the gathering's membership WHERE factored into
    /// ONE function that BOTH assembleReading and the composer read … the two
    /// can never drift"*). The WHERE conditions over a `container c` that
    /// make a note an ASSEMBLED member of this gathering — the ambient
    /// live/unarchived/post clauses, the wing and the rule (`ruleMatchSQL`),
    /// and the hide-owned exclusion when the gathering hides owned notes —
    /// with their arguments in order. **nil = the gathering assembles EMPTY**:
    /// archived (13i-e — "a saved rule put away"), no rule (R-13ic-4) or a
    /// malformed one (fails closed). Byte-identical to the assembly's arm as
    /// it stood before 13o U3 (moved, not rewritten).
    ///
    /// Read by `assembleReading`'s gathering arm and by the search's
    /// `.book(id)` scope on a gathering (`Queries.searchEnvironment(_:scope:)`).
    static func gatheringMembership(
        _ db: Database, _ reading: Reading
    ) throws -> (conditions: [String], arguments: [(any DatabaseValueConvertible)?])? {
        // 13i-e (R-13ie-3, her confirmation inside R-13ie-4): an ARCHIVED
        // gathering STOPS ASSEMBLING — "a saved rule put away" answers
        // EMPTY here, so every reader THROUGH the assembly (the book
        // surfaces, export, the bind and its preview, the Bookcase's
        // gathering counts) follows by construction; the four readers that
        // run a rule OUTSIDE it skip an archived gathering themselves (the
        // Pool's tuck, the chip's gathering leg, the Library card's feed,
        // the word counts). A BOOK keeps assembling while archived — it
        // opens from Archived with its members (the edit law).
        guard reading.kind == .gathering, reading.archivedAt == nil else { return nil }
        var conditions = [
            "c.deleted_at IS NULL", "c.archived_at IS NULL", "c.kind = 'post'",
        ]
        var arguments: [(any DatabaseValueConvertible)?] = []
        // 13i-c (R-13ic-4): NO rule shows NOTHING — the match-all
        // tolerance letter died with the rule-less sweep (v1_20); a
        // rule-less gathering lives only as a Trash restoree until it
        // gets a rule. MALFORMED fails closed as before.
        let match: (conditions: [String], arguments: [(any DatabaseValueConvertible)?])
        var stars = StarContext()
        switch RuleGrammar.read(reading.querySpec) {
        case .malformed, .none: return nil
        case .rule(let term):
            // 13i-b U4 (F-U3-3): the ★ term's context — read only when
            // the rule carries one, so a held observation of a star
            // gathering TRACKS the 'starred' setting (an un-star evicts
            // on the next emission) and every other gathering's never
            // touches it.
            match = ruleMatchSQL(
                term, wingID: reading.wingId,
                starredNoteIDs: try stars.ids(db, for: term))
        }
        conditions += match.conditions
        arguments += match.arguments
        // 13i-c U2 — HIDE-OWNED (the sitting record §6): a gathering that
        // hides owned notes (its own toggle, else the global default —
        // SHOW) composes the ONE exclusion fragment.
        if try hidesOwned(db, reading) {
            conditions.append(ownedElsewhereExclusion(alias: "c"))
        }
        return (conditions, arguments)
    }

    /// The v2 rule's SQL half over a `container c` scope — the ONE
    /// implementation (13i-a; `smartMatchSQL`'s successor) shared by reading
    /// assembly, the Pool, the membership chip and the word counts. The
    /// caller supplies ambient scoping (live/unarchived/kind) exactly as
    /// before; this returns the WING scope (a gathering assembles within
    /// its wing only — sitting record §9) plus the rule's own condition.
    /// A nil term is NO RULE: wing scope only (the standing match-all).
    ///
    /// `starredNoteIDs` is the star term's context (the 'starred' setting's
    /// live NOTE targets — `starredNoteIDs(_:)`; the `IN` list is bounded by
    /// `Operations.starLimit`, which caps the write side). **REQUIRED, no
    /// default** (13i-b U4, F-U3-3): the old `= []` let every caller but
    /// intake match a ★ term against NOTHING, silently — so the compiler now
    /// enumerates the sites, and each passes `StarContext.ids` (a read only
    /// when its rule carries a ★) or an explicit `[]` where no rule exists.
    static func ruleMatchSQL(
        _ term: RuleTerm?, wingID: String, starredNoteIDs: [String]
    ) -> (conditions: [String], arguments: [(any DatabaseValueConvertible)?]) {
        var conditions: [String] = ["c.wing_id = ?"]
        var arguments: [(any DatabaseValueConvertible)?] = [wingID]
        if let term {
            let built = ruleSQL(term, starredNoteIDs: starredNoteIDs)
            conditions.append(built.condition)
            arguments += built.arguments
        }
        return (conditions, arguments)
    }

    /// **The star term's context, read lazily** (13i-b U4 — F-U3-3, the ONE
    /// way a site gets `ruleMatchSQL`'s `starredNoteIDs`). `ids(_:for:)`
    /// answers `[]` without touching the store when the rule carries no ★
    /// term, and otherwise reads `starredNoteIDs` ONCE per context — so a loop
    /// over every gathering (the Pool, the chip, the word counts, the Library
    /// card) pays one setting read at most, and only when some rule needs it.
    ///
    /// Why lazily and not always: a HELD observation tracks what its fetch
    /// read. A star gathering's assembly must read the setting (that is what
    /// makes an un-star evict on the next emission); a tag-only gathering's
    /// must not start re-fetching on every unrelated setting write.
    ///
    /// Cost: one `setting` row + at most `Operations.starLimit` (15) id
    /// resolutions in two indexed reads (`Queries.starred`'s own bound).
    struct StarContext {
        private var cached: [String]?

        init() {}

        mutating func ids(_ db: Database, for term: RuleTerm?) throws -> [String] {
            guard RuleGrammar.referencesStar(term) else { return [] }
            if let cached { return cached }
            let fresh = try Queries.starredNoteIDs(db)
            cached = fresh
            return fresh
        }
    }

    private static func ruleSQL(
        _ term: RuleTerm, starredNoteIDs: [String]
    ) -> (condition: String, arguments: [(any DatabaseValueConvertible)?]) {
        switch term {
        case .and(let terms):
            guard !terms.isEmpty else { return ("1", []) }
            let parts = terms.map { ruleSQL($0, starredNoteIDs: starredNoteIDs) }
            return ("(" + parts.map(\.condition).joined(separator: " AND ") + ")",
                    parts.flatMap(\.arguments))
        case .or(let terms):
            guard !terms.isEmpty else { return ("0", []) }
            let parts = terms.map { ruleSQL($0, starredNoteIDs: starredNoteIDs) }
            return ("(" + parts.map(\.condition).joined(separator: " OR ") + ")",
                    parts.flatMap(\.arguments))
        case .not(let inner):
            let part = ruleSQL(inner, starredNoteIDs: starredNoteIDs)
            return ("NOT (" + part.condition + ")", part.arguments)
        case .tag(let id):
            // Subtree matching THROUGH the referenced tag's LIVE path
            // (§19's rulings: the rule holds the ID, so renameTag can
            // never break it; a dead or missing tag matches NOTHING —
            // the root join fails). The applied-tag walk is v1's own.
            // 13i-b U1 (the 13i-a §9 hand-off a): the walk is WING-SCOPED —
            // tags are per-wing since v1_18 (R-13ia-1), so another wing's
            // same-path twin is a different tag and never satisfies this
            // term ("nothing should cross wings", the sitting record §9).
            // Pinned by direct row insertion (`RuleWingScopingTests`).
            return ("""
                EXISTS (SELECT 1 FROM post_tag pt
                         JOIN tag applied ON applied.id = pt.tag_id AND applied.deleted_at IS NULL
                         JOIN tag root ON root.id = ? AND root.deleted_at IS NULL
                        WHERE pt.post_id = c.id AND pt.deleted_at IS NULL
                          AND applied.wing_id = root.wing_id
                          AND (applied.path = root.path
                               OR substr(applied.path, 1, length(root.path) + 1) = root.path || '/'))
                """, [id])
        case .star:
            guard !starredNoteIDs.isEmpty else { return ("0", []) }
            let marks = Array(repeating: "?", count: starredNoteIDs.count).joined(separator: ",")
            return ("c.id IN (\(marks))", starredNoteIDs)
        case .legacyProfile(let profile):
            return ("c.profile = ?", [profile])
        case .legacyEntryDateFrom(let day):
            return ("c.entry_date >= ?", [day])
        case .legacyEntryDateTo(let day):
            return ("c.entry_date <= ?", [day])
        }
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
