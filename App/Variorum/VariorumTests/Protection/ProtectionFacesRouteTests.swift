//
//  ProtectionFacesRouteTests.swift
//  VariorumTests — VX-306 U2: THE HONEST FACES end to end through `AppBootstrap` (the one switch turned on by a test
//  harness) on a temp slot and a THROWAWAY keychain scope (the real custody and memory leaves; an in-memory Apple
//  leaf): the interlude STATE between the unlock and the library's open (rule 21's offer: *Use it* → the open with the
//  receipt; *Not now* → the open, nothing written), the open library's faces (`roadStanding`: rule 1's restore
//  receipt, rule 3's first-backup moment), the set-passphrase sheet through the bootstrap's faces model on the real
//  custody, and rule 27's lobby starting a new library through the bootstrap. Mac only (the keychain); the same
//  states from planted facts are the per-piece suites'.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U2 — the honest faces through AppBootstrap (throwaway scope, temp slot)", .serialized)
@MainActor
struct ProtectionFacesRouteTests {
    /// A stray key file beside the library — the open stops at the OFFER card; *Use it* → the library opens, the
    /// library's own file is back, and the receipt naming this Mac's keychain is owed to the status seam.
    @Test func aStrayBesideStopsAtTheOfferAndUseItOpensWithTheReceipt() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (created, _) = try await world.created()
            try world.system().leaves.keyFiles.writeLiveKeyFile(
                try KeyFile.building(libraryID: "another-library", key: StoreKey.mint(), epoch: 1,
                                     locks: NewKeyLocks(words: try WordsKey.derive(try RecoveryPhrase.generate()))))
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .roadInterlude(let interlude) = bootstrap.state else {
                Issue.record("the offer is said before the library shows: \(bootstrap.state)")
                return
            }
            guard case .offer(let offer, _)? = interlude.current else {
                Issue.record("the offer card")
                return
            }
            #expect(offer.source == .thisMacsKeychain)
            await interlude.useIt()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("the library opens after the answer: \(bootstrap.state)")
                return
            }
            #expect(try world.system().leaves.keyFiles.readLiveKeyFile()?.fingerprint == created.library.fingerprint)
            let standing = try #require(bootstrap.roadStanding)
            var spoken: [String] = []
            standing.speak = { spoken.append($0) }
            #expect(spoken.contains(ProtectionWords.offerRestoredFromKeychain), "\(spoken)")
        }
    }

    /// *Not now*: the library opens all the same, and the stray beside it is exactly as it was.
    @Test func notNowOpensTheLibraryAndWritesNothing() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await world.created()
            let stray = try KeyFile.building(
                libraryID: "another-library", key: StoreKey.mint(), epoch: 1,
                locks: NewKeyLocks(words: try WordsKey.derive(try RecoveryPhrase.generate())))
            try world.system().leaves.keyFiles.writeLiveKeyFile(stray)
            let bytes = try Data(contentsOf: world.slot.places.liveKeyFile)
            let memory = world.scope.accounts(ProtectionNames.memoryService)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .roadInterlude(let interlude) = bootstrap.state else {
                Issue.record("the offer card: \(bootstrap.state)")
                return
            }
            interlude.notNow()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("the library opens after Not now: \(bootstrap.state)")
                return
            }
            #expect(try Data(contentsOf: world.slot.places.liveKeyFile) == bytes, "the stray is untouched")
            #expect(world.scope.accounts(ProtectionNames.memoryService) == memory)
        }
    }

    /// The live key file gone: the open restores this Mac's sealed copy and owes rule 1's receipt; a library with no
    /// backup yet shows rule 3's first-backup moment on the open library's faces.
    @Test func theRestoreReceiptAndTheFirstBackupMomentReachTheOpenLibrarysFaces() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await world.created()
            try FileManager.default.removeItem(at: world.slot.places.liveKeyFile)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("the silent item opens it: \(bootstrap.state)")
                return
            }
            let standing = try #require(bootstrap.roadStanding)
            var spoken: [String] = []
            standing.speak = { spoken.append($0) }
            #expect(spoken == [ProtectionWords.restoredFromMirror])
            #expect(standing.reminder.showing?.moment == .beforeFirstBackup)
            #expect(FileManager.default.fileExists(atPath: world.slot.places.liveKeyFile.path))
        }
    }

    /// The set-passphrase sheet through the bootstrap's faces model, on the real custody: set, the reminder done, the
    /// receipt spoken, the key file carrying the passphrase lock.
    @Test func theSetPassphraseSheetThroughTheBootstrapSetsTheFirstPassphrase() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await world.created()
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            let standing = try #require(bootstrap.roadStanding)
            var spoken: [String] = []
            standing.speak = { spoken.append($0) }
            var closed = 0
            let sheet = standing.makeSetPassphraseSheet { closed += 1 }
            await sheet.submit(passphrase: "a passphrase", again: "a passphrase")
            #expect(closed == 1 && sheet.refusal == nil)
            #expect(spoken.last == ProtectionWords.passphraseSetReceipt)
            #expect(standing.reminder.showing == nil)
            #expect(try world.system().leaves.keyFiles.readLiveKeyFile()?.passphrase != nil)
            #expect(bootstrap.roadSession?.library.record?.passphraseSet == true)
            #expect(standing.makeSetPassphraseSheet {}.alreadySet)
        }
    }

    /// Rule 27 before unlock through the bootstrap: the lobby's face, and its *Start a New Library* → the new library open
    /// (VX-307 U2b: no words card in front of it).
    @Test func rule27sLobbyStartsANewLibraryThroughTheBootstrap() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await world.created()
            try FileManager.default.removeItem(at: world.slot.places.liveKeyFile)
            world.scope.purge()
            for id in try world.apple.readableAppleKeyIDs() { try world.apple.deleteAppleKey(id: id) }
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .roadLobby(let lobby) = bootstrap.state else {
                Issue.record("rule 27's lobby: \(bootstrap.state)")
                return
            }
            #expect(lobby.face.noKeyFileAnywhere != nil)
            #expect(lobby.offersStartNew)
            await lobby.startNewLibrary()
            // VX-307 U2b: the creation opens straight on — no words card (rules 2–3 as amended).
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("a new library opens with nothing in front: \(bootstrap.state)")
                return
            }
            #expect(!(try FileManager.default.contentsOfDirectory(atPath: world.slot.places.previousLibraries.path)).isEmpty,
                    "the unopenable library stepped aside whole")
        }
    }
}
