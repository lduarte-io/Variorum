//
//  ProtectionCopyPeekTests.swift
//  VariorumCoreTests — VX-306 U3: LOOK INSIDE's read road (`Protection/Files/ProtectionCopyPeek.swift`; the orchestrator's
//  ruling P-VX306-U3-15 — the read-only facts sheet), on real SQLCipher files in a temp folder — headless, both
//  configurations. A keyed library planted through the operations (its books, its notes newest first, a note with a
//  second take chosen, an archived note, a deleted one, a gathering), then looked at: the catalogued file is never opened
//  in place (its folder byte-identical, no sidecar made beside it), the books carry their member counts, the notes come a
//  page at a time newest first, a note reads as its page does, a wrong key refuses, closing deletes the private folder —
//  and the notes page walks the touched index backward with no temp sort (P1).
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-306 U3 — Look inside's read road (real SQLCipher, temp folders)")
struct ProtectionCopyPeekTests {
    final class Folder {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("vx306-peek-\(UUID().uuidString)", isDirectory: true)
        init() { try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }
        deinit { try? FileManager.default.removeItem(at: url) }
        func file(_ name: String) -> URL { url.appendingPathComponent(name) }
    }

    struct Planted {
        var store: URL
        var key: StoreKey
        var newest: String
        var older: String
        var archived: String
        var takeText: String
        /// VX-307 U2c (VX-413): the deleted note's id, and the newest note's text as Copy full text writes it for the
        /// LIVE library (`Queries.variorumDocumentText` over the open database, before the pool closed).
        var deleted: String
        var newestDocument: String
    }

    /// A keyed library through the ordinary ops: two living notes (the newer one with two blocks, its second block's
    /// SECOND take chosen), an archived note, a deleted one, a book holding both living notes, a gathering.
    static func plant(_ folder: Folder) throws -> Planted {
        let url = folder.url.appendingPathComponent("catalogued", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        let store = url.appendingPathComponent("variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.onDisk(url: store, key: key)
        let tick = LockIsolated(0)
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        return try withDependencies {
            $0.database = database
            $0.uuid = .incrementing
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 306))
            $0.date = DateGenerator {
                start.addingTimeInterval(Double(tick.withValue { value -> Int in defer { value += 1 }; return value }))
            }
        } operation: {
            let ops = Operations()
            let older = try ops.createPost(title: "The older note")
            _ = try ops.newBlock(in: older.id, text: "An older paragraph.")
            let archived = try ops.createPost(title: "Archived")
            _ = try ops.newBlock(in: archived.id, text: "kept out of view")
            try ops.archiveContainer(archived.id)
            let deleted = try ops.createPost(title: "Deleted")
            _ = try ops.newBlock(in: deleted.id, text: "gone")
            try ops.deleteContainer(deleted.id)
            let newest = try ops.createPost(title: "The newest note")
            _ = try ops.newBlock(in: newest.id, text: "First block.")
            let second = try ops.newBlock(in: newest.id, text: "The first take.")
            let take = try ops.branchVariant(second.block.id, from: second.variant.id)
            try ops.autosave(take.id, text: "The second take, chosen.", charDelta: 10)
            try ops.chooseVariant(second.block.id, variantID: take.id)
            // VX-307 U2c (VX-413): a labeled take beside the chosen one and a tag — what the full text carries.
            try ops.setTakeLabel(second.variant.id, label: "first")
            let trip = try ops.createTag(name: "trip")
            _ = try ops.applyTag(trip.id, toPost: newest.id)
            let book = try ops.createReading(name: "A book", kind: .book)
            try ops.addPostToReading(older.id, to: book.id)
            try ops.addPostToReading(newest.id, to: book.id)
            _ = try ops.createReading(name: "A gathering", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let document = try database.read { try Queries.variorumDocumentText($0, postID: newest.id) }
            let (_, binding) = database.asRebindable()
            binding.lock()  // the pool closed, the WAL drained — the library as a closed app leaves it
            return Planted(
                store: store, key: key, newest: newest.id, older: older.id, archived: archived.id,
                takeText: "The second take, chosen.", deleted: deleted.id, newestDocument: document)
        }
    }

    static func bytes(_ folder: URL) throws -> [String: Data] {
        var out: [String: Data] = [:]
        for name in try FileManager.default.contentsOfDirectory(atPath: folder.path) {
            out[name] = try Data(contentsOf: folder.appendingPathComponent(name))
        }
        return out
    }

    @Test func aLookReadsTheCopysBooksNotesAndANotesTextAndNeverTouchesTheCataloguedFile() throws {
        let folder = Folder()
        let planted = try Self.plant(folder)
        let catalogued = planted.store.deletingLastPathComponent()
        let before = try Self.bytes(catalogued)
        let scratch = folder.file("scratch")
        let reader = try ProtectionCopyPeek.open(planted.store, key: planted.key, inside: scratch)
        #expect(!reader.folder.path.hasPrefix(catalogued.path), "the look reads a PRIVATE copy")
        let books = try reader.books()
        #expect(books.map(\.name) == ["A book"], "a gathering holds no membership — not listed")
        #expect(books.first?.noteCount == 2)
        let notes = try reader.notes()
        #expect(notes.map(\.id) == [planted.newest, planted.older], "the living notes, newest first")
        #expect(!notes.contains { $0.id == planted.archived })
        let text = try #require(try reader.note(id: planted.newest))
        #expect(text.title == "The newest note")
        #expect(text.blocks == ["First block.", planted.takeText], "the page as it reads — the chosen take")
        #expect(try reader.notes(offset: 1, limit: 1).map(\.id) == [planted.older], "a page at a time")
        reader.close()
        #expect(reader.isClosed)
        #expect(!FileManager.default.fileExists(atPath: reader.folder.path), "closing forgets — the private folder gone")
        #expect(try Self.bytes(catalogued) == before, "the catalogued file is only read — nothing beside it, nothing changed")
        #expect(throws: (any Error).self) { _ = try reader.notes() }
    }

    @Test func aWrongKeyRefusesAndLeavesNoPrivateFolder() throws {
        let folder = Folder()
        let planted = try Self.plant(folder)
        let scratch = folder.file("scratch")
        #expect(throws: (any Error).self) {
            _ = try ProtectionCopyPeek.open(planted.store, key: StoreKey.mint(), inside: scratch)
        }
        let left = (try? FileManager.default.contentsOfDirectory(atPath: scratch.path)) ?? []
        #expect(left.isEmpty, "\(left)")
    }

    /// VX-307 U2c — VX-413 (her word: "copy full text is a good idea"): a look hands a note's FULL TEXT in the
    /// Variorum document format — byte-equal to what Copy full text writes for the same note in the live library (the
    /// title, every live take with its label, the tags), so File ▸ Import re-imports it whole — and the catalogued file is
    /// still only read. A deleted note has no full text; a closed look refuses.
    @Test func aLookHandsANotesFullTextInTheDocumentFormatAndWritesNothing() throws {
        let folder = Folder()
        let planted = try Self.plant(folder)
        let catalogued = planted.store.deletingLastPathComponent()
        let before = try Self.bytes(catalogued)
        let reader = try ProtectionCopyPeek.open(planted.store, key: planted.key, inside: folder.file("scratch"))
        let text = try #require(try reader.fullText(id: planted.newest))
        #expect(text == planted.newestDocument, "the clipboard carries exactly Copy full text's document")
        #expect(text.hasPrefix("{t:\"The newest note\"} {#trip}\n\nFirst block."), "\(text)")
        #expect(text.contains(VariorumDocument.alternatesHeader) && text.contains("take: \"first\"\n\nThe first take."))
        let parsed = try VariorumDocument.parse(text)
        #expect(parsed.title == "The newest note" && parsed.tagPaths == ["trip"])
        #expect(parsed.blocks.map(\.text) == ["First block.", planted.takeText])
        #expect(parsed.blocks.last?.alternates == [VariorumDocument.Take(label: "first", text: "The first take.")])
        #expect(try reader.fullText(id: planted.deleted) == nil, "a deleted note has no full text")
        #expect(try reader.fullText(id: "no-such-note") == nil)
        reader.close()
        #expect(try Self.bytes(catalogued) == before, "the catalogued file is only read")
        #expect(throws: (any Error).self) { _ = try reader.fullText(id: planted.newest) }
    }

    /// P1: the notes page walks `idx_container_touched` backward — no temp sort over the corpus.
    @Test func theNotesPageWalksTheTouchedIndexWithNoTempSort() throws {
        let folder = Folder()
        let planted = try Self.plant(folder)
        let reader = try ProtectionCopyPeek.open(planted.store, key: planted.key, inside: folder.file("scratch"))
        defer { reader.close() }
        let plan = try reader.queryPlan(ProtectionCopyPeek.notesSQL, arguments: [100, 0]).joined(separator: " | ")
        #expect(plan.contains("idx_container_touched"), "\(plan)")
        #expect(!plan.contains("TEMP B-TREE"), "\(plan)")
    }

    /// A library created but never opened holds `protection_record` alone — it reads as empty, never as an error.
    @Test func aLibraryWithNoAppTablesReadsEmpty() throws {
        let folder = Folder()
        let store = folder.file("variorum.sqlite")
        let key = StoreKey.mint()
        try ProtectionLibraryFiles.createLibrary(
            at: store, key: key,
            record: ProtectionRecord.minting(
                libraryID: UUID().uuidString.lowercased(), mode: .standard, account: nil,
                currentFingerprint: StoreKeyEnvelope.fingerprint(of: key), at: Date()),
            date: Date())
        let reader = try ProtectionCopyPeek.open(store, key: key, inside: folder.file("scratch"))
        defer { reader.close() }
        #expect(try reader.books().isEmpty && reader.notes().isEmpty && reader.note(id: "x") == nil)
    }
}
