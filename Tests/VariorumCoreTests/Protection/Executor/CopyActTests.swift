//
//  CopyActTests.swift
//  VariorumCoreTests — VX-305 U3: the copy acts (design §3.7) — opening a
//  copy of this library (re-encrypted under the current key, the current
//  facts, never lowering the mode, no act carried), landing a different
//  library (a fresh key, an empty history, one secret then the other typed or
//  made new, none through a readable Apple key), Send Library, the plaintext
//  export, the offer's delete.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A backup copy of `fixture`'s library as it is now, then the library moves on.
func copyOfToday(_ fixture: EX, id: String = "container:Backups/copy-1.sqlite") -> String {
    fixture.world.copies[id] = fixture.world.live
    fixture.world.live?.generation += 1
    return id
}

/// A sender's library, as a pair in the receiver's folder.
func sentPair(_ sender: EX, into receiver: EX, id: String = "farFolder:Hand-off/pair.sqlite") -> LandingPair {
    receiver.world.copies[id] = ExecutorWorld.LibraryFile(
        fingerprint: PF.fp(sender.key), record: sender.liveRecord, generation: 42)
    return LandingPair(copyID: id, keyFile: .format3(sender.world.liveFormat3!), record: sender.liveRecord)
}

@Suite("VX-305 U3 — opening a copy of this library: the current key, the current facts, no act carried")
struct OpenCopyTests {
    @Test func aCopyIsReEncryptedUnderTheCurrentKeyAndTakesTheCurrentFacts() async throws {
        let fixture = try EX(.castle)
        let copy = copyOfToday(fixture)
        let k = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.openCopy(&library, copyID: copy, opener: k, copyRecord: fixture.world.copies[copy]?.record)
        #expect(fixture.world.writeLog(naming: [PF.fp(k): "K"]) == [
            "record K", "memory K", "plan", "stage K", "plan", "staged-record K", "plan", "swap K", "plan",
            "memory K", "plan", "record K", "memory K", "plan-",
        ])
        #expect(fixture.world.live?.generation == 1)          // her writing as it was
        #expect(fixture.world.live?.fingerprint == PF.fp(k))  // under the CURRENT key
        #expect(fixture.world.aside.count == 1)               // the library she had, kept aside
        expectSettled(fixture, library)
    }

    @Test func aCastleEraCopyOpenedIntoAStandardLibraryTakesTheStandardModeAndNeverLowersAnything() async throws {
        let fixture = try EX(.castle)
        let castleCopy = copyOfToday(fixture)
        let castleKey = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        fixture.key = library.key
        // The Castle-era copy opens through the anchor with the leave day's passphrase.
        let anchor = try #require(fixture.world.liveFormat3?.anchor)
        let opener = try anchor.open(.passphrase(fixture.passphrase), floor: PF.floor).outgoing.key
        #expect(opener == castleKey)
        _ = try await executor.openCopy(&library, copyID: castleCopy, opener: opener, copyRecord: fixture.world.copies[castleCopy]?.record)
        #expect(fixture.liveRecord?.mode == .standard && fixture.world.live?.fingerprint == PF.fp(library.key))
        // The family tree still knows the Castle key — this library's own line.
        #expect(fixture.liveRecord?.familyTree.entry(PF.fp(castleKey))?.kind == .castle)
        expectSettled(fixture, library)
    }

    @Test func aCopysActInFlightIsClearedWhenItsOpened() async throws {
        let fixture = try EX(.standard)
        // A copy taken while an act was in flight (a lock-time byte copy).
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let (inFlight, _) = library.section.beginningAct(.replaceAllKeys, from: library.fingerprint, to: nil, at: PF.t0)
        try executor.writeFacts(&library, section: inFlight)
        let copy = copyOfToday(fixture)
        try executor.writeFacts(&library, section: library.section.endingAct(sequence: inFlight.actInFlight!.sequence))
        _ = try await executor.openCopy(&library, copyID: copy, opener: fixture.key, copyRecord: fixture.world.copies[copy]?.record)
        let reopened = try fixture.executor().unlock(with: fixture.key)
        #expect(reopened.section.actInFlight == nil)
    }

    @Test func aCrashAfterEveryWriteFinishesOrNeverHappened() async throws {
        for dropPlan in [false, true] {
            try await CrashHarness.everywhere(
                { let f = try EX(.standard); _ = copyOfToday(f); return f },
                act: { fixture, executor, library in
                    _ = try await executor.openCopy(
                        &library, copyID: "container:Backups/copy-1.sqlite", opener: fixture.key,
                        copyRecord: fixture.world.copies["container:Backups/copy-1.sqlite"]?.record)
                },
                finished: { fixture, _ in fixture.world.live?.generation == 1 },
                neverHappened: { fixture, _ in fixture.world.live?.generation == 2 },
                dropPlan: dropPlan, resumeMayRollBack: true)
        }
    }
}

@Suite("VX-305 U3 — landing a different library: a fresh key, an empty history, one secret")
struct LandTests {
    @Test func aCastlePairLandsWithItsPassphraseAloneTheWordsMadeNew() async throws {
        let sender = try EX(.castle)
        let receiver = try EX(.standard)
        let pair = sentPair(sender, into: receiver)
        let senderFile = sender.world.liveFormat3!
        let executor = receiver.executor()
        var library = try receiver.unlocked(executor)
        let newWords = try PF.words()
        _ = try await executor.land(
            &library, pair: pair, opener: sender.key,
            typed: TypedSecrets(passphrase: sender.passphrase, words: newWords, wordsAreNew: true), gate: .touchID)
        let landed = try #require(receiver.liveRecord)
        #expect(landed.libraryID == sender.libraryID && landed.mode == .castle)
        #expect(library.key != sender.key)                                // a FRESH key — never held by two Macs
        let live = try #require(receiver.world.liveFormat3)
        #expect(live.history.isEmpty && live.anchor == nil && live.apple == nil)
        #expect(try live.open(passphrase: .passphrase(sender.passphrase), floor: PF.floor) == library.key)
        #expect(try live.open(words: newWords) == library.key)
        #expect(receiver.world.copies[pair.copyID]?.fingerprint == PF.fp(sender.key))  // the pair never written
        #expect(sender.world.liveFormat3 == senderFile)
        #expect(receiver.world.aside.count == 1)                          // the library she had: an older library
        #expect(receiver.custody(.touchid, library.key))
        expectSettled(receiver, library)
    }

    @Test func aCastlePairLandsWithItsWordsAloneThePassphraseMadeNew() async throws {
        let sender = try EX(.castle)
        let receiver = try EX(.castle)
        let pair = sentPair(sender, into: receiver)
        let executor = receiver.executor()
        var library = try receiver.unlocked(executor)
        _ = try await executor.land(
            &library, pair: pair, opener: sender.key,
            typed: TypedSecrets(words: sender.words, newPassphrase: "a new one"), gate: .alwaysAsk)
        let live = try #require(receiver.world.liveFormat3)
        #expect(try live.open(passphrase: .passphrase("a new one"), floor: PF.floor) == library.key)
        #expect(live.passphrase?.kdf != sender.p.kdf)
        #expect(receiver.world.custody.keys.allSatisfy { $0.fingerprint != PF.fp(library.key) })  // Always ask: no item
        expectSettled(receiver, library)
    }

    @Test func aStandardPairThroughAReadableAppleKeyLandsWithNothingTyped() async throws {
        let sender = try EX(.standard)
        let receiver = try EX(.castle, world: ExecutorWorld(icloud: sender.world.icloud, server: sender.world.server))
        let pair = sentPair(sender, into: receiver)
        let opener = try #require(try sender.world.liveFormat3?.open(apple: sender.ownApple!))
        let executor = receiver.executor()
        var library = try receiver.unlocked(executor)
        _ = try await executor.land(&library, pair: pair, opener: opener, typed: .none)
        let live = try #require(receiver.world.liveFormat3)
        #expect(receiver.liveRecord?.mode == .standard && live.passphrase == nil && live.words == nil)
        let own = try #require(live.apple?.keyID)
        #expect(own != sender.ownApple!.id)                                 // this Mac's OWN key
        #expect(library.section.appleKeys.contains { $0.id == own && $0.isOwnLibraryKey })
        #expect(receiver.custody(.silent, library.key))
        expectSettled(receiver, library)
    }

    @Test func aCrashAfterEveryWriteFinishesOrNeverHappened() async throws {
        var senderKey: StoreKey!, senderID: String!
        try await CrashHarness.everywhere(
            {
                let sender = try EX(.castle)
                let receiver = try EX(.standard)
                senderKey = sender.key
                senderID = sender.libraryID
                _ = sentPair(sender, into: receiver)
                receiver.world.catalogKeyFiles["pair"] = .format3(sender.world.liveFormat3!)
                return receiver
            },
            act: { fixture, executor, library in
                guard case .format3(let file)? = fixture.world.catalogKeyFiles["pair"] else { return }
                let pair = LandingPair(
                    copyID: "farFolder:Hand-off/pair.sqlite", keyFile: .format3(file),
                    record: fixture.world.copies["farFolder:Hand-off/pair.sqlite"]?.record)
                _ = try await executor.land(
                    &library, pair: pair, opener: senderKey,
                    typed: TypedSecrets(passphrase: fixture.passphrase, words: try PF.words(), wordsAreNew: true), gate: .touchID)
            },
            finished: { fixture, _ in fixture.liveRecord?.libraryID == senderID && fixture.world.live?.fingerprint != PF.fp(senderKey) },
            neverHappened: { fixture, _ in fixture.liveRecord?.libraryID != senderID },
            resumeMayRollBack: true)
    }
}

@Suite("VX-305 U3 — Send Library, the plaintext export, the offer's delete")
struct SmallCopyActTests {
    @Test func sendLibraryWritesThePairWithNoSharingNote() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let outcome = try await executor.sendLibrary(&library, to: "hand-off")
        #expect(outcome.done.isEmpty && outcome.notices.isEmpty)
        let sent = try #require(fixture.world.sent["hand-off"])
        #expect(sent.fingerprint == PF.fp(fixture.key) && sent.keyFile == fixture.world.liveFormat3)
        expectSettled(fixture, library)
    }

    @Test func aPlaintextExportInCastleTakesThePassphrase() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.plaintextExport(&library, typed: .none, to: "out")
        }
        _ = try await executor.plaintextExport(&library, typed: TypedSecrets(passphrase: fixture.passphrase), to: "out")
        #expect(fixture.world.exports == ["out"])
    }

    @Test func theOfferDeletesOnlyThisMacsCopiesOfAnotherLibraryAndTheLastCopysAppleKey() async throws {
        let fixture = try EX(.castle)
        let other = "cccc3333-0000-4000-8000-000000000003"
        let otherKey = AppleKeyMaterial.mint()
        fixture.world.icloud.keys[otherKey.id] = otherKey
        let otherLibraryKey = StoreKey.mint()
        let own = try KeyFile(libraryID: other, key: otherLibraryKey, epoch: 1).settingApple(otherKey, for: otherLibraryKey)
        fixture.world.ownKeyFiles[other] = own
        let mine = CatalogCopy(
            id: "c:mine", place: .container, folders: [], name: "a", kind: .backup, stamp: PF.t0, nameFingerprint8: nil,
            servingKeyFiles: [], fingerprint: nil, candidateFingerprints: [], library: other, mac: .thisMacsContainer)
        var anotherMacs = mine
        anotherMacs.id = "f:theirs"
        anotherMacs.mac = .mac8("ffffffff")
        var thisLibrarys = mine
        thisLibrarys.id = "c:ours"
        thisLibrarys.library = fixture.libraryID
        for copy in [mine, anotherMacs, thisLibrarys] { fixture.world.copies[copy.id] = fixture.world.live }
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.offerDelete(
            &library, copies: [mine, anotherMacs, thisLibrarys], catalog: Catalog(copies: [mine, anotherMacs, thisLibrarys]))
        #expect(fixture.world.copies["c:mine"] == nil)
        #expect(fixture.world.copies["f:theirs"] != nil && fixture.world.copies["c:ours"] != nil)
        #expect(fixture.world.icloud.keys[otherKey.id] == nil)
    }
}
