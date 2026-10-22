//
//  RoadLockRouteTests.swift
//  VariorumTests — VX-308 U4 piece 3: VX-445 THROUGH `AppBootstrap` — THE LOCK ON THE NEW ROAD (a new-road bootstrap over
//  the PLANTED road — no keychain, a temp slot, the test bootstrap's own export suite): Lock Now's door reads Castle only;
//  the lock tears down in the crossings' order and lands in the open road's own lobby (never routing — a stale quiet item
//  never re-opens it: no theater), the road session and its faces let go; the lobby's typed road (Always ask) or its one
//  auto-ask (Touch ID) opens the library again; a lock asked while an act runs waits for it; the EXISTING monitors lock a
//  Castle library at sleep/screen lock and after THIS MAC'S SEALED idle minutes, never a Standard one. And NIT-R2-1 through
//  the production switch: the bootstrap's mark is keyed by the open library.
//
//  RED ON OLD (the pre-VX-445 bootstrap, by behavioural revert — the orchestrator's under the stage): `canLock` read false
//  on the new road and `lock()` returned at once (`guard !newRoad else { return }`), and the monitors read today's effective
//  gate (never demanded on the new road) — every lock below stayed `.ready`. Mac only (`AppBootstrap`).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// A new-road bootstrap over a planted road, and a library brought to Castle THROUGH it.
@MainActor
enum LockWorld {
    static let passphrase = "a castle passphrase"

    static func bootstrap(_ road: PlantedRoad) -> AppBootstrap {
        let url = road.slot.places.slot
        return AppBootstrap(
            testStoreURL: url,
            protectionRoad: ProtectionRoadTestHarness(system: road.system(), session: .signedOut, open: { key in
                Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                    .mapError { $0 as? AppDatabase.StoreOpenError
                        ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
            }))
    }

    /// A library created on the planted road (its words kept), opened by a new-road bootstrap — ready, in Standard.
    static func readyInStandard(_ road: PlantedRoad) async throws -> (bootstrap: AppBootstrap, words: [String]) {
        let (_, words) = try await road.created()
        let bootstrap = bootstrap(road)
        await bootstrap.awaitOpen()
        if case .opening = bootstrap.state { await bootstrap.awaitOpen() }
        guard case .ready = bootstrap.state, bootstrap.roadSession != nil else {
            throw LockWorldError.notReady("\(bootstrap.state)")
        }
        return (bootstrap, words)
    }

    /// …then crossed into Castle THROUGH the bootstrap (its crossings — the pool closed, the reopen), `gate` chosen.
    static func readyInCastle(
        _ road: PlantedRoad, gate: GateStyle = .alwaysAsk
    ) async throws -> (bootstrap: AppBootstrap, words: [String]) {
        let (bootstrap, words) = try await readyInStandard(road)
        let crossings = try #require(bootstrap.roadCrossings)
        await crossings.refresh()
        crossings.open(.useCastle)
        let confirm = try #require(crossings.confirm)
        confirm.gate = gate
        await confirm.submit(passphrase: passphrase, again: passphrase, words: words.joined(separator: " "))
        #expect(crossings.confirm == nil, "the crossing landed: \(confirm.refusal ?? "-")")
        guard case .ready = bootstrap.state, bootstrap.roadSession?.library.record?.mode == .castle else {
            throw LockWorldError.notReady("in Castle: \(bootstrap.state)")
        }
        return (bootstrap, words)
    }

    /// The lobby the bootstrap stands in now.
    static func lobby(_ bootstrap: AppBootstrap) throws -> ProtectionLobbyModel {
        guard case .roadLobby(let lobby) = bootstrap.state else { throw LockWorldError.notLocked("\(bootstrap.state)") }
        return lobby
    }

    /// The typed road: the passphrase, then the reopen awaited.
    static func unlock(_ bootstrap: AppBootstrap) async throws {
        try await lobby(bootstrap).unlock(passphrase: passphrase)
        await bootstrap.awaitOpen()
        guard case .ready = bootstrap.state else { throw LockWorldError.notReady("after the unlock: \(bootstrap.state)") }
    }

    enum LockWorldError: Error {
        case notReady(String)
        case notLocked(String)
    }
}

@Suite("VX-308 U4 — VX-445: the lock on the new road, through AppBootstrap (planted, no keychain)", .serialized)
@MainActor
struct RoadLockRouteTests {
    /// LOCK NOW: no door and no lock in Standard; in Castle the door, and the lock — the composition root's teardown once,
    /// the road session and its faces let go, THE LOBBY (a stale silent item a crash left behind never re-opens it: the lock
    /// does not route), the typed road asked; a wrong passphrase refused in place; the right one opens the library again —
    /// a fresh session, Castle, the same key — and the door is back. NIT-R2-1 through the production switch: the bootstrap's
    /// rule-11 mark is the OPEN library's (its id in the key), never the legacy one.
    @Test func lockNowClosesACastleLibraryBehindTheLobbyAndItsSecretOpensItAgain() async throws {
        try await withRoadDependencies {
            UserDefaults().removePersistentDomain(forName: AppBootstrap.crossingTestExportSuiteName)
            defer { UserDefaults().removePersistentDomain(forName: AppBootstrap.crossingTestExportSuiteName) }
            let road = PlantedRoad()
            let (bootstrap, words) = try await LockWorld.readyInStandard(road)
            let standing = try #require(bootstrap.roadSession)
            #expect(!bootstrap.canLock, "Standard never locks — no door (P-2)")
            await bootstrap.lock()
            #expect(bootstrap.roadSession === standing, "Standard: the lock is never theater — nothing closed")

            // Into Castle through the bootstrap, the weekly copy on (rule 11's mark — NIT-R2-1, the production switch).
            ProtectionCrossingRouteTests.exports.set(true)
            let crossings = try #require(bootstrap.roadCrossings)
            await crossings.refresh()
            crossings.open(.useCastle)
            let confirm = try #require(crossings.confirm)
            confirm.gate = .alwaysAsk
            await confirm.submit(
                passphrase: LockWorld.passphrase, again: LockWorld.passphrase, words: words.joined(separator: " "))
            guard case .ready = bootstrap.state, let castle = bootstrap.roadSession, castle.library.record?.mode == .castle
            else {
                Issue.record("the crossing reopened in Castle: \(bootstrap.state) \(confirm.refusal ?? "-")")
                return
            }
            let libraryID = try #require(castle.library.record?.libraryID)
            let suite = try #require(UserDefaults(suiteName: AppBootstrap.crossingTestExportSuiteName))
            #expect(suite.bool(forKey: ExportNoticeMark.key(libraryID)), "rule 11's mark — the open library's")
            #expect(suite.object(forKey: ExportNoticeMark.legacyKey) == nil, "never the one-per-domain mark")
            #expect(bootstrap.canLock, "Castle: Lock Now's door")

            // A stale silent item (a crash corner's leftover) — the lock must not open through it.
            try road.custody.writeCustody(castle.key, itemClass: .silent, libraryID: libraryID)
            var teardowns = 0
            bootstrap.onWillLock = { teardowns += 1 }
            await bootstrap.lock()
            let lobby = try LockWorld.lobby(bootstrap)
            #expect(teardowns == 1, "the composition root's teardown, once")
            #expect(bootstrap.roadSession == nil && bootstrap.roadStanding == nil, "nothing keeps the key")
            #expect(!bootstrap.canLock)
            #expect(lobby.face.passphraseField && !lobby.face.touchIDButton, "Always ask types")
            await lobby.unlock(passphrase: "not it")
            #expect(lobby.message == ProtectionWords.passphraseDoesNotOpen)
            #expect(try LockWorld.lobby(bootstrap) === lobby, "a wrong passphrase leaves the lobby standing")
            try await LockWorld.unlock(bootstrap)
            let reopened = try #require(bootstrap.roadSession)
            #expect(reopened !== castle && reopened.key == castle.key && reopened.library.record?.mode == .castle)
            #expect(bootstrap.canLock, "the door is back")
        }
    }

    /// TOUCH ID: the relock lobby offers the button and its one auto-ask (the lobby's existing behaviour); the press opens
    /// the library again.
    @Test func underTouchIDTheRelockLobbyAutoAsksAndThePressOpens() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            road.biometry = .ready
            let (bootstrap, _) = try await LockWorld.readyInCastle(road, gate: .touchID)
            let castle = try #require(bootstrap.roadSession)
            #expect(bootstrap.canLock)
            await bootstrap.lock()
            let lobby = try LockWorld.lobby(bootstrap)
            #expect(lobby.face.touchIDButton && lobby.face.autoAsk)
            await lobby.autoAskIfDue(appIsActive: true)
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, let reopened = bootstrap.roadSession else {
                Issue.record("the auto-ask's press opens it: \(bootstrap.state)")
                return
            }
            #expect(reopened.key == castle.key && reopened !== castle)
        }
    }

    /// ONE ACT AT A TIME: a lock asked while an act holds the session waits — the library stays open under the act — and
    /// locks once the act ends.
    @Test func aLockAskedWhileAnActRunsWaitsForTheActThenLocks() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (bootstrap, _) = try await LockWorld.readyInCastle(road)
            let session = try #require(bootstrap.roadSession)
            #expect(session.beginAct(), "an act holds the session")
            let locking = Task { await bootstrap.lock() }
            try await Task.sleep(for: .milliseconds(400))
            guard case .ready = bootstrap.state else {
                Issue.record("the lock waits for the act: \(bootstrap.state)")
                session.endAct()
                return
            }
            #expect(bootstrap.roadSession === session)
            session.endAct()
            await locking.value
            _ = try LockWorld.lobby(bootstrap)
        }
    }

    /// THE EXISTING MONITORS on the new road (R-U4-3): the idle tick locks a Castle library after THIS MAC'S SEALED idle
    /// minutes (10 by default; 30 once the setting says so; never when it says never), sleep and screen lock lock it at
    /// once; a Standard library is never locked by either.
    @Test func theMonitorsLockACastleLibraryOnItsSealedIdleMinutesAndAtSleep() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (bootstrap, _) = try await LockWorld.readyInCastle(road)
            let protection = bootstrap.protection
            let now = Date()
            protection.noteActivity(now: now.addingTimeInterval(-9 * 60))
            await protection.relockIfIdle(now: now)
            #expect(bootstrap.roadSession != nil, "9 minutes away: the default 10 has not passed")
            protection.noteActivity(now: now.addingTimeInterval(-11 * 60))
            await protection.relockIfIdle(now: now)
            _ = try LockWorld.lobby(bootstrap)

            try await LockWorld.unlock(bootstrap)
            try await RoadLockTests.setIdle(try #require(bootstrap.roadSession), 30)
            protection.noteActivity(now: now.addingTimeInterval(-11 * 60))
            await protection.relockIfIdle(now: now)
            #expect(bootstrap.roadSession != nil, "the sealed setting says 30")
            protection.noteActivity(now: now.addingTimeInterval(-31 * 60))
            await protection.relockIfIdle(now: now)
            _ = try LockWorld.lobby(bootstrap)

            try await LockWorld.unlock(bootstrap)
            try await RoadLockTests.setIdle(try #require(bootstrap.roadSession), nil)
            protection.noteActivity(now: now.addingTimeInterval(-24 * 60 * 60))
            await protection.relockIfIdle(now: now)
            #expect(bootstrap.roadSession != nil, "never")
            await protection.relockIfPolicySays()
            _ = try LockWorld.lobby(bootstrap)

            // Standard: neither the tick nor sleep locks it.
            let standardRoad = PlantedRoad()
            let (standard, _) = try await LockWorld.readyInStandard(standardRoad)
            let open = try #require(standard.roadSession)
            standard.protection.noteActivity(now: now.addingTimeInterval(-24 * 60 * 60))
            await standard.protection.relockIfIdle(now: now)
            await standard.protection.relockIfPolicySays()
            #expect(standard.roadSession === open)
        }
    }
}
