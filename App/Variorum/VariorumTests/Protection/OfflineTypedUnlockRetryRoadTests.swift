//
//  OfflineTypedUnlockRetryRoadTests.swift
//  VariorumTests — VX-544 (the VX-849 run, batch 2 — D-544; her R-849-1 + R-849-2; the record
//  `notes/plans/fixes/vx-849-typed-over-rescue.md`, BATCH 2 RECORD). HER TWO-MAC TEST'S STEPS 8–9, END TO END OVER WHAT
//  SHIPS — the bootstrap over the PLANTED road (no keychain; `ProtectionAccountSupport`'s vault and sync keys), the app's
//  real `AppServices` and `SyncSession` attached through the ONE composition function (`AppBootstrap.attach(services:)`), a
//  fake server that accepts everything (no network): a library in Castle under Always ask, synced (VX-509's ARM 3 — the
//  passphrase set at Use Castle, the set-up in Castle); a LOCK; then the TYPED unlock while the vault is out of reach
//  (step 8 — "Wi-Fi off"): the library opens, the row says "Sync locked"; then the vault answers again (step 9 — "Wi-Fi back
//  on") and the NEXT ROUND runs with the keys, nothing typed again.
//    - THE PIN (pre-fix API only — BEHAVIOR-red on the pre-fix tree, where the round after step 9 still refuses for keys:
//      nothing kept the typed secret, nothing retried): `herOfflineTypedUnlockSyncsAtTheNextRoundOnceTheVaultAnswers`.
//    - the let-go roads through the bootstrap's own wiring (compile-red — they name the new seam): the lock, a sign-out, a
//      reopen that replaces the session.
//  The live confirmation is HERS — the two-Mac test's steps 8–9 on her Air, OWED (never claimed here).
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-544 — her offline typed unlock syncs once the vault answers (bootstrap, real services, planted road, fake server)",
       .serialized)
@MainActor
struct OfflineTypedUnlockRetryRoadTests {
    typealias Account = PlantedAccount
    typealias Drill = FirstRunDrillTests

    /// VX-509's ARM 3, to its first round: Use Castle under Always ask through the bootstrap's crossing (its reopen composes
    /// fresh services), then Turn on sync's Castle set-up (the passphrase set at Use Castle, the library's words). The
    /// library is in Castle, synced, its account's keys in session memory only — no item on this Mac at all.
    static func castleAlwaysAskSynced(_ world: FirstRoundWorld) async throws {
        world.reopensComposeFreshServices()
        try await world.settlePreActRounds(try await world.composeServices())
        try await world.useCastle(gate: .alwaysAsk)
        let services = try #require(world.services, "the crossing's reopen composed fresh services")
        try await world.settlePreActRounds(services)
        let confirm = try await Drill.press(
            world, passphrase: Crossing.passphrase, words: world.words, expecting: .setsUpInLibrarysMode)
        try await Drill.expectFirstRound(world, confirm, line: ProtectionWords.firstRoundSetUpLanded, row: .idle)
        #expect(world.bootstrap.roadSession?.library.record?.mode == .castle)
        #expect(world.bootstrap.roadSession?.library.record?.account == Account.account)
        #expect(world.keys.items.isEmpty, "Always ask: no sync-keys item on this Mac at all")
    }

    /// The LOCK, then the TYPED unlock at the lobby with the vault OUT OF REACH (step 8): the library opens (never hostage),
    /// the reopened ready arm composes fresh services, their first rounds settle refused for keys — "Sync locked".
    static func lockThenUnlockOffline(_ world: FirstRoundWorld) async throws -> AppServices {
        await world.bootstrap.lock()
        guard case .roadLobby(let lobby) = world.bootstrap.state else {
            Issue.record("Castle locks into the road's lobby — \(world.bootstrap.state)")
            throw RoadWorld.RoadWorldError.notCreated
        }
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "the lock dropped session memory")
        world.vault.reachable = false
        await lobby.unlock(passphrase: Crossing.passphrase)
        await world.bootstrap.awaitOpen()
        guard case .ready = world.bootstrap.state else {
            Issue.record("the typed passphrase opens the library offline — \(world.bootstrap.state) \(lobby.message ?? "")")
            throw RoadWorld.RoadWorldError.notCreated
        }
        await world.awaitReadyCompose()
        let services = try #require(world.services, "the unlock's ready arm composed fresh services")
        await FirstRoundWorld.settle(seconds: 15) {
            services.sync.status.roundsCompleted >= 1 && !services.sync.status.isSyncing
        }
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "offline: nothing loaded")
        #expect(Drill.row(world, services).kind == .keysLocked,
                "the row says Sync locked — \(String(describing: services.sync.status.lastError))")
        return services
    }

    /// **THE PIN — her steps 8–9.** Offline at the typed unlock, "Sync locked"; the vault answers again; the NEXT ROUND (any
    /// trigger's — here the session's own one-round road) runs with the account's keys: clean, "Synced", the keys in
    /// session memory, nothing typed again, nothing written to the keychain. RED on the pre-fix tree for the behavioral
    /// reason: the typed secret died with the failed read, so the round after step 9 still refused for keys.
    @Test func herOfflineTypedUnlockSyncsAtTheNextRoundOnceTheVaultAnswers() async throws {
        try await FirstRoundWorld.run { world in
            try await Self.castleAlwaysAskSynced(world)
            let services = try await Self.lockThenUnlockOffline(world)

            world.vault.reachable = true  // step 9 — the vault answers again
            guard case .ran(let status) = await services.sync.roundNow() else {
                Issue.record("the next round ran")
                return
            }
            #expect(status.lastError == nil, "the round ran with the keys — \(String(describing: status.lastError))")
            // (The row reads the session's observed status, which follows the scheduler's stream a hop later.)
            await FirstRoundWorld.settle(seconds: 5) {
                !services.sync.status.isSyncing && services.sync.status.lastError == nil
            }
            #expect(Drill.row(world, services).kind == .idle,
                    "the row says Synced — \(Drill.row(world, services).kind) \(String(describing: services.sync.status.lastError))")
            let held = try #require(world.keys.sessionSyncKeys(accountID: Account.account), "the keys loaded")
            #expect(held.rowKeyID == world.bootstrap.roadSession?.library.record?.accountRowKeyID)
            #expect(world.keys.items.isEmpty, "nothing written to the keychain — session memory only")
        }
    }

    /// **HER STEP 9 BY ITSELF — "Wi-Fi back on, a minute's wait"** (her R-849-2): no press, no write, no app switch — the
    /// network path coming back (a planted path standing in for `NWPathMonitor`) runs ONE round, its occasion retries the
    /// typed unlock's load first, and the round runs with the keys: "Synced". Before the path comes back, a full settle window
    /// passes with the vault still out of reach (any trigger already owed — the settle observation's — runs and fails then),
    /// so the heal is the path's. COMPILE-red on old (the planted path); behavior-red by the record's reverts R-4a (no round
    /// follows the path) and R-3a (no retry in the occasion).
    @Test func herStep9TheNetworkComingBackHealsItByItself() async throws {
        try await FirstRoundWorld.run { world in
            let path = PlantedNetworkPath()
            world.networkPath = { path }
            try await Self.castleAlwaysAskSynced(world)
            let services = try await Self.lockThenUnlockOffline(world)
            #expect(path.isWatched, "the unlock's fresh chain watches the path")
            path.send(false)  // offline, as this Mac sees it
            try await Task.sleep(for: .milliseconds(3500))
            #expect(Drill.row(world, services).kind == .keysLocked, "still offline: Sync locked")
            let rounds = services.sync.status.roundsCompleted

            world.vault.reachable = true  // the network back: the vault answers again
            path.send(true)
            await FirstRoundWorld.settle(seconds: 10) {
                services.sync.status.roundsCompleted > rounds && !services.sync.status.isSyncing
                    && services.sync.status.lastError == nil
            }
            #expect(services.sync.status.roundsCompleted > rounds, "the path coming back ran a round")
            #expect(Drill.row(world, services).kind == .idle,
                    "the row says Synced — \(Drill.row(world, services).kind) \(String(describing: services.sync.status.lastError))")
            #expect(world.keys.sessionSyncKeys(accountID: Account.account) != nil, "the retry loaded the keys")
            #expect(world.keys.items.isEmpty, "nothing written to the keychain")
        }
    }

    /// **THE LOCK LETS GO OF IT** through the bootstrap's own lock: the session the offline unlock opened carries the pending
    /// load; the lock's drop ends it (and the keys stay unloaded).
    @Test func theLockLetsGoOfTheOfflineUnlocksPendingLoad() async throws {
        try await FirstRoundWorld.run { world in
            try await Self.castleAlwaysAskSynced(world)
            _ = try await Self.lockThenUnlockOffline(world)
            let opened = try #require(world.bootstrap.roadSession)
            #expect(opened.pendingSyncKeyLoad?.account == Account.account, "the offline unlock left its load pending")
            await world.bootstrap.lock()
            #expect(opened.pendingSyncKeyLoad == nil, "the lock let go of the derived secret")
            world.vault.reachable = true
            await ProtectionOpenRoad.retryPendingSyncKeyLoad(opened, signIn: Account.signedIn)
            #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "nothing loads past the lock")
            // The world back to open (its services' watch waits for the next ready): the typed unlock online loads them.
            guard case .roadLobby(let lobby) = world.bootstrap.state else {
                Issue.record("locked into the lobby — \(world.bootstrap.state)")
                return
            }
            await lobby.unlock(passphrase: Crossing.passphrase)
            await world.bootstrap.awaitOpen()
            await world.awaitReadyCompose()
            #expect(world.keys.sessionSyncKeys(accountID: Account.account) != nil, "online, the typed unlock loads them")
        }
    }

    /// **A SIGN-OUT LETS GO OF IT** through the bootstrap's attach roads: the services' sign-in observation reaches the
    /// CURRENT road session.
    @Test func aSignOutLetsGoOfTheOfflineUnlocksPendingLoad() async throws {
        try await FirstRoundWorld.run { world in
            try await Self.castleAlwaysAskSynced(world)
            let services = try await Self.lockThenUnlockOffline(world)
            let opened = try #require(world.bootstrap.roadSession)
            #expect(opened.pendingSyncKeyLoad != nil, "precondition: pending")
            await services.signOutVariorum()
            await FirstRoundWorld.settle(seconds: 5) { opened.pendingSyncKeyLoad == nil }
            #expect(opened.pendingSyncKeyLoad == nil, "the sign-out let go of the derived secret")
        }
    }

    /// **A REOPEN THAT REPLACES THE SESSION LETS GO OF IT**: Use Standard (a re-keying crossing, through the one reopening
    /// seam) while the offline unlock's load is still pending — the outgoing session's derived secret does not outlive it.
    @Test func aReopenLetsGoOfTheOutgoingSessionsPendingLoad() async throws {
        try await FirstRoundWorld.run { world in
            try await Self.castleAlwaysAskSynced(world)
            let services = try await Self.lockThenUnlockOffline(world)
            let outgoing = try #require(world.bootstrap.roadSession)
            #expect(outgoing.pendingSyncKeyLoad != nil, "precondition: pending")
            // No round may run the retry before the crossing (it would end the pending by loading the keys): the chain is
            // stopped first — the crossing's teardown stops the services anyway.
            services.sync.stop()
            world.vault.reachable = true  // the crossing reads the account's vault
            let roads = world.bootstrap.crossingRoads()
            let faces = try #require(await roads.read(), "the pane reads the crossings")
            let shown = try #require(faces.useStandard.openDoor, "\(faces.useStandard)")
            let press = await roads.cross(RoadCrossingRequest(
                door: .useStandard, shown: shown, typed: TypedSecrets(passphrase: Crossing.passphrase, words: world.words),
                gate: .alwaysAsk))
            #expect(press == .made(exportTurnedOff: false), "\(press)")
            await world.awaitReadyCompose()
            #expect(world.bootstrap.roadSession !== outgoing, "the reopen replaced the session")
            #expect(outgoing.pendingSyncKeyLoad == nil, "the outgoing session let go of the derived secret")
        }
    }
}
