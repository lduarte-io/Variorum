import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U4 — VX-195, THE NOTE at EDIT (R-VX184-1): `rename_note` — her title
// doors (trimmed, a blank or null title clears; a title is library metadata,
// so a seal does not freeze it) — and `delete_lens` — her `deleteLens` (the
// lens and its picks go; what the note shows is untouched). ONE client-named
// undo entry each. Written BEFORE the fix: on the pre-fix tree both tools
// answer "Unknown tool".

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

@Suite("VX-195 — the note at edit: its title and its saved lenses", .serialized)
struct MCPNoteEditServerTests {
    private struct World {
        let book: Reading
        let note: Container
        let block: String
        let other: String
        let lensID: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let one = try h.operations.newBlock(in: note.id, text: "Her opening.", registeringUndo: false)
        let other = try h.operations.branchVariant(one.block.id, from: one.variant.id)
        try h.operations.autosave(other.id, text: "A bolder opening.", charDelta: 4)
        let lens = try h.operations.createLens(post: note.id, name: "the bold cut")
        _ = try h.operations.setLensChoice(lens: lens.id, block: one.block.id, variant: other.id)
        return World(book: book, note: note, block: one.block.id, other: other.id, lensID: lens.id)
    }

    private func title(_ h: ServerHarness, _ noteID: String) async throws -> String? {
        try await h.database.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = ?", arguments: [noteID])
        }
    }

    private func liveLensRows(_ h: ServerHarness, _ lensID: String) async throws -> (lens: Bool, choices: Int) {
        try await h.database.read { db in
            (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM lens WHERE id = ? AND deleted_at IS NULL",
                              arguments: [lensID]) == 1,
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM lens_choice WHERE lens_id = ? AND deleted_at IS NULL",
                              arguments: [lensID]) ?? 0)
        }
    }

    // MARK: - rename_note

    @Test func renameNoteIsHerTitleDoorAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let renamed = try await call(connection, "rename_note", [
                "note_id": .string(w.note.id), "title": .string("  Chapter one: the door  "),
            ])
            #expect(renamed.isError != true, "\(text(renamed))")
            #expect(try json(renamed)["title"] as? String == "Chapter one: the door")
            #expect(try await title(h, w.note.id) == "Chapter one: the door", "trimmed, as her title field does")
            #expect(h.undoStack.topLabel == "claude-code's note title")
            #expect(h.receipts.value.last?.act.rawValue == "note title")
            let same = try json(try await call(connection, "rename_note", [
                "note_id": .string(w.note.id), "title": .string("Chapter one: the door"),
            ]))
            #expect(same["changed"] as? Bool == false && h.undoStack.depth == 1)

            // A title is library metadata: a seal does not freeze it (her op's posture).
            try h.operations.lockPost(w.note.id)
            let cleared = try json(try await call(connection, "rename_note", [
                "note_id": .string(w.note.id), "title": .string("   "),
            ]))
            #expect(cleared["changed"] as? Bool == true && cleared["title"] is NSNull, "blank clears")
            #expect(try await title(h, w.note.id) == nil)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's note title")
            #expect(try await title(h, w.note.id) == "Chapter one: the door")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's note title")
            #expect(try await title(h, w.note.id) == "ch 1", "her title, back")
            await h.hangUp(connection)
        }
    }

    // MARK: - delete_lens

    @Test func deleteLensTakesTheLensAndItsPicksAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            let shown = try await h.database.read { try Queries.renderedText($0, containerID: w.note.id) }

            try h.operations.lockPost(w.note.id)  // lens CRUD is allowed under a seal (her posture)
            let deleted = try await call(connection, "delete_lens", ["lens_id": .string(w.lensID)])
            #expect(deleted.isError != true, "\(text(deleted))")
            #expect(try json(deleted)["note_id"] as? String == w.note.id)
            #expect(try await liveLensRows(h, w.lensID) == (false, 0))
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: w.note.id) } == shown,
                    "deleting a way of looking never touches what is looked at")
            #expect(h.undoStack.topLabel == "claude-code's lens deletion")
            #expect(h.receipts.value.last?.act.rawValue == "lens deletion"
                    && h.receipts.value.last?.detail == "the bold cut")

            let again = try await call(connection, "delete_lens", ["lens_id": .string(w.lensID)])
            #expect(again.isError == true && text(again) == MCPRefusalCopy.words(.notShared, .note),
                    "a deleted lens lives nowhere — the one answer")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's lens deletion")
            #expect(try await liveLensRows(h, w.lensID) == (true, 1), "the lens and its pick, back")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's lens deletion")
            #expect(try await liveLensRows(h, w.lensID) == (false, 0))
            await h.hangUp(connection)
        }
    }

    // MARK: - The rung and the one answer

    @Test func belowEditTheRungRefusesAndOutsideTheGrantIsTheOneAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let outside = try h.operations.createPost(title: "not shared")
            let theirLens = try h.operations.createLens(post: outside.id, name: "theirs")
            let version = try h.operations.saveNoteVersion(w.note.id)

            let maker = try await h.connect(as: "maker")
            _ = try h.approve("maker", spec(.writeNew, .book, w.book.id))
            for (tool, arguments): (String, [String: Value]) in [
                ("rename_note", ["note_id": .string(w.note.id), "title": .string("x")]),
                ("delete_lens", ["lens_id": .string(w.lensID)]),
            ] {
                let refused = try await call(maker, tool, arguments)
                #expect(refused.isError == true
                        && text(refused).hasPrefix("This client may only read, suggest and write new here."),
                        "\(tool): \(text(refused))")
            }
            #expect(h.asks.value.last?.clientName == "maker" && h.asks.value.last?.rung == .edit)
            await h.hangUp(maker)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            let unshared = MCPRefusalCopy.words(.notShared, .note)
            for (tool, arguments): (String, [String: Value]) in [
                ("rename_note", ["note_id": .string(outside.id), "title": .string("x")]),
                ("rename_note", ["note_id": .string(version.post.id), "title": .string("x")]),
                ("rename_note", ["note_id": .string("no-such-note"), "title": .string("x")]),
                ("delete_lens", ["lens_id": .string(theirLens.id)]),
                ("delete_lens", ["lens_id": .string("no-such-lens")]),
            ] {
                let refused = try await call(connection, tool, arguments)
                #expect(refused.isError == true && text(refused) == unshared, "\(tool) \(arguments): \(text(refused))")
            }
            #expect(try await title(h, outside.id) == "not shared")
            #expect(try await liveLensRows(h, theirLens.id).lens)
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }
}
