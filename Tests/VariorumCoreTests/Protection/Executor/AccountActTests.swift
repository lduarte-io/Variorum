//
//  AccountActTests.swift
//  VariorumCoreTests — VX-305 U3: the account acts (design §3.8) — set up
//  sync, enroll by the joining rules, every leave re-keying in both modes,
//  Move — their writes, a crash after every write, the refusals.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U3 — set up sync and enroll: the joining rules")
struct AccountJoinTests {
    /// Rule 7 + rule 14: the first device hands its library's pair up — the
    /// vault is locked by the library's passphrase and words and nothing else;
    /// the library key stays; no Apple key is minted for the account.
    @Test func setUpSyncInStandardHandsTheLibrarysPairUpAndKeepsTheLibraryKey() async throws {
        let fixture = try EX(.standard)
        let account = PF.id()
        let executor = fixture.executor(session: .signedIn(accountID: account, email: nil))
        var library = try fixture.unlocked(executor)
        _ = try await executor.setUpSync(&library, typed: fixture.typed)
        let vault = try #require(fixture.world.server.snapshot(account))
        #expect(vault.mode == .standard)
        #expect(vault.vault.master(passphrase: try PassphraseKey.derive(fixture.passphrase, kdf: vault.vault.kdf), words: nil) != nil)
        #expect(vault.vault.master(passphrase: nil, words: fixture.w) != nil)
        #expect(library.key == fixture.key && fixture.liveRecord?.account == account)
        #expect(fixture.liveRecord?.accountRowKeyID == vault.rowKeyID)
        let live = try #require(fixture.world.liveFormat3)
        #expect(live.master != nil && live.masterWordsCopy == vault.vault.masterByWords)
        // VX-462 (VX-329 R1): the account's copy is the words' road — no own words lock is kept beside it (an own lock
        // can never be proven the account's at a later re-join — W-VX309-5); the library's words open it through the copy.
        #expect(live.words == nil, "an own words lock was kept beside the account's copy")
        #expect(try live.open(.words(fixture.words), floor: PF.floor) == fixture.key, "the library's words open it")
        #expect(fixture.world.syncItems.keys.map(\.itemClass) == [.silent])
        #expect(fixture.world.writes.allSatisfy { if case .appleAdd = $0 { return false } else { return true } })
        expectSettled(fixture, library)
    }

    @Test func setUpSyncInCastleGivesTheVaultTheCastleFlag() async throws {
        let fixture = try EX(.castle)
        let account = PF.id()
        let executor = fixture.executor(session: .signedIn(accountID: account, email: nil))
        var library = try fixture.unlocked(executor)
        _ = try await executor.setUpSync(&library, typed: fixture.typed)
        let vault = try #require(fixture.world.server.snapshot(account))
        #expect(vault.mode == .castle)
        #expect(fixture.world.syncItems.keys.map(\.itemClass) == [.touchid])
        #expect(fixture.world.writes.allSatisfy { if case .appleAdd = $0 { return false } else { return true } })
        expectSettled(fixture, library)
    }

    /// Rule 7 + rule 14: joining types ONE of the account's secrets and adopts
    /// the account's pair — the key stays, the passphrase lock is the
    /// account's, the library's own words no longer open it (the account's do,
    /// through the master's copy), and the face is told.
    @Test func joiningInTheLibrarysOwnModeTypesOneSecretAndAdoptsTheAccountsPair() async throws {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let k0 = laptop.key
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        let outcome = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        #expect(outcome.notices.contains(.wordsReplacedByAccount))
        #expect(library.key == k0 && laptop.liveRecord?.account == mac.account)
        let live = try #require(laptop.world.liveFormat3)
        let vault = try #require(mac.world.server.snapshot(mac.account!))
        #expect(live.passphrase?.kdf == vault.vault.kdf)  // corner 27
        #expect(try live.open(passphrase: .passphrase(mac.passphrase), floor: PF.floor) == k0)
        #expect(try live.open(.words(mac.words), floor: PF.floor) == k0)
        #expect((try? live.open(.words(laptop.words), floor: PF.floor)) == nil, "the library's old words still open the live file")
        #expect(laptop.liveRecord?.accountRowKeyID == vault.rowKeyID)
        expectSettled(laptop, library)
    }

    @Test func joiningACastleAccountFromStandardIsEnteringCastle() async throws {
        let mac = try EX(.castle, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let k0 = laptop.key, own = laptop.ownApple!.id
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(words: mac.words), gate: .touchID)
        #expect(laptop.liveRecord?.mode == .castle && laptop.liveRecord?.account == mac.account)
        #expect(library.key != k0 && laptop.world.icloud.keys[own] == nil)
        #expect(try laptop.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: library.key) == k0)
        expectSettled(laptop, library)
    }

    @Test func joiningAStandardAccountFromCastleIsLeavingCastle() async throws {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.castle, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let k0 = laptop.key
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        let outcome = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase, words: mac.words))
        #expect(outcome.done.contains(.ruleFive))
        #expect(laptop.liveRecord?.mode == .standard && laptop.liveRecord?.account == mac.account)
        // Rule 4: the history carries the Castle key (the anchor left with VX-378 U1).
        #expect(try laptop.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: library.key) == k0)
        expectSettled(laptop, library)
    }

    @Test func theRefusalsAreNamed() async throws {
        let synced = try EX(.standard, synced: true)
        let e1 = synced.executor()
        var l1 = try synced.unlocked(e1)
        await #expect(throws: ExecutorRefusal.nothingToDo) { _ = try await e1.enroll(&l1, typed: synced.typed) }
        await #expect(throws: ExecutorRefusal.nothingToDo) { _ = try await e1.move(&l1, typed: synced.typed) }
        let local = try EX(.standard)
        let e2 = local.executor()
        var l2 = try local.unlocked(e2)
        await #expect(throws: ExecutorRefusal.noAccountSignedIn) { _ = try await e2.setUpSync(&l2, typed: local.typed) }
        await #expect(throws: ExecutorRefusal.notSynced) {
            _ = try await e2.leaveAccount(.stopSyncingHere, &l2)
        }
    }
}

@Suite("VX-305 U3 — no leave changes a key (rule 16); Move")
struct LeaveAccountTests {
    /// Rule 16: the record stops naming the account and this Mac forgets its
    /// sync keys; the key, its file and the account stay as they were.
    @Test func aCastleLeaveUnbindsAndForgetsTheAccountsKeysAndChangesNothingElse() async throws {
        let fixture = try EX(.castle, synced: true)
        let k0 = fixture.key, account = fixture.account!
        let vaultBefore = fixture.world.server.snapshot(account)
        let fileBefore = fixture.world.liveFormat3
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        #expect(fixture.liveRecord?.account == nil && fixture.liveRecord?.mode == .castle)
        #expect(library.key == k0 && fixture.world.liveFormat3 == fileBefore)
        #expect(fixture.world.server.snapshot(account) == vaultBefore)          // the account untouched
        #expect(fixture.world.syncItems.isEmpty && fixture.world.session[account] == nil)
        expectSettled(fixture, library)
    }

    @Test func moveLeavesOneAccountAndJoinsTheSignedInOne() async throws {
        let x = try EX(.standard, synced: true)
        let y = try EX(.standard, synced: true, world: ExecutorWorld(icloud: x.world.icloud, server: x.world.server))
        let k0 = x.key
        let executor = x.executor(session: y.session)
        var library = try x.unlocked(executor)
        _ = try await executor.move(&library, typed: TypedSecrets(passphrase: y.passphrase, words: y.words))
        #expect(x.liveRecord?.account == y.account && library.key == k0)
        #expect(!x.world.syncItems.keys.contains { $0.accountID == x.account })
        #expect(x.world.syncItems.keys.contains { $0.accountID == y.account && $0.itemClass == .silent })
        expectSettled(x, library)
    }

    @Test func aLeaveCrashAfterEveryWriteFinishes_AlwaysAsk() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.castle, synced: true, gate: .alwaysAsk); k0 = f.key; return f },
            act: { _, executor, library in
                _ = try await executor.leaveAccount(.stopSyncingHere, &library)
            },
            finished: { fixture, _ in fixture.liveRecord?.account == nil && fixture.world.live!.fingerprint == PF.fp(k0) },
            neverHappened: { fixture, _ in fixture.liveRecord?.account != nil && fixture.world.live!.fingerprint == PF.fp(k0) })
    }

    @Test func aLeaveWithThePlanGoneRollsBackOrFinishes() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.standard, synced: true); k0 = f.key; return f },
            act: { _, executor, library in
                _ = try await executor.leaveAccount(.stopSyncingHere, &library)
            },
            finished: { fixture, _ in
                fixture.liveRecord?.account == nil && fixture.world.live!.fingerprint == PF.fp(k0) && fixture.world.syncItems.isEmpty
            },
            neverHappened: { fixture, _ in fixture.liveRecord?.account != nil && fixture.world.live!.fingerprint == PF.fp(k0) },
            dropPlan: true)
    }

    @Test func anEnrollIntoCastleCrashAfterEveryWriteFinishes() async throws {
        var k0: StoreKey!
        var accountTyped: TypedSecrets!
        try await CrashHarness.everywhere(
            {
                let mac = try EX(.castle, synced: true)
                let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
                laptop.account = mac.account
                k0 = laptop.key
                accountTyped = mac.typed
                return laptop
            },
            act: { _, executor, library in _ = try await executor.enroll(&library, typed: accountTyped, gate: .touchID) },
            finished: { fixture, _ in fixture.liveRecord?.mode == .castle && fixture.liveRecord?.account != nil },
            neverHappened: { fixture, _ in fixture.liveRecord?.account == nil && fixture.world.live!.fingerprint == PF.fp(k0) },
            typed: { _ in accountTyped })
    }
}
