//
//  VX670TrashRoadsProbeTests.swift
//  VariorumCoreTests
//
//  VX-670 (the VX-678 run, Unit 3) — the MEASUREMENT PROBE for her three
//  reported roads, not a pin (the pins are `TrashLineageP1Tests`). Her words
//  (the kickoff's "Her reports"): *"the trash has a several second delay
//  before it shows what items are in there … it was just a blank screen … i
//  click delete, then delete now, nothing happens for a long time."*
//
//  It drives the STORE SIDE of each road exactly as the Mac's Trash does,
//  on a keyed on-disk store (SQLCipher, the shipped shape) in Unit 2's world
//  (200 posts × 20 blocks + a note with R seam rounds whose placed block was
//  just deleted, so the Trash holds a stranded original):
//
//  · LISTING — `RecoveryView` starts TWO held observations at once:
//    `startTrash` (`observeTrash`, the listed kinds, limit 501) and
//    `startTrashTotal` (limit 1). The listing paints at the first value of
//    the first. Measured: wall time from starting both to each's first value.
//  · PUT BACK (a deleted note) — `TrashPutBack.run` is one `restoreContainer`
//    write; the receipt shows when the write returns. With both observations
//    HELD (the Trash is open), GRDB re-fetches each SYNCHRONOUSLY ON THE
//    WRITER inside the commit (`tracking`'s non-constant-region mode — the
//    VX-647 trace's amplifier), so the write returns only after both.
//    Measured: the write's return, and the listing's next value.
//  · DELETE NOW (a deleted note) — `TrashPurge.confirm` on a never-synced
//    store: the `anyFamilyEverSynced` read, the `requestPurge` write (the row
//    leaves the listing here), then `LocalPurge.sweep()` (one write per
//    family), then the receipt. Measured: each leg and the total.
//
//  Run on the pre-rewrite tree for the BEFORE numbers and after it for the
//  AFTER numbers ("UNIT 3 MEASUREMENTS" in the run record).
//
//  Gated: runs only with `VX670_PROBE=1`. Knobs: VX670_STEPS (default
//  "100,300,600"), VX670_CORPUS_POSTS (200), VX670_CORPUS_BLOCKS (20).
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private let probeEnabled = ProcessInfo.processInfo.environment["VX670_PROBE"] == "1"

private func env(_ name: String, _ fallback: Int) -> Int {
    Int(ProcessInfo.processInfo.environment[name] ?? "") ?? fallback
}

private var probeSteps: [Int] {
    (ProcessInfo.processInfo.environment["VX670_STEPS"] ?? "100,300,600")
        .split(separator: ",").compactMap { Int($0) }
}

/// The kinds the Mac's Trash lists (`TrashScope.listedKinds`, app-side).
private let listedKinds: Set<Queries.TrashItem.Kind> = [
    .note, .book, .block, .snippetGroup, .preservedOriginal,
]

private func ms(_ duration: Duration) -> Double {
    let (seconds, attoseconds) = duration.components
    return Double(seconds) * 1000 + Double(attoseconds) / 1e15
}

/// A held observation's deliveries: how many values arrived and when.
private final class Held: @unchecked Sendable {
    private let state = LockIsolated<(count: Int, at: [ContinuousClock.Instant])>((0, []))

    func deliver() {
        let now = ContinuousClock.now
        state.withValue { $0.count += 1; $0.at.append(now) }
    }

    var count: Int { state.value.count }

    /// Waits (polling) until the `n`th value has arrived; returns its instant.
    func arrival(_ n: Int, timeout: Duration = .seconds(900)) async throws -> ContinuousClock.Instant {
        let deadline = ContinuousClock.now + timeout
        while ContinuousClock.now < deadline {
            let snapshot = state.value
            if snapshot.count >= n { return snapshot.at[n - 1] }
            try await Task.sleep(for: .milliseconds(1))
        }
        Issue.record("value #\(n) never arrived")
        return ContinuousClock.now
    }
}

private func hold(
    _ observation: AsyncValueObservation<[Queries.TrashItem]>, into held: Held
) -> Task<Void, Never> {
    Task {
        do {
            for try await _ in observation { held.deliver() }
        } catch {}
    }
}

/// A keyed on-disk store in a fresh temp dir (removed by the caller).
private func keyedStore() throws -> (AppDatabase, URL) {
    let dir = FileManager.default.temporaryDirectory
        .appendingPathComponent("vx670-probe-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    var keyBytes = Data(count: 32)
    for i in 0..<32 { keyBytes[i] = UInt8((i * 37 + 11) & 0xFF) }
    let key = try #require(StoreKey(data: keyBytes))
    return (try AppDatabase.onDisk(url: dir.appendingPathComponent("probe.sqlite"), key: key), dir)
}

@Suite("VX-670 — the Trash's three roads, measured", .enabled(if: probeEnabled), .serialized)
struct VX670TrashRoadsProbeTests {

    @Test func theThreeRoads() async throws {
        let (db, dir) = try keyedStore()
        defer { try? FileManager.default.removeItem(at: dir) }
        let tick = LockIsolated(0)
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        try await withDependencies {
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
            let posts = env("VX670_CORPUS_POSTS", 200)
            let blocks = env("VX670_CORPUS_BLOCKS", 20)
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
            print("VX670 corpus=\(posts)x\(blocks) (keyed on-disk); wall ms")
            print("VX670     R | listing 1st value | total 1st value | put back answered | listing after put back | delete now: synced read | intent write | local sweep | answered (receipt)")
            var done = 0
            for target in probeSteps {
                for _ in done..<target {
                    let divided = try ops.divide(seam, cut: 24)
                    seam = try ops.merge(seam, divided.block.id, joining: .deleteKeystroke).block.id
                }
                done = target
                // The Trash's contents: the seam's placed block (a stranded
                // original rides it) and two deleted five-block notes.
                try ops.deleteBlock(seam)
                func deletedNote(_ title: String) throws -> String {
                    let victim = try ops.createPost(title: title)
                    for b in 0..<5 {
                        try ops.seedBlock(in: victim.id, text: CorpusFactory.blockText(post: 7000 + target, block: b))
                    }
                    try ops.deleteContainer(victim.id)
                    return victim.id
                }
                let putBack = try deletedNote("put back \(target)")
                let purge = try deletedNote("delete now \(target)")
                let now = start.addingTimeInterval(Double(tick.value) + 60)

                // 1 · THE LISTING: both of RecoveryView's observations, started together.
                let listing = Held(), total = Held()
                let opened = ContinuousClock.now
                let listingTask = hold(db.observeTrash(
                    now: now, kinds: listedKinds, oldestFirst: false, limit: 501, wingID: ""), into: listing)
                let totalTask = hold(db.observeTrash(
                    now: now, kinds: listedKinds, oldestFirst: false, limit: 1, wingID: ""), into: total)
                let listingFirst = try await listing.arrival(1) - opened
                let totalFirst = try await total.arrival(1) - opened

                // 2 · PUT BACK, the Trash open (both observations held).
                let before = listing.count
                let w0 = ContinuousClock.now
                try ops.restoreContainer(putBack)
                let putBackAnswered = ContinuousClock.now - w0
                let listingAfterPutBack = try await listing.arrival(before + 1) - w0

                // 3 · DELETE NOW, the Trash open.
                let targetRow = SyncPurgeTarget(table: "container", rowID: purge)
                let d0 = ContinuousClock.now
                _ = try await db.read { try PurgeJanitor.anyFamilyEverSynced($0, targets: [targetRow]) }
                let d1 = ContinuousClock.now
                try ops.requestPurge([targetRow])
                let d2 = ContinuousClock.now
                let report = try await LocalPurge(database: db).sweep()
                let d3 = ContinuousClock.now
                #expect(report.familiesPurged == 1, "the never-synced family purges locally")

                listingTask.cancel()
                totalTask.cancel()
                _ = try ops.restoreBlock(seam)
                print("VX670 \(String(format: "%5d", target)) | "
                      + String(format: "%17.1f | %15.1f | %17.1f | %22.1f | %23.1f | %12.1f | %11.1f | %18.1f",
                               ms(listingFirst), ms(totalFirst), ms(putBackAnswered), ms(listingAfterPutBack),
                               ms(d1 - d0), ms(d2 - d1), ms(d3 - d2), ms(d3 - d0)))
            }
        }
    }
}
