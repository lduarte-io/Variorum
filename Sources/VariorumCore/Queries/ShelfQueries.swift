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

    /// Whitespace-word counts of every curated book's rendered content, in
    /// ONE pass over live memberships → live placements → rendered variants
    /// (chosen with the default fallback — the read-time rule in SQL, the
    /// `renderedLength` COALESCE shape). ONE-SHOT by contract (see header).
    /// Smart books are absent (their membership is a predicate, not rows —
    /// the view model may count a smart book on open if wanted).
    public static func bookWordCounts(_ db: Database) throws -> [String: Int] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT rp.reading_id AS reading_id,
                       SUM(LENGTH(TRIM(v.working_text))
                           - LENGTH(REPLACE(TRIM(v.working_text), ' ', ''))
                           + (LENGTH(TRIM(v.working_text)) > 0)) AS words
                FROM reading_post rp
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
                GROUP BY rp.reading_id
                """)
        return Dictionary(uniqueKeysWithValues: rows.map {
            ($0["reading_id"] as String, ($0["words"] as Int? ?? 0))
        })
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
    /// live, non-archived posts with NO live reading membership, newest
    /// touched first. Bounded like every held listing.
    public static func poolPosts(_ db: Database, limit: Int) throws -> [TimelineItem] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT id, title, entry_date,
                       COALESCE(last_touched_at, created_at) AS stamp
                FROM container c
                WHERE c.kind = 'post' AND c.deleted_at IS NULL AND c.archived_at IS NULL
                  AND NOT EXISTS (SELECT 1 FROM reading_post rp
                                   WHERE rp.post_id = c.id AND rp.deleted_at IS NULL)
                ORDER BY stamp DESC, id DESC
                LIMIT ?
                """,
            arguments: [limit]
        ).map {
            TimelineItem(
                postID: $0["id"], title: $0["title"],
                entryDate: $0["entry_date"], stamp: $0["stamp"])
        }
    }

    /// The books holding a post — the R35 membership chip's feed ("this
    /// post also appears in N books"). Indexed via `idx_reading_post_post`.
    public static func readingsContaining(_ db: Database, postID: String) throws -> [Reading] {
        try Reading.fetchAll(
            db,
            sql: """
                SELECT r.* FROM reading r
                JOIN reading_post rp ON rp.reading_id = r.id AND rp.deleted_at IS NULL
                WHERE rp.post_id = ? AND r.deleted_at IS NULL
                ORDER BY r.name, r.id
                """,
            arguments: [postID])
    }

    // MARK: - The catalog search (Library = EVERYTHING, R32; ⌘K's feed, R15)

    public struct CatalogHit: Equatable, Sendable {
        public enum Kind: Sendable { case book, post, block }
        public let kind: Kind
        public let id: String
        public let title: String
        public let detail: String?

        public init(kind: Kind, id: String, title: String, detail: String?) {
            self.kind = kind
            self.id = id
            self.title = title
            self.detail = detail
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
        let like = "%\(trimmed.replacingOccurrences(of: "%", with: ""))%"

        let books = try Row.fetchAll(
            db,
            sql: """
                SELECT id, name, kind, locked FROM reading
                WHERE deleted_at IS NULL AND (? = '' OR name LIKE ?)
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
                SELECT id, title, entry_date FROM container
                WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL
                  AND (? = '' OR COALESCE(title, '') LIKE ? OR COALESCE(entry_date, '') LIKE ?)
                ORDER BY COALESCE(last_touched_at, created_at) DESC, id DESC
                LIMIT ?
                """,
            arguments: [trimmed, like, like, limitPerKind])
        hits += posts.map {
            CatalogHit(
                kind: .post, id: $0["id"],
                title: ($0["title"] as String?)?.isEmpty == false
                    ? $0["title"]! : (($0["entry_date"] as String?) ?? "Untitled"),
                detail: $0["entry_date"])
        }

        // Blocks: named blocks anywhere + pool scraps by first-line handle.
        if !trimmed.isEmpty {
            let blocks = try Row.fetchAll(
                db,
                sql: """
                    SELECT b.id AS id,
                           COALESCE(b.name, SUBSTR(v.working_text, 1, 80)) AS handle,
                           c.title AS home
                    FROM block b
                    JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
                    JOIN container c ON c.id = cb.container_id AND c.deleted_at IS NULL
                    LEFT JOIN variant v ON v.id = b.default_variant_id AND v.deleted_at IS NULL
                    WHERE b.deleted_at IS NULL
                      AND (b.name LIKE ? OR (c.kind = 'pool' AND v.working_text LIKE ?))
                    ORDER BY b.updated_at DESC LIMIT ?
                    """,
                arguments: [like, like, limitPerKind])
            hits += blocks.map {
                CatalogHit(
                    kind: .block, id: $0["id"], title: $0["handle"] ?? "block",
                    detail: $0["home"])
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
