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

    /// **VX-197 (VX-336 U8a): every tool that writes a take's label says which
    /// rule applies.** Her split (VX-197): the client prefix is worn only by
    /// takes a client adds at SUGGEST (`add_take`, `add_takes`), in VX-267's
    /// form; every other tool that writes a label keeps it as given. The words
    /// are pinned per tool — red on the old descriptions, where the rule was
    /// unstated on create_note, import_document, duplicate_note and
    /// set_take_label, and add_take/add_takes said it without its form — the
    /// example is tied to `aiLabel`, and the as-given half runs on the wire as
    /// a control (green on both sides by design).
    @Test func everyLabelWritingToolSaysWhichLabelRuleApplies() async throws {
        let suggestRule = """
            labeled with your client name, then " · " and your label when you give one \
            (e.g. "<your client name> · english"; a blank label is none)
            """
        let notPrefixed = "your client name is added only by add_take and add_takes"
        let says: [String: String] = [
            "add_take": suggestRule,
            "add_takes": suggestRule,
            "create_note": "Each label is stored as given (trimmed; a blank label is none) — " + notPrefixed,
            "insert_blocks": "Each label is stored as given (trimmed; a blank label is none) — " + notPrefixed,
            "set_take_label": "The label is stored as given (trimmed) — " + notPrefixed,
            "import_document": "each labeled as its take: line says — " + notPrefixed,
            "duplicate_note": "every take keeps its label — " + notPrefixed,
        ]
        for (tool, needle) in says.sorted(by: { $0.key < $1.key }) {
            let words = try #require(MCPToolCatalog.declaration(named: tool)).description
            #expect(words.contains(needle), "\(tool) says: \(needle)\n— it reads: \(words)")
        }
        // The example is aiLabel's own form, separator and all.
        #expect(MCPWriteTools.aiLabel(client: "<your client name>", own: " english ")
                == "<your client name>\(MCPWriteTools.labelSeparator)english")
        #expect(suggestRule.contains("\"\(MCPWriteTools.labelSeparator)\""))

        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let source = try h.operations.createPost(title: "to K")
            let one = try h.operations.newBlock(in: source.id, text: "Dear K,", registeringUndo: false)
            let alternate = try h.operations.newBlankVariant(one.block.id)
            try h.operations.autosave(alternate.id, text: "Dearest K,", charDelta: 10)
            try h.operations.setTakeLabel(alternate.id, label: "warmer")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            func labels(_ noteID: String) async throws -> [String] {
                try await h.database.read { db in
                    try String.fetchAll(db, sql: """
                        SELECT v.label FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                        WHERE cb.container_id = ? AND v.label IS NOT NULL AND v.deleted_at IS NULL
                        """, arguments: [noteID])
                }
            }

            // import_document: the label its take: line gives, no prefix.
            let document = try await h.database.read { try Queries.variorumDocumentText($0, postID: source.id) }
            let imported = try await call(connection, "import_document", [
                "document": .string(document), "wing_id": .string(""),
            ])
            #expect(imported.isError != true, "\(text(imported))")
            let importedNote = try #require(try json(imported)["note_id"] as? String)
            #expect(try await labels(importedNote) == ["warmer"], "import keeps the line's label")

            // duplicate_note: every take keeps its label.
            let duplicated = try await call(connection, "duplicate_note", ["note_id": .string(source.id)])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let copy = try #require(try json(duplicated)["note_id"] as? String)
            #expect(try await labels(copy) == ["warmer"], "the copy's take keeps its label")

            // set_take_label: as given, trimmed — no client name.
            let relabeled = try await call(connection, "set_take_label", [
                "take_id": .string(alternate.id), "label": .string("  warmest  "),
            ])
            #expect(relabeled.isError != true, "\(text(relabeled))")
            #expect(try await label(h, alternate.id) == "warmest", "stored as given, trimmed, no prefix")
            await h.hangUp(connection)
        }
    }
}
