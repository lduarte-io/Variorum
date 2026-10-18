//
//  KeyFileTests.swift
//  VariorumCoreTests — VX-305 U1 (the model): key file format 3 — its wraps,
//  the history and the re-key that carries it (rule 4; the Castle anchor left
//  with VX-378 U1).
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
        let file = try KeyFile.building(
            libraryID: world.library, key: key, epoch: 1,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: world.master,
                               masterWordsCopy: try world.masterWordsCopy, apple: apple))

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
        #expect(file.roads == [.passphrase, .words, .master, .masterThroughWords, .apple])
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
        let left = try world.castleFile(k1)
            .rekeyed(from: k1, to: k2, kind: .standard, locks: NewKeyLocks(passphrase: world.p, words: world.w), at: PF.day(1))
        let data = try left.encoded()
        let reread = try ProtectionCoding.decoder().decode(KeyFile.self, from: data)
        #expect(reread == left)
        #expect(reread.formatVersion == 3)
        #expect(try reread.historyKeys(currentKey: k2).map(\.key) == [k1])
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
                from: keys[i - 1], to: keys[i], kind: .castle, locks: world.castleLocks(), at: PF.day(Double(i))))
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

}

@Suite("VX-305 U1 — every key change carries the history (rule 4)")
struct KeyFileCrossingTests {
    /// Into Castle: the old key and its history; a Castle key never takes an
    /// Apple lock.
    @Test func enteringCastleTakesEverything() throws {
        let world = try KeyWorld()
        let s0 = StoreKey.mint(), s1 = StoreKey.mint(), c = StoreKey.mint()
        let apple = AppleKeyMaterial.mint()
        let standard0 = try KeyFile.building(
            libraryID: world.library, key: s0, epoch: 1, locks: NewKeyLocks(words: world.w, apple: apple))
        let standard1 = try standard0.rekeyed(
            from: s0, to: s1, kind: .standard, locks: NewKeyLocks(passphrase: world.p, words: world.w, apple: apple), at: PF.day(1))
        let castle = try standard1.rekeyed(from: s1, to: c, kind: .castle, locks: world.castleLocks(), at: PF.day(2))
        #expect(try castle.historyKeys(currentKey: c).map(\.key) == [s1, s0])
        #expect(castle.apple == nil)
        #expect(throws: KeyFileError.appleWrapOnACastleKey) {
            _ = try standard1.rekeyed(from: s1, to: c, kind: .castle,
                                       locks: NewKeyLocks(passphrase: world.p, words: world.w, apple: apple), at: PF.day(2))
        }
    }

    /// Out of Castle: the same — the Castle keys ride the history, and the
    /// current passphrase and words open every one of them (rule 4, rule 12).
    @Test func leavingCastleCarriesEveryCastleKey() throws {
        let world = try KeyWorld()
        let c0 = StoreKey.mint(), c1 = StoreKey.mint(), s = StoreKey.mint()
        let castle = try world.castleFile(c0)
            .rekeyed(from: c0, to: c1, kind: .castle, locks: world.castleLocks(), at: PF.day(1))
        let standard = try castle.rekeyed(
            from: c1, to: s, kind: .standard,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, apple: .mint()), at: PF.day(2))
        #expect(try standard.historyKeys(currentKey: s).map(\.key) == [c1, c0])
        for secret in [ProtectionSecret.passphrase(world.passphrase), .words(world.words)] {
            let current = try standard.open(secret, floor: PF.floor)
            #expect(current == s)
            #expect(try standard.historyKeys(currentKey: current).map(\.key) == [c1, c0])
        }
        #expect(Set(standard.heldFingerprints) == Set([s, c1, c0].map(PF.fp)))
    }

    /// Castle → Standard → Castle: every older key is in the newest history,
    /// each with the day it was retired.
    @Test func castleToStandardToCastleKeepsEveryKey() throws {
        let world = try KeyWorld()
        let c0 = StoreKey.mint(), s1 = StoreKey.mint(), s2 = StoreKey.mint(), c3 = StoreKey.mint()
        let standard = try world.castleFile(c0).rekeyed(
            from: c0, to: s1, kind: .standard, locks: NewKeyLocks(passphrase: world.p, words: world.w), at: PF.day(1))
        let standard2 = try standard.rekeyed(
            from: s1, to: s2, kind: .standard, locks: NewKeyLocks(passphrase: world.p, words: world.w), at: PF.day(2))
        let back = try standard2.rekeyed(from: s2, to: c3, kind: .castle, locks: world.castleLocks(), at: PF.day(3))
        #expect(try back.historyKeys(currentKey: c3).map(\.key) == [s2, s1, c0])
        #expect(try back.historyKeys(currentKey: c3).last?.retiredAt == PF.day(1), "the leave's day")
    }

    /// A landing starts empty (a different library: a fresh key, no history —
    /// the sent pair keeps its own locks).
    @Test func aLandingStartsEmpty() throws {
        let world = try KeyWorld()
        let landed = try KeyFile.building(
            libraryID: world.library, key: StoreKey.mint(), epoch: 5, locks: NewKeyLocks(passphrase: world.p, words: world.w))
        #expect(landed.history.isEmpty)
        #expect(landed.epoch == 5)
    }

    /// No value ever holds a master under the passphrase: every lock in a
    /// synced Standard key file after a leave, tried with the passphrase key,
    /// never yields the master; the words copy is the master under the words.
    @Test func noValueEverHoldsAMasterUnderThePassphrase() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint(), s = StoreKey.mint()
        let file = try world.castleFile(c).rekeyed(
            from: c, to: s, kind: .standard,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: world.master,
                               masterWordsCopy: try world.masterWordsCopy, apple: .mint()),
            at: PF.day(1))
        var blobs: [Data] = [file.passphrase?.wrapped, file.words, file.master, file.masterWordsCopy, file.apple?.wrapped]
            .compactMap { $0 }
        blobs += file.history.map(\.wrapped)
        let masterBytes = PF.bytes(world.master)
        for kdf in [file.passphrase?.kdf].compactMap({ $0 }) {
            let derived = try PassphraseKDF.deriveKey(passphrase: world.passphrase, descriptor: kdf)
            for blob in blobs {
                #expect(Lock.unwrap(blob, under: derived) != masterBytes)
            }
        }
        // And the words copy is the master under the WORDS (non-secret: 128-bit words).
        #expect(Lock.unwrap(try #require(file.masterWordsCopy), under: world.w.key) == masterBytes)
    }
}
