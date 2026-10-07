import Foundation

/// **THE ONE SEARCH COMPOSER** (Phase 13o, R-13o-8 — "no search SQL composed
/// outside the one Domain composer"). `SearchQuery` (the AST) + `SearchScope`
/// in, SQL text + positional arguments out. Pure: it never touches a
/// database, so every statement it builds is a value a pin can read
/// (`EXPLAIN QUERY PLAN` is asked about the SHIPPED text, the
/// `catalogPostsSQL` discipline).
///
/// The shape it composes (the §FORK RULINGS):
/// - the TEXT half drives — FTS5 `MATCH` over `search_fts` (F1: external
///   content over the source rows; F4: `unicode61 remove_diacritics 2`), every
///   user leaf quoted as an FTS5 string so the index's own tokenizer folds it
///   and no user text is ever FTS5 syntax;
/// - each match's HOME is resolved at query time through the I2 placement and
///   the container / reading rows (F3 — own-row facts only on the doc); the
///   wing scope (ALWAYS), the within-scope, the archived facet, the version
///   fence and the FILTER half are predicates over those rows;
/// - the ranking is `bm25 × the kind's weight × the rendered-take boost`
///   (F4: one column, kind weight at query time), keyset-paged on
///   `(score, doc id)` so every match is reachable (R-13o-9);
/// - snippets are computed for the PAGE rows only: a second walk of the
///   match's doclists (cheap — no ranking reads) joined to the page by rowid,
///   so `snippet()` runs for the ≤ `limit` rows that join. (Measured at U1:
///   a page-DRIVEN lookup — one FTS5 query per page row by rowid — costs a
///   full FTS5 query initialization per row, every segment opened each time:
///   660–790 page requests for a 20-row page against 160–190 for one walk.)
///
/// The fragments whose rules live elsewhere — the version classifier, the
/// wing rule, the edited-in-a-window rule, the starred list — come in through
/// `Environment` from their one home, never as a copy here.
public enum SearchComposer {
    /// A text the index cannot serve.
    public enum Refusal: Error, Equatable, Sendable {
        /// Every leaf is negated — FTS5 cannot enumerate "everything except".
        case negativeOnlyText
    }

    /// One positional SQL argument (Domain stays free of GRDB's types).
    public enum Value: Equatable, Sendable {
        case text(String)
        case integer(Int64)
        case real(Double)
    }

    /// A composed statement: SQL with `?` placeholders, and their values in
    /// order.
    public struct Statement: Equatable, Sendable {
        public let sql: String
        public let arguments: [Value]
    }

    /// Where the page resumes: the last row's `(score, doc id)`.
    public struct Cursor: Equatable, Sendable {
        public let score: Double
        public let docID: Int64
        public init(score: Double, docID: Int64) {
            self.score = score
            self.docID = docID
        }
    }

    /// The shared fragments, read from their one home by the caller
    /// (`Queries.searchPassages`).
    public struct Environment: Sendable {
        /// The saved-version classifier over a container alias (no
        /// placeholders) — `Queries.versionHistoryPredicate`.
        public var versionPredicate: @Sendable (_ alias: String) -> String
        /// The wing rule over a column expression — `Queries.wingScope`.
        public var wingScope: @Sendable (_ column: String, _ wingID: String) -> (sql: String, arguments: [Value])
        /// "Edited in [start, end)" over a container alias, four placeholders
        /// (start, end, start, end) — `Queries.editedOnSQL`.
        public var editedOn: @Sendable (_ alias: String) -> String
        /// The starred notes (the star list is a bounded setting).
        public var starredNoteIDs: [String]
        /// "A LIVING book" over a reading alias, no placeholders — intake's
        /// own candidate predicate (`Queries.livingBookSQL`, 13o U3).
        public var livingBook: @Sendable (_ alias: String) -> String

        public init(
            versionPredicate: @escaping @Sendable (String) -> String,
            wingScope: @escaping @Sendable (String, String) -> (sql: String, arguments: [Value]),
            editedOn: @escaping @Sendable (String) -> String,
            starredNoteIDs: [String],
            livingBook: @escaping @Sendable (String) -> String = { _ in "0" }
        ) {
            self.versionPredicate = versionPredicate
            self.wingScope = wingScope
            self.editedOn = editedOn
            self.starredNoteIDs = starredNoteIDs
            self.livingBook = livingBook
        }
    }

    // MARK: - Ranking (PROVISIONAL weights — P-13o-U1-6)

    /// A kind's bm25 multiplier (bm25 is negative: a larger multiplier ranks
    /// higher). Names outrank prose; prose outranks margins.
    static let kindWeights: [(kind: String, weight: Double)] = [
        ("title", 3.0), ("book", 3.0), ("chapter", 2.5), ("block_name", 2.0),
        ("take_label", 1.5), ("take", 1.0), ("comment", 0.8), ("note_meta", 0.8),
    ]
    /// The rendered take's boost over the block's other takes.
    static let renderedBoost = 1.25

    // MARK: - The text half → an FTS5 MATCH expression

    /// The AST's text half as an FTS5 query; nil when nothing in it can match
    /// a token (every leaf is punctuation — "—", "#"). Throws when only
    /// negations remain.
    public static func ftsMatch(_ text: SearchText) throws -> String? {
        switch text {
        case .word(let word), .phrase(let word):
            return hasTokenCharacter(word) ? quoted(word) : nil
        case .prefix(let word):
            return hasTokenCharacter(word) ? quoted(word) + " *" : nil
        case .any(let children):
            let parts = try children.compactMap { try ftsMatch($0) }
            guard !parts.isEmpty else { return nil }
            return parts.count == 1 ? parts[0] : "(" + parts.joined(separator: " OR ") + ")"
        case .all(let children):
            var positives: [String] = []
            var negatives: [String] = []
            for child in children {
                if case .not(let inner) = child {
                    if let part = try ftsMatch(inner) { negatives.append(part) }
                } else if let part = try ftsMatch(child) {
                    positives.append(part)
                }
            }
            guard !positives.isEmpty else {
                if negatives.isEmpty { return nil }
                throw Refusal.negativeOnlyText
            }
            var expression = positives.count == 1 ? positives[0]
                : "(" + positives.joined(separator: " AND ") + ")"
            for negative in negatives { expression = "(" + expression + " NOT " + negative + ")" }
            return expression
        case .not(let inner):
            guard try ftsMatch(inner) != nil else { return nil }
            throw Refusal.negativeOnlyText
        }
    }

    /// An FTS5 string literal: double quotes, inner quotes doubled.
    static func quoted(_ s: String) -> String {
        "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    /// Does the word hold at least one character `unicode61` keeps as a TOKEN
    /// character (anything that is not whitespace, punctuation or a control /
    /// format code — its default separator classes)? A word of separators only
    /// would be an FTS5 phrase with no tokens.
    static func hasTokenCharacter(_ word: String) -> Bool {
        word.unicodeScalars.contains { scalar in
            switch scalar.properties.generalCategory {
            case .spaceSeparator, .lineSeparator, .paragraphSeparator,
                 .connectorPunctuation, .dashPunctuation, .openPunctuation, .closePunctuation,
                 .initialPunctuation, .finalPunctuation, .otherPunctuation,
                 .control, .format, .unassigned, .surrogate:
                return false
            default:
                return true
            }
        }
    }

    // MARK: - The passage page

    /// The page statement: matches → their homes → scope / facet / filter →
    /// ranked → keyset page → snippets for the page rows. nil when the text
    /// half cannot match anything (the caller returns no passages).
    ///
    /// Result columns: doc_id, kind, src_id, block_id, reading_id, home_id,
    /// home_kind, home_title, home_entry_date, home_created_at, reading_name,
    /// reading_kind, archived, rendered, score, snippet.
    public static func passages(
        _ query: SearchQuery, scope: SearchScope, after cursor: Cursor?, limit: Int,
        environment: Environment
    ) throws -> Statement? {
        guard let hits = try hits(query, scope: scope, visibility: query.visibility, environment: environment)
        else { return nil }
        var arguments = hits.arguments
        var keyset = ""
        if cursor != nil {
            keyset = "WHERE (s.score > ? OR (s.score = ? AND s.doc_id > ?))"
        }
        let sql = """
            WITH hits AS (\(hits.sql)),
            scored AS (
              SELECT h.*, \(scoreSQL) AS score
              FROM hits h
            ),
            page AS (
              SELECT s.* FROM scored s
              \(keyset)
              ORDER BY s.score, s.doc_id
              LIMIT ?
            )
            SELECT page.*, snippet(search_fts, 0, char(2), char(3), '…', 16) AS snippet
            FROM search_fts JOIN page ON page.doc_id = search_fts.rowid
            WHERE search_fts MATCH ?
            ORDER BY page.score, page.doc_id
            """
        if let cursor {
            arguments += [.real(cursor.score), .real(cursor.score), .integer(cursor.docID)]
        }
        arguments += [.integer(Int64(limit)), .text(hits.match)]
        return Statement(sql: sql, arguments: arguments)
    }

    /// The score of a hit row `h` — `bm25 × the kind's weight × the
    /// rendered-take boost` (lower is better; bm25 is negative).
    static var scoreSQL: String {
        let weight = "CASE h.kind "
            + kindWeights.map { "WHEN '\($0.kind)' THEN \($0.weight)" }.joined(separator: " ")
            + " ELSE 1.0 END"
        return "h.bm * (\(weight)) * (CASE WHEN h.rendered THEN \(renderedBoost) ELSE 1.0 END)"
    }

    /// **The HITS** — every matching doc with its home's facts, scoped,
    /// faceted and filtered — as ONE CTE body that every statement over the
    /// matches composes on (the passage page, the group page, the counts),
    /// so no two of them can disagree about what a hit is (13o U2).
    struct Hits {
        /// The CTE body (`SELECT … FROM search_fts … WHERE search_fts MATCH ? …`).
        let sql: String
        /// Its placeholders, in order — the MATCH first.
        let arguments: [Value]
        /// The FTS5 expression (a snippet stage re-binds it).
        let match: String
    }

    /// The hits body; nil when the text half cannot match anything. `extra`
    /// conditions (over `d`, `c`, `b`, `r`) join the scope's, last.
    ///
    /// Result columns: doc_id, kind, src_id, block_id, reading_id, home_id,
    /// home_kind, home_title, home_entry_date, home_created_at, reading_name,
    /// reading_kind, archived, rendered, bm.
    static func hits(
        _ query: SearchQuery, scope: SearchScope, visibility: SearchVisibility,
        extra: [String] = [], environment: Environment
    ) throws -> Hits? {
        guard let text = query.text, let match = try ftsMatch(text) else { return nil }
        var arguments: [Value] = [.text(match)]
        var conditions: [String] = ["(c.id IS NOT NULL OR r.id IS NOT NULL)"]

        // The WING, always (the 13i sitting record §12) — a book's own wing
        // for book/chapter docs, the home container's otherwise. Scraps (a
        // pool home) list in every wing: the scraps area is one shared room
        // (the shipped catalog's P-13id-U5-4, kept — P-13o-U1-5).
        let wing = environment.wingScope("COALESCE(r.wing_id, c.wing_id)", scope.wingID)
        conditions.append("(c.kind = 'pool' OR \(wing.sql))")
        arguments += wing.arguments

        switch scope.within {
        case .library:
            break
        case .note(let id):
            conditions.append("c.id = ?")
            arguments.append(.text(id))
        case .book(let id):
            conditions.append("""
                (c.id IN (SELECT rp.post_id FROM reading_post rp
                           WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member')
                 OR d.reading_id = ?)
                """)
            arguments += [.text(id), .text(id)]
        }

        let archived = """
            (d.archived = 1 OR c.archived_at IS NOT NULL OR b.archived_at IS NOT NULL
             OR (d.kind = 'chapter' AND r.archived_at IS NOT NULL))
            """
        switch visibility {
        case .living:
            conditions.append("NOT \(archived)")
        case .includingArchived:
            conditions.append("(c.id IS NULL OR NOT (\(environment.versionPredicate("c"))))")
        case .archivedOnly:
            conditions.append(archived)
            conditions.append("(c.id IS NULL OR NOT (\(environment.versionPredicate("c"))))")
        }

        if let filter = query.filter {
            let composed = composeFilter(filter, level: .passage, wingID: scope.wingID, environment: environment)
            conditions.append(composed.sql)
            arguments += composed.arguments
        }
        conditions += extra

        // The rendered take: `PostRender`'s rule (chosen while it renders —
        // live, active, this block's — else the block's default), decided
        // from the doc's OWN facts wherever they suffice; one seek only for a
        // default take whose block points at ANOTHER take.
        let rendered = """
            CASE
              WHEN d.kind <> 'take' THEN 0
              WHEN pl.chosen_variant_id = d.src_id AND d.archived = 0 THEN 1
              WHEN b.default_variant_id IS NOT d.src_id THEN 0
              WHEN pl.chosen_variant_id IS NULL OR pl.chosen_variant_id = d.src_id THEN 1
              ELSE NOT EXISTS (SELECT 1 FROM variant ch
                                WHERE ch.id = pl.chosen_variant_id AND ch.block_id = d.block_id
                                  AND ch.deleted_at IS NULL AND ch.status = 'active')
            END
            """
        // Leading and trailing newline: the body sits inside `WITH hits AS (…)`
        // exactly where the shipped page statement wrote it.
        let sql = """

              SELECT d.id AS doc_id, d.kind AS kind, d.src_id AS src_id, d.block_id AS block_id,
                     d.reading_id AS reading_id, c.id AS home_id, c.kind AS home_kind,
                     c.title AS home_title, c.entry_date AS home_entry_date,
                     c.created_at AS home_created_at, r.name AS reading_name, r.kind AS reading_kind,
                     \(archived) AS archived,
                     \(rendered) AS rendered,
                     bm25(search_fts) AS bm
              FROM search_fts
              JOIN search_doc d ON d.id = search_fts.rowid
              LEFT JOIN container_block pl ON pl.block_id = d.block_id AND pl.deleted_at IS NULL
              LEFT JOIN container c ON c.id = COALESCE(d.container_id, pl.container_id) AND c.deleted_at IS NULL
              LEFT JOIN block b ON b.id = d.block_id AND b.deleted_at IS NULL
              LEFT JOIN reading r ON r.id = d.reading_id AND r.deleted_at IS NULL
              WHERE search_fts MATCH ?
                AND \(conditions.joined(separator: "\n    AND "))

            """
        return Hits(sql: sql, arguments: arguments, match: match)
    }

    // MARK: - The group page (13o U2 — Direction C's answer sheet, R-13o-15)

    /// Where a GROUP page resumes: the last group's `(best score, home id)`.
    public struct GroupCursor: Equatable, Sendable {
        public let best: Double
        public let homeID: String
        public init(best: Double, homeID: String) {
            self.best = best
            self.homeID = homeID
        }
    }

    /// **The answer sheet's page** — the matches GROUPED by their home (a
    /// note, or a scraps group), the groups ranked by their BEST hit and
    /// keyset-paged on `(best, home id)`, each carrying its top `perGroup`
    /// hits with their snippets (a title hit ranks last inside its group —
    /// the group's head already says the title). Book and chapter hits are
    /// not groups (the Books section reads them as passages). Every group is
    /// reachable by paging; every hit of a group is reachable through
    /// `passages` scoped `.note(home)` — "all N ›" (R-13o-9).
    ///
    /// P1: ONE walk of the matches ranks and groups them (the scored CTE is
    /// materialized and read twice), and snippets are cut for the page's top
    /// rows only — the passage page's own shape, one level up.
    ///
    /// Result columns: the hits' columns, score, g_best, g_hits (every hit of
    /// the group), g_lines (its non-title hits), rn (the hit's place in its
    /// group), snippet — ordered by group, then place.
    public static func groups(
        _ query: SearchQuery, scope: SearchScope, after cursor: GroupCursor?, limit: Int,
        perGroup: Int, environment: Environment
    ) throws -> Statement? {
        guard let hits = try hits(
            query, scope: scope, visibility: query.visibility,
            extra: ["d.reading_id IS NULL"], environment: environment)
        else { return nil }
        var arguments = hits.arguments
        var keyset = ""
        if cursor != nil {
            keyset = "WHERE (g.g_best > ? OR (g.g_best = ? AND g.g_home > ?))"
        }
        let sql = """
            WITH hits AS (\(hits.sql)),
            scored AS MATERIALIZED (
              SELECT h.*, \(scoreSQL) AS score
              FROM hits h
            ),
            grouped AS (
              SELECT s.home_id AS g_home, MIN(s.score) AS g_best, COUNT(*) AS g_hits,
                     SUM(s.kind <> 'title') AS g_lines
              FROM scored s
              GROUP BY s.home_id
            ),
            gpage AS (
              SELECT g.* FROM grouped g
              \(keyset)
              ORDER BY g.g_best, g.g_home
              LIMIT ?
            ),
            ranked AS (
              SELECT s.*, g.g_best, g.g_hits, g.g_lines,
                     ROW_NUMBER() OVER (
                       PARTITION BY s.home_id ORDER BY (s.kind = 'title'), s.score, s.doc_id
                     ) AS rn
              FROM scored s JOIN gpage g ON g.g_home = s.home_id
            ),
            top AS (
              SELECT * FROM ranked WHERE rn <= ?
            )
            SELECT top.*, snippet(search_fts, 0, char(2), char(3), '…', 16) AS snippet
            FROM search_fts JOIN top ON top.doc_id = search_fts.rowid
            WHERE search_fts MATCH ?
            ORDER BY top.g_best, top.home_id, top.rn
            """
        if let cursor {
            arguments += [.real(cursor.best), .real(cursor.best), .text(cursor.homeID)]
        }
        arguments += [.integer(Int64(limit)), .integer(Int64(max(1, perGroup))), .text(hits.match)]
        return Statement(sql: sql, arguments: arguments)
    }

    // MARK: - The counts (13o U2 — the band's honest per-kind numbers)

    /// **What the whole question finds, per kind** — counted over the SAME
    /// hits the pages list (one builder), under the archived facet ON, so the
    /// living numbers and the "+ archived" numbers come from one walk:
    /// books (distinct books a book or chapter hit names) · notes (distinct
    /// note homes, plus the nameless notes the worn-day arm found — confirmed
    /// in Swift by the one display brain, so their ids come in as JSON
    /// arrays, the living ones and all of them) · passages (a note's
    /// non-title hits) · scraps (a scraps group's non-title hits) ·
    /// archived_places (distinct homes or books any ARCHIVED hit lands in —
    /// what the facet would add).
    ///
    /// Result columns: books, notes, passages, scraps, all_books, all_notes,
    /// all_passages, all_scraps, archived_places.
    ///
    /// 13o U3 — the TAG-ASSOCIATION JOIN's books fold into the books counts
    /// exactly as the worn-day notes fold into the notes (JSON id arrays,
    /// decided in Swift by `SearchTagAssociation`): living, all, and the
    /// archived ones among what the facet would add. `[]` (the default) adds
    /// none — every pre-U3 caller reads unchanged.
    public static func counts(
        _ query: SearchQuery, scope: SearchScope, wornLivingNoteIDs: String, wornAllNoteIDs: String,
        wornArchivedNoteIDs: String, associatedLivingBookIDs: String = "[]",
        associatedAllBookIDs: String = "[]", associatedArchivedBookIDs: String = "[]",
        environment: Environment
    ) throws -> Statement? {
        guard let hits = try hits(query, scope: scope, visibility: .includingArchived, environment: environment)
        else { return nil }
        let book = "h.reading_id IS NOT NULL"
        let note = "h.reading_id IS NULL AND h.home_kind = 'post'"
        let pool = "h.reading_id IS NULL AND h.home_kind = 'pool'"
        let sql = """
            WITH hits AS MATERIALIZED (\(hits.sql))
            SELECT
              (SELECT COUNT(DISTINCT k.id) FROM (
                 SELECT h.reading_id AS id FROM hits h WHERE \(book) AND NOT h.archived
                 UNION ALL SELECT value FROM json_each(?)) k) AS books,
              (SELECT COUNT(DISTINCT n.id) FROM (
                 SELECT h.home_id AS id FROM hits h WHERE \(note) AND NOT h.archived
                 UNION ALL SELECT value FROM json_each(?)) n) AS notes,
              (SELECT COUNT(*) FROM hits h WHERE \(note) AND h.kind <> 'title' AND NOT h.archived) AS passages,
              (SELECT COUNT(*) FROM hits h WHERE \(pool) AND h.kind <> 'title' AND NOT h.archived) AS scraps,
              (SELECT COUNT(DISTINCT k.id) FROM (
                 SELECT h.reading_id AS id FROM hits h WHERE \(book)
                 UNION ALL SELECT value FROM json_each(?)) k) AS all_books,
              (SELECT COUNT(DISTINCT n.id) FROM (
                 SELECT h.home_id AS id FROM hits h WHERE \(note)
                 UNION ALL SELECT value FROM json_each(?)) n) AS all_notes,
              (SELECT COUNT(*) FROM hits h WHERE \(note) AND h.kind <> 'title') AS all_passages,
              (SELECT COUNT(*) FROM hits h WHERE \(pool) AND h.kind <> 'title') AS all_scraps,
              (SELECT COUNT(DISTINCT p.id) FROM (
                 SELECT COALESCE(h.reading_id, h.home_id) AS id FROM hits h WHERE h.archived
                 UNION ALL SELECT value FROM json_each(?)
                 UNION ALL SELECT value FROM json_each(?)) p) AS archived_places
            """
        return Statement(
            sql: sql,
            arguments: hits.arguments
                + [.text(associatedLivingBookIDs), .text(wornLivingNoteIDs),
                   .text(associatedAllBookIDs), .text(wornAllNoteIDs),
                   .text(wornArchivedNoteIDs), .text(associatedArchivedBookIDs)])
    }

    // MARK: - The worn-day arm (R-13o-6)

    /// The NOTES that may wear the query's day, two statements — the dated
    /// notes by their `entry_date` key (seeks on `idx_container_entry_date`),
    /// and the undated ones by their creation instant (range seeks on v1_22's
    /// `idx_container_undated_created`). The caller confirms each row with
    /// the ONE display brain (`DisplayTitle` — nameless, and wearing this
    /// day), so no SQL twin of the display rule exists. Both carry the same
    /// scope / facet / filter predicates as the passages, at NOTE level.
    ///
    /// Result columns: id, title, entry_date, created_at, archived.
    public static func wornDay(
        _ query: SearchQuery, scope: SearchScope,
        dayKeys: [String], createdWindows: [(start: String, end: String)],
        environment: Environment
    ) -> [Statement] {
        var common: [String] = []
        var commonArguments: [Value] = []
        let wing = environment.wingScope("c.wing_id", scope.wingID)
        common.append(wing.sql)
        commonArguments += wing.arguments
        switch scope.within {
        case .library:
            break
        case .note(let id):
            common.append("c.id = ?")
            commonArguments.append(.text(id))
        case .book(let id):
            common.append("""
                c.id IN (SELECT rp.post_id FROM reading_post rp
                          WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member')
                """)
            commonArguments.append(.text(id))
        }
        switch query.visibility {
        case .living:
            common.append("c.archived_at IS NULL")
        case .includingArchived:
            common.append("NOT (\(environment.versionPredicate("c")))")
        case .archivedOnly:
            common.append("c.archived_at IS NOT NULL")
            common.append("NOT (\(environment.versionPredicate("c")))")
        }
        if let filter = query.filter {
            let composed = composeFilter(filter, level: .note, wingID: scope.wingID, environment: environment)
            common.append(composed.sql)
            commonArguments += composed.arguments
        }
        let tail = common.isEmpty ? "" : "\n  AND " + common.joined(separator: "\n  AND ")
        var statements: [Statement] = []
        if !dayKeys.isEmpty {
            statements.append(Statement(
                sql: """
                    SELECT c.id, c.title, c.entry_date, c.created_at, (c.archived_at IS NOT NULL) AS archived
                    FROM container c
                    WHERE c.deleted_at IS NULL AND +c.kind = 'post'
                      AND c.entry_date IN (\(dayKeys.map { _ in "?" }.joined(separator: ", ")))\(tail)
                    ORDER BY c.id
                    """,
                arguments: dayKeys.map { .text($0) } + commonArguments))
        }
        if !createdWindows.isEmpty {
            // One RANGE per window, UNION ALL'd: each arm is a seek on the
            // partial index (an OR of ranges would let the planner walk it).
            let arm = """
                SELECT c.id, c.title, c.entry_date, c.created_at, (c.archived_at IS NOT NULL) AS archived
                FROM container c
                WHERE c.deleted_at IS NULL AND (c.entry_date IS NULL OR c.entry_date = '')
                  AND c.created_at >= ? AND c.created_at < ?
                  AND +c.kind = 'post'\(tail)
                """
            statements.append(Statement(
                sql: createdWindows.map { _ in arm }.joined(separator: "\nUNION ALL\n"),
                arguments: createdWindows.flatMap { [Value.text($0.start), .text($0.end)] + commonArguments }))
        }
        return statements
    }

    // MARK: - The tag-association join's reads (13o U3 — the 13i sitting record §12)

    /// **The typed tag's stored paths** in the scope's wing — live, matched
    /// case-insensitively (the typed `#path`'s letter everywhere in search,
    /// P-13o-U1-9). Result column: path.
    public static func typedTagPaths(
        _ path: String, wingID: String, environment: Environment
    ) -> Statement {
        let wing = environment.wingScope("t.wing_id", wingID)
        return Statement(
            sql: """
                SELECT t.path FROM tag t
                WHERE t.deleted_at IS NULL AND \(wing.sql) AND t.path = ? COLLATE NOCASE
                ORDER BY t.path
                """,
            arguments: wing.arguments + [.text(path)])
    }

    /// **The live paths of the tags a set of readings references** (their
    /// rules' terms and their outflows), in the scope's wing — bounded by the
    /// ids (`idsJSON`, a JSON array). Result columns: id, path.
    public static func tagPaths(
        idsJSON: String, wingID: String, environment: Environment
    ) -> Statement {
        let wing = environment.wingScope("t.wing_id", wingID)
        return Statement(
            sql: """
                SELECT t.id, t.path
                FROM json_each(?) j CROSS JOIN tag t ON t.id = j.value AND t.deleted_at IS NULL
                WHERE \(wing.sql)
                """,
            arguments: [.text(idsJSON)] + wing.arguments)
    }

    /// **The association's CANDIDATES** — the scope wing's live readings
    /// that carry a rule or an outflow, under the archived facet and the
    /// query's filter half read at READING level (the mode facets narrow
    /// them; a family or kind that is not a book's, or a day, excludes
    /// them; a tag term is the association's own KEY, decided in Swift by
    /// `SearchTagAssociation`). ∝ the wing's readings (the Bookcase's own
    /// class). nil outside the Library scope — a book's search has no
    /// association to surface. Result columns: id, name, query_spec,
    /// auto_tag_ids, archived.
    public static func associationCandidates(
        _ query: SearchQuery, scope: SearchScope, environment: Environment
    ) -> Statement? {
        guard case .library = scope.within else { return nil }
        let wing = environment.wingScope("r.wing_id", scope.wingID)
        var conditions = [
            "r.deleted_at IS NULL", wing.sql,
            "(r.query_spec IS NOT NULL OR r.auto_tag_ids IS NOT NULL)",
        ]
        var arguments = wing.arguments
        switch query.visibility {
        case .living: conditions.append("r.archived_at IS NULL")
        case .includingArchived: break
        case .archivedOnly: conditions.append("r.archived_at IS NOT NULL")
        }
        if let filter = query.filter {
            let composed = composeFilter(filter, level: .reading, wingID: scope.wingID, environment: environment)
            conditions.append(composed.sql)
            arguments += composed.arguments
        }
        return Statement(
            sql: """
                SELECT r.id, r.name, r.query_spec, r.auto_tag_ids, (r.archived_at IS NOT NULL) AS archived
                FROM reading r
                WHERE \(conditions.joined(separator: "\n  AND "))
                ORDER BY r.id
                """,
            arguments: arguments)
    }

    // MARK: - The filter half

    enum Level {
        /// A passage row: the doc `d`, its home container `c`, block `b`,
        /// reading `r`.
        case passage
        /// A note row: the container `c` alone (the worn-day arm).
        case note
        /// A reading row `r` alone (13o U3 — the association's candidates).
        case reading
    }

    static func composeFilter(
        _ filter: SearchFilter, level: Level, wingID: String, environment: Environment
    ) -> (sql: String, arguments: [Value]) {
        switch filter {
        case .all(let children):
            guard !children.isEmpty else { return ("1", []) }
            let parts = children.map { composeFilter($0, level: level, wingID: wingID, environment: environment) }
            return ("(" + parts.map(\.sql).joined(separator: " AND ") + ")", parts.flatMap(\.arguments))
        case .any(let children):
            guard !children.isEmpty else { return ("0", []) }
            let parts = children.map { composeFilter($0, level: level, wingID: wingID, environment: environment) }
            return ("(" + parts.map(\.sql).joined(separator: " OR ") + ")", parts.flatMap(\.arguments))
        case .not(let inner):
            let part = composeFilter(inner, level: level, wingID: wingID, environment: environment)
            return ("NOT COALESCE(" + part.sql + ", 0)", part.arguments)
        case .tagPath(let path):
            // A reading row is not tagged: the typed tag is the association's
            // KEY there (`SearchTagAssociation` decides), never a constraint.
            if level == .reading { return ("1", []) }
            let rootWing = environment.wingScope("root.wing_id", wingID)
            return tagSubtree(
                root: "root.path = ? COLLATE NOCASE AND \(rootWing.sql)",
                rootArguments: [.text(path)] + rootWing.arguments, level: level)
        case .tag(let id):
            if level == .reading { return ("1", []) }
            return tagSubtree(root: "root.id = ?", rootArguments: [.text(id)], level: level)
        case .starred:
            // "The NOTE is starred" — a reading row is no note.
            if level == .reading { return ("0", []) }
            let ids = environment.starredNoteIDs
            guard !ids.isEmpty else { return ("0", []) }
            return ("c.id IN (" + ids.map { _ in "?" }.joined(separator: ", ") + ")", ids.map { .text($0) })
        case .days(let range):
            // A book carries no edit stamp — an armed day excludes books at
            // every level (the passage level's own answer for a book hit).
            if level == .reading { return ("0", []) }
            switch range.field {
            case .edited:
                return ("COALESCE(" + environment.editedOn("c") + ", 0)",
                        [.text(range.start), .text(range.end), .text(range.start), .text(range.end)])
            case .created:
                return ("(c.created_at >= ? AND c.created_at < ?)", [.text(range.start), .text(range.end)])
            }
        case .family(let family):
            switch (family, level) {
            case (.notes, .reading), (.scraps, .reading): return ("0", [])
            case (.notes, _): return ("c.kind = 'post'", [])
            case (.scraps, _): return ("c.kind = 'pool'", [])
            case (.books, .passage): return ("d.reading_id IS NOT NULL", [])
            case (.books, .note): return ("0", [])
            case (.books, .reading): return ("1", [])
            }
        case .docKind(let kind):
            switch level {
            case .passage: return ("d.kind = ?", [.text(kind.rawValue)])
            // A worn-day hit is a NAME-level hit with no doc behind it.
            case .note: return (kind == .title ? "1" : "0", [])
            // An associated reading is a BOOK-level answer.
            case .reading: return (kind == .book ? "1" : "0", [])
            }
        case .bookState(let state):
            let fact = bookStateSQL(state, alias: "r", environment: environment)
            switch level {
            // Only a book or chapter hit names a reading row (`r` is joined
            // for those alone) — a facet narrows the answer to books.
            case .passage: return ("(d.reading_id IS NOT NULL AND r.id IS NOT NULL AND \(fact))", [])
            case .note: return ("0", [])
            case .reading: return ("(\(fact))", [])
            }
        }
    }

    /// A mode facet as a fact over a reading alias (the № census's reading,
    /// `BookcaseSolo`; living is intake's own predicate from its one home).
    static func bookStateSQL(_ state: SearchBookState, alias r: String, environment: Environment) -> String {
        switch state {
        case .gathering: "\(r).kind = 'gathering'"
        case .living: environment.livingBook(r)
        case .owned: "(\(r).kind = 'book' AND \(r).owned = 1)"
        case .finished: "\(r).locked = 1"
        case .sealed: "\(r).sealed_at IS NOT NULL"
        }
    }

    /// A tag term, SUBTREE-matched through the root's LIVE path (the
    /// gathering rule's own reading — `ruleSQL`'s letter, wing-scoped: the
    /// applied tag shares the root's wing). A note matches by its own tags; a
    /// passage also by its BLOCK's own tags ("everything tagged X UNIONs the
    /// two"). The subqueries are uncorrelated: materialized once per query,
    /// ∝ the subtree's applications.
    private static func tagSubtree(
        root: String, rootArguments: [Value], level: Level
    ) -> (sql: String, arguments: [Value]) {
        // Driven FROM THE ROOT: the applied tags are found by a RANGE on
        // `uq_tag_path_live (wing_id, path)` — [path, path || '0') holds every
        // path that starts with the root's ('0' follows '/') — and the exact
        // subtree test is the residual; then the applications by tag id. Cost
        // ∝ the subtree's applications, never every tag application.
        let applied = """
            FROM tag root
                      JOIN tag applied ON applied.wing_id = root.wing_id AND applied.deleted_at IS NULL
                       AND applied.path >= root.path AND applied.path < root.path || '0'
                       AND (applied.path = root.path
                            OR substr(applied.path, 1, length(root.path) + 1) = root.path || '/')
            """
        let notes = """
            c.id IN (SELECT pt.post_id \(applied)
                      JOIN post_tag pt ON pt.tag_id = applied.id AND pt.deleted_at IS NULL
                     WHERE root.deleted_at IS NULL AND \(root))
            """
        switch level {
        case .reading:
            return ("1", [])  // unreachable: `composeFilter` answers a reading row first
        case .note:
            return ("COALESCE(" + notes + ", 0)", rootArguments)
        case .passage:
            let blocks = """
                d.block_id IN (SELECT bt.block_id \(applied)
                                JOIN block_tag bt ON bt.tag_id = applied.id AND bt.deleted_at IS NULL
                               WHERE root.deleted_at IS NULL AND \(root))
                """
            return ("(COALESCE(" + notes + ", 0) OR COALESCE(" + blocks + ", 0))",
                    rootArguments + rootArguments)
        }
    }

    // MARK: - Snippets

    /// The snippet markers the page statement asks FTS5 for (STX / ETX —
    /// control characters no text she writes carries).
    static let matchOpen: Character = "\u{2}"
    static let matchClose: Character = "\u{3}"

    /// A marked snippet → its segments (matched runs flagged).
    public static func snippetSegments(_ marked: String) -> [SearchSnippetSegment] {
        var segments: [SearchSnippetSegment] = []
        var current = ""
        var inMatch = false
        for ch in marked {
            if ch == matchOpen || ch == matchClose {
                if !current.isEmpty { segments.append(SearchSnippetSegment(text: current, isMatch: inMatch)) }
                current = ""
                inMatch = ch == matchOpen
            } else {
                current.append(ch)
            }
        }
        if !current.isEmpty { segments.append(SearchSnippetSegment(text: current, isMatch: inMatch)) }
        return segments
    }
}

/// One run of a hit's snippet — matched words flagged, so a face draws the
/// highlight in its own idiom (no markup crosses the seam).
public struct SearchSnippetSegment: Equatable, Sendable {
    public let text: String
    public let isMatch: Bool
}
