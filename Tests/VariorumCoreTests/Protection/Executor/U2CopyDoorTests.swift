//
//  U2CopyDoorTests.swift
//  VariorumCoreTests — VX-378 U2 piece H: RULE 17 (`notes/CastleRules.md`: "A
//  copy is a copy. Look inside: any copy … opens read-only with its own secrets
//  (or its own quiet road on this Mac). The app writes nothing … Make this my
//  library: one confirmed door. The copy takes the live place as a new library
//  — a fresh identity and a fresh key in the posture you are in now, under your
//  current pair — and your previous library steps aside whole into Previous
//  Libraries … You never leave Castle by opening something.") and rule 23's
//  fresh device ID. New API — the old tree's Land was a registry stub with no
//  entry (red by construction).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A copy planted in `fixture`'s container: its pair's catalog entries (with
/// the live key file's), and the world's file for it.
func plantCopy(
    _ fixture: EX, libraryID: String, key: StoreKey, keyFile: KeyFile, record: ProtectionRecord?, generation: Int = 42
) throws -> (CatalogCopy, Catalog) {
    let folders = CF.macFolder(libraryID, CF.macA)
    var entries = [
        CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(CF.stamp(1), key)),
        CatalogEntry(place: .container, folders: folders, name: CF.pairName(CF.stamp(1), key), bytes: try keyFile.encoded()),
    ]
    if let live = fixture.world.liveKeyFile {
        entries.append(CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try live.encoded()))
    }
    let catalog = Catalog.build(entries)
    let copy = try #require(catalog.copies.first)
    fixture.world.copies[copy.id] = ExecutorWorld.LibraryFile(fingerprint: PF.fp(key), record: record, generation: generation)
    return (copy, catalog)
}

@Suite("VX-378 U2 — rule 17: Look inside opens a copy read-only and writes NOTHING")
struct U2LookInsideTests {
    /// Her own Standard-era backup after she entered Castle: its quiet locks
    /// died at the entry; her current secrets open it through the history.
    /// With the crash switch armed at the first write, any write would crash.
    @Test func herOldBackupOpensWithHerSecretsAndNothingIsWritten() async throws {
        let fixture = try EX(.standard)
        let k0 = fixture.key, backupFile = try #require(fixture.world.liveKeyFile)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .alwaysAsk)
        let (copy, catalog) = try plantCopy(fixture, libraryID: fixture.libraryID, key: k0, keyFile: backupFile, record: nil)
        #expect(throws: ExecutorRefusal.copyDoesNotOpen, "a Castle library's old backup opened by a quiet road") {
            _ = try fixture.executor().lookInside(copy, in: catalog, quietRoads: .includingTouchID)
        }
        let before = (fixture.world.custody, fixture.world.memories, fixture.world.liveKeyFile)
        fixture.world.writes = []
        fixture.world.crashAfterWrites = 1
        let looked = try fixture.executor().lookInside(copy, in: catalog, typed: TypedSecrets(words: fixture.words), quietRoads: .includingTouchID)
        #expect(looked.key == k0)
        #expect(fixture.world.writes.isEmpty)
        #expect(fixture.world.custody == before.0 && fixture.world.memories == before.1 && fixture.world.liveKeyFile == before.2)
    }

    /// Someone else's library opens with ITS secrets — read-only, nothing written.
    @Test func someoneElsesLibraryOpensWithItsOwnSecrets() throws {
        let mine = try EX(.castle)
        let theirs = try EX(.standard)
        let (copy, catalog) = try plantCopy(
            mine, libraryID: theirs.libraryID, key: theirs.key, keyFile: try #require(theirs.world.liveKeyFile),
            record: theirs.liveRecord)
        mine.world.writes = []
        mine.world.crashAfterWrites = 1
        let looked = try mine.executor().lookInside(copy, in: catalog, typed: theirs.typed, quietRoads: .includingTouchID)
        #expect(looked.key == theirs.key && looked.road == .itsOwnSecrets)
        #expect(mine.world.writes.isEmpty)
        // (Every fixture types the same passphrase; the words are each its own.)
        #expect(throws: ExecutorRefusal.copyDoesNotOpen) {
            _ = try mine.executor().lookInside(copy, in: catalog, typed: TypedSecrets(words: mine.words), quietRoads: .includingTouchID)
        }
    }

    /// VX-306 ladder round 1, m2: a face's AUTOMATIC probe (`.withoutAPress`)
    /// never reads a Touch ID item — a copy only Touch ID holds on this Mac
    /// refuses it with no press; the deliberate press (`.includingTouchID` — the
    /// model's own door, rule 17's "its own quiet road on this Mac"; chosen
    /// explicitly since VX-307 U2c dropped the default) opens it by that road.
    @Test func theAutomaticProbeNeverPressesTouchIDAndAPressDoes() throws {
        let fixture = try EX(.castle, gate: .touchID)
        let (copy, catalog) = try plantCopy(
            fixture, libraryID: fixture.libraryID, key: fixture.key, keyFile: try #require(fixture.world.liveKeyFile),
            record: fixture.liveRecord)
        #expect(fixture.custody(.touchid, fixture.key) && !fixture.custody(.silent, fixture.key), "only Touch ID holds it")
        #expect(throws: ExecutorRefusal.copyDoesNotOpen) {
            _ = try fixture.executor().lookInside(copy, in: catalog, quietRoads: .withoutAPress)
        }
        #expect(fixture.world.touchIDPresses == 0, "the automatic probe pressed Touch ID")
        let pressed = try fixture.executor().lookInside(copy, in: catalog, quietRoads: .includingTouchID)
        #expect(pressed.road == .quietRoad(.touchID) && pressed.key == fixture.key)
        #expect(fixture.world.touchIDPresses == 1)
    }

    /// VX-307 U2c — the VX-306 ladder's round-2 NIT 2: the core's copy door
    /// carries NO prompting default — a caller that says nothing about the
    /// quiet roads does not compile, so the road that may raise a Touch ID
    /// prompt is never the one a caller gets by omission (the app's twin
    /// defaults to `.withoutAPress`; every core caller chooses). BY SOURCE: the
    /// declaration names `quietRoads: CopyQuietRoads` with nothing after it.
    @Test func theCoreCopyDoorCarriesNoPromptingDefault() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/VariorumCore/Protection/Executor/Acts/Copies.swift")
        let source = try String(contentsOf: url, encoding: .utf8)
        let start = try #require(source.range(of: "public func lookInside("))
        let end = try #require(source.range(of: ") throws -> LookedInside", range: start.upperBound..<source.endIndex))
        let signature = String(source[start.upperBound..<end.lowerBound])
        #expect(signature.contains("quietRoads: CopyQuietRoads"), "\(signature)")
        #expect(!signature.contains("quietRoads: CopyQuietRoads ="), "the core door defaults to a prompting road: \(signature)")
        #expect(!signature.contains(".includingTouchID"), "\(signature)")
    }

    /// Its own quiet road on this Mac: a backup under the current Standard key
    /// opens by the silent item that holds that key directly (rule 4).
    @Test func aBackupUnderTheCurrentKeyOpensByThisMacsQuietRoad() throws {
        let fixture = try EX(.standard)
        let (copy, catalog) = try plantCopy(
            fixture, libraryID: fixture.libraryID, key: fixture.key, keyFile: try #require(fixture.world.liveKeyFile),
            record: fixture.liveRecord)
        fixture.world.writes = []
        let looked = try fixture.executor().lookInside(copy, in: catalog, quietRoads: .includingTouchID)
        #expect(looked.road == .quietRoad(.thisMac) && fixture.world.writes.isEmpty)
    }
}

@Suite("VX-378 U2 — rule 17: Make this my library — a NEW library, the posture of now, the current pair")
struct U2MakeMineTests {
    @Test func aCopyBecomesANewLibraryInStandardUnderTheCurrentPair() async throws {
        let mine = try EX(.standard)
        let theirs = try EX(.castle, gate: .alwaysAsk)
        let k0 = mine.key, oldID = mine.libraryID, oldDevice = mine.deviceID
        let oldFile = try #require(mine.world.liveKeyFile)
        let (copy, catalog) = try plantCopy(
            mine, libraryID: theirs.libraryID, key: theirs.key, keyFile: try #require(theirs.world.liveKeyFile),
            record: theirs.liveRecord)
        let executor = mine.executor()
        var library = try mine.unlocked(executor)
        _ = try await executor.makeThisMyLibrary(&library, copy: copy, in: catalog, copySecrets: theirs.typed, currentPair: mine.typed)
        let record = try #require(mine.liveRecord)
        #expect(record.libraryID != oldID && record.libraryID != theirs.libraryID, "the copy kept an identity")
        #expect(record.mode == .standard && record.account == nil)
        #expect(mine.world.live?.generation == 42 && library.key != k0 && library.key != theirs.key)
        #expect(library.section.deviceID != oldDevice, "rule 23: a fresh device ID for the new library")
        let live = try #require(mine.world.liveFormat3)
        #expect(live.libraryID == record.libraryID && live.history.isEmpty)
        #expect(try live.open(passphrase: .passphrase(mine.passphrase), floor: PF.floor) == library.key)
        #expect(try live.open(words: mine.words) == library.key)
        #expect((try? live.open(.words(theirs.words), floor: PF.floor)) == nil, "the copy's own secrets lock the new library")
        let apple = try #require(live.apple)
        #expect(mine.world.icloud.keys[apple.keyID] != nil && mine.custody(.silent, library.key))
        // The outgoing library stepped aside WHOLE, with its own key file.
        #expect(mine.world.aside.last?.fingerprint == PF.fp(k0) && mine.world.asideKeyFiles.last == oldFile)
        // This Mac remembers ONE library — the new one.
        #expect(Set(mine.world.memories.keys) == [record.libraryID])
        expectSettled(mine, library)
    }

    /// VX-307 U2c — the VX-306 ladder's round-2 NIT 1 (i): Make this my library
    /// on a copy only THIS MAC'S TOUCH ID ITEM opens — her one confirmed press
    /// reads that item ONCE. The door's preflight is a look at her press (here
    /// the copy field held a wrong secret, so the copy opened by its own quiet
    /// road — the press); the act takes the key that look opened and re-verifies
    /// it against the copy's file (no keychain read), never opening the copy a
    /// second time. The secrets form, by contrast, opens it again at the act —
    /// a second prompt for the same press (the hand-forward's bug, kept for the
    /// lifecycle walk and the scenario world, which never hand a key). A key
    /// that doesn't open the copy refuses with nothing written.
    @Test func anOpenedCopyIsMadeMineWithOnePressNotTwo() async throws {
        let wrong = TypedSecrets(passphrase: "not this copy's passphrase")
        func plantOwnBackup(_ fixture: EX) throws -> (CatalogCopy, Catalog) {
            let planted = try plantCopy(
                fixture, libraryID: fixture.libraryID, key: fixture.key,
                keyFile: try #require(fixture.world.liveKeyFile), record: fixture.liveRecord)
            #expect(fixture.custody(.touchid, fixture.key) && !fixture.custody(.silent, fixture.key), "only Touch ID holds it")
            return planted
        }
        // The opened form: one press.
        let mine = try EX(.castle, gate: .touchID)
        let oldID = mine.libraryID
        let (copy, catalog) = try plantOwnBackup(mine)
        let executor = mine.executor()
        let opened = try executor.lookInside(copy, in: catalog, typed: wrong, quietRoads: .includingTouchID)
        #expect(opened.road == .quietRoad(.touchID) && mine.world.touchIDPresses == 1, "her press — the preflight's look")
        var library = try mine.unlocked(executor)
        let pressesBeforeTheAct = mine.world.touchIDPresses
        _ = try await executor.makeThisMyLibrary(
            &library, opened: opened, copy: copy, in: catalog, currentPair: mine.typed)
        #expect(mine.world.touchIDPresses == pressesBeforeTheAct, "the act re-verified the opened key — no second press")
        #expect(mine.liveRecord.map { $0.libraryID != oldID } == true, "made — a new library")
        expectSettled(mine, library)
        // The secrets form re-opens the copy at the act: a second read of the same item.
        let twice = try EX(.castle, gate: .touchID)
        let (copy2, catalog2) = try plantOwnBackup(twice)
        let executor2 = twice.executor()
        _ = try executor2.lookInside(copy2, in: catalog2, typed: wrong, quietRoads: .includingTouchID)
        var library2 = try twice.unlocked(executor2)
        let before2 = twice.world.touchIDPresses
        _ = try await executor2.makeThisMyLibrary(
            &library2, copy: copy2, in: catalog2, copySecrets: wrong, currentPair: twice.typed)
        #expect(twice.world.touchIDPresses == before2 + 1, "the secrets form presses again at the act")
        // A key the copy doesn't open (stale, or another copy's) refuses — nothing written.
        let stale = try EX(.castle, gate: .touchID)
        let (copy3, catalog3) = try plantOwnBackup(stale)
        let executor3 = stale.executor()
        var library3 = try stale.unlocked(executor3)
        stale.world.writes = []
        await #expect(throws: ExecutorRefusal.copyDoesNotOpen) {
            _ = try await executor3.makeThisMyLibrary(
                &library3, opened: LookedInside(copyID: copy3.id, key: StoreKey.mint(), road: .itsOwnSecrets),
                copy: copy3, in: catalog3, currentPair: stale.typed)
        }
        #expect(stale.world.writes.isEmpty && stale.world.touchIDPresses == 0)
    }

    /// "You never leave Castle by opening something": a Standard copy made
    /// hers on a Castle Mac becomes a CASTLE library — no Apple road, its Touch
    /// ID item made because this Mac's gate says so.
    @Test func inCastleTheNewLibraryIsCastle() async throws {
        let mine = try EX(.castle, gate: .touchID)
        let theirs = try EX(.standard)
        let (copy, catalog) = try plantCopy(
            mine, libraryID: theirs.libraryID, key: theirs.key, keyFile: try #require(theirs.world.liveKeyFile),
            record: theirs.liveRecord)
        let executor = mine.executor()
        var library = try mine.unlocked(executor)
        _ = try await executor.makeThisMyLibrary(&library, copy: copy, in: catalog, copySecrets: theirs.typed, currentPair: mine.typed)
        #expect(mine.liveRecord?.mode == .castle)
        #expect(mine.world.liveFormat3?.apple == nil)
        #expect(mine.custody(.touchid, library.key) && !mine.custody(.silent, library.key))
        #expect(!mine.world.writes.contains { if case .appleAdd = $0 { return true } else { return false } })
        expectSettled(mine, library)
    }

    @Test func aCrashAfterEveryWriteFinishesOrNeverHappened() async throws {
        var oldID = "", typedCopy = TypedSecrets.none
        var copy: CatalogCopy!, catalog: Catalog!
        try await CrashHarness.everywhere(
            {
                let mine = try EX(.standard)
                let theirs = try EX(.castle, gate: .alwaysAsk)
                oldID = mine.libraryID
                typedCopy = theirs.typed
                (copy, catalog) = try plantCopy(
                    mine, libraryID: theirs.libraryID, key: theirs.key, keyFile: try #require(theirs.world.liveKeyFile),
                    record: theirs.liveRecord)
                return mine
            },
            act: { fixture, executor, library in
                _ = try await executor.makeThisMyLibrary(&library, copy: copy, in: catalog, copySecrets: typedCopy, currentPair: fixture.typed)
            },
            finished: { fixture, _ in
                fixture.liveRecord.map { $0.libraryID != oldID } == true && Set(fixture.world.memories.keys).count == 1
            },
            neverHappened: { fixture, _ in
                fixture.liveRecord?.libraryID == oldID && Set(fixture.world.memories.keys) == [oldID]
            },
            resumeMayRollBack: true)
    }

    /// No choice at the door and never quiet: the current pair is always typed
    /// and verified — with nothing typed for it the door refuses before any
    /// write, even when the copy itself would open by a quiet road here. (Kept
    /// from VX-378 U4's piece B2 at her ruling of 2026-10-17, which removed the
    /// carry but not this guard: the posture of now, no choice, the current
    /// pair always typed.)
    @Test func theDoorAlwaysVerifiesTheCurrentPairAndOffersNoChoice() async throws {
        let mine = try EX(.standard)
        let (copy, catalog) = try plantCopy(
            mine, libraryID: PF.id(), key: mine.key, keyFile: try #require(mine.world.liveKeyFile), record: mine.liveRecord)
        let executor = mine.executor()
        var library = try mine.unlocked(executor)
        mine.world.writes = []
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.makeThisMyLibrary(&library, copy: copy, in: catalog, currentPair: .none)
        }
        #expect(mine.world.writes.isEmpty)
    }

    /// Her ruling at the U4 stop (2026-10-17): "let's remove "Make this my
    /// library" carrying keys." A new library starts with no previous keys —
    /// so a backup of the library that stepped aside opens with the secrets it
    /// was made with (the floor, rule 4), and today's secrets, changed since,
    /// no longer reach it through the new library.
    @Test func theNewLibraryStartsWithNoPreviousKeysAndAnOldBackupOpensWithItsOwnSecrets() async throws {
        let mine = try EX(.standard)
        let theirs = try EX(.castle, gate: .alwaysAsk)
        let k0 = mine.key, oldLibraryID = mine.libraryID
        let backupFile = try #require(mine.world.liveKeyFile)
        let executor = mine.executor()
        var library = try mine.unlocked(executor)
        let today = "a passphrase of today"
        _ = try await executor.changePassphrase(&library, current: mine.passphrase, new: today)
        let (copy, catalog) = try plantCopy(
            mine, libraryID: theirs.libraryID, key: theirs.key, keyFile: try #require(theirs.world.liveKeyFile),
            record: theirs.liveRecord)
        _ = try await executor.makeThisMyLibrary(
            &library, copy: copy, in: catalog, copySecrets: theirs.typed,
            currentPair: TypedSecrets(passphrase: today, words: mine.words))
        #expect(try #require(mine.world.liveFormat3).history.isEmpty, "the new library carries previous keys")
        let (old, after) = try plantCopy(mine, libraryID: oldLibraryID, key: k0, keyFile: backupFile, record: nil)
        // The previous library's quiet roads (its silent item, its Apple lock)
        // would open it with nothing typed; the roads under test are the typed
        // ones.
        mine.world.custody[CustodyItemFact(fingerprint: PF.fp(k0), itemClass: .silent)] = nil
        if let apple = backupFile.apple { mine.world.icloud.keys[apple.keyID] = nil }
        #expect((try? executor.lookInside(old, in: after, typed: TypedSecrets(passphrase: today), quietRoads: .includingTouchID)) == nil,
                "today's passphrase reached the previous library's backup")
        let looked = try executor.lookInside(old, in: after, typed: TypedSecrets(passphrase: mine.passphrase), quietRoads: .includingTouchID)
        #expect(looked.key == k0 && looked.road == .itsOwnSecrets)
    }

    @Test func theRefusalsWriteNothing() async throws {
        let mine = try EX(.standard)
        let theirs = try EX(.standard)
        let (copy, catalog) = try plantCopy(
            mine, libraryID: theirs.libraryID, key: theirs.key, keyFile: try #require(theirs.world.liveKeyFile),
            record: theirs.liveRecord)
        let executor = mine.executor()
        var library = try mine.unlocked(executor)
        mine.world.writes = []
        await #expect(throws: ExecutorRefusal.copyDoesNotOpen) {
            _ = try await executor.makeThisMyLibrary(
                &library, copy: copy, in: catalog, copySecrets: TypedSecrets(words: mine.words), currentPair: mine.typed)
        }
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await executor.makeThisMyLibrary(
                &library, copy: copy, in: catalog, copySecrets: theirs.typed,
                currentPair: TypedSecrets(passphrase: "not mine", words: mine.words))
        }
        await #expect(throws: ExecutorRefusal.wordsDoNotOpen) {
            _ = try await executor.makeThisMyLibrary(
                &library, copy: copy, in: catalog, copySecrets: theirs.typed,
                currentPair: TypedSecrets(passphrase: mine.passphrase, words: theirs.words))
        }
        #expect(mine.world.writes.isEmpty)
    }
}
