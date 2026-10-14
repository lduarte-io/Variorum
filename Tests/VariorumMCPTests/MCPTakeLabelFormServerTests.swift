import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-267 (VX-336 U5a — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`):
// AN AI TAKE'S LABEL DROPS "suggested". Her ruling, verbatim: "why do we need
// claude-code * suggested * english. isn't it obvious it's suggested if it's
// claude? seems like an extra word." Since her label split (VX-197) the client
// prefix appears only on takes a client adds at SUGGEST, inside her writing, so
// the name already says it was proposed: `<client>`, or `<client> · <label>`.
// Pinned on the wire (the two tools that prefix — `add_take`, `add_takes`), with
// the split's other half as a control: what a client writes at WRITE NEW keeps
// its label exactly as given.

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

@Suite("VX-267 — an AI take's label is <client> or <client> · <label>", .serialized)
struct MCPTakeLabelFormServerTests {
    private func label(_ h: ServerHarness, _ takeID: String) async throws -> String? {
        try await h.database.read { db in
            try String.fetchOne(db, sql: "SELECT label FROM variant WHERE id = ?", arguments: [takeID])
        }
    }

    @Test func aSuggestedTakeIsLabelledWithTheClientAloneOrTheClientAndItsLabel() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let one = try h.operations.newBlock(in: note.id, text: "Eu não pedi para herdar o observatório.", registeringUndo: false)
            let two = try h.operations.newBlock(in: note.id, text: "Cuidar de um observatório dá trabalho.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            // Write new on the book reaches the suggest doors too (the rungs are cumulative).
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))

            // add_take: with a label, without one, and with a blank one.
            var single: [String] = []
            for (blockID, given) in [(one.block.id, Value.string("english")), (one.block.id, .null),
                                     (two.block.id, .string("   "))] {
                var arguments: [String: Value] = ["block_id": .string(blockID), "text": .string("a take")]
                if given != .null { arguments["label"] = given }
                let landed = try await call(connection, "add_take", arguments)
                #expect(landed.isError != true, "\(text(landed))")
                single.append(try #require(try json(landed)["take_id"] as? String))
            }
            // Read into locals first, so a failure prints the labels it met.
            let singles = [try await label(h, single[0]), try await label(h, single[1]), try await label(h, single[2])]
            #expect(singles == ["claude-code \u{00B7} english", "claude-code", "claude-code"],
                    "with a label: the client and its label; none, or a blank one: the client alone")

            // add_takes: the same form on every item.
            let batch = try await call(connection, "add_takes", [
                "note_id": .string(note.id),
                "takes": .array([
                    .object(["block_id": .string(one.block.id), "text": .string("I never asked for the observatory."),
                             "label": .string("english")]),
                    .object(["block_id": .string(two.block.id), "text": .string("Running an observatory is hard work.")]),
                ]),
            ])
            #expect(batch.isError != true, "\(text(batch))")
            let batchIDs = try #require(try json(batch)["take_ids"] as? [String])
            #expect(batchIDs.count == 2)
            let batched = [try await label(h, batchIDs[0]), try await label(h, batchIDs[1])]
            #expect(batched == ["claude-code \u{00B7} english", "claude-code"], "add_takes wears the same form")

            // The control (her VX-197 split, P-VX195-5 — green on both sides by
            // design): at WRITE NEW a client's labels are stored exactly as given.
            let created = try await call(connection, "create_note", [
                "book_id": .string(book.id), "title": .string("ch 2"),
                "blocks": .array([.object([
                    "text": .string("Olá."),
                    "takes": .array([.object(["text": .string("Hello."), "label": .string("english")])]),
                ])]),
            ])
            #expect(created.isError != true, "\(text(created))")
            let createdNote = try #require(try json(created)["note_id"] as? String)
            #expect(try await h.database.read { db in
                try String.fetchAll(db, sql: """
                    SELECT v.label FROM variant v
                    JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                    WHERE cb.container_id = ? AND v.label IS NOT NULL
                    """, arguments: [createdNote])
            } == ["english"], "write new keeps the label exactly as given")
            await h.hangUp(connection)
        }
    }
}
