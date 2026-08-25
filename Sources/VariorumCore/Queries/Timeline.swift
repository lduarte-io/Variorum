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
        /// The note's stored `created_at` stamp — carried ONLY so
        /// `displayTitle` can fall back to the day it was written (13g batch
        /// 7, R6-3). Optional with a nil default so every existing caller
        /// (tests included) compiles unchanged and degrades to exactly the
        /// entry-date-else-"Untitled" behaviour it had before.
        public let createdAt: String?
        /// The value of the ordering stamp for this row — feeds the next
        /// page's cursor.
        public let stamp: String

        public init(
            postID: String, title: String?, entryDate: String?,
            createdAt: String? = nil, stamp: String
        ) {
            self.postID = postID
            self.title = title
            self.entryDate = entryDate
            self.createdAt = createdAt
            self.stamp = stamp
        }

        /// What this note is CALLED on screen (13g batch 7, R6-3) — the one
        /// brain, asked lazily so a listing pays only for the rows it draws
        /// (the stamp parse is per rendered row, never per fetched row).
        public var displayTitle: String {
            DisplayTitle.note(title: title, entryDate: entryDate, createdAt: createdAt)
        }
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
            SELECT id AS post_id, title AS title, entry_date AS entry_date,
                   created_at AS created_at, \(column) AS stamp
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
                   created_at AS created_at, \(sort.expression) AS stamp
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
    ///
    /// **VERSION HISTORY IS NEVER AN ARCHIVED NOTE** (the post-13l polish
    /// round, ledger row 8 — the architect's V1 classifier, built here as the
    /// EXCLUSION before the versions themselves exist).
    ///
    /// A saved version of a note is a full copy that is born archived, and
    /// its ONE home is that note's own Versions listing: a note with fifteen
    /// saved moments would otherwise drown the genuinely set-aside notes on
    /// the Archived surface — her own crowding worry, answered structurally
    /// rather than with a schema column.
    ///
    /// **The classifier needs no schema and no "version" attribute**, and it
    /// is a CONJUNCTION on purpose:
    ///
    /// - **born archived** — `archived_at = created_at`, both stamps written
    ///   by ONE clock call inside the save-a-version transaction. It is a
    ///   same-row birth fact, never a comparison across devices, so the
    ///   no-clock-trust doctrine is untouched and no CAS repair can rewrite
    ///   the pair into a different meaning;
    /// - **version-linked to a note that is still LIVE and UNARCHIVED** — the
    ///   `version_of` edge `duplicateAsVersion` already mints, read exactly
    ///   the way `versionPeerPosts` reads it (posts are edges-only across
    ///   versions, I8, and edges are block-to-block, so the post link rides
    ///   the blocks).
    ///
    /// A note that was ever LIVE is never version history — a duplicate she
    /// made to work with is a first-class note at birth, and archiving it
    /// later makes it a set-aside WORK. That is precisely what the born-
    /// archived half tests, and why the two halves must both hold.
    ///
    /// The parameter defaults to TRUE because that is the product truth
    /// wherever archived notes are listed; a caller that wants the raw
    /// column (the core's own tombstone/archive pins) says so explicitly.
    public static func archivedPosts(
        _ db: Database, limit: Int? = nil, excludingVersionHistory: Bool = true
    ) throws -> [TimelineItem] {
        let versionFence = excludingVersionHistory ? """

              AND NOT (
                container.archived_at = container.created_at
                AND EXISTS (
                  SELECT 1 FROM edge e
                  JOIN container_block mine
                    ON mine.block_id IN (e.source_block_id, e.target_block_id)
                   AND mine.container_id = container.id AND mine.deleted_at IS NULL
                  JOIN container_block theirs
                    ON theirs.block_id IN (e.source_block_id, e.target_block_id)
                   AND theirs.block_id <> mine.block_id AND theirs.deleted_at IS NULL
                  JOIN container peer
                    ON peer.id = theirs.container_id AND peer.id <> container.id
                   AND peer.kind = 'post' AND peer.deleted_at IS NULL
                   AND peer.archived_at IS NULL
                  WHERE e.type = 'version_of' AND e.deleted_at IS NULL))
            """ : ""
        var sql = """
            SELECT id AS post_id, title AS title, entry_date AS entry_date,
                   created_at AS created_at, archived_at AS stamp
            FROM container
            WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NOT NULL\(versionFence)
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
    ///
    /// `now` (13j J1) is REQUIRED, and required is the point: the 30-day
    /// window is what "in the Trash" MEANS, so a caller must decide the clock
    /// rather than inherit a listing that quietly shows things she can no
    /// longer get back. Rows older than the window have left every surface;
    /// removing them is the purge, which is sync-shaped and designed
    /// separately (`TrashWindow`'s note).
    public static func deletedPosts(
        _ db: Database, now: Date, limit: Int? = nil
    ) throws -> [TimelineItem] {
        var sql = """
            SELECT id AS post_id, title AS title, entry_date AS entry_date,
                   created_at AS created_at, deleted_at AS stamp
            FROM container
            WHERE kind = 'post' AND deleted_at IS NOT NULL AND deleted_at >= ?
              AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                WHERE pi.table_name = 'container' AND pi.row_id = container.id
                  AND (pi.deleted_at IS NULL OR pi.deleted_at >= container.deleted_at))
            ORDER BY deleted_at DESC, id DESC
            """
        var arguments: [(any DatabaseValueConvertible)?] = [TrashWindow.cutoffStamp(now: now)]
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
            createdAt: row["created_at"],
            stamp: row["stamp"])
    }
}
