import Foundation
import Testing
@testable import VariorumCore

/// Phase 8, amendment A3 — the engine-lifecycle guarantees, made explicit
/// and pinned: strictly sequential rounds, trigger coalescing (≤ one
/// follow-up), the pull → push order, monotonic cursor, and the offline
/// posture (an error skips the round and keeps the outbox — Step 6's
/// lifecycle tests live here too, where the fake transport is).
@Suite("Sync scheduler lifecycle (Phase 8, A3 + Step 6)")
struct SyncSchedulerTests {
    private struct World {
        let server: FakeSyncServer
        let spy: GatedSpyTransport
        let client: SyncClient
        let scheduler: SyncScheduler
    }

    private func makeWorld() throws -> World {
        let server = FakeSyncServer()
        let spy = GatedSpyTransport(server: server)
        let client = try SyncClient(name: "A", prefix: "AA", transport: spy)
        let scheduler = SyncScheduler(engine: SyncEngine(transport: spy))
        return World(server: server, spy: spy, client: client, scheduler: scheduler)
    }

    @Test func simultaneousTriggersRunStrictlySequentialRoundsWithOneDrain() async throws {
        let world = try makeWorld()
        try world.client.with { ops, _ in
            _ = try ops.createPost(title: "queued while gated", profile: .journal)
        }

        // Gate the transport so round 1 is provably still running when the
        // later triggers land. (A trigger arriving BEFORE the round begins
        // is legitimately absorbed by it — the round it announces hasn't
        // started; only mid-round triggers must coalesce into a follow-up.)
        await world.spy.closeGate()
        try await world.client.withAsync { _ in
            await world.scheduler.trigger()
            await world.spy.awaitCallAtGate()  // round 1 is now mid-flight
            await world.scheduler.trigger()
            await world.scheduler.trigger()
        }
        await world.spy.openGate()
        await world.scheduler.awaitIdle()

        let status = await world.scheduler.status
        #expect(status.roundsCompleted == 2,
                "one round + exactly one coalesced follow-up — never three")
        #expect(await world.spy.drainingPushCalls == 1,
                "the outbox drains once; the follow-up round finds nothing to push")
        #expect(try world.client.outboxCount() == 0)
        #expect(status.pendingPushCount == 0)
    }

    @Test func aTriggerStormCoalescesToAtMostTwoRounds() async throws {
        let world = try makeWorld()
        try world.client.with { ops, _ in
            _ = try ops.createPost(title: "storm content", profile: .journal)
        }
        await world.spy.closeGate()
        try await world.client.withAsync { _ in
            await world.scheduler.trigger()
            await world.spy.awaitCallAtGate()  // the storm hits mid-round
            for _ in 1...20 {
                await world.scheduler.trigger()
            }
        }
        await world.spy.openGate()
        await world.scheduler.awaitIdle()
        let status = await world.scheduler.status
        #expect(status.roundsCompleted == 2, "20 mid-round triggers coalesce to exactly one follow-up")
        #expect(try world.client.outboxCount() == 0)
    }

    @Test func roundsArePinnedPullThenPush() async throws {
        let world = try makeWorld()
        // Content in BOTH directions: another device's rows to pull, local
        // rows to push.
        let other = try SyncClient(name: "B", prefix: "BB", transport: world.server, seed: 2)
        try other.with { ops, _ in
            _ = try ops.createPost(title: "from the other device", profile: .journal)
        }
        _ = try await other.push()
        try world.client.with { ops, _ in
            _ = try ops.createPost(title: "local content", profile: .journal)
        }

        try await world.client.withAsync { _ in await world.scheduler.trigger() }
        await world.scheduler.awaitIdle()

        let calls = await world.spy.calls
        #expect(calls.first == .pull, "a round opens with the pull (reconcile before draining)")
        if let firstPush = calls.firstIndex(where: {
            if case .push = $0 { return true } else { return false }
        }) {
            #expect(!calls[firstPush...].contains(.pull),
                    "no pull may follow a push within the round")
        } else {
            Issue.record("the round never pushed — the scenario lost its push half")
        }
        #expect(try world.client.outboxCount() == 0)
    }

    @Test func theCursorAdvancesMonotonically() async throws {
        let world = try makeWorld()
        let other = try SyncClient(name: "B", prefix: "BB", transport: world.server, seed: 2)

        func cursor() throws -> Int64 {
            Int64(try world.client.db.fetchString(
                "SELECT value FROM sync_state WHERE key = 'last_server_seq'") ?? "0") ?? 0
        }

        try other.with { ops, _ in _ = try ops.createPost(title: "one", profile: .journal) }
        _ = try await other.push()
        try await world.client.withAsync { _ in await world.scheduler.trigger() }
        await world.scheduler.awaitIdle()
        let first = try cursor()

        try other.with { ops, _ in _ = try ops.createPost(title: "two", profile: .journal) }
        _ = try await other.push()
        try await world.client.withAsync { _ in await world.scheduler.trigger() }
        await world.scheduler.awaitIdle()
        let second = try cursor()

        try await world.client.withAsync { _ in await world.scheduler.trigger() }
        await world.scheduler.awaitIdle()
        let third = try cursor()

        #expect(first > 0)
        #expect(second > first, "new server content advances the cursor")
        #expect(third >= second, "a quiet round never rewinds the cursor")
    }

    /// Step 6's lifecycle posture: offline is free — writes accumulate in
    /// the outbox, a failed round touches nothing, the next healthy round
    /// drains everything; the status surface reflects pending/error.
    @Test func offlineRoundsKeepTheOutboxAndHealOnTheNextTrigger() async throws {
        let world = try makeWorld()
        try world.client.with { ops, _ in
            let entry = try ops.createPost(title: "written offline", profile: .journal)
            _ = try ops.newBlock(in: entry.id, text: "Captured in airplane mode.", at: .end)
        }
        let pendingBefore = try world.client.outboxCount()
        #expect(pendingBefore > 0)

        await world.spy.setFailing(true)
        try await world.client.withAsync { _ in await world.scheduler.trigger() }
        await world.scheduler.awaitIdle()

        var status = await world.scheduler.status
        #expect(status.lastError != nil, "the failed round surfaces its error")
        #expect(status.pendingPushCount == pendingBefore)
        #expect(try world.client.outboxCount() == pendingBefore,
                "an offline round must leave the outbox exactly as it was")

        // More writing while offline accumulates.
        try world.client.with { ops, _ in
            _ = try ops.createPost(title: "second offline entry", profile: .journal)
        }
        #expect(try world.client.outboxCount() > pendingBefore)

        // Back online: one trigger drains everything.
        await world.spy.setFailing(false)
        try await world.client.withAsync { _ in await world.scheduler.trigger() }
        await world.scheduler.awaitIdle()

        status = await world.scheduler.status
        #expect(status.lastError == nil, "a clean round clears the error")
        #expect(status.lastSuccessAt != nil)
        #expect(status.pendingPushCount == 0)
        #expect(try world.client.outboxCount() == 0)
        #expect(await world.server.rowCount(table: "container") == 2)
    }

    @Test func statusUpdatesStreamTheRoundLifecycle() async throws {
        let world = try makeWorld()
        try world.client.with { ops, _ in
            _ = try ops.createPost(title: "observed", profile: .journal)
        }
        let stream = await world.scheduler.statusUpdates()
        try await world.client.withAsync { _ in await world.scheduler.trigger() }

        var sawSyncing = false
        var final: SyncScheduler.Status?
        for await status in stream {
            if status.isSyncing { sawSyncing = true }
            if status.roundsCompleted >= 1 && !status.isSyncing {
                final = status
                break
            }
        }
        #expect(sawSyncing, "the stream shows the round in flight")
        #expect(final?.pendingPushCount == 0)
        #expect(final?.lastError == nil)
    }
}

// MARK: - Review round 2: retirement closes the stale-trigger door

@Suite("Scheduler retirement (Phase 8, review round 2)")
struct SchedulerRetirementTests {
    /// THE PIN: a `triggerSync` Task that captured the old scheduler before
    /// a re-configure can execute AFTER the drain — the retired scheduler
    /// must refuse to start a round on the retired chain (stale engine,
    /// possibly pre-rotation credentials).
    @Test func aRetiredSchedulerRefusesNewRounds() async throws {
        let server = FakeSyncServer()
        let spy = GatedSpyTransport(server: server)
        let client = try SyncClient(name: "A", prefix: "AA", transport: spy)
        let scheduler = SyncScheduler(engine: SyncEngine(transport: spy))
        try client.with { ops, _ in
            _ = try ops.createPost(title: "content a stale trigger would push", profile: .journal)
        }

        await scheduler.retire()
        try await client.withAsync { _ in
            await scheduler.trigger()  // the stale Task's revival attempt
        }
        await scheduler.awaitIdle()

        let status = await scheduler.status
        #expect(status.roundsCompleted == 0, "a retired scheduler never starts a round")
        #expect(await spy.calls.isEmpty, "the retired chain's transport is never touched")
        #expect(try client.outboxCount() > 0, "the outbox is the NEW chain's to drain")
    }

    /// Retirement mid-round: the in-flight round finishes (awaitIdle
    /// observes it) but the coalesced follow-up is cancelled — no new round
    /// starts on a retired chain.
    @Test func retirementCancelsTheCoalescedFollowUp() async throws {
        let server = FakeSyncServer()
        let spy = GatedSpyTransport(server: server)
        let client = try SyncClient(name: "A", prefix: "AA", transport: spy)
        let scheduler = SyncScheduler(engine: SyncEngine(transport: spy))
        try client.with { ops, _ in
            _ = try ops.createPost(title: "gated content", profile: .journal)
        }

        await spy.closeGate()
        try await client.withAsync { _ in
            await scheduler.trigger()
            await spy.awaitCallAtGate()   // round 1 provably mid-flight
            await scheduler.trigger()     // would coalesce into a follow-up
            await scheduler.retire()      // the session swaps chains here
        }
        await spy.openGate()
        await scheduler.awaitIdle()

        let status = await scheduler.status
        #expect(status.roundsCompleted == 1,
                "the in-flight round finishes; the follow-up dies with retirement")
    }
}
