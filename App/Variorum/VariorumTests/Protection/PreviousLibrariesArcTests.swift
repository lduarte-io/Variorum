//
//  PreviousLibrariesArcTests.swift
//  VariorumTests — VX-309 U1b piece 2: VX-305's SECOND HAND-OFF — this Mac's own set-aside library, through the doors, end
//  to end, over planted keychain leaves and a temp slot with the real file leaves (`PlantedRoad` — no keychain; the suite
//  also runs headless in the implementer's SwiftPM harness). A library that stepped aside WHOLE into `Previous Libraries/
//  <stamp>/` (Make this my library's own step-aside) is LISTED (rule 19), opens READ-ONLY through Look inside by its own
//  quiet road or its own secrets — writing nothing — and RETURNS as the library through Make this my library: from an open
//  library (the standing act — the current one steps aside in its turn) and from the empty slot (T-5).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum ArcPlant {
    struct Stepped {
        /// The library that stepped aside (A) — its key, words, ID.
        let aKey: StoreKey
        let aWords: [String]
        let aID: String
        /// The library open now (B — A's backup made this Mac's library), its session.
        let b: ProtectionRoadSession
    }

    /// A (one note, one backup pair) made way for B: Make this my library on A's own backup — A steps aside WHOLE.
    static func aSteppedAside(_ road: PlantedRoad) async throws -> Stepped {
        let (a, words, row) = try await CopyDoorsPlant.libraryWithABackup(road)
        // A's identity read NOW — the doors' act moves the session onto the library it makes.
        let aKey = a.key
        let aID = try #require(a.library.record?.libraryID)
        try LookPlant.note(road, key: a.key, title: "A's own note", blocks: ["Written in A."])
        // A fresh pair after the note, so the backup B is made from carries it.
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try a.system.backups.takeBackupPair(with: a.key, keyFile: live, deviceID: a.library.section.deviceID)
        let newest = try #require(ProtectionCopyDoors.listing(a).thisLibrary.first)
        #expect(newest.id != row.id, "the newer pair, carrying the note")
        let pair = TypedSecrets(words: words)
        guard case .ready(let copy, let catalog, let opened) = ProtectionCopyDoors.preflight(
            a, row: newest, copySecrets: pair, currentPair: pair) else { throw ArcError.preflight }
        let made = await ProtectionCopyDoors.makeMine(
            a, copy: copy, catalog: catalog, row: newest, opened: opened, currentPair: pair)
        guard made.outcome == .made else { throw ArcError.notMade }
        guard case .opened(let b) = await ProtectionOpenRoad.route(road.context(), keyInHand: made.reopenKey) else {
            throw ArcError.notOpened
        }
        return Stepped(aKey: aKey, aWords: words, aID: aID, b: b)
    }

    enum ArcError: Error { case preflight, notMade, notOpened }

    static func previousRow(_ listing: CopyDoorsListing, library: String) -> CopyDoorRow? {
        listing.all.first { $0.kind == .previousLibrary && $0.copy.library == library }
    }

    /// The doors' roads with NO library open, as `AppBootstrap.copyDoorsRoadsWithoutALibrary` composes them (the bootstrap
    /// itself is Mac-only — the route pins drive it).
    static func noLibraryRoads(_ road: PlantedRoad) -> CopyDoorsRoads {
        let system = road.system()
        let context: @Sendable () -> CopyDoorsContext = {
            CopyDoorsContext(RoadContext(system: system, session: .signedOut, writes: true))
        }
        return CopyDoorsRoads(
            listing: { ProtectionCopyDoors.listing(context()) },
            opensQuietly: { ProtectionCopyDoors.opensQuietly(context(), $0) },
            passphraseSet: { false },
            makeMine: { row, copySecrets, _ in
                await ProtectionCopyDoors.makeMineInTheEmptySlot(
                    context(), row: row, copySecrets: copySecrets).outcome
            },
            pick: { ProtectionCopyDoors.pick($0, context()) },
            lookInside: { copy, typed, quietRoads in
                ProtectionCopyDoors.lookInside(context(), copy: copy, typed: typed, quietRoads: quietRoads)
            },
            landsInTheEmptySlot: true)
    }

    static func titles(_ road: PlantedRoad, key: StoreKey) throws -> [String?] {
        let reader = try ProtectionCopyPeek.open(road.slot.places.slot, key: key, inside: road.slot.places.scratch)
        defer { reader.close() }
        return try reader.notes().map(\.title)
    }
}

@Suite("VX-309 U1b — Previous Libraries through the doors: listed, looked inside, made the library again (planted)", .serialized)
@MainActor
struct PreviousLibrariesArcTests {
    /// RULE 19's LISTING + LOOK INSIDE: A, stepped aside whole, is listed among the other libraries on this Mac (as a
    /// previous library, its day the step-aside's); it opens read-only by its OWN QUIET ROAD (A's silent item stays on this
    /// Mac) and — that road gone — by its OWN WORDS, nothing written either way.
    @Test func aSteppedAsideLibraryIsListedAndOpensReadOnlyByItsQuietRoadOrItsOwnSecrets() async throws {
        let road = PlantedRoad()
        let stepped = try await ArcPlant.aSteppedAside(road)
        let listing = ProtectionCopyDoors.listing(stepped.b)
        let row = try #require(ArcPlant.previousRow(listing, library: stepped.aID), "listed (rule 19): \(listing.all.map(\.kind))")
        #expect(!row.isThisLibrary && listing.otherLibraries.contains(row))
        #expect(row.asOf == row.copy.stamp && row.asOf != nil, "its day: the day it stepped aside")
        let before = try LookPlant.untouched(road)
        let logs = LookPlant.writeLogs(road)
        // Its own quiet road on this Mac.
        guard case .opened(let quiet) = ProtectionCopyDoors.lookInside(CopyDoorsContext(stepped.b), copy: row.copy, typed: .none)
        else {
            Issue.record("A's own quiet road opens it")
            return
        }
        #expect(try quiet.notes().map(\.title).contains("A's own note"))
        quiet.close()
        // Its own words, with its quiet roads gone.
        road.custody.items = road.custody.items.filter { $0.key.fingerprint != KeyFingerprint.of(stepped.aKey) }
        road.apple.keys = road.apple.keys.filter { road.apple.stamps[$0.key] != stepped.aID }
        let afterRoadsGone = try LookPlant.untouched(road)
        guard case .refused(.copyDoesNotOpen) = ProtectionCopyDoors.lookInside(
            CopyDoorsContext(stepped.b), copy: row.copy, typed: .none) else {
            Issue.record("with its quiet roads gone, nothing typed opens nothing")
            return
        }
        guard case .opened(let typed) = ProtectionCopyDoors.lookInside(
            CopyDoorsContext(stepped.b), copy: row.copy, typed: TypedSecrets(words: stepped.aWords)) else {
            Issue.record("A's own words open it")
            return
        }
        #expect(try typed.notes().map(\.title).contains("A's own note"))
        typed.close()
        #expect(LookPlant.writeLogs(road) == logs, "no keychain, memory or Apple write")
        #expect(try LookPlant.untouched(road) == afterRoadsGone, "nothing written (the roads gone by the test's own hand)")
        #expect(before.container == afterRoadsGone.container)
    }

    /// FROM AN OPEN LIBRARY: Make this my library on A's previous library — A's writing returns as a NEW library (rule 17: a
    /// fresh identity), under her current pair, and B steps aside whole in its turn; A's folder stays as it was.
    @Test func aSteppedAsideLibraryReturnsThroughMakeThisMyLibraryFromAnOpenLibrary() async throws {
        let road = PlantedRoad()
        let stepped = try await ArcPlant.aSteppedAside(road)
        let row = try #require(ArcPlant.previousRow(ProtectionCopyDoors.listing(stepped.b), library: stepped.aID))
        let aFolder = try #require(stepped.b.system.places.withFile(catalogID: row.id) { $0.deletingLastPathComponent() })
        let aFolderBefore = try CopyDoorsPlant.tree(aFolder)
        let bID = try #require(stepped.b.library.record?.libraryID)
        let pair = TypedSecrets(words: stepped.aWords)  // B is under her current pair — A's words, carried by rule 17
        guard case .ready(let copy, let catalog, let opened) = ProtectionCopyDoors.preflight(
            stepped.b, row: row, copySecrets: .none, currentPair: pair) else {
            Issue.record("the preflight passes: its own quiet road, her current pair")
            return
        }
        let made = await ProtectionCopyDoors.makeMine(
            stepped.b, copy: copy, catalog: catalog, row: row, opened: opened, currentPair: pair)
        #expect(made.outcome == .made)
        let record = try #require(try ProtectionLibraryFiles.readRecord(at: road.slot.places.slot, key: made.reopenKey))
        #expect(record.libraryID != stepped.aID && record.libraryID != bID, "a NEW library, A's writing in it")
        #expect(try ArcPlant.titles(road, key: made.reopenKey).contains("A's own note"))
        #expect(CopyDoorsPlant.asideFolders(road.slot.places).count == 2, "B stepped aside whole in its turn")
        #expect(try CopyDoorsPlant.tree(aFolder) == aFolderBefore, "A's own folder untouched — a copy is a copy")
    }

    /// FROM THE EMPTY SLOT (T-5): B's file gone (the missing face), A's previous library lands in the empty slot with A's
    /// own words typed — A's writing as a NEW library; B's key file set aside, never written over.
    @Test func aSteppedAsideLibraryReturnsThroughMakeThisMyLibraryFromTheEmptySlot() async throws {
        let road = PlantedRoad()
        let stepped = try await ArcPlant.aSteppedAside(road)
        let bID = try #require(stepped.b.library.record?.libraryID)
        ProtectionLibraryFiles.removeWithSidecars(road.slot.places.slot)
        let ctx = CopyDoorsContext(road.context())
        let row = try #require(ArcPlant.previousRow(ProtectionCopyDoors.listing(ctx), library: stepped.aID))
        let result = await ProtectionCopyDoors.makeMineInTheEmptySlot(
            ctx, row: row, copySecrets: TypedSecrets(words: stepped.aWords))
        #expect(result.outcome == .made)
        let key = try #require(result.key)
        let record = try #require(try ProtectionLibraryFiles.readRecord(at: road.slot.places.slot, key: key))
        #expect(record.libraryID != stepped.aID && record.libraryID != bID)
        #expect(try ArcPlant.titles(road, key: key).contains("A's own note"))
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(try live.open(words: stepped.aWords) == key, "under A's own words, typed at the door")
    }

    /// THE DOORS' AVAILABILITY WITH NO LIBRARY OPEN (the gap the arc showed — F-U1b-2): the missing face's *Restore from
    /// Backup…* on the new road is the doors over this Mac's copies (rule 17: "The app's Restore from Backup is this door")
    /// — the listing holds A's previous library, and its row's *Make this my library…* lands it in the empty slot under
    /// A's own words. Over the same roads the bootstrap composes with no library open (`copyDoorsRoadsWithoutALibrary`).
    @Test func withNoLibraryOpenTheRestoreListOffersThePreviousLibraryAndLandsIt() async throws {
        let road = PlantedRoad()
        let stepped = try await ArcPlant.aSteppedAside(road)
        ProtectionLibraryFiles.removeWithSidecars(road.slot.places.slot)
        let doors = CopyDoorsModel(roads: ArcPlant.noLibraryRoads(road))
        await doors.beginListing()
        guard case .listing(let listing) = doors.phase else {
            Issue.record("the listing: \(doors.phase)")
            return
        }
        let row = try #require(ArcPlant.previousRow(listing, library: stepped.aID), "A's previous library is listed")
        #expect(doors.offersLookInside && doors.offersMakeMine)
        await doors.openMakeMine(row)
        guard case .makeMine(let confirm) = doors.phase else {
            Issue.record("the confirm: \(doors.phase)")
            return
        }
        #expect(confirm.intoTheEmptySlot)
        await confirm.submitIntoTheEmptySlot(copySecret: stepped.aWords.joined(separator: " "))
        #expect({ if case .done = doors.phase { true } else { false } }(), "made: \(String(describing: confirm.refusal))")
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        let key = try live.open(words: stepped.aWords)
        #expect(try ArcPlant.titles(road, key: key).contains("A's own note"), "A's writing, landed")
    }

    /// THE PICKED ROAD to the same copy (the missing face has no Restore list — its *Open Library…* is the door): A's
    /// previous-library folder (or its store) picked by hand is the catalogue's own copy, used where it is — never filed.
    @Test func pickingAPreviousLibraryByHandUsesItWhereItIs() async throws {
        let road = PlantedRoad()
        let stepped = try await ArcPlant.aSteppedAside(road)
        let row = try #require(ArcPlant.previousRow(ProtectionCopyDoors.listing(stepped.b), library: stepped.aID))
        let store = try #require(stepped.b.system.places.withFile(catalogID: row.id) { $0 })
        let safety = road.slot.places.backups.appendingPathComponent(CatalogNames.safetyCopiesFolderName)
        let ctx = CopyDoorsContext(road.context())
        for picked in [store, store.deletingLastPathComponent()] {
            guard case .copy(let found) = ProtectionCopyDoors.pick(picked, ctx) else {
                Issue.record("\(picked.lastPathComponent): the catalogue's copy")
                continue
            }
            #expect(found.id == row.id && found.kind == .previousLibrary)
        }
        #expect(!FileManager.default.fileExists(atPath: safety.path), "nothing filed")
    }
}
