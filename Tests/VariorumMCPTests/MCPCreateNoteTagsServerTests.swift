import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-814 — `create_note`'s `tags` ON THE WIRE (the VX-809 run, batch 3). Every
// pin drives a real client over the socket: the note is born wearing the tags in
// the one act and the one client-named undo, the answer's `tag_ids` + `tags` lead
// with them in the given order (VX-361's rule — then a book's outflow, each
// once), living books hear the birth (a Private book's would-be seat bells —
// A-809-11), the argument refuses in words when malformed (before any decision:
// nothing read, minted, spent or logged), the schema declares it (VX-606), and a
// U+0000 inside a path is counted (VX-357). Features: no red-on-old owed.

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

@Suite("VX-814 — create_note's tags at birth, on the wire", .serialized)
struct MCPCreateNoteTagsServerTests {
    private func worn(_ h: ServerHarness, _ postID: String) throws -> [String] {
        try h.database.read {
            try String.fetchAll(
                $0,
                sql: """
                    SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL ORDER BY pt.created_at, pt.rowid
                    """,
                arguments: [postID])
        }
    }

    private func status(_ h: ServerHarness, _ readingID: String, _ postID: String) throws -> String? {
        try h.database.read {
            try String.fetchOne(
                $0,
                sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                arguments: [readingID, postID])
        }
    }

    private func tagID(_ h: ServerHarness, path: String) throws -> String? {
        try h.database.read { try String.fetchOne($0, sql: "SELECT id FROM tag WHERE path = ?", arguments: [path]) }
    }

    private func parentID(_ h: ServerHarness, _ tagID: String) throws -> String? {
        try h.database.read { try String.fetchOne($0, sql: "SELECT parent_id FROM tag WHERE id = ?", arguments: [tagID]) }
    }

    private func consumedAt(_ h: ServerHarness, _ grant: String) throws -> String? {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
        }
    }

    private func counts(_ h: ServerHarness) throws -> [Int] {
        try h.database.read { db in
            try ["container", "tag", "post_tag", "mcp_activity"].map {
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \($0)") ?? 0
            }
        }
    }

    @Test func aNoteIsBornWearingItsTagsWithOneClientNamedUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let life = try h.operations.createTag(name: "life")
            let topic = try h.operations.createTag(name: "topic")
            let seats = try h.operations.createReading(
                name: "Seats", kind: .book, querySpec: try RuleGrammar.encode(.tag(topic.id)))
            let diary = try h.operations.createReading(
                name: "Diary", kind: .book, querySpec: try RuleGrammar.encode(.tag(topic.id)))
            _ = try h.operations.setBookPrivate(diary.id, true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let result = try await call(connection, "create_note", [
                "wing_id": .string(""), "title": .string("born tagged"), "text": .string("Words."),
                "tags": .array([.string("life/goals"), .string("topic"), .string("/life//goals/")]),
            ])
            #expect(result.isError != true, "\(text(result))")
            let answer = try json(result)
            let note = try #require(answer["note_id"] as? String)
            #expect(answer["tags"] as? [String] == ["life/goals", "topic"], "the given order, each once")
            let goals = try #require(try tagID(h, path: "life/goals"))
            #expect(answer["tag_ids"] as? [String] == [goals, topic.id])
            #expect(try parentID(h, goals) == life.id, "the existing ancestor adopted, the missing leaf minted under it")
            #expect(try worn(h, note) == ["life/goals", "topic"])
            // Intake heard the birth: a plain book seats it, a Private one bells.
            #expect(try status(h, seats.id, note) == "member")
            #expect(try status(h, diary.id, note) == "arrival")
            // ONE client-named undo — the mint's — and ONE receipt.
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's note")
            #expect(h.receipts.value.map(\.act) == [.note])
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's note")
            #expect(try worn(h, note).isEmpty, "the applications go with the note")
            await h.hangUp(connection)
        }
    }

    @Test func theAnswerLeadsWithTheBirthTagsThenTheOutflow() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let out = try h.operations.createTag(name: "out")
            let book = try h.operations.createReading(name: "Filed", kind: .book)
            try h.operations.setReadingOutflow(book.id, tagIDs: [out.id])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let result = try await call(connection, "create_note", [
                "book_id": .string(book.id), "blocks": .array([.object(["text": .string("One.")])]),
                "tags": .array([.string("mine")]),
            ])
            #expect(result.isError != true, "\(text(result))")
            #expect(try json(result)["tags"] as? [String] == ["mine", "out"])
            await h.hangUp(connection)
        }
    }

    /// A malformed `tags` refuses the call in words BEFORE any decision —
    /// nothing minted, read into the log or spent.
    @Test func aMalformedTagsArgumentRefusesInWordsAndTouchesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            let grant = try #require(try h.approve("claude-code", spec(.writeNew, .wing, "", .once)))
            let before = try counts(h)
            for (tags, words) in [
                (Value.string("life"), "tags must be an array."),
                (.array([.int(3)]), "tags must hold strings."),
                (.array([.string("ok"), .string(" / // ")]), MCPWriteTools.emptyTagPathWords(1)),
            ] {
                let result = try await call(connection, "create_note",
                                            ["wing_id": .string(""), "text": .string("x"), "tags": tags])
                #expect(result.isError == true && text(result) == words, "\(text(result))")
            }
            #expect(try counts(h) == before, "nothing minted, applied or logged")
            #expect(try consumedAt(h, grant) == nil, "the once grant unspent")
            // An empty list is no tags at all.
            let plain = try await call(connection, "create_note",
                                       ["wing_id": .string(""), "text": .string("x"), "tags": .array([])])
            #expect(plain.isError != true)
            let plainTags = try json(plain)["tags"] as? [String]
            #expect(plainTags == [])
            await h.hangUp(connection)
        }
    }

    /// The schema declares `tags` (VX-606 serves it), and a U+0000 inside a
    /// path is stripped and counted (VX-357), as `apply_tag`'s path is.
    @Test func theSchemaDeclaresTagsAndANullInAPathIsCounted() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let properties = MCPToolCatalog.createNote.inputSchema.objectValue?["properties"]?.objectValue
            #expect(properties?["tags"]?.objectValue?["type"] == .string("array"))
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let result = try await call(connection, "create_note", [
                "wing_id": .string(""), "text": .string("x"), "tags": .array([.string("nu\u{0}ll")]),
            ])
            #expect(result.isError != true, "\(text(result))")
            let answer = try json(result)
            #expect(answer["tags"] as? [String] == ["null"])
            #expect(answer["null_characters_removed"] as? Int == 1)
            await h.hangUp(connection)
        }
    }
}
