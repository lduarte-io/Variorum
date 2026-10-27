import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-252 (VX-336 U5b — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U5b D1–D2): the core half of "a write says the ids it minted", as exact state
// transitions — `DocumentImport.blocks` is what the mint wrote, row for row, and
// `createNote` / `createStructuredNote`'s `section` files the membership under a
// chapter of THAT book in the same transaction, refusing anything else before a
// row is minted. (The wire pins are `MCPMintedAnswerServerTests`.) New API, so
// green by construction: state transitions, the house's rule for a pure addition.

@Suite("VX-252 — the minted record and the chapter filing (core)")
struct MCPMintedBlocksActsTests {
    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    @Test func theMintedRecordIsEveryTakeTheMintWroteInFanOrder() throws {
        try withUndo { ops, _, db in
            let book = try ops.createReading(name: "o ladrão de raios", kind: .book)
            let minted = try ops.createStructuredNote(
                title: "ch 1", entryDate: nil,
                blocks: [
                    .init(text: "Olá.", takes: [.init(label: "english", text: "Hello."), .init(label: nil, text: "")]),
                    .init(text: "Adeus."),
                ],
                in: .book(book.id), undoLabel: "claude-code's note")
            #expect(minted.blocks.map(\.blockID) == minted.blockIDs)
            for record in minted.blocks {
                let fan = try db.read { db in
                    try Row.fetchAll(
                        db, sql: """
                            SELECT id, label FROM variant WHERE block_id = ? AND deleted_at IS NULL
                            ORDER BY fan_position, id
                            """, arguments: [record.blockID])
                }
                #expect(record.takes.map(\.id) == fan.map { $0["id"] as String }, "every take, in fan order")
                #expect(record.takes.map(\.label) == fan.map { $0["label"] as String? })
                let chosen = try db.fetchString(
                    "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    [record.blockID])
                #expect(record.shownTakeID == chosen && record.shownTakeID == record.takes.first?.id,
                        "the shown take is the in-place text — chosen, first in the fan")
            }
            #expect(minted.blocks.map(\.takes.count) == [3, 1], "a blank take is a take (R-VX171-2)")
        }
    }

    @Test func aSectionFilesTheMembershipAndTheUndoAndRedoCarryIt() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "o ladrão de raios", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "um")
            let minted = try ops.createNote(
                title: "ch 1", text: "Olá.", in: .book(book.id), section: chapter.id, undoLabel: "claude-code's note")
            let filed = "SELECT section_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL"
            #expect(try db.fetchString(filed, [minted.post.id]) == chapter.id)
            #expect(stack.depth == 1)
            #expect(try stack.undo(with: ops) == "claude-code's note")
            #expect(try db.deletedAt("container", minted.post.id) != nil)
            #expect(try stack.redo(with: ops) == "claude-code's note")
            #expect(try db.fetchString(filed, [minted.post.id]) == chapter.id, "the redo returns it filed")
        }
    }

    @Test func aSectionThatIsntALiveChapterOfThatBookRefusesBeforeAnythingIsMinted() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "o ladrão de raios", kind: .book)
            let other = try ops.createReading(name: "another", kind: .book)
            let theirs = try ops.createSection(in: other.id, name: "theirs")
            let gone = try ops.createSection(in: book.id, name: "gone")
            try ops.deleteSection(gone.id)
            let notes = "SELECT COUNT(*) FROM container WHERE kind = 'post'"
            let before = try db.fetchInt(notes)
            #expect(throws: OperationError.sectionNotInReading(sectionID: theirs.id, readingID: book.id)) {
                try ops.createNote(title: nil, text: "x", in: .book(book.id), section: theirs.id, undoLabel: "u")
            }
            #expect(throws: OperationError.sectionNotFound(id: gone.id)) {
                try ops.createStructuredNote(
                    title: nil, entryDate: nil, blocks: [.init(text: "x")], in: .book(book.id), section: gone.id,
                    undoLabel: "u")
            }
            #expect(throws: OperationError.sectionNotFound(id: theirs.id), "a wing holds no chapter") {
                try ops.createNote(title: nil, text: "x", in: .wing(""), section: theirs.id, undoLabel: "u")
            }
            #expect(try db.fetchInt(notes) == before && stack.depth == 0, "nothing minted, no entry")
        }
    }

    // MARK: - VX-566 / VX-567 (the VX-620 run, batch 3): the import doors' halves

    /// VX-566: `importNote`'s `section` is `createNote`'s — filed in the same
    /// transaction, the undo and redo carrying it; anything that isn't a live
    /// chapter of THAT book refuses before a row is minted. New API: green by
    /// construction (the wire pins `MCPImportSectionServerTests` ran red on old).
    @Test func anImportedDocumentFilesUnderItsChapterAsCreateNoteDoes() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "o ladrão de raios", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "um")
            let other = try ops.createReading(name: "another", kind: .book)
            let theirs = try ops.createSection(in: other.id, name: "theirs")
            let named = VariorumDocument.NamedDocument(
                fallbackTitle: "", document: try VariorumDocument.parse("{t:\"capítulo\"}\n\nOlá."))
            let notes = "SELECT COUNT(*) FROM container WHERE kind = 'post'"
            let before = try db.fetchInt(notes)
            #expect(throws: OperationError.sectionNotInReading(sectionID: theirs.id, readingID: book.id)) {
                try ops.importNote(named, in: .book(book.id), section: theirs.id, undoLabel: "u")
            }
            #expect(throws: OperationError.sectionNotFound(id: chapter.id), "a wing holds no chapter") {
                try ops.importNote(named, in: .wing(""), section: chapter.id, undoLabel: "u")
            }
            #expect(try db.fetchInt(notes) == before && stack.depth == 0, "nothing minted, no entry")

            let minted = try ops.importNote(named, in: .book(book.id), section: chapter.id, undoLabel: "claude-code's import")
            let filed = "SELECT section_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL"
            #expect(try db.fetchString(filed, [minted.post.id]) == chapter.id)
            #expect(try stack.undo(with: ops) == "claude-code's import")
            #expect(try stack.redo(with: ops) == "claude-code's import")
            #expect(try db.fetchString(filed, [minted.post.id]) == chapter.id, "the redo returns it filed")
        }
    }

    /// VX-567: `BookImport.notes` is what each seat minted — parallel to
    /// `postIDs`, each note's blocks in note order, each block's takes the fan
    /// rows in fan order (the in-place text first, shown) — never a second read.
    @Test func aBookImportsNotesAreWhatEachSeatMinted() throws {
        try withUndo { ops, _, db in
            let one = try VariorumDocument.parse("{t:\"um\"}\n\nOlá.\n\nAdeus.")
            let two = try VariorumDocument.parse("{t:\"dois\"}\n\nCapítulo dois.")
            let result = try ops.importBook(
                VariorumDocument.Book(
                    name: "o ladrão de raios",
                    chapters: [.init(name: "um", notes: [.init(fallbackTitle: "", document: one)])],
                    unfiled: [.init(fallbackTitle: "", document: two)]),
                wingId: "", undoLabel: "claude-code's book import")
            #expect(result.notes.map(\.postID) == result.postIDs, "one record per note, in book order")
            for note in result.notes {
                let placed = try db.read { db in
                    try String.fetchAll(
                        db, sql: """
                            SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL
                            ORDER BY position, id
                            """, arguments: [note.postID])
                }
                #expect(note.blockIDs == placed && note.blocks.map(\.blockID) == placed, "the note's blocks, in order")
                for record in note.blocks {
                    let fan = try db.read { db in
                        try Row.fetchAll(
                            db, sql: """
                                SELECT id, working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL
                                ORDER BY fan_position, id
                                """, arguments: [record.blockID])
                    }
                    #expect(record.takes.map(\.id) == fan.map { $0["id"] as String })
                    #expect(record.takes.map(\.text) == fan.map { $0["working_text"] as String }, "the stored text")
                    #expect(record.shownTakeID == record.takes.first?.id)
                }
            }
            #expect(result.notes.map { $0.blocks.count } == [2, 1])
        }
    }
}
