import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U5 — VX-196, THE NOTE IN THE LIBRARY at EDIT (R-VX184-1, her picks):
// `delete_note` (her Trash road — `deleteContainer`: the note and its saved
// versions on one stamp, 30 days, restorable) and `archive_note` /
// `unarchive_note` (her `archiveContainer` / `unarchiveContainer`, no-op-guarded
// — an archived note is never re-stamped). ONE client-named undo entry each.
// Written BEFORE the fix: on the pre-fix tree every tool answers "Unknown tool".

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

@Suite("VX-196 — the note in the library at edit: delete, archive", .serialized)
struct MCPNoteLibraryServerTests {
    private func note(_ h: ServerHarness, _ id: String) throws -> Container {
        try #require(try h.database.read { try Container.fetchOne($0, key: id) })
    }

    @Test func deleteNoteIsHerTrashRoadAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let target = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(target.id, to: book.id)
            _ = try h.operations.newBlock(in: target.id, text: "Her words.", registeringUndo: false)
            let version = try h.operations.saveNoteVersion(target.id).post
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))

            // A sealed note may still be deleted (§9 — the post itself may be
            // archived, deleted, retitled…).
            try h.operations.lockPost(target.id)
            let deleted = try await call(connection, "delete_note", ["note_id": .string(target.id)])
            #expect(deleted.isError != true, "\(text(deleted))")
            #expect(try json(deleted)["deleted"] as? Bool == true)
            let stamp = try #require(try note(h, target.id).deletedAt)
            #expect(try note(h, version.id).deletedAt == stamp, "its saved versions ride, on one stamp")
            #expect(try await h.database.read { try Queries.noteMemberships($0, postID: target.id) }.isEmpty)
            #expect(h.undoStack.topLabel == "claude-code's note deletion")
            #expect(h.receipts.value.last?.act.rawValue == "note deletion")
            let gone = try await call(connection, "delete_note", ["note_id": .string(target.id)])
            #expect(gone.isError == true && text(gone) == MCPRefusalCopy.words(.notShared, .note),
                    "a deleted note lives nowhere the wire reaches — the one answer")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's note deletion")
            #expect(try note(h, target.id).deletedAt == nil && note(h, version.id).deletedAt == nil)
            #expect(try await h.database.read { try Queries.noteMemberships($0, postID: target.id) }.map(\.book.id) == [book.id],
                    "back in its book, whole")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: target.id) } == "Her words.")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's note deletion")
            #expect(try note(h, target.id).deletedAt != nil)

            // Put back from the Trash first: the undo then has nothing to do.
            try h.operations.restoreContainer(target.id)
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's note deletion")
            #expect(try note(h, target.id).deletedAt == nil, "quiet — the world moved past the entry")
            await h.hangUp(connection)
        }
    }

    @Test func archiveAndUnarchiveANoteAreHerDoorsNoOpGuarded() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let target = try h.operations.createPost(title: "ch 1")
            let owned = try h.operations.createReading(name: "the novel", kind: .book)
            let member = try h.operations.createPost(title: "its own")
            _ = try h.operations.addPostToReading(member.id, to: owned.id)
            _ = try h.operations.setReadingOwned(owned.id, owned: true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let archived = try await call(connection, "archive_note", ["note_id": .string(target.id)])
            #expect(archived.isError != true, "\(text(archived))")
            #expect(try json(archived)["archived"] as? Bool == true && json(archived)["changed"] as? Bool == true)
            let stamp = try #require(try note(h, target.id).archivedAt)
            #expect(h.undoStack.topLabel == "claude-code's note archiving")
            let twice = try json(try await call(connection, "archive_note", ["note_id": .string(target.id)]))
            #expect(twice["changed"] as? Bool == false && h.undoStack.depth == 1)
            #expect(try note(h, target.id).archivedAt == stamp, "never re-stamped")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's note archiving")
            #expect(try note(h, target.id).archivedAt == nil)
            let live = try json(try await call(connection, "unarchive_note", ["note_id": .string(target.id)]))
            #expect(live["changed"] as? Bool == false)

            // A note archived WITH its owned book (her door): the client's
            // unarchive brings it back alone; the undo restores HER stamp, so
            // her book's unarchive still returns it.
            _ = try h.operations.archiveReadingWithNotes(owned.id)
            let herStamp = try #require(try note(h, member.id).archivedAt)
            let unarchived = try await call(connection, "unarchive_note", ["note_id": .string(member.id)])
            #expect(unarchived.isError != true, "\(text(unarchived))")
            #expect(try note(h, member.id).archivedAt == nil)
            #expect(h.undoStack.topLabel == "claude-code's note unarchiving")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's note unarchiving")
            #expect(try note(h, member.id).archivedAt == herStamp, "her own stamp, exactly")
            _ = try h.operations.unarchiveReading(owned.id)
            #expect(try note(h, member.id).archivedAt == nil, "her book's unarchive still returns it")
            await h.hangUp(connection)
        }
    }

    @Test func belowEditTheRungRefusesAndOutsideTheGrantIsTheOneAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let target = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(target.id, to: book.id)
            let outside = try h.operations.createPost(title: "not shared")
            let privateNote = try h.operations.createPost(title: "not for anyone")
            _ = try h.operations.addPostToReading(privateNote.id, to: book.id)
            _ = try h.operations.setNotePrivate(privateNote.id, true)
            // (A version needs a note with something in it — fixture fix at
            // piece 5: the pin's first draft saved one of an empty note.)
            _ = try h.operations.newBlock(in: target.id, text: "Her words.", registeringUndo: false)
            let version = try h.operations.saveNoteVersion(target.id).post

            let maker = try await h.connect(as: "maker")
            _ = try h.approve("maker", spec(.writeNew, .book, book.id))
            for tool in ["delete_note", "archive_note", "unarchive_note"] {
                let refused = try await call(maker, tool, ["note_id": .string(target.id)])
                #expect(refused.isError == true
                        && text(refused).hasPrefix("This client may only read, suggest and write new here."),
                        "\(tool): \(text(refused))")
            }
            #expect(h.asks.value.last?.clientName == "maker" && h.asks.value.last?.rung == .edit)
            await h.hangUp(maker)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let unshared = MCPRefusalCopy.words(.notShared, .note)
            for tool in ["delete_note", "archive_note", "unarchive_note"] {
                for id in [outside.id, privateNote.id, version.id, "no-such-note"] {
                    let refused = try await call(connection, tool, ["note_id": .string(id)])
                    #expect(refused.isError == true && text(refused) == unshared, "\(tool) \(id): \(text(refused))")
                }
            }
            for id in [outside.id, privateNote.id, target.id] {
                #expect(try note(h, id).deletedAt == nil && note(h, id).archivedAt == nil)
            }
            #expect(try note(h, privateNote.id).locked == false, "Private, Seal and Own are hers")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }
}
