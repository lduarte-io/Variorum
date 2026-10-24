//
//  FirstRoundAfterTheActTests.swift
//  VariorumTests — VX-510 unit A (VX-498 · VX-507): THE FIRST ROUND AFTER THE ACT, end to end over what ships — the bootstrap
//  over the PLANTED road (no keychain; the planted vault and sync keys — `ProtectionAccountSupport`), the app's real
//  `AppServices` and `SyncSession` attached through the ONE composition function (`AppBootstrap.attach(services:)`), and a
//  fake server that accepts everything (no network). Also runs headless in the implementer's SwiftPM harness.
//
//  THE MECHANISM (the run record's T-1): on 0.10, Turn on sync lands on the OPEN session — the vault written, the record
//  naming the account, the keys held — but nothing starts a sync round afterwards, so the row keeps the pre-act round's
//  "Sync locked" until something else triggers one (typing, switching apps, Sync now, a relaunch). VX-329 U1 deleted the
//  old road's post-enrollment round hook and never rewired it.
//    - VX-498: a set-up through the attach glue runs a round with no relaunch and no other trigger. RED on old: zero
//      rounds after the act.
//    - VX-507: the act's sheet does not close on its own at `.made` — it stays to confirm its first round. RED on old: the
//      sheet went at `.made`.
//
//  This world is the first case of VX-509's standing drill (unit B extends it across every arm): `FirstRoundWorld` is the
//  seam it builds on.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

/// A dumb server that accepts every push and has nothing to pull — the engine's round lands clean against it. Counts the
/// round's data calls (a round refused for keys makes none: the engine refuses before any network contact).
actor FirstRoundServer: SyncTransport {
    private(set) var pulls = 0
    private(set) var pushes = 0
    private(set) var enrollments = 0
    private var seq: Int64 = 0

    func fetchChallenges(_ count: Int) async throws -> [String] {
        (0..<max(count, 1)).map { _ in Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString() }
    }
    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws { enrollments += 1 }
    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
        pushes += 1
        return batch.map { row in
            seq += 1
            return .accepted(newVersion: row.syncVersion + 1, serverSeq: seq)
        }
    }
    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws
        -> [SyncPulledRow]
    {
        pulls += 1
        return []
    }
    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
}

/// VX-510's end-to-end world: a library created on the planted road (its twelve words in hand — the Mac's bootstrap drops a
/// creation's words unseen), the bootstrap opened on it quietly, signed in to the planted account, and the app's services
/// composed over the ready session exactly as `VariorumApp` composes them — attached through `AppBootstrap.attach`.
@MainActor
final class FirstRoundWorld {
    typealias Account = PlantedAccount

    let road: PlantedRoad
    let vault: PlantedVaultLeaf
    let keys: PlantedSyncKeysLeaf
    let words: [String]
    let bootstrap: AppBootstrap
    let server = FirstRoundServer()
    let auth: AuthSession
    private(set) var services: AppServices?

    private static let authConfiguration = AuthConfiguration(
        projectURL: URL(string: "https://vx510-first-round.invalid")!, apiKey: "publishable")

    private init(road: PlantedRoad, vault: PlantedVaultLeaf, keys: PlantedSyncKeysLeaf, words: [String]) {
        self.road = road
        self.vault = vault
        self.keys = keys
        self.words = words
        let url = road.slot.places.slot
        bootstrap = AppBootstrap(
            testStoreURL: url,
            protectionRoad: ProtectionRoadTestHarness(system: road.system(), session: Account.signedIn, open: { key in
                Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                    .mapError { $0 as? AppDatabase.StoreOpenError
                        ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
            }))
        auth = AuthSession(
            configuration: Self.authConfiguration, store: .inMemory(),
            http: { _ in throw AuthSessionError.malformedResponse("no network in this test") })
    }

    /// The world, its bootstrap READY on the library (call inside `run`).
    static func make() async throws -> FirstRoundWorld {
        let (road, vault, keys) = Account.road()
        road.session = Account.signedIn
        let (_, words) = try await road.created()
        let world = FirstRoundWorld(road: road, vault: vault, keys: keys, words: words)
        await world.bootstrap.awaitOpen()
        if case .opening = world.bootstrap.state { await world.bootstrap.awaitOpen() }
        guard case .ready = world.bootstrap.state else {
            Issue.record("the planted library opens quietly: \(world.bootstrap.state)")
            throw RoadWorld.RoadWorldError.notCreated
        }
        return world
    }

    var readySession: AppSession? {
        if case .ready(let session) = bootstrap.state { return session }
        return nil
    }

    /// `VariorumApp`'s `.task`, for this world: signed in as the planted account (the library's account once it joins),
    /// the services composed over the ready session with the bootstrap's own key seam and bound-account read, attached
    /// through the ONE composition function, then started (the sign-in's chain: owner adoption, configure, a trigger).
    /// The real store's variant — the A4 fence lets only the real store pair with a server (`Phase9cAuthWiringTests`'
    /// precedent); the server here is the fake.
    func composeServices() async throws -> AppServices {
        let session = try #require(readySession)
        await auth.adopt(AuthTokens(
            accessToken: "access", refreshToken: "refresh", expiresAt: Date().addingTimeInterval(3600),
            userID: Account.account, email: Account.email))
        let server = server
        let services = AppServices(
            session: session, storeVariant: .real, backupEnabled: false, auth: auth,
            makeSyncTransport: { _ in server },
            makeSyncKeyProvider: { [newRoadSyncKeys = bootstrap.newRoadSyncKeys] in newRoadSyncKeys },
            boundAccountRead: { @Sendable [newRoadSyncKeys = bootstrap.newRoadSyncKeys] in newRoadSyncKeys.boundAccount },
            legacyCleanup: {})
        self.services = services
        bootstrap.attach(services: services)
        await services.start()
        return services
    }

    /// The pre-act rounds settled: the sign-in's trigger (and, when the fresh library's outbox holds rows, the settle
    /// trigger 3 s later) — each refused for keys, the library not yet joined.
    func settlePreActRounds(_ services: AppServices) async throws {
        let session = try #require(readySession)
        let pending = try await session.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0 }
        let expected = pending > 0 ? 2 : 1
        await Self.settle(seconds: 10) {
            services.sync.status.roundsCompleted >= expected && !services.sync.status.isSyncing
        }
    }

    /// Turn on sync's set-up arm through the account section, as she presses it: the door read, its confirm opened through
    /// the one presenter, her new passphrase (twice) and the library's twelve words typed, the press.
    func turnOnSync() async throws -> RoadAccountConfirmModel {
        let account = try #require(bootstrap.roadAccount)
        await account.refresh()
        let door = try #require(account.faces?.turnOnSync.openDoor, "\(String(describing: account.faces?.turnOnSync))")
        #expect(door.spec.join == .setsUpInLibrarysMode, "no vault yet — the set-up arm")
        account.open(.turnOnSync)
        let confirm = try #require(account.confirm)
        await confirm.submit(
            passphrase: Account.passphrase, again: Account.passphrase, words: words.joined(separator: " "))
        return confirm
    }

    /// Polls `condition` on the main actor for at most `seconds`.
    static func settle(seconds: Double, until condition: @MainActor () async -> Bool) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            if await condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    /// The dependencies the world runs under: the clock and ids the bootstrap's `.ready` arm reads, the owner identity the
    /// sign-in's adoption stamps (the planted account), and — once the library is open — its database as the ambient one
    /// the engine's rounds read (`AppDatabase.install` is production's; a test bootstrap skips it).
    static func run(_ body: @MainActor (FirstRoundWorld) async throws -> Void) async throws {
        let owner = Account.account
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 510))
            $0.ownerIdentity = OwnerIdentity { owner }
        } operation: { @MainActor in
            let world = try await make()
            let database = try #require(world.readySession).database
            try await withDependencies {
                $0.database = database
            } operation: { @MainActor in
                try await body(world)
                world.services?.stop()
            }
        }
    }
}

@Suite("VX-510 unit A — the first round after the act (planted road, real services, a fake server)", .serialized)
@MainActor
struct FirstRoundAfterTheActTests {
    private static let keysLocked = String(describing: SyncError.encryptionKeysUnavailable)

    /// **VX-498 — THE PIN (red on old: zero rounds after the act).** Before the act the library has not joined: the
    /// sign-in's rounds refuse for keys ("Sync locked"). Turn on sync lands on the open session — and a round then runs
    /// with the account's keys, with NO relaunch and no other trigger (no typing, no app switch, no Sync now): the server
    /// sees the round's pull and push, and the row's status reads a clean round.
    @Test func vx498_aSetUpRunsItsFirstRoundWithNoRelaunch() async throws {
        try await FirstRoundWorld.run { world in
            let services = try await world.composeServices()
            #expect(services.sync.isConfigured, "signed in: the chain composed at the sign-in")
            try await world.settlePreActRounds(services)
            #expect(services.sync.status.lastError == Self.keysLocked, "before the act the rounds refuse for keys")
            #expect(services.sync.status.lastSuccessAt == nil)
            #expect(await world.server.pulls == 0, "a keys refusal makes no network contact")
            let roundsBefore = services.sync.status.roundsCompleted

            _ = try await world.turnOnSync()
            #expect(world.bootstrap.roadSession?.library.record?.account == FirstRoundWorld.Account.account,
                    "the act landed: the record names the account")
            #expect(world.vault.snapshot(FirstRoundWorld.Account.account) != nil, "the vault is written")

            await FirstRoundWorld.settle(seconds: 5) {
                services.sync.status.lastSuccessAt != nil && !services.sync.status.isSyncing
            }
            #expect(services.sync.status.roundsCompleted > roundsBefore, "a round ran after the act — no relaunch")
            #expect(services.sync.status.lastError == nil, "with the account's keys: \(String(describing: services.sync.status.lastError))")
            #expect(services.sync.status.lastSuccessAt != nil, "the row reads a clean round")
            #expect(await world.server.pulls > 0, "the round reached the server")
        }
    }

    /// **VX-507 — THE PIN (red on old: the sheet went at `.made`).** The set-up's confirm does not close on its own when
    /// the act lands: it stays to confirm its first round (or say what blocks it).
    @Test func vx507_theSetUpsSheetStaysAfterTheActLands() async throws {
        try await FirstRoundWorld.run { world in
            let services = try await world.composeServices()
            try await world.settlePreActRounds(services)
            let confirm = try await world.turnOnSync()
            #expect(world.bootstrap.roadSession?.library.record?.account == FirstRoundWorld.Account.account, "the act landed")
            #expect(confirm.refusal == nil)
            #expect(world.bootstrap.roadAccount?.confirm === confirm, "the sheet stays to confirm its first round")
        }
    }
}
