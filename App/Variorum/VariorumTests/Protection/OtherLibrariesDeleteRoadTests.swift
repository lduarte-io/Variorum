//
//  OtherLibrariesDeleteRoadTests.swift
//  VariorumTests — VX-309 U1c pieces 1 and 2 (VX-265, VX-210) over planted keychain leaves and a temp slot with the real
//  file leaves (`PlantedRoad` — no keychain; the suite also runs headless in the implementer's SwiftPM harness). RULE 19's
//  delete: "Copies of other libraries are listed and can be deleted" — ONE library's copies at a time, confirmed each time,
//  never part of another act. With a library open (Data Safety's Restore list) the library that stepped aside is offered
//  *Delete…* and every copy THIS Mac made of it goes — its backups (filed under ITS device ID's mac8, rule 23) and its
//  Previous Library, whole — while the open library's own copies stay (retention's). With no library open (the empty-slot
//  listing) a library this Mac remembers is never offered (P-VX309-U1c-2). And VX-210's one honest line counts the copies
//  Variorum leaves as they are.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1c — rule 19's delete of other libraries' copies, and VX-210's line (planted, no keychain)", .serialized)
@MainActor
struct OtherLibrariesDeleteRoadTests {
    /// THE OPEN-LIBRARY ROAD: A stepped aside for B (Make this my library on A's own backup). The listing offers A's rows
    /// *Delete…* — counting this Mac's copies of A: its backups and its Previous Library — and never B's own rows. The press
    /// deletes exactly those (A's Previous Library folder whole), B's copies and B itself untouched, the act ended.
    @Test func withALibraryOpenTheOtherLibrarysCopiesGoAndTheOpenOnesStay() async throws {
        let road = PlantedRoad()
        let stepped = try await ArcPlant.aSteppedAside(road)
        let b = stepped.b
        let bID = try #require(b.library.record?.libraryID)
        let before = ProtectionCopyDoors.listing(b)
        let choice = try #require(before.deleteChoices[stepped.aID], "the library that stepped aside is offered a delete")
        let aCopies = before.otherLibraries.filter { $0.copy.library == stepped.aID }
        #expect(choice.count == aCopies.count && choice.staying == 0, "every listed copy of A is this Mac's")
        #expect(choice.previousLibraries == 1 && choice.backups == aCopies.count - 1)
        #expect(before.thisLibrary.allSatisfy { before.deleteChoice(for: $0) == nil }, "never the open library's rows")
        #expect(before.deleteChoices[bID] == nil)
        let bRows = before.thisLibrary.count
        #expect(bRows > 0, "B's own pair (Make this my library's backup step)")

        let outcome = await ProtectionCopyDoors.deleteCopies(b, libraryID: stepped.aID)
        #expect(outcome == .deleted(choice.count))
        let after = ProtectionCopyDoors.listing(b)
        #expect(!after.all.contains { $0.copy.library == stepped.aID }, "A's copies are gone from the list")
        #expect(after.thisLibrary.count == bRows, "B's copies are retention's — untouched")
        #expect(CopyDoorsPlant.asideFolders(road.slot.places).isEmpty, "A's Previous Library folder — whole")
        #expect(ProtectionLibraryFiles.opens(road.slot.places.slot, key: b.key), "the open library untouched")
        #expect(b.library.section.actInFlight == nil, "the act ended")
        // A second press finds nothing of A's left: said, nothing written.
        #expect(await ProtectionCopyDoors.deleteCopies(b, libraryID: stepped.aID) == .refused(.copyGone))
        // The open library is never rule 19's.
        #expect(await ProtectionCopyDoors.deleteCopies(b, libraryID: bID) == .refused(.deleteFailed))
    }

    /// THE EMPTY-SLOT ROAD: B (the library this Mac remembers) moved out of the slot — the missing face. B's copies are
    /// never offered and never deleted (they are what the empty-slot landing lands from — P-VX309-U1c-2); A's are offered
    /// and go.
    @Test func withNoLibraryOpenARememberedLibraryIsNeverOfferedAndAnotherIsDeleted() async throws {
        let road = PlantedRoad()
        let stepped = try await ArcPlant.aSteppedAside(road)
        let bID = try #require(stepped.b.library.record?.libraryID)
        let away = road.slot.root.appendingPathComponent("moved-away", isDirectory: true)
        try Plant.moveLibraryAway(road, to: away)
        let ctx = CopyDoorsContext(road.context())
        #expect(ctx.libraryID == nil)
        let listing = ProtectionCopyDoors.listing(ctx)
        #expect(listing.deleteChoices[bID] == nil, "the remembered library — never offered")
        #expect(listing.all.contains { $0.copy.library == bID }, "…and still listed (its copies land it back)")
        let choice = try #require(listing.deleteChoices[stepped.aID])
        let bCopies = listing.all.filter { $0.copy.library == bID }.count
        #expect(ProtectionCopyDoors.deleteCopies(ctx, libraryID: bID) == .refused(.copyGone), "the act's own exclusion")
        #expect(ProtectionCopyDoors.listing(ctx).all.filter { $0.copy.library == bID }.count == bCopies)
        #expect(ProtectionCopyDoors.deleteCopies(ctx, libraryID: stepped.aID) == .deleted(choice.count))
        let after = ProtectionCopyDoors.listing(ctx)
        #expect(!after.all.contains { $0.copy.library == stepped.aID })
        #expect(after.all.filter { $0.copy.library == bID }.count == bCopies, "B's copies — untouched")
        #expect(!FileManager.default.fileExists(atPath: road.slot.places.slot.path), "the slot stays empty — a delete lands nothing")
    }

    /// RULE 27's LOBBY (a library no key file opens stands in the slot — no library open, the slot NOT empty): its ID is
    /// inside the file no key opens, so any listed library could be it (its older backups are its last road back) — no row
    /// is offered a delete there, and the act refuses (P-VX309-U1c-2).
    @Test func withALibraryStandingInTheSlotNoDeleteIsOffered() async throws {
        let road = PlantedRoad()
        let stepped = try await ArcPlant.aSteppedAside(road)
        // B stands in the slot, every road to it gone (rule 27's state): its key file, its silent item, its memory.
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        road.custody.items = [:]
        road.memory.items = [:]
        road.apple.keys = [:]
        let ctx = CopyDoorsContext(road.context())
        let listing = ProtectionCopyDoors.listing(ctx)
        #expect(listing.all.contains { $0.copy.library == stepped.aID }, "A is still listed")
        #expect(listing.deleteChoices.isEmpty, "no delete with a library standing in the slot")
        #expect(ProtectionCopyDoors.deleteCopies(ctx, libraryID: stepped.aID) == .refused(.deleteFailed))
        #expect(ProtectionCopyDoors.listing(ctx).all.contains { $0.copy.library == stepped.aID }, "nothing deleted")
    }

    /// THE CONFIRM'S BRAIN (planted roads): the lead names the library by its day, counts what goes and says what stays;
    /// nothing runs before the press; *Cancel* writes nothing; from the listing the press re-reads the listing with the
    /// receipt above it, from a row elsewhere the sheet leaves.
    @Test func theConfirmCountsWhatGoesAndActsOnlyAtThePress() async throws {
        let choice = CopyDeleteChoice(
            libraryID: "lib-a", copyIDs: ["c:1", "c:2", "c:3"], backups: 2, previousLibraries: 1, openedCopies: 0,
            newest: PlantCatalog.day(2), staying: 1)
        #expect(ProtectionWords.deleteCopiesCounts(choice) == "2 backups and a previous library")
        let lead = ProtectionWords.deleteCopiesLead(choice, libraryOpen: true)
        #expect(lead.contains(ProtectionWords.day(PlantCatalog.day(2))) && lead.contains("2 backups and a previous library"))
        #expect(lead.contains("One copy another Mac made stays.") && lead.hasSuffix("Your library isn't touched."))
        #expect(!ProtectionWords.deleteCopiesLead(choice, libraryOpen: false).contains("Your library"))

        final class Asked { var libraries: [String] = []; var answer: CopyDeleteOutcome = .refused(.busy) }
        let asked = Asked()
        let planted = PlantedCopyDoors()
        planted.listing = CopyDoorsListing(thisLibrary: [], otherLibraries: [], deleteChoices: ["lib-a": choice])
        var roads = planted.roads
        roads.deleteCopies = { library in
            asked.libraries.append(library)
            return asked.answer
        }
        // From a row elsewhere (Data Safety): a refusal says so in place; the press that lands closes the sheet.
        let model = CopyDoorsModel(roads: roads)
        model.openDeleteCopies(choice)
        guard case .deleteCopies(let confirm) = model.phase else {
            Issue.record("the confirm stands")
            return
        }
        #expect(asked.libraries.isEmpty, "nothing before the press")
        await confirm.delete()
        #expect(asked.libraries == ["lib-a"] && confirm.refusal == ProtectionWords.copyDoorBusy)
        asked.answer = .deleted(3)
        await confirm.delete()
        guard case .done = model.phase else {
            Issue.record("a row's press leaves the sheet once the copies went: \(model.phase)")
            return
        }
        // Cancel writes nothing.
        let left = CopyDoorsModel(roads: roads)
        left.openDeleteCopies(choice)
        guard case .deleteCopies(let leaving) = left.phase else { return }
        leaving.cancel()
        #expect(asked.libraries.count == 2)
        // From the listing: back to the listing, read again, the receipt above it.
        let listed = CopyDoorsModel(roads: roads)
        await listed.beginListing()
        listed.openDeleteCopies(choice)
        guard case .deleteCopies(let fromList) = listed.phase else { return }
        await fromList.delete()
        for _ in 0..<200 where listed.listingReceipt == nil { await Task.yield() }
        guard case .listing = listed.phase else {
            Issue.record("back to the listing: \(listed.phase)")
            return
        }
        #expect(listed.listingReceipt == ProtectionWords.deleteCopiesReceipt(3))
        #expect(ProtectionWords.deleteCopiesReceipt(1) == "Deleted 1 copy of another library from this Mac.")
    }

    /// VX-210 — THE COUNT behind the one honest line: a library-shaped file in a place no build of this design writes
    /// (today's flat backups beside the library and in the picked folder, the A1 rail's copy, a folder she made), a copy no
    /// key file names (rule 26), a far copy outside any Mac's subfolder. Sidecars, other files of hers and the app's own
    /// pairs never count; with none of these the line is not rendered (P-2).
    @Test func theLineCountsTheCopiesVariorumLeavesAsTheyAre() throws {
        let library = PlantCatalog.id(), mac = PlantCatalog.id()
        let file = try PlantCatalog.keyFile(libraryID: library)
        let own = try PlantCatalog.backup(file, mac: mac, at: PlantCatalog.day(1))
            + PlantCatalog.previous(file, at: PlantCatalog.day(2))
        #expect(CopyDoorsListing.unmanagedCopies(in: Catalog.build(own)) == 0)
        #expect(CopyDoorsListing.make(Catalog.build(own), libraryID: library).unmanagedCopies == 0)
        let flat = "variorum-backup-2026-10-19-120000.sqlite"
        let elsewhere = own + [
            CatalogEntry(place: .container, folders: ["Backups"], name: flat),
            CatalogEntry(place: .container, folders: ["Backups"], name: flat + "-wal"),
            CatalogEntry(place: .farFolder, folders: [], name: flat),
            CatalogEntry(place: .container, folders: ["Backups", "safety-copies", "variorum-backup-a1-2026-10-19T120000Z"],
                         name: CatalogNames.libraryFilename),
            CatalogEntry(place: .container, folders: ["Previous Libraries", "my old one"], name: CatalogNames.libraryFilename),
            CatalogEntry(place: .container, folders: ["Previous Libraries", "my old one"], name: "notes.txt"),
            CatalogEntry(place: .container, folders: [], name: "variorum-keys.json"),
            CatalogEntry(place: .farFolder, folders: ["Backups", "safety-copies", "variorum-adopt-safety-2026-10-19-120000"],
                         name: CatalogNames.libraryFilename),
            CatalogEntry(place: .farFolder, folders: ["Backups", "safety-copies", "variorum-adopt-safety-2026-10-19-120000"],
                         name: ProtectionNames.keyFilename, bytes: try file.encoded()),
        ] + PlantCatalog.preDesignSafetyCopy(at: PlantCatalog.day(3))
        let catalog = Catalog.build(elsewhere)
        // 4 foreign `.sqlite` (two flat backups, the A1 rail's, her folder) + the far copy outside a Mac subfolder + the
        // copy no format-3 key file names.
        #expect(CopyDoorsListing.unmanagedCopies(in: catalog) == 6)
        #expect(CopyDoorsListing.make(catalog, libraryID: library).unmanagedCopies == 6)
    }
}
