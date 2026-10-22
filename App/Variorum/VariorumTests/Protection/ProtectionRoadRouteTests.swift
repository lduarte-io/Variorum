//
//  ProtectionRoadRouteTests.swift
//  VariorumTests — VX-306 U1b piece 6: THE NEW ROAD'S ROUTE, end to end through `AppBootstrap` (the one switch
//  turned on by a test harness) on a temp slot and a THROWAWAY keychain scope: the lifecycle's stage 1 (a fresh
//  slot → the creation → the library open with nothing in front — VX-307 U2b retired the creation-time words card on
//  the Mac — the four remembered things written,
//  and — since VX-329 U1 — no file of today's names beside it), the quiet relaunch, stage 5's on-device half (the silent item gone → the
//  Apple wrap opens silently and the item is re-made — rule 8), both quiet roads gone → the lobby's typed field →
//  the words open it, and the throwing edges: K5's `recordMissing` → the missing face with no sentence; a file in
//  the live place that is no key file → the lobby, never a crash (P-VX306-U1a-2); an unlistable keychain → the
//  lobby's typed field with its reason (P-VX306-U1a-3); the missing face's Start a New Library → the core's
//  creation, the missing library's key file stepping aside first (P-VX306-U1b-3).
//

import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1b — the new road's route through AppBootstrap (throwaway scope, temp slot)", .serialized)
@MainActor
struct ProtectionRoadRouteTests {
    /// Stage 1, then a relaunch: the open with NOTHING in front of it (VX-307 U2b — rules 2–3 as amended: the words are
    /// never shown before the first screen), rule 21's four things, nothing of today's names (VX-329 U1) — and a silent reopen. Before VX-412
    /// this arm landed on `.newLibraryWords` (the creation-time card) — the flip's red-on-old.
    @Test func aFreshSlotCreatesAndOpensWithNothingInFrontThenReopensQuietly() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let bootstrap = world.bootstrap()
            #expect(!ProtectionRoad.showsWordsAtCreation, "the Mac's first open has no words card")
            await bootstrap.awaitOpen()
            if case .opening = bootstrap.state { await bootstrap.awaitOpen() }
            guard case .ready(let session) = bootstrap.state else {
                Issue.record("a fresh slot opens straight on — no words card, no lobby: \(bootstrap.state)")
                return
            }
            // The library has its twelve words from birth (rule 2) — a words lock on its key file — but no face held them.
            let system = world.system()
            let live = try #require(try system.leaves.keyFiles.readLiveKeyFile())
            #expect(live.opensWithTheWords, "rule 2: twelve words from the moment it is created")
            #expect(live.passphrase == nil, "rule 3: the passphrase is asked later")
            #expect(FileManager.default.fileExists(atPath: world.slot.places.livedHereMarker.path))
            let road = try #require(bootstrap.roadSession)
            #expect(road.isFresh)
            // The app's store opened over the core's library: today's tables beside the protection record.
            let tables = try await session.database.read { db in
                try String.fetchAll(db, sql: "SELECT name FROM sqlite_master WHERE type = 'table'")
            }
            #expect(tables.contains("protection_record") && tables.contains("container"))
            // VX-329 U1: today's store id (a stub envelope beside the store, read only by today's sync custody, dials and
            // backup log) left with today's road — nothing of today's key-file names is written beside the library now.
            let besideTheSlot = try FileManager.default.contentsOfDirectory(
                atPath: world.slotURL.deletingLastPathComponent().path)
            #expect(!besideTheSlot.contains { $0.hasPrefix("variorum-keys") }, "no file of today's names: \(besideTheSlot)")
            // Rule 21's four things, as this Mac remembers them; the silent item stamped; the Apple key stamped.
            let libraryID = try #require(road.library.record?.libraryID)
            #expect(try KeychainMemoryLeaf(scope: world.scope.scope).rememberedLibraryIDs() == [libraryID])
            let items = try KeychainCustodyLeaf(scope: world.scope.scope).custodyItems()
            #expect(items.map(\.itemClass) == [.silent] && items.first?.libraryID == libraryID)
            #expect(try world.apple.appleKeyIDs(ofLibrary: libraryID).count == 1)
            #expect(road.report.faults.isEmpty, "\(road.report.faults)")

            // A relaunch: the quiet road opens at once — no lobby, no card.
            let again = world.bootstrap()
            await again.awaitOpen()
            guard case .ready = again.state else {
                Issue.record("a relaunch opens quietly: \(again.state)")
                return
            }
            #expect(again.roadSession?.library.record?.libraryID == libraryID)
            #expect(again.roadSession?.isFresh == false)
            #expect(!again.canLock, "Standard never locks (VX-308 U4 — VX-445: the new road's lock is Castle's)")
        }
    }

    /// Stage 5's on-device half (rule 8): the silent item deleted by hand → the Apple wrap opens silently, and
    /// `remakeOnDeviceItem` makes the silent item again. Both gone → the typed field at once → the words open it.
    @Test func theQuietRoadsReMakeEachOtherAndWithBothGoneTheWordsOpen() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (created, words) = try await world.created()
            let fingerprint = created.library.fingerprint
            let custody = KeychainCustodyLeaf(scope: world.scope.scope)
            try custody.deleteCustody(fingerprint: fingerprint, itemClass: .silent)

            let viaApple = world.bootstrap()
            await viaApple.awaitOpen()
            guard case .ready = viaApple.state else {
                Issue.record("the Apple wrap opens silently: \(viaApple.state)")
                return
            }
            #expect(viaApple.roadSession?.report.repairsDone.contains(.remakeOnDeviceItem) == true)
            #expect(try custody.custodyItems().contains(CustodyItemFact(fingerprint: fingerprint, itemClass: .silent)),
                    "rule 8: the on-device road re-made")

            // Both quiet roads gone: the silent item and the Apple key.
            try custody.deleteCustody(fingerprint: fingerprint, itemClass: .silent)
            for id in try world.apple.readableAppleKeyIDs() { try world.apple.deleteAppleKey(id: id) }
            let locked = world.bootstrap()
            await locked.awaitOpen()
            guard case .roadLobby(let lobby) = locked.state else {
                Issue.record("no quiet road remains — the lobby: \(locked.state)")
                return
            }
            #expect(lobby.face.wordsRoad == .field, "no passphrase yet — the words field at once")
            #expect(!lobby.face.passphraseField)
            await lobby.unlock(wordsText: "these are not twelve words")
            #expect(lobby.message != nil, "a wrong attempt says why and opens nothing")
            await lobby.unlock(wordsText: words.joined(separator: " "))
            await locked.awaitOpen()
            guard case .ready = locked.state else {
                Issue.record("the words open the library: \(locked.state)")
                return
            }
            let report = try #require(locked.roadSession?.report)
            #expect(report.repairsDone.contains(.remakeOnDeviceItem))
            #expect(report.repairsDone.contains(.remakeAppleRoad), "rule 8: a fresh Apple road, quietly")
        }
    }

    /// K5 (rule 26): a store with no protection record opens through a road and is not handled — the missing
    /// face, with no sentence about the store.
    @Test func aStoreWithNoRecordLandsOnTheMissingFaceWithNoSentence() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let key = StoreKey.mint()
            // A keyed library from before this design (its record table empty), its key in a silent item.
            _ = try AppDatabase.onDisk(url: world.slotURL, key: key)
            try KeychainCustodyLeaf(scope: world.scope.scope).writeCustody(key, itemClass: .silent, libraryID: "pre-design")
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .libraryMissing(let missing) = bootstrap.state else {
                Issue.record("recordMissing → the missing face: \(bootstrap.state)")
                return
            }
            #expect(missing.lastError == nil, "no sentence about the store (her word)")
        }
    }

    /// P-VX306-U1a-2: a file in the live place that is no format-3 key file never crashes the route — the lobby,
    /// with its one line; nothing is written over it.
    @Test func aLiveKeyFileThatIsNotAKeyFileLeavesTheLobbyStandingAndIsNeverWrittenOver() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await world.created()
            let junk = Data("not a key file".utf8)
            try junk.write(to: world.slot.places.liveKeyFile)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .roadLobby(let lobby) = bootstrap.state else {
                Issue.record("the lobby, never a crash: \(bootstrap.state)")
                return
            }
            #expect(lobby.face.liveKeyFileUnreadable)
            #expect(try Data(contentsOf: world.slot.places.liveKeyFile) == junk, "nothing written over it")
        }
    }

    /// P-VX306-U1a-3: a keychain that cannot be listed stops the facts — the typed field with its reason, never
    /// rule 27's refusal on a guess.
    @Test func anUnlistableKeychainShowsTheTypedFieldWithItsReason() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await world.created()
            let planted = PlantedCustodyLeaf()
            planted.listingFails = true
            world.custody = planted
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .roadLobby(let lobby) = bootstrap.state else {
                Issue.record("the lobby: \(bootstrap.state)")
                return
            }
            #expect(lobby.face.keychainUnreadable)
            #expect(lobby.face.noKeyFileAnywhere == nil)
            #expect(lobby.face.passphraseField && lobby.face.wordsRoad == .disclosure)
        }
    }

    /// The missing face's Start a New Library on the new road: the core's creation, the missing library's key file
    /// stepping aside into `Previous Libraries/<stamp>/` first (P-VX306-U1b-3), then the words card.
    @Test func startANewLibraryOnTheMissingFaceCreatesAndSetsTheOldKeyFileAside() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await world.created()
            let oldKeyFile = try Data(contentsOf: world.slot.places.liveKeyFile)
            // The library file goes missing (its key file and the marker stay).
            ProtectionLibraryFiles.removeWithSidecars(world.slotURL)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .libraryMissing(let missing) = bootstrap.state else {
                Issue.record("a library lived here and is gone — the missing face: \(bootstrap.state)")
                return
            }
            await missing.startNewLibrary()
            #expect(missing.lastError == nil)
            // VX-307 U2b: the creation opens straight on — no words card (rules 2–3 as amended).
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("the creation opens with nothing in front: \(bootstrap.state)")
                return
            }
            let aside = try FileManager.default.contentsOfDirectory(atPath: world.slot.places.previousLibraries.path)
            let folder = try #require(aside.first)
            let moved = try Data(contentsOf: world.slot.places.previousLibraries
                .appendingPathComponent(folder).appendingPathComponent(ProtectionNames.keyFilename))
            #expect(moved == oldKeyFile, "the missing library's key file stepped aside whole, never written over")
        }
    }

    /// THE LADDER'S ROUND-1 m1, through the bootstrap (the reviewer's pin): a format-3 key file and a silent item whose
    /// key opens a RECORD-LESS store → the route → the missing face (K5) → *Start a New Library* → the store aside WHOLE
    /// in `Previous Libraries/<stamp>/` (its key file with it, never written over) and the words card. Before the fix
    /// the face's one act met the creation's no-clobber belt and said *Variorum couldn't create your library.* forever.
    @Test func startANewLibraryOnTheMissingFaceOverARecordLessStoreSetsItAsideAndOpens() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (old, _) = try await world.created()
            let oldKey = old.key
            let oldKeyFile = try Data(contentsOf: world.slot.places.liveKeyFile)
            // The slot's library replaced by a record-less store under the SAME key (its record table empty).
            ProtectionLibraryFiles.removeWithSidecars(world.slotURL)
            do { _ = try AppDatabase.onDisk(url: world.slotURL, key: oldKey) }
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .libraryMissing(let missing) = bootstrap.state else {
                Issue.record("K5: the silent item opens a store with no record — the missing face: \(bootstrap.state)")
                return
            }
            await missing.startNewLibrary()
            #expect(missing.lastError == nil, "the face's one act succeeds: \(missing.lastError ?? "")")
            // VX-307 U2b: the creation opens straight on — no words card (rules 2–3 as amended).
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("the creation opens with nothing in front: \(bootstrap.state)")
                return
            }
            let aside = try FileManager.default.contentsOfDirectory(atPath: world.slot.places.previousLibraries.path)
            let folder = world.slot.places.previousLibraries.appendingPathComponent(try #require(aside.first), isDirectory: true)
            #expect(aside.count == 1)
            #expect(try Data(contentsOf: folder.appendingPathComponent(ProtectionNames.keyFilename)) == oldKeyFile,
                    "the record-less store's key file stepped aside byte-equal, never written over")
            #expect(ProtectionLibraryFiles.opens(folder.appendingPathComponent(CatalogNames.libraryFilename), key: oldKey),
                    "the record-less store stepped aside whole")
        }
    }

    /// A hosted test run (the test host IS the dev-store app) runs the road read-only: it never creates.
    @Test func aReadOnlyRoadNeverCreates() async throws {
        await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let bootstrap = world.bootstrap(writes: false)
            await bootstrap.awaitOpen()
            guard case .failed(let error) = bootstrap.state else {
                Issue.record("a read-only road over an empty slot creates nothing: \(bootstrap.state)")
                return
            }
            #expect(error.reason == ProtectionWords.testRunNeverCreates)
            #expect(!FileManager.default.fileExists(atPath: world.slotURL.path))
            #expect(world.scope.accounts(ProtectionNames.custodyService).isEmpty)
        }
    }
}
