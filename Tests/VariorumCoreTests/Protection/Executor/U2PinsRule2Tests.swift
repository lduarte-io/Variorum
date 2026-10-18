//
//  U2PinsRule2Tests.swift
//  VariorumCoreTests — VX-378 U2 piece B: RULE 2, words at birth
//  (`notes/CastleRules.md`: "Every library has twelve words from the moment it
//  is created … There is no such thing as a library with no secret"). Written
//  against the API both trees share, so the red-on-old run is honest.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U2 — rule 2: every library has twelve words from the moment it is created")
struct U2PinsRule2Tests {
    /// Created with nothing typed, the library's key file still opens with
    /// twelve words — minted at the creation, never left to the caller.
    @Test func aLibraryCreatedWithNothingTypedHasItsTwelveWords() throws {
        let world = ExecutorWorld()
        let executor = ProtectionExecutor(
            leaves: world.leaves,
            configuration: ExecutorConfiguration(scope: EX.scope, libraryID: "", deviceName: "Mac A", floor: PF.floor))
        _ = try executor.createLibrary()
        let file = try #require(world.liveFormat3)
        #expect(file.words != nil, "a library was born with no words lock")
        #expect(file.passphrase == nil)
    }

    /// No key change can write a file the twelve words would not open: a lock
    /// set with neither the words nor the master's twelve-words copy is
    /// refused before it is written.
    @Test func aKeyFileTheWordsWouldNotOpenIsRefused() throws {
        let p = try PF.passphraseKey("the day I left")
        let k1 = StoreKey.mint(), k2 = StoreKey.mint()
        #expect(throws: (any Error).self) {
            _ = try KeyFile.building(libraryID: PF.id(), key: k1, epoch: 1, locks: NewKeyLocks(passphrase: p))
        }
        let words = try PF.words()
        let file = try KeyFile.building(
            libraryID: PF.id(), key: k1, epoch: 1, locks: NewKeyLocks(passphrase: p, words: try PF.wordsKey(words)))
        #expect(throws: (any Error).self) {
            _ = try file.rekeyed(from: k1, to: k2, kind: .castle, locks: NewKeyLocks(passphrase: p), at: PF.t0)
        }
    }
}

@Suite("VX-378 U2 — rule 2: the words a creation mints come back once, and open the library")
struct U2CreatedWordsTests {
    @Test func theWordsHandedBackOpenTheNewKeyFile() throws {
        let world = ExecutorWorld()
        let executor = ProtectionExecutor(
            leaves: world.leaves,
            configuration: ExecutorConfiguration(scope: EX.scope, libraryID: "", deviceName: "Mac A", floor: PF.floor))
        let created = try executor.createLibrary(passphrase: "the day I left")
        #expect(created.words.count == 12)
        let file = try #require(world.liveFormat3)
        #expect(try file.open(words: created.words) == created.library.key)
        #expect(!"\(created)".contains(created.words[0]), "the words leak through a description")
    }
}
