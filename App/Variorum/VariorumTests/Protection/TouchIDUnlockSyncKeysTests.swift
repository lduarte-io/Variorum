//
//  TouchIDUnlockSyncKeysTests.swift
//  VariorumTests — VX-487 (VX-488 M1): THE TOUCH ID UNLOCK LOADS THE ACCOUNT'S SYNC KEYS FOR THE SESSION, IN THE SAME PRESS.
//  Under Castle with Touch ID the account's sync keys live in a Touch ID item (rule 15's custody), and the engine's provider
//  never reads that item (a press per round is nobody's wish — P-VX307-U1-3: "rounds run while an act or unlock has loaded
//  session memory"). Before VX-487 no unlock loaded session memory, so a Castle + Touch ID library could never sync ("Sync
//  locked", across every relaunch). Over the new road's PLANTED leaves (no keychain, no biometry hardware — the vault and
//  the sync keys are `ProtectionAccountSupport`'s; also runs headless in the implementer's SwiftPM harness).
//    - pin 2: the press of a library bound to an account loads the keys into session memory, and the engine's seam
//      (`NewRoadSyncKeyProvider`) reads them. RED on the pre-fix tree.
//    - pin 3: ONE PRESS, NEVER TWO PROMPTS — the custody read is the one gated read that prompts; the sync-keys read RIDES
//      the press it handed on (`TouchIDPressContext`), no context-less Touch ID read of the sync-keys item happens (each
//      would mint a context and prompt), and the press is ended with the unlock.
//    - pin 4 (a guard — the brief named it "already pinned", but no test named the provider): the provider reads session
//      memory first, then the silent item, and NEVER the Touch ID item.
//    - pin 5: NEVER HOSTAGE — a sync-keys read that throws, an item that is gone, a library bound to no account, a press
//      whose key opens nothing: the unlock goes as it would have (opened / not opened), nothing loaded, the press ended.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-487 (b) — the Touch ID unlock loads the account's sync keys for the session (planted, no keychain)")
@MainActor
struct TouchIDUnlockSyncKeysTests {
    typealias Account = PlantedAccount

    struct World {
        let road: PlantedRoad
        let vault: PlantedVaultLeaf
        let keys: PlantedSyncKeysLeaf
        let session: ProtectionRoadSession
        let words: [String]
    }

    /// A library bound to the planted account, in CASTLE with TOUCH ID on a Mac with a finger enrolled: turned on to sync
    /// (U1's road — the pair handed up), then Use Castle synced with Touch ID chosen (the account's one vault write; the
    /// keys filed the Castle way — the Touch ID item).
    static func castleTouchIDSynced() async throws -> World {
        let (road, vault, keys) = Account.road()
        road.biometry = .ready
        road.session = Account.signedIn
        let (session, words) = try await road.created()
        let turnOn = try #require(ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?
            .turnOnSync.openDoor)
        let turned = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(
                door: .turnOnSync, shown: turnOn, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(turned == .made(receipt: ProtectionWords.turnOnSyncReceipt), "the library syncs")
        let read = try await Account.read(session, Account.signedIn)
        let exports = PlantedExportSwitch()
        let faces = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: exports.road, read: read))
        let shown = try #require(faces.useCastle.openDoor, "\(faces.useCastle)")
        let typed = TypedSecrets(passphrase: Account.passphrase, words: words)
        session.executor.configuration.session = Account.signedIn
        #expect(ProtectionCrossings.preflight(
            session, door: .useCastle, shown: shown, typed: typed, exportSwitch: exports.road, read: read) == .ready)
        let crossed = await ProtectionCrossings.cross(
            session, door: .useCastle, typed: typed, gate: .touchID, exportSwitch: exports.road)
        #expect(crossed.outcome == .made(.useCastle, exportTurnedOff: false))
        #expect(session.library.record?.mode == .castle && session.library.record?.account == Account.account)
        #expect(vault.snapshot(Account.account)?.vault.mode == .castle, "the account entered Castle")
        #expect(!Crossing.items(road, .touchid).isEmpty, "the library's Touch ID item, made at the press")
        return World(road: road, vault: vault, keys: keys, session: session, words: words)
    }

    /// The account's sync keys in the Touch ID item (rule 15's Castle way).
    static func touchIDItem(_ world: World) throws -> AccountKeys {
        try #require(world.keys.items[SyncKeysItemFact(accountID: Account.account, itemClass: .touchid)],
                     "the account's keys filed in the Touch ID item")
    }

    /// What a relaunch or a lock leaves: session memory gone, every item as it was.
    static func relaunched(_ world: World) {
        world.keys.holdInSession(nil, accountID: Account.account)
    }

    /// The lobby a relaunch (or a lock) lands in, and THE PRESS from it — what it did.
    static func attempt(_ road: PlantedRoad) async -> RoadAttempt {
        let lobby = ProtectionOpenRoad.lobbyFacts(road.context())
        #expect(ProtectionLobbyFace.derive(lobby).touchIDButton, "the lobby offers Touch ID")
        return await ProtectionOpenRoad.pressTouchID(road.context(), facts: lobby.facts)
    }

    /// …a press that opens the library.
    static func press(_ road: PlantedRoad) async throws -> ProtectionRoadSession {
        guard case .opened(let opened) = await attempt(road) else {
            Issue.record("the Touch ID press opens the library")
            throw RoadWorld.RoadWorldError.notCreated
        }
        return opened
    }

    static func press(_ world: World) async throws -> ProtectionRoadSession { try await press(world.road) }

    /// PIN 2 — the Touch ID unlock of a library bound to an account loads the account's keys into SESSION MEMORY, and the
    /// engine's seam reads them: the round is no longer refused. RED on the pre-fix tree — no unlock loaded session memory,
    /// so the provider refused `notEnrolled` (the engine's `encryptionKeysUnavailable`, "Sync locked") on every launch.
    @Test func pin2_theTouchIDUnlockLoadsTheAccountsKeysForTheEngine() async throws {
        let world = try await Self.castleTouchIDSynced()
        let item = try Self.touchIDItem(world)
        Self.relaunched(world)
        let opened = try await Self.press(world)
        #expect(opened.library.record?.account == Account.account && opened.library.record?.mode == .castle)
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == item,
                "the press loaded the Touch ID item's keys into session memory")
        let provider = NewRoadSyncKeyProvider()
        provider.attach(opened)
        let current = try? provider.currentKeys()
        #expect(current?.corpusKeyID == item.rowKeyID, "the engine's seam reads them — the round runs")
        #expect(current?.corpusKeyID == world.vault.snapshot(Account.account)?.rowKeyID, "the account's current key")
    }

    /// PIN 4 — THE PROVIDER (a guard, green on both sides by design — the provider is unchanged): session memory first,
    /// then the silent item, NEVER the Touch ID item; nothing attached, nothing read.
    @Test func pin4_theProviderReadsSessionThenSilentAndNeverTheTouchIDItem() async throws {
        let world = try await Self.castleTouchIDSynced()
        _ = try Self.touchIDItem(world)
        Self.relaunched(world)
        let provider = NewRoadSyncKeyProvider()
        provider.attach(world.session)
        #expect(throws: (any Error).self, "only the Touch ID item holds the keys — the provider never presses it") {
            _ = try provider.currentKeys()
        }
        let silent = AccountKeys(
            master: Data(repeating: 1, count: 32), rowKeyID: "silent-row-key", rowKey: Data(repeating: 2, count: 32))
        world.keys.items[SyncKeysItemFact(accountID: Account.account, itemClass: .silent)] = silent
        #expect((try? provider.currentKeys())?.corpusKeyID == "silent-row-key", "the silent item is read")
        let held = AccountKeys(
            master: Data(repeating: 3, count: 32), rowKeyID: "session-row-key", rowKey: Data(repeating: 4, count: 32))
        world.keys.holdInSession(held, accountID: Account.account)
        #expect((try? provider.currentKeys())?.corpusKeyID == "session-row-key", "session memory first")
        provider.attach(nil)
        #expect(throws: (any Error).self, "nothing attached, nothing read") { _ = try provider.currentKeys() }
    }

    /// PIN 3 — ONE PRESS, NEVER TWO PROMPTS. The custody read is the press's ONE gated read (the prompt); the sync-keys
    /// read RIDES the very press it handed on; no context-less Touch ID read of the sync-keys item happens (on the real
    /// leaf each mints its own context — a second prompt); the press is ended with the unlock. A load that pressed again
    /// (a context-less read) would load the keys all the same — pin 2 stays green — and fail HERE.
    @Test func pin3_onePressNeverTwoPrompts_theSyncKeysReadRidesTheCustodyReadsPress() async throws {
        let world = try await Self.castleTouchIDSynced()
        Self.relaunched(world)
        let custodyPresses = world.road.custody.reads.filter { $0 == .touchid }.count
        let freshSyncPresses = world.keys.touchIDReads
        let rides = world.keys.ridingReads.count
        let opened = try await Self.press(world)
        #expect(world.road.custody.reads.filter { $0 == .touchid }.count == custodyPresses + 1,
                "ONE gated custody read — the press")
        let handed = try #require(world.road.custody.handedPresses.last, "the custody read handed its press on")
        #expect(world.keys.ridingReads.count == rides + 1, "the sync-keys item read once, riding a press")
        #expect(world.keys.ridingReads.last === handed, "…THE press the custody read evaluated")
        #expect(world.keys.touchIDReads == freshSyncPresses,
                "no fresh-context Touch ID read of the sync-keys item — no second prompt")
        #expect(handed.isInvalidated, "the press ends with the unlock")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) != nil && opened.library.record?.mode == .castle)
    }

    /// PIN 5 — NEVER HOSTAGE (the brief's limit): the sync-keys load can only ADD session memory; it never changes what
    /// the press does. A read that throws, an item that is gone: the library opens, nothing loaded, the press ended. A
    /// Castle + Touch ID library bound to NO account opens and reads nothing. A press whose key opens nothing is not
    /// opened — and reads nothing.
    @Test func pin5_aFailingOrAbsentSyncKeysReadNeverFailsTheUnlock() async throws {
        // The read throws (a keychain answer the press does not cover — errSecInteractionNotAllowed on the real leaf).
        let failing = try await Self.castleTouchIDSynced()
        Self.relaunched(failing)
        failing.keys.ridingReadFails = true
        let rides = failing.keys.ridingReads.count
        let opened = try await Self.press(failing)
        #expect(opened.library.record?.mode == .castle && opened.key == failing.session.key, "the library opens")
        #expect(failing.keys.ridingReads.count == rides + 1, "the read was tried")
        #expect(failing.keys.sessionSyncKeys(accountID: Account.account) == nil, "nothing loaded")
        #expect(failing.road.custody.handedPresses.last?.isInvalidated == true, "the press ended")

        // The item is gone: the library opens, nothing loaded.
        let absent = try await Self.castleTouchIDSynced()
        Self.relaunched(absent)
        absent.keys.items[SyncKeysItemFact(accountID: Account.account, itemClass: .touchid)] = nil
        let reopened = try await Self.press(absent)
        #expect(reopened.library.record?.account == Account.account)
        #expect(absent.keys.sessionSyncKeys(accountID: Account.account) == nil, "nothing loaded")

        // A library bound to NO account: the press opens it and reads no sync keys at all.
        let local = PlantedRoad()
        let localKeys = PlantedSyncKeysLeaf()
        local.syncKeys = localKeys
        local.biometry = .ready
        let (created, words) = try await local.created()
        let crossed = try await Crossing.press(
            created, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), gate: .touchID)
        #expect(crossed.outcome == .made(.useCastle, exportTurnedOff: false))
        let unbound = try await Self.press(local)
        #expect(unbound.library.record?.mode == .castle && unbound.library.record?.account == nil)
        #expect(localKeys.ridingReads.isEmpty && localKeys.touchIDReads == 0 && localKeys.session.isEmpty,
                "an unbound library reads nothing")
        #expect(local.custody.handedPresses.last?.isInvalidated == true, "the press ended")

        // The item's key opens nothing here: not opened (the item is the final word) — and no sync keys read.
        let stale = try await Self.castleTouchIDSynced()
        Self.relaunched(stale)
        let item = try #require(stale.road.custody.items.keys.first { $0.itemClass == .touchid })
        stale.road.custody.items[item] = StoreKey.mint()
        let staleRides = stale.keys.ridingReads.count
        guard case .touchIDNotOpened(let press, _, let gone) = await Self.attempt(stale.road) else {
            Issue.record("a key that opens nothing does not open the library")
            return
        }
        #expect(press == .failedOnExistingItem && !gone)
        #expect(stale.keys.ridingReads.count == staleRides && stale.keys.sessionSyncKeys(accountID: Account.account) == nil,
                "nothing opened, nothing read")
        #expect(stale.road.custody.handedPresses.last?.isInvalidated == true, "the press ended")
    }
}

/// VX-488 ladder round 1, F1 — the THIRD clear (the orchestrator's adjudication: the plain-text bring-in is one of the
/// finding's adopt/step-aside roads, and it never runs Make this my library). With a library OPEN, bringing in a plain-text
/// copy sets that library aside whole and CREATES a new one on the creation road; the outgoing library's account hold must
/// leave with it — with the process's one sync-keys leaf (F-M1-1) nothing else would ever clear it. Planted (no keychain).
@Suite("VX-488 R1 F1 — the plain-text bring-in drops the outgoing account's session hold (planted)", .serialized)
@MainActor
struct SessionHoldBringInTests {
    typealias Account = PlantedAccount

    /// A bound Castle + Touch ID library, OPEN with its account's keys held in session (the Touch ID unlock's load); a
    /// plain-text copy brought in over it: the new library names no account, and the hold is gone. A landing that could not
    /// land (a read-only road refuses before anything steps aside) keeps it — the library stays.
    @Test func bringingInAPlainTextCopyDropsTheOutgoingAccountsSessionHold() async throws {
        let world = try await TouchIDUnlockSyncKeysTests.castleTouchIDSynced()
        let item = try TouchIDUnlockSyncKeysTests.touchIDItem(world)
        world.keys.holdInSession(item, accountID: Account.account)
        try CopyDoorsPlant.migrate(world.road, key: world.session.key)
        let export = try ExportPlant.export(
            into: world.road.slot.root.appendingPathComponent("Downloads/vx488-export", isDirectory: true))
        guard case .plan(let plan) = ProtectionCopyDoors.readPlaintextExport(export) else {
            Issue.record("the export plans")
            return
        }

        let refused = await ProtectionCopyDoors.landPlaintextExport(
            world.road.context(writes: false), plan: plan, outgoing: world.session)
        #expect(refused.created == nil && refused.refusal != nil, "a read-only road lands nothing")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == item, "nothing landed — the hold stays")

        let landed = await ProtectionCopyDoors.landPlaintextExport(world.road.context(), plan: plan, outgoing: world.session)
        let created = try #require(landed.created, "the copy lands as a new library")
        #expect(created.session.library.record?.account == nil, "the new library names no account")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil,
                "the outgoing library's account hold left with it")
    }
}
