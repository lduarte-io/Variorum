import Foundation
import GRDB

// OWNERSHIP's read side (13i-c U2 — the sitting record §1, §5, §6, §18.4; the
// 13i-c plan §3/§5/§6). The confirms LIST what a ceremony will do before it
// does it (her ruling: "the one copy-as-consequence in the design is never
// silent"), so every preview here reads the SAME predicate its operation
// acts on — a confirm can never name a different set than the act forks.
//
// Membership, throughout: a live `status='member'` row of a live BOOK (an
// arrival is never membership; a gathering holds nothing — the three
// readers' `kind='book'` ruling, 13i-b ladder F-R1-7).
//
// Cost (P1): every statement is driven by ONE note's rows
// (`idx_reading_post_post`) or ONE book's rows (`idx_reading_post_order`),
// or by a PAGE of note ids — never the corpus.
extension Queries {
    /// A book, named — what a confirm or a receipt says.
    public struct BookRef: Equatable, Sendable, Identifiable {
        public let id: String
        public let name: String

        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }

    /// One live membership row of a note, with the facts the ownership table
    /// and the doors read.
    public struct NoteMembership: Equatable, Sendable {
        /// The `reading_post` row.
        public let rowID: String
        public let book: BookRef
        public let owned: Bool
        /// The book is FINISHED (`locked` — a sealed book is finished too).
        public let finished: Bool
        public let status: MembershipStatus
    }

    /// The note's live rows in live BOOKS other than `excluding`, earliest
    /// row first (`created_at, id` — the order the revival pass ranks by, so
    /// "the earliest claim" reads the same everywhere). `members` false also
    /// returns arrivals (the move-in preview's severed list).
    public static func noteMemberships(
        _ db: Database, postID: String, excluding readingID: String? = nil,
        membersOnly: Bool = true
    ) throws -> [NoteMembership] {
        let statusClause = membersOnly ? "AND rp.status = 'member'" : ""
        return try Row.fetchAll(
            db,
            sql: """
                SELECT rp.id AS row_id, rp.status AS status,
                       r.id AS reading_id, r.name AS name, r.owned AS owned, r.locked AS locked
                FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                 AND r.kind = 'book'
                WHERE rp.post_id = ? AND rp.deleted_at IS NULL
                  AND rp.reading_id IS NOT ? \(statusClause)
                ORDER BY rp.created_at, rp.id
                """,
            arguments: [postID, readingID]
        ).map { row in
            NoteMembership(
                rowID: row["row_id"],
                book: BookRef(id: row["reading_id"], name: row["name"]),
                owned: row["owned"], finished: row["locked"],
                status: MembershipStatus(rawValue: row["status"]) ?? .member)
        }
    }

    /// A member of a book that also lives in other books — what a fork will
    /// copy, named for the confirm.
    public struct SharedMember: Equatable, Sendable, Identifiable {
        public var id: String { postID }
        public let postID: String
        /// The book's own membership row for it (the slot a fork takes).
        public let membershipID: String
        /// `DisplayTitle.note` — the one naming rule every note row reads.
        public let title: String
        /// The OTHER books it lives in, earliest membership first.
        public let elsewhere: [BookRef]
    }

    /// **THE FORK SET** — the book's live members (live notes, archived ones
    /// included: an archived note is still a note) that are ALSO members of
    /// another live book, in the book's own order (`position, id`). ONE
    /// predicate behind three acts and their confirms: `setReadingOwned`'s
    /// conversion (the plan §3 — "the confirm LISTS them"), `sealReading`'s
    /// forks (§5) and their previews. An owned book's set is empty by
    /// construction — "sealing an owned book needs no forks" (§5).
    public static func sharedMembers(_ db: Database, readingID: String) throws -> [SharedMember] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT rp.id AS row_id, rp.post_id AS post_id,
                       c.title AS title, c.entry_date AS entry_date,
                       c.created_at AS note_created_at,
                       r.id AS other_id, r.name AS other_name
                FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                 AND c.kind = 'post'
                JOIN reading_post o ON o.post_id = rp.post_id AND o.reading_id <> rp.reading_id
                 AND o.deleted_at IS NULL AND o.status = 'member'
                JOIN reading r ON r.id = o.reading_id AND r.deleted_at IS NULL AND r.kind = 'book'
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                ORDER BY rp.position, rp.id, o.created_at, o.id
                """,
            arguments: [readingID])
        var result: [SharedMember] = []
        for row in rows {
            let postID: String = row["post_id"]
            let other = BookRef(id: row["other_id"], name: row["other_name"])
            if let last = result.last, last.postID == postID {
                result[result.count - 1] = SharedMember(
                    postID: postID, membershipID: last.membershipID, title: last.title,
                    elsewhere: last.elsewhere + [other])
            } else {
                result.append(SharedMember(
                    postID: postID, membershipID: row["row_id"],
                    title: DisplayTitle.note(
                        title: row["title"], entryDate: row["entry_date"],
                        createdAt: row["note_created_at"]),
                    elsewhere: [other]))
            }
        }
        return result
    }

    /// **"Own its notes…" — the confirm's list** (the plan §3): the members
    /// that WILL fork, each named with where else it lives. Exactly
    /// `sharedMembers` — the set `setReadingOwned` acts on. Empty for a book
    /// already owned (the conversion is a no-op there).
    public static func ownConversionPreview(
        _ db: Database, readingID: String
    ) throws -> [SharedMember] {
        guard let reading = try Queries.reading(db, id: readingID),
              reading.kind == .book, !reading.owned
        else { return [] }
        return try sharedMembers(db, readingID: readingID)
    }

    /// One membership MOVE IN will sever.
    public struct SeveredMembership: Equatable, Sendable, Identifiable {
        public var id: String { rowID }
        public let rowID: String
        public let book: BookRef
        /// A waiting ARRIVAL (dismissed by the move) rather than a member.
        public let isArrival: Bool
        /// The book is FINISHED: its assembly is frozen, so MOVE IN refuses
        /// while this row stands (PROVISIONAL P-13ic-U2-4) — the door offers
        /// COPY IN alone.
        public let finished: Bool
    }

    /// **"Move in…" — the confirm's severed list** (the plan §3): every OTHER
    /// live row of the note in a live book — members and arrivals alike —
    /// exactly the rows `movePostIntoReading` tombstones. The daily Journal's
    /// membership is one of them when the note is claimed out of it (§10).
    public static func moveInPreview(
        _ db: Database, postID: String, into readingID: String
    ) throws -> [SeveredMembership] {
        try noteMemberships(db, postID: postID, excluding: readingID, membersOnly: false)
            .map {
                SeveredMembership(
                    rowID: $0.rowID, book: $0.book, isArrival: $0.status == .arrival,
                    finished: $0.finished)
            }
    }

    /// A note in a gathering's assembly that another book OWNS — what the
    /// bind cannot materialize as a plain member.
    public struct OwnedElsewhereNote: Equatable, Sendable, Identifiable {
        public var id: String { postID }
        public let postID: String
        public let title: String
        /// The owning book (the EARLIEST owning claim — §18.4).
        public let owner: BookRef
    }

    /// **The bind's confirm — the owned-notes limb** (the 13i-c plan §3): the
    /// notes of the gathering's CURRENT assembly (the order she is looking at,
    /// `order` — the bind's own parameter) that another book owns, each named
    /// with its owner. Exactly the set `convertSmartReadingToCurated`'s
    /// `ownedNotes:` limb acts on. Empty for anything but a live gathering.
    public static func bindOwnedNotesPreview(
        _ db: Database, readingID: String, order: ReadingOrder? = nil
    ) throws -> [OwnedElsewhereNote] {
        guard let reading = try Queries.reading(db, id: readingID),
              reading.kind == .gathering
        else { return [] }
        var result: [OwnedElsewhereNote] = []
        for entry in try assembleReading(db, readingID: readingID, order: order) {
            guard let owner = try noteMemberships(
                db, postID: entry.postID, excluding: readingID
            ).first(where: { $0.owned }) else { continue }
            result.append(OwnedElsewhereNote(
                postID: entry.postID,
                title: DisplayTitle.note(
                    title: entry.title, entryDate: entry.entryDate,
                    createdAt: entry.createdAt),
                owner: owner.book))
        }
        return result
    }

    /// **The Trash's "and N notes"** (the sitting record §18.3; the 13i-c plan
    /// §6): how many notes went to the Trash WITH this deleted book — its
    /// member rows and their notes on the book's EXACT stamp, which only
    /// `deleteReadingWithNotes` writes (a book-only delete leaves its notes
    /// live). 0 for a live or missing book. ∝ the book's own rows.
    public static func trashBookNoteCount(_ db: Database, readingID: String) throws -> Int {
        try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(DISTINCT rp.post_id) FROM reading r
                JOIN reading_post rp ON rp.reading_id = r.id AND rp.deleted_at = r.deleted_at
                 AND rp.status = 'member'
                JOIN container c ON c.id = rp.post_id AND c.deleted_at = r.deleted_at
                WHERE r.id = ? AND r.deleted_at IS NOT NULL
                """,
            arguments: [readingID]) ?? 0
    }

    /// **"Seal…" — the confirm's facts** (the 13i-c plan §5): the members
    /// that WILL fork (named, with where else they live — the confirm LISTS
    /// them, ruled) and how many arrivals the seal's finish will dismiss
    /// (§24's line, shown only when > 0; 0 on a book already finished — its
    /// finish happened). Empty for a sealed book or a gathering.
    public struct SealPreview: Equatable, Sendable {
        public let forks: [SharedMember]
        public let pendingArrivals: Int

        public static let none = SealPreview(forks: [], pendingArrivals: 0)
    }

    public static func sealPreview(_ db: Database, readingID: String) throws -> SealPreview {
        guard let reading = try Queries.reading(db, id: readingID),
              reading.kind == .book, reading.sealedAt == nil
        else { return .none }
        return SealPreview(
            forks: try sharedMembers(db, readingID: readingID),
            pendingArrivals: reading.locked ? 0 : try pendingArrivalCount(db, readingID: readingID))
    }

    /// **The finish confirm's N** (the sitting record §24 — "N waiting at the
    /// door will be dismissed"): the book's pending arrivals, counted by the
    /// Arrivals face's own predicate (`bookArrivals`), so the confirm and the
    /// door's line can never disagree.
    public static func pendingArrivalCount(_ db: Database, readingID: String) throws -> Int {
        try bookArrivals(db, readingID: readingID, limit: 0).count
    }
}
