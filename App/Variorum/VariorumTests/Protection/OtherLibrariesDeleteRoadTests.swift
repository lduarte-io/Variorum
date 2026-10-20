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
        // VX-309 U2 — VX-264 item 5, FLIPPED DELIBERATELY: the count is her "older libraries" sentence now (#216).
        let counted = "That's 2 backups, plus 1 older library Variorum kept when you opened or restored a different one."
        #expect(ProtectionWords.deleteCopiesCounts(choice) == counted)
        let lead = ProtectionWords.deleteCopiesLead(choice, libraryOpen: true)
        #expect(lead.contains(ProtectionWords.day(PlantCatalog.day(2))) && lead.contains(counted))
        // VX-309 ladder round 1, F-R1 — FLIPPED DELIBERATELY: a copy that stays may be an unattributed far copy, whose
        // maker is not knowable — the staying sentence says so (PROVISIONAL P-VX309-R1-1).
        #expect(lead.contains("One copy another Mac made, or that this \(ProtectionCopy.deviceName) can't vouch for, stays.")
            && lead.hasSuffix("Your library isn't touched."))
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

    /// VX-309 ladder round 1, F-R6 — a library-shaped file is library-shaped whatever the case of its suffix: an `.SQLITE`
    /// (a hand-renamed file, a case-preserving volume) counts toward the one honest line like an `.sqlite`; its sidecar
    /// never does. RED ON OLD: the foreign arm's suffix test was case-sensitive (0, not 2).
    @Test func theLineCountsALibraryShapedFileWhateverTheCaseOfItsSuffix() {
        let shouted = [
            CatalogEntry(place: .container, folders: ["Backups"], name: "VARIORUM-BACKUP-2026-10-19-120000.SQLITE"),
            CatalogEntry(place: .container, folders: ["Backups"], name: "VARIORUM-BACKUP-2026-10-19-120000.SQLITE-wal"),
            CatalogEntry(place: .farFolder, folders: [], name: "Old Library.Sqlite"),
        ]
        let catalog = Catalog.build(shouted)
        #expect(catalog.foreign.count == 3, "all three foreign to the catalogue")
        #expect(CopyDoorsListing.unmanagedCopies(in: catalog) == 2, "the two library-shaped files; never the sidecar")
    }

    /// `entries` as the lister lists them in the picked second folder (`<picked>/Variorum/…`).
    static func far(_ entries: [CatalogEntry]) -> [CatalogEntry] {
        entries.map {
            CatalogEntry(place: .farFolder, folders: $0.folders, name: $0.name, bytes: $0.bytes, modifiedAt: $0.modifiedAt)
        }
    }

    /// VX-309 ladder round 1, F-R1 — A FAR PAIR OF ANOTHER LIBRARY THAT NO CONTAINER TWIN VOUCHES FOR (its container copies
    /// deleted while the second folder was unplugged; or another Mac's own library in a shared second folder): rule 19's
    /// fence cannot claim it — the `<mac8>` it is filed under may be another Mac's (rule 23) — so it is NEVER offered a
    /// delete (never delete what might be another Mac's); and the one honest line now COUNTS it, so its row is never
    /// silently door-less (PROVISIONAL P-VX309-R1-1 — the option question is her bundle's). Its twin standing, the pair is
    /// this Mac's: deletable, never counted. The open library's far copies and a protected library's are never counted
    /// (their rows are the restore list's and the empty-slot landing's, never rule 19's). RED ON OLD: the line's count was
    /// 0 — the row visible, door-less, unsaid.
    @Test func aFarPairNoContainerTwinVouchesForIsSaidAndNeverDeleted() throws {
        let open = PlantCatalog.id(), x = PlantCatalog.id()
        let thisMac = PlantCatalog.id(), xMac = PlantCatalog.id(), otherMac = PlantCatalog.id()
        let openFile = try PlantCatalog.keyFile(libraryID: open)
        let xFile = try PlantCatalog.keyFile(libraryID: x)
        let openOwn = try PlantCatalog.backup(openFile, mac: thisMac, at: PlantCatalog.day(1))
        let xFar = Self.far(try PlantCatalog.backup(xFile, mac: xMac, at: PlantCatalog.day(2)))
        let catalog = Catalog.build(openOwn + xFar)

        let listing = CopyDoorsListing.make(catalog, libraryID: open, protected: [open])
        let xRow = try #require(listing.otherLibraries.first { $0.copy.library == x }, "listed (rule 19)")
        #expect(listing.deleteChoice(for: xRow) == nil, "never delete what might be another Mac's — the fence unwidened")
        #expect(listing.unmanagedCopies == 1, "the one honest line says it — never silently door-less")
        // With no library open (the missing face), not remembered: the same; remembered (protected): the landing's, not counted.
        #expect(CopyDoorsListing.make(catalog, libraryID: nil, protected: []).unmanagedCopies == 1)
        #expect(CopyDoorsListing.make(catalog, libraryID: nil, protected: [x]).unmanagedCopies == 0)

        // Its container twin standing: this Mac's copies of X — the delete offered, nothing counted.
        let xTwin = try PlantCatalog.backup(xFile, mac: xMac, at: PlantCatalog.day(3))
        let twinned = Catalog.build(openOwn + xFar + xTwin)
        let withTwin = CopyDoorsListing.make(twinned, libraryID: open, protected: [open])
        #expect(withTwin.deleteChoices[x]?.count == 2 && withTwin.deleteChoices[x]?.staying == 0)
        #expect(withTwin.unmanagedCopies == 0)

        // The open library's far pair under another Mac's subfolder (a synced library's other device): its restore row.
        let openFar = Self.far(try PlantCatalog.backup(openFile, mac: otherMac, at: PlantCatalog.day(4)))
        let openListing = CopyDoorsListing.make(Catalog.build(openOwn + openFar), libraryID: open, protected: [open])
        #expect(openListing.thisLibrary.count == 2 && openListing.unmanagedCopies == 0)
    }
}
