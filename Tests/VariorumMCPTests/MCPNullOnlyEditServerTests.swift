import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-774 (the VX-771 run, batch 3 — found in-run as batch 2's O-1; the record
// `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`, BATCH 3 RECORD). R-VX171-2:
// `edit_take` never empties a take. THE MECHANISM: the whole form's blank check is
// the parse's, on the text AS SENT, and the operations layer strips U+0000 only
// afterwards (VX-357) — U+0000 is not whitespace, so a `text` of only null
// characters passed the parse and landed the empty take. THE FIX: the blank check
// reads the text as it would be stored (`StoredText.stripped`).
//
// RED ON OLD: every null-only whole form LANDED (`changed: true`, the stored take
// `""`, both bracket commits, an undo entry, a receipt). The replace form's
// null-only result already refused (`wouldEmptyTake` reads the stripped result) —
// a guard, green on both sides; so is the strip of a text that keeps words.

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

@Suite("VX-774 — a whole-form edit_take of only null characters never empties the take", .serialized)
struct MCPNullOnlyEditServerTests {
    private struct World {
        let book: Reading
        let note: Container
        let takeID: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let placed = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
        return World(book: book, note: note, takeID: placed.variant.id)
    }

    private func stored(_ h: ServerHarness, _ takeID: String) async throws -> String? {
        try await h.database.read { db in
            try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [takeID])
        }
    }

    private func commitCount(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { db in try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point") ?? 0 }
    }

    /// THE PIN (red on old): a whole form whose text is only U+0000 — alone,
    /// doubled, or mixed with whitespace — refuses in the blank sentence and
    /// writes nothing: the take keeps its words, no bracket commit, no undo
    /// entry, no receipt.
    @Test func aNullOnlyWholeFormRefusesAsEditToEmptyAndWritesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            for blank in ["\u{0}", "\u{0}\u{0}", " \u{0}\n", "\u{0}\n\u{0}"] {
                let cleared = try await call(connection, "edit_take", [
                    "take_id": .string(w.takeID), "text": .string(blank), "expected_text": .string("Her line."),
                ])
                #expect(cleared.isError == true && text(cleared) == MCPWriteTools.editTakeBlankRefusal,
                        "a text of only null characters (and whitespace) empties the take: \(text(cleared))")
                #expect(try await stored(h, w.takeID) == "Her line.", "her words stand")
            }
            #expect(try await commitCount(h) == 0, "no bracket commits for a refused edit")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty, "nothing registered, nothing said")
            await h.hangUp(connection)
        }
    }

    /// THE GUARDS (green on both sides): the replace form's result is read
    /// after the strip, so a `new_str` of only null characters replacing the
    /// whole take — or leaving only whitespace — refuses in the same blank
    /// sentence; and a whole text that keeps words still lands stripped,
    /// saying how many it removed.
    @Test func theReplaceFormAndAWordedTextStayAsTheyWere() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            for replacement in ["\u{0}", "\u{0} \u{0}"] {
                let replaced = try await call(connection, "edit_take", [
                    "take_id": .string(w.takeID), "old_str": .string("Her line."), "new_str": .string(replacement),
                ])
                #expect(replaced.isError == true && text(replaced) == MCPWriteTools.editTakeBlankRefusal,
                        "\(text(replaced))")
                #expect(try await stored(h, w.takeID) == "Her line.")
            }
            #expect(try await commitCount(h) == 0 && h.undoStack.depth == 0)

            let worded = try await call(connection, "edit_take", [
                "take_id": .string(w.takeID), "text": .string("\u{0}Her new line."),
                "expected_text": .string("Her line."),
            ])
            #expect(worded.isError != true, "\(text(worded))")
            #expect(try json(worded)["null_characters_removed"] as? Int == 1)
            #expect(try await stored(h, w.takeID) == "Her new line.")
            await h.hangUp(connection)
        }
    }
}
