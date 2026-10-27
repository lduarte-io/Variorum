import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-252 (VX-336 U5b — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U5b UNIT RECORD D1–D3 and the orchestrator's rulings): A WRITE SAYS THE IDS IT
// MINTED. `create_note` minted every take and answered only `block_ids`, so a client
// that needed a take id (to `save_lens` it, to `edit_take` it) read the whole note
// back — 25 reads and ~2.7M characters in her bilingual-book run. The ruled shape,
// named ONCE (`MCPMintedBlocks`): per block `{block_id, shown_take_id, takes:
// [{take_id, label?}]}`, every take an object in fan order, the shown one included,
// built from what the act minted (no second read). `block_ids` stays beside it (F-6).
// `import_document`'s ONE-document form had the same gap and closes the same way;
// its BOOK form kept its answer (F-2 — a guard here, FLIPPED at VX-567: a whole
// book now answers each note's record too). And `create_note` takes an
// optional `section_id`: the note is filed under that chapter of the book it joins,
// in the same call and the same undo; any id that isn't a live chapter of THAT book
// answers the ONE sentence its siblings speak (F-3 — no oracle), and an unreachable
// book answers the one not-shared sentence whatever `section_id` says (a guard).
//
// Wire only (the SDK's own client over a real socket), so every pin compiles — and
// runs RED — on the tree before the fix: there the answer had no `blocks`, and a
// `section_id` was silently ignored (the note landed unsectioned, answering success).

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

/// One block as the answer's record says it — or as `read_note with_ids` reads it.
private struct BlockRecord: Equatable, CustomStringConvertible {
    let blockID: String
    let shownTakeID: String?
    let takes: [String]
    let labels: [String?]

    var description: String { "\(blockID) shows \(shownTakeID ?? "-") of \(takes) labelled \(labels)" }

    /// From the write's answer (`blocks`).
    static func answered(_ answer: [String: Any]) -> [BlockRecord]? {
        guard let blocks = answer["blocks"] as? [[String: Any]] else { return nil }
        return blocks.map { block in
            let takes = block["takes"] as? [[String: Any]] ?? []
            return BlockRecord(
                blockID: block["block_id"] as? String ?? "", shownTakeID: block["shown_take_id"] as? String,
                takes: takes.map { $0["take_id"] as? String ?? "" }, labels: takes.map { $0["label"] as? String })
        }
    }

    /// From `read_note with_ids` — the store, read back.
    static func read(_ read: [String: Any]) -> [BlockRecord] {
        (read["blocks"] as? [[String: Any]] ?? []).map { block in
            let takes = block["takes"] as? [[String: Any]] ?? []
            return BlockRecord(
                blockID: block["block_id"] as? String ?? "", shownTakeID: block["shown_take_id"] as? String,
                takes: takes.map { $0["take_id"] as? String ?? "" }, labels: takes.map { $0["label"] as? String })
        }
    }
}

@Suite("VX-252 — a write answers the ids it minted, and create_note files into a chapter", .serialized)
struct MCPMintedAnswerServerTests {
    private func liveNotes(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? -1
        }
    }

    private func filing(_ h: ServerHarness, note: String, book: String) async throws -> String? {
        try await h.database.read { db in
            try String.fetchOne(
                db, sql: "SELECT section_id FROM reading_post WHERE post_id = ? AND reading_id = ? AND deleted_at IS NULL",
                arguments: [note, book])
        }
    }

    // MARK: - create_note: every block's takes, in fan order

    @Test func createNoteAnswersEveryBlocksTakesInFanOrderWithTheShownOne() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))

            let created = try await call(connection, "create_note", [
                "book_id": .string(book.id), "title": .string("ch 1"),
                "blocks": .array([
                    .object([
                        "text": .string("Olá."),
                        "takes": .array([
                            .object(["text": .string("Hello."), "label": .string("english")]),
                            .object(["text": .string("")]),  // a blank take is a take (R-VX171-2)
                        ]),
                    ]),
                    .object(["text": .string("Adeus."), "name": .string("the end")]),
                ]),
            ])
            #expect(created.isError != true, "\(text(created))")
            let answer = try json(created)
            let noteID = try #require(answer["note_id"] as? String)
            let read = try json(try await call(connection, "read_note",
                                               ["note_id": .string(noteID), "with_ids": .bool(true)]))
            let stored = BlockRecord.read(read)
            #expect(stored.count == 2 && stored[0].takes.count == 3, "the store holds what was asked: \(stored)")
            #expect(BlockRecord.answered(answer) == stored,
                    "every block, its shown take and every take with its label, in fan order — no read needed")
            #expect(stored.first?.labels == [nil, "english", nil], "labels exactly as given at write new")
            #expect(answer["block_ids"] as? [String] == stored.map(\.blockID), "block_ids stays (F-6)")

            // The plain-prose payload answers the same shape: one take a block.
            let prose = try await call(connection, "create_note", [
                "book_id": .string(book.id), "title": .string("ch 2"), "text": .string("Um.\n\nDois."),
            ])
            #expect(prose.isError != true, "\(text(prose))")
            let proseAnswer = try json(prose)
            let proseID = try #require(proseAnswer["note_id"] as? String)
            let proseRead = try json(try await call(connection, "read_note",
                                                    ["note_id": .string(proseID), "with_ids": .bool(true)]))
            #expect(BlockRecord.answered(proseAnswer) == BlockRecord.read(proseRead))
            #expect(BlockRecord.read(proseRead).map(\.takes.count) == [1, 1])
            await h.hangUp(connection)
        }
    }

    // MARK: - import_document: one document closes the same way; a book answers its notes too (VX-567)

    @Test func importDocumentAnswersTheSameRecordsForOneDocumentAndABookAnswersItsNotesToo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "letters", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            // A document as the export writes it (its Alternates sections), so
            // the format's own spelling of an extra take is what the import reads.
            let source = try h.operations.createPost(title: "to K")
            let one = try h.operations.newBlock(in: source.id, text: "Dear K,", registeringUndo: false)
            let alternate = try h.operations.newBlankVariant(one.block.id)
            try h.operations.autosave(alternate.id, text: "Dearest K,", charDelta: 10)
            try h.operations.setTakeLabel(alternate.id, label: "warmer")
            _ = try h.operations.newBlock(in: source.id, text: "Yours.", registeringUndo: false)
            let document = try await h.database.read { try Queries.variorumDocumentText($0, postID: source.id) }
            let imported = try await call(connection, "import_document", [
                "document": .string(document), "book_id": .string(book.id),
            ])
            #expect(imported.isError != true, "\(text(imported))")
            let answer = try json(imported)
            let noteID = try #require(answer["note_id"] as? String)
            let read = try json(try await call(connection, "read_note",
                                               ["note_id": .string(noteID), "with_ids": .bool(true)]))
            let stored = BlockRecord.read(read)
            #expect(stored.map(\.takes.count) == [2, 1], "\(stored)")
            #expect(BlockRecord.answered(answer) == stored, "one document answers the same records")
            #expect(answer["block_ids"] as? [String] == stored.map(\.blockID))

            // F-2's guard, FLIPPED DELIBERATELY (VX-567 — the VX-620 run, batch 3,
            // PROVISIONAL RB-4; it supersedes P-VX252-1 / P-VX254-2's "ids only",
            // ratified 2026-10-15, on the ticket she seated in her run): a whole
            // book keeps book, notes and chapters AND answers each note's VX-252
            // record (`notes` — its truth pinned in `MCPBookImportRecordsServerTests`).
            // Was: the keys exactly `book_id`, `note_ids`, `chapter_ids`.
            let whole = try await call(connection, "import_document", [
                "wing_id": .string(""),
                "book": .object([
                    "name": .string("a whole book"),
                    "chapters": .array([.object(["name": .string("one"), "documents": .array([.string("Ch 1.")])])]),
                ]),
            ])
            #expect(whole.isError != true, "\(text(whole))")
            #expect(Set(try json(whole).keys) == ["book_id", "note_ids", "chapter_ids", "notes"])
            await h.hangUp(connection)
        }
    }

    // MARK: - section_id: filed in the same call, the same undo

    @Test func sectionIDFilesTheNewNoteUnderItsChapterInTheSameCallAndTheSameUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "um")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let depth = h.undoStack.depth

            let created = try await call(connection, "create_note", [
                "book_id": .string(book.id), "section_id": .string(chapter.id), "title": .string("ch 1"),
                "text": .string("Olá."),
            ])
            #expect(created.isError != true, "\(text(created))")
            let answer = try json(created)
            let noteID = try #require(answer["note_id"] as? String)
            #expect(try await filing(h, note: noteID, book: book.id) == chapter.id, "filed under the chapter")
            #expect(answer["section_id"] as? String == chapter.id, "the answer says where (add_note_to_book's echo)")
            #expect(h.undoStack.depth == depth + 1 && h.undoStack.topLabel == "claude-code's note",
                    "the filing rides the note's ONE undo")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's note")
            #expect(try await h.database.read { try Container.fetchOne($0, key: noteID) }?.deletedAt != nil)
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's note")
            #expect(try await filing(h, note: noteID, book: book.id) == chapter.id, "the redo returns it filed")
            await h.hangUp(connection)
        }
    }

    // MARK: - section_id: one sentence for every id that isn't this book's chapter

    @Test func everySectionIDThatIsntALiveChapterOfTheBookAnswersOneSentenceAndMintsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let gone = try h.operations.createSection(in: book.id, name: "deleted")
            try h.operations.deleteSection(gone.id)
            let readable = try h.operations.createReading(name: "another book", kind: .book)
            let readableChapter = try h.operations.createSection(in: readable.id, name: "theirs")
            let hidden = try h.operations.createReading(name: "never shared", kind: .book)
            let hiddenChapter = try h.operations.createSection(in: hidden.id, name: "hidden")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .book, readable.id))
            let notes = try await liveNotes(h)
            let depth = h.undoStack.depth

            var said: [String] = []
            for sectionID in ["no-such-chapter", gone.id, readableChapter.id, hiddenChapter.id] {
                let refused = try await call(connection, "create_note", [
                    "book_id": .string(book.id), "section_id": .string(sectionID), "text": .string("Olá."),
                ])
                #expect(refused.isError == true, "\(sectionID): \(text(refused))")
                said.append(text(refused))
            }
            #expect(Set(said) == ["section_id isn't a chapter of this book (list_notes or create_section gives chapter ids)."],
                    "one sentence for nothing, a deleted chapter, a readable book's and a hidden book's: \(said)")
            #expect(try await liveNotes(h) == notes && h.undoStack.depth == depth, "a refusal mints nothing")

            // section_id goes with book_id — refused at the parse, before any decision.
            let places: [[String: Value]] = [["wing_id": .string("")], [:]]
            for place in places {
                var arguments: [String: Value] = ["section_id": .string(readableChapter.id), "text": .string("Olá.")]
                arguments.merge(place) { _, given in given }
                let refused = try await call(connection, "create_note", arguments)
                #expect(refused.isError == true)
                #expect(text(refused)
                        == "section_id goes with book_id: it files the note under a chapter of the book the note joins.")
            }
            #expect(try await liveNotes(h) == notes)
            await h.hangUp(connection)
        }
    }

    // MARK: - THE GUARD: an unreachable book says the one sentence whatever section_id names

    /// Green on both sides by design: the book is decided first, so a chapter
    /// of a book the client can't reach never changes what it hears.
    @Test func anUnreachableBookAnswersTheOneNotSharedSentenceWithOrWithoutASection() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let shared = try h.operations.createReading(name: "shared", kind: .book)
            let hidden = try h.operations.createReading(name: "never shared", kind: .book)
            let hiddenChapter = try h.operations.createSection(in: hidden.id, name: "hidden")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, shared.id))
            let bare = try await call(connection, "create_note", ["book_id": .string(hidden.id), "text": .string("x")])
            let named = try await call(connection, "create_note", [
                "book_id": .string(hidden.id), "section_id": .string(hiddenChapter.id), "text": .string("x"),
            ])
            let nothing = try await call(connection, "create_note", [
                "book_id": .string("no-such-book"), "section_id": .string(hiddenChapter.id), "text": .string("x"),
            ])
            #expect(bare.isError == true && named.isError == true && nothing.isError == true)
            #expect(text(bare).hasPrefix("That book isn't shared with this client"))
            #expect(text(named) == text(bare) && text(nothing) == text(bare), "byte-identical")
            await h.hangUp(connection)
        }
    }
}
