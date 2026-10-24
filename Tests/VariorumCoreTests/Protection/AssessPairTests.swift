//
//  AssessPairTests.swift
//  VariorumCoreTests — VX-529 unit 1, scope 1: DETECTION — a pair changed
//  elsewhere (`notes/plans/fixes/vx-529-pair-catchup.md`, design §1). With a
//  fresh vault read for the library's account, the same posture and the same
//  sync key, the key file's passphrase lock under another descriptor than the
//  vault's, or its master's twelve-words copy other than the vault's recovery
//  wrap, owes the follow's third kind — and the `followOwed` gate then closes
//  every key and mode door (the repro's false Change-passphrase refusal class,
//  closed structurally).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A synced library as `assess` reads it: its key file carries the account's pair as this library last knew it — the
/// passphrase lock and the master with its twelve-words copy — and the vault's reading carries both halves as they stand
/// (`VaultSnapshot.reading`'s `kdf` and `recoveryWrap`). With nothing moved, they agree.
func pairWorld(_ mode: ProtectionMode) throws -> (AWorld, String) {
    let x = PF.id()
    var world = try AWorld(mode, account: x)
    world.session = .signedIn(accountID: x, email: nil)
    let copy = try world.world.masterWordsCopy
    world.liveFile = try world.liveFile.settingMaster(world.world.master, wordsCopy: copy, for: world.key)
    world.vault = VaultReading(
        accountID: x, mode: mode, rowKeyID: "c1", kdf: try #require(world.liveFile.passphrase).kdf, recoveryWrap: copy,
        updatedByDevice: "Lillian's Air", updatedAt: CF.stamp(9))
    return (world, x)
}

/// The account's passphrase re-made elsewhere: the vault's lock under a fresh descriptor (a new passphrase always takes
/// one — U2's hand-forward).
func passphraseMovedElsewhere(_ world: inout AWorld) { world.vault?.kdf = PF.fastKDF() }

/// The account's words re-made elsewhere: the vault's recovery wrap is the master under other words.
func wordsMovedElsewhere(_ world: inout AWorld) throws {
    let other = try AES.KeyWrap.wrap(world.world.master, using: try PF.wordsKey(try PF.words()).key)
    world.vault?.recoveryWrap = other
}

func owesAFollow(_ assessed: Assessment) -> Bool {
    assessed.acts.contains { if case .follow = $0 { return true } else { return false } }
}

@Suite("VX-529 scope 1 — RED ON OLD: a pair changed elsewhere owes a follow, and the key doors refuse until it lands")
struct AssessPairRedPins {
    /// The no-follow-offered class (the VX-510 repro: "Settings ▸ Sync offers NO follow") and the false-refusal class
    /// ("Change passphrase old → new refuses 'That passphrase doesn't open this library.'") — closed by detection.
    @Test(arguments: ProtectionMode.allCases)
    func aPassphraseChangedElsewhereOwesAFollowAndTheKeyDoorsRefuse(_ mode: ProtectionMode) throws {
        var (world, _) = try pairWorld(mode)
        passphraseMovedElsewhere(&world)
        let assessed = try world.assessed()
        #expect(owesAFollow(assessed), "no follow offered for a passphrase changed elsewhere (\(mode))")
        #expect(assessed.door(.followNow).isOpen)
        #expect(assessed.door(.changePassphrase).refusal == .followOwed, "Change passphrase stays open (\(mode))")
    }

    @Test(arguments: ProtectionMode.allCases)
    func wordsChangedElsewhereOweAFollowAndTheKeyDoorsRefuse(_ mode: ProtectionMode) throws {
        var (world, _) = try pairWorld(mode)
        try wordsMovedElsewhere(&world)
        let assessed = try world.assessed()
        #expect(owesAFollow(assessed), "no follow offered for words changed elsewhere (\(mode))")
        #expect(assessed.door(.followNow).isOpen)
        #expect(assessed.door(.newWords).refusal == .followOwed, "New words stays open (\(mode))")
    }

    /// The guard row, green on both trees: with nothing moved, nothing is owed and the key doors stand open.
    @Test(arguments: ProtectionMode.allCases)
    func withNothingMovedNothingIsOwed(_ mode: ProtectionMode) throws {
        let (world, _) = try pairWorld(mode)
        let assessed = try world.assessed()
        #expect(!owesAFollow(assessed))
        #expect(assessed.door(.changePassphrase).isOpen && assessed.door(.newWords).isOpen)
        #expect(assessed.door(.followNow).refusal == .nothingToDo)
    }
}
