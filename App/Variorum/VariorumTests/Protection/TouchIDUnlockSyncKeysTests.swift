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
//    - pin 4 (a guard — the brief named it "already pinned", but no test named the provider): the provider reads session
//      memory first, then the silent item, and NEVER the Touch ID item.
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

    /// The lobby a relaunch (or a lock) lands in, and THE PRESS from it.
    static func press(_ world: World) async throws -> ProtectionRoadSession {
        let lobby = ProtectionOpenRoad.lobbyFacts(world.road.context())
        #expect(ProtectionLobbyFace.derive(lobby).touchIDButton, "the lobby offers Touch ID")
        guard case .opened(let opened) = await ProtectionOpenRoad.pressTouchID(world.road.context(), facts: lobby.facts)
        else {
            Issue.record("the Touch ID press opens the library")
            throw RoadWorld.RoadWorldError.notCreated
        }
        return opened
    }

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
}
