import Foundation
import GRDB

// VX-831 — THE VISIBLE PRIVATE MARK's facts (her ask, 2026-11-04: "things that
// are private do not carry a visible mark of being private … we need a
// deliberate private symbol too"). The mark shows on anything ALREADY marked
// Private, read from the STORE's own fact — never reach, never client state
// (the VX-878 record's N-2): a note's own `container.ai_private_at`, or a live
// MEMBER row in a live reading carrying `ai_private_at` (the fence's
// `privateLegForNote`, split into its two halves so the mark's door can tell
// the note's OWN mark from one it wears via a book); a BOOK's own
// `reading.ai_private_at`, books only (a gathering refuses the mark —
// `setBookPrivate`'s `wrongReadingKind`; a stale synced stamp on one is never
// drawn).
//
// P1 — the shared icon's law, bound identically: computed for the ids a host
// DRAWS, never the corpus. Each statement is driven by the ids
// (`json_each … CROSS JOIN`, the `ownershipFactsSQL` discipline): a
// primary-key seek per note or book, `idx_reading_post_post` per note's
// memberships — plan-pinned (`PrivateMarkFactsTests`). Read-only: nothing here
// writes `ai_private_at` (its writers stay `setNotePrivate` /
// `setBookPrivate`, her hand alone).
extension Queries {
    /// One note's Private mark, as its face draws it.
    public struct PrivateMark: Equatable, Sendable {
        /// The note's OWN stamp (`container.ai_private_at`).
        public let own: Bool
        /// The live Private books it is a live member of, by name
        /// (case-insensitive, then id — `privateBooksHolding`'s order).
        public let viaBooks: [BookRef]

        public init(own: Bool, viaBooks: [BookRef]) {
            self.own = own
            self.viaBooks = viaBooks
        }

        /// Private at all — exactly the fence's Private leg for a live note.
        public var isPrivate: Bool { own || !viaBooks.isEmpty }
    }

    /// **The Private marks of the notes a host draws** — only the MARKED ids
    /// appear (an unmarked note is absent: the calm case reads nothing back).
    /// ∝ the ids passed.
    public static func privateMarks(
        _ db: Database, noteIDs: [String]
    ) throws -> [String: PrivateMark] {
        guard !noteIDs.isEmpty else { return [:] }
        let json = String(decoding: try JSONEncoder().encode(noteIDs), as: UTF8.self)
        let own = Set(try String.fetchAll(db, sql: privateMarkOwnSQL, arguments: [json]))
        var via: [String: [BookRef]] = [:]
        for row in try Row.fetchAll(db, sql: privateMarkViaSQL, arguments: [json]) {
            let postID: String = row["post_id"]
            via[postID, default: []].append(BookRef(id: row["reading_id"], name: row["name"]))
        }
        var marks: [String: PrivateMark] = [:]
        for id in own.union(via.keys) {
            marks[id] = PrivateMark(own: own.contains(id), viaBooks: via[id] ?? [])
        }
        return marks
    }

    /// **The BOOKS among `readingIDs` that wear the mark** — live books with
    /// their own stamp. A gathering never does. ∝ the ids passed.
    public static func privateBookMarks(_ db: Database, readingIDs: [String]) throws -> Set<String> {
        guard !readingIDs.isEmpty else { return [] }
        let json = String(decoding: try JSONEncoder().encode(readingIDs), as: UTF8.self)
        return Set(try String.fetchAll(db, sql: privateBookMarkSQL, arguments: [json]))
    }

    /// A note's own half (the fence's `c.ai_private_at IS NOT NULL` over a
    /// live post). One placeholder: the ids as a JSON array.
    static let privateMarkOwnSQL = """
        SELECT c.id FROM json_each(?) j
        CROSS JOIN container c ON c.id = j.value
        WHERE c.deleted_at IS NULL AND c.kind = 'post' AND c.ai_private_at IS NOT NULL
        """

    /// The via-book half (the fence's `EXISTS` leg — a live MEMBER row, an
    /// arrival never, in a live reading carrying the stamp; an archived
    /// Private book is alive and still counts). One placeholder.
    static let privateMarkViaSQL = """
        SELECT j.value AS post_id, r.id AS reading_id, r.name AS name
        FROM json_each(?) j
        CROSS JOIN reading_post rp ON rp.post_id = j.value AND rp.deleted_at IS NULL
         AND rp.status = 'member'
        JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL AND r.ai_private_at IS NOT NULL
        ORDER BY r.name COLLATE NOCASE, r.id
        """

    /// A book's own mark. One placeholder.
    static let privateBookMarkSQL = """
        SELECT r.id FROM json_each(?) j
        CROSS JOIN reading r ON r.id = j.value
        WHERE r.deleted_at IS NULL AND r.kind = 'book' AND r.ai_private_at IS NOT NULL
        """
}
