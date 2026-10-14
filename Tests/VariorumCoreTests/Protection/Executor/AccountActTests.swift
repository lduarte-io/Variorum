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
    @Test func setUpSyncInStandardMintsTheAccountKeyAndKeepsTheLibraryKey() async throws {
        let fixture = try EX(.standard)
        let account = PF.id()
        let executor = fixture.executor(session: .signedIn(accountID: account, email: nil))
        var library = try fixture.unlocked(executor)
        _ = try await executor.setUpSync(&library, typed: fixture.typed)
        let vault = try #require(fixture.world.server.snapshot(account))
        let accountKey = try #require(library.section.appleKeys.first { $0.purpose == .account })
        #expect(vault.mode == .standard(appleKeyID: accountKey.id))
        #expect(library.key == fixture.key && fixture.liveRecord?.account == account)
        let live = try #require(fixture.world.liveFormat3)
        #expect(live.master != nil && live.masterWordsCopy == vault.format.masterWrappedByRecovery)
        #expect(fixture.world.syncItems.keys.map(\.itemClass) == [.silent])
        expectSettled(fixture, library)
    }

    @Test func setUpSyncInCastleGivesTheVaultNoAppleCopy() async throws {
        let fixture = try EX(.castle)
        let account = PF.id()
        let executor = fixture.executor(session: .signedIn(accountID: account, email: nil))
        var library = try fixture.unlocked(executor)
        _ = try await executor.setUpSync(&library, typed: fixture.typed)
        let vault = try #require(fixture.world.server.snapshot(account))
        #expect(vault.mode == .castle && vault.format.appleKeyID == nil)
        #expect(fixture.world.syncItems.keys.map(\.itemClass) == [.touchid])
        #expect(fixture.world.writes.allSatisfy { if case .appleAdd = $0 { return false } else { return true } })
        expectSettled(fixture, library)
    }

    @Test func joiningInTheLibrarysOwnModeKeepsTheKeyAndReWrapsThePassphraseUnderTheAccounts() async throws {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let k0 = laptop.key
        // The laptop's library has its own passphrase; joining types the account's.
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase, words: mac.words))
        #expect(library.key == k0 && laptop.liveRecord?.account == mac.account)
        let live = try #require(laptop.world.liveFormat3)
        let vault = try #require(mac.world.server.snapshot(mac.account!))
        #expect(live.passphrase?.kdf == vault.format.kdf)  // corner 27
        #expect(try live.open(passphrase: .passphrase(mac.passphrase), floor: PF.floor) == k0)
        #expect(library.section.appleKeys.contains { $0.id == mac.accountApple!.id && $0.origin == .followed })
        expectSettled(laptop, library)
    }

    @Test func joiningACastleAccountFromStandardIsEnteringCastle() async throws {
        let mac = try EX(.castle, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let k0 = laptop.key, own = laptop.ownApple!.id
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase, words: mac.words), gate: .touchID)
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
        let anchor = try #require(laptop.world.liveFormat3?.anchor)
        #expect(anchor.outgoingFingerprint == PF.fp(k0))
        #expect(try laptop.world.liveFormat3?.historyKeys(currentKey: library.key).isEmpty == true)
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
            _ = try await e2.leaveAccount(.stopSyncingHere, &l2, typed: local.typed)
        }
    }
}

@Suite("VX-305 U3 — every leave re-keys, in both modes; Move")
struct LeaveAccountTests {
    @Test func aCastleLeaveReKeysWithBothSecretsAndNothingAfterOpensThroughTheAccount() async throws {
        let fixture = try EX(.castle, synced: true)
        let k0 = fixture.key, account = fixture.account!
        let vaultBefore = fixture.world.server.snapshot(account)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.leaveAccount(.stopSyncingHere, &library, typed: fixture.typed)
        #expect(fixture.liveRecord?.account == nil && fixture.liveRecord?.mode == .castle)
        let live = try #require(fixture.world.liveFormat3)
        #expect(library.key != k0 && live.master == nil)                        // nothing written after opens through it
        #expect(try live.historyKey(PF.fp(k0), currentKey: library.key) == k0)  // her copies keep opening for her
        #expect(fixture.world.server.snapshot(account) == vaultBefore)          // the account untouched
        #expect(fixture.world.syncItems.isEmpty && fixture.world.session[account] == nil)
        expectSettled(fixture, library)
    }

    @Test func aStandardLeaveWithAForgottenPassphraseSetNewMintsNothing() async throws {
        let fixture = try EX(.standard, synced: true)
        let own = fixture.ownApple!.id, accountKey = fixture.accountApple!.id
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.leaveAccount(
            .thisMacOnly, &library,
            typed: TypedSecrets(words: fixture.words, newPassphrase: "a fresh one"))
        let live = try #require(fixture.world.liveFormat3)
        #expect(live.apple?.keyID == own)                      // under this Mac's EXISTING own key
        #expect(fixture.world.icloud.keys[accountKey] != nil)  // the account's key left alone
        #expect(fixture.world.writes.allSatisfy { if case .appleAdd = $0 { return false } else { return true } })
        #expect(try live.open(passphrase: .passphrase("a fresh one"), floor: PF.floor) == library.key)
        #expect(live.passphrase?.kdf != fixture.p.kdf)          // a new passphrase: a fresh descriptor
        expectSettled(fixture, library)
    }

    @Test func thisMacOnlyCastleFromAnAccountInStandardLeavesTheAccountsKeyUntouched() async throws {
        let fixture = try EX(.standard, synced: true)
        let accountKey = fixture.accountApple!.id, own = fixture.ownApple!.id
        let executor = fixture.executor(session: .signedOut)
        var library = try fixture.unlocked(executor)
        _ = try await executor.leaveAccount(.thisMacOnly, &library, typed: fixture.typed, mode: .castle, gate: .touchID)
        #expect(fixture.liveRecord?.mode == .castle && fixture.liveRecord?.account == nil)
        #expect(fixture.world.icloud.keys[accountKey] != nil && fixture.world.icloud.keys[own] == nil)
        #expect(fixture.world.server.snapshot(fixture.account!)!.mode == .standard(appleKeyID: accountKey))
        expectSettled(fixture, library)
    }

    @Test func moveLeavesOneAccountAndJoinsTheSignedInOne() async throws {
        let x = try EX(.standard, synced: true)
        let y = try EX(.standard, synced: true, world: ExecutorWorld(icloud: x.world.icloud, server: x.world.server))
        let k0 = x.key
        let executor = x.executor(session: y.session)
        var library = try x.unlocked(executor)
        _ = try await executor.move(&library, typed: TypedSecrets(passphrase: y.passphrase, words: y.words))
        #expect(x.liveRecord?.account == y.account && library.key != k0)
        #expect(!x.world.syncItems.keys.contains { $0.accountID == x.account })
        #expect(x.world.syncItems.keys.contains { $0.accountID == y.account && $0.itemClass == .silent })
        #expect(try x.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: library.key) == k0)
        expectSettled(x, library)
    }

    @Test func aLeaveCrashAfterEveryWriteFinishes_AlwaysAsk() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.castle, synced: true, gate: .alwaysAsk); k0 = f.key; return f },
            act: { fixture, executor, library in
                _ = try await executor.leaveAccount(.stopSyncingHere, &library, typed: fixture.typed)
            },
            finished: { fixture, _ in fixture.liveRecord?.account == nil && fixture.world.live!.fingerprint != PF.fp(k0) },
            neverHappened: { fixture, _ in fixture.liveRecord?.account != nil && fixture.world.live!.fingerprint == PF.fp(k0) })
    }

    @Test func aLeaveWithThePlanGoneRollsBackOrFinishes() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.standard, synced: true); k0 = f.key; return f },
            act: { fixture, executor, library in
                _ = try await executor.leaveAccount(.stopSyncingHere, &library, typed: fixture.typed)
            },
            finished: { fixture, _ in
                fixture.liveRecord?.account == nil && fixture.world.live!.fingerprint != PF.fp(k0) && fixture.world.syncItems.isEmpty
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
