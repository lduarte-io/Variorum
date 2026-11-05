import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// A-809-11 — THE F-5 BUILD ON THE WIRE (the VX-809 run, batch 3; PROVISIONAL
// P-809-8): an intake seat a WIRE applying act triggers never fences the note.
// FINDING F-5 (batch 1's record): a client's act applied a tag (or a star), a
// PRIVATE book — or THE daily Journal — collecting it SEATED the note, and the
// client's NEXT read of its own subject answered not-shared: the topic channel
// her R-825 named ("the book subject alone could tell you something"). Now the
// would-be seat BELLS — an arrival is no membership, so no fence — on every
// road through the one application road: `apply_tag`, `set_starred`,
// `duplicate_note`'s tags, a book's outflow on `create_note`. Each pin drives a
// real client over the socket and asserts the STATE (the arrival row exists, no
// membership row, the note unfenced) and the client's next read SERVING.
//
// RED ON OLD: every pin here (and the catalog's F-5 rows) compiles on the
// pre-fix tree and fails there on content — the seat lands, the note is
// fenced, the next read answers the not-shared shape (the record's B3-3).

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

@Suite("A-809-11 — a wire act's intake never fences the note, on the wire", .serialized)
struct MCPWireIntakeNeverFencesServerTests {
    private func rows(_ h: ServerHarness, _ readingID: String, _ postID: String) throws -> [String] {
        try h.database.read {
            try String.fetchAll(
                $0,
                sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                arguments: [readingID, postID])
        }
    }

    private func fence(_ h: ServerHarness, _ postID: String) throws -> MCPGrantRule.Fence? {
        try h.database.read { try #require(try Queries.mcpNoteFacts($0, noteID: postID)).fence }
    }

    /// THE STATE PIN, one note: the arrival row at the fencing book, no
    /// membership there, the note unfenced — and the client's next read serves.
    private func expectBelledAndStillReadable(
        _ h: ServerHarness, _ connection: HarnessConnection, book: String, note: String, _ road: String
    ) async throws {
        #expect(try rows(h, book, note) == ["arrival"], "\(road): the would-be seat waits at the door")
        #expect(try fence(h, note) == nil, "\(road): the note stays as reachable as the act found it")
        let read = try await call(connection, "read_note", ["note_id": .string(note)])
        #expect(read.isError != true, "\(road): the client's next read of its own subject serves: \(text(read))")
    }

    /// A Private book collecting #topic, a Private book collecting ★ (both join
    /// quietly — her intake would SEAT), a plain book collecting #topic.
    private func world(_ h: ServerHarness) throws -> (diary: String, stars: String, plain: String, topic: String) {
        let ops = h.operations
        let topic = try ops.createTag(name: "topic")
        let diary = try ops.createReading(name: "Diary", kind: .book, querySpec: try RuleGrammar.encode(.tag(topic.id)))
        _ = try ops.setBookPrivate(diary.id, true)
        let stars = try ops.createReading(name: "Starred diary", kind: .book, querySpec: try RuleGrammar.encode(.star))
        _ = try ops.setBookPrivate(stars.id, true)
        let plain = try ops.createReading(name: "Plain", kind: .book, querySpec: try RuleGrammar.encode(.tag(topic.id)))
        return (diary.id, stars.id, plain.id, topic.id)
    }

    @Test func applyTagBellsAtAPrivateBookAndTheNoteStaysReadable() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let note = try h.operations.createPost(title: "the client's")
            _ = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let result = try await call(connection, "apply_tag", ["note_id": .string(note.id), "tag": .string("topic")])
            #expect(result.isError != true, "\(text(result))")
            try await expectBelledAndStillReadable(h, connection, book: w.diary, note: note.id, "apply_tag")
            #expect(try rows(h, w.plain, note.id) == ["member"], "a plain book still seats a wire act's note")
            // Her own tag, the parity witness: her intake seats and fences.
            let mine = try h.operations.createPost(title: "hers")
            _ = try h.operations.applyTag(w.topic, toPost: mine.id)
            #expect(try rows(h, w.diary, mine.id) == ["member"] && fence(h, mine.id) == .privateMark)
            // The client's ⌥⌘Z takes the application back; the bell stays
            // (un-tagging is a non-event — §19, P-13nb-U2-6).
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's tag")
            #expect(try rows(h, w.diary, note.id) == ["arrival"])
            await h.hangUp(connection)
        }
    }

    @Test func setStarredBellsAtAPrivateStarBookAndTheNoteStaysReadable() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let note = try h.operations.createPost(title: "starry")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let result = try await call(connection, "set_starred", ["note_id": .string(note.id), "starred": .bool(true)])
            #expect(result.isError != true, "\(text(result))")
            try await expectBelledAndStillReadable(h, connection, book: w.stars, note: note.id, "set_starred")
            let unstar = try await call(connection, "set_starred", ["note_id": .string(note.id), "starred": .bool(false)])
            #expect(unstar.isError != true)
            #expect(try rows(h, w.stars, note.id) == ["arrival"], "un-starring is a non-event (§19)")
            await h.hangUp(connection)
        }
    }

    @Test func duplicateNoteWithTagsBellsTheCopyAtAPrivateBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let source = try h.operations.createPost(title: "source")
            _ = try h.operations.newBlock(in: source.id, text: "Source words.", registeringUndo: false)
            _ = try h.operations.applyTag(w.topic, toPost: source.id)
            // Her seat fenced the SOURCE; out of the Diary again (a decided
            // pair), so only the COPY's tagging is heard there.
            _ = try h.operations.removePostFromReading(source.id, from: w.diary)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let result = try await call(connection, "duplicate_note", ["note_id": .string(source.id), "brief": .bool(true)])
            #expect(result.isError != true, "\(text(result))")
            let copy = try #require(try json(result)["note_id"] as? String)
            try await expectBelledAndStillReadable(h, connection, book: w.diary, note: copy, "duplicate_note")
            await h.hangUp(connection)
        }
    }

    @Test func createNotesOutflowBellsAtAPrivateBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let filed = try h.operations.createReading(name: "Filed", kind: .book)
            try h.operations.setReadingOutflow(filed.id, tagIDs: [w.topic])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let result = try await call(connection, "create_note",
                                        ["book_id": .string(filed.id), "title": .string("filed"), "text": .string("Words.")])
            #expect(result.isError != true, "\(text(result))")
            let note = try #require(try json(result)["note_id"] as? String)
            #expect(try rows(h, filed.id, note) == ["member"], "the client's own filing lands")
            try await expectBelledAndStillReadable(h, connection, book: w.diary, note: note, "create_note's outflow")
            await h.hangUp(connection)
        }
    }

    @Test func theDailyJournalsWouldBeSeatBellsForAWireTag() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let topic = try h.operations.createTag(name: "day-topic")
            let entry = try h.operations.createOrOpenJournalEntry(entryDate: "2026-06-30").container
            guard case .shelved(let journal) = h.operations.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily Journal was not made")
                return
            }
            try h.operations.setReadingQuerySpec(journal, querySpec: try RuleGrammar.encode(.tag(topic.id)))
            let note = try h.operations.createPost(title: "a wire note")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let result = try await call(connection, "apply_tag", ["note_id": .string(note.id), "tag": .string("day-topic")])
            #expect(result.isError != true, "\(text(result))")
            try await expectBelledAndStillReadable(h, connection, book: journal, note: note.id, "apply_tag (the daily Journal)")
            await h.hangUp(connection)
        }
    }
}
