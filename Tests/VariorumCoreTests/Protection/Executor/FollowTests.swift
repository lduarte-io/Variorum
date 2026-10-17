//
//  FollowTests.swift
//  VariorumCoreTests — VX-305 U3: Replace All Keys and the follow (design
//  §3.9) on two devices of one account — the history growing within a mode,
//  the follow into Castle and into Standard typing ONE secret, the history
//  carried by every follow (rule 4), a leave's rotation completed by its
//  follower. (The follower's anchor and the finish of a stuck leave left with
//  VX-378 U1 — rules 4, 12.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U3 — Replace All Keys: within its mode, the history grows; the account's sync key stays (rule 15)")
struct ReplaceAllKeysTests {
    @Test func castleReplaceAllKeysGrowsTheHistoryAndLeavesTheAccountsSyncKey() async throws {
        let fixture = try EX(.castle, synced: true)
        let k0 = fixture.key
        let before = try #require(fixture.world.server.snapshot(fixture.account!))
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.replaceAllKeys(&library, typed: fixture.typed)
        let k1 = library.key
        #expect(fixture.world.writeLog(naming: [PF.fp(k0): "K0", PF.fp(k1): "K1"]) == [
            "record K0", "memory K0", "plan",
            "custody+ touchid K1", "plan", "keyfile K1", "plan", "stage K1", "plan", "staged-record K1", "plan", "swap K1", "plan",
            "memory K1", "plan", "custody- touchid K0", "plan", "backup K1", "plan", "record K1", "memory K1", "plan-",
        ])
        #expect(fixture.liveRecord?.mode == .castle)
        #expect(try fixture.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: k1) == k0)
        #expect(fixture.world.server.snapshot(fixture.account!) == before, "Replace All Keys wrote the vault")
        expectSettled(fixture, library)
    }

    @Test func standardReplaceAllKeysKeepsThisMacsOwnAppleKeyAndTheVault() async throws {
        let fixture = try EX(.standard, synced: true)
        let k0 = fixture.key
        let before = try #require(fixture.world.server.snapshot(fixture.account!))
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.replaceAllKeys(&library, typed: fixture.typed)
        #expect(fixture.world.server.snapshot(fixture.account!) == before)
        #expect(fixture.world.liveFormat3?.apple?.keyID == fixture.ownApple!.id)
        #expect(fixture.world.writes.allSatisfy { if case .appleAdd = $0 { return false } else { return true } })
        #expect(try fixture.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: library.key) == k0)
        expectSettled(fixture, library)
    }

    @Test func aCrashAfterEveryWriteFinishes() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.castle, synced: true, gate: .alwaysAsk); k0 = f.key; return f },
            act: { fixture, executor, library in _ = try await executor.replaceAllKeys(&library, typed: fixture.typed) },
            finished: { fixture, _ in fixture.liveRecord?.mode == .castle && fixture.world.live!.fingerprint != PF.fp(k0) },
            neverHappened: { fixture, _ in fixture.world.live!.fingerprint == PF.fp(k0) })
    }

    @Test func aLocalLibraryIsRefused() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: ExecutorRefusal.notSynced) { _ = try await executor.replaceAllKeys(&library, typed: fixture.typed) }
    }
}

@Suite("VX-305 U3 — the follow: into Castle one secret, out of Castle quiet, a lagging device catching up")
struct FollowTests {
    @Test func aStandardDeviceFollowsIntoCastleTypingOneSecret() async throws {
        let mac = try EX(.standard, synced: true)
        let phone = try EX(.standard, synced: true, joining: mac)
        let k0 = phone.key, phoneOwn = phone.ownApple!.id
        let original = try #require(phone.material?.rowKeyID)
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useCastle(&macLibrary, typed: mac.typed, gate: .touchID)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        phone.world.writes = []
        _ = try await executor.follow(&library, kind: .intoCastle, typed: TypedSecrets(words: phone.words))
        #expect(phone.liveRecord?.mode == .castle)
        let live = try #require(phone.world.liveFormat3)
        // Locked under the secret typed and the new master, its words copy beside.
        #expect(live.words != nil && live.passphrase == nil && live.master != nil)
        #expect(try live.open(wordsThroughMaster: phone.words) == library.key)
        #expect(try live.historyKey(PF.fp(k0), currentKey: library.key) == k0)
        // Its own key retired and deleted.
        #expect(phone.world.icloud.keys[phoneOwn] == nil)
        #expect(library.section.retiredAppleKeyIDs.contains(phoneOwn))
        #expect(!phone.world.custody.keys.contains { $0.itemClass == .silent })
        // Rule 15: it follows the account's new sync key and still reads rows
        // sealed under the one before.
        let vault = try #require(phone.world.server.snapshot(phone.account!))
        #expect(phone.liveRecord?.accountRowKeyID == vault.rowKeyID && vault.rowKeyID != original)
        let held = try #require(phone.world.syncItems[SyncKeysItemFact(accountID: phone.account!, itemClass: .touchid)])
        #expect(held.rowKey(for: original) != nil && held.rowKey(for: vault.rowKeyID) != nil)
        expectSettled(phone, library)
    }

    /// Rule 12: the account left Castle elsewhere; this device follows out
    /// QUIETLY — nothing typed (the leave changed no key) — with the notice.
    /// Its new Standard key's history carries the Castle key (rule 4), and the
    /// account's words open it through the master's copy, its passphrase
    /// through the vault.
    @Test func aCastleDeviceFollowsOutQuietlyAndItsHistoryOpensWithTheAccountsSecrets() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        let k0 = phone.key
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        let outcome = try await executor.follow(&library, kind: .intoStandard, typed: .none)
        #expect(outcome.done == [.ruleFive] && outcome.notices.contains(.followedOutOfCastle))
        #expect(phone.liveRecord?.mode == .standard)
        let live = try #require(phone.world.liveFormat3)
        #expect(try live.historyKey(PF.fp(k0), currentKey: try live.open(wordsThroughMaster: phone.words)) == k0)
        let vault = try #require(phone.world.server.snapshot(phone.account!)).vault
        let master = try #require(vault.master(passphrase: phone.p, words: nil))
        #expect(try live.historyKey(PF.fp(k0), currentKey: try live.open(master: master)) == k0)
        #expect(phone.world.syncItems.keys.map(\.itemClass) == [.silent])
        expectSettled(phone, library)
    }

    /// Rule 15: a device that lagged through a whole Castle stretch (in and out
    /// again) types a secret once to catch up — its old master opens nothing
    /// written since; the account's earlier sync keys come with the new master.
    @Test func aDeviceThatLaggedThroughCastleCatchesUpWithOneSecret() async throws {
        let mac = try EX(.standard, synced: true)
        let phone = try EX(.standard, synced: true, joining: mac)
        let original = try #require(phone.material?.rowKeyID)
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useCastle(&macLibrary, typed: mac.typed, gate: .touchID)
        _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed)
        let vault = try #require(phone.world.server.snapshot(phone.account!))
        #expect(vault.mode == .standard && vault.rowKeyID != original)
        #expect(throws: (any Error).self, "a lagging device's master still opens the account's keys") {
            _ = try vault.vault.keys(master: phone.material!.masterKey)
        }
        await #expect(throws: ExecutorRefusal.secretMissing) {
            let e = phone.executor()
            var l = try phone.unlocked(e)
            _ = try await e.follow(&l, kind: .keysReplaced, typed: .none)
        }
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        _ = try await executor.follow(&library, kind: .keysReplaced, typed: TypedSecrets(passphrase: phone.passphrase))
        #expect(phone.liveRecord?.accountRowKeyID == vault.rowKeyID)
        let held = try #require(phone.world.syncItems[SyncKeysItemFact(accountID: phone.account!, itemClass: .silent)])
        #expect(held.rowKey(for: original) != nil && held.rowKey(for: vault.rowKeyID) != nil)
        expectSettled(phone, library)
    }

    @Test func theOldPassphraseAfterAChangeElsewhereIsRefusedWithTheChangeNamed() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        // The Mac changed the account's passphrase (a fresh descriptor).
        var account = mac.world.server.accounts[mac.account!]!
        let fresh = try PassphraseKey.derive("a new passphrase", kdf: PF.fastKDF())
        account.vault = try VaultModel.rewrappingPassphrase(
            account.vault, master: mac.material!.masterKey, passphrase: fresh, device: "Lillian's Air")
        mac.world.server.accounts[mac.account!] = account
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        await #expect(throws: ExecutorRefusal.passphraseChangedElsewhere(device: "Lillian's Air", day: nil)) {
            _ = try await executor.follow(&library, kind: .keysReplaced, typed: TypedSecrets(passphrase: phone.passphrase))
        }
    }

    @Test func aFollowIntoStandardCrashAfterEveryWriteFinishes_AlwaysAsk() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            {
                let mac = try EX(.castle, synced: true)
                let phone = try EX(.castle, synced: true, gate: .alwaysAsk, joining: mac)
                k0 = phone.key
                let e = mac.executor()
                var l = try mac.unlocked(e)
                _ = try await e.useStandard(&l, typed: mac.typed)
                return phone
            },
            act: { fixture, executor, library in
                _ = try await executor.follow(&library, kind: .intoStandard, typed: TypedSecrets(words: fixture.words))
            },
            finished: { fixture, _ in fixture.liveRecord?.mode == .standard && fixture.world.live!.fingerprint != PF.fp(k0) },
            neverHappened: { fixture, _ in fixture.liveRecord?.mode == .castle && fixture.world.live!.fingerprint == PF.fp(k0) },
            typed: { TypedSecrets(words: $0.words) })
    }
}
