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
    /// Seed 10: the account enters Castle on another device; a device that
    /// hasn't followed yet presses Re-link for the account — it must refuse
    /// (follow first), never land an Apple copy over the Castle-era master.
    @Test func aStaleDeviceNeverRelinksACastleAccount() async throws {
        let world = try Self.start("a device that joined without a secret", seed: 10000048)
        await world.step(.useCastle("phone", .touchID, newWords: false))
        let relink = await world.step(.relinkAccount("macA"))
        #expect(relink != .done, "a stale device re-linked an account in Castle")
        await world.done([.settle])
        expectPromisesKept(world)
    }

    /// Seed 10: a phone's forgotten-passphrase reset moved the account's
    /// passphrase; a Mac's Use Castle (synced) then crashed twice — the
    /// resume must take the passphrase that opens the vault, never the old one
    /// under the vault's descriptor.
    @Test func aSyncedResumeTakesThePassphraseThatOpensTheVault() async throws {
        let world = try Self.start("a device that joined without a secret", seed: 10000043)
        await world.step(.resetPassphrase("phone", .touchID))
        await world.step(.crash(.useCastle("macA", .touchID, newWords: false), afterWrites: 10))
        let account = try #require(world.macA.slot?.record?.account ?? world.macA.slot?.rowsOwner)
        let old = try #require(world.known(account).timeline.first?.passphrase)
        // She types her library's old passphrase at the resume.
        _ = try? await world.launch(world.macA, typed: TypedSecrets(passphrase: old, words: world.known(account).words))
        if let vault = world.server.snapshot(account), let wrap = world.liveKeyFile(world.macA)?.passphrase, wrap.kdf == vault.format.kdf,
           let pk = world.passphraseKey(old, wrap.kdf) {
            #expect(Lock.unwrap(wrap.wrapped, under: pk.key) == nil, "a lock under the vault's descriptor opens with a passphrase the vault refuses")
        }
        world.lock(world.macA)
        await world.done([.launch("macA"), .settle])
        expectPromisesKept(world)
    }
    /// Seed 11 (§3.13 step 1): a device opens on this build offline — its
    /// mode recorded unconfirmed — while the account leaves Castle elsewhere;
    /// once online, the vault's word is an ordinary follow (a key change by
    /// the follow's road), never a confirm nothing offers.
    @Test func aDeviceMigratedOfflineFollowsOnceOnline() async throws {
        let world = try Self.start("a synced Castle account on two Macs and the phone", seed: 11000072)
        for action in [Action.goOffline("macB"), .useStandard("phone"), .settle, .goOnline("macB")] { await world.step(action) }
        await world.done([.settle])
        #expect(world.macB.slot?.record?.mode == .standard, "the device migrated offline never followed")
        expectPromisesKept(world)
    }
    /// Seed 12 (promise 10, P-U4-6): a Castle library sets up sync (the key
    /// stays — joining is no crossing); its library file from before is
    /// replayed alone — under the same key — and must not take the account
    /// away: this Mac's newer section in the memory names the facts it
    /// confirmed.
    @Test func aLibraryFileReplayedFromBeforeAJoinChangesNothing() async throws {
        let world = try Self.start("two Macs sharing an iCloud Drive", seed: 12000053)
        await world.step(.signIn("macB", account: "00000000-0000-4000-8000-000000000000"))
        await world.step(.crash(.turnOnSync("macB"), afterWrites: 23))
        await world.done([.launch("macB")])
        let account = try #require(world.macB.slot?.record?.account)
        await world.step(.tamper("macB", .replayLibraryFile))
        #expect(world.macB.slot?.record?.account == account, "a replayed library file took the account away")
        expectPromisesKept(world)
    }
    /// Seed 16: This Mac Only into Standard crashed mid-act; its resume must
    /// finish — the new key's Apple wrap is a local library's (decision 35
    /// reads the vault for a SYNCED library's writes), so no vault read holds
    /// it up.
    @Test func aCrashedThisMacOnlyIntoStandardFinishes() async throws {
        let world = try Self.start("a synced Castle account on two Macs and the phone", seed: 16000094)
        await world.step(.crash(.thisMacOnly("macA", .standard), afterWrites: 12))
        await world.done([.launch("macA")])
        #expect(world.macA.library?.section.actInFlight == nil, "the leave stuck in flight")
        expectPromisesKept(world)
    }

    /// Seed 16: a Mac replaced in the middle of Use Castle (its memory item
    /// carried) — the new identity can't resume its predecessor's act, and
    /// the new key's file left in the live place goes back to the mirror's.
    @Test func aMacReplacedMidUseCastleGetsItsKeyFileBack() async throws {
        let world = try Self.start("Standard-waiting", seed: 16000087)
        await world.step(.createLibrary("macB", secrets: true))
        await world.step(.crash(.useCastle("macB", .alwaysAsk, newWords: false), afterWrites: 7))
        await world.done([.replaceMac("macB", carriesMemory: true), .settle])
        #expect(world.liveKeyFile(world.macB)?.fingerprint == world.macB.slot?.fingerprint, "another key's file stayed live")
        expectPromisesKept(world)
    }
    /// Seed 16: the same crashed leave, then the Mac signs back into its
    /// Apple ID (its keychain's un-uploaded own key lost) — the resume mints
    /// a fresh own key and finishes.
    @Test func aCrashedLeaveWhoseOwnKeyWasLostFinishes() async throws {
        let world = try Self.start("a synced Castle account on two Macs and the phone", seed: 16000094)
        await world.step(.crash(.thisMacOnly("macA", .standard), afterWrites: 12))
        await world.step(.switchAppleID("macA", to: SWorld.appleA))
        await world.done([.launch("macA"), .settle])
        #expect(world.macA.library?.section.actInFlight == nil, "the leave stuck on its lost Apple key")
        expectPromisesKept(world)
    }
    /// Seed 19: a Mac whose own library is synced (signed out) lands a local
    /// pair from another Mac — the landing's Apple write is the landed local
    /// library's, never held up by the outgoing library's account; it
    /// finishes whole.
    @Test func aLocalPairLandsBesideASyncedLibrary() async throws {
        let world = try Self.start("signed out with keys (Standard, synced)", seed: 19000060)
        await world.done([.createLibrary("macB", secrets: true), .sendLibrary(from: "macB", to: "macA"),
                          .land("macA", .passphraseWordsTyped)])
        #expect(world.macA.library?.section.actInFlight == nil)
        expectPromisesKept(world)
    }
    /// Seed 19: Use Standard crashed after its rotation's first write (the
    /// vault names the actor's fresh account key, not yet carried by iCloud
    /// Keychain); the actor's keychain is then wiped — its resume can't wait
    /// for a key that no longer exists anywhere, so it mints afresh and
    /// completes the leave.
    @Test func anActorWhoseNamedKeyWasLostFinishesItsLeave() async throws {
        let world = try Self.start("a synced Castle account on two Macs and the phone", seed: 19000097)
        await world.step(.crash(.useStandard("macA"), afterWrites: 15))
        await world.done([.wipeKeychain("macA"), .launch("macA")])
        #expect(world.macA.library?.section.actInFlight == nil, "the actor's leave waited for a key that no longer exists")
        let account = try #require(world.macA.slot?.record?.account)
        #expect(world.server.snapshot(account)?.format.masterWrappedByAppleHeld != nil)
        expectPromisesKept(world)
    }
    /// Seed 20: a device that never followed the account out of Castle has
    /// its keychain wiped (its memory's vault facts with it), picks up the
    /// account's current keys for the session, and the account then returns
    /// to Castle — its library's master is none the account names: the
    /// follow is owed and the world converges.
    @Test func aWipedDeviceBehindTheAccountStillFollows() async throws {
        let world = try Self.start("a synced Castle account on two Macs and the phone", seed: 20000071)
        for action in [Action.useStandard("macA"), .launch("macB"), .wipeKeychain("macB"), .turnOnSync("macB"),
                       .useCastle("macA", .alwaysAsk, newWords: false)] {
            await world.step(action)
        }
        await world.done([.settle])
        expectPromisesKept(world)
    }
}
