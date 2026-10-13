import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U5 — VX-196, A BOOK's CHAPTERS at EDIT (R-VX184-1, her picks):
// `rename_chapter` (her `renameSection` — free on a finished book),
// `delete_chapter` (her `deleteSection` — the notes keep their pointer, read
// unfiled) and `move_chapter` (her `reorderSection`), each decided on the
// chapter's BOOK at edit, ONE client-named undo entry each — and
// `list_notes(book_id:)` carries the book's chapters, so a chapter with no notes
// filed is addressable too. Written BEFORE the fix: on the pre-fix tree every
// tool answers "Unknown tool" and list_notes carries no chapters.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("VX-196 — a book's chapters at edit", .serialized)
struct MCPChapterEditServerTests {
    private func chapters(_ h: ServerHarness, _ bookID: String) throws -> [String] {
        try h.database.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT name FROM reading_section WHERE reading_id = ? AND deleted_at IS NULL
                    ORDER BY position, id
                    """,
                arguments: [bookID])
        }
    }

    @Test func listNotesCarriesTheBooksChaptersInOrderEvenEmptyOnes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let one = try h.operations.createSection(in: book.id, name: "one")
            let two = try h.operations.createSection(in: book.id, name: "two")
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            try h.operations.assignPostToSection(note.id, in: book.id, section: two.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, book.id))
            let listed = try json(try await call(connection, "list_notes", ["book_id": .string(book.id)]))
            let carried = try #require(listed["chapters"] as? [[String: Any]], "\(listed)")
            #expect(carried.map { $0["section_id"] as? String } == [one.id, two.id])
            #expect(carried.map { $0["name"] as? String } == ["one", "two"], "the empty chapter is listed too")
            await h.hangUp(connection)
        }
    }

    @Test func renameDeleteAndMoveAChapterAreHerDoorsEachOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let one = try h.operations.createSection(in: book.id, name: "one")
            let two = try h.operations.createSection(in: book.id, name: "two")
            let three = try h.operations.createSection(in: book.id, name: "three")
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            try h.operations.assignPostToSection(note.id, in: book.id, section: one.id)
            let other = try h.operations.createReading(name: "letters", kind: .book)
            let foreign = try h.operations.createSection(in: other.id, name: "elsewhere")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            // rename_chapter — her renameSection: trimmed; the same name writes nothing.
            let renamed = try await call(connection, "rename_chapter", [
                "section_id": .string(two.id), "name": .string("  two, revised  "),
            ])
            #expect(renamed.isError != true, "\(text(renamed))")
            #expect(try json(renamed)["name"] as? String == "two, revised")
            #expect(try chapters(h, book.id) == ["one", "two, revised", "three"])
            #expect(h.undoStack.topLabel == "claude-code's chapter name")
            #expect(h.receipts.value.last?.act.rawValue == "chapter name")
            let same = try json(try await call(connection, "rename_chapter", [
                "section_id": .string(two.id), "name": .string("two, revised"),
            ]))
            #expect(same["changed"] as? Bool == false && h.undoStack.depth == 1)
            let blank = try await call(connection, "rename_chapter", ["section_id": .string(two.id), "name": .string(" ")])
            #expect(blank.isError == true)

            // move_chapter — her reorderSection, one road at a time.
            let moved = try await call(connection, "move_chapter", [
                "section_id": .string(three.id), "before_section_id": .string(one.id),
            ])
            #expect(moved.isError != true, "\(text(moved))")
            #expect(try chapters(h, book.id) == ["three", "one", "two, revised"])
            #expect(h.undoStack.topLabel == "claude-code's chapter move")
            _ = try await call(connection, "move_chapter", ["section_id": .string(three.id), "at": .string("end")])
            #expect(try chapters(h, book.id) == ["one", "two, revised", "three"])
            let elsewhere = try await call(connection, "move_chapter", [
                "section_id": .string(one.id), "after_section_id": .string(foreign.id),
            ])
            #expect(elsewhere.isError == true, "an anchor of another book: \(text(elsewhere))")

            // delete_chapter — her deleteSection: the note keeps its pointer
            // (it reads unfiled), and the chapter comes back with it.
            let deleted = try await call(connection, "delete_chapter", ["section_id": .string(one.id)])
            #expect(deleted.isError != true, "\(text(deleted))")
            #expect(try chapters(h, book.id) == ["two, revised", "three"])
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT section_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                                    arguments: [note.id])
            } == one.id, "the membership's pointer is never rewritten")
            #expect(h.undoStack.topLabel == "claude-code's chapter deletion")
            let listed = try json(try await call(connection, "list_notes", ["book_id": .string(book.id)]))
            #expect(((listed["notes"] as? [[String: Any]])?.first?["section_id"]) == nil, "the note reads unfiled")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's chapter deletion")
            #expect(try chapters(h, book.id) == ["one", "two, revised", "three"])
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's chapter move")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's chapter move")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's chapter name")
            #expect(try chapters(h, book.id) == ["one", "two", "three"], "her chapters, exactly")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's chapter name")
            #expect(try chapters(h, book.id) == ["one", "two, revised", "three"])

            // A finished book: a chapter's NAME stays free; its structure is frozen.
            try h.operations.lockReading(book.id)
            let finishedRename = try await call(connection, "rename_chapter", [
                "section_id": .string(three.id), "name": .string("coda"),
            ])
            #expect(finishedRename.isError != true, "\(text(finishedRename))")
            for (tool, arguments): (String, [String: Value]) in [
                ("delete_chapter", ["section_id": .string(three.id)]),
                ("move_chapter", ["section_id": .string(three.id), "at": .string("start")]),
            ] {
                let refused = try await call(connection, tool, arguments)
                #expect(refused.isError == true && text(refused).contains("lockedReading"), "\(tool): \(text(refused))")
            }
            #expect(try chapters(h, book.id) == ["one", "two, revised", "coda"])
            await h.hangUp(connection)
        }
    }

    @Test func belowEditTheRungRefusesAndOutsideTheGrantIsTheOneAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "one")
            let outside = try h.operations.createReading(name: "not shared", kind: .book)
            let theirs = try h.operations.createSection(in: outside.id, name: "theirs")

            let maker = try await h.connect(as: "maker")
            _ = try h.approve("maker", spec(.writeNew, .book, book.id))
            for (tool, arguments): (String, [String: Value]) in [
                ("rename_chapter", ["section_id": .string(chapter.id), "name": .string("x")]),
                ("delete_chapter", ["section_id": .string(chapter.id)]),
                ("move_chapter", ["section_id": .string(chapter.id), "at": .string("end")]),
            ] {
                let refused = try await call(maker, tool, arguments)
                #expect(refused.isError == true
                        && text(refused).hasPrefix("This client may only read, suggest and write new here."),
                        "\(tool): \(text(refused))")
            }
            #expect(h.asks.value.last?.rung == .edit && h.asks.value.last?.scopeKind == .book)
            await h.hangUp(maker)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let unshared = MCPRefusalCopy.words(.notShared, .book)
            for (tool, arguments): (String, [String: Value]) in [
                ("rename_chapter", ["section_id": .string(theirs.id), "name": .string("x")]),
                ("delete_chapter", ["section_id": .string(theirs.id)]),
                ("move_chapter", ["section_id": .string("no-such-chapter"), "at": .string("end")]),
            ] {
                let refused = try await call(connection, tool, arguments)
                #expect(refused.isError == true && text(refused) == unshared, "\(tool): \(text(refused))")
            }
            #expect(try chapters(h, outside.id) == ["theirs"] && chapters(h, book.id) == ["one"])
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }
}
