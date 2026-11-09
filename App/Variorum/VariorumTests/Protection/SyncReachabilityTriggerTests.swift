//
//  SyncReachabilityTriggerTests.swift
//  VariorumTests — VX-544 (the VX-849 run, batch 2 — D-544 (3b); her R-849-2: "the reachability trigger IS built — a
//  transition to connected runs one debounced round"; the record `notes/plans/fixes/vx-849-typed-over-rescue.md`, BATCH 2
//  RECORD). THE REACHABILITY TRIGGER in the shared `SyncSession`: the path watched while a chain stands; a transition to
//  satisfied from not-satisfied runs ONE round through `triggerSync` (so the occasion runs first) after the debounce; the
//  first reading alone never triggers; a path that drops inside the debounce cancels; a teardown stops the watch. Over a
//  PLANTED path (no Network framework) and a fake server; each round is counted by the occasion it runs.
//
//  RED ON OLD: the path seam does not exist on the pre-fix tree (COMPILE-red); the behavioral red is the record's named
//  revert (`pathReading` never schedules — no round ever follows the path coming back).
//

import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// A path a pin drives by hand: what the watch was handed, and every start and stop.
@MainActor
final class PlantedNetworkPath: NetworkPathWatching {
    private var reading: (@MainActor (Bool) -> Void)?
    private(set) var starts = 0
    private(set) var stops = 0

    var isWatched: Bool { reading != nil }

    func start(_ reading: @escaping @MainActor (Bool) -> Void) {
        starts += 1
        self.reading = reading
    }

    func stop() {
        stops += 1
        reading = nil
    }

    /// One reading, as `NWPathMonitor` would deliver it (nothing when unwatched).
    func send(_ satisfied: Bool) { reading?(satisfied) }
}

@Suite("VX-544 — the reachability trigger: the path coming back runs one debounced round (planted path)", .serialized)
@MainActor
struct SyncReachabilityTriggerTests {
    static let debounce: Duration = .milliseconds(120)
    /// Comfortably past the debounce (the round's own hops included).
    static let pastTheDebounce: Duration = .milliseconds(500)

    /// A configured session watching `path`, every round it starts counted by its occasion.
    static func watching(
        _ path: PlantedNetworkPath, held: Bool = false, _ body: @MainActor (SyncSession, LockIsolated<Int>) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 544))
            $0.ownerIdentity = OwnerIdentity { "owner-544" }
        } operation: { @MainActor in
            let session = SyncSession(database: db, allowsSync: true, path: path, reachabilityDebounce: Self.debounce)
            if held { session.roundsHeld = { true } }
            let rounds = LockIsolated(0)
            await session.configure(transport: FirstRoundServer(), keyProvider: AppTestKeyProvider())
            session.beforeRound = { rounds.withValue { $0 += 1 } }
            try await body(session, rounds)
            session.stop()
            try? await Task.sleep(for: .milliseconds(150))
        }
    }

    /// **THE PIN — THE PATH COMING BACK RUNS ONE ROUND, DEBOUNCED**: not satisfied, then satisfied — nothing before the
    /// debounce, exactly one round after it.
    @Test func aTransitionToSatisfiedRunsOneRoundAfterTheDebounce() async throws {
        let path = PlantedNetworkPath()
        try await Self.watching(path) { _, rounds in
            #expect(path.starts == 1 && path.isWatched, "the chain watches the path")
            path.send(false)
            path.send(true)
            #expect(rounds.value == 0, "debounced: nothing at once")
            try await Task.sleep(for: Self.pastTheDebounce)
            #expect(rounds.value == 1, "one round after the debounce")
        }
    }

    /// The FIRST reading alone — satisfied or not — runs nothing (the path as it stands; a chain just composed runs its own
    /// round, and a launch offline waits for the path to come up).
    @Test func theFirstReadingAloneRunsNothing() async throws {
        for first in [true, false] {
            let path = PlantedNetworkPath()
            try await Self.watching(path) { _, rounds in
                path.send(first)
                try await Task.sleep(for: Self.pastTheDebounce)
                #expect(rounds.value == 0, "first reading \(first): nothing")
            }
        }
    }

    /// A path that STAYS satisfied (an interface change on a live path, a repeated reading) runs nothing more.
    @Test func aPathStayingSatisfiedRunsNothingMore() async throws {
        let path = PlantedNetworkPath()
        try await Self.watching(path) { _, rounds in
            path.send(false)
            path.send(true)
            try await Task.sleep(for: Self.pastTheDebounce)
            #expect(rounds.value == 1)
            path.send(true)
            path.send(true)
            try await Task.sleep(for: Self.pastTheDebounce)
            #expect(rounds.value == 1, "satisfied after satisfied: nothing")
        }
    }

    /// A path that DROPS AGAIN inside the debounce cancels the round; the one that settles satisfied runs it — a flapping
    /// network earns one round.
    @Test func aPathThatDropsAgainInsideTheDebounceRunsOnlyOnceItSettles() async throws {
        let path = PlantedNetworkPath()
        try await Self.watching(path) { _, rounds in
            path.send(false)
            path.send(true)
            path.send(false)
            try await Task.sleep(for: Self.pastTheDebounce)
            #expect(rounds.value == 0, "dropped inside the debounce: cancelled")
            path.send(true)
            path.send(false)
            path.send(true)
            try await Task.sleep(for: Self.pastTheDebounce)
            #expect(rounds.value == 1, "settled: one round")
        }
    }

    /// EACH satisfied transition runs its own round.
    @Test func eachSatisfiedTransitionRunsItsOwnRound() async throws {
        let path = PlantedNetworkPath()
        try await Self.watching(path) { _, rounds in
            path.send(false)
            path.send(true)
            try await Task.sleep(for: Self.pastTheDebounce)
            path.send(false)
            path.send(true)
            try await Task.sleep(for: Self.pastTheDebounce)
            #expect(rounds.value == 2)
        }
    }

    /// The watch RIDES THE CHAIN: a stop ends it (a round scheduled inside the debounce cancelled with it), and a
    /// reconfigure starts a fresh one whose first reading is a baseline again.
    @Test func theWatchRidesTheChain() async throws {
        let path = PlantedNetworkPath()
        try await Self.watching(path) { session, rounds in
            path.send(false)
            path.send(true)
            session.stop()
            #expect(!path.isWatched && path.stops >= 1, "stopped with the chain")
            try await Task.sleep(for: Self.pastTheDebounce)
            #expect(rounds.value == 0, "the round scheduled before the stop was cancelled with it")
            await session.configure(transport: FirstRoundServer(), keyProvider: AppTestKeyProvider())
            #expect(path.isWatched && path.starts == 2, "a fresh watch with the fresh chain")
            path.send(true)
            try await Task.sleep(for: Self.pastTheDebounce)
            #expect(rounds.value == 0, "its first reading is a baseline")
        }
    }

    /// Under the restore hold the path coming back runs nothing (`triggerSync`'s gate — 13x row 7).
    @Test func aHeldStoreRunsNothingWhenThePathComesBack() async throws {
        let path = PlantedNetworkPath()
        try await Self.watching(path, held: true) { _, rounds in
            path.send(false)
            path.send(true)
            try await Task.sleep(for: Self.pastTheDebounce)
            #expect(rounds.value == 0)
        }
    }

    /// GUARD — no path, no watch: a composition that names none is the pre-trigger session exactly.
    @Test func noPathIsInert() async throws {
        let db = try AppDatabase.inMemory()
        let session = SyncSession(database: db, allowsSync: true)
        await session.configure(transport: FirstRoundServer(), keyProvider: AppTestKeyProvider())
        session.stop()
    }

    /// THE COMPOSITION: the services hand their path to the chain — it is watched once the chain composes (a signed-in
    /// start), and released at the services' stop.
    @Test func theServicesHandTheirPathToTheChain() async throws {
        let db = try AppDatabase.inMemory()
        await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 545))
            $0.ownerIdentity = OwnerIdentity { "owner-545" }
        } operation: { @MainActor in
            let path = PlantedNetworkPath()
            let auth = AuthSession(
                configuration: AuthConfiguration(projectURL: URL(string: "https://vx544-path.invalid")!, apiKey: "k"),
                store: .inMemory(), http: { _ in throw AuthSessionError.malformedResponse("no network") })
            await auth.adopt(AuthTokens(
                accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600), userID: "owner-545",
                email: nil))
            let services = AppServices(
                session: AppSession(database: db), storeVariant: .real, backupEnabled: false, auth: auth,
                makeSyncTransport: { _ in FirstRoundServer() }, makeSyncKeyProvider: { AppTestKeyProvider() },
                networkPath: path, legacyCleanup: {})
            #expect(!path.isWatched, "no chain, no watch")
            await services.start()
            #expect(services.sync.isConfigured && path.isWatched, "the chain watches the services' path")
            services.stop()
            #expect(!path.isWatched, "released at the stop")
            try? await Task.sleep(for: .milliseconds(150))
        }
    }
}
