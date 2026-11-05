import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-812 — THE LIST FORMS ON THE WIRE (the VX-809 run, batch 3; her R-812; the
// tool set and the once grant ruled A-809-18, the receipts A-809-19). Every pin
// drives a real client over the socket: `note_ids` on delete_note ·
// move_note_to_wing · apply_tag · remove_tag runs each item as the SINGLE call's
// own act — its answer or its refusal byte for byte, its own ⌥⌘Z entry, its own
// Activity line — one refusing never stopping the rest; landed items' receipts
// share ONE run key (one line at the app); a once grant covers ONE item; a
// malformed list refuses in words before any decision. Features: no red-on-old
// owed (the argument did not exist).

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

@Suite("VX-812 — the list forms: each item the single act, one call", .serialized)
struct MCPNoteListsServerTests {
    private func isLive(_ h: ServerHarness, _ postID: String) throws -> Bool {
        try h.database.read {
            try Bool.fetchOne($0, sql: "SELECT deleted_at IS NULL FROM container WHERE id = ?", arguments: [postID]) ?? false
        }
    }

    private func worn(_ h: ServerHarness, _ postID: String) throws -> [String] {
        try h.database.read {
            try String.fetchAll(
                $0,
                sql: """
                    SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL ORDER BY t.path
                    """,
                arguments: [postID])
        }
    }

    private func activity(_ h: ServerHarness, _ act: String) throws -> [Row] {
        try h.database.read {
            try Row.fetchAll($0, sql: "SELECT * FROM mcp_activity WHERE act = ? ORDER BY id", arguments: [act])
        }
    }

    private func consumedAt(_ h: ServerHarness, _ grant: String) throws -> String? {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
        }
    }

    private func count(_ h: ServerHarness, _ sql: String) throws -> Int {
        try h.database.read { try Int.fetchOne($0, sql: sql) ?? 0 }
    }

    /// delete_note over three ids — a note it may edit, a hidden one, another
    /// it may edit: two land (each the single answer, byte for byte), the
    /// hidden one answers the single call's one shape, ⌥⌘Z walks the items one
    /// by one, every landed item's receipt rides ONE run key.
    @Test func deleteNoteOverAListLandsEachItemAsTheSingleCallWould() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let one = try h.operations.createPost(title: "one")
            let two = try h.operations.createPost(title: "two")
            let hidden = try h.operations.createPost(title: "hidden")
            _ = try h.operations.setNotePrivate(hidden.id, true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            // The single call's refusal on the hidden note — the item's words.
            let single = try await call(connection, "delete_note", ["note_id": .string(hidden.id)])
            #expect(single.isError == true)

            let result = try await call(connection, "delete_note",
                                        ["note_ids": .array([.string(one.id), .string(hidden.id), .string(two.id)])])
            #expect(result.isError != true, "\(text(result))")
            let answer = try json(result)
            #expect(answer["landed_count"] as? Int == 2 && answer["refused_count"] as? Int == 1)
            let results = try #require(answer["results"] as? [[String: Any]])
            #expect(results.count == 3)
            #expect(results[0]["note_id"] as? String == one.id && results[0]["deleted"] as? Bool == true
                    && results[0]["trash_days"] as? Int == TrashWindow.days && results[0].count == 3,
                    "the single call's answer, its keys exactly")
            #expect(Set(results[1].keys) == ["note_id", "refused"] && results[1]["refused"] as? String == text(single),
                    "the hidden item answers the single call's one shape, byte for byte")
            #expect(results[2]["note_id"] as? String == two.id)
            #expect(try !isLive(h, one.id) && !isLive(h, two.id) && isLive(h, hidden.id))
            // Per item: two entries, two receipts on ONE run key, two landed lines.
            #expect(h.undoStack.depth == 2)
            let receipts = h.receipts.value
            #expect(receipts.map(\.act) == [.noteDelete, .noteDelete])
            #expect(receipts[0].runKey != nil && receipts[0].runKey == receipts[1].runKey)
            #expect(receipts.flatMap(\.notesLeftDead) == [one.id, two.id], "each item sends its pane road")
            #expect(try activity(h, "delete_note").map { $0["outcome"] as String } == ["refused", "allowed", "refused", "allowed"])
            // ⌥⌘Z walks the items: the newest first.
            _ = try h.undoStack.undo(with: h.writeOperations)
            #expect(try isLive(h, two.id) && !isLive(h, one.id))
            // A later single act's receipt carries no run key.
            let more = try h.operations.createPost(title: "more")
            _ = try await call(connection, "delete_note", ["note_id": .string(more.id)])
            #expect(h.receipts.value.last?.runKey == nil)
            await h.hangUp(connection)
        }
    }

    /// apply_tag over a list: a fresh application, a note already wearing it
    /// (`changed: false` — no receipt), a note it may only READ (the rung's
    /// refusal), a missing id — every item runs, in order.
    @Test func applyTagOverAListRunsEveryItemOneRefusalNeverHaltingTheRest() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let fresh = try h.operations.createPost(title: "fresh")
            let wearing = try h.operations.createPost(title: "worn")
            let readOnly = try h.operations.createPost(title: "read only")
            let tag = try h.operations.createTag(name: "listed")
            _ = try h.operations.applyTag(tag.id, toPost: wearing.id)
            let book = try h.operations.createReading(name: "Shelf", kind: .book)
            for note in [fresh, wearing] { _ = try h.operations.addPostToReading(note.id, to: book.id) }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, readOnly.id))
            let result = try await call(connection, "apply_tag", [
                "note_ids": .array([.string(readOnly.id), .string(fresh.id), .string("no-such-note"), .string(wearing.id)]),
                "tag": .string("listed"),
            ])
            #expect(result.isError != true, "\(text(result))")
            let results = try #require(try json(result)["results"] as? [[String: Any]])
            #expect(results.map { $0["note_id"] as? String } == [readOnly.id, fresh.id, "no-such-note", wearing.id])
            #expect(results[0]["refused"] != nil && results[2]["refused"] != nil)
            #expect(results[1]["changed"] as? Bool == true && results[3]["changed"] as? Bool == false)
            #expect(try json(result)["landed_count"] as? Int == 2)
            #expect(try worn(h, fresh.id) == ["listed"] && worn(h, readOnly.id).isEmpty)
            #expect(h.receipts.value.map(\.act) == [.tag], "a no-op item claims nothing")
            #expect(h.undoStack.depth == 1)
            await h.hangUp(connection)
        }
    }

    /// A ONCE grant covers ONE item (A-809-18 a.1, P-809-12): the first item it
    /// allows lands and spends it; the next answers the single call's
    /// spent-grant answer.
    @Test func aOnceGrantCoversOneItem() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let first = try h.operations.createPost(title: "first")
            let second = try h.operations.createPost(title: "second")
            let connection = try await h.connect(as: "claude-code")
            let grant = try #require(try h.approve("claude-code", spec(.edit, .wing, "", .once)))
            let result = try await call(connection, "delete_note",
                                        ["note_ids": .array([.string(first.id), .string(second.id)])])
            #expect(result.isError != true, "\(text(result))")
            let results = try #require(try json(result)["results"] as? [[String: Any]])
            #expect(results[0]["deleted"] as? Bool == true && results[1]["refused"] != nil)
            #expect(try consumedAt(h, grant) != nil, "spent inside the first item's transaction")
            #expect(try !isLive(h, first.id) && isLive(h, second.id))
            await h.hangUp(connection)
        }
    }

    /// move_note_to_wing and remove_tag over a list: each item's answer is the
    /// single answer (its `beyond_reach`, its `left_books`, its
    /// `still_in_books`); the move's receipts share the run key.
    @Test func moveAndRemoveTagOverAListAnswerEachItemAsTheSingleCall() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let topic = try h.operations.createTag(name: "topic")
            let a = try h.operations.createPost(title: "a")
            let b = try h.operations.createPost(title: "b")
            for note in [a, b] { _ = try h.operations.applyTag(topic.id, toPost: note.id) }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.edit, .wing, studio.id))
            let untag = try await call(connection, "remove_tag",
                                       ["note_ids": .array([.string(a.id), .string(b.id)]), "tag": .string("topic")])
            #expect(untag.isError != true, "\(text(untag))")
            for item in try #require(try json(untag)["results"] as? [[String: Any]]) {
                #expect(item["removed"] as? Bool == true && item["still_in_books"] as? [Any] != nil
                        && item[MCPWriteTools.beyondReachKey] as? String == MCPWriteTools.beyondReachWords)
            }
            let move = try await call(connection, "move_note_to_wing",
                                      ["note_ids": .array([.string(a.id), .string(b.id)]), "wing_id": .string(studio.id)])
            #expect(move.isError != true, "\(text(move))")
            let moved = try #require(try json(move)["results"] as? [[String: Any]])
            #expect(moved.allSatisfy { $0["moved"] as? Bool == true && $0["wing_id"] as? String == studio.id })
            let moves = h.receipts.value.filter { $0.act == .wingMove }
            #expect(moves.count == 2 && moves[0].runKey != nil && moves[0].runKey == moves[1].runKey)
            #expect(h.undoStack.depth == 4, "two un-tags and two moves — four entries")
            await h.hangUp(connection)
        }
    }

    /// A list where EVERY item refused is an error answer carrying every
    /// item's refusal; a malformed list refuses in words before any decision.
    @Test func anAllRefusedListIsAnErrorAndAMalformedListTouchesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let none = try await call(connection, "delete_note", ["note_ids": .array([.string("x"), .string("y")])])
            #expect(none.isError == true)
            #expect(try json(none)["refused_count"] as? Int == 2)
            let note = try h.operations.createPost(title: "kept")
            let before = try count(h, "SELECT COUNT(*) FROM mcp_activity")
            let tooMany = Value.array((0...MCPWriteTools.listCap).map { .string("n\($0)") })
            for (args, words) in [
                (["note_ids": .array([.string(note.id)]), "note_id": .string(note.id)] as [String: Value],
                 "Pass note_id or note_ids, not both."),
                (["note_ids": .array([])], "note_ids lists no note."),
                (["note_ids": .string(note.id)], "note_ids must be an array."),
                (["note_ids": .array([.int(1)])], "note_ids must hold strings."),
                (["note_ids": .array([.string(note.id), .string(note.id)])], "note_ids lists a note twice."),
                (["note_ids": tooMany], MCPWriteTools.listCapWords(MCPWriteTools.listCap + 1)),
            ] {
                let result = try await call(connection, "delete_note", args)
                #expect(result.isError == true && text(result) == words, "\(text(result))")
            }
            #expect(try count(h, "SELECT COUNT(*) FROM mcp_activity") == before, "nothing decided, nothing logged")
            #expect(try isLive(h, note.id))
            await h.hangUp(connection)
        }
    }

    /// Every list-form tool declares `note_ids` and no longer requires
    /// `note_id`; its description states the cap and the once-grant rule.
    @Test func theFourToolsDeclareTheListForm() {
        for name in MCPWriteTools.listFormTools {
            let tool = try! #require(MCPToolCatalog.declaration(named: name))
            let schema = tool.inputSchema.objectValue
            #expect(schema?["properties"]?.objectValue?["note_ids"] != nil, "\(name)")
            let required = (schema?["required"]?.arrayValue ?? []).compactMap(\.stringValue)
            #expect(!required.contains("note_id"), "\(name): \(required)")
            #expect(tool.description.contains("a once grant covers one item") && tool.description.contains("200"), "\(name)")
        }
    }
}
