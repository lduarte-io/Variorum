//
//  TypedUnlockSyncKeysTests.swift
//  VariorumTests — VX-510 unit B2, D-B4: VX-501 (her R-494-4, "I think a typed unlock should hold sync keys in session
//  until lock, I don't see why"; R-510-11 joined it to this run). THE TYPED CASTLE UNLOCK LOADS THE ACCOUNT'S SYNC KEYS FOR
//  THE SESSION — the typed twin of VX-487 (b)'s Touch ID load. Under Castle the engine's provider reads session memory and
//  the silent item only (P-VX307-U1-3); Castle has no silent item (rule 9), and under Always ask no item at all, so before
//  VX-501 a library unlocked by its passphrase or its twelve words never synced until a key act or a Touch ID moment ("how
//  is a user that isn't using touchid even supposed to get sync to get going again at ALL?" — her words). Over the new
//  road's PLANTED leaves (no keychain, no network — `ProtectionAccountSupport`'s vault and sync keys; also runs headless in
//  the implementer's SwiftPM harness).
//    - the typed passphrase under Always ask loads the keys and the engine's seam reads them (RED on the pre-fix tree);
//    - the twelve words the same (RED);
//    - under Touch ID a typed unlock loads them too — from the vault, with no press and no Touch ID read (RED);
//    - NEVER HOSTAGE — offline the unlock opens all the same, nothing loaded (its "the read was tried" leg RED on old);
//      a secret that opens the library but not the vault, and an account that moved since this library followed, load
//      nothing (their "tried" legs RED on old);
//    - guards (green on both sides by design — the reverts show their teeth): Standard loads nothing and reads no vault
//      (its silent item serves); an unbound library reads nothing; signed out reads nothing.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-501 (D-B4) — the typed Castle unlock loads the account's sync keys for the session (planted, no keychain)")
@MainActor
struct TypedUnlockSyncKeysTests {
    typealias Account = PlantedAccount
    typealias World = TouchIDUnlockSyncKeysTests.World

    /// A library bound to the planted account, in CASTLE under ALWAYS ASK (no item at all — the keys only ever in session
    /// memory): turned on to sync (the pair handed up), then Use Castle synced with Always ask (the account's one vault
    /// write).
    static func castleAlwaysAskSynced() async throws -> World {
        let (road, vault, keys) = Account.road()
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
            session, door: .useCastle, typed: typed, gate: .alwaysAsk, exportSwitch: exports.road)
        #expect(crossed.outcome == .made(.useCastle, exportTurnedOff: false))
        #expect(session.library.record?.mode == .castle && session.library.record?.account == Account.account)
        #expect(vault.snapshot(Account.account)?.vault.mode == .castle, "the account entered Castle")
        #expect(keys.items.isEmpty, "Always ask: no sync-keys item on this Mac at all")
        return World(road: road, vault: vault, keys: keys, session: session, words: words)
    }

    /// The account's current keys, as the vault holds them (the test opens them with the passphrase it knows).
    static func accountsKeys(_ world: World) throws -> AccountKeys {
        let snapshot = try #require(world.vault.snapshot(Account.account))
        let typed = try PassphraseKey.derive(Account.passphrase, kdf: snapshot.vault.kdf)
        let master = try #require(snapshot.vault.master(passphrase: typed, words: nil))
        return try snapshot.vault.keys(master: master)
    }

    /// The lobby's typed press (a relaunch or a lock lands there) — a press that opens the library.
    static func typedUnlock(_ world: World, _ secret: ProtectionSecret) async throws -> ProtectionRoadSession {
        guard case .opened(let opened) = await ProtectionOpenRoad.openTyped(world.road.context(), secret: secret) else {
            Issue.record("the typed secret opens the library")
            throw RoadWorld.RoadWorldError.notCreated
        }
        return opened
    }

    static func fetches(_ world: World) -> Int {
        world.vault.calls.filter { $0 == "fetch \(Account.account)" }.count
    }

    /// The engine's seam over the opened session: what a round would read.
    static func engineKeyID(_ opened: ProtectionRoadSession) -> String? {
        let provider = NewRoadSyncKeyProvider()
        provider.attach(opened)
        return (try? provider.currentKeys())?.corpusKeyID
    }

    // MARK: - The load (RED on the pre-fix tree)

    /// THE TYPED PASSPHRASE UNDER ALWAYS ASK loads the account's keys into session memory, with ONE vault read, and the
    /// engine's seam reads them — the round runs. RED on the pre-fix tree: no typed unlock loaded anything, so the provider
    /// refused `notEnrolled` ("Sync locked") until a key act.
    @Test func vx501_aTypedPassphraseUnlockUnderAlwaysAskLoadsTheAccountsKeys() async throws {
        let world = try await Self.castleAlwaysAskSynced()
        let keys = try Self.accountsKeys(world)
        TouchIDUnlockSyncKeysTests.relaunched(world)
        #expect(Self.engineKeyID(world.session) == nil, "precondition: after the relaunch nothing is loaded")
        let before = Self.fetches(world)
        let opened = try await Self.typedUnlock(world, .passphrase(Account.passphrase))
        #expect(opened.library.record?.account == Account.account && opened.library.record?.mode == .castle)
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == keys,
                "the typed unlock loaded the account's keys into session memory")
        #expect(Self.engineKeyID(opened) == keys.rowKeyID, "the engine's seam reads them — the round runs")
        #expect(Self.fetches(world) == before + 1, "ONE vault read")
        #expect(world.keys.items.isEmpty, "nothing written to the keychain — session memory only")
    }

    /// THE TWELVE WORDS TYPED load them the same.
    @Test func vx501_theTwelveWordsTypedLoadThemToo() async throws {
        let world = try await Self.castleAlwaysAskSynced()
        let keys = try Self.accountsKeys(world)
        TouchIDUnlockSyncKeysTests.relaunched(world)
        let opened = try await Self.typedUnlock(world, .words(world.words))
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == keys, "the words loaded the keys")
        #expect(Self.engineKeyID(opened) == keys.rowKeyID)
    }

    /// UNDER TOUCH ID a typed unlock (the press cancelled, the passphrase typed) loads them too — from the vault, with NO
    /// press: no Touch ID read of the custody item or of the sync-keys item (each would prompt), no press ridden.
    @Test func vx501_aTypedUnlockUnderTouchIDLoadsThemWithNoPress() async throws {
        let world = try await TouchIDUnlockSyncKeysTests.castleTouchIDSynced()
        let item = try TouchIDUnlockSyncKeysTests.touchIDItem(world)
        TouchIDUnlockSyncKeysTests.relaunched(world)
        let custodyPresses = world.road.custody.reads.filter { $0 == .touchid }.count
        let syncPresses = world.keys.touchIDReads
        let rides = world.keys.ridingReads.count
        let opened = try await Self.typedUnlock(world, .passphrase(Account.passphrase))
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == item, "the account's keys, loaded")
        #expect(Self.engineKeyID(opened) == item.rowKeyID)
        #expect(world.road.custody.reads.filter { $0 == .touchid }.count == custodyPresses, "no Touch ID custody read")
        #expect(world.keys.touchIDReads == syncPresses && world.keys.ridingReads.count == rides,
                "no Touch ID read of the sync-keys item — no prompt")
    }

    // MARK: - Never hostage

    /// OFFLINE: the typed unlock opens the library all the same; the read was tried; nothing loaded (the row says locked as
    /// today). Its "tried" leg is RED on the pre-fix tree (nothing read there) — the never-hostage legs pass on both.
    @Test func offlineTheTypedUnlockStillOpensAndLoadsNothing() async throws {
        let world = try await Self.castleAlwaysAskSynced()
        TouchIDUnlockSyncKeysTests.relaunched(world)
        world.vault.reachable = false
        let before = Self.fetches(world)
        let opened = try await Self.typedUnlock(world, .passphrase(Account.passphrase))
        #expect(opened.library.record?.mode == .castle && opened.key == world.session.key, "the library opens")
        #expect(Self.fetches(world) == before + 1, "the read was tried")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "nothing loaded")
        #expect(Self.engineKeyID(opened) == nil)
    }

    /// A SECRET THAT OPENS THE LIBRARY BUT NOT THE VAULT (the account's passphrase changed on another device; this
    /// library's lock still the old one): the library opens, the read was tried, nothing loaded — and no second derivation
    /// under the vault's new descriptor is ever made to reach it.
    @Test func aSecretThatOpensTheLibraryButNotTheVaultLoadsNothing() async throws {
        let world = try await Self.castleAlwaysAskSynced()
        TouchIDUnlockSyncKeysTests.relaunched(world)
        let snapshot = try #require(world.vault.snapshot(Account.account))
        let master = try #require(snapshot.vault.master(
            passphrase: try PassphraseKey.derive(Account.passphrase, kdf: snapshot.vault.kdf), words: nil))
        let elsewhere = try PassphraseKey.derive("changed on another mac", kdf: FastIDsLeaf().mintPassphraseKDF())
        world.vault.accounts[Account.account]?.vault = try VaultModel.rewrappingPassphrase(
            snapshot.vault, master: master, passphrase: elsewhere, device: "Another Mac")
        let before = Self.fetches(world)
        let opened = try await Self.typedUnlock(world, .passphrase(Account.passphrase))
        #expect(opened.library.record?.mode == .castle, "the old passphrase still opens the library")
        #expect(Self.fetches(world) == before + 1, "the read was tried")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "nothing loaded")
    }

    /// AN ACCOUNT THAT MOVED since this library followed (its sync key replaced elsewhere): the keys the typed secret reaches
    /// are not the ones this library follows — nothing loaded (the follow is owed, and loads them).
    @Test func anAccountThatMovedLoadsNothing() async throws {
        let world = try await Self.castleAlwaysAskSynced()
        TouchIDUnlockSyncKeysTests.relaunched(world)
        let snapshot = try #require(world.vault.snapshot(Account.account))
        let master = try #require(snapshot.vault.master(
            passphrase: try PassphraseKey.derive(Account.passphrase, kdf: snapshot.vault.kdf), words: nil))
        var moved = snapshot.vault
        moved.earlierRowKeys[moved.rowKey.keyID] = moved.rowKey.wrappedByMaster
        moved.rowKey = VaultKey(
            keyID: "moved-row-key", wrappedByMaster: try AES.KeyWrap.wrap(SymmetricKey(size: .bits256), using: master))
        world.vault.accounts[Account.account]?.vault = moved
        #expect(world.session.library.record?.accountRowKeyID != "moved-row-key", "precondition: the library is behind")
        let before = Self.fetches(world)
        let opened = try await Self.typedUnlock(world, .passphrase(Account.passphrase))
        #expect(opened.library.record?.mode == .castle)
        #expect(Self.fetches(world) == before + 1, "the read was tried")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "nothing loaded — the follow loads them")
    }

    // MARK: - Guards (green on both sides by design)

    /// STANDARD loads nothing and reads no vault — its silent item serves the engine (the design's own pin).
    @Test func aStandardLibraryLoadsNothingAndReadsNoVault() async throws {
        let (road, vault, keys) = Account.road()
        road.session = Account.signedIn
        let (session, words) = try await road.created()
        let turnOn = try #require(ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?
            .turnOnSync.openDoor)
        let turned = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(
                door: .turnOnSync, shown: turnOn, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(turned == .made(receipt: ProtectionWords.turnOnSyncReceipt))
        #expect(session.library.record?.mode == .standard && session.library.record?.account == Account.account)
        keys.holdInSession(nil, accountID: Account.account)
        let fetches = vault.calls.count
        let world = World(road: road, vault: vault, keys: keys, session: session, words: words)
        let opened = try await Self.typedUnlock(world, .passphrase(Account.passphrase))
        #expect(opened.library.record?.mode == .standard)
        #expect(vault.calls.count == fetches, "Standard reads no vault at a typed unlock")
        #expect(keys.sessionSyncKeys(accountID: Account.account) == nil, "nothing loaded — the silent item serves")
        #expect(Self.engineKeyID(opened) != nil, "the engine reads the silent item")
    }

    /// AN UNBOUND Castle library reads nothing — no vault, no keys.
    @Test func anUnboundCastleLibraryReadsNothing() async throws {
        let (road, vault, keys) = Account.road()
        road.session = Account.signedIn
        let (created, words) = try await road.created()
        let crossed = try await Crossing.press(
            created, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), gate: .alwaysAsk)
        #expect(crossed.outcome == .made(.useCastle, exportTurnedOff: false))
        let fetches = vault.calls.count
        let world = World(road: road, vault: vault, keys: keys, session: created, words: words)
        let opened = try await Self.typedUnlock(world, .passphrase(Crossing.passphrase))
        #expect(opened.library.record?.mode == .castle && opened.library.record?.account == nil)
        #expect(vault.calls.count == fetches && keys.session.isEmpty, "an unbound library reads nothing")
    }

    /// SIGNED OUT (or into another account): the vault is the account's, so nothing is read and nothing loaded; the library
    /// opens.
    @Test func signedOutReadsNothing() async throws {
        let world = try await Self.castleAlwaysAskSynced()
        TouchIDUnlockSyncKeysTests.relaunched(world)
        for signIn in [SessionFact.signedOut, .signedIn(accountID: Account.other, email: "someone@example.test")] {
            world.road.session = signIn
            let before = world.vault.calls.count
            let opened = try await Self.typedUnlock(world, .passphrase(Account.passphrase))
            #expect(opened.library.record?.account == Account.account)
            #expect(world.vault.calls.count == before, "\(signIn): nothing read")
            #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "\(signIn): nothing loaded")
        }
    }
}
