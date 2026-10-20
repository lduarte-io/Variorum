//
//  EmptySlotLandingRoadTests.swift
//  VariorumTests — VX-309 U1b piece 1: T-5, THE EMPTY-SLOT LANDING on the app's road (`ProtectionCopyDoors
//  .makeMineInTheEmptySlot`) over planted keychain leaves and a temp slot with the real file leaves (`PlantedRoad` — no
//  keychain; the suite also runs headless in the implementer's SwiftPM harness). The missing face (the library file gone,
//  its key file still in the live place) and rule 27's lobby (a library no key file opens): Make this my library lands a
//  catalogued copy as a NEW library under the secret typed for it, what stood in the slot set aside WHOLE first (never
//  written over), the restore hold beside it, today's store id minted fresh; a wrong secret or a quiet road alone refuses
//  with NOTHING written. And the confirm's brain at the empty slot: the copy's secret, always asked, the one thing typed.
//  New road and new model arm — red by construction on the pre-unit tree (`makeMine` was nil with no library open).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum EmptySlotPlant {
    /// The missing face: library A (one note, one backup pair) whose file — with its sidecars — is gone from the slot,
    /// its key file still in the live place, its silent item and memory item still on this Mac.
    static func missingFace(_ road: PlantedRoad) async throws -> (key: StoreKey, words: [String], libraryID: String) {
        let (session, words) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: session.key)
        try LookPlant.note(road, key: session.key, title: "Kept in the backup", blocks: ["One.", "Two."])
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try session.system.backups.takeBackupPair(with: session.key, keyFile: live, deviceID: session.library.section.deviceID)
        ProtectionLibraryFiles.removeWithSidecars(road.slot.places.slot)
        return (session.key, words, try #require(session.library.record?.libraryID))
    }

    static func noLibraryContext(_ road: PlantedRoad) -> CopyDoorsContext { CopyDoorsContext(road.context()) }
}

@Suite("VX-309 U1b — T-5: Make this my library into the empty slot, on the app's road (planted, no keychain)", .serialized)
@MainActor
struct EmptySlotLandingRoadTests {
    /// THE MISSING FACE: A's own backup, its own words typed → a NEW library in the empty slot (fresh identity and key,
    /// Standard, under the typed words, no past), its content landed; A's key file — the missing library's, still in the
    /// live place — set aside WHOLE into Previous Libraries first (never written over); the hold beside the new library,
    /// its day the backup's; today's store id minted for the new key; this Mac remembers ONE library.
    @Test func theMissingFacesBackupLandsAsANewLibraryAndTheMissingKeyFileStepsAside() async throws {
        let road = PlantedRoad()
        let (oldKey, words, oldID) = try await EmptySlotPlant.missingFace(road)
        let oldFile = try Data(contentsOf: road.slot.places.liveKeyFile)
        let ctx = EmptySlotPlant.noLibraryContext(road)
        let row = try #require(ProtectionCopyDoors.listing(ctx).all.first { $0.kind == .backup })
        let minted = KeyBox()
        let result = await ProtectionCopyDoors.makeMineInTheEmptySlot(
            ctx, row: row, copySecrets: TypedSecrets(words: words), mintStoreIdentity: { minted.append($0) })
        #expect(result.outcome == .made)
        let newKey = try #require(result.key)
        let slot = road.slot.places.slot
        #expect(newKey != oldKey && ProtectionLibraryFiles.opens(slot, key: newKey))
        let record = try #require(try ProtectionLibraryFiles.readRecord(at: slot, key: newKey))
        #expect(record.libraryID != oldID && record.mode == .standard && record.account == nil)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(live.libraryID == record.libraryID && live.history.isEmpty && live.passphrase == nil)
        #expect(try live.open(words: words) == newKey, "under the copy's own words, typed at the door")
        // The missing library's key file, set aside whole — never written over.
        let aside = CopyDoorsPlant.asideFolders(road.slot.places)
        #expect(aside.count == 1)
        let folder = try #require(aside.first)
        #expect(try Data(contentsOf: folder.appendingPathComponent(ProtectionNames.keyFilename)) == oldFile)
        #expect(!FileManager.default.fileExists(atPath: folder.appendingPathComponent(CatalogNames.libraryFilename).path),
                "nothing else stood in the slot — only the missing library's key file stepped aside")
        let hold = try #require(LibraryRestoreHold.read(besideStore: slot))
        #expect(hold.asOf == row.asOf, "held, as every adoption lands")
        #expect(minted.keys == [newKey], "today's store id minted for the new library")
        #expect(road.memory.items.keys.sorted() == [record.libraryID], "this Mac remembers ONE library (rule 21)")
        // Its content landed (read back through Look inside's own read road).
        let reader = try ProtectionCopyPeek.open(slot, key: newKey, inside: road.slot.places.scratch)
        defer { reader.close() }
        #expect(try reader.notes().map(\.title) == ["Kept in the backup"])
    }

    /// RULE 27's LOBBY: a library no key file opens stands in the slot (every road to it gone); another library's copy,
    /// AirDropped and filed, lands with ITS words — the unopenable library first set aside WHOLE (the file, its sidecars),
    /// opening still under its own key in Previous Libraries (a key file found later still opens it there).
    @Test func ruleTwentySevensLibraryStepsAsideWholeAndACopyLands() async throws {
        let mine = PlantedRoad()
        let (session, _) = try await mine.created()
        try CopyDoorsPlant.migrate(mine, key: session.key)
        let unopenableKey = session.key
        // Every road to it gone: its key file, its silent item, its memory, its Apple key.
        try FileManager.default.removeItem(at: mine.slot.places.liveKeyFile)
        mine.custody.items = [:]
        mine.memory.items = [:]
        mine.apple.keys = [:]
        let theirs = PlantedRoad()
        let (theirSession, theirWords) = try await theirs.created()
        try CopyDoorsPlant.migrate(theirs, key: theirSession.key)
        let downloads = mine.slot.root.appendingPathComponent("Downloads/vx309-airdrop", isDirectory: true)
        try FileManager.default.createDirectory(at: downloads, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: theirs.slot.places.slot, to: downloads.appendingPathComponent(CatalogNames.libraryFilename))
        try FileManager.default.copyItem(at: theirs.slot.places.liveKeyFile, to: downloads.appendingPathComponent(ProtectionNames.keyFilename))
        let ctx = EmptySlotPlant.noLibraryContext(mine)
        guard case .copy(let row) = ProtectionCopyDoors.pick(downloads, ctx) else {
            Issue.record("their pair is filed with no library open")
            return
        }
        let unopenableBytes = try Data(contentsOf: mine.slot.places.slot)
        let result = await ProtectionCopyDoors.makeMineInTheEmptySlot(
            ctx, row: row, copySecrets: TypedSecrets(words: theirWords), mintStoreIdentity: { _ in })
        #expect(result.outcome == .made)
        let newKey = try #require(result.key)
        let record = try #require(try ProtectionLibraryFiles.readRecord(at: mine.slot.places.slot, key: newKey))
        #expect(record.libraryID != theirSession.library.record?.libraryID, "their copy becomes a library of its own")
        let folder = try #require(CopyDoorsPlant.asideFolders(mine.slot.places).first)
        let aside = folder.appendingPathComponent(CatalogNames.libraryFilename)
        #expect(try Data(contentsOf: aside) == unopenableBytes, "the unopenable library moved WHOLE — never written over")
        #expect(ProtectionLibraryFiles.opens(aside, key: unopenableKey), "it still opens under its own key there")
    }

    /// The preflight is all reads: a wrong secret, or nothing typed where only this Mac's quiet road would open the copy
    /// (rule 14's precedent — a quiet road alone carries no pair), refuses `copyDoesNotOpen` and NOTHING is written — no
    /// hold, nothing set aside, the missing library's key file where it stood.
    @Test func aWrongSecretOrAQuietRoadAloneRefusesAndWritesNothing() async throws {
        let road = PlantedRoad()
        let (_, _, _) = try await EmptySlotPlant.missingFace(road)
        let ctx = EmptySlotPlant.noLibraryContext(road)
        let row = try #require(ProtectionCopyDoors.listing(ctx).all.first { $0.kind == .backup })
        #expect(ProtectionCopyDoors.opensQuietly(ctx, row.copy), "this Mac's silent item opens its own backup")
        let before = try CopyDoorsPlant.tree(road.slot.places.container)
        for typed in [TypedSecrets(words: try RecoveryPhrase.generate()), TypedSecrets.none] {
            let result = await ProtectionCopyDoors.makeMineInTheEmptySlot(
                ctx, row: row, copySecrets: typed, mintStoreIdentity: { _ in Issue.record("no store id for nothing landed") })
            #expect(result.outcome == .refused(.copyDoesNotOpen) && result.key == nil)
        }
        #expect(try CopyDoorsPlant.tree(road.slot.places.container) == before, "nothing written")
        #expect(!LibraryRestoreHold.isHeld(besideStore: road.slot.places.slot))
    }

    /// The confirm's brain at the empty slot: no quiet probe (no quiet road counts), the copy's own secret always asked
    /// and required, T-5's own lead, and the press hands the act that secret with NO current pair.
    @Test func theConfirmAtTheEmptySlotAsksTheCopysSecretAlone() async throws {
        let planted = PlantedCopyDoors()
        planted.quiet = true
        var roads = planted.roads
        roads.landsInTheEmptySlot = true
        let file = try PlantCatalog.keyFile(libraryID: PlantCatalog.id())
        let catalog = Catalog.build(try PlantCatalog.backup(file, mac: PlantCatalog.id(), at: PlantCatalog.day(1)))
        let row = try #require(CopyDoorsListing.make(catalog, libraryID: nil).all.first)
        let doors = CopyDoorsModel(roads: roads)
        await doors.openMakeMine(row)
        guard case .makeMine(let confirm) = doors.phase else {
            Issue.record("the confirm opens: \(doors.phase)")
            return
        }
        #expect(confirm.intoTheEmptySlot && confirm.needsCopySecret && !confirm.checking)
        #expect(planted.probes == 0, "no quiet probe — a quiet road never lands a copy into the empty slot")
        #expect(confirm.lead == ProtectionWords.makeMineEmptySlotLead)
        #expect(!confirm.canSubmitIntoTheEmptySlot(copySecret: ""))
        let words = try RecoveryPhrase.generate()
        await confirm.submitIntoTheEmptySlot(copySecret: words.joined(separator: " "))
        let act = try #require(planted.acts.last)
        #expect(act.copy.words == words && act.copy.passphrase == nil)
        #expect(act.pair.words == nil && act.pair.passphrase == nil, "no current pair exists — none is sent")
        #expect({ if case .done = doors.phase { true } else { false } }(), "made — the sheet leaves")
    }
}
