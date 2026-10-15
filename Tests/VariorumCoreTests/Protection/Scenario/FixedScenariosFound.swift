//
//  FixedScenariosFound.swift
//  VariorumCoreTests — VX-305 U4: the generator's findings, each pinned as a
//  fixed scenario at its minimal sequence (the seed that found it named), red
//  on the tree before its fix.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U4 fixed — what the generator found")
struct GeneratorFoundScenarios {
    static func start(_ named: String, seed: UInt64) throws -> SWorld {
        let world = SWorld(seed: seed)
        try StartingState.all.first { "\($0)".contains(named) }!.build(world)
        return world
    }

    /// Seed 7 (P-U4-9): a Mac in Castle replaced without its memory item,
    /// its predecessor's retirement of the old shared key lost with the old
    /// keychain; another library's Use Castle on the same Apple account then
    /// deletes the key in iCloud — the replacement, its switch off, must
    /// still know the key was retired here and delete it on sight.
    @Test func aReplacementMacKnowsTheOldSharedKeyWasRetired() async throws {
        let world = try Self.start("a stuck VX-235 marker", seed: 7000032)
        for action in [Action.createLibrary("macB", secrets: true), .useCastle("macA", .alwaysAsk, newWords: false),
                       .replaceMac("macA", carriesMemory: false), .iCloudOff("macA"), .launch("macA"),
                       .useCastle("macB", .touchID, newWords: false)] {
            await world.step(action)
        }
        #expect(world.macA.library?.section.oldSharedKey?.retiredAt != nil, "the replacement doesn't know the old key was retired")
        expectPromisesKept(world)
    }

    /// Seed 9: a device replaced without its memory item while the account
    /// replaced its keys elsewhere — the follow is owed (read from the
    /// library's master words copy), and the key doors wait for it.
    @Test func aReplacedDeviceFollowsBeforeItsKeyDoors() async throws {
        let world = try Self.start("a synced Castle account on two Macs and the phone", seed: 9000034)
        for action in [Action.settle, .replaceAllKeys("macA", newWords: true), .replaceMac("phone", carriesMemory: false)] {
            await world.step(action)
        }
        let regenerate = await world.step(.regenerateWords("phone"))
        #expect(regenerate != .done, "a key door ran on a library behind the account's keys")
        await world.done([.settle])
        expectPromisesKept(world)
    }

    /// Seed 9 (P-U4-4 refined): a synced Standard device whose keychain was
    /// wiped before its first open on this build — no silent item, so the
    /// custody shape alone reads Castle; with an Apple wrap on its key file,
    /// the migration takes the vault's Standard.
    @Test func aWipedKeychainBeforeTheMigrationKeepsStandard() async throws {
        let world = try Self.start("a device that joined without a secret", seed: 9000035)
        await world.step(.wipeKeychain("macA"))
        await world.step(.crash(.setScheduledExport("macA", true), afterWrites: 23))
        await world.done([.launch("macA")])
        #expect(world.macA.slot?.record?.mode == .standard, "the migration read a wiped keychain as Castle")
        expectPromisesKept(world)
    }

    /// Seed 9: a leave crashed mid-act; the account's passphrase changed on
    /// another device meanwhile; at the resume she types the new one — the
    /// resume refuses it (one descriptor names one passphrase), and finishes
    /// with the one that opens her library.
    @Test func aResumeRefusesAPassphraseThePressNeverTyped() async throws {
        let world = try Self.start("a synced Castle account on two Macs and the phone", seed: 9000034)
        let account = try #require(world.macB.slot?.rowsOwner ?? world.macB.slot?.record?.account)
        await world.step(.crash(.stopSyncingHere("macB", forgotPassphrase: false), afterWrites: 9))
        await world.done([.changePassphrase("macA")])
        let changed = try #require(world.known(account).passphrase)
        _ = try? await world.launch(world.macB, typed: TypedSecrets(passphrase: changed, words: world.known(account).words))
        if let wrap = world.liveKeyFile(world.macB)?.passphrase, let pk = world.passphraseKey(changed, wrap.kdf) {
            #expect(Lock.unwrap(wrap.wrapped, under: pk.key) == nil, "the resume locked the new key under a passphrase the press never typed")
        }
        world.lock(world.macB)
        await world.done([.launch("macB"), .settle])
        expectPromisesKept(world)
    }
}
