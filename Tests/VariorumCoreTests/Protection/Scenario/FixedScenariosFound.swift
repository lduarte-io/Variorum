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
    /// Seed 1 (sequence 662): Use Castle crashed past its commit point, then
    /// the device was replaced (memory carried) — the new identity can't
    /// resume its predecessor's act, so the entry's last step (retiring every
    /// own Apple key) never ran; the Castle repairs retire them, and the
    /// pre-Castle copies stop opening through the Apple account.
    @Test func aReplacementFinishesUseCastlesRetirement() async throws {
        let world = try Self.start("two Macs sharing an iCloud Drive", seed: 1000665)
        for action in [Action.createLibrary("phone", secrets: true), .syncICloud("phone"), .backup("phone"),
                       .crash(.useCastle("phone", .touchID, newWords: false), afterWrites: 20)] {
            await world.step(action)
        }
        await world.done([.replaceMac("phone", carriesMemory: true), .settle])
        #expect(world.phone.library?.section.ownLibraryAppleKeyIDsToRetire.isEmpty == true)
        expectPromisesKept(world)
    }
    /// Seed 1 (sequence 772): landing a synced Standard pair — it lands held,
    /// writing nothing Apple-reachable until Resume Sync reads its account's
    /// vault; a crash mid-landing then settles (before its commit point it
    /// rolls back — the pair's key is never stored), never stuck on a read the
    /// held landing can't make; landed whole on a second press.
    @Test func aSyncedStandardPairLandsHeldAndFinishes() async throws {
        let world = try Self.start("a device that joined without a secret", seed: 1000775)
        await world.step(.createLibrary("macB", secrets: true))
        await world.step(.sendLibrary(from: "macA", to: "macB"))
        await world.step(.crash(.land("macB", .passphraseWordsMadeNew), afterWrites: 8))
        await world.done([.launch("macB")])
        #expect(world.macB.library?.section.actInFlight == nil, "the landing stuck in flight")
        await world.done([.land("macB", .passphraseWordsMadeNew)])
        #expect(world.macB.slot?.record?.account != nil && world.liveKeyFile(world.macB)?.apple == nil,
                "a held landing wrote an Apple wrap")
        expectPromisesKept(world)
    }
    /// Seed 1 (sequence 852): a Time Machine snapshot of today's files, Use
    /// Castle (synced), then the rollback — today's library comes back with
    /// its Standard key (Apple-wrapped) while the account reads Castle and the
    /// Castle sweep took today's silent item: the migration records the key's
    /// Standard birth and owes the follow, never "Castle" over an Apple wrap.
    @Test func aRollbackPastUseCastleToTodaysFilesKeepsTheKeysBirth() async throws {
        let world = try Self.start("a device that joined without a secret", seed: 1000855)
        await world.done([.timeMachineSnapshot("macA"), .useCastle("macA", .touchID, newWords: false), .timeMachineRollback("macA"),
                          .launch("macA")])
        #expect(world.macA.slot?.record?.mode == .standard, "an Apple-wrapped key recorded Castle")
        await world.done([.settle])
        #expect(world.macA.slot?.record?.mode == .castle, "the follow never came")
        expectPromisesKept(world)
    }
    /// Seed 1 (sequence 854): Use Standard (synced) crashed before its first
    /// vault write; the account's passphrase then changed on another device —
    /// the resume's first write finds the passphrase no longer opens the vault
    /// and rolls back (the account moved before this device's first write).
    @Test func aLeaveCrashedBeforeItsFirstWriteRollsBackWhenTheAccountMoved() async throws {
        let world = try Self.start("a synced Castle account on two Macs and the phone", seed: 1000857)
        await world.step(.crash(.useStandard("phone"), afterWrites: 7))
        await world.done([.changePassphrase("macA"), .launch("phone")])
        #expect(world.phone.library?.section.actInFlight == nil, "the leave stuck in flight")
        await world.done([.settle])
        expectPromisesKept(world)
    }

    /// Seed 2 (sequence 432) — HER RULING 2026-10-14/15: a synced leave
    /// crashed PAST its rotation's first write (here past the completing write
    /// too: the account reads Standard, the library still under its Castle
    /// key), then signed out. It STAYS IN FLIGHT, named and waiting: the
    /// library opens, sync waits, copies stay paused (a backup refused), a door
    /// refuses with the act named — and it finishes at the next vault reach,
    /// signing in here. (Promise 6's vault-reach qualifier; the face, "Finish
    /// leaving Castle — sign in to finish", is phase 3/4's.)
    @Test func aSyncedLeaveCrashedPastItsFirstWriteWaitsForTheVault() async throws {
        let world = try Self.start("a phone on an older build beside a synced Castle Mac", seed: 2000438)
        let account = try #require(world.macA.slot?.rowsOwner)
        await world.step(.crash(.useStandard("macA"), afterWrites: 21))
        await world.step(.signOut("macA"))
        let gate = await world.step(.setGate("macA", .alwaysAsk))
        #expect(gate == .refused(String(describing: ExecutorRefusal.actInFlight(.leaveCastle))))
        #expect(world.macA.isOpen, "the library didn't open")
        #expect(world.macA.lastSettle == .waiting(.leaveCastle, account: account), "the leave isn't named and waiting")
        #expect(world.macA.library?.section.actInFlight?.act == .leaveCastle)
        let backup = await world.step(.backup("macA"))
        #expect(backup != .done && world.macA.paused, "copies ran while the leave waited")
        expectPromisesKept(world, "while it waits")
        await world.done([.signIn("macA", account: account)])
        #expect(world.macA.library?.section.actInFlight == nil, "the leave didn't finish at the vault reach")
        #expect(world.macA.slot?.record?.mode == .standard && !world.macA.paused)
        await world.done([.settle])
        expectPromisesKept(world)
    }

    /// Her ruling, "or another device": the leave crashed just past its
    /// rotation's first write (the vault names the leave's key, no wrap yet),
    /// the actor signed out; another device of the account finishes the leave
    /// (it reads the named key) while the actor waits, named — and the actor,
    /// signing in, finishes its own library's re-key.
    @Test func aWaitingLeaveIsFinishedByAnotherDeviceThenAtSignIn() async throws {
        let (clean, _) = try syncedWorld(.castle, devices: ["macA", "macB"])
        await clean.done([.launch("macA")])
        let begin = clean.stepLog.count
        await clean.done([.useStandard("macA")])
        let writes = clean.stepLog[begin...].filter { $0.contains("✎") }
        let firstVault = try #require(writes.firstIndex { $0.contains("✎ vault") })
        let (world, account) = try syncedWorld(.castle, devices: ["macA", "macB"])
        await world.done([.launch("macA"), .launch("macB")])
        await world.step(.crash(.useStandard("macA"), afterWrites: firstVault + 1))
        #expect(world.server.snapshot(account)?.format.appleKeyID != nil
                && world.server.snapshot(account)?.format.masterWrappedByAppleHeld == nil, "the vault doesn't read a leave in progress")
        await world.done([.signOut("macA"), .launch("macA")])
        #expect(world.macA.lastSettle == .waiting(.leaveCastle, account: account))
        await world.done([.settle])
        #expect(world.server.snapshot(account)?.format.masterWrappedByAppleHeld != nil, "another device didn't finish the leave")
        #expect(world.macA.library?.section.actInFlight?.act == .leaveCastle, "the actor's own re-key isn't still waiting")
        await world.done([.signIn("macA", account: account), .settle])
        #expect(world.macA.library?.section.actInFlight == nil && world.macA.slot?.record?.mode == .standard)
        expectPromisesKept(world)
    }

    /// Her ruling's other half: a synced leave crashed BEFORE its rotation's
    /// first write (the account key minted, its stamp not yet in the plan),
    /// then signed out — at the open it ROLLS BACK: still Castle under its
    /// key, the vault untouched, nothing waiting. (Red on the tree before: the
    /// resume read and rotated the vault while signed out, then stuck at the
    /// Apple write, in flight past a commit point it should never have
    /// crossed.)
    @Test func aSyncedLeaveCrashedBeforeItsFirstWriteRollsBackWhileSignedOut() async throws {
        let clean = try Self.start("a phone on an older build beside a synced Castle Mac", seed: 2000438)
        await clean.done([.launch("macA")])
        let begin = clean.stepLog.count
        await clean.done([.useStandard("macA")])
        let writes = clean.stepLog[begin...].filter { $0.contains("✎") }
        let firstVault = try #require(writes.firstIndex { $0.contains("✎ vault") })
        #expect(firstVault >= 2 && writes[firstVault - 1].contains("✎ plan"), "the stamp's plan write precedes the first vault write")
        let world = try Self.start("a phone on an older build beside a synced Castle Mac", seed: 2000438)
        let account = try #require(world.macA.slot?.rowsOwner)
        await world.done([.launch("macA")])
        let before = try #require(world.server.snapshot(account))
        let key = world.macA.slot?.fingerprint
        await world.step(.crash(.useStandard("macA"), afterWrites: firstVault - 1))
        await world.done([.signOut("macA"), .launch("macA")])
        #expect(world.macA.lastSettle == .rolledBack(.leaveCastle), "the leave didn't roll back")
        #expect(world.macA.library?.section.actInFlight == nil && !world.macA.paused)
        #expect(world.macA.slot?.record?.mode == .castle && world.macA.slot?.fingerprint == key)
        #expect(world.server.snapshot(account)?.revision == before.revision, "the vault was written while signed out")
        await world.done([.signIn("macA", account: account), .settle])
        expectPromisesKept(world)
    }

    /// Her ruling: while the act waits, copies STAY PAUSED — also when the
    /// crash fell after the prepare's pause was recorded done, so the resume
    /// starts past it (the pause is the process's and the crash took it). Red
    /// on the tree before: the waiting leave left copies running, and a
    /// backup pair of the Castle-era library was taken mid-act.
    @Test func copiesStayPausedWhileAnActWaitsAcrossARelaunch() async throws {
        let world = try Self.start("a phone on an older build beside a synced Castle Mac", seed: 2000438)
        let account = try #require(world.macA.slot?.rowsOwner)
        await world.step(.crash(.useStandard("macA"), afterWrites: 22))
        await world.done([.signOut("macA"), .launch("macA")])
        #expect(world.macA.lastSettle == .waiting(.leaveCastle, account: account))
        #expect(world.macA.paused, "copies run while the leave waits")
        let backup = await world.step(.backup("macA"))
        #expect(backup != .done, "a backup was taken while the leave waited")
        expectPromisesKept(world, "while it waits")
        await world.done([.signIn("macA", account: account), .settle])
        #expect(world.macA.library?.section.actInFlight == nil && !world.macA.paused)
        expectPromisesKept(world)
    }
}

extension GeneratorFoundScenarios {
    /// Seed 5 (sequence 5, the closer's 60-sequence sweep) — a WORLD finding:
    /// a synced pair landed with the passphrase made new, crashed after its
    /// swap; the world recorded her choice before the act's own opening, which
    /// dropped it as a rolled-back act's — her truth lost the passphrase the
    /// landed key file is under, and the backup's "your passphrase" line read
    /// as a lie (promise 9). The choice is now made inside the act.
    @Test func aCrashedLandingsMadeNewPassphraseStaysHers() async throws {
        let world = try Self.start("a deleted account", seed: 5000020)
        for action in [Action.sendLibrary(from: "macA", to: "macB"), .createLibrary("macB", secrets: true),
                       .crash(.land("macB", .wordsPassphraseMadeNew), afterWrites: 15), .backup("macB")] {
            await world.step(action, words: true)
        }
        expectPromisesKept(world)
    }

    /// Seed 1 (sequence 180, the closer's soak): a local Standard pair's
    /// landing crashed between its record written into the staged file and
    /// the swap; the relaunch's resume swapped, then carried the OUTGOING
    /// library's device section into the landed library — this Mac's own
    /// Apple key for it (minted at the landing, listed in the landed section)
    /// read as nobody's, promise 3 broken. The resume takes this Mac's landed
    /// section from the swapped-in record, where the press wrote it.
    @Test func aLandingResumedAtItsSwapKeepsTheLandedSection() async throws {
        let world = try Self.start("exposed", seed: 1000183)
        for action in [Action.createLibrary("phone", secrets: true), .sendLibrary(from: "phone", to: "macA"),
                       .crash(.land("macA", .wordsPassphraseMadeNew), afterWrites: 14)] {
            await world.step(action)
        }
        await world.done([.settle])
        let landed = try #require(world.liveKeyFile(world.macA)?.apple?.keyID)
        #expect(world.macA.library?.section.appleKeys.contains { $0.id == landed && $0.isOwnLibraryKey } == true,
                "the landed library's section doesn't list this Mac's own key for it")
        expectPromisesKept(world)
    }

    /// Seed 1 (sequence 358, the closer's soak) — a CHECKER finding: Use
    /// Standard, a Time Machine snapshot, Use Castle, Use Standard again, then
    /// the rollback to the snapshot — the first Standard stretch's library and
    /// key file come back and the open believes them (P-U4-8, her restore);
    /// its own Apple key was retired at Use Castle, so Re-link's library arm
    /// re-wraps its key. That is the stated limit her 2026-10-14/15 ruling
    /// accepted for P-U4-5 (pre-Castle content, Apple-reachable in its day);
    /// the world now applies to a Time Machine restore the truth the two-home
    /// replay already did (PROVISIONAL P-U4-12).
    @Test func aTimeMachineRestorePastACastleStretchIsTheStatedLimit() async throws {
        let world = try Self.start("Castle with Touch ID, the old shared key with pre-Castle copies", seed: 1000361)
        for action in [Action.useStandard("macA"), .timeMachineSnapshot("macA"), .useCastle("macA", .touchID, newWords: false),
                       .useStandard("macA"), .timeMachineRollback("macA"), .settle] {
            await world.step(action, words: true)
        }
        expectPromisesKept(world)
    }

    /// Seed 1 (sequence 596, the closer's soak) — a CHECKER finding: a synced
    /// pair landed on a device signed into that same account lands HELD, with
    /// no Apple wrap until Resume Sync (§3.7's restore hold); promise 3 now
    /// waits for the press, as promise 7 already did — and after it, holds.
    @Test func aHeldLandingWaitsForResumeSyncBeforeStandardMeansStandard() async throws {
        let world = try Self.start("a synced Standard account, a device that joined without a secret", seed: 1000599)
        await world.done([.sendLibrary(from: "macA", to: "phone"), .land("phone", .passphraseWordsMadeNew), .settle])
        #expect(world.liveKeyFile(world.phone)?.apple == nil, "a held landing wrote an Apple wrap")
        await world.done([.resumeSync("phone"), .settle])
        #expect(world.liveKeyFile(world.phone)?.apple != nil, "Resume Sync didn't give the library its Apple road")
        expectPromisesKept(world)
    }

    /// Seed 2 (sequence 342, the closer's soak) — a CHECKER finding: the same
    /// held landing, crashed after its swap and finished by the relaunch — the
    /// world marked a landing held only when its press returned, so promise 3
    /// judged the resumed one. A synced pair is held from its press.
    @Test func aCrashedHeldLandingIsHeldWhenItsResumeFinishes() async throws {
        let world = try Self.start("a synced Castle account on two Macs and the phone", seed: 2000348)
        for action in [Action.useStandard("macA"), .sendLibrary(from: "macA", to: "macB"),
                       .crash(.land("macB", .wordsPassphraseMadeNew), afterWrites: 15), .settle] {
            await world.step(action)
        }
        #expect(world.liveKeyFile(world.macB)?.apple == nil, "a held landing wrote an Apple wrap")
        expectPromisesKept(world)
    }

    /// Seed 2 (sequence 647, the closer's soak): Use Castle crashed right
    /// after writing its new key file into the live place, then the Mac was
    /// REPLACED with no memory item (Migration Assistant never carries one) —
    /// the new identity rightly ignores its predecessor's act, but the
    /// outgoing key file lived only in the lost memory's mirror, so the live
    /// place kept a key file of a key the library never had and the Standard
    /// library had no Apple road (promise 3). The plan now carries the
    /// outgoing key file (sealed, no secret in it), and an open that meets a
    /// plan it won't resume restores the current key's file from it — the
    /// new identity taking over its wrap's key (§3.5) — before the plan goes.
    @Test func aMacReplacedMidUseCastleWithNoMemoryGetsItsKeyFileBack() async throws {
        let world = try Self.start("Standard-waiting", seed: 2000653)
        for action in [Action.createLibrary("macB", secrets: false),
                       .crash(.useCastle("macB", .alwaysAsk, newWords: false), afterWrites: 5),
                       .replaceMac("macB", carriesMemory: false), .settle] {
            await world.step(action)
        }
        #expect(world.liveKeyFile(world.macB)?.fingerprint == world.macB.slot?.fingerprint, "another key's file stayed live")
        expectPromisesKept(world)
    }
}
