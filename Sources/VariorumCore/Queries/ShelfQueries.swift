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

        public init(reading: Reading, postCount: Int, sectionCount: Int) {
            self.reading = reading
            self.postCount = postCount
            self.sectionCount = sectionCount
        }
    }

    /// The live books with membership + chapter counts, by name — the
    /// shelf's observed listing (pin/journal ordering is the view model's
    /// presentation call over `shelfPins`).
    public static func bookshelf(_ db: Database) throws -> [ShelfBook] {
        let readings = try Queries.readings(db)
        guard !readings.isEmpty else { return [] }
        let postCounts = try countsByReading(
            db, sql: """
                SELECT reading_id, COUNT(*) AS n FROM reading_post
                WHERE deleted_at IS NULL GROUP BY reading_id
                """)
        let sectionCounts = try countsByReading(
            db, sql: """
                SELECT reading_id, COUNT(*) AS n FROM reading_section
                WHERE deleted_at IS NULL GROUP BY reading_id
                """)
        return readings.map { reading in
            ShelfBook(
                reading: reading,
                postCount: postCounts[reading.id] ?? 0,
                sectionCount: sectionCounts[reading.id] ?? 0)
        }
    }

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
                WHERE rp.deleted_at IS NULL
                """)
        for row in rows {
            counts[row["reading_id"], default: 0] += wordCount(row["text"])
        }
        // Smart books: derived membership through the ONE shared predicate
        // (a word target on a smart book must show real progress — the
        // extent sheet offers it).
        for reading in try readings(db) where reading.kind == .smart {
            guard let spec = decodeSpec(reading.querySpec) else { continue }
            let match = smartMatchSQL(spec)
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
        for reading in try readings(db) where reading.maxPosts != nil {
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
                WHERE rp.deleted_at IS NULL
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
    public static func poolPosts(_ db: Database, limit: Int) throws -> [TimelineItem] {
        var exclusions: [String] = ["""
            NOT EXISTS (SELECT 1 FROM reading_post rp
                         WHERE rp.post_id = c.id AND rp.deleted_at IS NULL)
            """]
        var arguments: [(any DatabaseValueConvertible)?] = []
        for reading in try readings(db) where reading.kind == .smart {
            guard let spec = decodeSpec(reading.querySpec) else { continue }
            let match = smartMatchSQL(spec)
            if match.conditions.isEmpty {
                // The empty spec matches every post — nothing is bookless.
                return []
            }
            exclusions.append("NOT (" + match.conditions.joined(separator: " AND ") + ")")
            arguments += match.arguments
        }
        return try Row.fetchAll(
            db,
            sql: """
                SELECT id, title, entry_date, created_at,
                       COALESCE(last_touched_at, created_at) AS stamp
                FROM container c
                WHERE c.kind = 'post' AND c.deleted_at IS NULL AND c.archived_at IS NULL
                  AND \(exclusions.joined(separator: " AND "))
                ORDER BY stamp DESC, id DESC
                LIMIT ?
                """,
            arguments: StatementArguments(arguments + [limit])
        ).map {
            TimelineItem(
                postID: $0["id"], title: $0["title"],
                entryDate: $0["entry_date"], createdAt: $0["created_at"],
                stamp: $0["stamp"])
        }
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
                WHERE rp.post_id = ? AND r.deleted_at IS NULL
                ORDER BY r.name, r.id
                """,
            arguments: [postID])
        for reading in try readings(db) where reading.kind == .smart {
            guard let spec = decodeSpec(reading.querySpec) else { continue }
            let match = smartMatchSQL(spec)
            let conditions = (["c.id = ?", "c.deleted_at IS NULL",
                               "c.archived_at IS NULL", "c.kind = 'post'"]
                              + match.conditions).joined(separator: " AND ")
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
        for reading in try readings(db) where reading.kind == .smart {
            guard let spec = decodeSpec(reading.querySpec) else { continue }
            let statement = smartMembershipSQL(spec)
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
    static func smartMembershipSQL(
        _ spec: SmartQuerySpec
    ) -> (sql: String, arguments: [(any DatabaseValueConvertible)?]) {
        let match = smartMatchSQL(spec)
        let conditions = (["c.deleted_at IS NULL", "c.archived_at IS NULL",
                           "c.kind = 'post'"] + match.conditions)
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
        public enum Kind: Sendable { case book, post, block }
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

        public init(
            kind: Kind, id: String, title: String, detail: String?,
            storedTitle: String? = nil,
            homeContainerID: String? = nil, homeIsPool: Bool = false,
            createdAt: String? = nil, lastTouchedAt: String? = nil
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
        }
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
    public static func searchCatalog(
        _ db: Database, query: String, limitPerKind: Int = 20,
        sort: LibrarySort = .lastTouched, direction: SortDirection = .desc
    ) throws -> [CatalogHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var hits: [CatalogHit] = []
        // LIKE-escape the query (round 2 NIT: `_` is a single-char
        // wildcard too; escape the escape first, then both wildcards).
        let escaped = trimmed
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
        let like = "%\(escaped)%"

        let books = try Row.fetchAll(
            db,
            sql: """
                SELECT id, name, kind, locked FROM reading
                WHERE deleted_at IS NULL AND (? = '' OR name LIKE ? ESCAPE '\\')
                ORDER BY name LIMIT ?
                """,
            arguments: [trimmed, like, limitPerKind])
        hits += books.map {
            CatalogHit(
                kind: .book, id: $0["id"], title: $0["name"],
                detail: ($0["kind"] as String) == "smart" ? "smart book"
                    : (($0["locked"] as Int) == 1 ? "finished book" : "book"))
        }

        let dir = direction == .desc ? "DESC" : "ASC"
        let posts = try Row.fetchAll(
            db,
            sql: """
                SELECT id, title, entry_date, created_at,
                       COALESCE(last_touched_at, created_at) AS touched_at
                FROM container
                WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL
                  AND (? = '' OR COALESCE(title, '') LIKE ? ESCAPE '\\' OR COALESCE(entry_date, '') LIKE ? ESCAPE '\\')
                ORDER BY \(sort.expression) \(dir), id \(dir)
                LIMIT ?
                """,
            arguments: [trimmed, like, like, limitPerKind])
        hits += posts.map {
            // 13g batch 7 (R6-3): the hit's name is the ONE display brain's
            // answer — this row-set is bounded by `limitPerKind`, so it is
            // computed eagerly rather than lazily like a listing's.
            CatalogHit(
                kind: .post, id: $0["id"],
                title: DisplayTitle.note(
                    title: $0["title"], entryDate: $0["entry_date"],
                    createdAt: $0["created_at"]),
                detail: $0["entry_date"],
                storedTitle: DisplayTitle.isAbsent($0["title"]) ? nil : $0["title"],
                createdAt: $0["created_at"],
                lastTouchedAt: $0["touched_at"])
        }

        // Blocks: named blocks anywhere + pool scraps by first-line handle.
        if !trimmed.isEmpty {
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
                           OR (c.kind = 'pool' AND v.working_text LIKE ? ESCAPE '\\'))
                    ORDER BY b.updated_at DESC LIMIT ?
                    """,
                arguments: [like, like, limitPerKind])
            hits += blocks.map {
                CatalogHit(
                    kind: .block, id: $0["id"], title: $0["handle"] ?? "block",
                    detail: $0["home"],
                    homeContainerID: $0["home_id"],
                    homeIsPool: ($0["home_kind"] as String) == "pool")
            }
        }
        return hits
    }

    // MARK: - The note picker's feed (pre-13u Act 10, item 14)

    /// One row of the searchable note picker: enough context that five
    /// notes all displaying "2026-08-01" are tellable apart — the display
    /// title, the day, and a SNIPPET of the note's opening words, derived
    /// at read time from the first block's representative take and NEVER
    /// stored (the 13u item-4 display-NAME rule is deliberately not built
    /// here — titles stay as they are; the snippet is row context only).
    public struct NotePickerHit: Equatable, Sendable, Identifiable {
        public let id: String
        /// The display answer (`DisplayTitle.note` — title, else its day).
        public let title: String
        public let entryDate: String?
        /// When the note was last touched (canonical ISO-8601 text).
        public let touchedStamp: String
        /// The note's opening words (the first block's default take,
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
    public static func notePickerNotes(
        _ db: Database, query: String, excluding subjectID: String? = nil,
        limit: Int = 30
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
                    ORDER BY stamp DESC, c.id DESC
                    LIMIT :limit
                )
                SELECT h.id AS id, h.title AS title, h.entry_date AS entry_date,
                       h.created_at AS created_at, h.stamp AS stamp,
                       (SELECT SUBSTR(COALESCE(v.working_text, ''), 1, 160)
                          FROM container_block cb
                          JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                          LEFT JOIN variant v
                            ON v.id = b.default_variant_id AND v.deleted_at IS NULL
                         WHERE cb.container_id = h.id AND cb.deleted_at IS NULL
                         ORDER BY cb.position, cb.id
                         LIMIT 1) AS snippet
                FROM hits h
                ORDER BY h.stamp DESC, h.id DESC
                """,
            arguments: [
                "query": trimmed, "like": like, "subject": subjectID, "limit": limit,
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
                       (SELECT SUBSTR(COALESCE(v.working_text, ''), 1, 160)
                          FROM container_block cb
                          JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                          LEFT JOIN variant v
                            ON v.id = b.default_variant_id AND v.deleted_at IS NULL
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

private func countsByReading(_ db: Database, sql: String) throws -> [String: Int] {
    let rows = try Row.fetchAll(db, sql: sql)
    return Dictionary(uniqueKeysWithValues: rows.map {
        ($0["reading_id"] as String, $0["n"] as Int)
    })
}
