//
//  RoadLockTests.swift
//  VariorumTests — VX-308 U4 piece 3: VX-445's parts that are not the bootstrap's seam (`ProtectionRoadLock.swift`) over the
//  new road's PLANTED leaves (no keychain; also runs headless in the implementer's SwiftPM harness): the relock POLICY —
//  Castle locks, Standard never, the idle minutes this Mac's SEALED setting; THE LOBBY a lock lands in — the open road's
//  own, the quiet roads not tried, Always ask typing and Touch ID's one auto-ask; and what the lock lets go of on the session
//  (the account's sync keys in session memory). The bootstrap's seam itself (the teardown, the lobby landing, Lock Now's
//  door, the monitors, the wait for an act) is `RoadLockRouteTests`' (the Mac target).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U4 — VX-445: the new road's relock policy, its lobby and its session drop (planted, no keychain)")
@MainActor
struct RoadLockTests {
    /// This Mac's sealed settings changed on the open library (`changeSettings` — the executor's one road).
    static func setIdle(_ session: ProtectionRoadSession, _ minutes: Int?) async throws {
        var library = session.library
        var settings = library.section.settings
        settings.idleLockMinutes = minutes
        _ = try await session.executor.changeSettings(&library, to: settings)
        session.library = library
    }

    /// THE POLICY (R-U4-1, R-U4-3): a Standard library never locks; in Castle it locks, after this Mac's SEALED idle
    /// minutes — 10 by default (decision 18's, kept), whatever the setting says after, nil = never.
    @Test func theRelockPolicyIsCastlesAndReadsThisMacsSealedIdleMinutes() async throws {
        let road = PlantedRoad()
        let (standard, _) = try await road.created()
        #expect(RoadRelockPolicy.of(standard.library) == nil, "Standard never locks — its quiet roads would open it at once")

        let castleRoad = PlantedRoad()
        let (session, _) = try await Crossing.inCastle(castleRoad)
        #expect(session.library.record?.mode == .castle)
        #expect(RoadRelockPolicy.of(session.library) == RoadRelockPolicy(idleMinutes: DeviceSettings.defaultIdleLockMinutes))
        #expect(DeviceSettings.defaultIdleLockMinutes == 10)
        try await Self.setIdle(session, 30)
        #expect(RoadRelockPolicy.of(session.library) == RoadRelockPolicy(idleMinutes: 30), "the sealed setting, honored")
        try await Self.setIdle(session, nil)
        #expect(RoadRelockPolicy.of(session.library) == RoadRelockPolicy(idleMinutes: nil), "never — but still locks at sleep")
    }

    /// THE LOBBY A LOCK LANDS IN (R-U4-2), ALWAYS ASK: the open road's own — the passphrase field and the words, no Touch ID
    /// button, nothing asked by itself — and the quiet roads are NOT taken: even with a stale silent item a crash left
    /// behind (which the ROUTE would open through at once — the theater a lock must never be), the lock's lobby is facts
    /// and roads only (its gatherer may read the item to assess it; nothing opens); the passphrase opens the library again
    /// under the same key.
    @Test func underAlwaysAskTheLobbyTypesAndNoQuietRoadIsTaken() async throws {
        let road = PlantedRoad()
        let (session, _) = try await Crossing.inCastle(road)
        let libraryID = try #require(session.library.record?.libraryID)
        try road.custody.writeCustody(session.key, itemClass: .silent, libraryID: libraryID)  // a crash corner's leftover
        let lobby = ProtectionRoadLock.lobby(road.context())
        let face = ProtectionLobbyFace.derive(lobby)
        #expect(face.passphraseField && !face.touchIDButton && !face.autoAsk, "\(face)")
        #expect(lobby.offeredTyped.contains(.passphrase))
        guard case .opened = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the contrast: the ROUTE tries the quiet roads and opens through the stale item")
            return
        }
        guard case .opened(let reopened) = await ProtectionOpenRoad.openTyped(
            road.context(), secret: .passphrase(Crossing.passphrase)) else {
            Issue.record("the passphrase opens the locked library")
            return
        }
        #expect(reopened.key == session.key && reopened.library.record?.mode == .castle)
    }

    /// TOUCH ID: the lobby offers the button and its ONE auto-ask (the lobby's existing behaviour, untouched) — the press
    /// opens the library again.
    @Test func underTouchIDTheLobbyAutoAsksAndThePressOpens() async throws {
        let road = PlantedRoad()
        road.biometry = .ready
        let (created, words) = try await road.created()
        let crossed = try await Crossing.press(
            created, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), gate: .touchID)
        #expect(crossed.outcome == .made(.useCastle, exportTurnedOff: false))
        #expect(!Crossing.items(road, .touchid).isEmpty, "the item made at the press")
        let ctx = road.context()
        let lobby = ProtectionRoadLock.lobby(ctx)
        let face = ProtectionLobbyFace.derive(lobby)
        #expect(face.touchIDButton && face.autoAsk)
        var opened: ProtectionRoadSession?
        let model = ProtectionLobbyModel(
            standing: lobby,
            typedRoad: { await ProtectionOpenRoad.openTyped(ctx, secret: $0) },
            touchIDRoad: { await ProtectionOpenRoad.pressTouchID(ctx, facts: $0) },
            refreshRoad: { ProtectionOpenRoad.lobbyFacts(ctx) },
            opened: { opened = $0 },
            recordMissing: {})
        await model.autoAskIfDue(appIsActive: true)
        #expect(model.pressesRun == 1, "the one automatic ask")
        #expect(opened?.key == crossed.reopenKey && opened?.library.record?.mode == .castle)
    }

    /// WHAT THE LOCK LETS GO OF: the account's sync keys held in SESSION memory (the leaf's contract — "gone at a relock");
    /// the silent item (a Standard account's custody) is not the lock's to touch.
    @Test func theLockDropsTheAccountsSyncKeysFromSessionMemory() async throws {
        let world = try await RoadRestoreHoldGateTests.synced()
        let account = PlantedAccount.account
        let keys = try #require(world.road.syncKeys as? PlantedSyncKeysLeaf)
        let held = try #require(keys.items.values.first, "turning sync on held the account's keys")
        keys.holdInSession(held, accountID: account)
        #expect(keys.sessionSyncKeys(accountID: account) != nil)
        ProtectionRoadLock.dropSessionMemory(world.session)
        #expect(keys.sessionSyncKeys(accountID: account) == nil, "gone at the relock")
        #expect(keys.items.values.contains(held), "the item stays — custody is not the lock's")

        // A library bound to no account holds none — nothing to drop, nothing touched.
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        ProtectionRoadLock.dropSessionMemory(session)
    }
}
