//
//  TypedSecretNeverPressesTests.swift
//  VariorumTests — VX-510 unit B2, D-B5: VX-503 (the run record's T-B5-1…4). A Standard library JOINING a Standard account
//  raised the system Touch ID prompt ("…is trying to Unlock your Variorum library") and waited; cancelled, the join
//  completed. THE TRACED READ: the join's first step (`pickUpJoinKeys` → `material(for:)` → `syncMaterial()`) read the
//  account's TOUCH ID sync-keys item before anything else — a prompt whenever such an item stands for the account in this
//  Mac's scope (a stale one, left by an earlier Castle + Touch ID library: the production listing never deletes a Touch ID-only
//  item — recorded as a finding) — although the act already held the typed secret that opens the vault. The prompt bought
//  nothing: the derivation from the vault gives the very same keys. Now an act whose TYPED secret opens the vault derives the
//  keys from it and reads no custody at all. Over the planted leaves (their `touchIDReads` counts every context-less Touch ID
//  read — on the real leaf each one mints its own `LAContext`, a prompt); also headless in the implementer's harness.
//    - a Standard join with a stale Touch ID item standing reads no Touch ID item (RED on the pre-fix tree);
//    - Use Standard on a synced Castle + Touch ID library — both secrets typed — reads no Touch ID sync-keys item (RED);
//    - guards: the join still holds the vault's own keys, filed silently (Standard's custody); a quiet follow with nothing
//      typed still reads custody (the fallback stands).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-503 (D-B5) — an act holding the typed secret never presses Touch ID for the sync keys (planted, no keychain)")
@MainActor
struct TypedSecretNeverPressesTests {
    typealias Account = PlantedAccount

    static let accountWords = FirstRunDrillTests.accountWords

    /// A Touch ID sync-keys item a LEFT Castle library leaves standing for the account (keys of no use to anyone now).
    static let staleItem = AccountKeys(
        master: Data(repeating: 7, count: 32), rowKeyID: "stale-row-key", rowKey: Data(repeating: 8, count: 32))

    /// THE OBSERVATION'S ROAD: a fresh Standard library joins an account that syncs in Standard (its passphrase typed) while
    /// a stale Touch ID sync-keys item for that account stands on this Mac. RED on the pre-fix tree: the join's first step
    /// read the Touch ID item (the prompt) before deriving from the typed secret.
    @Test func vx503_aStandardJoinWithAStaleTouchIDItemNeverPresses() async throws {
        let (road, vault, keys) = Account.road()
        road.session = Account.signedIn
        let (session, _) = try await road.created()
        let accountKeys = try vault.plant(
            accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .standard)
        keys.items[SyncKeysItemFact(accountID: Account.account, itemClass: .touchid)] = Self.staleItem
        let join = try #require(ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?
            .turnOnSync.openDoor)
        #expect(join.spec.join == .sameMode, "precondition: the join arm, same posture")
        let presses = keys.touchIDReads
        let made = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(
                door: .turnOnSync, shown: join, typed: TypedSecrets(passphrase: Account.passphrase)),
            signIn: Account.signedIn, exportSwitch: nil)
        guard case .made = made else {
            Issue.record("the join lands: \(made)")
            return
        }
        #expect(keys.touchIDReads == presses, "no Touch ID read of the sync keys — no prompt (the typed secret opens the vault)")
        #expect(session.library.record?.account == Account.account && session.library.record?.mode == .standard)
        #expect(keys.items[SyncKeysItemFact(accountID: Account.account, itemClass: .silent)] == accountKeys,
                "the vault's own keys, filed silently (Standard's custody)")
    }

    /// USE STANDARD on a synced Castle + Touch ID library — her passphrase and words typed: the act derives the account's
    /// keys from the vault and reads no Touch ID sync-keys item (RED on the pre-fix tree: `leaveCastleWrite` read it first).
    @Test func vx503_useStandardWithBothSecretsTypedNeverPressesForTheSyncKeys() async throws {
        let world = try await TouchIDUnlockSyncKeysTests.castleTouchIDSynced()
        TouchIDUnlockSyncKeysTests.relaunched(world)
        let read = try await Account.read(world.session, Account.signedIn)
        let exports = PlantedExportSwitch()
        let faces = try #require(ProtectionCrossings.readCrossings(world.session, exportSwitch: exports.road, read: read))
        let shown = try #require(faces.useStandard.openDoor, "\(faces.useStandard)")
        let typed = TypedSecrets(passphrase: Account.passphrase, words: world.words)
        world.session.executor.configuration.session = Account.signedIn
        #expect(ProtectionCrossings.preflight(
            world.session, door: .useStandard, shown: shown, typed: typed, exportSwitch: exports.road, read: read) == .ready)
        let presses = world.keys.touchIDReads
        let crossed = await ProtectionCrossings.cross(
            world.session, door: .useStandard, typed: typed, gate: .alwaysAsk, exportSwitch: exports.road)
        #expect(crossed.outcome == .made(.useStandard, exportTurnedOff: false), "\(crossed.outcome)")
        #expect(world.keys.touchIDReads == presses, "no Touch ID read of the sync keys during Use Standard — no prompt")
        #expect(world.vault.snapshot(Account.account)?.vault.mode == .standard, "the account left Castle")
    }

    /// GUARD (green on both sides): with NOTHING typed that opens the vault, custody still serves — the key doors' road (their
    /// secrets are the NEW ones): Change passphrase on the synced Castle + Touch ID library holding its keys in session lands.
    @Test func theCustodyFallbackStandsWhenNoTypedSecretOpensTheVault() async throws {
        let world = try await TouchIDUnlockSyncKeysTests.castleTouchIDSynced()
        let item = try TouchIDUnlockSyncKeysTests.touchIDItem(world)
        world.keys.holdInSession(item, accountID: Account.account)
        world.session.executor.configuration.session = Account.signedIn
        var library = world.session.library
        _ = try await world.session.executor.changePassphrase(
            &library, current: Account.passphrase, new: "a brand new castle passphrase")
        world.session.library = library
        let snapshot = try #require(world.vault.snapshot(Account.account))
        #expect(snapshot.vault.master(
            passphrase: try PassphraseKey.derive("a brand new castle passphrase", kdf: snapshot.vault.kdf), words: nil) != nil,
                "the key door re-wrapped the account's lock — its vault step found the held keys")
    }
}
