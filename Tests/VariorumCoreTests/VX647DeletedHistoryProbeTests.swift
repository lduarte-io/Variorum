//
//  VX647DeletedHistoryProbeTests.swift
//  VariorumCoreTests
//
//  VX-647 (VX-648 batch 1) — the TRACE PROBE, not a pin. Her report: "when
//  a note has a lot of deleted blocks, making new blocks with newlines and
//  deleting blocks starts to have a several second (like 3-5 seconds at
//  least) delay." This file measures every store road a Write structural
//  flight runs (and every held observation an open note re-runs on a
//  structural write) as a function of the note's deleted HISTORY, on a
//  keyed on-disk store (SQLCipher, the shipped shape). It prints numbers;
//  it asserts nothing. Gated: runs only with `VX647_PROBE=1` in the
//  environment, so the ordinary suite never pays for it.
//
//  Knobs (environment): VX647_CORPUS_POSTS (default 200), VX647_CORPUS_BLOCKS
//  (default 20), VX647_STEPS (default "0,100,400,1000").
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private let probeEnabled = ProcessInfo.processInfo.environment["VX647_PROBE"] == "1"

/// Median wall time of `runs` executions, in milliseconds.
private func medianMS(runs: Int = 5, _ body: () throws -> Void) rethrows -> Double {
    var samples: [Double] = []
    for _ in 0..<runs {
        let start = DispatchTime.now().uptimeNanoseconds
        try body()
        samples.append(Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000)
    }
    samples.sort()
    return samples[samples.count / 2]
}

private func fmt(_ ms: Double) -> String { String(format: "%9.3f", ms) }

private func env(_ name: String, _ fallback: Int) -> Int {
    Int(ProcessInfo.processInfo.environment[name] ?? "") ?? fallback
}

private var probeSteps: [Int] {
    (ProcessInfo.processInfo.environment["VX647_STEPS"] ?? "0,100,400,1000")
        .split(separator: ",").compactMap { Int($0) }
}

/// A keyed on-disk store in a fresh temp dir (removed by the caller).
private func keyedStore() throws -> (AppDatabase, URL) {
    let dir = FileManager.default.temporaryDirectory
        .appendingPathComponent("vx647-probe-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    var keyBytes = Data(count: 32)
    for i in 0..<32 { keyBytes[i] = UInt8((i * 37 + 11) & 0xFF) }
    let key = try #require(StoreKey(data: keyBytes))
    return (try AppDatabase.onDisk(url: dir.appendingPathComponent("probe.sqlite"), key: key), dir)
}

/// The deterministic world every probe runs in.
private func inWorld<T>(_ db: AppDatabase, _ tick: LockIsolated<Int>, _ body: () throws -> T) rethrows -> T {
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    return try withDependencies {
        $0.database = db
        // Random, not incrementing: the probe re-enters the world many times
        // over one store, and an incrementing generator restarts each time.
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
    } operation: {
        try body()
    }
}

/// The background corpus + the note under test (20 live paragraphs).
private func seedCorpusAndNote(_ ops: Operations) throws -> (noteID: String, live: [String]) {
    let posts = env("VX647_CORPUS_POSTS", 200)
    let blocks = env("VX647_CORPUS_BLOCKS", 20)
    for p in 0..<posts {
        let post = try ops.createPost(title: "corpus \(p)")
        for b in 0..<blocks {
            let minted = try ops.seedBlock(
                in: post.id, text: CorpusFactory.blockText(post: p, block: b))
            if b == 0, p % 5 == 0 { _ = try ops.divide(minted.block.id, cut: 24) }
        }
    }
    // The candidate fix, measured in place: a LOCAL index serving
    // tombstoned placements by block (VX647_WITH_INDEX=1).
    if ProcessInfo.processInfo.environment["VX647_WITH_INDEX"] == "1" {
        try ops.database.write { db in
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS vx647_probe_cblock_block ON container_block(block_id, deleted_at)")
        }
    }
    let note = try ops.createPost(title: "the note")
    var live: [String] = []
    for b in 0..<20 {
        live.append(try ops.seedBlock(
            in: note.id, text: CorpusFactory.blockText(post: 9999, block: b)).block.id)
    }
    return (note.id, live)
}

/// One CARVE round: ⏎ at a block's end mints an empty block, ⌫ in it carves
/// it — a TOMBSTONED block whose `last_container_id` is the note.
private func carveRound(_ ops: Operations, noteID: String, after anchor: String) throws {
    let minted = try ops.newBlock(in: noteID, text: "", at: .after(anchor))
    try ops.deleteBlock(
        minted.block.id, requiring: .emptyWithNothingUnshown(variantID: minted.variant.id))
}

/// One SEAM round: ⏎ mid-paragraph divides, ⌫ at the seam merges — both
/// sources RELEASED (live, unplaced, lineage edges). Returns the merged id.
private func seamRound(_ ops: Operations, block: String) throws -> String {
    let divided = try ops.divide(block, cut: 24)
    return try ops.merge(block, divided.block.id, joining: .deleteKeystroke).block.id
}

@Suite("VX-647 — deleted-history trace probe", .enabled(if: probeEnabled), .serialized)
struct VX647DeletedHistoryProbeTests {

    /// Every candidate road, timed directly (no observation held), as the
    /// note's history grows. Two history shapes, because her two gestures
    /// make two (see `carveRound` / `seamRound`).
    @Test(arguments: ["carve", "seam"])
    func directCost(shape: String) throws {
        let (db, dir) = try keyedStore()
        defer { try? FileManager.default.removeItem(at: dir) }
        let tick = LockIsolated(0)
        try inWorld(db, tick) {
            let ops = Operations()
            let (noteID, live) = try seedCorpusAndNote(ops)
            var seamBlock = live[10]
            print("VX647 direct shape=\(shape) corpus=\(env("VX647_CORPUS_POSTS", 200))x\(env("VX647_CORPUS_BLOCKS", 20))")
            print("VX647 direct    M | carveRnd  seamRnd   | renderPost trayCounts trayBlocks preserved unplacedO comments  presents  stamps    stranded")
            var current = 0
            for target in probeSteps {
                for _ in current..<target {
                    if shape == "carve" {
                        try carveRound(ops, noteID: noteID, after: live[19])
                    } else {
                        seamBlock = try seamRound(ops, block: seamBlock)
                    }
                }
                current = target
                let now = Date(timeIntervalSince1970: 1_782_864_000 + Double(tick.value) + 60)
                let tCarve = try medianMS(runs: 3) { try carveRound(ops, noteID: noteID, after: live[19]) }
                let tSeam = try medianMS(runs: 3) { seamBlock = try seamRound(ops, block: seamBlock) }
                let reads: [Double] = try db.read { d in
                    [
                        try medianMS { _ = try Queries.renderPost(d, containerID: noteID) },
                        try medianMS { _ = try Queries.trayCounts(d, postID: noteID, now: now) },
                        try medianMS { _ = try Queries.trayBlocks(d, postID: noteID, now: now, limit: 501) },
                        try medianMS(runs: 1) { _ = try Queries.preservedOriginals(d, postID: noteID, limit: 501) },
                        try medianMS { _ = try Queries.unplacedOrigins(d, inContainer: noteID) },
                        try medianMS { _ = try Queries.containerComments(d, containerID: noteID) },
                        try medianMS { _ = try Queries.blockPresentations(d, containerID: noteID) },
                        try medianMS { _ = try Queries.noteStamps(d, postID: noteID) },
                        try medianMS(runs: 1) { _ = try Queries.originalsStrandedBy(d, blockIDs: [seamBlock]) },
                    ]
                }
                print("VX647 direct \(String(format: "%5d", target)) | \(fmt(tCarve)) \(fmt(tSeam)) | "
                      + reads.map(fmt).joined(separator: " "))
            }
        }
    }

    /// The query plans of the suspects, printed.
    @Test func plans() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "n")
            let b = try ops.seedBlock(in: post.id, text: "one two three. four five.")
            try carveRound(ops, noteID: post.id, after: b.block.id)
            _ = try seamRound(ops, block: b.block.id)
            let statements: [(String, (Database) throws -> Void)] = [
                ("trayCounts", { _ = try Queries.trayCounts($0, postID: post.id, now: harnessNow) }),
                ("trayBlocks", { _ = try Queries.trayBlocks($0, postID: post.id, now: harnessNow, limit: 501) }),
                ("preservedOriginals", { _ = try Queries.preservedOriginals($0, postID: post.id, limit: 501) }),
                ("renderPost", { _ = try Queries.renderPost($0, containerID: post.id) }),
            ]
            for (name, body) in statements {
                let captured = LockIsolated<[String]>([])
                try db.read { d in
                    d.trace(options: .statement) { event in
                        guard case .statement(let s) = event else { return }
                        let sql = s.expandedSQL
                        captured.withValue { $0.append(sql) }
                    }
                    try body(d)
                    d.trace(options: [], nil)
                }
                for sql in captured.value where sql.uppercased().hasPrefix("SELECT") || sql.uppercased().hasPrefix("WITH") {
                    let plan = try db.read { d in
                        try Row.fetchAll(d, sql: "EXPLAIN QUERY PLAN \(sql)")
                            .map { "  " + (($0["detail"] as String?) ?? "") }
                    }
                    print("VX647 plan \(name):\n" + plan.joined(separator: "\n"))
                }
            }
        }
    }

    /// THE APP'S SHAPE: an open note in Write holds live observations; GRDB
    /// re-runs a `ValueObservation.tracking { }` fetch (non-constant region)
    /// SYNCHRONOUSLY on the writer connection inside `databaseDidCommit`, so
    /// every held fetch whose region a write touches is added to that
    /// write's latency. This times one carve round (two writes) and one
    /// autosave with the open note's held set running, and without it.
    @Test(arguments: ["carve", "seam"])
    func writeLatencyWithHeldObservations(shape: String) async throws {
        let (db, dir) = try keyedStore()
        defer { try? FileManager.default.removeItem(at: dir) }
        let tick = LockIsolated(0)
        let (noteID, live) = try inWorld(db, tick) {
            try seedCorpusAndNote(Operations())
        }
        let seamBox = LockIsolated(live[10])
        print("VX647 held shape=\(shape) corpus=\(env("VX647_CORPUS_POSTS", 200))x\(env("VX647_CORPUS_BLOCKS", 20))")
        print("VX647 held     M | carve(bare) carve(held) | autosave(bare) autosave(held) | trayCounts-only(held carve)")
        var current = 0
        for target in probeSteps {
            try inWorld(db, tick) {
                let ops = Operations()
                for _ in current..<target {
                    if shape == "carve" {
                        try carveRound(ops, noteID: noteID, after: live[19])
                    } else {
                        let next = try seamRound(ops, block: seamBox.value)
                        seamBox.setValue(next)
                    }
                }
            }
            current = target
            let now = Date(timeIntervalSince1970: 1_782_864_000 + Double(tick.value) + 60)
            let variantID = try #require(try await db.read { d in
                try String.fetchOne(
                    d, sql: "SELECT default_variant_id FROM block WHERE id = ?", arguments: [live[0]])
            })

            func measure() throws -> (carve: Double, autosave: Double) {
                try inWorld(db, tick) {
                    let ops = Operations()
                    let carve = try medianMS(runs: 3) {
                        try carveRound(ops, noteID: noteID, after: live[19])
                    }
                    var flip = false
                    let autosave = try medianMS(runs: 3) {
                        flip.toggle()
                        try ops.autosave(
                            variantID, text: CorpusFactory.blockText(post: 9999, block: 0) + (flip ? "x" : ""),
                            charDelta: 1)
                    }
                    return (carve, autosave)
                }
            }

            let bare = try measure()

            // The open note's held set (the Write pane + its host chrome):
            // EditorViewModel.start's five, PaneHost's tray badge, the
            // masthead stamp and title.
            let fetches: [@Sendable (Database) throws -> String] = [
                { try "\(Queries.renderPost($0, containerID: noteID).count)" },
                { try "\(String(describing: Queries.containerHeader($0, containerID: noteID)))" },
                { try "\(Queries.blockPresentations($0, containerID: noteID).count)" },
                { try "\(Queries.containerComments($0, containerID: noteID).count)" },
                { try "\(Queries.unplacedOrigins($0, inContainer: noteID).count)" },
                { try "\(Queries.trayCounts($0, postID: noteID, now: now))" },
                { try "\(String(describing: Queries.noteStamps($0, postID: noteID)))" },
                { try "\(String(describing: Queries.noteDisplayTitle($0, id: noteID)))" },
            ]
            let held = try await holding(db, fetches) { try measure() }
            let trayOnly = try await holding(db, [fetches[5]]) { try measure() }
            print("VX647 held \(String(format: "%5d", target)) | \(fmt(bare.carve)) \(fmt(held.carve)) | "
                  + "\(fmt(bare.autosave)) \(fmt(held.autosave)) | \(fmt(trayOnly.carve))")
        }
    }

    /// Starts each fetch as a held `AppDatabase.observe` (the app's road),
    /// waits for every first value, runs `body`, cancels.
    private func holding<T: Sendable>(
        _ db: AppDatabase, _ fetches: [@Sendable (Database) throws -> String],
        _ body: () throws -> T
    ) async throws -> T {
        let started = LockIsolated(0)
        var tasks: [Task<Void, Never>] = []
        for fetch in fetches {
            tasks.append(Task {
                do {
                    for try await _ in db.observe(fetch) {
                        started.withValue { $0 += 1 }
                    }
                } catch {}
            })
        }
        while started.value < fetches.count { try await Task.sleep(nanoseconds: 2_000_000) }
        // Let the initial fetches settle.
        try await Task.sleep(nanoseconds: 50_000_000)
        defer { tasks.forEach { $0.cancel() } }
        return try body()
    }
}
