//
//  ProtectionOpenRoadPlantedTests.swift
//  VariorumTests — VX-306 U1b piece 6: THE NEW ROAD (`ProtectionOpenRoad`) over PLANTED leaves — no keychain at all
//  (planted custody and memory, an in-memory Apple leaf) and a temp slot with the real file leaves — so the route's
//  every arm runs anywhere (this file also runs headless in the implementer's SwiftPM harness, the record says
//  how). Stage 1 (create → the twelve words), a quiet reopen, rule 8's quiet roads re-making each other, the
//  typed roads over the live key file AND rule 1's keychain mirror (with the mirror written back after), K5's
//  `recordMissing`, a live place holding no key file (P-VX306-U1a-2), an unlistable keychain (P-VX306-U1a-3),
//  and the read-only road of a hosted test run.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
final class PlantedRoad {
    let slot = TempSlot()
    let custody = PlantedCustodyLeaf()
    let memory = PlantedMemoryLeaf()
    let apple = InMemoryAppleKeysLeaf()
    /// This Mac's biometry for the systems made from here on (VX-307 U2a: the crossings' Touch ID arms).
    var biometry = BiometryFacts.none

    func system() -> ProtectionSystem {
        ProtectionSystem(
            scope: "vx306-planted", places: slot.places, deviceName: "Test Mac", floor: .relaxedForTests,
            custody: custody, syncKeys: EmptySyncKeysLeaf(), apple: apple, memory: memory,
            biometry: FixedBiometryLeaf(biometry), ids: FastIDsLeaf())
    }

    func context(writes: Bool = true) -> RoadContext {
        RoadContext(system: system(), session: .signedOut, writes: writes)
    }

    func created() async throws -> (session: ProtectionRoadSession, words: [String]) {
        guard case .created(let session, let words) = await ProtectionOpenRoad.route(context()) else {
            throw RoadWorld.RoadWorldError.notCreated
        }
        return (session, words.words)
    }

    var silentItems: [CustodyItemFact] { custody.items.keys.filter { $0.itemClass == .silent } }
}

@Suite("VX-306 U1b — the new road over planted leaves (no keychain)")
@MainActor
struct ProtectionOpenRoadPlantedTests {
    @Test func aFreshSlotIsCreatedWithItsWordsAndEveryHomeOfRule1() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        #expect(words.count == 12)
        #expect(session.isFresh)
        let libraryID = try #require(session.library.record?.libraryID)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(live.libraryID == libraryID && live.opensWithTheWords && live.passphrase == nil && live.apple != nil)
        #expect(road.silentItems.count == 1 && road.silentItems.first?.libraryID == libraryID)
        #expect(road.memory.items.keys.sorted() == [libraryID], "this Mac remembers ONE library — the one it made")
        #expect(try road.apple.appleKeyIDs(ofLibrary: libraryID).count == 1)
        #expect(FileManager.default.fileExists(atPath: road.slot.places.livedHereMarker.path))
        #expect(session.report.faults.isEmpty, "\(session.report.faults)")
    }

    @Test func aRelaunchOpensQuietlyWithNoNoticeAndNothingOwed() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the silent item opens it at once")
            return
        }
        #expect(!session.isFresh)
        #expect(session.key == created.key)
        #expect(session.report.notice == nil)
        #expect(session.report.repairsDone.isEmpty, "\(session.report.repairsDone)")
        #expect(session.report.faults.isEmpty, "\(session.report.faults)")
    }

    /// RULE 8 — the on-device item gone: the Apple wrap opens it silently, the item is re-made.
    @Test func theSilentItemGoneTheAppleWrapOpensAndTheItemIsReMade() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        road.custody.items = [:]
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the Apple wrap is a quiet road")
            return
        }
        #expect(session.key == created.key)
        #expect(session.report.repairsDone.contains(.remakeOnDeviceItem))
        #expect(road.silentItems.map(\.fingerprint) == [created.library.fingerprint])
    }

    /// Both quiet roads gone: the lobby — the words (no passphrase yet) — then the words open it and the quiet
    /// roads come back (rule 8: "quietly makes a fresh Apple road").
    @Test func bothQuietRoadsGoneTheWordsOpenAndTheQuietRoadsAreReMade() async throws {
        let road = PlantedRoad()
        let (created, words) = try await road.created()
        road.custody.items = [:]
        road.apple.keys = [:]
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("no quiet road remains — the lobby")
            return
        }
        #expect(lobby.offeredTyped == [.words])
        #expect(ProtectionLobbyFace.derive(lobby).wordsRoad == .field)
        guard case .refused(let sentence) = await ProtectionOpenRoad.openTyped(road.context(), secret: .words(
            try RecoveryPhrase.generate())) else {
            Issue.record("another library's words open nothing")
            return
        }
        #expect(sentence == ProtectionWords.wordsDoNotOpen)
        guard case .refused(let short) = await ProtectionOpenRoad.openTyped(road.context(), secret: .words(["one", "two"]))
        else {
            Issue.record("two words are refused")
            return
        }
        #expect(short == "There are twelve words — you entered 2.")
        guard case .opened(let session) = await ProtectionOpenRoad.openTyped(road.context(), secret: .words(words)) else {
            Issue.record("the words open the library")
            return
        }
        #expect(session.key == created.key)
        #expect(session.report.repairsDone.contains(.remakeOnDeviceItem))
        #expect(session.report.repairsDone.contains(.remakeAppleRoad))
        #expect(!road.silentItems.isEmpty && !road.apple.keys.isEmpty)
    }

    /// RULE 1's third home: with the live key file gone too, the words open the library through THIS MAC's sealed
    /// mirror (the N5 hand-forward — the typed roads include it), and the mirror is written back beside the library.
    @Test func theWordsOpenThroughTheKeychainMirrorAndTheKeyFileIsWrittenBack() async throws {
        let road = PlantedRoad()
        let (created, words) = try await road.created()
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        road.custody.items = [:]
        road.apple.keys = [:]
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("no quiet road, no live key file — the lobby")
            return
        }
        #expect(lobby.offeredTyped.contains(.words), "the mirror's words lock is offered")
        #expect(ProtectionLobbyFace.derive(lobby).noKeyFileAnywhere == nil)
        guard case .opened(let session) = await ProtectionOpenRoad.openTyped(road.context(), secret: .words(words)) else {
            Issue.record("the words open the library through the mirror")
            return
        }
        #expect(session.key == created.key)
        #expect(session.report.repairsDone.contains(.restoreKeyFileFromMirror))
        let back = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(back.fingerprint == live.fingerprint && back.words == live.words)
    }

    /// K5 (rule 26): a store with no protection record is not handled — the missing face.
    @Test func aStoreWithNoRecordRoutesToTheMissingFace() async throws {
        let road = PlantedRoad()
        let key = StoreKey.mint()
        do { _ = try AppDatabase.onDisk(url: road.slot.places.slot, key: key) }
        try road.custody.writeCustody(key, itemClass: .silent, libraryID: "pre-design")
        guard case .libraryMissing = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("recordMissing → the missing face")
            return
        }
    }

    /// THE LADDER'S ROUND-1 m1 (K5's missing face): a format-3 key file and a silent item whose key opens a
    /// RECORD-LESS store (rule 26's class — a hand-emptied record table, a recreation-shaped store) route to the missing
    /// face; its *Start a New Library* (`startNewLibraryFromAFace` — the bootstrap's one road for both faces) sets that
    /// store aside WHOLE, its key file with it, never written over, and the creation goes on to the words. RED on the
    /// pre-fix road (the missing face set the key file aside only over an EMPTY slot): the creation met its no-clobber
    /// belt — `.failed`, nothing aside, the live key file already written over by the new library's.
    @Test func startANewLibraryOverARecordLessStoreSetsItAsideWholeAndCreates() async throws {
        let road = PlantedRoad()
        let (old, _) = try await road.created()
        let oldKey = old.key
        let oldKeyFile = try Data(contentsOf: road.slot.places.liveKeyFile)
        // The slot's library replaced by a record-less store under the SAME key (its record table empty).
        ProtectionLibraryFiles.removeWithSidecars(road.slot.places.slot)
        do { _ = try AppDatabase.onDisk(url: road.slot.places.slot, key: oldKey) }
        guard case .libraryMissing = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("K5: the silent item opens a store with no record — the missing face")
            return
        }
        guard case .created(let created, let words) = await ProtectionOpenRoad.startNewLibraryFromAFace(road.context()) else {
            Issue.record("the missing face's Start a New Library acts: the store aside, the creation, the words")
            return
        }
        #expect(words.words.count == 12)
        #expect(created.key != oldKey)
        let newLive = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(newLive.libraryID == created.library.record?.libraryID && newLive.fingerprint == created.library.fingerprint)
        #expect(ProtectionLibraryFiles.opens(road.slot.places.slot, key: created.key), "the new library in the slot")
        // The record-less store and its key file, WHOLE in Previous Libraries — never written over.
        let aside = try FileManager.default.contentsOfDirectory(atPath: road.slot.places.previousLibraries.path)
        #expect(aside.count == 1, "one folder aside: \(aside)")
        let folder = road.slot.places.previousLibraries.appendingPathComponent(try #require(aside.first), isDirectory: true)
        #expect(try Data(contentsOf: folder.appendingPathComponent(ProtectionNames.keyFilename)) == oldKeyFile,
                "the record-less store's key file stepped aside byte-equal, never written over")
        #expect(ProtectionLibraryFiles.opens(folder.appendingPathComponent(CatalogNames.libraryFilename), key: oldKey),
                "the record-less store stepped aside whole — it still opens with its own key")
    }

    /// P-VX306-U1a-2: a file in the live place that is no key file never crashes — the lobby, its flag set.
    @Test func aLivePlaceHoldingNoKeyFileLeavesTheLobbyStanding() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        try Data("not a key file".utf8).write(to: road.slot.places.liveKeyFile)
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the lobby, never a crash")
            return
        }
        #expect(lobby.liveKeyFileUnreadable)
        #expect(try Data(contentsOf: road.slot.places.liveKeyFile) == Data("not a key file".utf8))
    }

    /// P-VX306-U1a-3: an unlistable keychain — no facts, the typed field with its reason; over an empty slot, no
    /// creation on a guess.
    @Test func anUnlistableKeychainYieldsNoFactsAndNeverCreatesOnAGuess() async throws {
        let road = PlantedRoad()
        road.custody.listingFails = true
        guard case .failed(let sentence) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("an empty slot with an unlistable keychain creates nothing")
            return
        }
        #expect(sentence == ProtectionWords.keychainUnreadableNoLibrary)
        road.custody.listingFails = false
        _ = try await road.created()
        road.custody.listingFails = true
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the lobby")
            return
        }
        #expect(lobby.facts == nil)
        #expect(ProtectionLobbyFace.derive(lobby).keychainUnreadable)
    }

    /// A hosted test run: read-only — never a creation, never a repair.
    @Test func theReadOnlyRoadNeverCreatesAndNeverRepairs() async throws {
        let road = PlantedRoad()
        guard case .failed(let sentence) = await ProtectionOpenRoad.route(road.context(writes: false)) else {
            Issue.record("read-only over an empty slot creates nothing")
            return
        }
        #expect(sentence == ProtectionWords.testRunNeverCreates)
        _ = try await road.created()
        road.custody.items = [:]
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context(writes: false)) else {
            Issue.record("read-only still opens (through the Apple wrap)")
            return
        }
        #expect(session.report.repairsDone.isEmpty)
        #expect(road.silentItems.isEmpty, "no silent item re-made on a read-only road")
        #expect(!session.writes)
    }
}
