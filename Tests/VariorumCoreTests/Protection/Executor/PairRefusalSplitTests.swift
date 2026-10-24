//
//  PairRefusalSplitTests.swift
//  VariorumCoreTests — VX-529 unit 1, scope 3: THE REFUSAL SPLIT at Change
//  passphrase's vault-verify arm (`notes/plans/fixes/vx-529-pair-catchup.md`).
//  The VX-510 repro (unit C, 22:36–22:46): the account's passphrase changed on
//  one Mac; on the lagging library Change passphrase old → new refused "That
//  passphrase doesn't open this library." — false: the old passphrase DOES open
//  this library. The mechanism: a synced library verifies the typed current
//  passphrase against the VAULT, where the old one no longer opens, and the arm
//  threw the plain refusal. Split: opens this library but not the vault ⇒
//  VX-113's `passphraseChangedElsewhere` (the vault's last writer and day);
//  opens neither ⇒ the plain refusal.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-529 scope 3 — Change passphrase after the account's passphrase changed elsewhere says so")
struct PairRefusalSplitTests {
    /// Two devices of one account; the first changes the account's passphrase through its own door. The second lags:
    /// its key file still carries the account's passphrase as it last knew it (rule 7's one pair, fact 1).
    static func laggingPair(_ mode: ProtectionMode) async throws -> (mac: EX, air: EX, vault: VaultSnapshot) {
        let mac = try EX(mode, synced: true, gate: mode == .castle ? .alwaysAsk : nil)
        let air = try EX(mode, synced: true, gate: mode == .castle ? .alwaysAsk : nil, joining: mac)
        let executor = mac.executor()
        var library = try mac.unlocked(executor)
        _ = try await executor.changePassphrase(&library, current: mac.passphrase, new: "a passphrase made on the other Mac")
        let vault = try #require(mac.world.server.snapshot(mac.account!))
        return (mac, air, vault)
    }

    /// RED ON THE PRE-FIX TREE (it threw `passphraseDoesNotOpen`): the old passphrase opens this library — and the
    /// door names the change, writing nothing.
    @Test(arguments: ProtectionMode.allCases)
    func theOldPassphraseThatOpensTheLibraryButNotTheVaultNamesTheChange(_ mode: ProtectionMode) async throws {
        let (_, air, vault) = try await Self.laggingPair(mode)
        let live = try #require(air.world.liveFormat3)
        #expect(try live.open(passphrase: .passphrase(air.passphrase), floor: PF.floor) == air.key,
                "the fixture: the old passphrase opens this library")
        #expect(live.passphrase?.kdf != vault.vault.kdf, "the fixture: the account's passphrase changed elsewhere")
        let executor = air.executor()
        var library = try air.unlocked(executor)
        air.world.writes = []
        await #expect(throws: ExecutorRefusal.passphraseChangedElsewhere(device: "Mac A", day: vault.updatedAt)) {
            _ = try await executor.changePassphrase(&library, current: air.passphrase, new: "a newer passphrase still")
        }
        #expect(air.world.writes.isEmpty, "the refused door wrote \(air.world.writeLog())")
        #expect(library.section.actInFlight == nil)
    }

    /// A passphrase that opens neither this library nor the account keeps the plain refusal.
    @Test(arguments: ProtectionMode.allCases)
    func aPassphraseThatOpensNeitherKeepsThePlainRefusal(_ mode: ProtectionMode) async throws {
        let (_, air, _) = try await Self.laggingPair(mode)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        air.world.writes = []
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await executor.changePassphrase(&library, current: "not any passphrase of hers", new: "a newer passphrase still")
        }
        #expect(air.world.writes.isEmpty)
    }

    /// With nothing changed elsewhere, a wrong passphrase is the plain refusal too (the split never names a change
    /// that didn't happen: the library's lock is the vault's descriptor, so nothing opens one and not the other).
    @Test func withNothingChangedElsewhereAWrongPassphraseIsThePlainRefusal() async throws {
        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await executor.changePassphrase(&library, current: "not any passphrase of hers", new: "a newer passphrase still")
        }
    }
}
