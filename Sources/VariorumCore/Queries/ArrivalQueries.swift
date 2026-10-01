import Foundation
import GRDB

// 13i-b U2 — THE ARRIVALS FACE's read side (the 13i-b plan §3; the sitting
// record §4, her clutter mandate: *"it's important to me that the UI of a book
// not start to feel excessively cluttered"* — so the face is INVISIBLE when
// this answers zero, and one muted line expanding inline when it does not).
//
// ONE fetch answers both halves the face needs: the COUNT the line says, and
// the first `limit` pending rows the expansion lists (`limit: 0` = the count
// alone — the collapsed line, which is the common occupied state, never pays
// for a listing it does not draw).
//
// ── P1, said exactly ─────────────────────────────────────────────────────────
// Both statements are DRIVEN by the book's own rows: `reading_post` is entered
// through a book-scoped index SEARCH (`reading_id = ?`, live rows), and each
// candidate's note is a primary-key SEEK (`CROSS JOIN` is SQLite's join-order
// directive — the `smartMembershipSQL` precedent: without it the planner may
// drive from `container` and scan every note in the corpus). So the work is ∝
// the BOOK's live pair rows (its members and its arrivals), never the corpus,
// and the listing joins at most `limit` notes. Strictly "∝ the pending set"
// would need an index on `(reading_id, status)` — a SCHEMA change, which this
// phase forbids; the book-scoped class is the shelf count's own, and the
// statement is pinned on its PLAN (`ArrivalQueriesTests`).
//
// A held observation of this re-fetches whenever `container` is written (the
// note join reads it, and an autosave rewrites the row), so the re-fetch rides
// the autosave rate while a book view is open — bounded by the book's rows as
// above; `removeDuplicates` keeps the face from invalidating on an unchanged
// answer (the `AppDatabase.observe` contract).
extension Queries {
    /// One note waiting at a book's door (13i-a's `status='arrival'` row).
    public struct BookArrival: Equatable, Sendable, Identifiable {
        /// The ARRIVAL ROW's id (`reading_post.id`) — what `seatArrival` /
        /// `dismissArrival` take. Deliberately not the note's id: a note
        /// dismissed and rung again by a fresh act stands on a NEW row
        /// (P-13ib-U1-1), and the judgment is about this ringing, not the
        /// note in general.
        public let id: String
        public let postID: String
        /// The note's display name — `DisplayTitle.note` (title, else its
        /// day), the one naming rule every note row in the app reads.
        public let title: String
        /// When it arrived: the arrival row's own `created_at`, canonical
        /// ISO-8601 text, carried RAW — the words are the face's
        /// (`TimeStampFace`), asked per rendered row.
        public let arrivedAt: String

        public init(id: String, postID: String, title: String, arrivedAt: String) {
            self.id = id
            self.postID = postID
            self.title = title
            self.arrivedAt = arrivedAt
        }
    }

    /// The door's whole answer: how many are waiting, and the first of them
    /// in arrival order.
    public struct BookArrivals: Equatable, Sendable {
        /// Every pending arrival the face may name — independent of `limit`.
        public let count: Int
        /// The first `limit` pending arrivals, oldest first (`created_at`,
        /// then id — the plan §3's order: they list in the order they rang).
        public let rows: [BookArrival]

        public init(count: Int, rows: [BookArrival]) {
            self.count = count
            self.rows = rows
        }

        /// Nothing at the door — the common case, and the face draws nothing.
        public static let none = BookArrivals(count: 0, rows: [])
    }

    /// **What is waiting at this book's door.**
    ///
    /// Counted and listed, by ONE predicate (so the line's number and the
    /// expansion's rows can never disagree):
    /// - a LIVE `status='arrival'` row of THIS book — dismissed arrivals are
    ///   tombstones and seated ones are members, so neither counts;
    /// - whose note is a live, UN-ARCHIVED post — the book view's own
    ///   ambient-view rule (an archived member does not render in the book
    ///   either, and intake never seats an archived note). PROVISIONAL
    ///   P-13ib-U2-2 (the U2 record): a waiting note that is archived drops
    ///   off the door while archived and returns on unarchive (its row
    ///   stands untouched);
    /// - of a live BOOK. A gathering holds nothing (the sitting record §1),
    ///   so its door is always empty here, even if a stray row stood on it
    ///   (the reverted-bind class, U1's F-4) — the face is a book's face.
    public static func bookArrivals(
        _ db: Database, readingID: String, limit: Int
    ) throws -> BookArrivals {
        guard let reading = try Queries.reading(db, id: readingID),
              reading.kind == .book
        else { return .none }
        let count = try Int.fetchOne(
            db, sql: bookArrivalCountSQL, arguments: [readingID]) ?? 0
        guard count > 0, limit > 0 else { return BookArrivals(count: count, rows: []) }
        let rows = try Row.fetchAll(
            db, sql: bookArrivalRowsSQL, arguments: [readingID, limit]
        ).map { row in
            BookArrival(
                id: row["id"],
                postID: row["post_id"],
                title: DisplayTitle.note(
                    title: row["title"], entryDate: row["entry_date"],
                    createdAt: row["note_created_at"]),
                arrivedAt: row["arrived_at"])
        }
        return BookArrivals(count: count, rows: rows)
    }

    /// The ONE predicate both statements share — so a pin's
    /// `EXPLAIN QUERY PLAN` reads the shipped text, never a copy of it (the
    /// `catalogPostsSQL` discipline). One placeholder: the book's id.
    static let bookArrivalSource = """
        FROM reading_post rp
        CROSS JOIN container c
          ON c.id = rp.post_id AND c.deleted_at IS NULL
         AND c.archived_at IS NULL AND c.kind = 'post'
        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'arrival'
        """

    /// The count. Placeholder: the book's id.
    static let bookArrivalCountSQL = "SELECT COUNT(*) \(bookArrivalSource)"

    /// The listing, oldest arrival first. Placeholders: the book's id, the
    /// limit.
    static let bookArrivalRowsSQL = """
        SELECT rp.id AS id, rp.post_id AS post_id, rp.created_at AS arrived_at,
               c.title AS title, c.entry_date AS entry_date,
               c.created_at AS note_created_at
        \(bookArrivalSource)
        ORDER BY rp.created_at, rp.id
        LIMIT ?
        """
}

extension AppDatabase {
    /// A book's door, live (13i-b U2 — the Arrivals face). `limit` is
    /// REQUIRED (the `observeLibrary` discipline): the face passes 0 while
    /// the line is collapsed — the count alone — and its window while the
    /// line is open. The cost note is `Queries.bookArrivals`'.
    public func observeBookArrivals(
        _ readingID: String, limit: Int
    ) -> AsyncValueObservation<Queries.BookArrivals> {
        observe { try Queries.bookArrivals($0, readingID: readingID, limit: limit) }
    }
}
