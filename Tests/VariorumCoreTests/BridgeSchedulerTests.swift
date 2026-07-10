import Foundation
import Testing
@testable import VariorumCore

/// Phase 9b, Step 5 — the bridge lifecycle: serialized, coalescing rounds
/// (the SyncScheduler contract, per the plan's "scheduler-level tests");
/// a failed round keeps ALL bridge state (cursor + day hashes) intact for
/// retry; a retired scheduler never rounds again. The after-sync ORDERING
/// lives in the app layer (AppServices triggers the bridge from sync
/// round-completions) — thin wiring documented there; the serialization
/// guarantees live here.
@Suite("Bridge scheduler (Phase 9b, Step 5)")
struct BridgeSchedulerTests {
    /// A transport wrapper that can hold calls at a gate and fail on
    /// demand — the GatedSpyTransport pattern for the Fragments dialect.
    actor GatedBridgeTransport: FragmentsBridgeTransport {
        enum Call: Equatable { case pull, push(count: Int), delete }
        private let server: FakeFragmentsServer
        private(set) var calls: [Call] = []
        private var gated = false
        private var gateWaiters: [CheckedContinuation<Void, Never>] = []
        private var arrivalWaiters: [CheckedContinuation<Void, Never>] = []
        private var failing = false

        init(server: FakeFragmentsServer) {
            self.server = server
        }

        func closeGate() { gated = true }
        func openGate() {
            gated = false
            let waiters = gateWaiters
            gateWaiters.removeAll()
            for waiter in waiters { waiter.resume() }
        }
        func setFailing(_ failing: Bool) { self.failing = failing }
        func awaitCallAtGate() async {
            if !gateWaiters.isEmpty { return }
            await withCheckedContinuation { arrivalWaiters.append($0) }
        }

        private func passGate() async throws {
            for waiter in arrivalWaiters { waiter.resume() }
            arrivalWaiters.removeAll()
            if gated {
                await withCheckedContinuation { gateWaiters.append($0) }
            }
            if failing { throw FragmentsTransportError.notHTTP }
        }

        func push(_ entries: [FragmentsEntry]) async throws -> FragmentsPushResponse {
            calls.append(.push(count: entries.count))
            try await passGate()
            return try await server.push(entries)
        }

        func pull(after cursor: FragmentsPullCursor?, limit: Int) async throws -> [FragmentsEntry] {
            calls.append(.pull)
            try await passGate()
            return try await server.pull(after: cursor, limit: limit)
        }

        func delete(ids: [String]) async throws -> Int {
            calls.append(.delete)
            try await passGate()
            return try await server.delete(ids: ids)
        }

        func fetchLocalUserID() async throws -> String? {
            try await passGate()
            return try await server.fetchLocalUserID()
        }
    }

    @Test func triggersMidRoundCoalesceIntoOneFollowUp() async throws {
        try await withBridge { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "text")
            let gate = GatedBridgeTransport(server: bridge.server)
            let engine = BridgeEngine(transport: gate, configuration: bridge.config)
            let scheduler = BridgeScheduler(engine: engine)

            await gate.closeGate()
            await scheduler.trigger()
            await gate.awaitCallAtGate()  // round 1 is genuinely mid-flight
            // A burst of triggers while the round runs…
            for _ in 0..<5 { await scheduler.trigger() }
            await gate.openGate()
            await scheduler.awaitIdle()

            // …collapses into exactly ONE follow-up round: 2 rounds total.
            let status = await scheduler.status
            #expect(status.roundsCompleted == 2)
            #expect(status.lastError == nil)
        }
    }

    @Test func aFailedRoundKeepsCursorAndDayStateIntact() async throws {
        try await withBridge { bridge in
            // A healthy first round lands one Fragments entry and records
            // state.
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Landed.", updatedAt: bridge.fragmentsStamp(0))
            let gate = GatedBridgeTransport(server: bridge.server)
            let engine = BridgeEngine(transport: gate, configuration: bridge.config)
            let scheduler = BridgeScheduler(engine: engine)
            await scheduler.trigger()
            await scheduler.awaitIdle()
            let cursorBefore = try await bridge.db.read { try BridgeEngine.cursor($0) }
            let stateBefore = try bridge.dayState("2026-07-09")
            #expect(cursorBefore != nil)
            #expect(stateBefore != nil)

            // The next round fails at the transport (offline).
            await gate.setFailing(true)
            await scheduler.trigger()
            await scheduler.awaitIdle()
            let status = await scheduler.status
            #expect(status.lastError != nil)
            #expect(status.roundsCompleted == 2)
            // Nothing moved: cursor and day hashes intact for retry.
            #expect(try await bridge.db.read { try BridgeEngine.cursor($0) } == cursorBefore)
            #expect(try bridge.dayState("2026-07-09") == stateBefore)

            // Healed: the retry succeeds and clears the error.
            await gate.setFailing(false)
            await scheduler.trigger()
            await scheduler.awaitIdle()
            #expect(await scheduler.status.lastError == nil)
        }
    }

    @Test func aRetiredSchedulerNeverRoundsAgain() async throws {
        try await withBridge { bridge in
            let gate = GatedBridgeTransport(server: bridge.server)
            let engine = BridgeEngine(transport: gate, configuration: bridge.config)
            let scheduler = BridgeScheduler(engine: engine)
            await scheduler.trigger()
            await scheduler.awaitIdle()
            #expect(await scheduler.status.roundsCompleted == 1)

            await scheduler.retire()
            await scheduler.trigger()
            await scheduler.awaitIdle()
            #expect(await scheduler.status.roundsCompleted == 1, "retired refuses new rounds")
        }
    }

    /// THE MINOR-4 PIN (review round 1): a permanent per-day failure — a
    /// live Fragments row for our (user, date) under a NON-derived id
    /// (legacy data / derivation drift; the class asks 8–10 exist to
    /// catch) — lands fine by date, but every push of that day rejects with
    /// the unique violation, forever. Pre-fix the round reported "success"
    /// and nothing surfaced (the day's projection silently frozen). Now the
    /// rejection reaches `Status.issueNotes` every round, visibly.
    @Test func aPermanentPushRejectionSurfacesInTheStatus() async throws {
        try await withBridge { bridge in
            // A foreign-id live row occupies the day on the server.
            _ = try await bridge.server.push([FragmentsEntry(
                id: "11111111-1111-4111-8111-111111111111",
                userID: bridge.config.userID, date: "2026-07-09",
                body: "row under a wrong id",
                createdAt: bridge.fragmentsStamp(0), updatedAt: bridge.fragmentsStamp(0))])
            // Variorum's entry for the same day diverges from it.
            try bridge.makeEntry(day: "2026-07-09", text: "Local text to project.")

            let scheduler = BridgeScheduler(engine: bridge.engine)
            await scheduler.trigger()
            await scheduler.awaitIdle()
            let status = await scheduler.status
            #expect(status.lastError == nil, "the round itself succeeds — that is the trap")
            #expect(!status.issueNotes.isEmpty,
                    "a recurring per-day rejection must be visible, not a healthy 'Bridged at …'")
            #expect(status.issueNotes.contains { $0.contains("derivation bug") })

            // Reconciliation: unique_violation = a mis-derived id — the day
            // is POISONED: held on every later round (visible), never
            // re-pushed (their confirmed never-retry treatment).
            let writesBefore = await bridge.server.acceptedWriteCount
            await scheduler.trigger()
            await scheduler.awaitIdle()
            #expect(await scheduler.status.issueNotes.contains { $0.contains("derivation bug") })
            #expect(await bridge.server.acceptedWriteCount == writesBefore,
                    "a poisoned day is never re-pushed")
        }
    }

    @Test func statusSurfacesTheDuplicateDayPause() async throws {
        try await withBridge { bridge in
            let dupA = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupA.id, text: "A", at: .end)
            let dupB = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupB.id, text: "B", at: .end)

            let scheduler = BridgeScheduler(engine: bridge.engine)
            await scheduler.trigger()
            await scheduler.awaitIdle()
            #expect(await scheduler.status.pausedDays == ["2026-07-09"])

            // Hand-merge → the pause clears from the surface.
            try bridge.ops.deleteContainer(dupB.id)
            await scheduler.trigger()
            await scheduler.awaitIdle()
            #expect(await scheduler.status.pausedDays.isEmpty)
        }
    }

    /// The round is pull → push, pinned (reconcile before projecting —
    /// what makes first contact safe).
    @Test func aRoundPullsBeforeItPushes() async throws {
        try await withBridge { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "to push")
            let gate = GatedBridgeTransport(server: bridge.server)
            let engine = BridgeEngine(transport: gate, configuration: bridge.config)
            let scheduler = BridgeScheduler(engine: engine)
            await scheduler.trigger()
            await scheduler.awaitIdle()
            let calls = await gate.calls
            #expect(calls.first == .pull)
            #expect(calls.contains { if case .push = $0 { return true }; return false })
            let firstPushIndex = calls.firstIndex { if case .push = $0 { return true }; return false }
            let lastPullIndex = calls.lastIndex(of: .pull)
            #expect(lastPullIndex! < firstPushIndex!, "every pull precedes the push half")
        }
    }
}
