//
//  U4MakeMineHistoryTests.swift
//  VariorumCoreTests — VX-378 U4, HER RULING ON P-VX378-U4-1 (2026-10-16):
//  Make this my library CARRIES THE KEY HISTORY FORWARD — rule 4 applied at the
//  door. Her words: "let's just keep carrying the key history file forward - I
//  see no particular reason to not do it, if you've decided that this is your
//  library from now on, then why should it *not* have the old keys to your
//  previous library? we say clearly that your new library always carries keys
//  forward." The new library's key is still a FRESH key (a fresh library ID, a
//  fresh device ID, the posture of now, under the current pair — rule 17); its
//  history now holds the copy's key and the copy's key file's history, and the
//  previous library's key and its history (the old keys to your previous
//  library), each sealed under the new key. Quiet roads still open only the new
//  key directly (rule 4). Red on the tree before the piece, where the new key
//  file had no past.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U4 — her ruling: Make this my library carries the key history forward (rule 4 at the door)")
struct U4MakeMineHistoryTests {
    /// A library re-keyed through Use Castle then Use Standard: its key file's
    /// current key now has a two-key history.
    static func rekeyedTwice(_ fixture: EX) async throws -> (key: StoreKey, file: KeyFile, all: [StoreKey]) {
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .alwaysAsk)
        let k1 = library.key
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        return (library.key, try #require(fixture.world.liveFormat3), [library.key, k1, k0])
    }

    /// THE PIN her ruling names: after Make this my library, a backup of the
    /// previous library made under an earlier key — whose own key file still
    /// wants that day's passphrase — opens by Look inside with TODAY's
    /// passphrase, through the new library's history.
    @Test func aBackupOfThePreviousLibraryOpensWithTodaysPassphraseThroughTheNewHistory() async throws {
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
        let (old, after) = try plantCopy(mine, libraryID: oldLibraryID, key: k0, keyFile: backupFile, record: nil)
        // The previous library's silent item would open it quietly; the road
        // under test is the typed one.
        mine.world.custody[CustodyItemFact(fingerprint: PF.fp(k0), itemClass: .silent)] = nil
        #expect((try? backupFile.open(.passphrase(today), floor: PF.floor)) == nil, "the backup's own file opens with today's passphrase")
        let looked = try executor.lookInside(old, in: after, typed: TypedSecrets(passphrase: today))
        #expect(looked.key == k0 && looked.road == .currentSecretsThroughTheHistory)
    }

    /// A Castle Mac making a Standard copy its library gets a CASTLE key (the
    /// posture of now) carrying the copy's keys — the Standard-era ones, as
    /// entering Castle takes everything in — and the previous library's key.
    @Test func aCastleMacMakingAStandardCopyItsLibraryGetsACastleKeyCarryingItsKeys() async throws {
        let mine = try EX(.castle, gate: .touchID)
        let theirs = try EX(.standard)
        let (theirKey, theirFile, theirKeys) = try await Self.rekeyedTwice(theirs)
        let k0 = mine.key
        let (copy, catalog) = try plantCopy(mine, libraryID: theirs.libraryID, key: theirKey, keyFile: theirFile, record: theirs.liveRecord)
        let executor = mine.executor()
        var library = try mine.unlocked(executor)
        _ = try await executor.makeThisMyLibrary(&library, copy: copy, in: catalog, copySecrets: theirs.typed, currentPair: mine.typed)
        let live = try #require(mine.world.liveFormat3)
        #expect(mine.liveRecord?.mode == .castle && live.apple == nil, "the posture of now wins at the door")
        let held = Set(try live.historyKeys(currentKey: library.key).map(\.fingerprint))
        #expect(held.isSuperset(of: theirKeys.map(PF.fp)), "the copy's key history wasn't carried")
        #expect(held.contains(PF.fp(k0)), "the previous library's key wasn't carried")
        #expect(!mine.custody(.silent, library.key) && mine.custody(.touchid, library.key))
    }

    /// A Standard Mac making a Castle-era backup its library gets a STANDARD
    /// key carrying the Castle keys (the leave's rule, applied to that copy) —
    /// with a fresh Apple road to the new key only.
    @Test func aStandardMacMakingACastleBackupItsLibraryGetsAStandardKeyCarryingItsKeys() async throws {
        let mine = try EX(.standard)
        let theirs = try EX(.standard)
        let k0 = mine.key, t0 = theirs.key
        let te = theirs.executor()
        var theirLibrary = try theirs.unlocked(te)
        _ = try await te.useCastle(&theirLibrary, typed: theirs.typed, gate: .alwaysAsk)
        let castleFile = try #require(theirs.world.liveFormat3)
        let (copy, catalog) = try plantCopy(
            mine, libraryID: theirs.libraryID, key: theirLibrary.key, keyFile: castleFile, record: theirs.liveRecord)
        let executor = mine.executor()
        var library = try mine.unlocked(executor)
        _ = try await executor.makeThisMyLibrary(&library, copy: copy, in: catalog, copySecrets: theirs.typed, currentPair: mine.typed)
        let live = try #require(mine.world.liveFormat3)
        #expect(mine.liveRecord?.mode == .standard, "the posture of now wins at the door")
        let held = Set(try live.historyKeys(currentKey: library.key).map(\.fingerprint))
        #expect(held.isSuperset(of: [theirLibrary.key, t0, k0].map(PF.fp)), "a key wasn't carried")
        // The Apple road opens the NEW key only: no Apple lock reaches the carried keys.
        let apple = try #require(live.apple)
        #expect(try live.open(apple: try #require(mine.world.icloud.keys[apple.keyID])) == library.key)
    }

    /// The Apple key this Mac made for the previous library comes with its key
    /// (it wraps a key the new library's history now holds): entering Castle
    /// afterwards retires it (rule 11 — "entering takes everything in"), so the
    /// previous library's key file no longer opens through Apple.
    @Test func enteringCastleAfterwardsRetiresTheAppleKeyMadeForThePreviousLibrary() async throws {
        let mine = try EX(.standard)
        let theirs = try EX(.standard)
        let previousApple = try #require(mine.ownApple)
        let (copy, catalog) = try plantCopy(
            mine, libraryID: theirs.libraryID, key: theirs.key, keyFile: try #require(theirs.world.liveKeyFile),
            record: theirs.liveRecord)
        let executor = mine.executor()
        var library = try mine.unlocked(executor)
        _ = try await executor.makeThisMyLibrary(&library, copy: copy, in: catalog, copySecrets: theirs.typed, currentPair: mine.typed)
        _ = try await executor.useCastle(&library, typed: mine.typed, gate: .alwaysAsk)
        #expect(mine.world.icloud.keys[previousApple.id] == nil, "the previous library's Apple key still reaches a key the Castle library carries")
        #expect(library.section.retiredAppleKeyIDs.contains(previousApple.id))
    }

    /// No choice at the door and never quiet: the current pair is always typed
    /// and verified — with nothing typed for it the door refuses before any
    /// write, even when the copy itself would open by a quiet road here.
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
}
