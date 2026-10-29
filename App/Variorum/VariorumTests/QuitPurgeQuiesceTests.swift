//
//  QuitPurgeQuiesceTests.swift
//  VariorumTests
//
//  VX-657 (the VX-678 run) — the purge-road quit race's app half. ⌘Q used
//  to exit the process over an in-flight GRDB reader (the SIGSEGV in the
//  page-decrypt teardown, her crash report): `AppServices.localPurgeTask`
//  ticks hourly into `AppSession.sweepLocalPurge` → `LocalPurge.sweep()`,
//  the transported janitor rides sync rounds, and
//  `applicationShouldTerminate` awaited only the editor flush and the
//  `quitFinalize` registry — nothing cancelled or awaited the sweeps.
//
//  The guard under test: the quit door's PROCEED path runs
//  `AppServices.quiesceForExit()` — the session's exit quiesce (refuse new
//  sweeps; cancel-and-await the in-flight one) plus
//  `SyncSession.quiesceForExit()` (retire + awaitIdle, `stop()`'s retire
//  AWAITED) — before replying to ⌘Q. The sweeps themselves stop at family
//  boundaries (core pins: PurgeConvergenceTests' VX-657 section). These
//  pins drive the session-level pieces the thin delegate calls; the
//  delegate's own branch is unreachable from a test host (calling
//  `reply(toApplicationShouldTerminate:)` on the real NSApp is exactly the
//  thing a pin must not do — the standing note on
//  `declineQuitIfACaptureStands`).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withQuiesceWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 57))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-657 — the quit door's purge quiesce", .serialized)
struct QuitPurgeQuiesceTests {
    /// A never-synced deleted note with a standing Delete Now intent — the
    /// local road's eligible family (test 11's shape, app-side).
    private func buildPurgeableFamily(_ session: AppSession, title: String) throws -> String {
        let ops = session.operations
        let post = try ops.createPost(title: title, profile: .generic)
        _ = try ops.newBlock(in: post.id, text: "Going.", at: .end)
        try ops.deleteContainer(post.id)
        _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: post.id)])
        return post.id
    }

    private func containerRows(_ db: AppDatabase, _ id: String) async throws -> Int {
        try await db.read { db in
            try Int.fetchOne(
                db, sql: "SELECT COUNT(*) FROM container WHERE id = ?", arguments: [id]) ?? 0
        }
    }

    /// **The refusal pin:** before the quiesce a sweep purges the eligible
    /// local family (the control arm — the world is real); once quiescing,
    /// `sweepLocalPurge` refuses outright and the next family stands
    /// untouched. The flag never resets: the process is exiting.
    @Test func quiesceRefusesNewSweepsAndBeforeItSweepsStillPurge() async throws {
        try await withQuiesceWorld { session, db in
            // Control: the sweep really purges in this world.
            let first = try buildPurgeableFamily(session, title: "doomed")
            await session.sweepLocalPurge()
            #expect(try await containerRows(db, first) == 0,
                    "the control sweep physically removes the never-synced family")

            // The quit door's proceed path has begun: new sweeps refuse.
            await session.quiesceLocalPurgeForExit()
            let second = try buildPurgeableFamily(session, title: "spared")
            await session.sweepLocalPurge()
            #expect(try await containerRows(db, second) > 0,
                    "a sweep asked for after the quiesce began runs nothing")
            #expect(session.localPurgeSweepsInFlight == 0)
        }
    }

    /// **The cancel-and-await pin (the injected-spy evidence shape):** a
    /// sweep parked mid-flight is held where the quit can reach it; the
    /// quiesce CANCELS it and returns only after it actually ended — the
    /// process never exits over an in-flight sweep. The spy records the
    /// cancellation and its own end, so the ordering is asserted, not
    /// assumed.
    @Test func quiesceCancelsAndAwaitsTheInFlightSweep() async throws {
        try await withQuiesceWorld { session, _ in
            let started = LockIsolated(false)
            let sawCancel = LockIsolated(false)
            let ended = LockIsolated(false)
            session.localPurgeSweepBody = {
                started.setValue(true)
                // Parks until cancelled (the quiesce's cancel wakes it);
                // a minute's ceiling keeps a broken quiesce from hanging
                // the suite rather than failing it.
                try? await Task.sleep(for: .seconds(60))
                sawCancel.setValue(Task.isCancelled)
                ended.setValue(true)
            }

            let sweep = Task { await session.sweepLocalPurge() }
            for _ in 0..<2000 {
                if started.value && session.localPurgeSweepsInFlight == 1 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(started.value && session.localPurgeSweepsInFlight == 1,
                    "the sweep is mid-flight and HELD — the quit door can reach it")

            await session.quiesceLocalPurgeForExit()
            #expect(ended.value,
                    "the quiesce returned only after the in-flight sweep ended")
            #expect(sawCancel.value,
                    "it ended because the quiesce CANCELLED it — not by luck")
            #expect(session.localPurgeSweepsInFlight == 0)
            await sweep.value
        }
    }

    /// **The stop() road (ladder R1, MINOR-3):** `AppServices.stop()` — the
    /// lock teardown, a sign-out's reconfigure — ends an in-flight sweep by
    /// a NON-AWAITING cancel (`AppSession.cancelLocalPurgeSweeps`, the one
    /// line stop() calls), and unlike the quit road it never refuses future
    /// sweeps: the process lives on. Driven at the model seam with the same
    /// spy body; the wiring in `stop()` is one call to exactly this.
    @Test func stopsCancelRoadCancelsWithoutRefusingFutureSweeps() async throws {
        try await withQuiesceWorld { session, _ in
            let started = LockIsolated(false)
            let sawCancel = LockIsolated(false)
            session.localPurgeSweepBody = {
                started.setValue(true)
                try? await Task.sleep(for: .seconds(60))
                sawCancel.setValue(Task.isCancelled)
            }
            let sweep = Task { await session.sweepLocalPurge() }
            for _ in 0..<2000 {
                if started.value && session.localPurgeSweepsInFlight == 1 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(started.value && session.localPurgeSweepsInFlight == 1)

            session.cancelLocalPurgeSweeps()
            await sweep.value
            #expect(sawCancel.value, "the stop() road's cancel reached the in-flight sweep")
            #expect(session.localPurgeSweepsInFlight == 0,
                    "the entry cleaned itself up through its own awaiting call")

            // Unlike the quit road, future sweeps stay welcome.
            let ranAgain = LockIsolated(false)
            session.localPurgeSweepBody = { ranAgain.setValue(true) }
            await session.sweepLocalPurge()
            #expect(ranAgain.value, "stop() never refuses later sweeps — only the quit door does")
        }
    }

    /// **The sync half:** `SyncSession.quiesceForExit()` blocks on the
    /// round in flight (the transported janitor rides it) and returns once
    /// the retired loop actually ends — `stop()`'s retire, awaited. An
    /// unconfigured session returns at once, and the quiesce is idempotent.
    @Test func syncQuiesceAwaitsTheInFlightRound() async throws {
        let db = try AppDatabase.inMemory()
        let session = SyncSession(database: db, allowsSync: true)

        // Unconfigured: returns at once, nothing to wait on.
        await session.quiesceForExit()
        #expect(!session.isConfigured)

        let gate = QuiesceGateTransport()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            await session.configure(transport: gate, keyProvider: AppTestKeyProvider())
            session.triggerSync()
            await gate.awaitParked()  // the round is provably mid-flight

            let finished = LockIsolated(false)
            let quiesce = Task { @MainActor in
                await session.quiesceForExit()
                finished.setValue(true)
            }
            try await Task.sleep(for: .milliseconds(50))
            #expect(!finished.value,
                    "the quiesce BLOCKS on the mid-flight round — the process must not exit over it")
            #expect(!session.isConfigured,
                    "the chain is already retired — no new round can start meanwhile")

            await gate.open()
            await quiesce.value
            #expect(finished.value, "the round ended; the quiesce returned")

            // Idempotent, and a later trigger runs nothing on the retired chain.
            await session.quiesceForExit()
            session.triggerSync()
            #expect(!session.isConfigured)
        }
    }
}

/// The round-gate transport (Phase8ServicesTests' instrument, local copy —
/// that one is file-private): parks the round's first data call until
/// `open()`, so "mid-flight" is a proven state, never a sleep's guess.
private actor QuiesceGateTransport: SyncTransport {
    private var gated = true
    private var gateWaiters: [CheckedContinuation<Void, Never>] = []
    private var arrivalWaiters: [CheckedContinuation<Void, Never>] = []
    private var parked = false

    func awaitParked() async {
        if parked { return }
        await withCheckedContinuation { arrivalWaiters.append($0) }
    }

    func open() {
        gated = false
        let waiters = gateWaiters
        gateWaiters.removeAll()
        for waiter in waiters { waiter.resume() }
    }

    private func pass() async {
        guard gated else { return }
        parked = true
        await withCheckedContinuation { continuation in
            gateWaiters.append(continuation)
            let arrivals = arrivalWaiters
            arrivalWaiters.removeAll()
            for arrival in arrivals { arrival.resume() }
        }
        parked = false
    }

    func fetchChallenges(_ count: Int) async throws -> [String] {
        (0..<max(count, 1)).map { _ in
            Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
        }
    }
    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {}
    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
        await pass()
        return batch.map { _ in .rejected(current: nil) }
    }
    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow] {
        await pass()
        return []
    }
    /// Round plumbing (SyncSpec §12) — never parks.
    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
}
