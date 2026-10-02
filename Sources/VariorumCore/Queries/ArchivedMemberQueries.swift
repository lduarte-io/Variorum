import Foundation
import GRDB

// 13i-d U4 — A BOOK'S ARCHIVED MEMBERS (her #169(a)(1) ruling, 2026-10-02 —
// the plan `notes/plans/phase-13i-d-bookcase.md` item 9; her words,
// verbatim-faithful: *"archived hides from a book's index and outline but it
// still is a part of that book … a per book 'archive', since it's the soft
// trash, and then you see what didn't make it in"*).
//
// THE ONE QUERY of item 9 ("faces + one query"), one predicate written ONCE
// (`archivedMemberJoin` + `archivedMemberRowFilter` — the `bookArrivalSource`
// discipline), read in two shapes:
// - per BOOK (`bookArchivedMembers`) — the archived line's count and, while
//   it is open, its rows; `limit: 0` = the count alone (the collapsed line,
//   and the book's count lines, never pay for a listing);
// - per WING (`archivedMemberCounts`) — the Bookcase row meta's "M archived",
//   grouped, read in the ONE-SHOT tier (`bookcaseAggregates`): it reads
//   `container`, which an autosave rewrites whole, so it can never ride the
//   Bookcase's HELD snapshot (U1's revert-verified P1 pin).
//
// An archived member is a MEMBER (archive is the note's state, never the
// membership's — "archived notes don't lose their books"): it counts toward
// capacity like any member row, and the INDEX never shows it (the assembly
// keeps archive's one meaning — kept, out of the working view). This query is
// the book's one door to its set-aside notes.
//
// ── P1, said exactly ─────────────────────────────────────────────────────────
// Per book: `reading_post` is entered through the book-scoped index SEARCH
// (`reading_id = ?`) and each candidate's note is a primary-key SEEK (`CROSS
// JOIN`, SQLite's join-order directive — never driven from `container`, which
// would scan the corpus's notes); the listing sorts the book's archived
// subset. So the work is ∝ the BOOK's live pair rows — the Arrivals line's
// own class (13i-b F-U2-5). A held observation of it re-fetches whenever
// `container` is written (an autosave rewrites the row), bounded the same way
// (KnownIssues row 13 names it). Per wing: the wing's BOOK rows drive, each
// book's rows a SEARCH, each note a SEEK — one-shot, never held.
extension Queries {
    /// One archived member of a book.
    public struct ArchivedMember: Equatable, Sendable, Identifiable {
        /// The MEMBERSHIP row's id (`reading_post.id`) — the row's identity
        /// in the listing.
        public let id: String
        /// The note — what Unarchive and Remove act on.
        public let postID: String
        /// `DisplayTitle.note` (title, else its day) — the one naming rule.
        public let title: String
        /// When the note was archived: `container.archived_at`, canonical
        /// ISO-8601 text carried RAW (the words are the face's —
        /// `TimeStampFace`).
        public let archivedAt: String

        public init(id: String, postID: String, title: String, archivedAt: String) {
            self.id = id
            self.postID = postID
            self.title = title
            self.archivedAt = archivedAt
        }
    }

    /// The archived line's whole answer: how many, and the first of them.
    public struct BookArchivedMembers: Equatable, Sendable {
        /// Every archived member — independent of `limit`.
        public let count: Int
        /// The first `limit`, newest-archived first (the Archived view's own
        /// order — `archived_at DESC`; PROVISIONAL P-13id-U4-3).
        public let rows: [ArchivedMember]

        public init(count: Int, rows: [ArchivedMember]) {
            self.count = count
            self.rows = rows
        }

        /// Nothing set aside — the common case; the face draws nothing.
        public static let none = BookArchivedMembers(count: 0, rows: [])
    }

    /// **A book's archived members** — counted and listed by ONE predicate: a
    /// LIVE `status='member'` row of THIS book whose note is a live,
    /// ARCHIVED post; a live BOOK only (a gathering holds nothing — §1 — so
    /// it answers none even with a stray row).
    public static func bookArchivedMembers(
        _ db: Database, readingID: String, limit: Int
    ) throws -> BookArchivedMembers {
        guard let reading = try Queries.reading(db, id: readingID),
              reading.kind == .book
        else { return .none }
        let count = try Int.fetchOne(
            db, sql: bookArchivedCountSQL, arguments: [readingID]) ?? 0
        guard count > 0, limit > 0 else { return BookArchivedMembers(count: count, rows: []) }
        let rows = try Row.fetchAll(
            db, sql: bookArchivedRowsSQL, arguments: [readingID, limit]
        ).map { row in
            ArchivedMember(
                id: row["id"],
                postID: row["post_id"],
                title: DisplayTitle.note(
                    title: row["title"], entryDate: row["entry_date"],
                    createdAt: row["note_created_at"]),
                archivedAt: row["archived_at"])
        }
        return BookArchivedMembers(count: count, rows: rows)
    }

    /// **Each live book's archived-member count in one wing** — the same
    /// predicate, grouped (books with none are absent). ONE-SHOT only (see
    /// the header).
    public static func archivedMemberCounts(
        _ db: Database, wingID: String
    ) throws -> [String: Int] {
        var counts: [String: Int] = [:]
        for row in try Row.fetchAll(db, sql: wingArchivedCountsSQL, arguments: [wingID]) {
            counts[row["reading_id"]] = row["n"]
        }
        return counts
    }

    // MARK: - The ONE predicate (shared text — pins read the shipped SQL)

    /// The note half: a live, ARCHIVED post, reached by primary key from the
    /// membership row (`rp`).
    static let archivedMemberJoin = """
        CROSS JOIN container c
          ON c.id = rp.post_id AND c.deleted_at IS NULL
         AND c.archived_at IS NOT NULL AND c.kind = 'post'
        """

    /// The membership half: a live MEMBER row (an arrival is not a member,
    /// §14.3 — an archived waiter is the Arrivals line's).
    static let archivedMemberRowFilter = "rp.deleted_at IS NULL AND rp.status = 'member'"

    /// One book's archived members. One placeholder: the book's id.
    static let bookArchivedSource = """
        FROM reading_post rp
        \(archivedMemberJoin)
        WHERE rp.reading_id = ? AND \(archivedMemberRowFilter)
        """

    static let bookArchivedCountSQL = "SELECT COUNT(*) \(bookArchivedSource)"

    /// Placeholders: the book's id, the limit.
    static let bookArchivedRowsSQL = """
        SELECT rp.id AS id, rp.post_id AS post_id,
               c.title AS title, c.entry_date AS entry_date,
               c.created_at AS note_created_at, c.archived_at AS archived_at
        \(bookArchivedSource)
        ORDER BY c.archived_at DESC, rp.id
        LIMIT ?
        """

    /// One wing's live BOOKS, each book's archived members counted. One
    /// placeholder: the wing's id.
    static let wingArchivedCountsSQL = """
        SELECT rp.reading_id AS reading_id, COUNT(*) AS n
        FROM reading r
        CROSS JOIN reading_post rp ON rp.reading_id = r.id
        \(archivedMemberJoin)
        WHERE r.wing_id = ? AND r.kind = 'book' AND r.deleted_at IS NULL
          AND \(archivedMemberRowFilter)
        GROUP BY rp.reading_id
        """
}

extension AppDatabase {
    /// A book's archived members, live (13i-d U4 — the archived line). `limit`
    /// is REQUIRED (the `observeBookArrivals` discipline): 0 while the line is
    /// collapsed — the count alone — and its window while it is open. The
    /// cost note is `Queries.bookArchivedMembers`'.
    public func observeBookArchivedMembers(
        _ readingID: String, limit: Int
    ) -> AsyncValueObservation<Queries.BookArchivedMembers> {
        observe { try Queries.bookArchivedMembers($0, readingID: readingID, limit: limit) }
    }
}
