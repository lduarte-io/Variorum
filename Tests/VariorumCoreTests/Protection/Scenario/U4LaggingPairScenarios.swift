//
//  U4LaggingPairScenarios.swift
//  VariorumCoreTests — VX-378 U4, THE DISCOVERY RUN'S DESIGN FIND (seed 21
//  sequence 83 — P-VX378-U4-3, STOPPED for her ruling): a device that lagged
//  while the account changed BOTH secrets and entered Castle (a new master)
//  holds a key file no secret of TODAY opens — its own locks are the pair of
//  its last follow, its master wrap is under a master the vault no longer
//  keeps (rule 15 keeps every earlier sync key, not earlier masters). Rule 4's
//  core sentence ("your current passphrase or words open every backup you have
//  ever made") and rule 12's "types a secret once to catch up" both fail there.
//  Recorded as a KNOWN ISSUE so the suite stays green while it waits on her;
//  `withKnownIssue` turns red the day the model closes it.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U4 — P-VX378-U4-3: a device that lagged through both secrets changing and a new master")
struct U4LaggingPairScenarios {
    @Test func todaysSecretsOpenALaggingDevicesLibraryAfterBothChangedAndANewMaster() async throws {
        let (world, account) = try await syncedWorld(.castle, devices: ["macA", "macB"], gate: .alwaysAsk)
        let then = world.known(account)
        await world.done([.launch("macA"), .useStandard("macA"), .regenerateWords("macA"),
                          .useCastle("macA", .alwaysAsk, newWords: false), .useStandard("macA"),
                          .resetPassphrase("macA", .plainConfirm)])
        let today = world.known(account)
        #expect(today.passphrase != then.passphrase && today.words != then.words)
        let live = try #require(world.liveKeyFile(world.macB))
        // Its own day's secrets still open it (promise 5 holds — nothing is lost).
        #expect((try? live.open(.passphrase(then.passphrase!), floor: PF.floor)) != nil)
        await withKnownIssue("P-VX378-U4-3: today's secrets open nothing on the lagging device") {
            let typedOpens = [ProtectionSecret.passphrase(today.passphrase!), .words(today.words!)]
                .contains { (try? live.open($0, floor: PF.floor)) != nil }
            let vault = try #require(world.server.snapshot(account))
            let pk = try #require(world.passphraseKey(today.passphrase!, vault.vault.kdf))
            let master = try #require(vault.vault.master(passphrase: pk, words: nil))
            let throughTheVault = (try? live.open(master: master)) != nil
            #expect(typedOpens || throughTheVault, "no secret of today opens the lagging device's key file")
            // …so the open itself fails with today's secrets (Always ask: no quiet road).
            let opened = await world.step(.launch("macB"))
            #expect(opened == .done, "the lagging device doesn't open with today's secrets")
        }
    }

    /// The condition is exactly BOTH secrets changed AND a new master: with the
    /// master unchanged, today's passphrase opens the lagging key file through
    /// the vault's master (the vault road), and the device opens.
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
