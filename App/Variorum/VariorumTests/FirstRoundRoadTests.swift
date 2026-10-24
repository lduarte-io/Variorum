//
//  FirstRoundRoadTests.swift
//  VariorumTests — VX-510 unit A (D-A1): THE FIRST-ROUND ROAD under the account confirm — `SyncSession.roundNow()` (one
//  round run to its end on the scheduler's EXISTING public API — trigger, wait for idle, read the status — no `Sync/`
//  line) and `AppServices.runFirstRound()` (the resume leaf's shape: a chain nothing configured is reconnected first). In
//  memory, a fake server, no network; also runs headless in the implementer's SwiftPM harness. Guards of new seams (no old
//  side exists to be red on); their teeth are shown by the record's behavioral reverts.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// A server whose DATA calls can be parked at a gate — a round provably mid-flight (`Phase8ServicesTests`' gate, restated:
/// that one is file-private there).
actor FirstRoundGateServer: SyncTransport {
    private var gated: Bool
    private var gateWaiters: [CheckedContinuation<Void, Never>] = []
    private var arrivalWaiters: [CheckedContinuation<Void, Never>] = []
    private var parked = false
    private(set) var pulls = 0

    init(gated: Bool = true) { self.gated = gated }

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
        (0..<max(count, 1)).map { _ in Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString() }
    }
    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {}
    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
        batch.enumerated().map { index, row in .accepted(newVersion: row.syncVersion + 1, serverSeq: Int64(index + 1)) }
    }
    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws
        -> [SyncPulledRow]
    {
        pulls += 1
        await pass()
        return []
    }
    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
}

@MainActor
@Suite("VX-510 unit A — the first-round road (roundNow, runFirstRound)", .serialized)
struct FirstRoundRoadTests {
    private static func withWorld(
        _ body: @MainActor (AppDatabase) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 510))
            $0.ownerIdentity = OwnerIdentity { "owner-510" }
        } operation: { @MainActor in
            try await body(db)
            // Every retired chain's cancelled tasks hold `db` in their task locals: a moment to unwind before the process
            // could exit under one (`FirstRoundWorld.quiesce`'s reason).
            try? await Task.sleep(for: .milliseconds(200))
        }
    }

    /// Nothing configured — a fresh session, and the dev store's fenced one — answers "not configured" at once, never a
    /// wait.
    @Test func roundNowWithNoChainSaysNotConfigured() async throws {
        try await Self.withWorld { db in
            #expect(await SyncSession(database: db, allowsSync: true).roundNow() == .notConfigured)
            let dev = SyncSession(database: db, allowsSync: false)
            await dev.configure(transport: FirstRoundServer(), keyProvider: AppTestKeyProvider())
            #expect(await dev.roundNow() == .notConfigured, "the A4 fence: a dev store never pairs")
        }
    }

    /// Under the restore hold no round runs (13x row 7): "held", and the server sees nothing.
    @Test func roundNowUnderTheRestoreHoldSaysHeldAndRunsNothing() async throws {
        try await Self.withWorld { db in
            let server = FirstRoundServer()
            let session = SyncSession(database: db, allowsSync: true)
            session.roundsHeld = { true }
            await session.configure(transport: server, keyProvider: AppTestKeyProvider())
            #expect(await session.roundNow() == .held)
            #expect(await server.pulls == 0, "held: nothing ran")
            session.stop()
        }
    }

    /// ONE round runs to its end and its status comes back: clean against the accepting server.
    @Test func roundNowRunsOneRoundToItsEndAndReturnsItsStatus() async throws {
        try await Self.withWorld { db in
            let server = FirstRoundServer()
            let session = SyncSession(database: db, allowsSync: true)
            await session.configure(transport: server, keyProvider: AppTestKeyProvider())
            guard case .ran(let status) = await session.roundNow() else {
                Issue.record("the round ran")
                return
            }
            #expect(status.lastError == nil && status.lastSuccessAt != nil && !status.isSyncing)
            #expect(status.roundsCompleted >= 1)
            #expect(await server.pulls >= 1, "the round reached the server")
            session.stop()
        }
    }

    /// COALESCING: asked while a round is in flight, roundNow waits for that round AND the one follow-up its trigger
    /// coalesces into — the follow-up is the round that reads the keys as they stand now.
    @Test func roundNowWaitsForTheFollowUpOfARoundInFlight() async throws {
        try await Self.withWorld { db in
            let gate = FirstRoundGateServer()
            let session = SyncSession(database: db, allowsSync: true)
            await session.configure(transport: gate, keyProvider: AppTestKeyProvider())
            session.triggerSync()
            await gate.awaitParked()  // a round is provably in flight
            let asked = Task { await session.roundNow() }
            try await Task.sleep(for: .milliseconds(50))
            await gate.open()
            guard case .ran(let status) = await asked.value else {
                Issue.record("the round ran")
                return
            }
            #expect(status.roundsCompleted == 2, "the round in flight, then the follow-up the ask coalesced into")
            #expect(await gate.pulls == 2)
            session.stop()
        }
    }

    /// `runFirstRound` reconnects a chain nothing configured (the resume leaf's shape — a stopped chain, signed in), then
    /// runs its round; the dev store's fence still answers "not configured".
    @Test func runFirstRoundReconnectsAnUnconfiguredChainThenRuns() async throws {
        try await Self.withWorld { db in
            let server = FirstRoundServer()
            let auth = AuthSession(
                configuration: AuthConfiguration(projectURL: URL(string: "https://vx510.invalid")!, apiKey: "k"),
                store: .inMemory(), http: { _ in throw AuthSessionError.malformedResponse("no network") })
            await auth.adopt(AuthTokens(
                accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600), userID: "owner-510",
                email: nil))
            let services = AppServices(
                session: AppSession(database: db), storeVariant: .real, backupEnabled: false, auth: auth,
                makeSyncTransport: { _ in server }, makeSyncKeyProvider: { AppTestKeyProvider() }, legacyCleanup: {})
            await services.start()
            #expect(services.sync.isConfigured)
            services.sync.stop()  // a chain that is not configured (a ceremony's pause, a sign-in gate that failed)
            #expect(!services.sync.isConfigured)
            guard case .ran(let status) = await services.runFirstRound() else {
                Issue.record("reconnected, then ran")
                return
            }
            #expect(services.sync.isConfigured, "the chain reconnected")
            #expect(status.lastError == nil && status.lastSuccessAt != nil)
            services.stop()

            let dev = AppServices(
                session: AppSession(database: db), storeVariant: .dev, backupEnabled: false, auth: auth,
                makeSyncTransport: { _ in server }, makeSyncKeyProvider: { AppTestKeyProvider() }, legacyCleanup: {})
            await dev.start()
            #expect(await dev.runFirstRound() == .notConfigured, "the A4 fence answers at once")
            dev.stop()
        }
    }
}
