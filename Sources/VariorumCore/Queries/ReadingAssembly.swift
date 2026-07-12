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
        /// The section this post falls under when the reading groups by a
        /// tag root: the path of the *immediate child* of the grouping tag
        /// whose subtree contains a tag applied to the post (the lexically
        /// smallest such path when several match — deterministic). `nil` ⇒
        /// ungrouped: no grouping tag, a dangling/tombstoned grouping tag
        /// (the AppSpec §7 read-time rule), or a post outside every section.
        public let sectionPath: String?

        /// Public so view layers and tests can build projections directly
        /// (the RenderedBlock precedent).
        public init(postID: String, title: String?, entryDate: String?, sectionPath: String?) {
            self.postID = postID
            self.title = title
            self.entryDate = entryDate
            self.sectionPath = sectionPath
        }
    }

    /// The v1 smart-reading predicate vocabulary (PROVISIONAL, Phase 4) —
    /// deliberately the smallest useful set: tag paths, profile, entry-date
    /// range. Stored as JSON in `reading.query_spec`; unknown keys are
    /// ignored (extensible later without migration).
    ///
    /// Semantics: conditions AND across fields; `tags` matches ANY of the
    /// listed paths with subtree semantics (a post tagged at or under any
    /// path). A NULL/absent spec matches all posts (no constraints — plain
    /// predicate semantics); a *malformed* spec assembles empty (fail
    /// closed on corrupt data, never crash).
    public struct SmartQuerySpec: Codable, Equatable, Sendable {
        public var tags: [String]?
        public var profile: String?
        public var entryDateFrom: String?
        public var entryDateTo: String?

        public init(
            tags: [String]? = nil,
            profile: String? = nil,
            entryDateFrom: String? = nil,
            entryDateTo: String? = nil
        ) {
            self.tags = tags
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

    /// Assembles a reading: curated memberships by `(position, id)` or the
    /// smart predicate, ordered by `sort_field`/`sort_dir`, capped by
    /// `max_posts`, sectioned by the grouping tag. A missing or tombstoned
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
    public static func assembleReading(
        _ db: Database, readingID: String, limit: Int? = nil
    ) throws -> [ReadingEntry] {
        guard let reading = try Reading.fetchOne(db, key: readingID),
              reading.deletedAt == nil
        else { return [] }

        // Grouping is active only while the tag is live: a dangling
        // `grouping_tag_id` reads as NULL/ungrouped (AppSpec §7; SET NULL
        // never fires under soft delete).
        var groupingRootID: String?
        if let tagID = reading.groupingTagId {
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
        case .curated:
            let order = reading.sortField == .manual
                ? "rp.position, rp.id"
                : stampOrder(reading.sortField, reading.sortDir)
            sql = """
                SELECT c.id AS post_id, c.title AS title, c.entry_date AS entry_date,
                       \(sectionSelect) AS section_path
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
            if let paths = spec.tags, !paths.isEmpty {
                let one = """
                    EXISTS (SELECT 1 FROM post_tag pt
                             JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                            WHERE pt.post_id = c.id AND pt.deleted_at IS NULL
                              AND (t.path = ?
                                   OR substr(t.path, 1, length(?) + 1) = ? || '/'))
                    """
                conditions.append(
                    "(" + Array(repeating: one, count: paths.count).joined(separator: " OR ") + ")")
                for path in paths {
                    arguments.append(contentsOf: [path, path, path])
                }
            }
            // A smart reading has no positions; `manual` is meaningless for
            // it — fall back to created_at ascending (PROVISIONAL, see
            // phase closeout).
            let order = reading.sortField == .manual
                ? "c.created_at ASC, c.id ASC"
                : stampOrder(reading.sortField, reading.sortDir)
            sql = """
                SELECT c.id AS post_id, c.title AS title, c.entry_date AS entry_date,
                       \(sectionSelect) AS section_path
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
                    sectionPath: row["section_path"])
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

    private static func decodeSpec(_ json: String?) -> SmartQuerySpec? {
        guard let json else { return SmartQuerySpec() }  // no spec = no constraints
        return try? JSONDecoder().decode(SmartQuerySpec.self, from: Data(json.utf8))
    }
}
