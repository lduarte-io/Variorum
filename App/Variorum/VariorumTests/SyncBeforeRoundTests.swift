//
//  SyncBeforeRoundTests.swift
//  VariorumTests
//
//  VX-683 A (the VX-849 run, batch 1 — the record
//  `notes/plans/fixes/vx-849-typed-over-rescue.md`, BATCH 1 RECORD; the memo
//  `notes/plans/fixes/vx-683-sync-into-debounce.md`, R-683-3; D-544 build step
//  3a's seam, minted here — batch 2 wires VX-544's retry onto it):
//  `SyncSession.beforeRound`, the occasion run to its end before EVERY round
//  the session's own roads start (`triggerSync`, `flush`, `roundNow`), behind
//  the restore hold, nil = inert. And the Mac's composition of it
//  (`AppServices`): her pending typing lands first — only when typing IS
//  pending (R-683-3: a quiet round touches no coordinator).
//
//  RED ON OLD: every pin names the new `beforeRound` (COMPILE-red on the
//  pre-fix tree); their BEHAVIORAL red is the batch record's named revert
//  (the roads ignore the occasion). The nil-occasion pin is a guard.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

/// A transport that writes every call it serves into a shared log, so the
/// ORDER of the occasion and the round's first call is observable.
private actor OrderLogTransport: SyncTransport {
    private let log: LockIsolated<[String]>
    init(log: LockIsolated<[String]>) { self.log = log }
    private func note(_ call: String) { log.withValue { $0.append("transport:\(call)") } }

    func fetchChallenges(_ count: Int) async throws -> [String] {
        note("fetchChallenges")
        return (0..<max(count, 1)).map { _ in Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString() }
    }
    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {
        note("enrollKeyProof")
    }
    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
        note("push")
        return batch.map { _ in .rejected(current: nil) }
    }
    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?)
        async throws -> [SyncPulledRow]
    {
        note("pull")
        return []
    }
    func schemaVersion() async throws -> Int {
        note("schemaVersion")
        return SyncSchema.lockstepVersion
    }
}

@MainActor
@Suite("VX-683 A — the occasion before every round (SyncSession.beforeRound)", .serialized)
struct SyncBeforeRoundTests {
    private static func withWorld(_ body: @MainActor (AppDatabase) async throws -> Void) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 683))
            $0.ownerIdentity = OwnerIdentity { "owner-683" }
        } operation: { @MainActor in
            try await body(db)
            // A retired chain's cancelled tasks hold `db` in their task locals
            // (`FirstRoundRoadTests.withWorld`'s reason).
            try? await Task.sleep(for: .milliseconds(200))
        }
    }

    /// An occasion that takes real time (two hops and a sleep) and logs both
    /// ends — a round that started before it finished would log between.
    private static func occasion(_ log: LockIsolated<[String]>) -> @MainActor () async -> Void {
        {
            log.withValue { $0.append("occasion:start") }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(30))
            log.withValue { $0.append("occasion:end") }
        }
    }

    private static func eventually(_ predicate: () -> Bool) async -> Bool {
        for _ in 0..<2000 {
            if predicate() { return true }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
        return predicate()
    }

    /// The log's shape: the occasion ran whole, and nothing of the round's
    /// reached the transport before it ended.
    private static func occasionPrecedesTheRound(_ entries: [String]) -> Bool {
        guard let end = entries.firstIndex(of: "occasion:end"),
              let start = entries.firstIndex(of: "occasion:start"),
              let firstCall = entries.firstIndex(where: { $0.hasPrefix("transport:") })
        else { return false }
        return start < end && end < firstCall
    }

    /// **`triggerSync` — the road every trigger funnels through** (the settle
    /// observation, became-active, Sync now): the occasion runs to its end,
    /// THEN the round starts.
    @Test func triggerSyncRunsTheOccasionToItsEndBeforeTheRound() async throws {
        try await Self.withWorld { db in
            let log = LockIsolated<[String]>([])
            let session = SyncSession(database: db, allowsSync: true)
            await session.configure(transport: OrderLogTransport(log: log), keyProvider: AppTestKeyProvider())
            session.beforeRound = Self.occasion(log)
            session.triggerSync()
            #expect(await Self.eventually { log.value.contains("transport:pull") }, "the round ran")
            #expect(Self.occasionPrecedesTheRound(log.value), "\(log.value)")
            session.stop()
        }
    }

    /// **`flush` — the iOS background transition's road**: same order.
    @Test func flushRunsTheOccasionToItsEndBeforeItsRound() async throws {
        try await Self.withWorld { db in
            let log = LockIsolated<[String]>([])
            let session = SyncSession(database: db, allowsSync: true)
            await session.configure(transport: OrderLogTransport(log: log), keyProvider: AppTestKeyProvider())
            session.beforeRound = Self.occasion(log)
            await session.flush()
            #expect(log.value.contains("transport:pull"), "the round ran")
            #expect(Self.occasionPrecedesTheRound(log.value), "\(log.value)")
            session.stop()
        }
    }

    /// **`roundNow` — an account act's first round**: same order.
    @Test func roundNowRunsTheOccasionToItsEndBeforeItsRound() async throws {
        try await Self.withWorld { db in
            let log = LockIsolated<[String]>([])
            let session = SyncSession(database: db, allowsSync: true)
            await session.configure(transport: OrderLogTransport(log: log), keyProvider: AppTestKeyProvider())
            session.beforeRound = Self.occasion(log)
            guard case .ran = await session.roundNow() else {
                Issue.record("the round ran")
                return
            }
            #expect(Self.occasionPrecedesTheRound(log.value), "\(log.value)")
            session.stop()
        }
    }

    /// Under the restore hold NOTHING runs (13x row 7) — not the round, and not
    /// the occasion either: a held store is not being synced.
    @Test func aHeldStoreRunsNeitherTheOccasionNorARound() async throws {
        try await Self.withWorld { db in
            let log = LockIsolated<[String]>([])
            let session = SyncSession(database: db, allowsSync: true)
            session.roundsHeld = { true }
            await session.configure(transport: OrderLogTransport(log: log), keyProvider: AppTestKeyProvider())
            session.beforeRound = Self.occasion(log)
            session.triggerSync()
            await session.flush()
            #expect(await session.roundNow() == .held)
            try await Task.sleep(for: .milliseconds(100))
            #expect(log.value.isEmpty, "\(log.value)")
            session.stop()
        }
    }

    /// GUARD — nil is inert: no occasion, the rounds run exactly as before.
    @Test func noOccasionIsInert() async throws {
        try await Self.withWorld { db in
            let log = LockIsolated<[String]>([])
            let session = SyncSession(database: db, allowsSync: true)
            await session.configure(transport: OrderLogTransport(log: log), keyProvider: AppTestKeyProvider())
            #expect(session.beforeRound == nil, "every existing composition: unwired")
            session.triggerSync()
            #expect(await Self.eventually { log.value.contains("transport:pull") })
            #expect(!log.value.contains { $0.hasPrefix("occasion:") })
            session.stop()
        }
    }

    // MARK: - The Mac's composition (AppServices)

    private static func stored(_ db: AppDatabase, _ variantID: String) throws -> String? {
        try db.read { try Variant.fetchOne($0, key: variantID)?.workingText }
    }

    private static func services(_ db: AppDatabase) -> AppServices {
        let auth = AuthSession(
            configuration: AuthConfiguration(projectURL: URL(string: "https://vx683.invalid")!, apiKey: "k"),
            store: .inMemory(), http: { _ in throw AuthSessionError.malformedResponse("no network") })
        return AppServices(
            session: AppSession(database: db), storeVariant: .real, backupEnabled: false, auth: auth,
            makeSyncKeyProvider: { AppTestKeyProvider() }, legacyCleanup: {})
    }

    /// **THE MAC'S OCCASION: her pending typing lands before the round.** A
    /// coordinator holding typed text (inside its debounce) is flushed by the
    /// composed occasion, so the round meets a DIRTY row and the standing S5
    /// road takes it from there (the core's `FlushBeforeTheRoundConvergenceTests`).
    @Test func theMacsOccasionLandsPendingTypingBeforeTheRound() async throws {
        try await Self.withWorld { db in
            let services = Self.services(db)
            let session = services.session
            let post = try session.operations.createPost(title: "typing")
            let made = try session.operations.newBlock(in: post.id, text: "Base.", registeringUndo: false)
            let coordinator = session.autosave(forPost: post.id, sleep: { _ in throw CancellationError() })
            coordinator.record(variantID: made.variant.id, text: "Base. Typed.", charDelta: 7, basedOn: "Base.")
            #expect(coordinator.isDirty, "fixture: typing is pending")

            let occasion = try #require(services.sync.beforeRound, "the Mac composes the occasion")
            await occasion()

            #expect(!coordinator.isDirty, "her typing landed")
            #expect(try Self.stored(db, made.variant.id) == "Base. Typed.")
            services.stop()
        }
    }

    /// **R-683-3 — ONLY when typing is pending:** with every coordinator clean
    /// the occasion touches none of them — no flush runs, no settle is
    /// announced (a flush always announces one), so a quiet round costs the
    /// main thread one cheap check.
    @Test func theMacsOccasionTouchesNothingWhenNoTypingIsPending() async throws {
        try await Self.withWorld { db in
            let services = Self.services(db)
            let session = services.session
            let post = try session.operations.createPost(title: "quiet")
            _ = try session.operations.newBlock(in: post.id, text: "Still.", registeringUndo: false)
            let coordinator = session.autosave(forPost: post.id, sleep: { _ in throw CancellationError() })
            let settles = LockIsolated(0)
            let token = coordinator.observe(onSettled: { settles.withValue { $0 += 1 } })

            let occasion = try #require(services.sync.beforeRound)
            await occasion()

            #expect(settles.value == 0, "a clean coordinator was not flushed")
            #expect(coordinator.flushCount == 0)
            coordinator.stopObserving(token)
            services.stop()
        }
    }
}
