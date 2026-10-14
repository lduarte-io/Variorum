import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-260 — HER EDIT MAKES AN AI'S COMMENT HERS (VX-184's ladder, round 1; her
// pick, "Your edit makes it yours" — the finding's option: "her edit of the
// comment clears the record"; the run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — "VX-260"). A
// suggest client deletes only a comment the authorship record names as its own;
// her comment edit never touched that record, so a suggest client could delete a
// comment she had rewritten (lesson 3: "Suggest … can't change a word you
// wrote"). Once she has edited it, deleting it needs EDIT, and a suggest caller
// hears her ruled R-VX188-2 sentence. Pre-fix API only — this compiles on the
// pre-fix tree, where it was watched RED.

@Suite("VX-260 — her edit makes an AI's comment hers, on the wire", .serialized)
struct MCPCommentHersServerTests {
    private func isLive(_ h: ServerHarness, _ commentID: String) async throws -> Bool {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block_comment WHERE id = ? AND deleted_at IS NULL",
                             arguments: [commentID]) == 1
        }
    }

    @Test func aSuggestClientCannotDeleteACommentSheEdited() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "Her opening.", registeringUndo: false).block.id
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .suggest, scopeKind: .note, scopeID: note.id, duration: .always))
            var ids: [String] = []
            for words in ["Check this date.", "A source?"] {
                let added = try await connection.client.callTool(name: "add_comment", arguments: [
                    "block_id": .string(block), "text": .string(words),
                ])
                ids.append(try #require(try json(added)["comment_id"] as? String))
            }

            // She rewrites the first in her Comments panel.
            try h.operations.editBlockComment(ids[0], text: "Check this date — it's 1971, I looked.")
            let refused = try await connection.client.callTool(name: "delete_comment", arguments: [
                "comment_id": .string(ids[0]),
            ])
            #expect(refused.isError == true && text(refused) == MCPWriteTools.notYourCommentWords,
                    "her edit made it hers: \(text(refused))")
            #expect(try await isLive(h, ids[0]), "her words stand")

            // The one she never touched is still the client's own.
            let deleted = try await connection.client.callTool(name: "delete_comment", arguments: [
                "comment_id": .string(ids[1]),
            ])
            #expect(deleted.isError != true, "its own, untouched: \(text(deleted))")
            #expect(try await isLive(h, ids[1]) == false)
            await h.hangUp(connection)
        }
    }
}
