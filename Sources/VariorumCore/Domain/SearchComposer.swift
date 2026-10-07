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
/// - snippets are computed for the PAGE rows only (a second FTS lookup per
///   page row by rowid), never for every match.
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

        public init(
            versionPredicate: @escaping @Sendable (String) -> String,
            wingScope: @escaping @Sendable (String, String) -> (sql: String, arguments: [Value]),
            editedOn: @escaping @Sendable (String) -> String,
            starredNoteIDs: [String]
        ) {
            self.versionPredicate = versionPredicate
            self.wingScope = wingScope
            self.editedOn = editedOn
            self.starredNoteIDs = starredNoteIDs
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
        switch query.visibility {
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
        let weight = "CASE h.kind "
            + kindWeights.map { "WHEN '\($0.kind)' THEN \($0.weight)" }.joined(separator: " ")
            + " ELSE 1.0 END"

        var keyset = ""
        if let cursor {
            keyset = "WHERE (s.score > ? OR (s.score = ? AND s.doc_id > ?))"
        }
        let sql = """
            WITH hits AS (
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
            ),
            scored AS (
              SELECT h.*, h.bm * (\(weight)) * (CASE WHEN h.rendered THEN \(renderedBoost) ELSE 1.0 END) AS score
              FROM hits h
            ),
            page AS (
              SELECT s.* FROM scored s
              \(keyset)
              ORDER BY s.score, s.doc_id
              LIMIT ?
            )
            SELECT page.*, snippet(search_fts, 0, char(2), char(3), '…', 16) AS snippet
            FROM page CROSS JOIN search_fts ON search_fts.rowid = page.doc_id
            WHERE search_fts MATCH ?
            ORDER BY page.score, page.doc_id
            """
        if let cursor {
            arguments += [.real(cursor.score), .real(cursor.score), .integer(cursor.docID)]
        }
        arguments += [.integer(Int64(limit)), .text(match)]
        return Statement(sql: sql, arguments: arguments)
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

    // MARK: - The filter half

    enum Level {
        /// A passage row: the doc `d`, its home container `c`, block `b`,
        /// reading `r`.
        case passage
        /// A note row: the container `c` alone (the worn-day arm).
        case note
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
            let rootWing = environment.wingScope("root.wing_id", wingID)
            return tagSubtree(
                root: "root.path = ? COLLATE NOCASE AND \(rootWing.sql)",
                rootArguments: [.text(path)] + rootWing.arguments, level: level)
        case .tag(let id):
            return tagSubtree(root: "root.id = ?", rootArguments: [.text(id)], level: level)
        case .starred:
            let ids = environment.starredNoteIDs
            guard !ids.isEmpty else { return ("0", []) }
            return ("c.id IN (" + ids.map { _ in "?" }.joined(separator: ", ") + ")", ids.map { .text($0) })
        case .days(let range):
            switch range.field {
            case .edited:
                return ("COALESCE(" + environment.editedOn("c") + ", 0)",
                        [.text(range.start), .text(range.end), .text(range.start), .text(range.end)])
            case .created:
                return ("(c.created_at >= ? AND c.created_at < ?)", [.text(range.start), .text(range.end)])
            }
        case .family(let family):
            switch (family, level) {
            case (.notes, _): return ("c.kind = 'post'", [])
            case (.scraps, _): return ("c.kind = 'pool'", [])
            case (.books, .passage): return ("d.reading_id IS NOT NULL", [])
            case (.books, .note): return ("0", [])
            }
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
