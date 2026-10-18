//
//  PickedCopyRoadTests.swift
//  VariorumTests — VX-306 U3 piece 3: A PICKED THING ON THE NEW ROAD over planted keychain leaves and a temp slot with
//  the real file leaves (`PlantedRoad` — no keychain; the suite also runs headless in the implementer's SwiftPM
//  harness). The lifecycle's stage 10: an "AirDropped" library folder is FILED FIRST into this Mac's safety copies
//  (P-VX306-U3-0 (a)) — the picked folder only read — then made a new library of hers; a copy already catalogued is
//  used where it is; the pick's honest refusals (the open library itself, a plain-text export — T-8 is VX-309's, a
//  store with no key file) and several pairs offered, never guessed.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U3 — a picked copy, filed first, then the doors (planted, no keychain)", .serialized)
@MainActor
struct PickedCopyRoadTests {
    /// The lifecycle's stage 10: someone else's library, AirDropped (a folder under "Downloads"), picked — FILED FIRST
    /// into this Mac's safety copies (the picked folder only read), then made this Mac's library with ITS secrets as
    /// the copy's and HER pair as the new library's.
    @Test func anAirDroppedLibraryIsFiledFirstThenBecomesANewLibraryOfHers() async throws {
        let mine = PlantedRoad()
        let (session, myWords, _) = try await CopyDoorsPlant.libraryWithABackup(mine)
        let theirs = PlantedRoad()
        let (theirSession, theirWords) = try await theirs.created()
        try CopyDoorsPlant.migrate(theirs, key: theirSession.key)
        let theirID = try #require(theirSession.library.record?.libraryID)
        // "AirDropped": their library folder (the store and its key file) in a folder outside both containers.
        let downloads = mine.slot.root.appendingPathComponent("Downloads/vx306-airdrop", isDirectory: true)
        try FileManager.default.createDirectory(at: downloads, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: theirs.slot.places.slot, to: downloads.appendingPathComponent(CatalogNames.libraryFilename))
        try FileManager.default.copyItem(at: theirs.slot.places.liveKeyFile, to: downloads.appendingPathComponent(ProtectionNames.keyFilename))
        let picked = try CopyDoorsPlant.tree(downloads)
        guard case .copy(let row) = ProtectionCopyDoors.pick(downloads, session: session) else {
            Issue.record("the pair is filed and catalogued")
            return
        }
        #expect(try CopyDoorsPlant.tree(downloads) == picked, "the picked folder is only read")
        #expect(row.kind == .adoptionSafetyCopy && !row.isThisLibrary && row.copy.library == theirID)
        #expect(row.copy.folders.first == CatalogNames.backupsFolderName && row.copy.folders.dropFirst().first == CatalogNames.safetyCopiesFolderName)
        // Her pair does not open their copy (and no quiet road on this Mac holds their key).
        #expect(!ProtectionCopyDoors.opensQuietly(session, row.copy))
        guard case .refused(.copyDoesNotOpen) = ProtectionCopyDoors.preflight(
            session, row: row, copySecrets: TypedSecrets(words: myWords), currentPair: TypedSecrets(words: myWords)) else {
            Issue.record("their copy needs their secrets")
            return
        }
        guard case .ready(let copy, let catalog) = ProtectionCopyDoors.preflight(
            session, row: row, copySecrets: TypedSecrets(words: theirWords), currentPair: TypedSecrets(words: myWords)) else {
            Issue.record("their words open their copy; her words verify her library")
            return
        }
        let result = await ProtectionCopyDoors.makeMine(
            session, copy: copy, catalog: catalog, row: row, copySecrets: TypedSecrets(words: theirWords),
            currentPair: TypedSecrets(words: myWords), mintStoreIdentity: { _ in })
        #expect(result.outcome == .made)
        let record = try #require(try ProtectionLibraryFiles.readRecord(at: mine.slot.places.slot, key: result.reopenKey))
        #expect(record.libraryID != theirID, "rule 18: an AirDropped library becomes its own library on arrival")
        let live = try #require(try mine.system().leaves.keyFiles.readLiveKeyFile())
        #expect(try live.open(words: myWords) == result.reopenKey, "under HER pair")
        #expect((try? live.open(words: theirWords)) == nil, "their secrets do not lock her new library")
        #expect(try CopyDoorsPlant.tree(downloads) == picked)
    }

    /// A copy already in this Mac's catalogue, picked by hand, is used where it is — never filed twice.
    @Test func aPickedCopyAlreadyCataloguedIsUsedWhereItIs() async throws {
        let road = PlantedRoad()
        let (session, _, row) = try await CopyDoorsPlant.libraryWithABackup(road)
        let url = try #require(session.system.places.withFile(catalogID: row.id) { $0 })
        let safety = road.slot.places.backups.appendingPathComponent(CatalogNames.safetyCopiesFolderName)
        guard case .copy(let picked) = ProtectionCopyDoors.pick(url, session: session) else {
            Issue.record("the catalogued copy itself")
            return
        }
        #expect(picked.id == row.id)
        #expect(!FileManager.default.fileExists(atPath: safety.path), "nothing filed")
    }

    /// The pick's honest refusals: the open library itself; a plain-text export (T-8 is VX-309's — never today's
    /// adoption on the new road); a store with no key file; and several pairs offered, never guessed.
    @Test func thePicksRefusalsAndTheChooser() async throws {
        let road = PlantedRoad()
        let (session, _, _) = try await CopyDoorsPlant.libraryWithABackup(road)
        guard case .refused(let live, _) = ProtectionCopyDoors.pick(road.slot.places.slot, session: session) else {
            Issue.record("the open library is refused"); return
        }
        #expect(live == ProtectionWords.pickedLiveLibrary)
        // A plain-text export of some library.
        let elsewhere = road.slot.root.appendingPathComponent("elsewhere", isDirectory: true)
        try FileManager.default.createDirectory(at: elsewhere, withIntermediateDirectories: true)
        let source = try AppDatabase.onDisk(url: elsewhere.appendingPathComponent("source.sqlite"), key: StoreKey.mint())
        let export = elsewhere.appendingPathComponent("export.sqlite")
        try StorePlaintextExport.export(from: source, to: export)
        guard case .refused(let plaintext, _) = ProtectionCopyDoors.pick(export, session: session) else {
            Issue.record("a plain-text export is refused on the new road"); return
        }
        #expect(plaintext == ProtectionWords.plaintextCopyNotYet)
        // A store with no key file beside it.
        let bare = elsewhere.appendingPathComponent("bare", isDirectory: true)
        try FileManager.default.createDirectory(at: bare, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: road.slot.places.slot, to: bare.appendingPathComponent(CatalogNames.libraryFilename))
        guard case .refused(let noKey, _) = ProtectionCopyDoors.pick(bare, session: session) else {
            Issue.record("a bare store is refused"); return
        }
        #expect(noKey == LibraryOpenCopy.bareStoreRefusal)
        // Two pairs in one folder: offered.
        let two = elsewhere.appendingPathComponent("two", isDirectory: true)
        try FileManager.default.createDirectory(at: two, withIntermediateDirectories: true)
        let live2 = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        for stamp in [1, 2] {
            let stem = CatalogNames.backupPrefix + CatalogNames.stampString(PlantCatalog.day(stamp)) + "-"
                + StoreKeyEnvelope.shortFingerprint(live2.fingerprint)
            try FileManager.default.copyItem(at: road.slot.places.slot, to: two.appendingPathComponent(stem + ".sqlite"))
            try live2.encoded().write(to: two.appendingPathComponent(stem + ".keys.json"))
        }
        guard case .several(let stores) = ProtectionCopyDoors.pick(two, session: session) else {
            Issue.record("several pairs are offered"); return
        }
        #expect(stores.count == 2)
    }
}
