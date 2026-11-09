//
//  TypedUnlockRetryTests.swift
//  VariorumTests — VX-544 (the VX-849 run, batch 2 — D-544 in `notes/plans/fixes/vx-544-offline-typed-unlock.md`, her
//  R-849-1 "Retain + quiet retry"; the record `notes/plans/fixes/vx-849-typed-over-rescue.md`, BATCH 2 RECORD). THE OFFLINE
//  TYPED UNLOCK: offline, the typed unlock's one bounded vault read fails, the library opens (never hostage), and before
//  VX-544 the derived secret died with the call — nothing ever retried, so the row said "Sync locked" all session. Now the
//  load KEEPS the typed secret's DERIVED material in the session's memory as its pending load (never the passphrase's
//  text, never the words, never disk or the keychain), the retry runs the same load with it once the vault answers, and
//  every let-go road drops it. Over the new road's PLANTED leaves (no keychain, no network — `ProtectionAccountSupport`'s
//  vault and sync keys; `TypedUnlockSyncKeysTests`' Castle-under-Always-ask world).
//
//  RED ON OLD: every pin names the new seam (`pendingSyncKeyLoad`, `retryPendingSyncKeyLoad`, `letGoOfSyncKeyLoad`) — so
//  COMPILE-red on the pre-fix tree. THE BEHAVIORAL red is the record's named reverts: the keep made a no-op (nothing is
//  kept ⇒ nothing can load the keys after the failed read — "fail, then the vault reachable, then keys present" RED, the
//  old tree's behavior exactly), the hold's let-go check removed (the lock-mid-retry pin RED), the relock's let-go removed
//  (the relock pin RED). Guards (green on both sides by design): a successful first load leaves nothing pending; every
//  other exit leaves nothing pending.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-544 — the offline typed unlock keeps its load pending, and the retry finishes it (planted, no keychain)")
@MainActor
struct TypedUnlockRetryTests {
    typealias Account = PlantedAccount
    typealias World = TouchIDUnlockSyncKeysTests.World
    typealias Load = TypedUnlockSyncKeysTests

    /// Castle under Always ask, synced (no sync-keys item on this Mac at all), relaunched — then a typed unlock with the
    /// vault OUT OF REACH (offline): the library opens, nothing loaded.
    static func offlineUnlock(
        _ secret: (World) -> ProtectionSecret = { _ in .passphrase(Account.passphrase) }
    ) async throws -> (World, ProtectionRoadSession) {
        let world = try await Load.castleAlwaysAskSynced()
        TouchIDUnlockSyncKeysTests.relaunched(world)
        world.vault.reachable = false
        let opened = try await Load.typedUnlock(world, secret(world))
        #expect(opened.library.record?.mode == .castle && opened.key == world.session.key, "never hostage: the library opens")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "offline: nothing loaded")
        #expect(Load.engineKeyID(opened) == nil, "the engine's seam refuses — 'Sync locked'")
        return (world, opened)
    }

    // MARK: - Piece 1 — the pending load

    /// **AN OFFLINE TYPED PASSPHRASE UNLOCK KEEPS ITS LOAD PENDING** — for the library's account, holding the passphrase's
    /// DERIVED keys (the open's own Argon2id), never the text; redacted wherever it is described; nothing written.
    @Test func anOfflineTypedUnlockLeavesItsLoadPendingWithTheKeysUnloaded() async throws {
        let (world, opened) = try await Self.offlineUnlock()
        let pending = try #require(opened.pendingSyncKeyLoad, "the failed read leaves the load pending")
        #expect(pending.account == Account.account)
        guard case .passphrase(let derived) = pending.secret, !derived.isEmpty else {
            Issue.record("the passphrase's DERIVED keys are kept — \(pending.secret)")
            return
        }
        #expect(String(describing: pending) == "PendingSyncKeyLoad(redacted)")
        #expect(String(describing: pending.secret) == "TypedUnlockSecret(redacted)")
        #expect(!String(describing: pending).contains(Account.passphrase) && !"\(pending.secret)".contains(Account.passphrase))
        #expect(world.keys.items.isEmpty, "nothing written to the keychain — session memory only")
    }

    /// **THE TWELVE WORDS TYPED OFFLINE**: the pending keeps the words' DERIVED wrap key — never the words themselves.
    @Test func anOfflineWordsUnlockKeepsTheWordsDerivedKeyNeverTheWords() async throws {
        let (_, opened) = try await Self.offlineUnlock { .words($0.words) }
        let pending = try #require(opened.pendingSyncKeyLoad)
        switch pending.secret {
        case .wordsKey: break
        case .words: Issue.record("the words themselves were kept")
        case .passphrase, .nothing: Issue.record("the words' derived key is kept — \(pending.secret)")
        }
    }

    /// A read that TIMES OUT (a slow server past the bound) leaves the load pending the same way.
    @Test func aTimedOutVaultReadLeavesTheLoadPendingToo() async throws {
        let world = try await Load.castleAlwaysAskSynced()
        TouchIDUnlockSyncKeysTests.relaunched(world)
        world.vault.fetchDelay = .seconds(2)
        guard case .opened(let opened) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase(Account.passphrase), syncKeysWithin: .milliseconds(200))
        else {
            Issue.record("the typed secret opens the library")
            return
        }
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "nothing loaded in time")
        #expect(opened.pendingSyncKeyLoad?.account == Account.account, "the timed-out read leaves the load pending")
        try await Task.sleep(for: .milliseconds(2300))
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "the late answer was dropped — no hold")
    }

    /// GUARD — A SUCCESSFUL FIRST LOAD LEAVES NOTHING PENDING (green on both sides by design).
    @Test func aSuccessfulFirstLoadLeavesNothingPending() async throws {
        let world = try await Load.castleAlwaysAskSynced()
        let keys = try Load.accountsKeys(world)
        TouchIDUnlockSyncKeysTests.relaunched(world)
        let opened = try await Load.typedUnlock(world, .passphrase(Account.passphrase))
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == keys, "loaded online, as VX-501 built")
        #expect(opened.pendingSyncKeyLoad == nil, "nothing pending")
    }

    /// GUARD — EVERY OTHER EXIT LEAVES NOTHING PENDING: signed out (or into another account), no vault for the account, a
    /// secret that opens the library but not the vault, a moved account, the keys already held, a read-only road. Only the
    /// read's failure or timeout keeps anything.
    @Test func everyOtherExitLeavesNothingPending() async throws {
        // Signed out, and signed into another account: nothing read, nothing kept.
        do {
            let world = try await Load.castleAlwaysAskSynced()
            TouchIDUnlockSyncKeysTests.relaunched(world)
            for signIn in [SessionFact.signedOut, .signedIn(accountID: Account.other, email: "someone@example.test")] {
                world.road.session = signIn
                let opened = try await Load.typedUnlock(world, .passphrase(Account.passphrase))
                #expect(opened.pendingSyncKeyLoad == nil, "\(signIn): nothing pending")
            }
        }
        // No vault for the library's account (the read answers nil).
        do {
            let world = try await Load.castleAlwaysAskSynced()
            TouchIDUnlockSyncKeysTests.relaunched(world)
            world.vault.accounts[Account.account] = nil
            let opened = try await Load.typedUnlock(world, .passphrase(Account.passphrase))
            #expect(opened.pendingSyncKeyLoad == nil, "no vault: nothing pending")
        }
        // A secret that opens the library but not the vault (the passphrase changed on another device).
        do {
            let world = try await Load.castleAlwaysAskSynced()
            TouchIDUnlockSyncKeysTests.relaunched(world)
            try Self.changePassphraseElsewhere(world)
            let opened = try await Load.typedUnlock(world, .passphrase(Account.passphrase))
            #expect(opened.pendingSyncKeyLoad == nil, "not the vault's secret: nothing pending")
        }
        // A moved account (its sync key replaced elsewhere).
        do {
            let world = try await Load.castleAlwaysAskSynced()
            TouchIDUnlockSyncKeysTests.relaunched(world)
            try Self.moveTheAccountsKey(world)
            let opened = try await Load.typedUnlock(world, .passphrase(Account.passphrase))
            #expect(opened.pendingSyncKeyLoad == nil, "a moved account: nothing pending")
        }
        // The keys already held: nothing read, nothing kept.
        do {
            let world = try await Load.castleAlwaysAskSynced()
            world.keys.holdInSession(try Load.accountsKeys(world), accountID: Account.account)
            world.vault.reachable = false
            let opened = try await Load.typedUnlock(world, .passphrase(Account.passphrase))
            #expect(opened.pendingSyncKeyLoad == nil, "already held: nothing pending")
        }
        // A read-only road (a hosted test run) reads nothing and keeps nothing.
        do {
            let world = try await Load.castleAlwaysAskSynced()
            TouchIDUnlockSyncKeysTests.relaunched(world)
            world.vault.reachable = false
            guard case .opened(let opened) = await ProtectionOpenRoad.openTyped(
                world.road.context(writes: false), secret: .passphrase(Account.passphrase))
            else {
                Issue.record("the read-only road opens the library")
                return
            }
            #expect(opened.pendingSyncKeyLoad == nil, "a read-only road: nothing pending")
        }
    }

    /// **THE RELOCK LETS GO OF IT** (her R-849-1: "dropped at lock/sign-out"): the lock's drop ends the pending — and the
    /// session keeps nothing afterwards, whatever a load's failure would ask.
    @Test func theRelockLetsGoOfThePendingLoad() async throws {
        let (_, opened) = try await Self.offlineUnlock()
        #expect(opened.pendingSyncKeyLoad != nil, "precondition: pending")
        ProtectionRoadLock.dropSessionMemory(opened)
        #expect(opened.pendingSyncKeyLoad == nil, "the relock dropped the typed secret's derived material")
        let again = try #require(PendingSyncKeyLoad(account: Account.account, typed: .passphrase([
            try PassphraseKey.derive("anything at all", kdf: FastIDsLeaf().mintPassphraseKDF())])))
        #expect(!opened.retainPendingSyncKeyLoad(again), "a session that let go keeps nothing afterwards")
        #expect(opened.pendingSyncKeyLoad == nil)
    }

    // MARK: - Piece 2 — the retry

    static func retry(_ world: World, _ opened: ProtectionRoadSession) async {
        await ProtectionOpenRoad.retryPendingSyncKeyLoad(opened, signIn: world.road.session)
    }

    /// **THE PIN — OFFLINE, THEN THE VAULT REACHABLE, THEN THE KEYS**: the retry runs the typed unlock's load again with the
    /// secret it kept — one more vault read, the account's keys in session memory, the engine's seam reads them (the round
    /// runs), the pending ended, nothing written, nothing typed again. RED on the pre-fix tree for a BEHAVIORAL reason once
    /// the entry point exists (revert R-1a: nothing kept ⇒ nothing can load the keys after the failed read).
    @Test func anOfflineUnlockThenTheVaultReachableTheRetryLoadsTheKeys() async throws {
        let (world, opened) = try await Self.offlineUnlock()
        let keys = try Load.accountsKeys(world)
        world.vault.reachable = true
        let before = Load.fetches(world)
        await Self.retry(world, opened)
        #expect(Load.fetches(world) == before + 1, "one vault read")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == keys, "the retry loaded the account's keys")
        #expect(Load.engineKeyID(opened) == keys.rowKeyID, "the engine's seam reads them — the round runs")
        #expect(opened.pendingSyncKeyLoad == nil, "the pending ended with the hold")
        #expect(world.keys.items.isEmpty, "nothing written to the keychain — session memory only")
    }

    /// The twelve words typed offline: the retry finishes with the words' kept DERIVED key.
    @Test func theRetryFinishesAWordsUnlockToo() async throws {
        let (world, opened) = try await Self.offlineUnlock { .words($0.words) }
        let keys = try Load.accountsKeys(world)
        world.vault.reachable = true
        await Self.retry(world, opened)
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == keys, "the words' kept key reached the vault")
        #expect(opened.pendingSyncKeyLoad == nil)
    }

    /// A SECOND FAILURE KEEPS IT (still offline: one more read, still pending); NOTHING PENDING ⇒ NOTHING (after the hold
    /// landed, and on a session that let go, the retry reads nothing — idempotent).
    @Test func aSecondFailureKeepsThePendingAndNothingPendingReadsNothing() async throws {
        let (world, opened) = try await Self.offlineUnlock()
        var before = Load.fetches(world)
        await Self.retry(world, opened)
        #expect(Load.fetches(world) == before + 1, "the retry read the vault")
        #expect(opened.pendingSyncKeyLoad?.account == Account.account, "a second failure keeps the pending")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil)

        world.vault.reachable = true
        await Self.retry(world, opened)
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) != nil && opened.pendingSyncKeyLoad == nil)
        before = Load.fetches(world)
        await Self.retry(world, opened)
        #expect(Load.fetches(world) == before, "nothing pending: no read")

        let (other, locked) = try await Self.offlineUnlock()
        ProtectionRoadLock.dropSessionMemory(locked)
        other.vault.reachable = true
        before = Load.fetches(other)
        await Self.retry(other, locked)
        #expect(Load.fetches(other) == before, "a session that let go: no read")
        #expect(other.keys.sessionSyncKeys(accountID: Account.account) == nil, "and nothing held")
    }

    /// **A RETRY ANSWERED AFTER THE LOCK HOLDS NOTHING** (her R-849-1: the derived material and the keys are gone at a
    /// relock): the retry's read is out when the lock lets the session go; its answer arrives — and lands nothing. The keys
    /// never outlive the lock. RED by revert R-2b (the hold's let-go check removed: the late answer would hold the keys past
    /// the relock).
    @Test func aRetryAnsweredAfterTheLockHoldsNothing() async throws {
        let (world, opened) = try await Self.offlineUnlock()
        world.vault.reachable = true
        world.vault.fetchDelay = .milliseconds(600)
        let before = Load.fetches(world)
        let signIn = Account.signedIn
        let retrying = Task.detached { await ProtectionOpenRoad.retryPendingSyncKeyLoad(opened, signIn: signIn) }
        try await Task.sleep(for: .milliseconds(200))
        ProtectionRoadLock.dropSessionMemory(opened)  // the lock, while the read is out
        await retrying.value
        #expect(Load.fetches(world) == before + 1, "the read was out when the lock came")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "its answer held nothing past the relock")
        #expect(opened.pendingSyncKeyLoad == nil)
    }

    /// **A RETRY NEVER OVERWRITES A HOLD THAT LANDED MEANWHILE** (an act's — a key door or a follow holds the account's keys
    /// on this session): the retry's answer leaves the act's hold standing and ends the pending. RED by revert R-2c (the
    /// hold's compare removed).
    @Test func aRetryNeverOverwritesAHoldThatLandedMeanwhile() async throws {
        let (world, opened) = try await Self.offlineUnlock()
        let rowKeyID = try #require(opened.library.record?.accountRowKeyID)
        let actsHold = AccountKeys(
            master: Data(repeating: 7, count: 32), rowKeyID: rowKeyID, rowKey: Data(repeating: 8, count: 32))
        world.vault.reachable = true
        world.vault.fetchDelay = .milliseconds(600)
        let signIn = Account.signedIn
        let retrying = Task.detached { await ProtectionOpenRoad.retryPendingSyncKeyLoad(opened, signIn: signIn) }
        try await Task.sleep(for: .milliseconds(200))
        world.keys.holdInSession(actsHold, accountID: Account.account)  // an act's hold, while the read is out
        await retrying.value
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == actsHold, "the act's hold stands")
        #expect(opened.pendingSyncKeyLoad == nil, "the keys are held: the pending is done")
    }

    /// **RETRIES ASKED TOGETHER SHARE ONE READ** (a burst of triggers — the settle, became-active, Sync now): one flight,
    /// one vault read, every asker returning with the keys loaded. RED by revert R-2d (the flight bypassed: a read each).
    @Test func retriesAskedTogetherShareOneRead() async throws {
        let (world, opened) = try await Self.offlineUnlock()
        let keys = try Load.accountsKeys(world)
        world.vault.reachable = true
        world.vault.fetchDelay = .milliseconds(300)
        let before = Load.fetches(world)
        let signIn = Account.signedIn
        async let first: Void = ProtectionOpenRoad.retryPendingSyncKeyLoad(opened, signIn: signIn)
        async let second: Void = ProtectionOpenRoad.retryPendingSyncKeyLoad(opened, signIn: signIn)
        async let third: Void = ProtectionOpenRoad.retryPendingSyncKeyLoad(opened, signIn: signIn)
        _ = await (first, second, third)
        #expect(Load.fetches(world) == before + 1, "one read for the three")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == keys)
        #expect(opened.pendingSyncKeyLoad == nil)
    }

    /// A retry that finds the account's passphrase CHANGED ELSEWHERE meanwhile (the kept secret opens the library, not the
    /// vault any more) loads nothing and ENDS the pending — a follow or a key door loads them; no read is wasted again.
    @Test func aRetryThatFindsTheSecretNoLongerTheVaultsEndsThePending() async throws {
        let (world, opened) = try await Self.offlineUnlock()
        try Self.changePassphraseElsewhere(world)
        world.vault.reachable = true
        await Self.retry(world, opened)
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil, "nothing loaded")
        #expect(opened.pendingSyncKeyLoad == nil, "the pending ended")
    }

    /// A retry SIGNED OUT (or into another account) reads nothing and ends the pending (the vault is the account's).
    @Test func aRetrySignedOutReadsNothingAndEndsThePending() async throws {
        for signIn in [SessionFact.signedOut, .signedIn(accountID: Account.other, email: "someone@example.test")] {
            let (world, opened) = try await Self.offlineUnlock()
            world.vault.reachable = true
            let before = Load.fetches(world)
            await ProtectionOpenRoad.retryPendingSyncKeyLoad(opened, signIn: signIn)
            #expect(Load.fetches(world) == before, "\(signIn): nothing read")
            #expect(world.keys.sessionSyncKeys(accountID: Account.account) == nil)
            #expect(opened.pendingSyncKeyLoad == nil, "\(signIn): the pending ended")
        }
    }

    // MARK: - World changes made elsewhere

    /// The account's passphrase changed on another Mac (this library's lock still the old one).
    static func changePassphraseElsewhere(_ world: World) throws {
        let snapshot = try #require(world.vault.snapshot(Account.account))
        let master = try #require(snapshot.vault.master(
            passphrase: try PassphraseKey.derive(Account.passphrase, kdf: snapshot.vault.kdf), words: nil))
        let elsewhere = try PassphraseKey.derive("changed on another mac", kdf: FastIDsLeaf().mintPassphraseKDF())
        world.vault.accounts[Account.account]?.vault = try VaultModel.rewrappingPassphrase(
            snapshot.vault, master: master, passphrase: elsewhere, device: "Another Mac")
    }

    /// The account's sync key replaced elsewhere since this library followed.
    static func moveTheAccountsKey(_ world: World) throws {
        let snapshot = try #require(world.vault.snapshot(Account.account))
        let master = try #require(snapshot.vault.master(
            passphrase: try PassphraseKey.derive(Account.passphrase, kdf: snapshot.vault.kdf), words: nil))
        var moved = snapshot.vault
        moved.earlierRowKeys[moved.rowKey.keyID] = moved.rowKey.wrappedByMaster
        moved.rowKey = VaultKey(
            keyID: "moved-row-key", wrappedByMaster: try AES.KeyWrap.wrap(SymmetricKey(size: .bits256), using: master))
        world.vault.accounts[Account.account]?.vault = moved
    }
}
