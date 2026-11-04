//
//  ApplyProfileMeasurementTests.swift
//  VariorumCoreTests
//
//  VX-497 (VX-500 U1b, D-497 (1)) — THE APPLY PROFILE at scale. A MEASUREMENT BENCH, not a pin: gated behind
//  `VARIORUM_APPLY_PROFILE=1` so the ordinary suite skips it (a skipped Swift Testing test still counts in "N tests" —
//  read the skipped lines). Client A seeds a D-497-sized corpus (1,200 posts × 30 blocks ≈ 109k synced rows — her real
//  library's size) and pushes it over the fake; client B — a FRESH device, by default on a keyed on-disk store (the
//  shipped shape) — pulls ONCE from zero in the production window (2,000 rows), and the engine's `ApplyProfileHook`
//  seam reports every phase: the download and the stage decode outside the apply; inside it the one-writer belt, the
//  straggler fixpoint, the row loop, the post-apply repairs and the commit prep; and the whole transaction's wall.
//  Numbers print as `[vx497-profile]` lines and land in the run record (`notes/plans/fixes/vx-500-sync-followups.md`,
//  the U1b record) as RELATIVE shares — this Mac's Debug figures, never promises.
//
//  Knobs (environment): VARIORUM_APPLY_PROFILE_POSTS (default 1200) · VARIORUM_APPLY_PROFILE_BLOCKS (default 30) ·
//  VARIORUM_APPLY_PROFILE_RUNS (default 3) · VARIORUM_APPLY_PROFILE_STORE = disk (default) | memory ·
//  VARIORUM_APPLY_PROFILE_INDEX_FIX — RETIRED at VX-500 U4: the v1_36 migration made the two FK child indexes
//  (block(default_variant_id), container_block(chosen_variant_id)) the store's own, so every run now measures the
//  fixed shape and the knob had nothing left to add; the pre-fix column survives in the U1b record
//  (`notes/plans/fixes/vx-500-sync-followups.md`, THE CANDIDATE FIX MEASURED) ·
//  VARIORUM_APPLY_PROFILE_TRACE=1 (a STATEMENT-LEVEL profile of each run's apply through GRDB's `.profile` trace on B's
//  writer connection — bench-side only, zero engine lines; the top statement shapes by total time, trigger time included
//  in the statement that fired them; it adds its own per-statement overhead, so a traced run is read for SHARES, never
//  beside an untraced run's absolute numbers).
//
//  The second suite is UNGATED and pins the seam itself: nil is inert (the default engine carries no hook), and a
//  wired hook hears every phase exactly once per round with exactly one `PRAGMA foreign_key_list` read per row of the
//  fixpoint's one pass — D-497's own claim ("the introspection runs once per ROW"), now a pin.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private let profiling = ProcessInfo.processInfo.environment["VARIORUM_APPLY_PROFILE"] == "1"

private func env(_ name: String, _ fallback: Int) -> Int {
    Int(ProcessInfo.processInfo.environment[name] ?? "") ?? fallback
}

/// A duration in whole milliseconds (Double, for the shares).
private func ms(_ duration: Duration) -> Double {
    Double(duration.components.seconds) * 1_000 + Double(duration.components.attoseconds) / 1e15
}

private let grouping: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.maximumFractionDigits = 0
    f.locale = Locale(identifier: "en_US")
    return f
}()

private func n(_ value: Double) -> String { grouping.string(from: NSNumber(value: value)) ?? String(value) }
private func n(_ value: Int) -> String { grouping.string(from: NSNumber(value: value)) ?? String(value) }
private func pct(_ part: Double, of whole: Double) -> String {
    whole > 0 ? String(format: "%5.1f%%", part / whole * 100) : "   n/a"
}

/// Right-aligns `text` in `width` columns (never `%s` — `String(format:)` reads a Swift String as a C pointer).
private func rpad(_ text: String, _ width: Int) -> String {
    String(repeating: " ", count: max(0, width - text.count)) + text
}

private func lpad(_ text: String, _ width: Int) -> String {
    text + String(repeating: " ", count: max(0, width - text.count))
}

/// A thread-safe sink for one pull's reports — the inner phases arrive on GRDB's writer queue.
private final class ProfileRecorder: Sendable {
    let phases = LockIsolated<[ApplyProfileHook.Phase: Duration]>([:])
    let phaseCounts = LockIsolated<[ApplyProfileHook.Phase: Int]>([:])
    let foreignKeyListCalls = LockIsolated(0)
    let foreignKeyListTime = LockIsolated(Duration.zero)

    var hook: ApplyProfileHook {
        ApplyProfileHook(
            phase: { [phases, phaseCounts] phase, duration in
                phases.withValue { $0[phase, default: .zero] += duration }
                phaseCounts.withValue { $0[phase, default: 0] += 1 }
            },
            foreignKeyList: { [foreignKeyListCalls, foreignKeyListTime] duration in
                foreignKeyListCalls.withValue { $0 += 1 }
                foreignKeyListTime.withValue { $0 += duration }
            })
    }

    func total(_ phase: ApplyProfileHook.Phase) -> Duration { phases.value[phase] ?? .zero }
    func count(_ phase: ApplyProfileHook.Phase) -> Int { phaseCounts.value[phase] ?? 0 }
}

/// VARIORUM_APPLY_PROFILE_TRACE=1 — one connection's statements, aggregated by SQL shape (the unexpanded text, so
/// bound values never split a shape; `PRAGMA foreign_key_list(<table>)` folded to one key). Installed on B's WRITER
/// connection before the pull (`Database.trace` is connection state, and a pool has one writer), so every statement
/// of the apply — and of the stage writes — lands here with the time SQLite measured for it, triggers included.
private final class StatementTrace: Sendable {
    struct Shape { var count = 0; var seconds = 0.0 }
    let shapes = LockIsolated<[String: Shape]>([:])

    static func key(_ sql: String) -> String {
        if sql.hasPrefix("PRAGMA foreign_key_list(") { return "PRAGMA foreign_key_list(<table>)" }
        let oneLine = sql.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: " ")
        return oneLine.count > 150 ? String(oneLine.prefix(150)) + "…" : oneLine
    }

    func install(on db: AppDatabase) throws {
        try db.write { connection in
            connection.trace(options: .profile) { [shapes] event in
                guard case .profile(let statement, let duration) = event else { return }
                let key = Self.key(statement.sql)
                shapes.withValue { $0[key, default: Shape()].count += 1; $0[key, default: Shape()].seconds += duration }
            }
        }
    }

    func remove(from db: AppDatabase) throws {
        try db.write { connection in connection.trace(options: .profile, nil) }
    }

    /// The report: every shape over `floor` seconds, descending, with its share of the traced SQL time.
    func lines(prefix: String, top: Int = 30) -> [String] {
        let all = shapes.value
        let total = all.values.reduce(0.0) { $0 + $1.seconds }
        let statements = all.values.reduce(0) { $0 + $1.count }
        var out = ["\(prefix) SQL time SQLite measured on B's writer: \(n(total * 1_000)) ms over \(n(statements)) statements in \(all.count) shapes"]
        for (key, shape) in all.sorted(by: { $0.value.seconds > $1.value.seconds }).prefix(top) {
            let perCall = shape.count > 0 ? shape.seconds * 1_000_000 / Double(shape.count) : 0
            out.append("\(prefix)   \(rpad(n(shape.seconds * 1_000), 9)) ms \(pct(shape.seconds, of: total))  \(rpad(n(shape.count), 9)) × \(rpad(String(format: "%.1f", perCall), 8)) µs  \(key)")
        }
        return out
    }
}

/// The corpus both suites seed: `posts` journal posts of `blocksPerPost` one-line blocks (the shape
/// `SyncProgressTests` / `ResumableCatchUpTests` seed). Each block is three synced rows (block · variant ·
/// container_block) and each post one more (container), so 1,200 × 30 ≈ 109k rows.
private func seedCorpus(_ client: SyncClient, posts: Int, blocksPerPost: Int) throws {
    try client.with { ops, _ in
        for p in 0..<posts {
            let post = try ops.createPost(title: "post \(p)", profile: .journal)
            for b in 0..<blocksPerPost {
                _ = try ops.newBlock(in: post.id, text: "post \(p), block \(b)", at: .end)
            }
        }
    }
}

/// One profiled pull, as the record tabulates it.
private struct Sample {
    var rows: Int
    var pullWall: Duration
    var phases: [ApplyProfileHook.Phase: Duration]
    var foreignKeyListCalls: Int
    var foreignKeyListTime: Duration

    static let innerPhases: [ApplyProfileHook.Phase] = [.belt, .fixpoint, .rowLoop, .repairs, .commitPrep]

    var apply: Duration { phases[.applyTransaction] ?? .zero }
    var innerSum: Duration { Self.innerPhases.reduce(Duration.zero) { $0 + (phases[$1] ?? .zero) } }
    var transactionOverhead: Duration { apply - innerSum }

    /// The run's lines.
    func lines(title: String) -> [String] {
        let applyMS = ms(apply)
        var out: [String] = []
        let rate = applyMS > 0 ? Double(rows) / (applyMS / 1_000) : 0
        out.append(
            "\(title): \(n(rows)) rows · pull wall \(n(ms(pullWall))) ms · apply \(n(applyMS)) ms (\(n(rate)) rows/s)")
        out.append("[vx497-profile]   download      \(rpad(n(ms(phases[.download] ?? .zero)), 10)) ms   (outside the apply; the fake transport in-process)")
        out.append("[vx497-profile]   stageDecode   \(rpad(n(ms(phases[.stageDecode] ?? .zero)), 10)) ms   (outside the apply)")
        for phase in Self.innerPhases {
            let d = ms(phases[phase] ?? .zero)
            out.append("[vx497-profile]   \(lpad(phase.rawValue, 13)) \(rpad(n(d), 10)) ms  \(pct(d, of: applyMS)) of the apply")
        }
        let overhead = ms(transactionOverhead)
        out.append("[vx497-profile]   txn overhead  \(rpad(n(overhead), 10)) ms  \(pct(overhead, of: applyMS)) of the apply   (applyTransaction − the five: begin, COMMIT, the hops)")
        let fkMS = ms(foreignKeyListTime)
        let perCall = foreignKeyListCalls > 0 ? fkMS * 1_000 / Double(foreignKeyListCalls) : 0
        out.append("[vx497-profile]   PRAGMA foreign_key_list: \(n(foreignKeyListCalls)) calls · \(n(fkMS)) ms in all (\(String(format: "%.1f", perCall)) µs each) = \(pct(fkMS, of: applyMS)) of the apply, \(pct(fkMS, of: ms(phases[.fixpoint] ?? .zero))) of the fixpoint")
        return out
    }
}

private func median(_ values: [Duration]) -> Duration {
    let sorted = values.sorted()
    return sorted.isEmpty ? .zero : sorted[sorted.count / 2]
}

/// THE BENCH (gated). One test, so the seed and the push are paid once and every run pulls the same feed.
@Suite("VX-497 — the apply profile at scale (gated: VARIORUM_APPLY_PROFILE=1)", .enabled(if: profiling), .serialized)
struct ApplyProfileMeasurementTests {
    @Test func aFirstCatchUpsApplyTimedByPhase() async throws {
        let posts = env("VARIORUM_APPLY_PROFILE_POSTS", 1_200)
        let blocks = env("VARIORUM_APPLY_PROFILE_BLOCKS", 30)
        let runs = max(1, min(15, env("VARIORUM_APPLY_PROFILE_RUNS", 3)))
        let onDisk = (ProcessInfo.processInfo.environment["VARIORUM_APPLY_PROFILE_STORE"] ?? "disk") != "memory"
        let tracing = ProcessInfo.processInfo.environment["VARIORUM_APPLY_PROFILE_TRACE"] == "1"
        let storeKind = (onDisk ? "keyed on-disk store" : "in-memory store") + (tracing ? ", statement-traced" : "")
        setvbuf(stdout, nil, _IOLBF, 0)  // line-buffered: a log being polled shows each run as it ends
        print("[vx497-profile] corpus \(n(posts)) posts × \(n(blocks)) blocks · \(runs) run(s) · B on a \(storeKind) · window 2,000")

        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let seedStart = ContinuousClock.now
        try seedCorpus(a, posts: posts, blocksPerPost: blocks)
        print("[vx497-profile] A seeded in \(n(ms(ContinuousClock.now - seedStart))) ms")
        let pushStart = ContinuousClock.now
        let pushed = try await a.push()
        let head = await server.headSeq
        print("[vx497-profile] A pushed \(n(pushed.accepted)) rows in \(n(ms(ContinuousClock.now - pushStart))) ms (\(pushed.iterations) iteration(s)); server head \(head)")
        #expect(try a.outboxCount() == 0, "the whole corpus reached the fake")

        let scratch = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx497-profile-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: scratch) }

        var samples: [Sample] = []
        for run in 1...runs {
            let b = try SyncClient(
                name: "B\(run)", prefix: String(format: "B%X", run), transport: server, seed: UInt64(run + 1),
                storeURL: onDisk ? scratch.appendingPathComponent("b\(run).sqlite") : nil)
            let recorder = ProfileRecorder()
            b.applyProfile = recorder.hook
            let trace = tracing ? StatementTrace() : nil
            try trace?.install(on: b.db)
            let start = ContinuousClock.now
            let report = try await b.pull(batchSize: 2_000)  // the production window (ResumableCatchUpTests pins it)
            let wall = ContinuousClock.now - start
            try trace?.remove(from: b.db)
            #expect(!report.stalled, "a from-zero catch-up over a complete feed never stalls")
            #expect(try b.cursor() == head, "converged")
            for phase in ApplyProfileHook.Phase.allCases {
                #expect(recorder.count(phase) == 1, "\(phase) reported once in run \(run)")
            }
            let sample = Sample(
                rows: report.applied + report.merged, pullWall: wall, phases: recorder.phases.value,
                foreignKeyListCalls: recorder.foreignKeyListCalls.value,
                foreignKeyListTime: recorder.foreignKeyListTime.value)
            samples.append(sample)
            for line in sample.lines(title: "[vx497-profile] run \(run) (\(storeKind))") { print(line) }
            for line in trace?.lines(prefix: "[vx497-profile]") ?? [] { print(line) }
        }

        // The medians, per metric, against the median apply.
        var medianPhases: [ApplyProfileHook.Phase: Duration] = [:]
        for phase in ApplyProfileHook.Phase.allCases {
            medianPhases[phase] = median(samples.map { $0.phases[phase] ?? .zero })
        }
        let medianSample = Sample(
            rows: samples[0].rows, pullWall: median(samples.map(\.pullWall)), phases: medianPhases,
            foreignKeyListCalls: samples[0].foreignKeyListCalls,
            foreignKeyListTime: median(samples.map(\.foreignKeyListTime)))
        for line in medianSample.lines(title: "[vx497-profile] MEDIAN of \(runs) (\(storeKind))") { print(line) }
    }
}

/// THE FTS5 PROBE (gated with the bench): is a 7 ms FTS5 insert inherent to the shipped index shape in this build? Four
/// arms, each a fresh in-memory store with the search family's shape in miniature (a source table, a doc table, the
/// `search_text`-style view, an FTS5 table) and N inserts in ONE transaction through the capture trigger's own
/// statement shape (`INSERT INTO fts (rowid, body) SELECT id, ? FROM doc WHERE src_id = ?`); only the FTS insert
/// statements are timed. Knob: VARIORUM_APPLY_PROFILE_FTS_N (default 10,000).
@Suite("VX-497 — the FTS5 insert cost, standalone (gated: VARIORUM_APPLY_PROFILE=1)", .enabled(if: profiling), .serialized)
struct ApplyProfileFTSProbeTests {
    private struct Arm {
        let name: String
        /// The FTS5 options after `body` (external content or not).
        let options: String
        let bodyLength: Int
    }

    @Test func fts5InsertCostByTableShape() throws {
        let count = max(100, env("VARIORUM_APPLY_PROFILE_FTS_N", 10_000))
        let shipped = "content = 'probe_text', content_rowid = 'id', tokenize = 'unicode61 remove_diacritics 2', prefix = '2 3'"
        let arms = [
            Arm(name: "the shipped shape (external content over the view, remove_diacritics 2, prefix '2 3'), ~18-char bodies",
                options: shipped, bodyLength: 18),
            Arm(name: "the shipped shape, ~400-char bodies (a paragraph take)", options: shipped, bodyLength: 400),
            Arm(name: "external content, NO prefix index, ~18-char bodies",
                options: "content = 'probe_text', content_rowid = 'id', tokenize = 'unicode61 remove_diacritics 2'", bodyLength: 18),
            Arm(name: "a plain FTS5 table (its own content), remove_diacritics 2, prefix '2 3', ~18-char bodies",
                options: "tokenize = 'unicode61 remove_diacritics 2', prefix = '2 3'", bodyLength: 18),
        ]
        print("[vx497-fts] \(n(count)) inserts per arm, one transaction each, the FTS insert statements timed alone")
        for arm in arms {
            let db = try DatabaseQueue()
            try db.write { db in
                try db.execute(sql: """
                    CREATE TABLE probe_src (id TEXT PRIMARY KEY, txt TEXT);
                    CREATE TABLE probe_doc (id INTEGER PRIMARY KEY AUTOINCREMENT, kind TEXT NOT NULL, src_id TEXT NOT NULL);
                    CREATE UNIQUE INDEX uq_probe_doc_src ON probe_doc(kind, src_id);
                    CREATE VIEW probe_text AS
                      SELECT d.id AS id, (SELECT s.txt FROM probe_src s WHERE s.id = d.src_id) AS body FROM probe_doc d;
                    CREATE VIRTUAL TABLE probe_fts USING fts5(body, \(arm.options));
                    """)
            }
            var ftsTime = Duration.zero
            let wallStart = ContinuousClock.now
            try db.write { db in
                let insertSrc = try db.cachedStatement(sql: "INSERT INTO probe_src (id, txt) VALUES (?, ?)")
                let insertDoc = try db.cachedStatement(sql: "INSERT INTO probe_doc (kind, src_id) VALUES ('take', ?)")
                let insertFTS = try db.cachedStatement(
                    sql: "INSERT INTO probe_fts (rowid, body) SELECT id, ? FROM probe_doc WHERE kind = 'take' AND src_id = ?")
                for i in 0..<count {
                    let id = String(format: "AA000000-0000-4000-8000-%012d", i)
                    let body = String(repeating: "post \(i % 97), block \(i % 31) ", count: max(1, arm.bodyLength / 18))
                    try insertSrc.execute(arguments: [id, body])
                    try insertDoc.execute(arguments: [id])
                    let start = ContinuousClock.now
                    try insertFTS.execute(arguments: [body, id])
                    ftsTime += ContinuousClock.now - start
                }
            }
            let wall = ContinuousClock.now - wallStart
            let perInsert = ms(ftsTime) * 1_000 / Double(count)
            print("[vx497-fts]   \(rpad(n(ms(ftsTime)), 8)) ms FTS (\(String(format: "%.1f", perInsert)) µs an insert) · \(rpad(n(ms(wall)), 8)) ms the transaction whole · \(arm.name)")
        }
    }
}

/// THE BISECTION (gated with the bench): the same `INSERT INTO variant` on the REAL migrated schema, in apply mode (the
/// outbox trigger's body muted exactly as under a pull), N takes each under a new block, in one transaction — with
/// (A) every trigger standing, (B) the two search-capture triggers on `variant` dropped, (C) every trigger on `variant`
/// dropped, and (D) B plus the capture's three statements run BY HAND after each insert so the FTS5 write against the
/// real `search_fts` is timed alone. Only the named statements are timed. Knobs: VARIORUM_APPLY_PROFILE_BISECT_N
/// (default 2,000); VARIORUM_APPLY_PROFILE_BISECT_STORE = memory (default) | disk (a keyed on-disk store, the shipped
/// shape — where FTS5's segment reads become SQLCipher page reads). Prints the triggers `sqlite_master` holds on
/// `variant` first, with the store's cache_size · page_size · journal_mode.
@Suite("VX-497 — the variant INSERT's cost by trigger set, on the real schema (gated: VARIORUM_APPLY_PROFILE=1)",
       .enabled(if: profiling), .serialized)
struct ApplyProfileBisectionTests {
    private enum Arm: String, CaseIterable {
        case everyTrigger = "A. every trigger standing"
        case noSearchCapture = "B. the two search-capture triggers on variant dropped"
        case noVariantTriggers = "C. every trigger on variant dropped"
        case captureByHand = "D. as B, the capture's three statements run by hand (the FTS5 write timed alone)"
        /// THE APPLY'S SHAPE: `PRAGMA defer_foreign_keys = ON` (what `applyingRemoteWithDeferredFKs` sets), every block
        /// landed FIRST with its `default_variant_id` naming a take not yet inserted (the feed's registry order), then
        /// the takes — every trigger standing.
        case applyShape = "E. THE APPLY'S SHAPE — defer_foreign_keys ON; all blocks first, each default_variant_id → its not-yet-inserted take; then the takes"
        /// E with an index on the unindexed FK child column.
        case applyShapeIndexed = "F. as E, plus CREATE INDEX ON block(default_variant_id)"
        /// E with no pending violation: the blocks' `default_variant_id` NULL (does the pragma alone cost the scan?).
        case applyShapeNoPending = "G. as E, but every block's default_variant_id NULL (no pending violation)"

        var blocksFirst: Bool { [.applyShape, .applyShapeIndexed, .applyShapeNoPending].contains(self) }
        var defersForeignKeys: Bool { blocksFirst }
        var defaultVariantSet: Bool { self == .applyShape || self == .applyShapeIndexed }
    }

    @Test func variantInsertCostByTriggerSet() throws {
        let count = max(100, env("VARIORUM_APPLY_PROFILE_BISECT_N", 2_000))
        let onDisk = ProcessInfo.processInfo.environment["VARIORUM_APPLY_PROFILE_BISECT_STORE"] == "disk"
        let scratch = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx497-bisect-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: scratch) }
        func freshStore(_ name: String) throws -> AppDatabase {
            onDisk ? try AppDatabase.openStore(at: scratch.appendingPathComponent("\(name).sqlite")) : try AppDatabase.inMemory()
        }
        let (triggers, pragmas) = try freshStore("probe").read { db -> ([String], String) in
            let names = try String.fetchAll(
                db, sql: "SELECT name FROM sqlite_master WHERE type = 'trigger' AND tbl_name = 'variant' ORDER BY name")
            let cache = try Int.fetchOne(db, sql: "PRAGMA cache_size") ?? 0
            let page = try Int.fetchOne(db, sql: "PRAGMA page_size") ?? 0
            let journal = try String.fetchOne(db, sql: "PRAGMA journal_mode") ?? "?"
            return (names, "cache_size \(cache) · page_size \(page) · journal_mode \(journal)")
        }
        print("[vx497-bisect] triggers on variant (\(triggers.count)): \(triggers.joined(separator: " · "))")
        print("[vx497-bisect] \(n(count)) takes per arm, one apply-mode transaction each, on \(onDisk ? "a keyed on-disk store" : "an in-memory store") (\(pragmas))")
        for arm in Arm.allCases {
            let store = try freshStore(String(arm.rawValue.prefix(1)).lowercased())
            try store.write { db in
                switch arm {
                case .everyTrigger: break
                case .noSearchCapture, .captureByHand:
                    for name in triggers where name.hasPrefix("search_variant_") && name.hasSuffix("_insert") {
                        try db.execute(sql: "DROP TRIGGER \(name)")
                    }
                case .noVariantTriggers:
                    for name in triggers { try db.execute(sql: "DROP TRIGGER \(name)") }
                case .applyShape, .applyShapeNoPending: break
                case .applyShapeIndexed:
                    try db.execute(sql: "CREATE INDEX idx_probe_block_default_variant ON block(default_variant_id)")
                }
            }
            var insertTime = Duration.zero
            var ftsTime = Duration.zero
            var docTime = Duration.zero
            let wallStart = ContinuousClock.now
            try store.applyingRemote { db in
                if arm.defersForeignKeys { try db.execute(sql: "PRAGMA defer_foreign_keys = ON") }
                let insertBlock = try db.cachedStatement(sql: """
                    INSERT INTO block (id, default_variant_id, created_at, updated_at, sync_version)
                    VALUES (?, ?, '2026-07-01T00:00:00.000Z', '2026-07-01T00:00:00.000Z', 1)
                    """)
                let insertVariant = try db.cachedStatement(sql: """
                    INSERT INTO variant (block_id, created_at, deleted_at, fan_position, id, label, locked, parent_variant_id, status,
                      updated_at, working_text, sync_version)
                    VALUES (?, '2026-07-01T00:00:00.000Z', NULL, 'a0', ?, NULL, 0, NULL, 'active', '2026-07-01T00:00:00.000Z', ?, 1)
                    """)
                let deleteDoc = try db.cachedStatement(sql: "DELETE FROM search_doc WHERE kind = 'take' AND src_id = ?")
                let insertDoc = try db.cachedStatement(sql: """
                    INSERT INTO search_doc (kind, src_id, block_id, archived) SELECT 'take', ?, ?, 0
                      ON CONFLICT (kind, src_id) DO UPDATE SET block_id = excluded.block_id, archived = excluded.archived
                    """)
                let insertFTS = try db.cachedStatement(
                    sql: "INSERT INTO search_fts (rowid, body) SELECT id, ? FROM search_doc WHERE kind = 'take' AND src_id = ?")
                func blockID(_ i: Int) -> String { String(format: "BB000000-0000-4000-8000-%012d", i) }
                func variantID(_ i: Int) -> String { String(format: "CC000000-0000-4000-8000-%012d", i) }
                if arm.blocksFirst {
                    for i in 0..<count {
                        try insertBlock.execute(arguments: [blockID(i), arm.defaultVariantSet ? variantID(i) : nil])
                    }
                }
                for i in 0..<count {
                    let blockID = blockID(i)
                    let variantID = variantID(i)
                    let body = "post \(i % 97), block \(i % 31)"
                    if !arm.blocksFirst { try insertBlock.execute(arguments: [blockID, nil]) }
                    let start = ContinuousClock.now
                    try insertVariant.execute(arguments: [blockID, variantID, body])
                    insertTime += ContinuousClock.now - start
                    if arm == .captureByHand {
                        let d0 = ContinuousClock.now
                        try deleteDoc.execute(arguments: [variantID])
                        try insertDoc.execute(arguments: [variantID, blockID])
                        let f0 = ContinuousClock.now
                        docTime += f0 - d0
                        try insertFTS.execute(arguments: [body, variantID])
                        ftsTime += ContinuousClock.now - f0
                    }
                }
            }
            let wall = ContinuousClock.now - wallStart
            let perInsert = ms(insertTime) * 1_000 / Double(count)
            var line = "[vx497-bisect]   INSERT INTO variant \(rpad(String(format: "%.1f", perInsert), 8)) µs each (\(rpad(n(ms(insertTime)), 7)) ms) · transaction whole \(rpad(n(ms(wall)), 7)) ms · \(arm.rawValue)"
            if arm == .captureByHand {
                line += " · by hand: search_doc \(String(format: "%.1f", ms(docTime) * 1_000 / Double(count))) µs, search_fts \(String(format: "%.1f", ms(ftsTime) * 1_000 / Double(count))) µs each"
            }
            print(line)
        }
    }
}

/// THE SEAM'S PINS (ungated, cheap): nil is inert; a wired hook hears every phase once per round and exactly one
/// `PRAGMA foreign_key_list` read per row of the fixpoint's one pass.
@Suite("VX-497 — the apply profile seam: nil is inert; a hook hears every phase and one PRAGMA per fixpoint row")
struct ApplyProfileSeamTests {
    @Test func theDefaultEngineCarriesNoHook() {
        #expect(SyncEngine(transport: FakeSyncServer()).applyProfile == nil, "nil = inert — production never wires one")
    }

    @Test func aWiredHookHearsEveryPhaseOnceAndOnePragmaPerRowOfTheFixpoint() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)
        try seedCorpus(a, posts: 3, blocksPerPost: 4)
        try await a.push()
        let recorder = ProfileRecorder()
        b.applyProfile = recorder.hook
        let report = try await b.pull(batchSize: 200)  // one window holds the feed
        #expect(!report.stalled)
        #expect(try b.cursor() == (await server.headSeq), "converged")
        let rows = report.applied + report.merged
        #expect(rows > 12, "non-vacuous: the corpus's rows all landed")
        for phase in ApplyProfileHook.Phase.allCases {
            #expect(recorder.count(phase) == 1, "\(phase) is reported exactly once per round")
        }
        #expect(recorder.foreignKeyListCalls.value == rows,
                "one PRAGMA foreign_key_list per row of the fixpoint's single pass — D-497's claim, pinned")
        let inner = Sample.innerPhases.reduce(Duration.zero) { $0 + recorder.total($1) }
        #expect(inner <= recorder.total(.applyTransaction), "the five inner phases fit inside the transaction's wall")
        #expect(recorder.foreignKeyListTime.value <= recorder.total(.fixpoint),
                "the introspection's time is part of the fixpoint's")
        #expect(recorder.total(.download) > .zero && recorder.total(.stageDecode) > .zero)
    }
}
