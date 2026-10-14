//
//  KeyFileTests.swift
//  VariorumCoreTests — VX-305 U1 (the model): key file format 3 — its wraps,
//  the history, the Castle anchor and the four crossings (design §3.4, §3.5a).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A small world of secrets and keys for the key-file suites.
struct KeyWorld {
    let library = PF.id()
    let passphrase = "the day I left"
    let words: [String]
    let p: PassphraseKey
    let w: WordsKey
    let master = SymmetricKey(size: .bits256)

    init() throws {
        words = try PF.words()
        p = try PF.passphraseKey(passphrase)
        w = try PF.wordsKey(words)
    }

    /// The vault's recovery wrap — the master under the words (§3.5a).
    var masterWordsCopy: Data { get throws { try AES.KeyWrap.wrap(master, using: w.key) } }

    func castleLocks(synced: Bool = true) throws -> NewKeyLocks {
        NewKeyLocks(passphrase: p, words: w, master: synced ? master : nil,
                    masterWordsCopy: synced ? try masterWordsCopy : nil)
    }

    /// A Castle library's first key file.
    func castleFile(_ key: StoreKey, synced: Bool = true) throws -> KeyFile {
        try KeyFile.building(libraryID: library, key: key, epoch: 1, locks: castleLocks(synced: synced))
    }
}

@Suite("VX-305 U1 — key file format 3: every wrap opens with the right secret and refuses a wrong one")
struct KeyFileWrapTests {
    @Test func everyWrapOpensWithTheRightSecretAndRefusesAWrongOne() throws {
        let world = try KeyWorld()
        let key = StoreKey.mint()
        let apple = AppleKeyMaterial.mint()
        let shared = AppleKeyMaterial.mint()
        var file = try KeyFile.building(
            libraryID: world.library, key: key, epoch: 1,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: world.master,
                               masterWordsCopy: try world.masterWordsCopy, apple: apple))
        file.sharedApple = AppleWrap(keyID: shared.id, wrapped: try AES.KeyWrap.wrap(SymmetricKey(data: key.data), using: shared.key))

        #expect(try file.open(passphrase: .passphrase(world.passphrase), floor: PF.floor) == key)
        #expect(try file.open(passphrase: .passphraseKey(world.p), floor: PF.floor) == key)
        #expect(throws: KeyFileError.doesNotOpen(.passphrase)) {
            _ = try file.open(passphrase: .passphrase("not it"), floor: PF.floor)
        }
        #expect(try file.open(words: world.words) == key)
        #expect(throws: KeyFileError.doesNotOpen(.words)) { _ = try file.open(words: try PF.words()) }
        #expect(try file.open(master: world.master) == key)
        #expect(throws: KeyFileError.doesNotOpen(.master)) { _ = try file.open(master: SymmetricKey(size: .bits256)) }
        #expect(try file.open(wordsThroughMaster: world.words) == key)
        #expect(throws: KeyFileError.doesNotOpen(.masterThroughWords)) { _ = try file.openMaster(words: try PF.words()) }
        #expect(try file.open(apple: apple) == key)
        #expect(throws: KeyFileError.appleKeyMismatch(expected: apple.id, offered: shared.id)) {
            _ = try file.open(apple: shared)
        }
        #expect(throws: KeyFileError.doesNotOpen(.apple)) {
            _ = try file.open(apple: AppleKeyMaterial(id: apple.id, key: SymmetricKey(size: .bits256)))
        }
        #expect(try file.open(sharedApple: shared) == key)
        #expect(file.roads == [.passphrase, .words, .master, .masterThroughWords, .apple, .sharedApple])
        // The words open the file by either road (§3.5a).
        var wordsOnlyThroughMaster = file
        wordsOnlyThroughMaster.words = nil
        #expect(try wordsOnlyThroughMaster.open(.words(world.words), floor: PF.floor) == key)
    }

    /// A wrap that opens to ANOTHER key than the file names is refused — a
    /// planted file can't hand over a key that isn't its own.
    @Test func aWrapOfAnotherKeyIsRefused() throws {
        let world = try KeyWorld()
        let key = StoreKey.mint(), planted = StoreKey.mint()
        var file = try world.castleFile(key)
        file.words = try AES.KeyWrap.wrap(SymmetricKey(data: planted.data), using: world.w.key)
        #expect(throws: KeyFileError.wrapsAnotherKey(.words)) { _ = try file.open(words: world.words) }
        #expect(throws: KeyFileError.keyIsNotThisFilesKey) { _ = try file.settingWords(world.w, for: planted) }
    }

    @Test func aFormat3FileRoundTrips() throws {
        let world = try KeyWorld()
        let k1 = StoreKey.mint(), k2 = StoreKey.mint()
        let castle = try world.castleFile(k1)
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: castle, outgoingKey: k1, locks: .pressingDevice(passphrase: world.p, words: world.w),
            madeAt: PF.day(1), madeBy: PF.id())
        let left = try castle.writingAnchor(anchor)
            .rekeyed(.leavingCastle, from: k1, to: k2, locks: NewKeyLocks(passphrase: world.p), at: PF.day(1)).keyFile
        let data = try left.encoded()
        let reread = try ProtectionCoding.decoder().decode(KeyFile.self, from: data)
        #expect(reread == left)
        #expect(reread.formatVersion == 3)
        #expect(reread.anchor?.opens(with: .words(world.words), floor: PF.floor) == true)
    }
}

@Suite("VX-305 U1 — the history: older keys reachable from the newest, never the reverse")
struct KeyHistoryTests {
    @Test func theHistorySurvivesThreeReKeys() throws {
        let world = try KeyWorld()
        let keys = (0...3).map { _ in StoreKey.mint() }
        var files = [try world.castleFile(keys[0])]
        for i in 1...3 {
            files.append(try files[i - 1].rekeyed(
                .withinMode, from: keys[i - 1], to: keys[i], locks: world.castleLocks(), at: PF.day(Double(i))).keyFile)
        }
        let newest = files[3]
        #expect(newest.epoch == 4)
        // Every old key reachable from the newest, each verified.
        let opened = try newest.historyKeys(currentKey: keys[3])
        #expect(opened.map(\.key) == [keys[2], keys[1], keys[0]])
        #expect(opened.map(\.epoch) == [3, 2, 1])
        #expect(opened.map(\.retiredAt) == [PF.day(3), PF.day(2), PF.day(1)])
        // Never the reverse: an older file holds only what came before it, and
        // an old key opens none of the newer file's entries.
        #expect(try files[1].historyKeys(currentKey: keys[1]).map(\.key) == [keys[0]])
        #expect(!files[1].heldFingerprints.contains(PF.fp(keys[2])))
        for old in keys[0...2] {
            for entry in newest.history {
                #expect(Lock.unwrap(entry.wrapped, under: SymmetricKey(data: old.data)) == nil)
            }
        }
        #expect(throws: KeyFileError.keyIsNotThisFilesKey) { _ = try newest.historyKeys(currentKey: keys[2]) }
    }

    /// The re-key drops the old shared key's wrap: this build never writes
    /// under it (§3.5 points 1–2).
    @Test func aReKeyDropsTheOldSharedWrap() throws {
        let world = try KeyWorld()
        let k0 = StoreKey.mint(), k1 = StoreKey.mint()
        var file = try world.castleFile(k0)
        let shared = AppleKeyMaterial.mint()
        file.sharedApple = AppleWrap(keyID: shared.id, wrapped: try AES.KeyWrap.wrap(SymmetricKey(data: k0.data), using: shared.key))
        let next = try file.rekeyed(.withinMode, from: k0, to: k1, locks: world.castleLocks(), at: PF.day(1)).keyFile
        #expect(next.sharedApple == nil)
        #expect(next.apple == nil)
    }
}

@Suite("VX-305 U1 — the crossings (design §3.4)")
struct KeyFileCrossingTests {
    /// Into Castle: everything — the old key, its history.
    @Test func enteringCastleTakesEverything() throws {
        let world = try KeyWorld()
        let s0 = StoreKey.mint(), s1 = StoreKey.mint(), c = StoreKey.mint()
        let apple = AppleKeyMaterial.mint()
        let standard0 = try KeyFile.building(
            libraryID: world.library, key: s0, epoch: 1, locks: NewKeyLocks(apple: apple))
        let standard1 = try standard0.rekeyed(
            .withinMode, from: s0, to: s1, locks: NewKeyLocks(passphrase: world.p, apple: apple), at: PF.day(1)).keyFile
        let castle = try standard1.rekeyed(
            .enteringCastle(openers: [.passphrase(world.passphrase), .words(world.words)]),
            from: s1, to: c, locks: world.castleLocks(), at: PF.day(2), floor: PF.floor)
        #expect(castle.unopenedAnchors.isEmpty)
        #expect(try castle.keyFile.historyKeys(currentKey: c).map(\.key) == [s1, s0])
        #expect(castle.keyFile.apple == nil)
        #expect(throws: KeyFileError.appleWrapOnACastleKey) {
            _ = try standard1.rekeyed(.enteringCastle(openers: []), from: s1, to: c,
                                       locks: NewKeyLocks(passphrase: world.p, apple: apple), at: PF.day(2))
        }
    }

    /// Out of Castle: nothing. The anchor is written first, and opens with the
    /// passphrase and with the words of the day.
    @Test func leavingCastleTakesNothing_theAnchorOpensWithThePassphraseAndTheWords() throws {
        let world = try KeyWorld()
        let c0 = StoreKey.mint(), c1 = StoreKey.mint(), s = StoreKey.mint()
        let castle = try world.castleFile(c0)
            .rekeyed(.withinMode, from: c0, to: c1, locks: world.castleLocks(), at: PF.day(1)).keyFile
        // Not first → refused.
        #expect(throws: KeyFileError.anchorNotWrittenFirst) {
            _ = try castle.rekeyed(.leavingCastle, from: c1, to: s, locks: NewKeyLocks(apple: .mint()), at: PF.day(2))
        }
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: castle, outgoingKey: c1, locks: .pressingDevice(passphrase: world.p, words: world.w),
            madeAt: PF.day(2), madeBy: PF.id())
        let first = try castle.writingAnchor(anchor)
        #expect(throws: KeyFileError.anchorIsNotThisKeysAnchor) {
            _ = try world.castleFile(StoreKey.mint()).writingAnchor(anchor)
        }
        let standard = try first.rekeyed(
            .leavingCastle, from: c1, to: s, locks: NewKeyLocks(passphrase: world.p, words: world.w, apple: .mint()),
            at: PF.day(2)).keyFile
        #expect(standard.history.isEmpty, "the new key starts clean")
        #expect(standard.anchor == anchor, "carried, byte for byte")
        #expect(try standard.historyKeys(currentKey: s).isEmpty)
        for secret in [ProtectionSecret.passphrase(world.passphrase), .words(world.words)] {
            let contents = try #require(try? standard.anchor?.open(secret, floor: PF.floor))
            #expect(contents.keys.map(\.key) == [c1, c0])
        }
        #expect(standard.anchor?.opens(with: .passphrase("another"), floor: PF.floor) == false)
        #expect(Set(standard.heldFingerprints) == Set([s, c1, c0].map(PF.fp)))
    }

    /// Castle → Standard → Castle folds the anchor back: every older key is in
    /// the newest history again, with nothing more typed than the door's.
    @Test func castleToStandardToCastleFoldsTheAnchorBack() throws {
        let world = try KeyWorld()
        let c0 = StoreKey.mint(), s1 = StoreKey.mint(), s2 = StoreKey.mint(), c3 = StoreKey.mint()
        let castle = try world.castleFile(c0)
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: castle, outgoingKey: c0, locks: .pressingDevice(passphrase: world.p, words: world.w),
            madeAt: PF.day(1), madeBy: nil)
        let standard = try castle.writingAnchor(anchor).rekeyed(
            .leavingCastle, from: c0, to: s1, locks: NewKeyLocks(passphrase: world.p, words: world.w), at: PF.day(1)).keyFile
        let standard2 = try standard.rekeyed(
            .withinMode, from: s1, to: s2, locks: NewKeyLocks(passphrase: world.p, words: world.w), at: PF.day(2)).keyFile
        let back = try standard2.rekeyed(
            .enteringCastle(openers: [.passphrase(world.passphrase), .words(world.words)]),
            from: s2, to: c3, locks: world.castleLocks(), at: PF.day(3), floor: PF.floor)
        #expect(back.unopenedAnchors.isEmpty)
        #expect(back.keyFile.anchor == nil)
        #expect(back.keyFile.keptAnchors.isEmpty)
        #expect(try back.keyFile.historyKeys(currentKey: c3).map(\.key) == [s2, s1, c0])
        #expect(try back.keyFile.historyKeys(currentKey: c3).last?.retiredAt == PF.day(1), "the leave's day")
    }

    /// A landing starts empty (a different library: a fresh key, no history,
    /// no anchor — the sent pair keeps its own locks).
    @Test func aLandingStartsEmpty() throws {
        let world = try KeyWorld()
        let landed = try KeyFile.building(
            libraryID: world.library, key: StoreKey.mint(), epoch: 5, locks: NewKeyLocks(passphrase: world.p))
        #expect(landed.history.isEmpty)
        #expect(landed.anchor == nil)
        #expect(landed.keptAnchors.isEmpty)
        #expect(landed.epoch == 5)
    }

    /// Within a mode the history grows, and the anchor rides unchanged.
    @Test func withinAModeTheHistoryGrowsAndTheAnchorRides() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint(), s1 = StoreKey.mint(), s2 = StoreKey.mint(), s3 = StoreKey.mint()
        let castle = try world.castleFile(c)
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: castle, outgoingKey: c, locks: .pressingDevice(passphrase: world.p, words: world.w),
            madeAt: PF.day(1), madeBy: nil)
        let one = try castle.writingAnchor(anchor).rekeyed(
            .leavingCastle, from: c, to: s1, locks: NewKeyLocks(words: world.w), at: PF.day(1)).keyFile
        let two = try one.rekeyed(.withinMode, from: s1, to: s2, locks: NewKeyLocks(words: world.w), at: PF.day(2)).keyFile
        let three = try two.rekeyed(.withinMode, from: s2, to: s3, locks: NewKeyLocks(words: world.w), at: PF.day(3)).keyFile
        #expect(try three.historyKeys(currentKey: s3).map(\.key) == [s2, s1])
        #expect(three.anchor == anchor)
    }

    /// An anchor the typed secrets can't open is kept beside the history,
    /// unchanged, and doesn't fail the entry; a later leave seals it inside the
    /// new anchor, where it still opens with the secrets of ITS day.
    @Test func anUnopenableAnchorIsKeptAndDoesNotFailTheEntry() throws {
        let world = try KeyWorld()
        let c0 = StoreKey.mint(), s1 = StoreKey.mint(), c2 = StoreKey.mint(), s3 = StoreKey.mint()
        let anchor1 = try CastleAnchor.sealing(
            outgoingKeyFile: try world.castleFile(c0), outgoingKey: c0,
            locks: .pressingDevice(passphrase: world.p, words: world.w), madeAt: PF.day(1), madeBy: nil)
        let standard = try world.castleFile(c0).writingAnchor(anchor1).rekeyed(
            .leavingCastle, from: c0, to: s1, locks: NewKeyLocks(passphrase: world.p, words: world.w), at: PF.day(1)).keyFile
        // Both secrets replaced since the leave (the key doors re-wrap the
        // current key only).
        let newPassphrase = "a later passphrase"
        let newWords = try PF.words()
        let p2 = try PF.passphraseKey(newPassphrase), w2 = try PF.wordsKey(newWords)
        let changed = try standard.settingPassphrase(p2, for: s1).settingWords(w2, for: s1)
        let entry = try changed.rekeyed(
            .enteringCastle(openers: [.passphrase(newPassphrase), .words(newWords)]),
            from: s1, to: c2, locks: NewKeyLocks(passphrase: p2, words: w2), at: PF.day(5), floor: PF.floor)
        #expect(entry.unopenedAnchors == [anchor1])
        #expect(entry.keyFile.keptAnchors == [anchor1], "kept beside, unchanged")
        #expect(try entry.keyFile.historyKeys(currentKey: c2).map(\.key) == [s1])
        // A later leave seals it inside the new anchor.
        let anchor2 = try CastleAnchor.sealing(
            outgoingKeyFile: entry.keyFile, outgoingKey: c2,
            locks: .pressingDevice(passphrase: p2, words: w2), madeAt: PF.day(9), madeBy: nil)
        let left = try entry.keyFile.writingAnchor(anchor2).rekeyed(
            .leavingCastle, from: c2, to: s3, locks: NewKeyLocks(passphrase: p2, words: w2), at: PF.day(9)).keyFile
        let contents = try left.anchor!.open(.passphrase(newPassphrase), floor: PF.floor)
        #expect(contents.keptAnchors == [anchor1])
        #expect(try contents.keptAnchors[0].open(.words(world.words), floor: PF.floor).outgoing.key == c0)
        #expect(Set(left.heldFingerprints) == Set([s3, c2, s1, c0].map(PF.fp)))
    }
}

@Suite("VX-305 U1 — the anchor keeps the secrets of its day")
struct CastleAnchorTests {
    /// No door re-locks it: changing the passphrase or making new words after
    /// the leave leaves the anchor byte-identical, still opening with the
    /// day's secrets and not the new ones; every re-key carries it unchanged.
    @Test func noDoorReLocksItAndEveryReKeyCarriesItUnchanged() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint(), s1 = StoreKey.mint(), s2 = StoreKey.mint()
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: try world.castleFile(c), outgoingKey: c,
            locks: .pressingDevice(passphrase: world.p, words: world.w), madeAt: PF.day(1), madeBy: nil)
        let standard = try world.castleFile(c).writingAnchor(anchor).rekeyed(
            .leavingCastle, from: c, to: s1, locks: NewKeyLocks(passphrase: world.p, words: world.w), at: PF.day(1)).keyFile
        let newPassphrase = "changed later"
        let newWords = try PF.words()
        let doors = try standard
            .settingPassphrase(try PF.passphraseKey(newPassphrase), for: s1)
            .settingWords(try PF.wordsKey(newWords), for: s1)
        #expect(doors.anchor == anchor)
        let rekeyed = try doors.rekeyed(.withinMode, from: s1, to: s2, locks: NewKeyLocks(), at: PF.day(3)).keyFile
        #expect(rekeyed.anchor == anchor)
        let anchorNow = try #require(rekeyed.anchor)
        #expect(anchorNow.opens(with: .passphrase(world.passphrase), floor: PF.floor))
        #expect(anchorNow.opens(with: .words(world.words), floor: PF.floor))
        #expect(!anchorNow.opens(with: .passphrase(newPassphrase), floor: PF.floor))
        #expect(!anchorNow.opens(with: .words(newWords), floor: PF.floor))
    }

    /// A follower's anchor opens with the secret typed at its follow, and with
    /// exactly what opened that device: the secret it held its key under (an
    /// older passphrase here), the words, or the words through the master copy.
    @Test func aFollowersAnchorOpensWithTheTypedSecretAndWithWhatOpenedThatDevice() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint()
        // The follower held its Castle key under an OLDER passphrase and the words.
        let olderPassphrase = "what I typed on the phone in August"
        let follower = try KeyFile.building(
            libraryID: world.library, key: c, epoch: 3,
            locks: NewKeyLocks(passphrase: try PF.passphraseKey(olderPassphrase), words: world.w,
                               master: world.master, masterWordsCopy: try world.masterWordsCopy))
        // At its follow it typed the CURRENT passphrase.
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: follower, outgoingKey: c,
            locks: .follower(typed: .passphrase(world.p), outgoingKeyFile: follower, includeMasterRoad: true),
            madeAt: PF.day(4), madeBy: PF.id())
        #expect(anchor.opens(with: .passphrase(world.passphrase), floor: PF.floor), "the secret typed at the follow")
        #expect(anchor.opens(with: .passphrase(olderPassphrase), floor: PF.floor), "the passphrase that device held it under")
        #expect(anchor.opens(with: .words(world.words), floor: PF.floor), "the words")
        #expect(!anchor.opens(with: .passphrase("never typed anywhere"), floor: PF.floor))
        #expect(try anchor.open(outgoingKey: c).outgoing.key == c)
        // Through the master copy alone (no words wrap copied).
        let viaMasterOnly = try KeyFile.building(
            libraryID: world.library, key: c, epoch: 3,
            locks: NewKeyLocks(master: world.master, masterWordsCopy: try world.masterWordsCopy))
        let masterAnchor = try CastleAnchor.sealing(
            outgoingKeyFile: viaMasterOnly, outgoingKey: c,
            locks: .follower(typed: .passphrase(world.p), outgoingKeyFile: viaMasterOnly, includeMasterRoad: true),
            madeAt: PF.day(4), madeBy: nil)
        #expect(masterAnchor.opens(with: .words(world.words), floor: PF.floor))
        #expect(masterAnchor.roads.copiedMasterThroughWords)
    }

    /// With the vault's master unchanged since Castle (an older build's leave
    /// put it under the old shared Apple key), the master's road is left out.
    @Test func withTheMasterUnchangedSinceCastleTheMastersRoadIsLeftOut() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint()
        let viaMasterOnly = try KeyFile.building(
            libraryID: world.library, key: c, epoch: 3,
            locks: NewKeyLocks(master: world.master, masterWordsCopy: try world.masterWordsCopy))
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: viaMasterOnly, outgoingKey: c,
            locks: .follower(typed: .passphrase(world.p), outgoingKeyFile: viaMasterOnly, includeMasterRoad: false),
            madeAt: PF.day(4), madeBy: nil)
        #expect(anchor.locks.copiedLocks?.master == nil)
        #expect(anchor.locks.copiedLocks?.masterWordsCopy == nil)
        #expect(!anchor.opens(with: .words(world.words), floor: PF.floor))
        #expect(anchor.opens(with: .passphrase(world.passphrase), floor: PF.floor))
    }

    /// A follower that only ever had the words typed: its anchor opens with the
    /// words, and its roads say the twelve words, not the passphrase.
    @Test func aWordsOnlyFollowersAnchorSaysTheWords() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint()
        let wordsOnly = try KeyFile.building(
            libraryID: world.library, key: c, epoch: 2,
            locks: NewKeyLocks(words: world.w, master: world.master, masterWordsCopy: try world.masterWordsCopy))
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: wordsOnly, outgoingKey: c,
            locks: .follower(typed: .words(world.w), outgoingKeyFile: wordsOnly, includeMasterRoad: true),
            madeAt: PF.day(4), madeBy: nil)
        #expect(anchor.opens(with: .words(world.words), floor: PF.floor))
        #expect(!anchor.roads.opensWithAPassphrase)
        #expect(anchor.roads.opensWithTheWords)
        #expect(!anchor.opens(with: .passphrase(world.passphrase), floor: PF.floor))
    }

    /// No value ever holds a master under the passphrase: every lock in a
    /// synced follower's key file and its anchor, tried with every passphrase
    /// key of the world, never yields the master.
    @Test func noValueEverHoldsAMasterUnderThePassphrase() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint(), s = StoreKey.mint()
        let castle = try world.castleFile(c)
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: castle, outgoingKey: c,
            locks: .follower(typed: .passphrase(world.p), outgoingKeyFile: castle, includeMasterRoad: true),
            madeAt: PF.day(1), madeBy: nil)
        let file = try castle.writingAnchor(anchor).rekeyed(
            .leavingCastle, from: c, to: s,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: world.master,
                               masterWordsCopy: try world.masterWordsCopy, apple: .mint()),
            at: PF.day(1)).keyFile
        var blobs: [Data] = [file.passphrase?.wrapped, file.words, file.master, file.masterWordsCopy, file.apple?.wrapped]
            .compactMap { $0 }
        blobs += file.history.map(\.wrapped)
        let locks = file.anchor!.locks
        blobs += [locks.passphrase?.wrapped, locks.words, locks.outgoingKey,
                  locks.copiedLocks?.passphrase?.wrapped, locks.copiedLocks?.words,
                  locks.copiedLocks?.master, locks.copiedLocks?.masterWordsCopy].compactMap { $0 }
        let masterBytes = PF.bytes(world.master)
        let descriptors = [file.passphrase?.kdf, locks.passphrase?.kdf, locks.copiedLocks?.passphrase?.kdf].compactMap { $0 }
        for kdf in descriptors {
            let derived = try PassphraseKDF.deriveKey(passphrase: world.passphrase, descriptor: kdf)
            for blob in blobs {
                #expect(Lock.unwrap(blob, under: derived) != masterBytes)
            }
        }
        // And the words copy is the master under the WORDS (non-secret: 128-bit words).
        #expect(Lock.unwrap(try #require(file.masterWordsCopy), under: world.w.key) == masterBytes)
    }

    /// The clear metadata can't be swapped onto another anchor's bundle: the
    /// bundle's additional data binds the outgoing fingerprint.
    @Test func aTamperedAnchorOpensNothing() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint()
        var anchor = try CastleAnchor.sealing(
            outgoingKeyFile: try world.castleFile(c), outgoingKey: c,
            locks: .pressingDevice(passphrase: world.p, words: world.w), madeAt: PF.day(1), madeBy: nil)
        anchor.outgoingFingerprint = PF.fp(StoreKey.mint())
        #expect(throws: KeyFileError.anchorBundleUnreadable) { _ = try anchor.open(.words(world.words), floor: PF.floor) }
        var flipped = try CastleAnchor.sealing(
            outgoingKeyFile: try world.castleFile(c), outgoingKey: c,
            locks: .pressingDevice(passphrase: world.p, words: world.w), madeAt: PF.day(1), madeBy: nil)
        flipped.bundle[flipped.bundle.startIndex + 20] ^= 0x01
        #expect(throws: KeyFileError.anchorBundleUnreadable) { _ = try flipped.open(.words(world.words), floor: PF.floor) }
    }
}
