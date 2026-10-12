import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-168 U3 — THE LENS DOORS END TO END, over a real socket driven by the
// SDK's own `Client` (U1's harness; `connect(as:)` presents the name's own
// setup key). VX-171 (R-VX171-2, door-only): the take-CREATION roads accept a
// blank take — `add_take` an empty text, `create_note`'s structured takes a
// take of `""` (minted, never dropped) — while `edit_take` to empty stays
// refused (P-VX171-2). VX-172: `read_note` reads a note THROUGH a lens.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: (client: Client, fd: Int32), _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("VX-168 U3 — VX-171's blank-take doors end to end", .serialized)
struct MCPBlankTakeDoorsServerTests {
    /// A note in a book with one block — her take, chosen.
    private struct World {
        let book: Reading
        let note: Container
        let blockID: String
        let hers: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let one = try h.operations.newBlock(in: note.id, text: "Her scaffold line.", registeringUndo: false)
        return World(book: book, note: note, blockID: one.block.id, hers: one.variant.id)
    }

    /// The block's live fan as `(text, label, chosen)` in fan order.
    private func fan(_ h: ServerHarness, _ blockID: String) async throws -> [[String?]] {
        try await h.database.read { db in
            let chosen = try String.fetchOne(
                db, sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                arguments: [blockID])
            return try Row.fetchAll(
                db,
                sql: """
                    SELECT id, working_text, label FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id
                    """,
                arguments: [blockID]
            ).map { [$0["working_text"], $0["label"], ($0["id"] as String) == chosen ? "chosen" : nil] }
        }
    }

    // MARK: - add_take

    /// R-VX171-2: a blank take is a legal take — the Mac's own blank-take
    /// gesture (`newBlankVariant`, `''`) made reachable at the suggest door.
    /// RED ON OLD: `add_take` refused an empty text ("text is required.").
    @Test func addTakeAcceptsAnEmptyTextAsABlankTake() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))

            let blank = try await call(connection, "add_take", ["block_id": .string(w.blockID), "text": .string("")])
            #expect(blank.isError != true, "a blank take is a legal take: \(text(blank))")
            let takeID = try #require(try json(blank)["take_id"] as? String)
            #expect(try await fan(h, w.blockID) == [
                ["Her scaffold line.", nil, "chosen"],
                ["", "claude-code \u{00B7} suggested", nil],
            ], "at the fan's end, labeled, never chosen — her text untouched")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: w.note.id) }
                    == "Her scaffold line.")
            #expect(h.undoStack.topLabel == "claude-code's take", "one client-named undo, as any take")
            #expect(try await h.database.read { db in
                try Variant.fetchOne(db, key: takeID).map { [$0.workingText, $0.status.rawValue] }
            } == ["", "active"])

            // The key must still be said: no text at all is no take.
            let absent = try await call(connection, "add_take", ["block_id": .string(w.blockID)])
            #expect(absent.isError == true && text(absent) == "text is required.", "\(text(absent))")

            // PROVISIONAL P-VX168-U3-1: the creation doors take ANY text —
            // whitespace alone too (create_note's takes always did).
            let spaces = try await call(connection, "add_take", ["block_id": .string(w.blockID), "text": .string("  ")])
            #expect(spaces.isError != true, "\(text(spaces))")
            #expect(try await fan(h, w.blockID).map { $0[0] } == ["Her scaffold line.", "", "  "])
            await h.hangUp(connection)
        }
    }

    // MARK: - create_note's takes

    /// R-VX171-2: `create_note`'s structured takes MINT a blank take — before
    /// this unit an empty take was silently DROPPED (P-13nb-U3-9's "empty-text
    /// takes drop", superseded at this door). RED ON OLD: the fan held two.
    @Test func createNoteMintsABlankTakeInsteadOfDroppingIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))

            let created = try await call(connection, "create_note", [
                "book_id": .string(w.book.id), "title": .string("the review"),
                "blocks": .array([
                    .object([
                        "text": .string("Kept as written."),
                        "takes": .array([
                            .object(["text": .string("")]),
                            .object(["text": .string("A second reading."), "label": .string("alt")]),
                        ]),
                    ]),
                ]),
            ])
            #expect(created.isError != true, "\(text(created))")
            let blockID = try #require((try json(created)["block_ids"] as? [String])?.first)
            #expect(try await fan(h, blockID) == [
                ["Kept as written.", nil, "chosen"],
                ["", nil, nil],
                ["A second reading.", "alt", nil],
            ], "the blank take joins the fan in document order, unchosen — never dropped")
            #expect(try await h.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT v.working_text FROM block b JOIN variant v ON v.id = b.default_variant_id WHERE b.id = ?",
                    arguments: [blockID])
            } == "Kept as written.", "the in-place text stays the block's default")
            await h.hangUp(connection)
        }
    }

    /// The FILE format's door is untouched (R-VX171-2 names add_take and
    /// create_note's takes only; "one format, one meaning" — R-13nb-11 G-2):
    /// the Level 0 format cannot carry a blank take, and import_document
    /// mints exactly what the format says.
    @Test func importDocumentStillMintsOnlyWhatTheFormatCarries() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let document = try await h.database.read { db -> String in
                try Queries.variorumDocumentText(db, postID: w.note.id)
            }
            let imported = try await call(connection, "import_document", [
                "document": .string(document), "book_id": .string(w.book.id),
            ])
            #expect(imported.isError != true, "\(text(imported))")
            let blockID = try #require((try json(imported)["block_ids"] as? [String])?.first)
            #expect(try await fan(h, blockID) == [["Her scaffold line.", nil, "chosen"]])
            await h.hangUp(connection)
        }
    }

    // MARK: - edit_take to empty stays refused

    /// P-VX171-2 (QUESTIONS #211): clearing a take's text is a different act
    /// from blanking in a lens — `edit_take` to empty refuses, the relaxation
    /// lives at the creation doors only. Nothing is written: no text, no
    /// bracket commit, no undo entry, no receipt.
    @Test func editTakeToEmptyStillRefuses() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            // RED ON OLD (the probe, before the refusal existed): the clear
            // LANDED — her text emptied, both bracket commits written, an
            // undo entry and a receipt. P-VX171-2's "stays refused" had no
            // standing refusal under it.
            for blank in ["", "  ", "\n\n"] {
                let cleared = try await call(connection, "edit_take", [
                    "take_id": .string(w.hers), "text": .string(blank), "expected_text": .string("Her scaffold line."),
                ])
                #expect(cleared.isError == true && text(cleared) == MCPWriteTools.editTakeBlankRefusal,
                        "clearing a take is not the edit door's act: \(text(cleared))")
            }
            #expect(MCPWriteTools.editTakeBlankRefusal
                    == "edit_take never empties a take. For a blank take, use add_take with an empty text.")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: w.note.id) }
                    == "Her scaffold line.")
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point")
            } == 0, "no bracket commits for a refused edit")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)

            // A blank take the client ADDED is no exception: the edit door
            // never empties a take, and fills a blank one like any other.
            let added = try json(try await call(connection, "add_take", [
                "block_id": .string(w.blockID), "text": .string(""),
            ]))
            let blankID = try #require(added["take_id"] as? String)
            let filled = try await call(connection, "edit_take", [
                "take_id": .string(blankID), "text": .string("Now with words."), "expected_text": .string(""),
            ])
            #expect(filled.isError != true, "\(text(filled))")
            let emptied = try await call(connection, "edit_take", [
                "take_id": .string(blankID), "text": .string(""), "expected_text": .string("Now with words."),
            ])
            #expect(emptied.isError == true && text(emptied) == MCPWriteTools.editTakeBlankRefusal)
            await h.hangUp(connection)
        }
    }
}
