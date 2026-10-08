//
//  SearchForkMeasurementTests.swift
//  VariorumCoreTests
//
//  13o U1, piece P1 — THE FORK MEASUREMENTS (contentless vs external-content
//  FTS5; doc normalization; where scope lives). A MEASUREMENT BENCH, not a
//  pin: gated behind `VARIORUM_SEARCH_MEASURE=1` so the ordinary suite skips
//  it (a skipped Swift Testing test still counts in "N tests" — read the
//  skipped lines). Its numbers are recorded in the 13o plan's U1 RECORD.
//

import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

private let measuring = ProcessInfo.processInfo.environment["VARIORUM_SEARCH_MEASURE"] == "1"

@Suite("13o fork measurements (gated)", .enabled(if: measuring), .serialized)
struct SearchForkMeasurementTests {
    // MARK: - Probe: what the linked SQLite can do

    @Test func probeTheLinkedSQLite() throws {
        let db = try DatabaseQueue()
        try db.write { db in
            let version = try String.fetchOne(db, sql: "SELECT sqlite_version()") ?? "?"
            let options = try String.fetchAll(db, sql: "PRAGMA compile_options")
            print("[13o-probe] sqlite_version = \(version)")
            print("[13o-probe] fts-ish options = \(options.filter { $0.contains("FTS") || $0.contains("DBSTAT") })")
            // contentless_delete (3.43+)
            do {
                try db.execute(sql: "CREATE VIRTUAL TABLE p_cd USING fts5(body, content='', contentless_delete=1)")
                try db.execute(sql: "INSERT INTO p_cd(rowid, body) VALUES (1, 'alpha beta')")
                try db.execute(sql: "DELETE FROM p_cd WHERE rowid = 1")
                let n = try Int.fetchOne(db, sql: "SELECT count(*) FROM p_cd WHERE p_cd MATCH 'alpha'") ?? -1
                print("[13o-probe] contentless_delete=1 OK, hits after delete = \(n)")
            } catch {
                print("[13o-probe] contentless_delete=1 FAILED: \(error)")
            }
            // A VIEW as external content.
            do {
                try db.execute(sql: """
                    CREATE TABLE p_src (id TEXT PRIMARY KEY, txt TEXT NOT NULL);
                    CREATE TABLE p_doc (id INTEGER PRIMARY KEY, src_id TEXT NOT NULL);
                    CREATE VIEW p_view AS
                      SELECT d.id AS id, (SELECT txt FROM p_src s WHERE s.id = d.src_id) AS body FROM p_doc d;
                    CREATE VIRTUAL TABLE p_ext USING fts5(body, content='p_view', content_rowid='id',
                      tokenize='unicode61 remove_diacritics 2', prefix='2 3');
                    INSERT INTO p_src VALUES ('a', 'The Café was naïve'), ('b', 'cafe NAIVE Résumé');
                    INSERT INTO p_doc (id, src_id) VALUES (1, 'a'), (2, 'b');
                    INSERT INTO p_ext(p_ext) VALUES ('rebuild');
                    """)
                let rows = try Row.fetchAll(db, sql: """
                    SELECT rowid, snippet(p_ext, 0, '[', ']', '…', 8) AS s FROM p_ext
                    WHERE p_ext MATCH 'cafe AND naive' ORDER BY rank
                    """)
                print("[13o-probe] view-as-external-content hits = \(rows.map { "\($0["rowid"] as Int64): \($0["s"] as String? ?? "nil")" })")
                let pre = try Row.fetchAll(db, sql: "SELECT rowid FROM p_ext WHERE p_ext MATCH 'res*'")
                print("[13o-probe] prefix res* (accent-folded) hits = \(pre.count)")
                try db.execute(sql: "INSERT INTO p_ext(p_ext, rank) VALUES ('integrity-check', 1)")
                print("[13o-probe] integrity-check(rank=1) on the view-backed table: OK")
                // Drift the content without telling the index: integrity-check must notice.
                try db.execute(sql: "UPDATE p_src SET txt = 'something else entirely' WHERE id = 'a'")
                do {
                    try db.execute(sql: "INSERT INTO p_ext(p_ext, rank) VALUES ('integrity-check', 1)")
                    print("[13o-probe] integrity-check after silent drift: PASSED (does NOT detect)")
                } catch {
                    print("[13o-probe] integrity-check after silent drift: DETECTED (\(error))")
                }
            } catch {
                print("[13o-probe] view-as-external-content FAILED: \(error)")
            }
            // Contentless snippet behavior.
            do {
                try db.execute(sql: """
                    CREATE VIRTUAL TABLE p_cl USING fts5(body, content='', contentless_delete=1,
                      tokenize='unicode61 remove_diacritics 2');
                    INSERT INTO p_cl(rowid, body) VALUES (1, 'the café was naïve');
                    """)
                let s = try String.fetchOne(db, sql: """
                    SELECT snippet(p_cl, 0, '[', ']', '…', 8) FROM p_cl WHERE p_cl MATCH 'cafe'
                    """)
                print("[13o-probe] contentless snippet = \(s ?? "nil")")
            } catch {
                print("[13o-probe] contentless snippet FAILED: \(error)")
            }
        }
    }

    // MARK: - The bench

    /// The four index designs under comparison.
    enum Design: String, CaseIterable {
        /// External content over a doc table that HOLDS the text (a mirror copy).
        case extDoc = "X"
        /// External content over a VIEW that resolves the text from the SOURCE
        /// rows (the doc table holds ids only — text stored once).
        case extView = "V"
        /// Contentless (`contentless_delete=1`): no text anywhere but the source;
        /// snippet() unavailable.
        case contentless = "C"
        /// A regular FTS5 table (its own `_content` copy of the text).
        case regular = "R"
    }

    /// Zipf-ish vocabulary over pseudo-words, deterministic.
    struct Vocabulary {
        let words: [String]
        let cumulative: [Double]
        init(size: Int) {
            let consonants = Array("bcdfghjklmnprstvwz")
            let vowels = Array("aeiou")
            var words: [String] = []
            words.reserveCapacity(size)
            for i in 0..<size {
                var n = i
                var w = ""
                repeat {
                    w.append(consonants[n % consonants.count]); n /= consonants.count
                    w.append(vowels[n % vowels.count]); n /= vowels.count
                } while n > 0
                if i % 997 == 13 { w += "é" } // a sprinkle of accents
                words.append(w)
            }
            self.words = words
            var acc = 0.0
            var cum: [Double] = []
            cum.reserveCapacity(size)
            for r in 1...size { acc += 1.0 / pow(Double(r), 1.07); cum.append(acc) }
            cumulative = cum
        }
        func sample(_ rng: inout SeededGenerator) -> String {
            let x = Double(rng.next() % 1_000_000_007) / 1_000_000_007.0 * cumulative.last!
            var lo = 0, hi = cumulative.count - 1
            while lo < hi { let mid = (lo + hi) / 2; if cumulative[mid] < x { lo = mid + 1 } else { hi = mid } }
            return words[lo]
        }
    }

    private func text(_ vocab: Vocabulary, _ rng: inout SeededGenerator, words: Int) -> String {
        var parts: [String] = []
        parts.reserveCapacity(words)
        for _ in 0..<words { parts.append(vocab.sample(&rng)) }
        return parts.joined(separator: " ")
    }

    /// The real schema on disk + `notes × blocksPerNote` placed single-take
    /// blocks (every 10th block carries a second take), split over two wings
    /// (90% Home). Raw SQL under the apply flag (no outbox rows) — a bench bed.
    private func corpus(at url: URL, notes: Int, blocksPerNote: Int) throws -> DatabaseQueue {
        try? FileManager.default.removeItem(at: url)
        var config = Configuration()
        config.foreignKeysEnabled = false
        let queue = try DatabaseQueue(path: url.path, configuration: config)
        try AppDatabase.migrator.migrate(queue)
        let vocab = Vocabulary(size: 30_000)
        var rng = SeededGenerator(seed: 42)
        try queue.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying VALUES (1)")
            let now = "2026-10-06T00:00:00.000Z"
            let container = try db.makeStatement(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at, wing_id)
                VALUES (?, 'post', ?, ?, ?, ?)
                """)
            let block = try db.makeStatement(sql: """
                INSERT INTO block (id, default_variant_id, created_at, updated_at) VALUES (?, ?, ?, ?)
                """)
            let variant = try db.makeStatement(sql: """
                INSERT INTO variant (id, block_id, working_text, fan_position, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
                """)
            let placement = try db.makeStatement(sql: """
                INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """)
            for n in 0..<notes {
                let noteID = String(format: "n%07d", n)
                let wing = n % 10 == 0 ? "wing-two" : ""
                try container.execute(arguments: [noteID, text(vocab, &rng, words: 4), now, now, wing])
                for b in 0..<blocksPerNote {
                    let blockID = String(format: "b%07d-%03d", n, b)
                    let v1 = blockID + "-v1"
                    try block.execute(arguments: [blockID, v1, now, now])
                    try variant.execute(arguments: [v1, blockID, text(vocab, &rng, words: 50), "a0", now, now])
                    if b % 10 == 0 {
                        try variant.execute(arguments: [blockID + "-v2", blockID, text(vocab, &rng, words: 50), "a1", now, now])
                    }
                    try placement.execute(arguments: [
                        blockID + "-p", noteID, blockID, String(format: "a%04d", b), v1, now, now])
                }
            }
            try db.execute(sql: "DELETE FROM _sync_applying")
        }
        return queue
    }

    /// Creates one design's tables + its take-capture triggers, and
    /// backfills it. Returns the backfill wall time.
    private func install(_ design: Design, _ db: Database, prefix: String = "prefix='2 3'") throws -> Duration {
        let tok = "tokenize='unicode61 remove_diacritics 2'" + (prefix.isEmpty ? "" : ", \(prefix)")
        let clock = ContinuousClock()
        switch design {
        case .extDoc:
            try db.execute(sql: """
                CREATE TABLE s_doc (id INTEGER PRIMARY KEY, kind TEXT NOT NULL, src_id TEXT NOT NULL,
                  block_id TEXT, note_id TEXT, wing_id TEXT, archived INTEGER NOT NULL DEFAULT 0, body TEXT NOT NULL);
                CREATE UNIQUE INDEX s_doc_src ON s_doc(src_id, kind);
                CREATE VIRTUAL TABLE s_fts USING fts5(body, content='s_doc', content_rowid='id', \(tok));
                CREATE TRIGGER s_v_upd AFTER UPDATE OF working_text ON variant BEGIN
                  UPDATE s_doc SET body = NEW.working_text WHERE src_id = NEW.id AND kind = 'take';
                END;
                CREATE TRIGGER s_doc_upd AFTER UPDATE OF body ON s_doc BEGIN
                  INSERT INTO s_fts(s_fts, rowid, body) VALUES ('delete', OLD.id, OLD.body);
                  INSERT INTO s_fts(rowid, body) VALUES (NEW.id, NEW.body);
                END;
                """)
            let t0 = clock.now
            try db.execute(sql: """
                INSERT INTO s_doc (kind, src_id, block_id, note_id, wing_id, body)
                SELECT 'take', v.id, v.block_id, cb.container_id, c.wing_id, v.working_text
                FROM variant v JOIN container_block cb ON cb.block_id = v.block_id
                JOIN container c ON c.id = cb.container_id;
                INSERT INTO s_fts(s_fts) VALUES ('rebuild');
                """)
            return clock.now - t0
        case .extView:
            try db.execute(sql: """
                CREATE TABLE s_doc (id INTEGER PRIMARY KEY, kind TEXT NOT NULL, src_id TEXT NOT NULL,
                  block_id TEXT, note_id TEXT, wing_id TEXT, archived INTEGER NOT NULL DEFAULT 0);
                CREATE UNIQUE INDEX s_doc_src ON s_doc(src_id, kind);
                CREATE VIEW s_text AS SELECT d.id AS id,
                  CASE d.kind WHEN 'take' THEN (SELECT working_text FROM variant WHERE id = d.src_id) END AS body
                  FROM s_doc d;
                CREATE VIRTUAL TABLE s_fts USING fts5(body, content='s_text', content_rowid='id', \(tok));
                CREATE TRIGGER s_v_upd AFTER UPDATE OF working_text ON variant BEGIN
                  INSERT INTO s_fts(s_fts, rowid, body)
                    SELECT 'delete', id, OLD.working_text FROM s_doc WHERE src_id = NEW.id AND kind = 'take';
                  INSERT INTO s_fts(rowid, body)
                    SELECT id, NEW.working_text FROM s_doc WHERE src_id = NEW.id AND kind = 'take';
                END;
                """)
            let t0 = clock.now
            try db.execute(sql: """
                INSERT INTO s_doc (kind, src_id, block_id, note_id, wing_id)
                SELECT 'take', v.id, v.block_id, cb.container_id, c.wing_id
                FROM variant v JOIN container_block cb ON cb.block_id = v.block_id
                JOIN container c ON c.id = cb.container_id;
                INSERT INTO s_fts(s_fts) VALUES ('rebuild');
                """)
            return clock.now - t0
        case .contentless:
            try db.execute(sql: """
                CREATE TABLE s_doc (id INTEGER PRIMARY KEY, kind TEXT NOT NULL, src_id TEXT NOT NULL,
                  block_id TEXT, note_id TEXT, wing_id TEXT, archived INTEGER NOT NULL DEFAULT 0);
                CREATE UNIQUE INDEX s_doc_src ON s_doc(src_id, kind);
                CREATE VIRTUAL TABLE s_fts USING fts5(body, content='', contentless_delete=1, \(tok));
                CREATE TRIGGER s_v_upd AFTER UPDATE OF working_text ON variant BEGIN
                  DELETE FROM s_fts WHERE rowid IN (SELECT id FROM s_doc WHERE src_id = NEW.id AND kind = 'take');
                  INSERT INTO s_fts(rowid, body)
                    SELECT id, NEW.working_text FROM s_doc WHERE src_id = NEW.id AND kind = 'take';
                END;
                """)
            let t0 = clock.now
            try db.execute(sql: """
                INSERT INTO s_doc (kind, src_id, block_id, note_id, wing_id)
                SELECT 'take', v.id, v.block_id, cb.container_id, c.wing_id
                FROM variant v JOIN container_block cb ON cb.block_id = v.block_id
                JOIN container c ON c.id = cb.container_id;
                INSERT INTO s_fts(rowid, body)
                SELECT d.id, v.working_text FROM s_doc d JOIN variant v ON v.id = d.src_id;
                """)
            return clock.now - t0
        case .regular:
            try db.execute(sql: """
                CREATE TABLE s_doc (id INTEGER PRIMARY KEY, kind TEXT NOT NULL, src_id TEXT NOT NULL,
                  block_id TEXT, note_id TEXT, wing_id TEXT, archived INTEGER NOT NULL DEFAULT 0);
                CREATE UNIQUE INDEX s_doc_src ON s_doc(src_id, kind);
                CREATE VIRTUAL TABLE s_fts USING fts5(body, \(tok));
                CREATE TRIGGER s_v_upd AFTER UPDATE OF working_text ON variant BEGIN
                  UPDATE s_fts SET body = NEW.working_text
                    WHERE rowid IN (SELECT id FROM s_doc WHERE src_id = NEW.id AND kind = 'take');
                END;
                """)
            let t0 = clock.now
            try db.execute(sql: """
                INSERT INTO s_doc (kind, src_id, block_id, note_id, wing_id)
                SELECT 'take', v.id, v.block_id, cb.container_id, c.wing_id
                FROM variant v JOIN container_block cb ON cb.block_id = v.block_id
                JOIN container c ON c.id = cb.container_id;
                INSERT INTO s_fts(rowid, body)
                SELECT d.id, v.working_text FROM s_doc d JOIN variant v ON v.id = d.src_id;
                """)
            return clock.now - t0
        }
    }

    private func pageRequests(_ db: Database, reset: Bool) -> Int {
        var hit: Int32 = 0, miss: Int32 = 0, hw: Int32 = 0
        sqlite3_db_status(db.sqliteConnection, SQLITE_DBSTATUS_CACHE_HIT, &hit, &hw, reset ? 1 : 0)
        sqlite3_db_status(db.sqliteConnection, SQLITE_DBSTATUS_CACHE_MISS, &miss, &hw, reset ? 1 : 0)
        return Int(hit) + Int(miss)
    }

    private func ms(_ d: Duration) -> String {
        let c = d.components
        return String(format: "%.2f", Double(c.seconds) * 1000 + Double(c.attoseconds) / 1e15)
    }

    /// Prefix-index sizing (design V only): size + type-ahead query cost.
    @Test(arguments: ["", "prefix='3'", "prefix='2 3'", "prefix='2 3 4'"])
    func prefixSizing(prefix: String) throws {
        let dir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("13o-bench")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("prefix-\(prefix.count).sqlite")
        let queue = try corpus(at: url, notes: 5_000, blocksPerNote: 10)
        let build = try queue.write { try install(.extView, $0, prefix: prefix) }
        let fts = try queue.read { db in
            try Int64.fetchOne(db, sql: "SELECT SUM(pgsize) FROM dbstat WHERE name LIKE 's_fts%'") ?? 0
        }
        let vocab = Vocabulary(size: 30_000)
        let clock = ContinuousClock()
        var lines: [String] = []
        for term in [String(vocab.words[3].prefix(2)) + "*", String(vocab.words[40].prefix(3)) + "*",
                     String(vocab.words[400].prefix(4)) + "*", String(vocab.words[4000].prefix(5)) + "*"] {
            var best: Duration = .seconds(1000)
            var p = 0
            for _ in 0..<5 {
                try queue.read { db in
                    _ = pageRequests(db, reset: true)
                    let t = clock.now
                    _ = try Row.fetchAll(db, sql: """
                        SELECT d.id FROM s_fts JOIN s_doc d ON d.id = s_fts.rowid
                        WHERE s_fts MATCH ? ORDER BY rank LIMIT 50
                        """, arguments: [term])
                    let d = clock.now - t
                    if d < best { best = d }
                    p = pageRequests(db, reset: false)
                }
            }
            let count = try queue.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM s_fts WHERE s_fts MATCH ?", arguments: [term]) ?? 0 }
            lines.append("\(term) matches=\(count) \(ms(best))ms/\(p)pg")
        }
        print("[13o-prefix] [\(prefix)] build=\(ms(build))ms fts=\(fts / 1024)KB :: \(lines.joined(separator: " · "))")
        try queue.close()
        try? FileManager.default.removeItem(at: url)
    }

    @Test(arguments: [1_000, 5_000])
    func bench(notes: Int) throws {
        let dir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("13o-bench")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let clock = ContinuousClock()
        for design in Design.allCases {
            let url = dir.appendingPathComponent("bench-\(design.rawValue)-\(notes).sqlite")
            let queue = try corpus(at: url, notes: notes, blocksPerNote: 10)
            let build = try queue.write { try install(design, $0) }
            let sizes = try queue.read { db in
                try Row.fetchAll(db, sql: """
                    SELECT CASE WHEN name LIKE 's_fts%' THEN 'fts' WHEN name LIKE 's_doc%' THEN 'doc'
                                WHEN name = 'variant' THEN 'variant' ELSE 'other' END AS grp,
                           SUM(pgsize) AS bytes FROM dbstat GROUP BY grp
                    """).map { "\($0["grp"] as String)=\(((($0["bytes"] as Int64?) ?? 0) / 1024))KB" }
            }
            // Autosave bench: 300 single-row text edits, each its own transaction.
            var rng = SeededGenerator(seed: 9)
            let blocks = notes * 10
            var pages = 0
            let t0 = clock.now
            for i in 0..<300 {
                let n = Int(rng.next() % UInt64(blocks))
                let id = String(format: "b%07d-%03d-v1", n / 10, n % 10)
                try queue.write { db in
                    _ = pageRequests(db, reset: true)
                    try db.execute(sql: "UPDATE variant SET working_text = working_text || ?  WHERE id = ?",
                                   arguments: [" edit\(i)", id])
                    pages += pageRequests(db, reset: false)
                }
            }
            let save = clock.now - t0
            // Queries.
            let vocab = Vocabulary(size: 30_000)
            let probes: [(String, String)] = [
                ("rare", vocab.words[20_000]), ("mid", vocab.words[100]),
                ("common", vocab.words[0]), ("prefix2", String(vocab.words[3].prefix(2)) + "*"),
                ("prefix3", String(vocab.words[40].prefix(3)) + "*"),
                ("and2", "\(vocab.words[100]) \(vocab.words[200])"),
            ]
            var qlines: [String] = []
            for (label, term) in probes {
                let snippetSQL: String
                switch design {
                case .contentless: snippetSQL = "NULL"
                default: snippetSQL = "snippet(s_fts, 0, '[', ']', '…', 10)"
                }
                let column = """
                    SELECT d.id, d.kind, d.src_id, \(snippetSQL) AS s FROM s_fts JOIN s_doc d ON d.id = s_fts.rowid
                    WHERE s_fts MATCH ? AND d.wing_id = '' ORDER BY rank LIMIT 50
                    """
                let joined = """
                    SELECT d.id, d.kind, d.src_id, \(snippetSQL) AS s FROM s_fts JOIN s_doc d ON d.id = s_fts.rowid
                    JOIN variant v ON v.id = d.src_id
                    JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                    JOIN container c ON c.id = cb.container_id
                    WHERE s_fts MATCH ? AND c.wing_id = '' ORDER BY rank LIMIT 50
                    """
                let count = try queue.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM s_fts WHERE s_fts MATCH ?", arguments: [term]) ?? 0 }
                func run(_ sql: String) throws -> (Duration, Int, Int) {
                    var best: Duration = .seconds(1000)
                    var p = 0, rows = 0
                    for _ in 0..<5 {
                        try queue.read { db in
                            _ = pageRequests(db, reset: true)
                            let t = clock.now
                            rows = try Row.fetchAll(db, sql: sql, arguments: [term]).count
                            let d = clock.now - t
                            if d < best { best = d }
                            p = pageRequests(db, reset: false)
                        }
                    }
                    return (best, p, rows)
                }
                let (cT, cP, cR) = try run(column)
                let (jT, jP, _) = try run(joined)
                qlines.append("\(label)[\(term)] matches=\(count) rows=\(cR) col=\(ms(cT))ms/\(cP)pg join=\(ms(jT))ms/\(jP)pg")
            }
            // Minority scopes: wing-two (10% of docs) and ONE note, column vs join.
            if design == .extView {
                let book = (0..<50).map { String(format: "n%07d", $0 * (notes / 50)) }
                try queue.write { db in
                    try db.execute(sql: "INSERT INTO reading (id, name, kind, created_at, updated_at) VALUES ('bk', 'b', 'book', 'x', 'x')")
                    for (i, n) in book.enumerated() {
                        try db.execute(sql: """
                            INSERT INTO reading_post (id, reading_id, post_id, position, created_at)
                            VALUES (?, 'bk', ?, ?, 'x')
                            """, arguments: ["rp\(i)", n, String(format: "a%03d", i)])
                    }
                }
                for (label, term) in [("common", vocab.words[0]), ("prefix2", String(vocab.words[3].prefix(2)) + "*"), ("mid", vocab.words[100])] {
                    let scopes: [(String, String)] = [
                        ("wing2-col", "SELECT d.id FROM s_fts JOIN s_doc d ON d.id = s_fts.rowid WHERE s_fts MATCH ? AND d.wing_id = 'wing-two' ORDER BY rank LIMIT 50"),
                        ("wing2-join", """
                            SELECT d.id FROM s_fts JOIN s_doc d ON d.id = s_fts.rowid
                            JOIN variant v ON v.id = d.src_id
                            JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                            JOIN container c ON c.id = cb.container_id
                            WHERE s_fts MATCH ? AND c.wing_id = 'wing-two' ORDER BY rank LIMIT 50
                            """),
                        ("note-col", "SELECT d.id FROM s_fts JOIN s_doc d ON d.id = s_fts.rowid WHERE s_fts MATCH ? AND d.note_id = 'n0000007' ORDER BY rank LIMIT 50"),
                        ("note-join", """
                            SELECT d.id FROM s_fts JOIN s_doc d ON d.id = s_fts.rowid
                            JOIN container_block cb ON cb.block_id = d.block_id AND cb.deleted_at IS NULL
                            WHERE s_fts MATCH ? AND cb.container_id = 'n0000007' ORDER BY rank LIMIT 50
                            """),
                        ("note-driven", """
                            SELECT d.id FROM s_fts JOIN s_doc d ON d.id = s_fts.rowid
                            WHERE s_fts MATCH ? AND s_fts.rowid IN (
                              SELECT d2.id FROM container_block cb JOIN s_doc d2 ON d2.block_id = cb.block_id
                              WHERE cb.container_id = 'n0000007' AND cb.deleted_at IS NULL)
                            ORDER BY rank LIMIT 50
                            """),
                        ("book-join", """
                            SELECT d.id FROM s_fts JOIN s_doc d ON d.id = s_fts.rowid
                            JOIN container_block cb ON cb.block_id = d.block_id AND cb.deleted_at IS NULL
                            WHERE s_fts MATCH ? AND cb.container_id IN (
                              SELECT post_id FROM reading_post WHERE reading_id = 'bk' AND deleted_at IS NULL)
                            ORDER BY rank LIMIT 50
                            """),
                    ]
                    for (name, sql) in scopes {
                        var best: Duration = .seconds(1000)
                        var p = 0, rows = 0
                        for _ in 0..<5 {
                            try queue.read { db in
                                _ = pageRequests(db, reset: true)
                                let t = clock.now
                                rows = try Row.fetchAll(db, sql: sql, arguments: [term]).count
                                let d = clock.now - t
                                if d < best { best = d }
                                p = pageRequests(db, reset: false)
                            }
                        }
                        qlines.append("scope \(label)[\(term)] \(name): rows=\(rows) \(ms(best))ms/\(p)pg")
                    }
                }
            }
            print("[13o-bench] \(design.rawValue) notes=\(notes) blocks=\(blocks) build=\(ms(build))ms sizes=\(sizes.joined(separator: " "))")
            print("[13o-bench] \(design.rawValue) notes=\(notes) autosave×300=\(ms(save))ms avg=\(ms(save / 300))ms pages/save=\(pages / 300)")
            for line in qlines { print("[13o-bench] \(design.rawValue) notes=\(notes) \(line)") }
            try queue.close()
            try? FileManager.default.removeItem(at: url)
        }
    }
}
