//
//  PlaintextExportBringInRoadTests.swift
//  VariorumTests — VX-309 U1b piece 3: T-8 on the app's road — A PLAINTEXT EXPORT BROUGHT IN AS A NEW LIBRARY, over planted
//  keychain leaves and a temp slot with the real file leaves (`PlantedRoad` — no keychain; the suite also runs headless in
//  the implementer's SwiftPM harness). The mapping ruled at the plan's §5b-R; the act: the creation's road (fresh identity,
//  key, device ID, Standard, the words for the band), what stands in the slot set aside WHOLE first (its restore hold with
//  it — the new library is never held), the export's content minted headless into the new store before its first open,
//  the export only read. The preflight refuses an export of another build's schema with nothing written; the doors' brain
//  names the export and offers its one door. New road — red by construction on the pre-unit tree (the pick refused it).
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum ExportPlant {
    /// A plaintext export of a small library (a book with a chapter and two notes, a bookless note, a tag, a snippet
    /// group), written into `folder` — its file and the source's ids.
    static func export(into folder: URL) throws -> URL {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let source = try AppDatabase.onDisk(url: folder.appendingPathComponent("source.sqlite"), key: StoreKey.mint())
        try withDependencies {
            $0.database = source
            $0.uuid = .init { UUID() }
            $0.date = .init { Date() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: {
            let ops = Operations()
            let first = try ops.importDocument(VariorumDocument.NamedDocument(
                fallbackTitle: "x", document: try VariorumDocument.parse("{t:\"First\"} {#trip}\n\nThe road out.")))
            let second = try ops.importDocument(VariorumDocument.NamedDocument(
                fallbackTitle: "Second", document: try VariorumDocument.parse("The road back.")))
            _ = try ops.importDocument(VariorumDocument.NamedDocument(
                fallbackTitle: "Loose", document: try VariorumDocument.parse("Bookless.")))
            let book = try ops.createReading(name: "Travels", kind: .book)
            let part = try ops.createSection(in: book.id, name: "Part one")
            _ = try ops.addPostToReading(first.post.id, to: book.id)
            _ = try ops.addPostToReading(second.post.id, to: book.id)
            try ops.assignPostToSection(first.post.id, in: book.id, section: part.id)
            let pool = try ops.createPool(title: "Ideas")
            _ = try ops.importBlocks(into: pool.id, text: "A scrap.")
        }
        let url = folder.appendingPathComponent("export.sqlite")
        try StorePlaintextExport.export(from: source, to: url)
        return url
    }

    /// The new library's titles and books, read back from its store.
    static func contents(_ road: PlantedRoad, key: StoreKey) throws -> (notes: [String], books: [String], pools: [String]) {
        let database = try AppDatabase.onDisk(url: road.slot.places.slot, key: key)
        defer { _ = database.asRebindable().binding.lock() }
        return try database.read { db in
            (try String.fetchAll(db, sql: "SELECT title FROM container WHERE kind = 'post' AND deleted_at IS NULL ORDER BY title"),
             try String.fetchAll(db, sql: "SELECT name FROM reading WHERE deleted_at IS NULL ORDER BY name"),
             try String.fetchAll(db, sql: "SELECT title FROM container WHERE kind = 'pool' AND deleted_at IS NULL"))
        }
    }
}

@Suite("VX-309 U1b — T-8: a plaintext export brought in as a new library, on the app's road (planted, no keychain)", .serialized)
@MainActor
struct PlaintextExportBringInRoadTests {
    /// FROM AN OPEN LIBRARY: the export's content lands in a NEW library made by the creation's road; the library that was
    /// open steps aside WHOLE (its file, its key file, its hold — the new library is never held); the export only read.
    @Test func anExportComesInAsANewLibraryAndTheOpenOneStepsAsideWhole() async throws {
        let road = PlantedRoad()
        let (old, _) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: old.key)
        let oldID = try #require(old.library.record?.libraryID)
        let oldFile = try Data(contentsOf: road.slot.places.liveKeyFile)
        try LibraryRestoreHold.set(besideStore: road.slot.places.slot, asOf: nil, now: Date(timeIntervalSince1970: 9))
        let downloads = road.slot.root.appendingPathComponent("Downloads/vx309-export", isDirectory: true)
        let export = try ExportPlant.export(into: downloads)
        let exportBytes = try Data(contentsOf: export)
        guard case .plan(let plan) = ProtectionCopyDoors.readPlaintextExport(export) else {
            Issue.record("the export plans")
            return
        }
        let result = await ProtectionCopyDoors.landPlaintextExport(road.context(), plan: plan)
        #expect(result.refusal == nil && !result.stoppedEarly)
        let created = try #require(result.created)
        let record = try #require(created.session.library.record)
        #expect(record.libraryID != oldID && record.mode == .standard && record.account == nil, "a NEW library, Standard")
        #expect(created.session.isFresh, "the creation's road")
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(try live.open(words: created.words.words) == created.session.key, "its words — the band offers fresh ones")
        #expect(live.history.isEmpty && live.passphrase == nil)
        #expect(!LibraryRestoreHold.isHeld(besideStore: road.slot.places.slot), "never held — a fresh mint never synced")
        // The open library, aside WHOLE — with its key file and its hold.
        let folder = try #require(CopyDoorsPlant.asideFolders(road.slot.places).first)
        #expect(ProtectionLibraryFiles.opens(folder.appendingPathComponent(CatalogNames.libraryFilename), key: old.key))
        #expect(try Data(contentsOf: folder.appendingPathComponent(ProtectionNames.keyFilename)) == oldFile)
        #expect(FileManager.default.fileExists(atPath: folder.appendingPathComponent(LibraryRestoreHold.filename).path),
                "its hold went with it")
        // The export's content, minted fresh in the new store.
        let contents = try ExportPlant.contents(road, key: created.session.key)
        #expect(contents.notes == ["First", "Loose", "Second"] && contents.books == ["Travels"] && contents.pools == ["Ideas"])
        #expect(result.landing.notes == 3 && result.landing.books == 1 && result.landing.snippets == 1)
        #expect(try Data(contentsOf: export) == exportBytes, "the export is only read")
        #expect(road.memory.items.keys.sorted() == [record.libraryID], "this Mac remembers ONE library")
        // The receipt says what landed.
        #expect(ProtectionWords.bringInReceipt(result.landing, stoppedEarly: false)
            == "A new library holds the plain-text copy's writing: 1 book \u{00B7} 3 notes \u{00B7} 1 snippet group.")
    }

    /// FROM THE MISSING FACE: no library in the slot — the missing library's key file steps aside (never written over) and
    /// the export comes in as a new library.
    @Test func atTheMissingFaceTheExportComesInAndTheMissingKeyFileStepsAside() async throws {
        let road = PlantedRoad()
        let (old, _) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: old.key)
        let oldFile = try Data(contentsOf: road.slot.places.liveKeyFile)
        ProtectionLibraryFiles.removeWithSidecars(road.slot.places.slot)
        let export = try ExportPlant.export(into: road.slot.root.appendingPathComponent("Downloads/vx309-export"))
        guard case .plan(let plan) = ProtectionCopyDoors.readPlaintextExport(export) else {
            Issue.record("the export plans")
            return
        }
        let result = await ProtectionCopyDoors.landPlaintextExport(road.context(), plan: plan)
        let created = try #require(result.created)
        #expect(ProtectionLibraryFiles.opens(road.slot.places.slot, key: created.session.key))
        let folder = try #require(CopyDoorsPlant.asideFolders(road.slot.places).first)
        #expect(try Data(contentsOf: folder.appendingPathComponent(ProtectionNames.keyFilename)) == oldFile)
        #expect(try ExportPlant.contents(road, key: created.session.key).books == ["Travels"])
    }

    /// THE PREFLIGHT refuses with NOTHING written: an export of an earlier build's schema (its words), and a thing that is
    /// not a plaintext export at all.
    @Test func thePreflightRefusesAnotherBuildsExportAndWritesNothing() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: session.key)
        let export = try ExportPlant.export(into: road.slot.root.appendingPathComponent("Downloads/vx309-export"))
        // An earlier build's export: its newest migration not yet applied (the plain file opens with no key).
        let queue = try DatabaseQueue(path: export.path)
        try await queue.write { db in
            let last = try #require(try String.fetchOne(db, sql: "SELECT identifier FROM grdb_migrations ORDER BY rowid DESC LIMIT 1"))
            try db.execute(sql: "DELETE FROM grdb_migrations WHERE identifier = ?", arguments: [last])
        }
        try queue.close()
        let before = try CopyDoorsPlant.tree(road.slot.places.container)
        guard case .refused(.exportRefused(let sentence)) = ProtectionCopyDoors.readPlaintextExport(export) else {
            Issue.record("an earlier build's export refuses")
            return
        }
        #expect(sentence == ProtectionWords.exportFromAnEarlierBuild)
        guard case .refused(.unreadableCopy) = ProtectionCopyDoors.readPlaintextExport(road.slot.places.liveKeyFile) else {
            Issue.record("a key file is no export")
            return
        }
        #expect(try CopyDoorsPlant.tree(road.slot.places.container) == before, "nothing written")
    }

    /// A READ-ONLY ROAD (a hosted test run's) never brings an export in — and never moves what stands in the slot first
    /// (the creation itself refuses there, so a step-aside before it would leave the slot empty for nothing).
    @Test func aReadOnlyRoadMovesNothing() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: session.key)
        let export = try ExportPlant.export(into: road.slot.root.appendingPathComponent("Downloads/vx309-export"))
        guard case .plan(let plan) = ProtectionCopyDoors.readPlaintextExport(export) else {
            Issue.record("the export plans")
            return
        }
        let before = try CopyDoorsPlant.tree(road.slot.places.container)
        let result = await ProtectionCopyDoors.landPlaintextExport(road.context(writes: false), plan: plan)
        #expect(result.created == nil && result.refusal != nil)
        #expect(try CopyDoorsPlant.tree(road.slot.places.container) == before, "nothing moved")
        #expect(ProtectionLibraryFiles.opens(road.slot.places.slot, key: session.key))
    }

    /// THE DOORS' BRAIN: a picked export is NAMED (never filed) and its one door offered where the road exists; without
    /// the road it keeps its honest refusal; the door's press made ⇒ the sheet leaves; refused ⇒ the sentence under it.
    @Test func theDoorsNameTheExportAndOfferItsOneDoor() async throws {
        let planted = PlantedCopyDoors()
        let picked = URL(fileURLWithPath: "/tmp/vx309-export.sqlite")
        planted.pickAnswer = .plaintextExport(picked)
        var roads = planted.roads
        var answers: [CopyDoorOutcome] = [.refused(.exportRefused("not this one")), .made]
        roads.bringInPlaintextExport = { _ in answers.removeFirst() }
        let doors = CopyDoorsModel(roads: roads)
        await doors.begin(picked: picked)
        guard case .plaintextExport(let store) = doors.phase else {
            Issue.record("the export's door: \(doors.phase)")
            return
        }
        #expect(store == picked && doors.bringInStepsALibraryAside)
        await doors.bringIn(store)
        #expect(doors.bringInRefusal == "not this one", "refused — said under the door")
        await doors.bringIn(store)
        #expect({ if case .done = doors.phase { true } else { false } }(), "made — the sheet leaves")
        let without = CopyDoorsModel(roads: planted.roads)
        await without.begin(picked: picked)
        guard case .refused(let sentence, _) = without.phase else {
            Issue.record("no road — the honest refusal: \(without.phase)")
            return
        }
        #expect(sentence == ProtectionWords.plaintextCopyNotYet)
    }
}
