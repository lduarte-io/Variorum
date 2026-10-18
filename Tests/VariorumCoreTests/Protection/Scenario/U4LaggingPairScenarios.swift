//
//  U4LaggingPairScenarios.swift
//  VariorumCoreTests — VX-378 U4, THE DISCOVERY RUN'S DESIGN FIND (seed 21
//  sequence 83 — P-VX378-U4-3), RULED at the U4 stop (2026-10-17): THE PROMISE
//  SHRINKS TO THE FLOOR. Her words: "let's shrink our promise to "can always
//  open with the keys that were their keys when you made them". and as a
//  niceity we like to carry them forward." The vault does NOT keep earlier
//  masters. A device that lagged while the account changed BOTH secrets and
//  entered Castle (a new master) holds a key file no secret of TODAY opens; it
//  opens with the secrets of its last sync (rule 4: "A backup always opens with
//  the passphrase and words you had when you made it"), then follows, typing
//  one secret, and catches up (rule 12: "types a secret once to catch up,
//  today's or the one it had when it last synced"). Before her ruling this was
//  a known issue (`withKnownIssue`); it is now the floor, asserted.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U4 — P-VX378-U4-3 RULED: a device that lagged through both secrets changing and a new master keeps the floor")
struct U4LaggingPairScenarios {
    @Test func aLaggingDeviceOpensWithItsLastSyncSecretsThenCatchesUpWithOneSecret() async throws {
        let (world, account) = try await syncedWorld(.castle, devices: ["macA", "macB"], gate: .alwaysAsk)
        let then = world.known(account)
        await world.done([.launch("macA"), .useStandard("macA"), .regenerateWords("macA"),
                          .useCastle("macA", .alwaysAsk, newWords: false), .useStandard("macA"),
                          .resetPassphrase("macA", .plainConfirm)])
        let today = world.known(account)
        #expect(today.passphrase != then.passphrase && today.words != then.words)
        let live = try #require(world.liveKeyFile(world.macB))
        // Today's secrets open nothing here — typed, or through the vault, which
        // keeps no earlier master (her ruling: the floor, not a new mechanism).
        let typedOpens = [ProtectionSecret.passphrase(today.passphrase!), .words(today.words!)]
            .contains { (try? live.open($0, floor: PF.floor)) != nil }
        let vault = try #require(world.server.snapshot(account))
        let pk = try #require(world.passphraseKey(today.passphrase!, vault.vault.kdf))
        let master = try #require(vault.vault.master(passphrase: pk, words: nil))
        #expect(!typedOpens && (try? live.open(master: master)) == nil)
        // THE FLOOR: the secrets of its last sync open it.
        #expect((try? live.open(.passphrase(then.passphrase!), floor: PF.floor)) != nil)
        #expect((try? live.open(.words(then.words!), floor: PF.floor)) != nil)
        // She types today's (nothing opens, Always ask), then the pair it had
        // when it last synced: it opens (rule 12).
        #expect(await world.step(.launch("macB")) == .done)
        #expect(world.macB.isOpen)
        // It owes the follow, which types ONE secret (today's — the follow reads
        // the account's vault), and catches up.
        #expect(world.owedFollow(world.macB) != nil)
        #expect(await world.step(.follow("macB", .passphrase)) == .done)
        let caughtUp = try #require(world.liveKeyFile(world.macB))
        #expect(world.macB.slot?.record?.mode == .standard && world.macB.slot?.record?.accountRowKeyID == vault.rowKeyID)
        #expect((try? caughtUp.open(.passphrase(today.passphrase!), floor: PF.floor)) != nil, "today's passphrase doesn't open the caught-up library")
        // Every key change carries the earlier keys forward: the caught-up key
        // file holds the key it lagged under.
        #expect(caughtUp.heldFingerprints.contains(live.fingerprint))
        expectPromisesKept(world)
    }

    /// With the master unchanged, today's passphrase opens the lagging key file
    /// through the vault's master (the vault road), and the device opens.
    @Test func withTheMasterUnchangedTheVaultRoadOpensIt() async throws {
        let (world, account) = try await syncedWorld(.castle, devices: ["macA", "macB"], gate: .alwaysAsk)
        await world.done([.launch("macA"), .regenerateWords("macA"), .changePassphrase("macA")])
        let today = world.known(account)
        let live = try #require(world.liveKeyFile(world.macB))
        let vault = try #require(world.server.snapshot(account))
        let pk = try #require(world.passphraseKey(today.passphrase!, vault.vault.kdf))
        let master = try #require(vault.vault.master(passphrase: pk, words: nil))
        #expect((try? live.open(master: master)) != nil)
        await world.done([.launch("macB")])
        expectPromisesKept(world)
    }
}
