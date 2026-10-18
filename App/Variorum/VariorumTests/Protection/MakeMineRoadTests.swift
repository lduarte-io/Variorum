//
//  MakeMineRoadTests.swift
//  VariorumTests — VX-306 U3 pieces 2 and 3: THE TWO DOORS' ROADS over planted keychain leaves and a temp slot with the
//  real file leaves (`PlantedRoad` — no keychain, so the suite also runs headless in the implementer's SwiftPM harness).
//  Rule 17's MAKE THIS MY LIBRARY end to end through the executor: a backup pair of this library and an "AirDropped"
//  copy of another become a NEW library (a fresh identity and key, Standard, under her current pair) with the outgoing
//  library and ITS key file whole in `Previous Libraries/<stamp>/` and the restore hold written by the core writer;
//  the preflight refuses before anything is written; a refusal inside the act puts the hold back as it stood. (The
//  picked copy's suite is `PickedCopyRoadTests`.)
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// A thread-safe box for what an injected `@Sendable` road was handed.
nonisolated final class KeyBox: @unchecked Sendable {
    private let lock = NSLock()
    private var held: [StoreKey] = []
    func append(_ key: StoreKey) { lock.withLock { held.append(key) } }
    var keys: [StoreKey] { lock.withLock { held } }
}

@MainActor
enum CopyDoorsPlant {
    /// The app's ordinary open over the slot — every migration — then the pool closed (WAL drained): the library as a
    /// running app leaves it, so its backups carry the schema the doors' schema check reads.
    static func migrate(_ road: PlantedRoad, key: StoreKey) throws {
        let (_, binding) = try AppDatabase.onDisk(url: road.slot.places.slot, key: key).asRebindable()
        binding.lock()
    }

    /// A fresh library on `road`, migrated once, with one backup pair (rule 5): its session, words and the pair's row.
    static func libraryWithABackup(_ road: PlantedRoad) async throws -> (ProtectionRoadSession, [String], CopyDoorRow) {
        let (session, words) = try await road.created()
        try migrate(road, key: session.key)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try session.system.backups.takeBackupPair(with: session.key, keyFile: live, deviceID: session.library.section.deviceID)
        let row = try #require(ProtectionCopyDoors.listing(session).thisLibrary.first)
        return (session, words, row)
    }

    /// Every file under `folder` with its bytes (a write-nothing comparison of a picked folder).
    static func tree(_ folder: URL) throws -> [String: Data] {
        var bytes: [String: Data] = [:]
        let enumerator = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: [.isDirectoryKey])
        while let url = enumerator?.nextObject() as? URL {
            guard (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory != true else { continue }
            bytes[url.path.replacingOccurrences(of: folder.path, with: "")] = try Data(contentsOf: url)
        }
        return bytes
    }

    static func asideFolders(_ places: ProtectionPlaces) -> [URL] {
        let home = places.previousLibraries
        return ((try? FileManager.default.contentsOfDirectory(at: home, includingPropertiesForKeys: nil)) ?? [])
            .filter { CatalogNames.stamp($0.lastPathComponent) != nil }
    }
}

@Suite("VX-306 U3 — Make this my library and the picked copy, through the executor (planted, no keychain)", .serialized)
@MainActor
struct MakeMineRoadTests {
    /// Rule 17 on a backup of THIS library (the lifecycle's stage 9): a NEW library — fresh identity, fresh key, the
    /// posture of now (Standard), under her current pair, no past keys — and the outgoing library steps aside WHOLE
    /// with its own key file; the restore hold stands beside the new library; this Mac remembers one library.
    @Test func aBackupBecomesANewLibraryAndTheOutgoingOneStepsAsideWholeHeld() async throws {
        let road = PlantedRoad()
        let (session, words, row) = try await CopyDoorsPlant.libraryWithABackup(road)
        let oldKey = session.key
        let oldID = try #require(session.library.record?.libraryID)
        let oldFile = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        let pair = TypedSecrets(words: words)
        guard case .ready(let copy, let catalog) = ProtectionCopyDoors.preflight(
            session, row: row, copySecrets: pair, currentPair: pair) else {
            Issue.record("the preflight passes for her own backup and her own words")
            return
        }
        let minted = KeyBox()
        let result = await ProtectionCopyDoors.makeMine(
            session, copy: copy, catalog: catalog, row: row, copySecrets: pair, currentPair: pair,
            mintStoreIdentity: { minted.append($0) })
        #expect(result.outcome == .made)
        let slot = road.slot.places.slot
        let newKey = result.reopenKey
        #expect(newKey != oldKey && ProtectionLibraryFiles.opens(slot, key: newKey) && !ProtectionLibraryFiles.opens(slot, key: oldKey))
        let record = try #require(try ProtectionLibraryFiles.readRecord(at: slot, key: newKey))
        #expect(record.libraryID != oldID, "a fresh identity (rule 17)")
        #expect(record.mode == .standard && record.account == nil, "the posture of now; no account")
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(live.libraryID == record.libraryID && live.history.isEmpty, "a new library carries no previous keys")
        #expect(try live.open(words: words) == newKey, "under her current pair")
        // The outgoing library, WHOLE, with ITS key file.
        let aside = CopyDoorsPlant.asideFolders(road.slot.places)
        #expect(aside.count == 1)
        let folder = try #require(aside.first)
        #expect(ProtectionLibraryFiles.opens(folder.appendingPathComponent(CatalogNames.libraryFilename), key: oldKey))
        let asideFile = try KeyFile.decode(try Data(contentsOf: folder.appendingPathComponent(ProtectionNames.keyFilename)))
        #expect(asideFile == oldFile)
        // The restore hold — the core writer's marker, its day the backup's.
        let hold = try #require(LibraryRestoreHold.read(besideStore: slot))
        #expect(hold.asOf == row.asOf)
        // Rule 21: this Mac remembers ONE library — the new one.
        #expect(road.memory.items.keys.sorted() == [record.libraryID])
        #expect(minted.keys == [newKey], "today's store id minted for the new library")
        // The catalogue lists the outgoing library as another library's copy now (§7c (8): "where you can look
        // inside it or make it your library again").
        let after = ProtectionCopyDoors.listing(session)
        #expect(after.otherLibraries.contains { $0.kind == .previousLibrary && $0.copy.library == oldID })
    }

    /// The preflight is all reads: wrong words, a copy nothing typed opens — refused, and NOTHING written (no hold).
    @Test func thePreflightRefusesAndWritesNothing() async throws {
        let road = PlantedRoad()
        let (session, words, row) = try await CopyDoorsPlant.libraryWithABackup(road)
        let before = try CopyDoorsPlant.tree(road.slot.places.container)
        let wrong = try RecoveryPhrase.generate()
        guard case .refused(let why) = ProtectionCopyDoors.preflight(
            session, row: row, copySecrets: TypedSecrets(words: words), currentPair: TypedSecrets(words: wrong)) else {
            Issue.record("her words are verified before anything closes")
            return
        }
        #expect(why == .wordsDoNotOpen)
        // The copy is under the library's current key, which this Mac's silent item holds: its own quiet road opens it
        // whatever was typed in its field (rule 17: "or its own quiet road on this Mac") — and still nothing is written.
        guard case .ready = ProtectionCopyDoors.preflight(
            session, row: row, copySecrets: TypedSecrets(words: wrong), currentPair: TypedSecrets(words: words)) else {
            Issue.record("the copy's own quiet road opens it")
            return
        }
        #expect(ProtectionCopyDoors.opensQuietly(session, row.copy))
        #expect(try CopyDoorsPlant.tree(road.slot.places.container) == before, "the preflight wrote nothing")
        #expect(!LibraryRestoreHold.isHeld(besideStore: road.slot.places.slot))
    }

    /// A refusal INSIDE the act (the preflight bypassed): nothing swapped, so the hold goes back as it stood — none.
    @Test func aRefusalInsideTheActPutsTheHoldBackAsItStood() async throws {
        let road = PlantedRoad()
        let (session, words, row) = try await CopyDoorsPlant.libraryWithABackup(road)
        let catalog = session.system.lister.catalog()
        let copy = try #require(catalog.copies.first { $0.id == row.id })
        let wrong = TypedSecrets(words: try RecoveryPhrase.generate())
        let result = await ProtectionCopyDoors.makeMine(
            session, copy: copy, catalog: catalog, row: row, copySecrets: TypedSecrets(words: words), currentPair: wrong,
            mintStoreIdentity: { _ in Issue.record("no store id for a library never made") })
        #expect(result.outcome == .refused(.wordsDoNotOpen) && result.reopenKey == session.key)
        #expect(!LibraryRestoreHold.isHeld(besideStore: road.slot.places.slot), "no hold stood — none stands")
        // A hold that stood before stays exactly as it was.
        try LibraryRestoreHold.set(besideStore: road.slot.places.slot, asOf: nil, now: Date(timeIntervalSince1970: 7))
        let marker = LibraryRestoreHold.markerURL(besideStore: road.slot.places.slot)
        let standing = try Data(contentsOf: marker)
        _ = await ProtectionCopyDoors.makeMine(
            session, copy: copy, catalog: catalog, row: row, copySecrets: TypedSecrets(words: words), currentPair: wrong,
            mintStoreIdentity: { _ in })
        #expect(try Data(contentsOf: marker) == standing)
    }
}
