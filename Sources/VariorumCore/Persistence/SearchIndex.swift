import GRDB

/// **THE SEARCH INDEX — a DERIVED, LOCAL-ONLY family** (Phase 13o, U1; the
/// rulings R-13o-3/4/6/11 and the §FORK RULINGS F1–F4 in
/// `notes/plans/phase-13o-search.md`).
///
/// Three objects and one trigger family:
///
/// - **`search_doc`** — one row per SOURCE TEXT FIELD (F2): `kind` names the
///   (table, column) pair, `src_id` the source row. A doc exists iff its
///   source row is LIVE (`deleted_at IS NULL`) and the field is non-NULL;
///   archived rows stay indexed with their OWN archived fact (R-13o-6). The
///   other columns are the source row's OWN facts only (F3): its parent id as
///   it carries it, its own `wing_id` (notes and books), its own archived
///   state. Everything else — which note holds a block, which take renders,
///   what a version or a scrap is, the wing a block lives in — is resolved
///   at QUERY time by the one composer, from rows-as-truth. The rowid is
///   `AUTOINCREMENT`: an id is never reused, so no index entry can ever be
///   inherited by a later doc.
/// - **`search_text`** — the VIEW that resolves each doc's text from its
///   SOURCE row (F1): the text is stored once, in the source; the index's
///   external content IS the truth.
/// - **`search_fts`** — FTS5, external content over `search_text`,
///   `unicode61 remove_diacritics 2` (R-13o-11 — case AND accents fold; the
///   deliberate third sameness rule beside the Write/Takes find bars' pinned
///   pair), prefix indexes for 2 and 3 characters (F4 — type-ahead), ONE
///   indexed column (`body`; a kind's weight is a query-time bm25
///   multiplier).
///
/// **The capture triggers — R-13o-4's third trigger family, DERIVED-INDEX
/// CAPTURE** (the plan's §R-13o-4 RECORD is its provenance). Mechanical
/// only: each reads NEW/OLD and the doc family (to find its rowid), and no
/// other table, ever. They fire for every writing layer — operations,
/// tombstone cascades, remote apply, repairs, the purge janitor — which is
/// the whole reason they are triggers (SyncSpec §3's outbox argument). They
/// do NOT check `_sync_applying`: a remote row must be indexed exactly like
/// a local one.
///
/// **The external-content contract (F1, adopted verbatim):** every source
/// text write updates the index IN THE SAME STATEMENT with OLD = what was
/// indexed. Each UPDATE trigger therefore retires the doc's entry with the
/// OLD text before adding the NEW one; the integrity check
/// (`INSERT INTO search_fts(search_fts, rank) VALUES ('integrity-check', 1)`)
/// compares the index against the source rows and is the net.
///
/// **No trigger may ever refuse a truth write.** A stale doc (an index bug)
/// is never allowed to collide: the INSERT trigger clears any leftover doc
/// for its key before adding (an orphaned index entry is the integrity
/// check's to find and the rebuild's to clear — never her write's to fail).
///
/// Frozen by convention once shipped: `v1_22` calls `createSearchIndex`, so a
/// later reshape is a NEW migration that drops and recreates (the
/// `createOutboxCaptureTriggers` discipline) — never an edit here that only
/// fresh stores would see.
enum SearchIndex {
    /// The derived family's TABLES (the virtual table + its five shadows'
    /// four that exist under external content + the doc table) — the set the
    /// sync registry's DERIVED list carries (the §FORK RULINGS' export ruling).
    static let tables: Set<String> = [
        "search_doc", "search_fts",
        "search_fts_config", "search_fts_data", "search_fts_docsize", "search_fts_idx",
    ]

    /// One indexed source field (F2's eight kinds).
    struct Source {
        /// The doc kind (closed, additive vocabulary).
        let kind: String
        let table: String
        /// The text column.
        let column: String
        /// The doc's own-row facts: doc column → SQL over the row (`R` is
        /// replaced by NEW or OLD).
        let facts: [(column: String, expression: String)]
        /// Source columns whose change can move a fact (beside the text
        /// column and `deleted_at`).
        let factColumns: [String]
    }

    /// The eight kinds (F2). Their facts are the source row's OWN columns
    /// (F3) — never another table's.
    static let sources: [Source] = [
        Source(kind: "take", table: "variant", column: "working_text",
               facts: [("block_id", "R.block_id"), ("archived", "(R.status = 'archived')")],
               factColumns: ["block_id", "status"]),
        Source(kind: "take_label", table: "variant", column: "label",
               facts: [("block_id", "R.block_id"), ("archived", "(R.status = 'archived')")],
               factColumns: ["block_id", "status"]),
        Source(kind: "block_name", table: "block", column: "name",
               facts: [("block_id", "R.id"), ("archived", "(R.archived_at IS NOT NULL)")],
               factColumns: ["archived_at"]),
        Source(kind: "comment", table: "block_comment", column: "text",
               facts: [("block_id", "R.block_id")],
               factColumns: ["block_id"]),
        Source(kind: "title", table: "container", column: "title",
               facts: [("container_id", "R.id"), ("wing_id", "R.wing_id"),
                       ("archived", "(R.archived_at IS NOT NULL)")],
               factColumns: ["wing_id", "archived_at"]),
        Source(kind: "note_meta", table: "container", column: "floating_notes",
               facts: [("container_id", "R.id"), ("wing_id", "R.wing_id"),
                       ("archived", "(R.archived_at IS NOT NULL)")],
               factColumns: ["wing_id", "archived_at"]),
        Source(kind: "book", table: "reading", column: "name",
               facts: [("reading_id", "R.id"), ("wing_id", "R.wing_id"),
                       ("archived", "(R.archived_at IS NOT NULL)")],
               factColumns: ["wing_id", "archived_at"]),
        Source(kind: "chapter", table: "reading_section", column: "name",
               facts: [("reading_id", "R.reading_id")],
               factColumns: ["reading_id"]),
    ]

    // MARK: - Schema (v1_22)

    /// Creates the family and its capture triggers. Called once, by `v1_22`.
    static func create(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE search_doc (
              id           INTEGER PRIMARY KEY AUTOINCREMENT,
              kind         TEXT NOT NULL,
              src_id       TEXT NOT NULL,
              block_id     TEXT,
              container_id TEXT,
              reading_id   TEXT,
              wing_id      TEXT,
              archived     INTEGER NOT NULL DEFAULT 0
            );
            CREATE UNIQUE INDEX uq_search_doc_src ON search_doc(kind, src_id);
            """)
        try db.execute(sql: """
            CREATE VIEW search_text AS
            SELECT d.id AS id,
              CASE d.kind
            \(sources.map { source in
                "    WHEN '\(source.kind)' THEN (SELECT s.\(source.column) FROM \(source.table) s WHERE s.id = d.src_id)"
              }.joined(separator: "\n"))
              END AS body
            FROM search_doc d;
            """)
        try db.execute(sql: """
            CREATE VIRTUAL TABLE search_fts USING fts5(
              body,
              content = 'search_text', content_rowid = 'id',
              tokenize = 'unicode61 remove_diacritics 2',
              prefix = '2 3'
            );
            """)
        for source in sources {
            try createCaptureTriggers(db, source)
        }
    }

    /// One source field's three capture triggers. One shape for all eight
    /// (no hand-written drift), named `search_<table>_<kind>_<event>`.
    private static func createCaptureTriggers(_ db: Database, _ source: Source) throws {
        let kind = source.kind
        let col = source.column
        func exists(_ r: String) -> String {
            "\(r).deleted_at IS NULL AND \(r).\(col) IS NOT NULL"
        }
        func factValues(_ r: String) -> String {
            source.facts.map { $0.expression.replacingOccurrences(of: "R.", with: "\(r).") }
                .joined(separator: ", ")
        }
        let factNames = source.facts.map(\.column).joined(separator: ", ")
        let factUpserts = source.facts.map { "\($0.column) = excluded.\($0.column)" }
            .joined(separator: ", ")
        let name = "search_\(source.table)_\(kind)"
        // The doc's entry for the NEW row, added after any retirement: the
        // upsert keeps a live doc's rowid stable across text edits; the index
        // row is then (re)written with the NEW text.
        let add = """
              INSERT INTO search_doc (kind, src_id, \(factNames))
                SELECT '\(kind)', NEW.id, \(factValues("NEW")) WHERE \(exists("NEW"))
                ON CONFLICT (kind, src_id) DO UPDATE SET \(factUpserts);
              INSERT INTO search_fts (rowid, body)
                SELECT id, NEW.\(col) FROM search_doc WHERE kind = '\(kind)' AND src_id = NEW.id;
            """
        // INSERT: clear any leftover doc for this key (never collide — a stale
        // doc orphans its index entry for the integrity check, never fails her
        // write), then add.
        try db.execute(sql: """
            CREATE TRIGGER \(name)_insert
            AFTER INSERT ON \(source.table)
            WHEN \(exists("NEW"))
            BEGIN
              DELETE FROM search_doc WHERE kind = '\(kind)' AND src_id = NEW.id;
            \(add)
            END;
            """)
        // UPDATE: only when the text, the liveness or an own fact moved (a
        // remote apply rewrites whole rows — same values must cost nothing).
        let watched = ([col, "deleted_at"] + source.factColumns).joined(separator: ", ")
        let changed = ([col, "deleted_at"] + source.factColumns)
            .map { "OLD.\($0) IS NOT NEW.\($0)" }.joined(separator: " OR ")
        try db.execute(sql: """
            CREATE TRIGGER \(name)_update
            AFTER UPDATE OF \(watched) ON \(source.table)
            WHEN \(changed)
            BEGIN
              INSERT INTO search_fts (search_fts, rowid, body)
                SELECT 'delete', id, OLD.\(col) FROM search_doc WHERE kind = '\(kind)' AND src_id = OLD.id;
              DELETE FROM search_doc
                WHERE kind = '\(kind)' AND src_id = OLD.id AND NOT (\(exists("NEW")));
            \(add)
            END;
            """)
        // DELETE (the purge janitor's physical removal): retire the entry.
        try db.execute(sql: """
            CREATE TRIGGER \(name)_delete
            AFTER DELETE ON \(source.table)
            BEGIN
              INSERT INTO search_fts (search_fts, rowid, body)
                SELECT 'delete', id, OLD.\(col) FROM search_doc WHERE kind = '\(kind)' AND src_id = OLD.id;
              DELETE FROM search_doc WHERE kind = '\(kind)' AND src_id = OLD.id;
            END;
            """)
    }

    // MARK: - The rebuild engine (the backfill, and P5's rebuild door)

    /// Rebuilds the whole family FROM TRUTH: every doc re-derived from the
    /// live source rows, then the index re-read from the view. Idempotent;
    /// cost ∝ the corpus (a maintenance act and the one-time backfill — never
    /// a keystroke road).
    static func rebuild(_ db: Database) throws {
        try db.execute(sql: "DELETE FROM search_doc")
        for source in sources {
            let factNames = source.facts.map(\.column).joined(separator: ", ")
            let factValues = source.facts
                .map { $0.expression.replacingOccurrences(of: "R.", with: "s.") }
                .joined(separator: ", ")
            try db.execute(sql: """
                INSERT INTO search_doc (kind, src_id, \(factNames))
                SELECT '\(source.kind)', s.id, \(factValues) FROM \(source.table) s
                WHERE s.deleted_at IS NULL AND s.\(source.column) IS NOT NULL
                """)
        }
        try db.execute(sql: "INSERT INTO search_fts (search_fts) VALUES ('rebuild')")
    }
}

// MARK: - The integrity check (the derived family's honesty net)

/// One doc's identity: its kind and its source row.
public struct SearchDocKey: Hashable, Sendable, CustomStringConvertible {
    public let kind: String
    public let srcID: String
    public var description: String { "\(kind):\(srcID)" }
}

/// **What the integrity check found** (13o U1 P5). Two independent nets:
/// the DOC set against the source rows (every live non-NULL field has its
/// doc, no doc outlives its field, every doc's own facts are its source
/// row's), and the INDEX against its content — FTS5's own
/// `integrity-check` with `rank = 1`, which re-tokenizes the view (the
/// SOURCE text, F1) and compares it with what is indexed: a source text
/// changed behind the index's back reads as a mismatch here
/// (SQLITE_CORRUPT_VTAB — the U1 bench's probe, now the drift pin).
public struct SearchIndexIntegrity: Equatable, Sendable {
    public let docCount: Int
    /// Live, non-NULL source fields with no doc.
    public let missing: [SearchDocKey]
    /// Docs whose source field is dead, NULL, or gone — or of no known kind.
    public let orphaned: [SearchDocKey]
    /// Docs whose own facts (parent id, wing, archived) disagree with their
    /// source row.
    public let factDrift: [SearchDocKey]
    /// FTS5's index-vs-content check passed.
    public let indexMatchesContent: Bool

    public var isHealthy: Bool {
        missing.isEmpty && orphaned.isEmpty && factDrift.isEmpty && indexMatchesContent
    }
}

extension SearchIndex {
    /// Runs both nets. Cost ∝ the corpus — a maintenance read, never a
    /// keystroke road. Needs a WRITABLE connection: FTS5's check is spelled
    /// as an INSERT into the virtual table (it writes nothing).
    static func integrity(_ db: Database) throws -> SearchIndexIntegrity {
        var missing: [SearchDocKey] = []
        var orphaned: [SearchDocKey] = []
        var drift: [SearchDocKey] = []
        for source in sources {
            let live = "s.deleted_at IS NULL AND s.\(source.column) IS NOT NULL"
            missing += try String.fetchAll(db, sql: """
                SELECT s.id FROM \(source.table) s
                WHERE \(live) AND NOT EXISTS (
                  SELECT 1 FROM search_doc d WHERE d.kind = '\(source.kind)' AND d.src_id = s.id)
                ORDER BY s.id
                """).map { SearchDocKey(kind: source.kind, srcID: $0) }
            orphaned += try String.fetchAll(db, sql: """
                SELECT d.src_id FROM search_doc d
                WHERE d.kind = '\(source.kind)' AND NOT EXISTS (
                  SELECT 1 FROM \(source.table) s WHERE s.id = d.src_id AND \(live))
                ORDER BY d.src_id
                """).map { SearchDocKey(kind: source.kind, srcID: $0) }
            // Every doc column the kind does not set must be NULL / 0 too —
            // a fact on the wrong column is drift as much as a wrong value.
            let set = Dictionary(uniqueKeysWithValues: source.facts.map { ($0.column, $0.expression) })
            let checks = ["block_id", "container_id", "reading_id", "wing_id", "archived"].map { column -> String in
                if let expression = set[column] {
                    return "d.\(column) IS NOT \(expression.replacingOccurrences(of: "R.", with: "s."))"
                }
                return column == "archived" ? "d.archived <> 0" : "d.\(column) IS NOT NULL"
            }.joined(separator: " OR ")
            drift += try String.fetchAll(db, sql: """
                SELECT d.src_id FROM search_doc d JOIN \(source.table) s ON s.id = d.src_id
                WHERE d.kind = '\(source.kind)' AND (\(checks))
                ORDER BY d.src_id
                """).map { SearchDocKey(kind: source.kind, srcID: $0) }
        }
        let known = sources.map { "'\($0.kind)'" }.joined(separator: ", ")
        orphaned += try Row.fetchAll(db, sql: """
            SELECT kind, src_id FROM search_doc WHERE kind NOT IN (\(known)) ORDER BY kind, src_id
            """).map { SearchDocKey(kind: $0["kind"], srcID: $0["src_id"]) }
        let docCount = try Int.fetchOne(db, sql: "SELECT count(*) FROM search_doc") ?? 0
        var indexMatches = true
        do {
            try db.execute(sql: "INSERT INTO search_fts (search_fts, rank) VALUES ('integrity-check', 1)")
        } catch let error as DatabaseError where error.resultCode == .SQLITE_CORRUPT {
            indexMatches = false
        }
        return SearchIndexIntegrity(
            docCount: docCount, missing: missing, orphaned: orphaned,
            factDrift: drift, indexMatchesContent: indexMatches)
    }
}
