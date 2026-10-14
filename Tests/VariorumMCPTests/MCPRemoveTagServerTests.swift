import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U3 — VX-190: `remove_tag` at EDIT. §9's `removeTag` under the grant
// guard inside its transaction, ONE client-named undo entry; un-tagging stays
// a NON-EVENT for intake (OverallModel §2 — intake fires on the APPLYING act
// only, §19: removing a tag never evicts). Written to compile on the pre-fix
// tree, where the call answers "Unknown tool".

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

@Suite("VX-190 — remove_tag at edit", .serialized)
struct MCPRemoveTagServerTests {
    private func liveApplications(_ h: ServerHarness, _ noteID: String) async throws -> [String] {
        try await h.database.read { db in
            try String.fetchAll(db, sql: """
                SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL ORDER BY t.path
                """, arguments: [noteID])
        }
    }

    @Test func removeTagTakesTheApplicationAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            _ = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            let ptEn = try h.operations.createTag(name: "percy")
            let child = try h.operations.createTag(parent: ptEn.id, name: "pt-en")
            _ = try h.operations.applyTag(child.id, toPost: note.id)
            let other = try h.operations.createTag(name: "kept")
            _ = try h.operations.applyTag(other.id, toPost: note.id)
            let applicationID = try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM post_tag WHERE tag_id = ? AND post_id = ?",
                                    arguments: [child.id, note.id])
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))

            let removed = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string("#percy/pt-en")])
            #expect(removed.isError != true, "\(text(removed))")
            let answer = try json(removed)
            #expect(answer["tag"] as? String == "percy/pt-en" && answer["note_id"] as? String == note.id)
            #expect(try await liveApplications(h, note.id) == ["kept"], "only that tag left the note")
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM tag WHERE id = ? AND deleted_at IS NULL", arguments: [child.id])
            } == 1, "the tag stays as vocabulary — only the application goes")
            #expect(!text(try await call(connection, "read_note", ["note_id": .string(note.id)])).contains("#percy/pt-en"))
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's tag removal")
            #expect(h.receipts.value.last?.act.rawValue == "tag removal")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's tag removal")
            #expect(try await liveApplications(h, note.id) == ["kept", "percy/pt-en"])
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM post_tag WHERE post_id = ? AND tag_id = ? AND deleted_at IS NULL",
                                    arguments: [note.id, child.id])
            } == applicationID, "the very application row comes back")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's tag removal")
            #expect(try await liveApplications(h, note.id) == ["kept"])
            await h.hangUp(connection)
        }
    }

    /// UN-TAGGING IS A NON-EVENT FOR INTAKE: a living book the tag seated the
    /// note into keeps it; no arrival row moves — neither on the removal nor
    /// on its undo (an exact-row revival is no applying act).
    @Test func untaggingStaysANonEventForIntake() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let travel = try h.operations.createTag(name: "travel")
            let living = try h.operations.createReading(
                name: "travel book", kind: .book, querySpec: try RuleGrammar.encode(.tag(travel.id)))
            let home = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "lisbon")
            _ = try h.operations.addPostToReading(note.id, to: home.id)
            _ = try h.operations.applyTag(travel.id, toPost: note.id)  // the applying act: intake seats it
            func memberships() async throws -> [String] {
                try await h.database.read { db in
                    try Row.fetchAll(db, sql: """
                        SELECT reading_id, status, deleted_at FROM reading_post WHERE post_id = ? ORDER BY reading_id
                        """, arguments: [note.id]).map(\.description)
                }
            }
            let seated = try await memberships()
            #expect(seated.contains { $0.contains(living.id) && $0.contains("member") }, "the tag seated it: \(seated)")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let removed = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string("travel")])
            #expect(removed.isError != true, "\(text(removed))")
            #expect(try await liveApplications(h, note.id) == [])
            #expect(try await memberships() == seated, "removing a tag never evicts and bells nothing")
            _ = try h.undoStack.undo(with: h.writeOperations)
            #expect(try await liveApplications(h, note.id) == ["travel"])
            #expect(try await memberships() == seated, "and its undo is no applying act")
            await h.hangUp(connection)
        }
    }

    /// A tag the note does not wear — a path naming nothing, or a tag of the
    /// library the note was never given — refuses in plain words, the same
    /// for both; nothing changes, nothing registers.
    @Test func aTagTheNoteDoesNotWearRefuses() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            _ = try h.operations.createTag(name: "unused")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))

            let unworn = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string("unused")])
            let nothing = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string("no/such/tag")])
            #expect(unworn.isError == true && text(unworn).hasPrefix("That note doesn't wear the tag"), "\(text(unworn))")
            #expect(nothing.isError == true && text(nothing).hasPrefix("That note doesn't wear the tag"), "\(text(nothing))")
            let blank = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string(" / ")])
            #expect(blank.isError == true)
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }

    /// EDIT on the note: write new hears the rung (and raises the ask for
    /// edit); an unshared note answers the one shape.
    @Test func removeTagNeedsEditOnTheNote() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let tag = try h.operations.createTag(name: "draft")
            _ = try h.operations.applyTag(tag.id, toPost: note.id)
            let outside = try h.operations.createPost(title: "not shared")
            _ = try h.operations.applyTag(tag.id, toPost: outside.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            #expect(!(try await connection.client.listTools().tools.map(\.name)).contains("remove_tag"),
                    "not offered below edit")

            let tooLow = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string("draft")])
            #expect(tooLow.isError == true
                    && text(tooLow).hasPrefix("This client may only read, suggest and write new here."), "\(text(tooLow))")
            #expect(h.asks.value.last?.rung == .edit && h.asks.value.last?.scopeID == note.id)
            let unshared = try await call(connection, "remove_tag", ["note_id": .string(outside.id), "tag": .string("draft")])
            #expect(unshared.isError == true && text(unshared).hasPrefix("That note isn't shared with this client"))
            let kept = try await liveApplications(h, note.id)
            let keptOutside = try await liveApplications(h, outside.id)
            #expect(kept == ["draft"] && keptOutside == ["draft"], "nothing untagged")
            await h.hangUp(connection)
        }
    }
}
