import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-566 (the VX-620 run, batch 3 — the record
// `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`, BATCH 3 RECORD). The
// agent report: importing 49 notes into a chapter cost 49 extra
// `file_note_in_chapter` calls, because `import_document` takes `book_id` but no
// `section_id` — and `create_note` already takes one (VX-252). THE BUILD:
// `create_note`'s exact shape on the ONE-DOCUMENT form — with `book_id` only, the
// note files under that chapter in the same call and the same client-named undo;
// after the book's own decision, any `section_id` that is not a live chapter of
// THAT book answers the ONE chapter sentence `add_note_to_book` speaks, byte for
// byte (no oracle). The BOOK form has no honest `section_id` (its chapters come
// from `book.chapters`), so it REFUSES one in words at the parse — the wire's
// discipline for a meaningful-elsewhere argument (`book_id` with a book refuses),
// never a silent ignore that would answer success with the notes unfiled.
//
// RED ON OLD: the one-document form ignored `section_id` silently (the note landed
// UNSECTIONED, answering success, no echo), and the book form imported with it.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("VX-566 — import_document files one document into a chapter, as create_note does", .serialized)
struct MCPImportSectionServerTests {
    private let document = "{t:\"capítulo um\"}\n\nOlá.\n\nAdeus."

    private func liveNotes(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? -1
        }
    }

    private func liveBooks(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") ?? -1
        }
    }

    private func filing(_ h: ServerHarness, note: String, book: String) async throws -> String? {
        try await h.database.read { db in
            try String.fetchOne(
                db, sql: "SELECT section_id FROM reading_post WHERE post_id = ? AND reading_id = ? AND deleted_at IS NULL",
                arguments: [note, book])
        }
    }

    // MARK: - Filed in the same call, the same undo (RED ON OLD: landed unsectioned)

    @Test func oneDocumentFilesUnderItsChapterInTheSameCallAndTheSameUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "um")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let depth = h.undoStack.depth

            let imported = try await call(connection, "import_document", [
                "document": .string(document), "book_id": .string(book.id), "section_id": .string(chapter.id),
            ])
            #expect(imported.isError != true, "\(text(imported))")
            let answer = try json(imported)
            let noteID = try #require(answer["note_id"] as? String)
            #expect(try await filing(h, note: noteID, book: book.id) == chapter.id, "filed under the chapter")
            #expect(answer["section_id"] as? String == chapter.id, "the answer says where (create_note's echo)")
            #expect((answer["blocks"] as? [Any])?.count == 2, "the rest of VX-252's answer, unchanged")
            #expect(h.undoStack.depth == depth + 1 && h.undoStack.topLabel == "claude-code's import",
                    "the filing rides the import's ONE client-named undo")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's import")
            #expect(try await h.database.read { try Container.fetchOne($0, key: noteID) }?.deletedAt != nil)
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's import")
            #expect(try await filing(h, note: noteID, book: book.id) == chapter.id, "the redo returns it filed")

            // Without section_id the one-document answer is byte-unchanged: no key.
            let plain = try json(try await call(connection, "import_document", [
                "document": .string(document), "book_id": .string(book.id),
            ]))
            #expect(plain["section_id"] == nil)
            await h.hangUp(connection)
        }
    }

    // MARK: - One sentence for every id that isn't this book's chapter (RED ON OLD: each landed)

    /// The book is decided first (the one not-shared shape for an unreachable
    /// book, whatever `section_id` names — a guard); inside a reachable book,
    /// nothing, a deleted chapter, a readable book's chapter, a hidden book's
    /// chapter, and any chapter under a GATHERING's id answer the one sentence —
    /// byte-identical to `create_note`'s and to `add_note_to_book`'s for the same
    /// id — and mint nothing.
    @Test func everySectionIDThatIsntALiveChapterOfTheBookAnswersTheOneSentenceAndMintsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let ops = h.operations
            let book = try ops.createReading(name: "o ladrão de raios", kind: .book)
            let gone = try ops.createSection(in: book.id, name: "deleted")
            try ops.deleteSection(gone.id)
            let readable = try ops.createReading(name: "another book", kind: .book)
            let readableChapter = try ops.createSection(in: readable.id, name: "theirs")
            let hidden = try ops.createReading(name: "never shared", kind: .book)
            let hiddenChapter = try ops.createSection(in: hidden.id, name: "hidden")
            let parser = try ops.createTag(name: "parser", wingID: "")
            let gathering = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            let loose = try ops.createPost(title: "a loose note")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let client = try h.client("claude-code").id
            _ = try ops.grantMCPAccess(client, spec(.read, .book, readable.id))
            _ = try ops.grantMCPAccess(client, spec(.writeNew, .gathering, gathering.id))
            _ = try ops.grantMCPAccess(client, spec(.writeNew, .note, loose.id))
            let notes = try await liveNotes(h)
            let depth = h.undoStack.depth

            let chapterSentence =
                "section_id isn't a chapter of this book (list_notes or create_section gives chapter ids)."
            for sectionID in ["no-such-chapter", gone.id, readableChapter.id, hiddenChapter.id] {
                let imported = try await call(connection, "import_document", [
                    "document": .string(document), "book_id": .string(book.id), "section_id": .string(sectionID),
                ])
                let created = try await call(connection, "create_note", [
                    "book_id": .string(book.id), "section_id": .string(sectionID), "text": .string("Olá."),
                ])
                let added = try await call(connection, "add_note_to_book", [
                    "note_id": .string(loose.id), "book_id": .string(book.id), "section_id": .string(sectionID),
                ])
                #expect(imported.isError == true, "\(sectionID): \(text(imported))")
                #expect(text(imported) == chapterSentence, "\(sectionID): \(text(imported))")
                #expect(text(imported) == text(created) && text(imported) == text(added),
                        "\(sectionID): the ONE sentence, byte for byte, on all three doors")
            }
            // A gathering's id holds no chapter: the same sentence create_note says there.
            let intoGathering = try await call(connection, "import_document", [
                "document": .string(document), "book_id": .string(gathering.id),
                "section_id": .string(readableChapter.id),
            ])
            let createGathering = try await call(connection, "create_note", [
                "book_id": .string(gathering.id), "section_id": .string(readableChapter.id), "text": .string("Olá."),
            ])
            #expect(intoGathering.isError == true && text(intoGathering) == chapterSentence)
            #expect(text(intoGathering) == text(createGathering))
            #expect(try await liveNotes(h) == notes && h.undoStack.depth == depth, "a refusal mints nothing")

            // THE GUARD (green on both sides): an unreachable book answers the one
            // not-shared sentence whatever section_id names.
            let bare = try await call(connection, "import_document", [
                "document": .string(document), "book_id": .string(hidden.id),
            ])
            let named = try await call(connection, "import_document", [
                "document": .string(document), "book_id": .string(hidden.id), "section_id": .string(hiddenChapter.id),
            ])
            #expect(bare.isError == true && text(bare).hasPrefix("That book isn't shared with this client"))
            #expect(text(named) == text(bare), "byte-identical")
            await h.hangUp(connection)
        }
    }

    // MARK: - section_id goes with book_id (RED ON OLD: imported bookless)

    @Test func sectionIDWithoutABookIsRefusedAtTheParseInCreateNotesWords() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "um")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let notes = try await liveNotes(h)
            let places: [[String: Value]] = [["wing_id": .string("")], [:]]
            for place in places {
                var arguments: [String: Value] = ["section_id": .string(chapter.id), "document": .string(document)]
                arguments.merge(place) { _, given in given }
                let refused = try await call(connection, "import_document", arguments)
                #expect(refused.isError == true)
                #expect(text(refused) == MCPWriteTools.sectionWithoutBookWords, "\(text(refused))")
            }
            #expect(try await liveNotes(h) == notes)
            await h.hangUp(connection)
        }
    }

    // MARK: - The book form brings its own chapters (RED ON OLD: imported, section_id ignored)

    @Test func aWholeBookRefusesASectionIDItsChaptersComeFromTheBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let elsewhere = try h.operations.createReading(name: "elsewhere", kind: .book)
            let chapter = try h.operations.createSection(in: elsewhere.id, name: "um")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let (notes, books) = (try await liveNotes(h), try await liveBooks(h))
            let book: Value = .object([
                "name": .string("a whole book"),
                "chapters": .array([.object(["name": .string("one"), "documents": .array([.string("Ch 1.")])])]),
            ])
            let refused = try await call(connection, "import_document", [
                "wing_id": .string(""), "book": book, "section_id": .string(chapter.id),
            ])
            #expect(refused.isError == true)
            // The sentence as a literal, so the pin compiles — and runs red — on the old tree.
            #expect(text(refused)
                    == "section_id goes with document and book_id: a book brings its own chapters in book.chapters.",
                    "\(text(refused))")
            let (notesAfter, booksAfter) = (try await liveNotes(h), try await liveBooks(h))
            #expect(notesAfter == notes && booksAfter == books, "nothing imported")
            // Without it, the book form is unchanged.
            let whole = try await call(connection, "import_document", ["wing_id": .string(""), "book": book])
            #expect(whole.isError != true, "\(text(whole))")
            await h.hangUp(connection)
        }
    }

    // MARK: - The catalog says it

    @Test func theCatalogDeclaresSectionIDAndSaysBothForms() throws {
        let properties = MCPToolCatalog.importDocument.inputSchema.objectValue?["properties"]?.objectValue ?? [:]
        let declared = try #require(properties["section_id"]?.objectValue?["description"]?.stringValue)
        #expect(declared.contains("with book_id"), "\(declared)")
        let description = MCPToolCatalog.importDocument.description
        #expect(description.contains("section_id (with book_id) files the document's note under one of that book's chapters"),
                "\(description)")
        #expect(description.contains("a book brings its own chapters in book.chapters"), "\(description)")
    }
}
