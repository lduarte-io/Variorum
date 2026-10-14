//
//  FollowTests.swift
//  VariorumCoreTests — VX-305 U3: Replace All Keys and the follow (design
//  §3.9) on two devices of one account — the history growing within a mode,
//  the follow into Castle and into Standard typing ONE secret, a follower's
//  anchor locked under the secret typed at its follow, the hold while a
//  rotation is in progress, the finish of a leave a lost device started.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U3 — Replace All Keys: within its mode, the history grows")
struct ReplaceAllKeysTests {
    @Test func castleReplaceAllKeysRotatesTheAccountAndGrowsTheHistory() async throws {
        let fixture = try EX(.castle, synced: true)
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.replaceAllKeys(&library, typed: fixture.typed)
        let k1 = library.key
        #expect(fixture.world.writeLog(naming: [PF.fp(k0): "K0", PF.fp(k1): "K1"]) == [
            "record K0", "memory K0", "plan",
            "plan", "vault rotating", "sync+ touchid", "plan", "reencrypt", "plan", "vault castle", "sync+ touchid", "plan",
            "custody+ touchid K1", "plan", "keyfile K1", "plan", "stage K1", "plan", "staged-record K1", "plan", "swap K1", "plan",
            "memory K1", "plan", "custody- touchid K0", "plan", "backup K1", "plan", "record K1", "memory K1", "plan-",
        ])
        #expect(fixture.liveRecord?.mode == .castle)
        #expect(try fixture.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: k1) == k0)
        expectSettled(fixture, library)
    }

    @Test func standardReplaceAllKeysKeepsTheAccountKeyAndThisMacsOwn() async throws {
        let fixture = try EX(.standard, synced: true)
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.replaceAllKeys(&library, typed: fixture.typed)
        let vault = try #require(fixture.world.server.snapshot(fixture.account!))
        // Decision 30: under the SAME account key; this Mac's existing own key.
        #expect(vault.mode == .standard(appleKeyID: fixture.accountApple!.id))
        #expect(fixture.world.liveFormat3?.apple?.keyID == fixture.ownApple!.id)
        #expect(fixture.world.writes.allSatisfy { if case .appleAdd = $0 { return false } else { return true } })
        #expect(try fixture.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: library.key) == k0)
        expectSettled(fixture, library)
    }

    @Test func onAnAccountStillOnTheOldSharedKeyItReLinksFirst() async throws {
        let fixture = try EX(.standard, synced: true)
        // The account's vault on the old shared key (today's shape).
        let shared = fixture.accountApple!
        fixture.world.icloud.oldShared = shared
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.replaceAllKeys(&library, typed: fixture.typed)
        let vault = try #require(fixture.world.server.snapshot(fixture.account!))
        let fresh = try #require(library.section.appleKeys.first { $0.purpose == .account && $0.id != shared.id })
        #expect(vault.mode == .standard(appleKeyID: fresh.id))
        #expect(fixture.world.icloud.oldShared?.id == shared.id)  // nothing written under it, nothing deleted
    }

    @Test func aCrashAfterEveryWriteFinishes() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.castle, synced: true, gate: .alwaysAsk); k0 = f.key; return f },
            act: { fixture, executor, library in _ = try await executor.replaceAllKeys(&library, typed: fixture.typed) },
            finished: { fixture, _ in
                fixture.liveRecord?.mode == .castle && fixture.world.live!.fingerprint != PF.fp(k0)
                    && fixture.world.server.snapshot(fixture.account!)!.format.previousCorpusKey == nil
            },
            neverHappened: { fixture, _ in fixture.world.live!.fingerprint == PF.fp(k0) })
    }

    @Test func aLocalLibraryIsRefused() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: ExecutorRefusal.notSynced) { _ = try await executor.replaceAllKeys(&library, typed: fixture.typed) }
    }
}

@Suite("VX-305 U3 — the follow: one secret typed, the anchor under it, the hold in a rotation's window")
struct FollowTests {
    @Test func aStandardDeviceFollowsIntoCastleTypingOneSecret() async throws {
        let mac = try EX(.standard, synced: true)
        let phone = try EX(.standard, synced: true, joining: mac)
        let k0 = phone.key, phoneOwn = phone.ownApple!.id
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useCastle(&macLibrary, typed: mac.typed, gate: .touchID)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        phone.world.writes = []
        let outcome = try await executor.follow(&library, kind: .intoCastle, typed: TypedSecrets(words: phone.words))
        #expect(!outcome.held)
        #expect(phone.liveRecord?.mode == .castle)
        let live = try #require(phone.world.liveFormat3)
        // Locked under the secret typed and the new master, its words copy beside.
        #expect(live.words != nil && live.passphrase == nil && live.master != nil)
        #expect(try live.open(wordsThroughMaster: phone.words) == library.key)
        #expect(try live.historyKey(PF.fp(k0), currentKey: library.key) == k0)
        // Its own key retired and deleted; the account's recorded retired.
        #expect(phone.world.icloud.keys[phoneOwn] == nil)
        #expect(library.section.retiredAppleKeyIDs.isSuperset(of: [phoneOwn, mac.accountApple!.id]))
        #expect(!phone.world.custody.keys.contains { $0.itemClass == .silent })
        expectSettled(phone, library)
    }

    @Test func aCastleDeviceFollowsIntoStandardAndItsAnchorOpensWithTheSecretTypedAtItsFollow() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        let k0 = phone.key
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        let outcome = try await executor.follow(&library, kind: .intoStandard, typed: TypedSecrets(passphrase: phone.passphrase))
        #expect(outcome.done == [.ruleFive] && !outcome.held)
        #expect(phone.liveRecord?.mode == .standard)
        let anchor = try #require(phone.world.liveFormat3?.anchor)
        // Under the secret typed at its follow, and through what opened this
        // device (its copied locks); the master's road kept (the master changed).
        #expect(try anchor.open(.passphrase(phone.passphrase), floor: PF.floor).outgoing.key == k0)
        #expect(try anchor.open(.words(phone.words), floor: PF.floor).outgoing.key == k0)
        #expect(anchor.locks.copiedLocks?.master != nil)
        #expect(try anchor.open(outgoingKey: k0).outgoing.key == k0)
        expectSettled(phone, library)
    }

    @Test func aFollowerMeetingALeaveInProgressHoldsItsReKeyWithItsKeysTheCastleWay() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        let k0 = phone.key
        // The Mac's leave stops right after the vault's first write (lost).
        let clean = try EX(.castle, synced: true)
        let ce = clean.executor()
        var cl = try clean.unlocked(ce)
        _ = try await ce.useStandard(&cl, typed: clean.typed)
        let firstVaultWrite = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("vault") })
        mac.world.crashAfterWrites = firstVaultWrite + 1
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        await #expect(throws: SimulatedCrash.self) { _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed) }
        // The named key hasn't reached this device's iCloud Keychain yet.
        let named = try #require(phone.world.server.snapshot(phone.account!)?.format.appleKeyID)
        let parked = phone.world.icloud.keys.removeValue(forKey: named)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        let held = try await executor.follow(&library, kind: .intoStandard, typed: TypedSecrets(passphrase: phone.passphrase))
        #expect(held.held && held.notices == [.heldForRotation])
        // It walked, but never cleared the previous key while the id stands with no wrap.
        let vault = try #require(phone.world.server.snapshot(phone.account!))
        #expect(vault.rowsBelowRotationSeq == 0 && vault.format.previousCorpusKey != nil)
        #expect(vault.reading.mode == .leavingCastle(appleKeyID: named))
        // The library re-key is held; the anchor is written; the keys the Castle way.
        #expect(phone.world.live!.fingerprint == PF.fp(k0) && phone.liveRecord?.mode == .castle)
        #expect(phone.world.liveFormat3?.anchor?.outgoingFingerprint == PF.fp(k0))
        #expect(phone.world.syncItems.keys.map(\.itemClass) == [.touchid])
        expectSettled(phone, library)
        // The key arrives: the next follow completes the leave and re-keys.
        phone.world.icloud.keys[named] = parked
        let done = try await executor.follow(&library, kind: .intoStandard, typed: TypedSecrets(passphrase: phone.passphrase))
        #expect(!done.held)
        #expect(phone.world.server.snapshot(phone.account!)!.format.masterWrappedByAppleHeld != nil)
        #expect(phone.liveRecord?.mode == .standard)
        #expect(phone.world.syncItems.keys.map(\.itemClass) == [.silent])
        expectSettled(phone, library)
    }

    @Test func finishingALeaveALostDeviceStartedMintsAFreshAccountKeyOnlyAtThePressThatStopsWaiting() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        let clean = try EX(.castle, synced: true)
        let ce = clean.executor()
        var cl = try clean.unlocked(ce)
        _ = try await ce.useStandard(&cl, typed: clean.typed)
        mac.world.crashAfterWrites = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("vault") }) + 1
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        await #expect(throws: SimulatedCrash.self) { _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed) }
        let named = try #require(phone.world.server.snapshot(phone.account!)?.format.appleKeyID)
        phone.world.icloud.keys[named] = nil  // it never arrives
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        let outcome = try await executor.follow(
            &library, kind: .intoStandard, typed: TypedSecrets(words: phone.words), mintingIfTheNamedKeyNeverArrives: true)
        #expect(!outcome.held)
        let vault = try #require(phone.world.server.snapshot(phone.account!))
        let minted = try #require(library.section.appleKeys.first { $0.purpose == .account && $0.origin == .minted })
        #expect(vault.mode == .standard(appleKeyID: minted.id) && minted.id != named)
        #expect(vault.format.previousCorpusKey == nil)
        expectSettled(phone, library)
    }

    @Test func theOldPassphraseAfterAChangeElsewhereIsRefusedWithTheChangeNamed() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        // The Mac changed the account's passphrase (a fresh descriptor).
        var account = mac.world.server.accounts[mac.account!]!
        let fresh = try PassphraseKey.derive("a new passphrase", kdf: PF.fastKDF())
        account.format = try account.format.rewrappingPassphrase(
            masterKey: mac.material!.masterSymmetricKey, passphraseKey: fresh.key, kdf: fresh.kdf)
        account.format.updatedByDevice = "Lillian's Air"
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
