import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13n-a — THE LIVE ROUND, HEADLESS (the plan's acceptance, second bullet,
/// as far as it can run without the screen): the committed PT/EN sample book
/// (`notes/plans/13n-a-sample/o ladrão de raios/` — two chapters, fanned
/// blocks, one take with internal line breaks) read from DISK the way the
/// import door reads a folder, imported as ONE book, read through a lens per
/// language, then ONE structural undo takes the whole book and ONE redo
/// brings it back whole — lenses included.
///
/// The GUI half (the real File ▸ Import… panel, Lenses on screen, ⌥⌘Z /
/// ⇧⌥⌘Z pressed) is the unit record's walk section.
@Suite("The PT/EN sample book round (13n-a, headless)")
struct SampleBookDrillTests {
    /// The fixture folder, from this file's own location in the repo.
    private static let fixture: URL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // VariorumCoreTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // repo root
        .appendingPathComponent("notes/plans/13n-a-sample/o ladrão de raios")

    /// The folder read the way `DocumentImporter.readFolder` reads one:
    /// hidden entries skipped, folder-relative paths, first-level folders.
    private func readFixture() throws -> (files: [VariorumDocumentFolder.File], subfolders: [String]) {
        let base = Self.fixture.resolvingSymlinksInPath().standardizedFileURL.pathComponents
        var files: [VariorumDocumentFolder.File] = []
        var subfolders: [String] = []
        let walker = FileManager.default.enumerator(
            at: Self.fixture, includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles])
        while let item = walker?.nextObject() as? URL {
            let components = item.resolvingSymlinksInPath().standardizedFileURL.pathComponents
            let relative = components.dropFirst(base.count).joined(separator: "/")
            if (try item.resourceValues(forKeys: [.isDirectoryKey])).isDirectory == true {
                subfolders.append(relative)
            } else if VariorumDocumentFolder.isImportable(relative) {
                files.append(.init(relativePath: relative, contents: try String(contentsOf: item, encoding: .utf8)))
            }
        }
        return (files, subfolders)
    }

    @Test func theSampleBookImportsWholeReadsThroughALensPerLanguageAndUndoesInOnePress() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let read = try readFixture()
            let book = try VariorumDocumentFolder.plan(
                folderName: Self.fixture.lastPathComponent, files: read.files, subfolders: read.subfolders)
            #expect(book.name == "o ladrão de raios")
            #expect(book.chapters.map(\.name) == ["1 o semideus", "2 a excursão"])
            #expect(book.noteCount == 4)

            let imported = try ops.importBook(book)
            #expect(stack.depth == 1)
            let titles = try db.read { database in
                try imported.postIDs.map { try Container.fetchOne(database, key: $0)?.title ?? "" }
            }
            #expect(titles == ["abertura", "a escola", "o museu", "posfácio"])

            // "abertura": three Portuguese blocks, each fanned with "english";
            // the third also carries an unlabeled take with line breaks.
            let abertura = imported.postIDs[0]
            let slots = try db.read { try Queries.renderPost($0, containerID: abertura) }
            #expect(slots.map(\.activeVariantCount) == [2, 2, 3])
            let english = try db.read { database in
                try slots.map { slot in
                    try #require(try Variant.fetchOne(
                        database,
                        sql: """
                            SELECT * FROM variant WHERE block_id = ? AND label = 'english'
                              AND deleted_at IS NULL
                            """,
                        arguments: [slot.blockID]))
                }
            }

            // A lens per language: português follows the chosen takes, english
            // picks every block's "english" take.
            let portugues = try ops.createLens(post: abertura, name: "português")
            let englishLens = try ops.createLens(post: abertura, name: "english")
            for (slot, take) in zip(slots, english) {
                try ops.setLensChoice(lens: englishLens.id, block: slot.blockID, variant: take.id)
            }
            let ptText = try db.read {
                try Queries.renderPost($0, containerID: abertura, throughLens: portugues.id).compactMap(\.text)
            }
            let enText = try db.read {
                try Queries.renderPost($0, containerID: abertura, throughLens: englishLens.id).compactMap(\.text)
            }
            #expect(ptText.first == "Eu não pedi para herdar o observatório.\n")
            #expect(enText == [
                "I never asked to inherit the observatory.",
                "It stands on an island with no bridge, and the ferry only runs when the tide allows.",
                "Running an observatory is hard work. Most nights, nobody says thank you.",
            ])

            // ⌥⌘Z once — the whole book gone (its notes and their lenses
            // with it); ⇧⌥⌘Z — back whole.
            #expect(try stack.undo(with: ops) == Operations.importUndoLabel)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 0)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container WHERE deleted_at IS NULL") == 0)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens WHERE deleted_at IS NULL") == 0)

            #expect(try stack.redo(with: ops) == Operations.importUndoLabel)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 1)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container WHERE deleted_at IS NULL") == 4)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading_section WHERE deleted_at IS NULL") == 2)
            let enAgain = try db.read {
                try Queries.renderPost($0, containerID: abertura, throughLens: englishLens.id).compactMap(\.text)
            }
            #expect(enAgain == enText)
        }
    }
}
