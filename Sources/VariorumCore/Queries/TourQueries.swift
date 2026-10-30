import Foundation
import GRDB

/// **The onboarding tour's two reads** (13s-b U2 — the rule is
/// `Domain/Tour`). Both are bounded by name and by one note's own rows, never
/// by the corpus (P1).
extension Queries {
    /// What the tour looks up once, when it starts: the seeded book its step 2
    /// points at, that book's first story (step 3's card), and the field guide
    /// both roads end at. Any of them may be missing — renamed, deleted, never
    /// seeded — and the tour degrades rather than strands (`Tour.State`).
    public struct TourLandmarks: Equatable, Sendable {
        public var seededBookID: String?
        public var firstStoryID: String?
        public var fieldGuideID: String?
        /// Whether a live, unarchived note wearing the readme's reserved
        /// title exists in the wing (the extra-pass MINOR-1 honesty gate:
        /// the end card's readme sentence shows only when it is true; an
        /// existing store that predates the U1b seed reads false until
        /// VX-105 lands her finished text). Defaulted so older callers
        /// and fixtures keep compiling unchanged.
        public var readmeNoteExists: Bool
        /// **VX-292 R-292-17 — the seeded book's PROPS are broken**: the book
        /// stands, but the chapter the tour names is not a live member of it,
        /// or no live member carries a block with a second take (the fan the
        /// tour teaches with). false with no seeded book (that is the other
        /// case — no book at all). The app's start asks the book's own
        /// restore road to mend what it can reach (`TourEngine`).
        public var seededBookPropsBroken: Bool

        public init(
            seededBookID: String?, firstStoryID: String?, fieldGuideID: String?,
            readmeNoteExists: Bool = false, seededBookPropsBroken: Bool = false
        ) {
            self.seededBookID = seededBookID
            self.firstStoryID = firstStoryID
            self.fieldGuideID = fieldGuideID
            self.readmeNoteExists = readmeNoteExists
            self.seededBookPropsBroken = seededBookPropsBroken
        }
    }

    /// The landmarks in ONE wing (the Bookcase she is looking at). A name is
    /// matched EXACTLY — the seeds' own discovery rule (a renamed book is hers
    /// from then on) — and the oldest live, unarchived BOOK of that name wins
    /// (the seeds' keepers converge on one anyway).
    public static func tourLandmarks(
        _ db: Database, seededBookName: String, firstStoryTitle: String,
        fieldGuideName: String, wingID: String, readmeTitle: String? = nil
    ) throws -> TourLandmarks {
        func book(named name: String) throws -> String? {
            try String.fetchOne(
                db, sql: """
                    SELECT id FROM reading
                    WHERE name = ? AND kind = 'book' AND wing_id = ?
                      AND deleted_at IS NULL AND archived_at IS NULL
                    ORDER BY created_at, id LIMIT 1
                    """,
                arguments: [name, wingID])
        }
        let seeded = try book(named: seededBookName)
        let named = try seeded.flatMap { bookID in
            try String.fetchOne(
                db, sql: """
                    SELECT c.id FROM reading_post rp
                    JOIN container c ON c.id = rp.post_id
                    WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                      AND c.deleted_at IS NULL AND c.kind = 'post' AND c.title = ?
                    ORDER BY rp.position, rp.id LIMIT 1
                    """,
                arguments: [bookID, firstStoryTitle])
        }
        // VX-292 R-292-17 — the toured chapter PREFERS the named one while it
        // carries a fanned block, else accepts the first live member (book
        // order) that still does, else the named one as it stands (any note
        // serves the tour's mechanics). Read only for the seeded book, once
        // per tour start: bounded by ONE book's own rows, never the corpus.
        var firstStory = named
        var propsBroken = false
        if let bookID = seeded {
            let namedIsFanned = try named.map { try noteCarriesAFan(db, postID: $0) } ?? false
            if !namedIsFanned {
                let fanned = try firstFannedMember(db, readingID: bookID)
                if let fanned { firstStory = fanned }
                propsBroken = named == nil || fanned == nil
            }
        }
        // The readme gate (extra-pass MINOR-1): a live, unarchived post
        // wearing the reserved title, in this wing. Versions are born
        // archived, so the archived_at filter fences them for free.
        let readmeExists = try readmeTitle.map { title in
            try Bool.fetchOne(
                db, sql: """
                    SELECT EXISTS(
                        SELECT 1 FROM container
                        WHERE kind = 'post' AND title = ? AND wing_id = ?
                          AND deleted_at IS NULL AND archived_at IS NULL)
                    """,
                arguments: [title, wingID]) ?? false
        } ?? false
        return TourLandmarks(
            seededBookID: seeded, firstStoryID: firstStory,
            fieldGuideID: try book(named: fieldGuideName),
            readmeNoteExists: readmeExists, seededBookPropsBroken: propsBroken)
    }

    /// The fan the tour teaches with: a live block placed in the note whose
    /// LIVE, ACTIVE takes number two or more (an archived take is out of the
    /// fan; a deleted one is gone) — Write's ⑂ badge's own condition.
    private static let fannedBlockInNote = """
        EXISTS (
            SELECT 1 FROM container_block cb
            JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
            WHERE cb.container_id = c.id AND cb.deleted_at IS NULL
              AND (SELECT COUNT(*) FROM variant v
                   WHERE v.block_id = cb.block_id AND v.deleted_at IS NULL
                     AND v.status = 'active') >= 2)
        """

    static func noteCarriesAFan(_ db: Database, postID: String) throws -> Bool {
        try Bool.fetchOne(
            db, sql: "SELECT \(fannedBlockInNote) FROM container c WHERE c.id = ?",
            arguments: [postID]) ?? false
    }

    /// The book's first live member note (book order) carrying a fanned block.
    static func firstFannedMember(_ db: Database, readingID: String) throws -> String? {
        try String.fetchOne(
            db, sql: """
                SELECT c.id FROM reading_post rp
                JOIN container c ON c.id = rp.post_id
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                  AND c.deleted_at IS NULL AND c.kind = 'post'
                  AND \(fannedBlockInNote)
                ORDER BY rp.position, rp.id LIMIT 1
                """,
            arguments: [readingID])
    }

    /// One note's facts the tour's step 11 and its leg wait on: its live tags
    /// (on live tags), and its live BOOK memberships (a gathering holds none;
    /// an arrival waiting at a door is not a membership — the 13i-a schema
    /// note). Starred-ness is the app's stars model's, not this read's.
    public struct TourNoteFacts: Equatable, Sendable {
        public var tagCount: Int
        public var bookCount: Int

        public init(tagCount: Int, bookCount: Int) {
            self.tagCount = tagCount
            self.bookCount = bookCount
        }
    }

    public static func tourNoteFacts(_ db: Database, postID: String) throws -> TourNoteFacts {
        let tags = try Int.fetchOne(
            db, sql: """
                SELECT COUNT(*) FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL AND t.deleted_at IS NULL
                """,
            arguments: [postID]) ?? 0
        let books = try Int.fetchOne(
            db, sql: """
                SELECT COUNT(*) FROM reading_post rp JOIN reading r ON r.id = rp.reading_id
                WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                  AND r.deleted_at IS NULL AND r.kind = 'book'
                """,
            arguments: [postID]) ?? 0
        return TourNoteFacts(tagCount: tags, bookCount: books)
    }
}
