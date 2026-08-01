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

        public init(
            kind: Kind, id: String, title: String, detail: String?,
            storedTitle: String? = nil,
            homeContainerID: String? = nil, homeIsPool: Bool = false
        ) {
            self.kind = kind
            self.id = id
            self.title = title
            self.storedTitle = storedTitle
            self.detail = detail
            self.homeContainerID = homeContainerID
            self.homeIsPool = homeIsPool
        }
    }

    /// Title/name/handle search across books, posts, and blocks — "all
    /// books, posts, and blocks, like literally everything, sortable and
    /// searchable" (R32) and the ⌘K palette's result feed (R15). ONE-SHOT
    /// per typed query, bounded per kind; an empty query returns recent
    /// posts + all books (the palette's resting state). Block hits cover
    /// named blocks and pool scraps (first-line handle) — prose content
    /// search stays out of scope (FTS is not this phase's).
    public static func searchCatalog(
        _ db: Database, query: String, limitPerKind: Int = 20
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

        let posts = try Row.fetchAll(
            db,
            sql: """
                SELECT id, title, entry_date, created_at FROM container
                WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL
                  AND (? = '' OR COALESCE(title, '') LIKE ? ESCAPE '\\' OR COALESCE(entry_date, '') LIKE ? ESCAPE '\\')
                ORDER BY COALESCE(last_touched_at, created_at) DESC, id DESC
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
                storedTitle: DisplayTitle.isAbsent($0["title"]) ? nil : $0["title"])
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
}

private func countsByReading(_ db: Database, sql: String) throws -> [String: Int] {
    let rows = try Row.fetchAll(db, sql: sql)
    return Dictionary(uniqueKeysWithValues: rows.map {
        ($0["reading_id"] as String, $0["n"] as Int)
    })
}
