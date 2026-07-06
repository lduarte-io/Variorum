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

    /// The whole library (folder view, post pickers): every live,
    /// non-archived post, totally ordered. Cost ∝ the number of posts —
    /// the listing surface, not a per-keystroke path; virtualized rendering
    /// is the view's job (P3).
    public static func library(
        _ db: Database, sort: LibrarySort = .lastTouched, direction: SortDirection = .desc
    ) throws -> [TimelineItem] {
        let dir = direction == .desc ? "DESC" : "ASC"
        return try Row.fetchAll(
            db,
            sql: """
                SELECT id AS post_id, title AS title, entry_date AS entry_date,
                       \(sort.expression) AS stamp
                FROM container
                WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL
                ORDER BY \(sort.expression) \(dir), id \(dir)
                """)
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
