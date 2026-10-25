//
//  VaultRoadTests.swift
//  VariorumCoreTests — VX-529 unit 2, scope 3 (`notes/plans/fixes/vx-529-pair-catchup.md` — R-529-1): THE LOBBY'S VAULT
//  ROAD's decision (`VaultRoad.answer`), pure. The typed passphrase derived under the vault's descriptor opens the vault's
//  master, the master opens a held key file's master lock: the key. Otherwise only what the read PROVES: this library is
//  the account's (its master's words copy IS the vault's recovery wrap) — then a passphrase lock under another descriptor
//  names the change, and no passphrase lock (E6) says the typed one is not the account's; else nothing beyond today's
//  refusal (another account's vault, both halves moved, an unsynced file, a cheap descriptor).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-529 unit 2 — the lobby's vault road: the decision (pure)")
struct VaultRoadTests {
    static let changed = "a passphrase made on the studio mac"

    static func vault(_ fixture: EX) throws -> VaultSnapshot {
        let account = try #require(fixture.account)
        return try #require(fixture.world.server.snapshot(account))
    }

    /// Another device re-made the account's passphrase (the vault's lock under a new descriptor; nothing else moved).
    static func passphraseChangedElsewhere(_ fixture: EX) throws {
        let account = try #require(fixture.account)
        var row = try #require(fixture.world.server.accounts[account])
        let master = try #require(row.vault.master(passphrase: fixture.p, words: nil))
        row.vault = try VaultModel.rewrappingPassphrase(
            row.vault, master: master, passphrase: try PF.passphraseKey(changed), device: "Studio Mac")
        row.revision += 1
        row.updatedAt = PF.t0.addingTimeInterval(3600)
        fixture.world.server.accounts[account] = row
    }

    /// …and its twelve words too.
    static func wordsChangedElsewhere(_ fixture: EX, to words: [String]) throws {
        let account = try #require(fixture.account)
        var row = try #require(fixture.world.server.accounts[account])
        let master = try #require(row.vault.master(passphrase: nil, words: fixture.w))
        row.vault = try VaultModel.rewrappingWords(
            row.vault, master: master, words: try PF.wordsKey(words), device: "Studio Mac")
        row.revision += 1
        fixture.world.server.accounts[account] = row
    }

    static func answer(_ typed: String, _ fixture: EX, live: KeyFile? = nil, floor: PassphraseKDF.Floor = PF.floor) throws
        -> VaultRoadAnswer
    {
        let file = try #require(live ?? fixture.world.liveFormat3)
        return VaultRoad.answer(typed, vault: try vault(fixture), files: [file], live: file, floor: floor)
    }

    /// THE ROAD: the account's CURRENT passphrase opens a lagging library through the vault (both postures) — the key is
    /// the library's own (the master lock's).
    @Test(arguments: ProtectionMode.allCases)
    func theAccountsCurrentPassphraseOpensThroughTheMasterLock(_ mode: ProtectionMode) throws {
        let fixture = try EX(mode, synced: true)
        try Self.passphraseChangedElsewhere(fixture)
        guard case .opens(let key, let derived) = try Self.answer(Self.changed, fixture) else {
            Issue.record("the account's current passphrase opens it through the vault")
            return
        }
        #expect(key == fixture.key)
        #expect(derived.kdf == (try Self.vault(fixture)).vault.kdf, "derived under the vault's own descriptor")
    }

    /// THE CHANGE NAMED: this library is the account's (its words copy is the vault's), its passphrase lock is under the
    /// old descriptor, and the typed passphrase opens neither — the vault's last writer and day.
    @Test func aPassphraseThatOpensNeitherNamesTheChange() throws {
        let fixture = try EX(.castle, synced: true)
        try Self.passphraseChangedElsewhere(fixture)
        let vault = try Self.vault(fixture)
        #expect(try Self.answer("not anyone's passphrase", fixture)
            == .passphraseChangedElsewhere(device: "Studio Mac", day: vault.updatedAt))
    }

    /// E6 — the library holds no passphrase lock of its own: the account's passphrase opens it through the vault; any
    /// other is not the account's.
    @Test func e6_theAccountsPassphraseOpensAndAnotherIsNotTheAccounts() throws {
        let fixture = try EX(.standard, synced: true)
        let e6 = try #require(fixture.world.liveFormat3).droppingPassphrase()
        guard case .opens(let key, _) = try Self.answer(fixture.passphrase, fixture, live: e6) else {
            Issue.record("the account's passphrase opens an E6 library through the vault")
            return
        }
        #expect(key == fixture.key)
        #expect(try Self.answer("not the account's", fixture, live: e6) == .notTheAccountsPassphrase)
    }

    /// NOTHING PROVEN, NOTHING SAID (F-U2-4): another account's vault; both halves moved (the copy no longer the vault's — a
    /// typed account-current passphrase still OPENS: the master lock proves it); an unsynced file; nothing moved (the typed
    /// one simply wrong); a descriptor below the floor (no cheap KDF, ever).
    @Test func nothingProvenNothingSaid() throws {
        let mine = try EX(.standard, synced: true)
        let theirs = try EX(.standard, synced: true)
        let file = try #require(mine.world.liveFormat3)
        #expect(VaultRoad.answer("garbage", vault: try Self.vault(theirs), files: [file], live: file, floor: PF.floor)
            == .nothingToSay, "another account's vault")
        #expect(VaultRoad.answer(theirs.passphrase, vault: try Self.vault(theirs), files: [file], live: file, floor: PF.floor)
            == .nothingToSay, "their passphrase opens their master, which opens no file here")
        let both = try EX(.castle, synced: true)
        try Self.passphraseChangedElsewhere(both)
        try Self.wordsChangedElsewhere(both, to: try PF.words())
        #expect(try Self.answer("garbage", both) == .nothingToSay, "both halves moved: no proof — today's refusal")
        guard case .opens(let key, _) = try Self.answer(Self.changed, both) else {
            Issue.record("the account's current passphrase still opens through the master lock")
            return
        }
        #expect(key == both.key)
        let local = try EX(.standard)
        #expect(VaultRoad.answer("garbage", vault: try Self.vault(mine), files: [try #require(local.world.liveFormat3)],
                                 live: local.world.liveFormat3, floor: PF.floor) == .nothingToSay, "an unsynced file")
        #expect(try Self.answer("garbage", mine) == .nothingToSay, "nothing moved: the typed one is simply wrong")
        #expect(try Self.answer(mine.passphrase, mine, floor: .production) == .nothingToSay,
                "a descriptor below the production floor is never derived")
    }

    /// THE ACCOUNT ENTERED CASTLE ELSEWHERE (a new master): the current passphrase opens the vault's new master, which
    /// doesn't reach this file's lock — nothing here (the follow's to catch up, typing a secret).
    @Test func aNewMasterReachesNothingHere() throws {
        let fixture = try EX(.standard, synced: true)
        let account = try #require(fixture.account)
        var row = try #require(fixture.world.server.accounts[account])
        let held = try #require(fixture.material)
        (row.vault, _) = try VaultModel.enteringCastle(
            row.vault, held: held, passphrase: fixture.p, words: fixture.w, device: "Studio Mac", ids: fixture.world)
        fixture.world.server.accounts[account] = row
        #expect(try Self.answer(fixture.passphrase, fixture) == .nothingToSay)
    }
}
