//
//  VX653LineageProbeTests.swift
//  VariorumCoreTests
//
//  VX-653 / VX-654 (the VX-678 run, Unit 2) — the MEASUREMENT PROBE, not a
//  pin (the pins are `LineageReadP1Tests`). It times the two lineage reads
//  over a note's SEAM history (⏎ mid-paragraph divides, ⌫ at the seam
//  merges — every round releases two live-unplaced originals with lineage)
//  on a keyed on-disk store (SQLCipher, the shipped shape), in the same
//  world the VX-647 probe measured the trace's numbers in
//  (`notes/plans/fixes/vx-648-launch-week.md`, "VX-653 / VX-654
//  MEASUREMENTS": 13,067 ms and 5,843 ms at R=600). It prints wall time AND
//  SQLite's VM-instruction count (machine-independent), old beside new:
//
//  · `stranded live` — `originalsStrandedBy` asked of the LIVE merged block
//    (the trace's own measurement shape);
//  · `stranded rcpt` — asked right after deleting it (the Delete Block
//    receipt's real road), then the block is put back;
//  · `preserved` — the open tray's listing (limit 501), with v1_34's
//    `idx_cblock_dead_block` (HEAD) and with it dropped (the tree the
//    trace measured on);
//  · `trash arm` / `fam clocks` — `Queries.strandedOriginals` (the Trash's
//    stranded-originals arm, which `Queries.trash` runs) and
//    `Queries.originFamilyClocks` (the tray panel's held fates read), in
//    the receipt state — NOT this unit's tickets; measured for Unit 3
//    (VX-670), which builds on the Trash listing;
//  · `control` — `Queries.renderPost` of the same note (20 live blocks), a
//    read the seam history should not move: its WALL time shows what the
//    store itself costs at each R (page cache, SQLCipher page decrypts),
//    separating that from any query's own growth (its VM count is flat).
//
//  The old `originalsStrandedBy` body rides here verbatim (`legacyStranded`)
//  so the probe can also assert, at every R, that the new body answers the
//  same rows on the large fixture.
//
//  Gated: runs only with `VX653_PROBE=1`. Knobs: VX653_STEPS (default
//  "100,300,600"), VX653_CORPUS_POSTS (200), VX653_CORPUS_BLOCKS (20),
//  VX653_LEGACY_MAX (600 — the largest R at which the old body is timed).
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

private let probeEnabled = ProcessInfo.processInfo.environment["VX653_PROBE"] == "1"

private func env(_ name: String, _ fallback: Int) -> Int {
    Int(ProcessInfo.processInfo.environment[name] ?? "") ?? fallback
}

private var probeSteps: [Int] {
    (ProcessInfo.processInfo.environment["VX653_STEPS"] ?? "100,300,600")
        .split(separator: ",").compactMap { Int($0) }
}

private final class Counter: @unchecked Sendable { var value = 0 }

/// One measured read: median wall ms over `runs`, and the VM instructions of
/// one run (`sqlite3_progress_handler`, period 1 — deterministic).
private struct Measure {
    var ms: Double
    var vm: Int
}

private func measure(_ db: Database, runs: Int, _ body: () throws -> Void) throws -> Measure {
    var samples: [Double] = []
    for _ in 0..<runs {
        let start = DispatchTime.now().uptimeNanoseconds
        try body()
        samples.append(Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000)
    }
    samples.sort()
    let counter = Counter()
    let context = Unmanaged.passRetained(counter).toOpaque()
    defer { Unmanaged<Counter>.fromOpaque(context).release() }
    sqlite3_progress_handler(db.sqliteConnection, 1, { pointer in
        guard let pointer else { return 0 }
        Unmanaged<Counter>.fromOpaque(pointer).takeUnretainedValue().value += 1
        return 0
    }, context)
    defer { sqlite3_progress_handler(db.sqliteConnection, 0, nil, nil) }
    try body()
    return Measure(ms: samples[samples.count / 2], vm: counter.value)
}

private func cell(_ m: Measure?) -> String {
    guard let m else { return String(repeating: " ", count: 10) + "—" + String(repeating: " ", count: 11) }
    return String(format: "%10.2f ms %9d", m.ms, m.vm)
}

/// A keyed on-disk store in a fresh temp dir (removed by the caller).
private func keyedStore() throws -> (AppDatabase, URL) {
    let dir = FileManager.default.temporaryDirectory
        .appendingPathComponent("vx653-probe-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    var keyBytes = Data(count: 32)
    for i in 0..<32 { keyBytes[i] = UInt8((i * 37 + 11) & 0xFF) }
    let key = try #require(StoreKey(data: keyBytes))
    return (try AppDatabase.onDisk(url: dir.appendingPathComponent("probe.sqlite"), key: key), dir)
}

/// The pre-VX-654 `originalsStrandedBy` body, verbatim (Trash.swift at
/// 50d8aa6ed) — the probe's old side and its large-fixture rows oracle.
private func legacyStranded(_ db: Database, blockIDs: [String]) throws -> [String] {
    guard !blockIDs.isEmpty else { return [] }
    let placeholders = Queries.databaseQuestionMarks(count: blockIDs.count)
    return try String.fetchAll(
        db,
        sql: """
            WITH RECURSIVE anc(id) AS (
              SELECT e.target_block_id FROM edge e
              WHERE e.source_block_id IN (\(placeholders))
                AND e.type = 'derived_from'
              UNION
              SELECT e.target_block_id FROM edge e
              JOIN anc a ON e.source_block_id = a.id
              WHERE e.type = 'derived_from'
            ),
            fam(origin, id) AS (
              SELECT a.id, e.source_block_id FROM anc a
              JOIN edge e ON e.target_block_id = a.id AND e.type = 'derived_from'
              UNION
              SELECT f.origin, e.source_block_id FROM fam f
              JOIN edge e ON e.target_block_id = f.id AND e.type = 'derived_from'
            )
            SELECT f.origin FROM fam f
            JOIN block d ON d.id = f.id
            JOIN block o ON o.id = f.origin
            WHERE o.deleted_at IS NULL AND o.archived_at IS NULL
              AND NOT EXISTS (
                SELECT 1 FROM container_block placed
                WHERE placed.block_id = o.id AND placed.deleted_at IS NULL)
            GROUP BY f.origin
            HAVING SUM(CASE WHEN d.deleted_at IS NULL THEN 1 ELSE 0 END) = 0
            """,
        arguments: StatementArguments(blockIDs))
}

@Suite("VX-653/654 — lineage read probe", .enabled(if: probeEnabled), .serialized)
struct VX653LineageProbeTests {

    @Test func seamHistoryCost() throws {
        let (db, dir) = try keyedStore()
        defer { try? FileManager.default.removeItem(at: dir) }
        let tick = LockIsolated(0)
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        try withDependencies {
            $0.database = db
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
            let ops = Operations()
            let posts = env("VX653_CORPUS_POSTS", 200)
            let blocks = env("VX653_CORPUS_BLOCKS", 20)
            for p in 0..<posts {
                let post = try ops.createPost(title: "corpus \(p)")
                for b in 0..<blocks {
                    let minted = try ops.seedBlock(
                        in: post.id, text: CorpusFactory.blockText(post: p, block: b))
                    if b == 0, p % 5 == 0 { _ = try ops.divide(minted.block.id, cut: 24) }
                }
            }
            let note = try ops.createPost(title: "the note")
            var live: [String] = []
            for b in 0..<20 {
                live.append(try ops.seedBlock(
                    in: note.id, text: CorpusFactory.blockText(post: 9999, block: b)).block.id)
            }
            var seam = live[10]
            let legacyMax = env("VX653_LEGACY_MAX", 600)
            print("VX653 corpus=\(posts)x\(blocks) (keyed on-disk); each cell = median wall · VM instructions")
            print("VX653     R | stranded live NEW     | stranded live OLD     | stranded rcpt NEW     | stranded rcpt OLD     | preserved (v1_34)     | preserved (no index)  | trash arm (rcpt)      | fam clocks (rcpt)     | control renderPost")
            var done = 0
            for target in probeSteps {
                for _ in done..<target {
                    let divided = try ops.divide(seam, cut: 24)
                    seam = try ops.merge(seam, divided.block.id, joining: .deleteKeystroke).block.id
                }
                done = target
                let now = start.addingTimeInterval(Double(tick.value) + 60)
                let timeOld = target <= legacyMax

                // The trace's shape: asked of the LIVE merged block.
                let liveSide: (new: Measure, old: Measure?) = try db.read { d in
                    var new: [String] = [], old: [String] = []
                    let n = try measure(d, runs: 3) { new = try Queries.originalsStrandedBy(d, blockIDs: [seam]) }
                    let o = timeOld ? try measure(d, runs: 1) { old = try legacyStranded(d, blockIDs: [seam]) } : nil
                    #expect(new == [], "a live block strands nothing")
                    if timeOld { #expect(new == old, "R=\(target): the new body answers the old rows") }
                    return (n, o)
                }
                // The receipt's road: delete it, ask, put it back.
                try ops.deleteBlock(seam)
                let receipt: (new: Measure, old: Measure?, preserved: Measure, preservedOld: Measure,
                              trashArm: Measure, famClocks: Measure, control: Measure) = try {
                    let side: (Measure, Measure?) = try db.read { d in
                        var new: [String] = [], old: [String] = []
                        let n = try measure(d, runs: 3) { new = try Queries.originalsStrandedBy(d, blockIDs: [seam]) }
                        let o = timeOld ? try measure(d, runs: 1) { old = try legacyStranded(d, blockIDs: [seam]) } : nil
                        #expect(new.count == 1, "the receipt names the released second half")
                        if timeOld { #expect(new == old, "R=\(target): the new body answers the old rows") }
                        return (n, o)
                    }
                    let (preserved, trashArm, famClocks, control): (Measure, Measure, Measure, Measure) = try db.read { d in
                        (try measure(d, runs: 5) { _ = try Queries.preservedOriginals(d, postID: note.id, limit: 501) },
                         try measure(d, runs: 1) { _ = try Queries.strandedOriginals(d, now: now, limit: 501) },
                         try measure(d, runs: 1) { _ = try Queries.originFamilyClocks(d, postID: note.id, now: now) },
                         try measure(d, runs: 5) { _ = try Queries.renderPost(d, containerID: note.id) })
                    }
                    try db.write { try $0.execute(sql: "DROP INDEX idx_cblock_dead_block") }
                    let preservedOld = try db.read { d in
                        try measure(d, runs: 1) { _ = try Queries.preservedOriginals(d, postID: note.id, limit: 501) }
                    }
                    try db.write {
                        try $0.execute(sql: """
                            CREATE INDEX idx_cblock_dead_block ON container_block(block_id, deleted_at)
                              WHERE deleted_at IS NOT NULL
                            """)
                    }
                    return (side.0, side.1, preserved, preservedOld, trashArm, famClocks, control)
                }()
                _ = try ops.restoreBlock(seam)
                print("VX653 \(String(format: "%5d", target)) | \(cell(liveSide.new)) | \(cell(liveSide.old)) | "
                      + "\(cell(receipt.new)) | \(cell(receipt.old)) | \(cell(receipt.preserved)) | "
                      + "\(cell(receipt.preservedOld)) | \(cell(receipt.trashArm)) | \(cell(receipt.famClocks)) | "
                      + "\(cell(receipt.control))")
            }
        }
    }
}
