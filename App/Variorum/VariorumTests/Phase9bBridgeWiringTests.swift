//
//  Phase9bBridgeWiringTests.swift
//  VariorumTests
//
//  Phase 9b, Step 5 — the app-side bridge wiring: the A4 fence extends to
//  the bridge (dev stores and the phone never bridge); bridge rounds follow
//  sync rounds, never interleaving with one (the after-sync ordering rides
//  SyncSession.onRoundCompleted); a bridge failure leaves state for retry
//  (pinned core-side in BridgeSchedulerTests — not duplicated here).
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - Local fakes (the core test target's FakeFragmentsServer is not
// visible here; the wiring tests need only call accounting)

private actor RecordingBridgeTransport: FragmentsBridgeTransport {
    private(set) var pullCalls = 0
    func push(_ entries: [FragmentsEntry]) async throws -> FragmentsPushResponse {
        FragmentsPushResponse(applied: entries.count, skipped: 0)
    }
    func pull(after cursor: FragmentsPullCursor?, limit: Int) async throws -> [FragmentsEntry] {
        pullCalls += 1
        return []
    }
    func delete(ids: [String]) async throws -> Int {
        ids.count
    }
    func fetchLocalUserID() async throws -> String? {
        "9f1c2b3a-4d5e-6f70-8192-a3b4c5d6e7f8"
    }
}

/// A sync transport that parks its round at a gate, so the test can prove
/// the bridge has NOT run while a sync round is mid-flight.
private actor GatedSyncTransport: SyncTransport {
    private var gated = true
    private var gateWaiters: [CheckedContinuation<Void, Never>] = []
    private var arrivalWaiters: [CheckedContinuation<Void, Never>] = []

    func awaitParked() async {
        if !gateWaiters.isEmpty { return }
        await withCheckedContinuation { arrivalWaiters.append($0) }
    }

    func open() {
        gated = false
        let waiters = gateWaiters
        gateWaiters.removeAll()
        for waiter in waiters { waiter.resume() }
    }

    private func pass() async {
        let arrivals = arrivalWaiters
        arrivalWaiters.removeAll()
        for arrival in arrivals { arrival.resume() }
        guard gated else { return }
        await withCheckedContinuation { gateWaiters.append($0) }
    }

    func push(_ batch: [SyncRow]) async throws -> [SyncPushOutcome] {
        await pass()
        return batch.map { _ in .rejected(current: nil) }
    }

    func pull(since: Int64, limit: Int) async throws -> [SyncPulledRow] {
        await pass()
        return []
    }

    /// Round plumbing (SyncSpec §12) — never parks at the gate.
    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
}

@MainActor
@Suite("Fragments bridge wiring (Phase 9b, Step 5)")
struct Phase9bBridgeWiringTests {
    private func testConfiguration() -> FragmentsBridgeConfiguration {
        FragmentsBridgeConfiguration(userID: "user-author")
    }

    /// THE FENCE PIN: a session that must not bridge (dev store; the phone
    /// this phase) refuses to configure — no engine, no rounds, ever.
    @Test func fencedSessionsNeverConfigureTheBridge() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let transport = RecordingBridgeTransport()
            let engine = BridgeEngine(transport: transport, configuration: testConfiguration())

            let fenced = BridgeSession(allowsBridge: false)
            await fenced.configure(engine: engine)
            #expect(!fenced.isConfigured,
                    "a fenced session must never hold a bridge chain")
            fenced.trigger()
            try await Task.sleep(for: .milliseconds(50))
            #expect(await transport.pullCalls == 0)

            let allowed = BridgeSession(allowsBridge: true)
            await allowed.configure(engine: engine)
            #expect(allowed.isConfigured)
            allowed.stop()
            fenced.stop()
        }
    }

    /// THE ORDERING PIN (the plan's "rounds serialize after sync"): the
    /// bridge trigger rides SyncSession.onRoundCompleted, so no bridge
    /// round starts while a sync round is mid-flight, and one follows each
    /// completed round.
    @Test func bridgeRoundsFollowSyncRoundsNeverInterleaving() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let syncGate = GatedSyncTransport()
            let syncSession = SyncSession(database: db, allowsSync: true)
            await syncSession.configure(transport: syncGate)

            let bridgeTransport = RecordingBridgeTransport()
            let bridge = BridgeSession(allowsBridge: true)
            await bridge.configure(
                engine: BridgeEngine(transport: bridgeTransport, configuration: testConfiguration()))
            // The AppServices wiring, verbatim.
            syncSession.onRoundCompleted = { [weak bridge] in bridge?.trigger() }

            syncSession.triggerSync()
            await syncGate.awaitParked()
            // Mid-sync-round: the bridge has not started.
            try await Task.sleep(for: .milliseconds(50))
            #expect(await bridgeTransport.pullCalls == 0,
                    "no bridge round may run while a sync round is in flight")

            await syncGate.open()
            // The completed sync round carries exactly one bridge trigger.
            for _ in 0..<2000 {
                if await bridgeTransport.pullCalls > 0 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(await bridgeTransport.pullCalls == 1)

            bridge.stop()
            syncSession.stop()
        }
    }

    /// A tiny deterministic RNG for the position jitter (the core test
    /// target's SeededGenerator is not visible here).
    private struct FixedGenerator: RandomNumberGenerator {
        var state: UInt64 = 0x9E3779B97F4A7C15
        mutating func next() -> UInt64 {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state
        }
    }

    /// Review round 1, MAJOR 2 (the cadence half): cadence triggers are
    /// throttled to the minimum round interval — a settle-rate burst
    /// forwards ONE immediate round plus at most ONE trailing round (so the
    /// last trigger is never lost), instead of a corpus hash sweep per
    /// burst member. Manual triggers bypass the throttle.
    @Test func cadenceTriggersAreThrottledToTheMinimumInterval() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let transport = RecordingBridgeTransport()
            let bridge = BridgeSession(
                allowsBridge: true, minimumRoundInterval: .milliseconds(150))
            await bridge.configure(
                engine: BridgeEngine(transport: transport, configuration: testConfiguration()))

            // A settle-rate burst.
            for _ in 0..<6 { bridge.trigger() }
            try await Task.sleep(for: .milliseconds(60))
            #expect(await transport.pullCalls == 1,
                    "inside the interval only the first cadence trigger forwards")

            // The trailing round fires once the interval elapses.
            for _ in 0..<400 {
                if await transport.pullCalls >= 2 { break }
                try await Task.sleep(for: .milliseconds(5))
            }
            #expect(await transport.pullCalls == 2,
                    "the burst coalesces into exactly one trailing round")

            // A manual trigger bypasses the throttle immediately.
            bridge.trigger(manual: true)
            for _ in 0..<400 {
                if await transport.pullCalls >= 3 { break }
                try await Task.sleep(for: .milliseconds(5))
            }
            #expect(await transport.pullCalls == 3)
            bridge.stop()
        }
    }

    /// The paused-day surface reaches the app layer (the status row renders
    /// `status.pausedDays` — the visible half of the duplicate-day pause).
    @Test func pausedDaysReachTheSessionStatus() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(FixedGenerator())
        } operation: { @MainActor in
            // Two live entries on one day, written through Operations.
            let ops = Operations()
            let first = try ops.createPost(profile: .journal, entryDate: "2026-07-09")
            _ = try ops.newBlock(in: first.id, text: "A", at: .end)
            let second = try ops.createPost(profile: .journal, entryDate: "2026-07-09")
            _ = try ops.newBlock(in: second.id, text: "B", at: .end)

            let bridge = BridgeSession(allowsBridge: true)
            await bridge.configure(
                engine: BridgeEngine(
                    transport: RecordingBridgeTransport(),
                    configuration: testConfiguration()))
            bridge.trigger()
            for _ in 0..<2000 {
                if !bridge.status.pausedDays.isEmpty { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(bridge.status.pausedDays == ["2026-07-09"])
            bridge.stop()
        }
    }
}
