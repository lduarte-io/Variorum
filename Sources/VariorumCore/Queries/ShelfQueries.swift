import Foundation
import GRDB

// The shelf's read side (Phase 13, B2 — the sitting-1 books reversal +
// R4's terminal list shelf + R44's final sidebar). Two cost tiers by
// design: `bookshelf` is observation-safe (reading rows + counted joins —
// author-scale), while `bookWordCounts` is a ONE-SHOT aggregate (it sums
// live variant text across memberships — corpus-scale work that must
// never sit in a held observation re-running at autosave rate; the view
// model fetches it on appearance/refresh — the P1 discipline, recorded).
extension Queries {
    /// One shelf row: the reading plus its cheap counts.
    public struct ShelfBook: Equatable, Sendable {
        public let reading: Reading
        public let postCount: Int
        public let sectionCount: Int
        /// 13i-d U1 — the Bookcase row's ARRIVAL count (the sitting record
        /// §4: "a small accent count on the Bookcase row"). A BOOK's pending
        /// `status='arrival'` rows; always 0 on a gathering (it holds
        /// nothing, §1). Defaulted so every existing call site compiles.
        public let arrivalCount: Int
        /// 13i-d U2 ACT 0 — whether the book is STARRED, read as the UNION
        /// (F-U1-2 (A), ruled): its `reading.starred` column OR its entry in
        /// the 13f `starred` list (`Queries.starredReadingIDs`). The Bookcase's
        /// float and its ★ read THIS, never `reading.starred` alone — the
        /// column is one of the two stores, not the truth. Defaulted to the
        /// column so a hand-built row (a pin) reads as it always did.
        public let starred: Bool

        public init(
            reading: Reading, postCount: Int, sectionCount: Int, arrivalCount: Int = 0,
            starred: Bool? = nil
        ) {
            self.reading = reading
            self.postCount = postCount
            self.sectionCount = sectionCount
            self.arrivalCount = arrivalCount
            self.starred = starred ?? reading.starred
        }
    }

    /// The live books with membership + chapter counts, by name — the
    /// shelf's observed listing (pin/journal ordering is the view model's
    /// presentation call over `shelfPins`).
    ///
    /// **13i-d U1:** `wingID` scopes the listing to ONE wing — the Bookcase
    /// is a wing's surface (the sitting record §9); nil keeps the shipped
    /// all-wings read (the phone's shelf, untouched this phase). Each row
    /// also carries its pending-ARRIVAL count, read from `reading_post`
    /// ALONE — and that is a P1 decision, not an economy: this listing rides
    /// a HELD observation, and `autosave` rewrites the `container` row whole
    /// (`Container.update`), so a statement that read any `container` column
    /// would wake the Bookcase at keystroke rate. Counting the rows alone
    /// also counts an ARCHIVED waiter — which is exactly the 13i-d U4 ruling
    /// (#169(a)(2): archived waiters show at the door, marked); a deleted
    /// note's arrival rows died with it (the container tombstone cascade).
    public static func bookshelf(_ db: Database, wingID: String? = nil) throws -> [ShelfBook] {
        let readings = try bookcaseReadings(db, wingID: wingID)
        guard !readings.isEmpty else { return [] }
        let wingScoped = wingID != nil
        let arguments: StatementArguments = wingID.map { [$0] } ?? []
        // 13i-a (ladder R1 MIN-3): an ARRIVAL is not a member — the
        // shelf's count, the capacity gate and the Pool's bookless
        // exclusion all read status='member' (sitting record §4's letter:
        // "membership rows counted").
        let postCounts = try countsByReading(
            db, sql: bookcaseMemberCountsSQL(wingScoped: wingScoped), arguments: arguments)
        let sectionCounts = try countsByReading(
            db, sql: bookcaseSectionCountsSQL(wingScoped: wingScoped), arguments: arguments)
        let arrivalCounts = try countsByReading(
            db, sql: bookcaseArrivalCountsSQL(wingScoped: wingScoped), arguments: arguments)
        // 13i-d U2 ACT 0: the star is the UNION of the two stores. Reading
        // the `setting` list adds that table to the held region — a setting
        // write is rare and never a keystroke's (P1 untouched).
        let starredIDs = try starredReadingIDs(db)
        return readings.map { reading in
            ShelfBook(
                reading: reading,
                postCount: postCounts[reading.id] ?? 0,
                sectionCount: sectionCounts[reading.id] ?? 0,
                arrivalCount: reading.kind == .book ? arrivalCounts[reading.id] ?? 0 : 0,
                starred: starredIDs.contains(reading.id))
        }
    }

    /// One wing's live readings (or, nil, every wing's — the phone's shipped
    /// all-wings read), by (name, id). The WING form filters in SQL, never in
    /// Swift over a store-wide fetch (ladder A round 1, MINOR 2).
    ///
    /// **13i-e — ARCHIVED READINGS ARE NOT ON THE BOOKCASE** (R-13ie-1: "it
    /// should be under archived"). This is the ONE choke point: `bookshelf`,
    /// `bookcase` (the snapshot the № census, the strip's counts and the
    /// solos derive from — `BookcaseBoard` reads only its books) and
    /// `bookcaseAggregates` all list through here, on the Mac's wing-scoped
    /// arm AND the phone's all-wings arm. The pickers keep archived books
    /// (`Queries.readings`); the Archived surface reads `archivedReadings`.
    static func bookcaseReadings(_ db: Database, wingID: String?) throws -> [Reading] {
        guard let wingID else {
            return try Reading.fetchAll(
                db,
                sql: """
                    SELECT * FROM reading WHERE deleted_at IS NULL AND archived_at IS NULL
                    ORDER BY name, id
                    """)
        }
        return try Reading.fetchAll(
            db,
            sql: """
                SELECT * FROM reading WHERE wing_id = ? AND deleted_at IS NULL
                  AND archived_at IS NULL
                ORDER BY name, id
                """,
            arguments: [wingID])
    }

    // The three per-book count statements behind `bookshelf` — split out so a
    // pin can read the SHIPPED text (the `catalogPostsSQL` discipline) and
    // assert two things: none names `container` (the P1 reason above), and
    // the WING-scoped form DRIVES FROM THE WING'S READINGS — `reading r WHERE
    // r.wing_id = ?`, the `wingArchivedCountsSQL` shape — so the held read's
    // work is the wing's own, never every wing's (ladder A round 1, MINOR 2:
    // these GROUP BYs scanned the whole store under a "one wing's" contract,
    // and U5's wings would have inherited the silent cross-wing cost into a
    // HELD read). `wingScoped: false` (a nil wing — the phone's all-wings
    // read) keeps the shipped store-wide shape. One placeholder when scoped:
    // the wing's id.

    static func bookcaseMemberCountsSQL(wingScoped: Bool) -> String {
        wingScoped
            ? """
                SELECT rp.reading_id AS reading_id, COUNT(*) AS n
                FROM reading r
                CROSS JOIN reading_post rp ON rp.reading_id = r.id
                WHERE r.wing_id = ? AND r.deleted_at IS NULL
                  AND rp.deleted_at IS NULL AND rp.status = 'member'
                GROUP BY rp.reading_id
                """
            : """
                SELECT reading_id, COUNT(*) AS n FROM reading_post
                WHERE deleted_at IS NULL AND status = 'member'
                GROUP BY reading_id
                """
    }

    static func bookcaseSectionCountsSQL(wingScoped: Bool) -> String {
        wingScoped
            ? """
                SELECT rs.reading_id AS reading_id, COUNT(*) AS n
                FROM reading r
                CROSS JOIN reading_section rs ON rs.reading_id = r.id
                WHERE r.wing_id = ? AND r.deleted_at IS NULL
                  AND rs.deleted_at IS NULL
                GROUP BY rs.reading_id
                """
            : """
                SELECT reading_id, COUNT(*) AS n FROM reading_section
                WHERE deleted_at IS NULL GROUP BY reading_id
                """
    }

    static func bookcaseArrivalCountsSQL(wingScoped: Bool) -> String {
        wingScoped
            ? """
                SELECT rp.reading_id AS reading_id, COUNT(*) AS n
                FROM reading r
                CROSS JOIN reading_post rp ON rp.reading_id = r.id
                WHERE r.wing_id = ? AND r.deleted_at IS NULL
                  AND rp.deleted_at IS NULL AND rp.status = 'arrival'
                GROUP BY rp.reading_id
                """
            : """
                SELECT reading_id, COUNT(*) AS n FROM reading_post
                WHERE deleted_at IS NULL AND status = 'arrival'
                GROUP BY reading_id
                """
    }

    // MARK: - The Bookcase (13i-d U1 — the sitting record §7, §19–§24)

    /// A wing's live SHELVES in strip order — left to right, which is also
    /// All's top-to-bottom (§24). Author-scale; observation-safe.
    public static func shelves(_ db: Database, wingID: String) throws -> [Shelf] {
        try Shelf.fetchAll(
            db,
            sql: """
                SELECT * FROM shelf WHERE wing_id = ? AND deleted_at IS NULL
                ORDER BY position, id
                """,
            arguments: [wingID])
    }

    /// The Bookcase's held snapshot: one wing's shelves and books.
    public struct BookcaseSnapshot: Equatable, Sendable {
        public let shelves: [Shelf]
        public let books: [ShelfBook]

        public init(shelves: [Shelf], books: [ShelfBook]) {
            self.shelves = shelves
            self.books = books
        }
    }

    /// The held half of the Bookcase (tables: `shelf`, `reading`,
    /// `reading_post`, `reading_section` — none of which a keystroke writes).
    public static func bookcase(_ db: Database, wingID: String) throws -> BookcaseSnapshot {
        BookcaseSnapshot(
            shelves: try shelves(db, wingID: wingID),
            books: try bookshelf(db, wingID: wingID))
    }

    /// The Bookcase's ONE-SHOT aggregates (the `bookWordCounts` contract:
    /// fetched on appearance and after the board's own acts, never held —
    /// they read `container`, which autosave rewrites).
    public struct BookcaseAggregates: Equatable, Sendable {
        /// "LAST EDITED" per reading, DERIVED (the sitting record §22's
        /// mechanism note — *never a synced column on `reading`*: a
        /// per-keystroke book-row write would storm the outbox). Canonical
        /// ISO-8601 text, so the order is a string compare.
        public let lastEdited: [String: String]
        /// How many notes each GATHERING shows right now (its assembly's own
        /// size — hide-owned, cap and rule exactly as it renders).
        public let gatheringCounts: [String: Int]
        /// 13i-d U4 — HONEST COUNTS (her #169(a)(1)): each BOOK's ARCHIVED
        /// members (`archivedMemberCounts` — the one archived-member
        /// predicate, grouped); a book with none is absent. One-shot because
        /// it reads `container` (the header's P1 rule).
        public let archivedCounts: [String: Int]

        public init(
            lastEdited: [String: String], gatheringCounts: [String: Int],
            archivedCounts: [String: Int] = [:]
        ) {
            self.lastEdited = lastEdited
            self.gatheringCounts = gatheringCounts
            self.archivedCounts = archivedCounts
        }
    }

    /// One wing's aggregates. A BOOK's last edit is the latest of its live,
    /// un-archived MEMBERS' touch stamps (`COALESCE(last_touched_at,
    /// created_at)` — the Library's own stamp); a GATHERING's is the latest
    /// over the notes its assembly shows; a reading with no notes falls back
    /// to its own `created_at` (PROVISIONAL P-13id-U1-5), so a brand-new
    /// empty book sorts by its birth rather than last.
    ///
    /// Cost, said exactly (true since ladder A round 1's MINOR 2 — before it
    /// the member-stamp GROUP BY aggregated the whole store): one GROUP BY
    /// over the wing's book memberships, the wing's readings driving
    /// (`wingMemberStampsSQL` — each note a primary-key seek into
    /// `container`), plus one assembly per GATHERING (∝ that gathering's
    /// extent — the `bookWordCounts` smart arm's class, minus the text), plus
    /// (13i-d U4) the archived-member GROUP BY (the wing's books drive; the
    /// same seeks). Never per render; never held.
    public static func bookcaseAggregates(
        _ db: Database, wingID: String
    ) throws -> BookcaseAggregates {
        let readings = try bookcaseReadings(db, wingID: wingID)
        var lastEdited: [String: String] = [:]
        let memberRows = try Row.fetchAll(
            db, sql: wingMemberStampsSQL, arguments: [wingID])
        var memberStamps: [String: String] = [:]
        for row in memberRows {
            if let stamp: String = row["stamp"] { memberStamps[row["reading_id"]] = stamp }
        }
        var gatheringCounts: [String: Int] = [:]
        for reading in readings {
            var stamp: String?
            if reading.kind == .gathering {
                let ids = try assembleReading(db, readingID: reading.id).map(\.postID)
                gatheringCounts[reading.id] = ids.count
                if !ids.isEmpty {
                    let json = String(
                        decoding: (try? JSONEncoder().encode(ids)) ?? Data("[]".utf8),
                        as: UTF8.self)
                    stamp = try String.fetchOne(
                        db,
                        sql: """
                            SELECT MAX(COALESCE(c.last_touched_at, c.created_at))
                            FROM json_each(?) j CROSS JOIN container c ON c.id = j.value
                            """,
                        arguments: [json])
                }
            } else {
                stamp = memberStamps[reading.id]
            }
            lastEdited[reading.id] = stamp
                ?? DateFormatter.variorumISO8601.string(from: reading.createdAt)
        }
        return BookcaseAggregates(
            lastEdited: lastEdited, gatheringCounts: gatheringCounts,
            archivedCounts: try archivedMemberCounts(db, wingID: wingID))
    }

    /// The member-stamp half of `bookcaseAggregates` — one wing's book
    /// memberships, each note a primary-key seek, the wing's readings
    /// driving (`wingArchivedCountsSQL`'s shape; ladder A round 1, MINOR 2 —
    /// it aggregated the whole store's memberships under a "wing's" doc).
    /// One placeholder: the wing's id. Split out so a pin reads the shipped
    /// text.
    static let wingMemberStampsSQL = """
        SELECT rp.reading_id AS reading_id,
               MAX(COALESCE(c.last_touched_at, c.created_at)) AS stamp
        FROM reading r
        CROSS JOIN reading_post rp ON rp.reading_id = r.id
        JOIN container c
          ON c.id = rp.post_id AND c.deleted_at IS NULL AND c.archived_at IS NULL
        WHERE r.wing_id = ? AND r.deleted_at IS NULL
          AND rp.deleted_at IS NULL AND rp.status = 'member'
        GROUP BY rp.reading_id
        """

    /// Word counts of every book's rendered content — curated AND smart
    /// (Stage B review round 2, MAJOR 4 + MINOR skews). ONE-SHOT by
    /// contract (see header). Counting happens app-side with the SAME
    /// Unicode `.byWords` rule as the editor's `TextMetrics`, so the
    /// shelf's "62% of 10,000w" and the editor's counts agree on the same
    /// prose (the SQL space-arithmetic predecessor miscounted newlines and
    /// consecutive spaces — multi-paragraph blocks are I4's core case).
    /// ARCHIVED member posts are excluded, matching the reading assembly's
    /// ambient-view ratification (the book view doesn't show them; the
    /// shelf number must not count them).
    public static func bookWordCounts(_ db: Database) throws -> [String: Int] {
        var counts: [String: Int] = [:]
        // Curated memberships: one pass, rendered take per slot (the
        // chosen-with-default-fallback read-time rule in SQL).
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT rp.reading_id AS reading_id, v.working_text AS text
                FROM reading_post rp
                JOIN container c
                  ON c.id = rp.post_id AND c.deleted_at IS NULL AND c.archived_at IS NULL
                JOIN container_block cb
                  ON cb.container_id = rp.post_id AND cb.deleted_at IS NULL
                JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                JOIN variant v
                  ON v.id = COALESCE(
                       (SELECT id FROM variant chosen
                         WHERE chosen.id = cb.chosen_variant_id
                           AND chosen.block_id = cb.block_id
                           AND chosen.deleted_at IS NULL AND chosen.status = 'active'),
                       b.default_variant_id)
                 AND v.deleted_at IS NULL
                WHERE rp.deleted_at IS NULL AND rp.status = 'member'
                """)
        // 13i-e: an ARCHIVED reading is off the Bookcase, so it is off its
        // count too (R-13ie-1) — and an archived gathering assembles nothing
        // (R-13ie-3). Author-scale: the archived readings' ids, read once.
        let archived = Set(try String.fetchAll(
            db, sql: "SELECT id FROM reading WHERE archived_at IS NOT NULL"))
        for row in rows where !archived.contains(row["reading_id"]) {
            counts[row["reading_id"], default: 0] += wordCount(row["text"])
        }
        // Smart books: derived membership through the ONE shared predicate
        // (a word target on a smart book must show real progress — the
        // extent sheet offers it).
        var stars = StarContext()  // 13i-b U4: the ★ term's context (F-U3-3)
        for reading in try readings(db)
        where reading.kind == .gathering && reading.archivedAt == nil {
            // Malformed rules fail closed (skipped); NO rule counts NOTHING
            // (13i-c, R-13ic-4 — the match-all letter is retired).
            let term: RuleTerm
            switch RuleGrammar.read(reading.querySpec) {
            case .malformed, .none: continue
            case .rule(let t): term = t
            }
            let match = ruleMatchSQL(
                term, wingID: reading.wingId, starredNoteIDs: try stars.ids(db, for: term))
            let conditions = (["c.deleted_at IS NULL", "c.archived_at IS NULL",
                               "c.kind = 'post'"] + match.conditions)
                .joined(separator: " AND ")
            let texts = try String.fetchAll(
                db,
                sql: """
                    SELECT v.working_text FROM container c
                    JOIN container_block cb
                      ON cb.container_id = c.id AND cb.deleted_at IS NULL
                    JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                    JOIN variant v
                      ON v.id = COALESCE(
                           (SELECT id FROM variant chosen
                             WHERE chosen.id = cb.chosen_variant_id
                               AND chosen.block_id = cb.block_id
                               AND chosen.deleted_at IS NULL AND chosen.status = 'active'),
                           b.default_variant_id)
                     AND v.deleted_at IS NULL
                    WHERE \(conditions)
                    """,
                arguments: StatementArguments(match.arguments))
            counts[reading.id] = texts.reduce(0) { $0 + wordCount($1) }
        }
        // A CAP counts like the assembly renders (round 3 NIT): `max_posts`
        // LIMITs the book view read-side (the Phase 4 extent rule, both
        // kinds), so a capped book's shelf number counts EXACTLY the
        // capped, ordered set the reader sees — a capped smart book's
        // extra matches don't count, and neither do a curated book's
        // members beyond a cap LOWERED below its membership (#25(d)
        // legal). Capped books are rare; one assembly each, still
        // one-shot (#26(g)).
        for reading in try readings(db) where reading.maxPosts != nil && reading.archivedAt == nil {
            let capped = try assembleReading(db, readingID: reading.id)
            counts[reading.id] = try capped.reduce(0) { total, entry in
                total + (try renderPost(db, containerID: entry.postID)
                    .compactMap(\.text)
                    .reduce(0) { $0 + wordCount($1) })
            }
        }
        return counts
    }

    /// The one word-counting rule (Unicode `.byWords` — the editor's
    /// `TextMetrics` counts the same way; two surfaces, one answer).
    public static func wordCount(_ text: String) -> Int {
        var count = 0
        text.enumerateSubstrings(
            in: text.startIndex..., options: [.byWords, .substringNotRequired]
        ) { _, _, _, _ in count += 1 }
        return count
    }

    /// The shelf's TAGS column feed (R4/round-2: the shelf shows tags):
    /// per curated book, the most-applied live tag paths of its member
    /// posts (top `perBook`, frequency then path). Smart books show their
    /// own query tags — decoded app-side from the spec, not here.
    public static func shelfBookTags(
        _ db: Database, perBook: Int = 3
    ) throws -> [String: [String]] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT rp.reading_id AS reading_id, t.path AS path, COUNT(*) AS n
                FROM reading_post rp
                JOIN post_tag pt ON pt.post_id = rp.post_id AND pt.deleted_at IS NULL
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE rp.deleted_at IS NULL AND rp.status = 'member'
                GROUP BY rp.reading_id, t.path
                ORDER BY rp.reading_id, n DESC, t.path
                """)
        var result: [String: [String]] = [:]
        for row in rows {
            let readingID: String = row["reading_id"]
            if result[readingID, default: []].count < perBook {
                result[readingID, default: []].append(row["path"])
            }
        }
        return result
    }

    /// The POOL surface (R44/R29 — "an area for posts that do not belong
    /// to any book"; its purpose is driving floating posts INTO books):
    /// live, non-archived posts with NO live curated membership AND no
    /// live SMART book collecting them (Stage B review round 2, MAJOR 3:
    /// promote-tags-to-book must DRAIN the pool — R30's flagship gesture;
    /// derived membership counts as being in a book). Consequence,
    /// recorded (#26(h)): tag edits move posts in and out of the Pool —
    /// derived membership flaps by design. A malformed smart spec matches
    /// nothing (fail closed); an EMPTY spec matches everything (the
    /// ratified NULL-spec rule — such a book empties the Pool). Newest
    /// touched first; bounded like every held listing.

    ///
    /// 13i-b U4: the Pool's LOOSE class — `notePoolListing(window:).loose`, so the
    /// Mac's tuck face, the phone's listing and every pin read ONE split.
    public static func poolPosts(
        _ db: Database, limit: Int, wingID: String? = nil
    ) throws -> [TimelineItem] {
        try notePoolListing(db, window: limit, wingID: wingID).loose
    }

    /// **THE POOL, SPLIT** (13i-b U4 — the sitting record §8; lesson 10: "The
    /// Pool is every note with no book. Notes that show in gatherings tuck
    /// behind the count in its masthead — one click shows them.").
    ///
    /// The DEFINITION is untouched — the Pool is every live, unarchived note
    /// with no live MEMBER row (a gathering gives a note no home; an arrival
    /// is not membership). The VIEW splits it: `tucked` = the bookless notes
    /// some live gathering shows (by its rule, in its wing — the assembly's
    /// own predicate, the ★ context included); `loose` = the rest. Each class
    /// carries its EXACT size (never the window's) and its own window of rows,
    /// newest touched first.
    public struct PoolListing: Equatable, Sendable {
        public let loose: [TimelineItem]
        public let tucked: [TimelineItem]
        public let looseCount: Int
        public let tuckedCount: Int

        public init(
            loose: [TimelineItem], tucked: [TimelineItem], looseCount: Int, tuckedCount: Int
        ) {
            self.loose = loose
            self.tucked = tucked
            self.looseCount = looseCount
            self.tuckedCount = tuckedCount
        }
    }

    /// ONE statement (`notePoolListingSQL` — split out so the P1 pin reads the
    /// shipped statement): every bookless note is classified ONCE by the OR of
    /// the live gatherings' rules (`shown`), then window functions number and
    /// count each class, and at most `window` rows per class come back.
    ///
    /// A HOME is a live MEMBER row of a LIVE BOOK (13i-c U2 — 13i-b ladder
    /// F-R1-7, the three readers ruled together; the liveness clause joined
    /// at the 13i-c ladder, matching the two sibling readers): a sync-stray
    /// member row on a gathering — or under a TOMBSTONED book — never takes
    /// a note out of the Pool.
    ///
    /// Per-gathering letters, each the assembly's own: NO rule shows NOTHING
    /// (13i-c, R-13ic-4 — the match-all letter retired at U1; this line was
    /// stale until the ladder's sanity pass caught it), exactly as a
    /// MALFORMED rule does (fails closed — it tucks nothing); a rule's truth
    /// is COALESCEd to 0, so a legacy term over
    /// a NULL column (a profile/date term on a note without one) reads FALSE
    /// exactly as the assembly's WHERE reads it. *(Fixed with the split, red
    /// on the old read: the pre-U4 exclusion `NOT (<rule>)` went NULL there,
    /// which dropped the note from the Pool though no gathering showed it.)*
    ///
    /// **P1, said exactly:** one pass over the live notes (the container
    /// table's post rows — the class the Library's own sorted listing pays,
    /// never text), one indexed membership probe per note
    /// (`idx_reading_post_post`), then for each BOOKLESS note one rule probe
    /// per live gathering (a tag term is the shipped rule predicate's plan —
    /// the wing's live tags by `uq_tag_path_live`, each a `(tag, note)`
    /// application seek on `uq_post_tag_live`, so ∝ the taxonomy; a ★ term an
    /// `IN` over at most `Operations.starLimit` ids) — so cost ∝ notes +
    /// bookless × gatherings × terms × tags-in-wing, plus one sort of the
    /// bookless set; the result is ≤ 2 × `window` rows. Gatherings and tags
    /// are author-scale; nothing reads text. This is the shipped Pool's own class
    /// (it already ran every gathering's rule over every bookless note per
    /// tick); the split adds the tucked class's count, not a new dimension.
    /// `window` must be ≥ 1 (ladder F-R1-8): the per-class counts are read
    /// off the returned rows (`COUNT(*) OVER` rides each row), so a
    /// zero-row window would answer 0/0 for non-empty classes. No count-only
    /// caller exists; if one ever lands, it needs a row-independent
    /// aggregate, not `window: 0` (the `bookArrivals(limit: 0)` idiom does
    /// NOT transfer here).
    ///
    /// `wingID` (13i-d U5, additive — §9: the Pool is "every note with no
    /// book" IN THIS LIBRARY): one wing's bookless notes, tucked behind that
    /// wing's gatherings only; nil = every wing (byte-identical).
    public static func notePoolListing(
        _ db: Database, window: Int, wingID: String? = nil
    ) throws -> PoolListing {
        assert(window >= 1, "notePoolListing's counts ride its rows — window: 0 would lie (F-R1-8)")
        let statement = try notePoolListingSQL(db, wingID: wingID)
        let rows = try Row.fetchAll(
            db, sql: statement.sql,
            arguments: StatementArguments(statement.arguments + [window]))
        var loose: [TimelineItem] = []
        var tucked: [TimelineItem] = []
        var looseCount = 0
        var tuckedCount = 0
        for row in rows {
            let item = TimelineItem(
                postID: row["id"], title: row["title"],
                entryDate: row["entry_date"], createdAt: row["created_at"],
                stamp: row["stamp"], profile: row["profile"])
            if (row["shown"] as Int) == 1 {
                tucked.append(item)
                tuckedCount = row["n"]
            } else {
                loose.append(item)
                looseCount = row["n"]
            }
        }
        return PoolListing(
            loose: loose, tucked: tucked, looseCount: looseCount, tuckedCount: tuckedCount)
    }

    /// The statement behind `notePoolListing`. The LAST placeholder is the window.
    static func notePoolListingSQL(
        _ db: Database, wingID: String? = nil
    ) throws -> (sql: String, arguments: [(any DatabaseValueConvertible)?]) {
        var shownTerms: [String] = []
        var arguments: [(any DatabaseValueConvertible)?] = []
        var stars = StarContext()
        // 13i-e (R-13ie-3): an ARCHIVED gathering shows nothing, so it tucks
        // nothing — its notes re-class LOOSE (the assembly's own letter).
        for reading in try readings(db, wingID: wingID)
        where reading.kind == .gathering && reading.archivedAt == nil {
            let term: RuleTerm?
            switch RuleGrammar.read(reading.querySpec) {
            case .malformed, .none: continue  // shows nothing — tucks nothing (13i-c, R-13ic-4)
            case .rule(let t): term = t
            }
            let match = ruleMatchSQL(
                term, wingID: reading.wingId, starredNoteIDs: try stars.ids(db, for: term))
            shownTerms.append(
                "COALESCE((" + match.conditions.joined(separator: " AND ") + "), 0)")
            arguments += match.arguments
        }
        let shown = shownTerms.isEmpty ? "0" : "(" + shownTerms.joined(separator: " OR ") + ")"
        let scope = wingID.map { wingScope(column: "c.wing_id", wingID: $0) }
        let wingFence = scope.map { "\n                  AND \($0.sql)" } ?? ""
        arguments += scope?.arguments ?? []
        return ("""
            SELECT id, title, entry_date, created_at, profile, stamp, shown, n FROM (
              SELECT id, title, entry_date, created_at, profile, stamp, shown,
                     ROW_NUMBER() OVER (PARTITION BY shown ORDER BY stamp DESC, id DESC) AS rn,
                     COUNT(*) OVER (PARTITION BY shown) AS n
              FROM (
                SELECT c.id AS id, c.title AS title, c.entry_date AS entry_date,
                       c.created_at AS created_at, c.profile AS profile,
                       COALESCE(c.last_touched_at, c.created_at) AS stamp,
                       CASE WHEN \(shown) THEN 1 ELSE 0 END AS shown
                FROM container c
                WHERE c.kind = 'post' AND c.deleted_at IS NULL AND c.archived_at IS NULL\(wingFence)
                  AND NOT EXISTS (SELECT 1 FROM reading_post rp
                                   WHERE rp.post_id = c.id AND rp.deleted_at IS NULL
                                     AND rp.status = 'member'
                                     AND EXISTS (SELECT 1 FROM reading r
                                                  WHERE r.id = rp.reading_id
                                                    AND r.deleted_at IS NULL
                                                    AND r.kind = 'book'))
              )
            )
            WHERE rn <= ?
            ORDER BY shown, stamp DESC, id DESC
            """, arguments)
    }

    /// The books holding a post — the R35 membership chip's feed ("this
    /// post also appears in N books"): curated memberships (indexed via
    /// `idx_reading_post_post`) PLUS the smart books whose predicate
    /// collects the post (round 2, MAJOR 3 — one membership truth across
    /// the Pool and the chip). Archived posts match no smart book (the
    /// ambient-view rule); their curated rows still list (the recovery
    /// surfaces show where things belonged).
    public static func readingsContaining(_ db: Database, postID: String) throws -> [Reading] {
        var result = try Reading.fetchAll(
            db,
            sql: """
                SELECT r.* FROM reading r
                JOIN reading_post rp ON rp.reading_id = r.id AND rp.deleted_at IS NULL
                 AND rp.status = 'member'
                WHERE rp.post_id = ? AND r.deleted_at IS NULL
                  -- 13i-c U2 (F-R1-7): membership is a BOOK's row; a stray
                  -- member row on a gathering never lists it as a book.
                  AND r.kind = 'book'
                ORDER BY r.name, r.id
                """,
            arguments: [postID])
        // 13i-e: the BOOK leg above keeps an ARCHIVED book — membership is a
        // fact (P-13ie-U1-8; the faces mute it "(archived)"); the GATHERING
        // leg below skips an archived gathering — it shows nothing (R-13ie-3).
        var stars = StarContext()  // 13i-b U4: the ★ term's context (F-U3-3)
        for reading in try readings(db)
        where reading.kind == .gathering && reading.archivedAt == nil {
            // Malformed fails closed (skipped); NO rule matches NOTHING
            // (13i-c, R-13ic-4), so neither lists on the chip.
            let term: RuleTerm
            switch RuleGrammar.read(reading.querySpec) {
            case .malformed, .none: continue
            case .rule(let t): term = t
            }
            let match = ruleMatchSQL(
                term, wingID: reading.wingId, starredNoteIDs: try stars.ids(db, for: term))
            // 13i-c U2 — a gathering that HIDES owned notes never claims to
            // show one on the chip (the assembly's own exclusion, §6).
            let hide = try hidesOwned(db, reading) ? [ownedElsewhereExclusion(alias: "c")] : []
            let conditions = (["c.id = ?", "c.deleted_at IS NULL",
                               "c.archived_at IS NULL", "c.kind = 'post'"]
                              + match.conditions + hide).joined(separator: " AND ")
            let matches = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM container c WHERE \(conditions))",
                arguments: StatementArguments([postID] + match.arguments)) ?? false
            if matches { result.append(reading) }
        }
        return result.sorted { ($0.name, $0.id) < ($1.name, $1.id) }
    }

    /// **The SMART books collecting each of a PAGE of posts** (13k K4 — her
    /// ruling reversing the shipped #51(c) curated-only card: *"the number of
    /// specifically defined smart books you have is probably small, no? you
    /// still have to choose to deliberately create a smart book"*).
    ///
    /// `readingsContaining`'s per-post probe, generalised from ONE post to
    /// the rows already on screen — same predicate (`smartMatchSQL`, the one
    /// implementation the assembly, the Pool and the chip share), same
    /// ambient-view rule (an ARCHIVED post matches no smart book), same
    /// fail-closed handling of a malformed spec (skipped, never crash).
    ///
    /// ── WHY `CROSS JOIN`, AND WHY IT IS NOT A STYLE CHOICE ───────────────
    /// The obvious shape — `WHERE c.id IN (SELECT value FROM json_each(?))` —
    /// lets SQLite pick `idx_container_kind` as the driver and **scan every
    /// post in the corpus** for each book. Measured at the 13k K4 gate: 4×
    /// slower at 10× the corpus, i.e. cost ∝ corpus, which is exactly the P1
    /// violation the shipped curated-only comment was right to fear.
    /// `CROSS JOIN` is SQLite's own join-order directive: the PAGE drives and
    /// the container is a primary-key seek, so the work is ∝ (books × rows on
    /// screen) and FLAT in corpus — proven at 10× and pinned on the PLAN
    /// (`smartMembershipSQL` exists so the pin reads the real statement).
    ///
    /// Measured at the gate (200 reps, ms per page load, all books): a
    /// 200-row page costs 0.15 ms at one smart book and 4.15 ms at
    /// twenty-five, unchanged at 10× the corpus. It is a ONE-SHOT read per
    /// listing load — never per keystroke, never per scroll.
    ///
    /// Returns post id → the names of the smart books collecting it, in the
    /// readings listing's own `(name, id)` order.
    ///
    /// *Recorded corner:* a `tagsAll` spec costs one EXISTS probe per
    /// conjunct per row, so a four-tag AND book costs about four times a
    /// one-tag book. Still flat in corpus.
    public static func smartBookMembership(
        _ db: Database, postIDs: [String]
    ) throws -> [String: [String]] {
        guard !postIDs.isEmpty else { return [:] }
        let json = String(
            decoding: (try? JSONEncoder().encode(postIDs)) ?? Data("[]".utf8),
            as: UTF8.self)
        var result: [String: [String]] = [:]
        var stars = StarContext()  // 13i-b U4: the ★ term's context (F-U3-3)
        // 13i-e (R-13ie-3): an ARCHIVED gathering collects nothing — the
        // Library card never names it.
        for reading in try readings(db)
        where reading.kind == .gathering && reading.archivedAt == nil {
            let term: RuleTerm
            switch RuleGrammar.read(reading.querySpec) {
            case .malformed, .none: continue  // both show nothing (13i-c, R-13ic-4)
            case .rule(let t): term = t
            }
            let statement = smartMembershipSQL(
                term, wingID: reading.wingId, starredNoteIDs: try stars.ids(db, for: term),
                hidesOwned: try hidesOwned(db, reading))
            let ids = try String.fetchAll(
                db, sql: statement.sql,
                arguments: StatementArguments([json] + statement.arguments))
            for id in ids { result[id, default: []].append(reading.name) }
        }
        return result
    }

    /// The page-driven membership statement for ONE spec — split out so the
    /// P1 pin can run `EXPLAIN QUERY PLAN` over the REAL statement rather
    /// than a copy of it that could drift away from what ships. The first
    /// argument is always the page's ids as a JSON array.
    /// 13i-c U2: `hidesOwned` composes the hide-owned exclusion (§6) — a
    /// gathering that hides owned notes never lists one on a page.
    static func smartMembershipSQL(
        _ term: RuleTerm?, wingID: String, starredNoteIDs: [String],
        hidesOwned: Bool = false
    ) -> (sql: String, arguments: [(any DatabaseValueConvertible)?]) {
        let match = ruleMatchSQL(term, wingID: wingID, starredNoteIDs: starredNoteIDs)
        let hide = hidesOwned ? [ownedElsewhereExclusion(alias: "c")] : []
        let conditions = (["c.deleted_at IS NULL", "c.archived_at IS NULL",
                           "c.kind = 'post'"] + match.conditions + hide)
            .joined(separator: " AND ")
        return (
            """
            SELECT j.value AS post_id
            FROM json_each(?) j
            CROSS JOIN container c ON c.id = j.value AND \(conditions)
            """,
            match.arguments)
    }

    // MARK: - The catalog search (Library = EVERYTHING, R32; ⌘K's feed, R15)

    public struct CatalogHit: Equatable, Sendable {
        public enum Kind: Sendable, Hashable { case book, post, block }
        public let kind: Kind
        public let id: String
        /// What the hit is CALLED — for a post this is the display brain's
        /// answer since 13g batch 7 (title, else its date), never the raw
        /// column.
        public let title: String
        /// The raw stored title, for the one caller that must not confuse a
        /// DISPLAYED date with a name she typed: the rename door's seed
        /// (13g batch 7 — seeding "2026-08-01" would have her naming a note
        /// after itself). nil ⇒ the note has no stored name.
        public let storedTitle: String?
        public let detail: String?
        /// Block hits: the HOME container's id + kind — a block result must
        /// be able to NAVIGATE (round 2, MINOR: dead palette rows violated
        /// fire-and-speak on the legibility surface itself).
        public let homeContainerID: String?
        public let homeIsPool: Bool
        /// **The note's two TIME facts, as stored** (18h batch 1 — her row 9:
        /// *"I need to be able to see the created time and last edited time
        /// easily on the library"*). Canonical ISO-8601 text, carried raw —
        /// the words are `TimeStampFace`'s, asked per RENDERED row, so a
        /// listing pays for the rows it draws and nothing is stored anywhere
        /// new (the no-denormalization rule).
        ///
        /// `lastTouchedAt` is the shelf's own COALESCE — `last_touched_at`
        /// falling back to `created_at`, so a note nobody has typed in still
        /// reports a day rather than a blank (`Queries.noteStamps`' rule, one
        /// surface over). Both are nil for book and block hits, and
        /// nil-defaulted so every existing caller compiles unchanged.
        public let createdAt: String?
        public let lastTouchedAt: String?
        /// **The note's `container.profile`, raw** (13u3 UNIT B — item 4's
        /// journal split: *journal cards stay date-led, a daily entry's date
        /// IS its identity*). The DAILY MINT's own marker, carried rather
        /// than inferred: "has an `entry_date`" is a different fact and a
        /// note she merely dated is not a diary entry. nil for book and block
        /// hits, and nil-defaulted so every existing caller compiles
        /// unchanged.
        public let profile: String?

        public init(
            kind: Kind, id: String, title: String, detail: String?,
            storedTitle: String? = nil,
            homeContainerID: String? = nil, homeIsPool: Bool = false,
            createdAt: String? = nil, lastTouchedAt: String? = nil,
            profile: String? = nil
        ) {
            self.kind = kind
            self.id = id
            self.title = title
            self.storedTitle = storedTitle
            self.detail = detail
            self.homeContainerID = homeContainerID
            self.homeIsPool = homeIsPool
            self.createdAt = createdAt
            self.lastTouchedAt = lastTouchedAt
            self.profile = profile
        }

        /// Is this note a DAILY ENTRY? (`profile='journal'` — the mint's
        /// marker.) Said here, once, so no face spells the string.
        public var isJournalEntry: Bool { profile == Profile.journal.rawValue }
    }

    /// Title/name/handle search across books, posts, and blocks — "all
    /// books, posts, and blocks, like literally everything, sortable and
    /// searchable" (R32) and the ⌘K palette's result feed (R15). ONE-SHOT
    /// per typed query, bounded per kind; an empty query returns recent
    /// posts + all books (the palette's resting state). Block hits cover
    /// named blocks and pool scraps (first-line handle) — prose content
    /// search stays out of scope (FTS is not this phase's).
    ///
    /// **`sort`/`direction` order the NOTE arm** (18h batch 1 — her row 10:
    /// *"i need to be able to sort the library by time"*). A PARAMETER of
    /// this one query, never a second listing (review focus F-5): books stay
    /// by name and blocks by their own recency, because a book list that
    /// reshuffled with the note sort is not what a sort menu over the notes
    /// means. The default is byte-identical to what shipped —
    /// `COALESCE(last_touched_at, created_at) DESC, id DESC` — so every
    /// caller that says nothing gets the order it always got (the ⌘K palette
    /// and the phone's listing both do).
    ///
    /// P1, unchanged in class: the ORDER BY is a COALESCE expression exactly
    /// as before (and `.title`'s is too), so SQLite runs the same bounded
    /// top-N scan over the `container` table it already ran — cost ∝ the note
    /// count under `limitPerKind`, never corpus text size.
    ///
    /// **`editedOn` is THE DAY SEARCH** (18h batch 2 — her row 11: *"being
    /// able to search for any note edited on a particular day"*; ruling
    /// R-Q8). One more ARM of this same query, never a second listing
    /// (review focus F-5): a note answers for a day when its own last-edit
    /// stamp falls in the day's window, **or** when any savepoint on a take
    /// of a block it holds was written that day. The union is what makes the
    /// answer honest — see `Queries.editedOnClause` for why the store needs
    /// both halves. Books and blocks stand down while a day is set (they
    /// carry no edit stamp; a listing that answered "on Sep 9" with every
    /// book would be a lie by juxtaposition — the batch's call, QUESTIONS
    /// #104).
    /// **`limitPerKind: nil` is UNBOUNDED** (the ladder's R1-4) — the
    /// `Queries.library(limit:)` convention two screens down, same meaning.
    /// The cap is a top-N answer's honest shape ("the 40 most recently
    /// edited"), and it is the WRONG shape for a question whose answer is a
    /// SET: "which notes did I edit on Sep 8" silently returned the day's 40
    /// newest and said nothing about the rest. A day's own predicate bounds
    /// the read (cost ∝ the day's notes), so the caller lifts the cap there
    /// and keeps it everywhere else.
    ///
    /// **`wingID` scopes every arm to ONE wing** (13i-d U5, additive — §9:
    /// "search … scope by wing"): its books and gatherings, its notes, and the
    /// named blocks of its notes — while SNIPPET hits (blocks in a scraps
    /// container) list in every wing, because the scraps area is one shared
    /// room (PROVISIONAL P-13id-U5-4). nil = every wing, byte-identical.
    public static func searchCatalog(
        _ db: Database, query: String, limitPerKind: Int? = 20,
        sort: LibrarySort = .lastTouched, direction: SortDirection = .desc,
        editedOn: DayBounds? = nil, wingID: String? = nil
    ) throws -> [CatalogHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        // SQLite's own rule: a negative LIMIT is no limit.
        let limit = limitPerKind ?? -1
        var hits: [CatalogHit] = []
        // LIKE-escape the query — the catalog's ONE rule (`catalogLikeEscaped`).
        let like = "%\(catalogLikeEscaped(trimmed))%"

        let noteScope = wingID.map { wingScope(column: "wing_id", wingID: $0) }
        if editedOn == nil {
            hits += try catalogBooks(db, query: query, limit: limitPerKind, wingID: wingID)
        }

        let posts = try Row.fetchAll(
            db,
            sql: catalogPostsSQL(
                sort: sort, direction: direction, editedOn: editedOn,
                wingScope: noteScope?.sql),
            arguments: StatementArguments(
                [trimmed, like, like]
                    + (editedOn.map { [$0.start, $0.end, $0.start, $0.end] } ?? [])
                    + (noteScope?.arguments ?? [])
                    + [limit]))
        hits += posts.map {
            // 13g batch 7 (R6-3): the hit's name is the ONE display brain's
            // answer, computed eagerly rather than lazily like a listing's —
            // this row-set is BOUNDED BY WHAT THE QUERY RETURNED, which is
            // `limitPerKind` when the caller passes one and the DAY's own
            // notes when it does not (18h batch 2's ladder, R2-3: `nil` is
            // not a bound, and the sentence used to name only the cap).
            // Either way it is the answer's size, never the corpus's.
            CatalogHit(
                kind: .post, id: $0["id"],
                title: DisplayTitle.note(
                    title: $0["title"], entryDate: $0["entry_date"],
                    createdAt: $0["created_at"]),
                detail: $0["entry_date"],
                storedTitle: DisplayTitle.isAbsent($0["title"]) ? nil : $0["title"],
                createdAt: $0["created_at"],
                lastTouchedAt: $0["touched_at"],
                profile: $0["profile"])
        }

        // Blocks: named blocks anywhere + pool scraps by first-line handle.
        if !trimmed.isEmpty, editedOn == nil {
            hits += try catalogBlocks(db, query: query, limit: limitPerKind, wingID: wingID)
        }
        return hits
    }

    /// **The catalog's BOOK arm** — its books and gatherings by name, in one
    /// wing, archived ones out (they live under Archived). Factored out of
    /// `searchCatalog` byte-for-byte (17y B1 (k)) so the Library can ask for
    /// EVERY book of a wing (`limit: nil`) while it pages its notes; the
    /// palette and the phone keep asking `searchCatalog` exactly as before.
    public static func catalogBooks(
        _ db: Database, query: String, limit: Int?, wingID: String? = nil
    ) throws -> [CatalogHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let like = "%\(catalogLikeEscaped(trimmed))%"
        let readingScope = wingID.map { wingScope(column: "wing_id", wingID: $0) }
        // 13i-e (the plan's edge, PROVISIONAL P-13ie-U1-9): an ARCHIVED
        // book leaves the catalog exactly as an archived note always has
        // (the note arm's `archived_at IS NULL`) — it lives under Archived.
        let books = try Row.fetchAll(
            db,
            sql: """
                SELECT id, name, kind, locked, sealed_at FROM reading
                WHERE deleted_at IS NULL AND archived_at IS NULL
                  AND (? = '' OR name LIKE ? ESCAPE '\\')\(
                    readingScope.map { " AND \($0.sql)" } ?? "")
                ORDER BY name LIMIT ?
                """,
            arguments: StatementArguments(
                [trimmed, like] + (readingScope?.arguments ?? []) + [limit ?? -1]))
        return books.map(catalogBookHit)
    }

    /// One book row as the catalog names it — factored at 13o U2 so the
    /// search state's book rows wear the same words.
    static func catalogBookHit(_ row: Row) -> CatalogHit {
        CatalogHit(
            kind: .book, id: row["id"], title: row["name"],
            // 13i-d U6 (a): the ruled nouns (the sitting record §1 —
            // "smart" retired app-wide, §14): a GATHERING is never a
            // book, and a SEALED book says so (Finished = the table of
            // contents is done; Sealed = the book is done, §5).
            detail: (row["kind"] as String) == "gathering" ? "gathering"
                : ((row["sealed_at"] as String?) != nil ? "sealed book"
                   : ((row["locked"] as Int) == 1 ? "finished book" : "book")))
    }

    /// **The catalog's book rows for named books** (13o U2 — the search
    /// state's Books section: the books a book or chapter hit names), in the
    /// order given, the dead ones dropped. Bounded by the ids.
    public static func catalogBookHits(_ db: Database, ids: [String]) throws -> [CatalogHit] {
        guard !ids.isEmpty else { return [] }
        let json = String(decoding: try JSONEncoder().encode(ids), as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT r.id, r.name, r.kind, r.locked, r.sealed_at
                FROM json_each(?) j CROSS JOIN reading r ON r.id = j.value AND r.deleted_at IS NULL
                ORDER BY j.key
                """,
            arguments: [json])
        return rows.map(catalogBookHit)
    }

    /// **The catalog's BLOCK arm** — named blocks anywhere and scraps by their
    /// first line, for a TYPED query only. Factored out of `searchCatalog`
    /// byte-for-byte (17y B1 (k)); an empty query names no block.
    public static func catalogBlocks(
        _ db: Database, query: String, limit: Int?, wingID: String? = nil
    ) throws -> [CatalogHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let like = "%\(catalogLikeEscaped(trimmed))%"
        let blockScope = wingID.map { wingScope(column: "c.wing_id", wingID: $0) }
        let blocks = try Row.fetchAll(
            db,
            sql: """
                SELECT b.id AS id,
                       COALESCE(b.name, SUBSTR(v.working_text, 1, 80)) AS handle,
                       c.title AS home, c.id AS home_id, c.kind AS home_kind
                FROM block b
                JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
                JOIN container c ON c.id = cb.container_id AND c.deleted_at IS NULL
                 AND c.archived_at IS NULL
                LEFT JOIN variant v ON v.id = b.default_variant_id AND v.deleted_at IS NULL
                WHERE b.deleted_at IS NULL
                  AND (b.name LIKE ? ESCAPE '\\'
                       OR (c.kind = 'pool' AND v.working_text LIKE ? ESCAPE '\\'))\(
                    blockScope.map { " AND (c.kind = 'pool' OR \($0.sql))" } ?? "")
                ORDER BY b.updated_at DESC LIMIT ?
                """,
            arguments: StatementArguments(
                [like, like] + (blockScope?.arguments ?? []) + [limit ?? -1]))
        return blocks.map {
            CatalogHit(
                kind: .block, id: $0["id"], title: $0["handle"] ?? "block",
                detail: $0["home"],
                homeContainerID: $0["home_id"],
                homeIsPool: ($0["home_kind"] as String) == "pool")
        }
    }

    /// The catalog's ONE LIKE-escape (round 2 NIT: `_` is a single-char
    /// wildcard too; escape the escape first, then both wildcards).
    static func catalogLikeEscaped(_ trimmed: String) -> String {
        trimmed
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
    }

    /// The catalog's NOTE arm, as SQL — one string, built in one place, so
    /// the shipped statement is the statement `EXPLAIN QUERY PLAN` is asked
    /// about in the pin (`LibraryDaySearchTests.theDaySearchIsOneBoundedStatement`).
    /// A pin that re-typed the query would be pinning a copy, which is the
    /// drift class this whole file's shape is against.
    ///
    /// Placeholders, in order: the trimmed query (3×), then — only when a day
    /// is set — `start, end, start, end`, then the limit.
    /// 13i-d U5: `wingScope` (a `Queries.wingScope` fragment over the bare
    /// `wing_id` column, its arguments bound after the day's) narrows the arm
    /// to one wing; nil is byte-identical to the shipped statement.
    static func catalogPostsSQL(
        sort: LibrarySort, direction: SortDirection, editedOn: DayBounds?,
        wingScope: String? = nil
    ) -> String {
        let dir = direction == .desc ? "DESC" : "ASC"
        let day = editedOn == nil ? "" : "\n  AND \(editedOnClause)"
        let wing = wingScope.map { "\n  AND \($0)" } ?? ""
        return """
            SELECT id, title, entry_date, created_at, profile,
                   COALESCE(last_touched_at, created_at) AS touched_at
            FROM container
            WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL
              AND (? = '' OR COALESCE(title, '') LIKE ? ESCAPE '\\' OR COALESCE(entry_date, '') LIKE ? ESCAPE '\\')\(day)\(wing)
            ORDER BY \(sort.expression) \(dir), id \(dir)
            LIMIT ?
            """
    }

    /// **"EDITED ON THIS DAY", THE UNION** (18h batch 2, her row 11).
    ///
    /// Two readings of one question, OR'd, because the store holds exactly
    /// one edit stamp per note — AppSpec §10's own design, *coarse, not
    /// forensic*. So:
    ///
    /// 1. **The last-edit stamp.** `COALESCE(last_touched_at, created_at)` —
    ///    the SAME expression the row's own stamp displays (and the
    ///    `.lastTouched` sort orders by), so the filter can never disagree
    ///    with the words beside it: a row reading *edited today* is always
    ///    found by today.
    /// 2. **A savepoint written that day** on a take of a block this note
    ///    holds. Since Phase 13j one lands per changed take when she leaves a
    ///    note (`closeAutoCommit`), with the 2-hour idle timer as backstop —
    ///    so the days a note was edited BEFORE its last one are exactly the
    ///    days its savepoints remember, from 13j's date onward.
    ///
    /// The honest caveat rides the face (`LibraryDayFace.emptyAnswer`): a
    /// note edited Monday and again Tuesday answers for Tuesday by its stamp,
    /// and for Monday only if a savepoint landed then. Storing a per-day edit
    /// log would answer it exactly and is forbidden by definition (that is
    /// the forensic tracking CoreDescription rules out) — so the product
    /// SAYS what it knows instead of pretending.
    ///
    /// The placement join is LIVE (`cb.deleted_at IS NULL`): the note's
    /// blocks are the ones it holds now (I2's live-unique ownership), never a
    /// released pointer that would attribute another note's block here. The
    /// variant is deliberately NOT filtered — a take she later deleted still
    /// spent that day being written, and its block is still this note's.
    ///
    /// ── WHY THE SECOND HALF IS UNCORRELATED (the ladder's R1-1, a P1
    ///    BLOCKER on the first shipped shape) ─────────────────────────────
    ///
    /// It was written as `OR EXISTS (… AND cb.container_id = container.id …)`.
    /// SQLite short-circuits `OR`, so that subquery ran for **every note
    /// whose own stamp missed the day** — which is every note in the store
    /// whenever she asks about a past day, the feature's ordinary use — at
    /// that note's blocks × takes. Measured on the shipped statement (VM
    /// steps, 300 notes × 2 takes × 2 savepoints, a day matching nothing):
    /// **18,016 → 206,116 → 998,116** for 1 → 20 → 100 blocks per note. The
    /// `LIMIT 40` cannot stop it: the `ORDER BY` is a `COALESCE`, so the plan
    /// carries `USE TEMP B-TREE FOR ORDER BY` and every row's `WHERE` is
    /// evaluated first. That is P1's forbidden shape — cost ∝ the corpus — on
    /// a query `search()` spawns per keystroke.
    ///
    /// Turned around, the question is the cheap one: *which notes do the
    /// DAY's savepoints belong to*. The set is the same set (the correlation
    /// became the subquery's projection), the driver is `idx_commit_created`
    /// (migration v1_17, its own commit), and the measurement is **FLAT at
    /// 6,636 steps** across 1 → 100 blocks per note — below the 7,078 the
    /// same query costs on a day that matches every note. The day filter
    /// stops being a cost at all.
    ///
    /// The index alone would NOT have fixed the correlated form: this repo
    /// never runs `ANALYZE`, so with no `sqlite_stat1` the planner keeps the
    /// correlated order and the counts are identical to the byte with and
    /// without it (that is why the first measurement and its adjudication saw
    /// nothing). Pinned both ways —
    /// `theSavepointArmIsDrivenByTheDaysOwnSavepoints` (the plan) and
    /// `theDaySearchsWorkTracksTheDaysSavepointsNotTheCorpusBlocks` (the
    /// steps).
    static let editedOnClause = editedOnSQL(alias: nil)

    /// The ONE "edited in this window" rule, over a container named `alias`
    /// (13o U1 — the search composer's day-RANGE filter reads it through
    /// `SearchComposer.Environment`, so the rule ships once). `nil` is the
    /// shipped unqualified statement, byte for byte (`editedOnClause`).
    /// Placeholders, in order: start, end, start, end.
    static func editedOnSQL(alias: String?) -> String {
        let q = alias.map { "\($0)." } ?? ""
        return """
            (
                 (COALESCE(\(q)last_touched_at, \(q)created_at) >= ?
                  AND COALESCE(\(q)last_touched_at, \(q)created_at) < ?)
              OR \(q)id IN (
                   SELECT cb.container_id FROM commit_point cp
                   JOIN variant v ON v.id = cp.variant_id
                   JOIN container_block cb ON cb.block_id = v.block_id
                    AND cb.deleted_at IS NULL
                   WHERE cp.created_at >= ? AND cp.created_at < ?)
            )
            """
    }

    // MARK: - The note picker's feed (pre-13u Act 10, item 14)

    /// One row of the searchable note picker: enough context that five
    /// notes all displaying "2026-08-01" are tellable apart — the display
    /// title, the day, and a SNIPPET of the note's opening words, derived
    /// at read time from the first block's RENDERED take — `renderPost`'s own
    /// rule, shared as `renderedTakeJoinSQL` since 13u3 UNIT G, where this
    /// read was found resolving `b.default_variant_id` ALONE and so previewing
    /// the wrong take for every block whose take she had switched — and NEVER
    /// stored (the 13u item-4 display-NAME rule is deliberately not built
    /// here — titles stay as they are; the snippet is row context only).
    public struct NotePickerHit: Equatable, Sendable, Identifiable {
        public let id: String
        /// The display answer (`DisplayTitle.note` — title, else its day).
        public let title: String
        public let entryDate: String?
        /// When the note was last touched (canonical ISO-8601 text).
        public let touchedStamp: String
        /// The note's opening words (the first block's RENDERED take,
        /// capped) — nil when the note is empty.
        public let snippet: String?
    }

    /// Search-as-you-type over the corpus's NOTES — the one searchable
    /// note-picker component's feed (item 14: the "Mark as Versions with"
    /// door, the Pool's Add-to-Book sheet's sibling, and wave 2c's Compare
    /// "Choose a note…" all read this one query).
    ///
    /// Recent-first; contextual RANKING (version peers first where versions
    /// are the subject) is the caller's pure brain over these rows, never a
    /// second query shape. Bounded by `limit` like `searchCatalog` (whose
    /// LIKE grammar and escape discipline this reuses — the same cost class
    /// as the shipped ⌘K palette: a LIKE over the container table's title
    /// columns, with the snippet subquery running only for the LIMIT rows).
    /// An empty query returns the most recently touched notes (the resting
    /// state). Saved versions never list (they are archived by the V1
    /// classifier, and the archived fence below excludes them).
    ///
    /// `wingID` (13i-d U5, additive): the picker offers one wing's notes —
    /// the subject note's own library (§9); nil = every wing (byte-identical).
    public static func notePickerNotes(
        _ db: Database, query: String, excluding subjectID: String? = nil,
        limit: Int = 30, wingID: String? = nil
    ) throws -> [NotePickerHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let escaped = trimmed
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
        let like = "%\(escaped)%"
        // The bounded id set FIRST, the snippets SECOND (the ladder's F7):
        // SQLite computes a SELECT list's correlated subquery for every row
        // that passes WHERE before the sorter applies LIMIT, so the old
        // single statement paid one placement + variant seek per LIVE NOTE
        // per keystroke — corpus-shaped on a typing road. The CTE pins the
        // LIMIT to the scan (which stays a title/day substring walk, the
        // inherent cost of a substring search), and the snippet subquery
        // then runs for at most `limit` rows. `NotePickerShapeTests` pins
        // the VM-step difference flat in corpus size.
        return try Row.fetchAll(
            db,
            sql: """
                WITH hits AS (
                    SELECT c.id AS id, c.title AS title, c.entry_date AS entry_date,
                           c.created_at AS created_at,
                           COALESCE(c.last_touched_at, c.created_at) AS stamp
                    FROM container c
                    WHERE c.kind = 'post' AND c.deleted_at IS NULL AND c.archived_at IS NULL
                      AND (:query = ''
                           OR COALESCE(c.title, '') LIKE :like ESCAPE '\\'
                           OR COALESCE(c.entry_date, '') LIKE :like ESCAPE '\\')
                      AND (:subject IS NULL OR c.id <> :subject)
                      AND (:wing IS NULL OR c.wing_id = :wing
                           OR (:wing = '' AND c.wing_id NOT IN
                               (SELECT w.id FROM wing w WHERE w.deleted_at IS NULL)))
                    ORDER BY stamp DESC, c.id DESC
                    LIMIT :limit
                )
                SELECT h.id AS id, h.title AS title, h.entry_date AS entry_date,
                       h.created_at AS created_at, h.stamp AS stamp,
                       (SELECT SUBSTR(COALESCE(\(Queries.renderedTakeTextSQL), ''), 1, 160)
                          FROM container_block cb
                          JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                          \(Queries.renderedTakeJoinSQL)
                         WHERE cb.container_id = h.id AND cb.deleted_at IS NULL
                         ORDER BY cb.position, cb.id
                         LIMIT 1) AS snippet
                FROM hits h
                ORDER BY h.stamp DESC, h.id DESC
                """,
            arguments: [
                "query": trimmed, "like": like, "subject": subjectID, "limit": limit,
                "wing": wingID,
            ]
        ).map { row in
            let snippet = (row["snippet"] as String?)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return NotePickerHit(
                id: row["id"],
                title: DisplayTitle.note(
                    title: row["title"], entryDate: row["entry_date"],
                    createdAt: row["created_at"]),
                entryDate: row["entry_date"],
                touchedStamp: row["stamp"],
                snippet: (snippet?.isEmpty ?? true) ? nil : snippet)
        }
    }

    /// The same rows for NAMED notes (the Unmark door's version peers, and
    /// any caller holding ids that must render with the picker's context).
    /// Recent-first like its sibling; dead/archived ids simply don't row.
    public static func notePickerNotes(
        _ db: Database, ids: [String]
    ) throws -> [NotePickerHit] {
        guard !ids.isEmpty else { return [] }
        let marks = databaseQuestionMarks(count: ids.count)
        return try Row.fetchAll(
            db,
            sql: """
                SELECT c.id AS id, c.title AS title, c.entry_date AS entry_date,
                       c.created_at AS created_at,
                       COALESCE(c.last_touched_at, c.created_at) AS stamp,
                       (SELECT SUBSTR(COALESCE(\(Queries.renderedTakeTextSQL), ''), 1, 160)
                          FROM container_block cb
                          JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                          \(Queries.renderedTakeJoinSQL)
                         WHERE cb.container_id = c.id AND cb.deleted_at IS NULL
                         ORDER BY cb.position, cb.id
                         LIMIT 1) AS snippet
                FROM container c
                WHERE c.kind = 'post' AND c.deleted_at IS NULL AND c.archived_at IS NULL
                  AND c.id IN (\(marks))
                ORDER BY stamp DESC, c.id DESC
                """,
            arguments: StatementArguments(ids)
        ).map { row in
            let snippet = (row["snippet"] as String?)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return NotePickerHit(
                id: row["id"],
                title: DisplayTitle.note(
                    title: row["title"], entryDate: row["entry_date"],
                    createdAt: row["created_at"]),
                entryDate: row["entry_date"],
                touchedStamp: row["stamp"],
                snippet: (snippet?.isEmpty ?? true) ? nil : snippet)
        }
    }
}

private func countsByReading(
    _ db: Database, sql: String, arguments: StatementArguments = StatementArguments()
) throws -> [String: Int] {
    let rows = try Row.fetchAll(db, sql: sql, arguments: arguments)
    return Dictionary(uniqueKeysWithValues: rows.map {
        ($0["reading_id"] as String, $0["n"] as Int)
    })
}
