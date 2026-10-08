import Foundation
import GRDB

// **17y B1 item (k) — THE LIBRARY'S NOTES, PAGED.** Her report, verbatim: "the
// fact that the library only shows you the first 40 notes is completely
// unacceptable… we need an area in which people can scroll through ALL of
// their notes, that kind of access is literally what library is supposed to
// be." The Library asked `searchCatalog` for the 40 newest notes and stopped;
// this is the page read its infinite scroll walks instead — KEYSET pagination
// on each sort's own `(key, id)` (AppSpec §6: the sort key is always
// `(value, id)`), never OFFSET, never a raised cap: a page costs one bounded
// statement wherever it sits, and scrolling never re-reads what stands.
//
// THE INDEX STORY, sort by sort (the 17y B1 RECORD carries the measurements):
// - **edited** (`.lastTouched`, the default) rides `idx_container_touched`
//   (`(last_touched_at, id) WHERE deleted_at IS NULL`, AppSpec §7): the
//   listing's key is `COALESCE(last_touched_at, created_at)`, which no index
//   holds, so the page is TWO arms — the touched notes walked down the index
//   from the cursor (a seek, ∝ the page), and the never-touched notes (no
//   stamp: a note no block was ever written into) by their birth — merged to
//   one page. The second arm costs ∝ the never-touched notes, which are rare
//   by construction.
// - **created**, **date** and **title** have no index on their key (the
//   schema's three stamp indexes are `entry_date`, `last_touched_at` and
//   `last_major_revision_at`, and `date` is `COALESCE(entry_date,
//   created_at)` — most notes carry no `entry_date`): each page is ONE
//   statement whose cost is a bounded top-N pass over the live notes of the
//   wing — flat in the page's DEPTH (the keyset never skips rows the way
//   OFFSET does) and ∝ the note count, the same class the shipped first page
//   always paid on every keystroke. Measured, recorded, never a raised cap;
//   an index for them would be a schema event (§12), the author's.
extension Queries {
    /// **Where a notes listing stands**: the last row's sort-key value and id
    /// — the keyset a next page continues from.
    public struct CatalogCursor: Equatable, Hashable, Sendable {
        public let key: String
        public let id: String

        public init(key: String, id: String) {
            self.key = key
            self.id = id
        }
    }

    /// One page of the Library's notes: the hits, in the sort's order, and
    /// the cursor after the last one — nil when the listing has no more.
    public struct CatalogNotesPage: Equatable, Sendable {
        public let hits: [CatalogHit]
        public let next: CatalogCursor?

        public init(hits: [CatalogHit], next: CatalogCursor?) {
            self.hits = hits
            self.next = next
        }
    }

    /// **The next `limit` notes after `cursor`** (nil = from the top), under
    /// the Library's sort, direction, typed query and wing — exactly the
    /// notes, in exactly the order, that `searchCatalog`'s note arm lists
    /// uncapped (pinned: `LibraryPagingTests` walks every sort both ways and
    /// compares). One statement; it asks for ONE more row than it returns, so
    /// the page knows whether another follows without a counting statement.
    ///
    /// **`narrowing` — a `#tag` typed with no words** (VX-84a, the 13o
    /// follow-up run's D-1: a tag alone narrows the Library like a day does).
    /// The question's TEXT-LESS road, read through the ONE composer
    /// (`SearchComposer.listingNarrowing` — R-13o-8: this file composes its
    /// fragment, never re-derives the tag SQL): each arm DRIVES from the
    /// tag's applications (`CROSS JOIN` — a page costs ∝ the tag's notes,
    /// never a walk of the wing's notes in sort order hunting for tagged ones;
    /// the seam record's measurement) and keeps its own sort and keyset, so
    /// the sort door orders a tag's notes exactly as it orders the Library.
    /// The composer's conditions carry the archived facet (the shipped
    /// `archived_at IS NULL` is its living letter). nil is the shipped
    /// statement, byte for byte; a narrowing the road cannot serve (words, or
    /// no typed tag) FAILS CLOSED — an empty page, never the whole Library
    /// under a question it did not answer.
    public static func catalogNotesPage(
        _ db: Database, query: String,
        sort: LibrarySort = .lastTouched, direction: SortDirection = .desc,
        after cursor: CatalogCursor? = nil, limit: Int, wingID: String? = nil,
        narrowing: SearchQuery? = nil
    ) throws -> CatalogNotesPage {
        precondition(limit > 0, "a page holds at least one note")
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let like = "%\(catalogLikeEscaped(trimmed))%"
        let scope = wingID.map { wingScope(column: "wing_id", wingID: $0) }
        let narrowed = try narrowing.flatMap { question in
            SearchComposer.listingNarrowing(
                question, kind: .notes, wingID: wingID ?? "",
                environment: try searchEnvironment(db))
        }
        if narrowing != nil, narrowed == nil { return CatalogNotesPage(hits: [], next: nil) }
        let sql = catalogNotesPageSQL(
            sort: sort, direction: direction, hasCursor: cursor != nil,
            wingScope: scope?.sql, narrowing: narrowed)
        // Each arm binds: the narrowing's driver and conditions (when one
        // narrows), the query (3×), the wing's arguments, the cursor (key,
        // id), its own limit; the merged page binds the outer limit.
        func armArguments() -> [(any DatabaseValueConvertible)?] {
            var arguments: [(any DatabaseValueConvertible)?] = []
            if let narrowed {
                arguments += (narrowed.driverArguments + narrowed.conditionArguments)
                    .map { databaseValue($0) as (any DatabaseValueConvertible)? }
            }
            arguments += [trimmed, like, like]
            arguments += scope?.arguments ?? []
            if let cursor { arguments += [cursor.key, cursor.id] }
            arguments.append(limit + 1)
            return arguments
        }
        var arguments = armArguments()
        if sort == .lastTouched {
            arguments += armArguments()
            arguments.append(limit + 1)
        }
        let rows = try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
        let hits = rows.prefix(limit).map { row in
            CatalogHit(
                kind: .post, id: row["id"],
                title: DisplayTitle.note(
                    title: row["title"], entryDate: row["entry_date"],
                    createdAt: row["created_at"]),
                detail: row["entry_date"],
                storedTitle: DisplayTitle.isAbsent(row["title"]) ? nil : row["title"],
                createdAt: row["created_at"],
                lastTouchedAt: row["touched_at"],
                profile: row["profile"],
                // VX-84a: only the narrowed page selects the fact (the shipped
                // statement lists no archived note at all).
                isArchived: (row["archived"] as Bool?) ?? false)
        }
        let next: CatalogCursor? = rows.count > limit
            ? CatalogCursor(key: rows[limit - 1]["sort_key"], id: rows[limit - 1]["id"])
            : nil
        return CatalogNotesPage(hits: Array(hits), next: next)
    }

    /// The page's statement — built in ONE place so the pins'
    /// `EXPLAIN QUERY PLAN` and step counts read the shipped text.
    static func catalogNotesPageSQL(
        sort: LibrarySort, direction: SortDirection, hasCursor: Bool, wingScope: String?,
        narrowing: SearchComposer.ListingNarrowing? = nil
    ) -> String {
        let dir = direction == .desc ? "DESC" : "ASC"
        let comparison = direction == .desc ? "<" : ">"
        func arm(
            key: String, collation: String, extraWhere: String, index: String? = nil
        ) -> String {
            let cursor = hasCursor
                ? "\n  AND (\(key)\(collation), id) \(comparison) (?, ?)" : ""
            let wing = wingScope.map { "\n  AND \($0)" } ?? ""
            if let narrowing {
                // VX-84a: DRIVEN from the tag's applications (the composer's
                // driver, CROSS JOIN keeps it the outer loop); the composer's
                // conditions say everything else — liveness, wing, the facet,
                // the filter half. No `INDEXED BY`: the sort index would make
                // the walk ∝ the wing's notes.
                return """
                    SELECT c.id AS id, c.title AS title, c.entry_date AS entry_date,
                           c.created_at AS created_at, c.profile AS profile,
                           COALESCE(c.last_touched_at, c.created_at) AS touched_at,
                           (c.archived_at IS NOT NULL) AS archived,
                           \(key) AS sort_key
                    FROM (\(narrowing.driver)) t
                    CROSS JOIN container c ON c.id = t.tagged_id
                    WHERE \(narrowing.conditions)\(extraWhere)
                      AND (? = '' OR COALESCE(title, '') LIKE ? ESCAPE '\\' OR COALESCE(entry_date, '') LIKE ? ESCAPE '\\')\(wing)\(cursor)
                    ORDER BY \(key)\(collation) \(dir), id \(dir)
                    LIMIT ?
                    """
            }
            return """
                SELECT id, title, entry_date, created_at, profile,
                       COALESCE(last_touched_at, created_at) AS touched_at,
                       \(key) AS sort_key
                FROM container\(index.map { " INDEXED BY \($0)" } ?? "")
                WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL\(extraWhere)
                  AND (? = '' OR COALESCE(title, '') LIKE ? ESCAPE '\\' OR COALESCE(entry_date, '') LIKE ? ESCAPE '\\')\(wing)\(cursor)
                ORDER BY \(key)\(collation) \(dir), id \(dir)
                LIMIT ?
                """
        }
        switch sort {
        case .lastTouched:
            // THE TWO ARMS (the index story above): touched notes down
            // `idx_container_touched`, never-touched ones by their birth.
            // `INDEXED BY` is the planner instruction this store needs: it
            // never runs `ANALYZE`, so with no `sqlite_stat1` the planner
            // prefers `idx_container_kind`'s equality and sorts every post
            // (measured: 22,729 VM steps for a 41-row page over 600 notes);
            // the timeline's own index answers the page from the cursor.
            let touched = arm(
                key: "last_touched_at", collation: "",
                extraWhere: " AND last_touched_at IS NOT NULL",
                index: "idx_container_touched")
            let untouched = arm(
                key: "created_at", collation: "",
                extraWhere: " AND last_touched_at IS NULL",
                index: "idx_container_touched")
            // (VX-84a: a narrowed page's arms carry no `INDEXED BY` — `arm`
            // returns the driven shape before the index is ever named.)
            return """
                SELECT * FROM (\(touched))
                UNION ALL
                SELECT * FROM (\(untouched))
                ORDER BY sort_key \(dir), id \(dir)
                LIMIT ?
                """
        case .entryDate, .createdAt, .lastMajorRevision, .title:
            return arm(key: sort.keyExpression, collation: sort.keyCollation, extraWhere: "")
        }
    }
}

extension Queries.LibrarySort {
    /// The sort's KEY without its collation (`expression` is the two
    /// together, for an `ORDER BY`); the cursor compares the key under the
    /// same collation the order uses.
    var keyExpression: String {
        switch self {
        case .entryDate: "COALESCE(entry_date, created_at)"
        case .createdAt: "created_at"
        case .lastTouched: "COALESCE(last_touched_at, created_at)"
        case .lastMajorRevision: "COALESCE(last_major_revision_at, created_at)"
        case .title: "COALESCE(NULLIF(title, ''), entry_date, created_at)"
        }
    }

    var keyCollation: String { self == .title ? " COLLATE NOCASE" : "" }
}
