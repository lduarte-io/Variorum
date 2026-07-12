import Foundation
import GRDB

// Timeline and library listings (AppSpec §10 the two sort stamps, §12
// timeline view; CoreDescription pillar 7 — sane sorting). Timeline pages
// are keyset-paginated: never OFFSET over the corpus (P1 — a page costs the
// page, wherever it sits).
extension Queries {
    /// One post in a timeline or library listing.
    public struct TimelineItem: Equatable, Sendable {
        public let postID: String
        public let title: String?
        public let entryDate: String?
        /// The value of the ordering stamp for this row — feeds the next
        /// page's cursor.
        public let stamp: String
    }

    /// What a timeline is keyed on. Posts missing the chosen stamp are not
    /// on that timeline (an undated post is not on the entry-date timeline;
    /// a never-revised post is not on the by-revision timeline) — the
    /// `library` listing below is the show-everything surface.
    public enum TimelineOrder: Sendable {
        case entryDate
        case lastTouched
        case lastMajorRevision

        var column: String {
            switch self {
            case .entryDate: "entry_date"
            case .lastTouched: "last_touched_at"
            case .lastMajorRevision: "last_major_revision_at"
            }
        }
    }

    /// One viewport-sized page of the timeline, keyset-paginated: pass the
    /// previous page's last item to get the next page. Live, non-archived
    /// posts only. Sort key is `(stamp, id)` — the row-value comparison
    /// makes every page an indexed seek, flat in corpus size (P1).
    public static func timelinePage(
        _ db: Database,
        order: TimelineOrder,
        direction: SortDirection = .desc,
        after last: TimelineItem? = nil,
        limit: Int = 50
    ) throws -> [TimelineItem] {
        let column = order.column
        let dir = direction == .desc ? "DESC" : "ASC"
        let comparator = direction == .desc ? "<" : ">"
        var sql = """
            SELECT id AS post_id, title AS title, entry_date AS entry_date, \(column) AS stamp
            FROM container
            WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL
              AND \(column) IS NOT NULL
            """
        var arguments: [(any DatabaseValueConvertible)?] = []
        if let last {
            sql += " AND (\(column), id) \(comparator) (?, ?)"
            arguments.append(contentsOf: [last.stamp, last.postID])
        }
        sql += " ORDER BY \(column) \(dir), id \(dir) LIMIT ?"
        arguments.append(limit)
        return try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            .map(timelineItem)
    }

    /// The library sort vocabulary: like `TimelineOrder` but total — rows
    /// missing the stamp fall back to `created_at` (never NULL), so a
    /// freshly created, never-touched post still shows up (PROVISIONAL,
    /// phase closeout).
    public enum LibrarySort: Sendable {
        case entryDate
        case createdAt
        case lastTouched
        case lastMajorRevision

        var expression: String {
            switch self {
            case .entryDate: "COALESCE(entry_date, created_at)"
            case .createdAt: "created_at"
            case .lastTouched: "COALESCE(last_touched_at, created_at)"
            case .lastMajorRevision: "COALESCE(last_major_revision_at, created_at)"
            }
        }
    }

    /// The library (folder view, post pickers): live, non-archived posts,
    /// totally ordered. `limit: nil` fetches the whole listing — legal for
    /// one-shot callers (pickers, export) and inherently ∝ the number of
    /// posts. **A held observation must pass a limit** (see
    /// `AppDatabase.observe` — a standing fetch re-runs at write rate, so
    /// its own cost must be viewport-shaped, P1/P3). Even limited, the sort
    /// expression is a COALESCE (un-indexable), so SQLite runs a top-N scan
    /// over the *container* table: cost ∝ post count, never corpus text
    /// size — asserted by benchmark.
    public static func library(
        _ db: Database,
        sort: LibrarySort = .lastTouched,
        direction: SortDirection = .desc,
        limit: Int? = nil,
        profile: Profile? = nil
    ) throws -> [TimelineItem] {
        let dir = direction == .desc ? "DESC" : "ASC"
        var arguments: [(any DatabaseValueConvertible)?] = []
        var sql = """
            SELECT id AS post_id, title AS title, entry_date AS entry_date,
                   \(sort.expression) AS stamp
            FROM container
            WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL
            """
        // Profile-scoped listing (Phase 8: the journal surface lists
        // journal-profile entries). The profile is a UI lens over one
        // container table — never a separate data model (CoreDescription
        // pillar 8).
        if let profile {
            sql += " AND profile = ?"
            arguments.append(profile.rawValue)
        }
        sql += " ORDER BY \(sort.expression) \(dir), id \(dir)"
        if let limit {
            sql += " LIMIT ?"
            arguments.append(limit)
        }
        return try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            .map(timelineItem)
    }

    /// THE notebook rule's canonical entry for a calendar day (Phase 9b
    /// review round 2, NIT 5 — one implementation, shared): the live
    /// journal-profile entry the day opens to, preferring **unarchived
    /// first, then earliest `(created_at, id)`** — deterministic on every
    /// device. `createOrOpenJournalEntry` opens through this; the bridge's
    /// duplicate-day landings target it; anything else that must agree on
    /// "the day's entry" uses this, never a re-typed ORDER BY.
    public static func canonicalJournalEntry(
        _ db: Database, day: String
    ) throws -> Container? {
        try Container.fetchOne(
            db,
            sql: """
                SELECT * FROM container
                WHERE kind = 'post' AND profile = 'journal'
                  AND entry_date = ? AND deleted_at IS NULL
                ORDER BY (archived_at IS NOT NULL) ASC, created_at ASC, id ASC
                LIMIT 1
                """,
            arguments: [day])
    }

    /// Where "kept, out of view" things are found again (review finding —
    /// without this listing, `unarchiveContainer` would be unreachable
    /// through the read layer): live but archived posts, most recently
    /// archived first. The recovery surface behind ratify item 7; its view
    /// arrives with Phases 10–11.
    /// `limit` (review round 1): a held observation must bound its
    /// standing fetch — archives accumulate over years. One-shot callers omit.
    public static func archivedPosts(_ db: Database, limit: Int? = nil) throws -> [TimelineItem] {
        var sql = """
            SELECT id AS post_id, title AS title, entry_date AS entry_date,
                   archived_at AS stamp
            FROM container
            WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NOT NULL
            ORDER BY archived_at DESC, id DESC
            """
        var arguments: [(any DatabaseValueConvertible)?] = []
        if let limit {
            sql += " LIMIT ?"
            arguments.append(limit)
        }
        return try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            .map(timelineItem)
    }

    /// The deleted-posts recovery surface (Phase 10, additive —
    /// `restoreContainer`'s listing; the author decision 2026-07-05 that
    /// deleted posts must be recoverable finally gets its read side):
    /// tombstoned posts, newest deletion first. Soft-delete is the only
    /// delete (S2), so everything here is one restore away until GC.
    /// `limit` (review round 1): the tombstone listing grows forever under
    /// S2 — a held observation bounds it. One-shot callers omit.
    public static func deletedPosts(_ db: Database, limit: Int? = nil) throws -> [TimelineItem] {
        var sql = """
            SELECT id AS post_id, title AS title, entry_date AS entry_date,
                   deleted_at AS stamp
            FROM container
            WHERE kind = 'post' AND deleted_at IS NOT NULL
            ORDER BY deleted_at DESC, id DESC
            """
        var arguments: [(any DatabaseValueConvertible)?] = []
        if let limit {
            sql += " LIMIT ?"
            arguments.append(limit)
        }
        return try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            .map(timelineItem)
    }

    private static func timelineItem(_ row: Row) -> TimelineItem {
        TimelineItem(
            postID: row["post_id"],
            title: row["title"],
            entryDate: row["entry_date"],
            stamp: row["stamp"])
    }
}
