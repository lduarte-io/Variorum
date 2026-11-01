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
//  VARIORUM_APPLY_PROFILE_RUNS (default 3) · VARIORUM_APPLY_PROFILE_STORE = disk (default) | memory.
//
//  The second suite is UNGATED and pins the seam itself: nil is inert (the default engine carries no hook), and a
//  wired hook hears every phase exactly once per round with exactly one `PRAGMA foreign_key_list` read per row of the
//  fixpoint's one pass — D-497's own claim ("the introspection runs once per ROW"), now a pin.
//

import Dependencies
import Foundation
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
        let storeKind = onDisk ? "keyed on-disk store" : "in-memory store"
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
            let start = ContinuousClock.now
            let report = try await b.pull(batchSize: 2_000)  // the production window (ResumableCatchUpTests pins it)
            let wall = ContinuousClock.now - start
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
