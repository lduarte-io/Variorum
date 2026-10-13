import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U3 — VX-188: the suggest rung deletes a client's OWN comment, known
// from the LOCAL-ONLY authorship record (`mcp_comment_author`, v1_27 — her
// R-VX188-1: "local only record is fine for clarity / for now"). The record is
// written in the comment's own transaction on every comment a client adds
// through the door; a comment the record does not name as the caller's — hers,
// another client's, one written before the record existed, one synced from
// another Mac — refuses with HER RULED SENTENCE (R-VX188-2), a rungTooLow-family
// refusal, never the not-shared shape: the client can read that comment.

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

/// Her ruled words (R-VX188-2), verbatim — the one refusal for a comment the
/// record does not name as the caller's.
private let herSentence =
    "You don't have permission to delete that comment. Suggest raising your permission level to edit."

@Suite("VX-188 — a client deletes its own comment at suggest", .serialized)
struct MCPCommentAuthorshipServerTests {
    private struct World {
        let book: Reading
        let note: Container
        let block: String
        let second: String
        let unshared: Container
        let unsharedBlock: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let one = try h.operations.newBlock(in: note.id, text: "Her opening.", registeringUndo: false)
        let two = try h.operations.newBlock(in: note.id, text: "Her close.", registeringUndo: false)
        let unshared = try h.operations.createPost(title: "not shared")
        let hidden = try h.operations.newBlock(in: unshared.id, text: "Private-ish words.", registeringUndo: false)
        return World(book: book, note: note, block: one.block.id, second: two.block.id, unshared: unshared,
                     unsharedBlock: hidden.block.id)
    }

    private func author(_ h: ServerHarness, _ commentID: String) async throws -> String? {
        try await h.database.read { db in
            try String.fetchOne(db, sql: "SELECT client_name FROM mcp_comment_author WHERE comment_id = ?",
                                arguments: [commentID])
        }
    }

    private func isLive(_ h: ServerHarness, _ commentID: String) async throws -> Bool {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block_comment WHERE id = ? AND deleted_at IS NULL",
                             arguments: [commentID]) == 1
        }
    }

    /// The record is written WITH the comment, by both comment doors, naming
    /// the client — and never for a comment of hers.
    @Test func everyDoorAddedCommentIsRecordedAsTheClientsAndHersNever() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))

            let single = try json(try await call(connection, "add_comment", [
                "block_id": .string(w.block), "text": .string("Check this date."),
            ]))
            let singleID = try #require(single["comment_id"] as? String)
            let batch = try json(try await call(connection, "add_comments", ["note_id": .string(w.note.id), "comments": .array([
                .object(["block_id": .string(w.block), "text": .string("A source?")]),
                .object(["block_id": .string(w.second), "text": .string("Tense shift.")]),
            ])]))
            let batchIDs = try #require(batch["comment_ids"] as? [String])
            for id in [singleID] + batchIDs {
                #expect(try await author(h, id) == "claude-code", "\(id) is on file as the client's")
            }
            let hers = try h.operations.addBlockComment(to: w.block, text: "Her own note.")
            #expect(try await author(h, hers.id) == nil, "her comment is never on file as a client's")
            // Undoing the comment keeps the record: it stays a fact of who wrote it.
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's comments")
            #expect(try await author(h, batchIDs[0]) == "claude-code")
            await h.hangUp(connection)
        }
    }

    /// SUGGEST deletes the client's OWN comment — one client-named undo entry,
    /// her ⌥⌘Z puts it back, ⇧⌥⌘Z deletes it again.
    @Test func suggestDeletesTheClientsOwnCommentAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let added = try json(try await call(connection, "add_comment", [
                "block_id": .string(w.block), "text": .string("Wrong — I take it back."),
            ]))
            let commentID = try #require(added["comment_id"] as? String)
            let depth = h.undoStack.depth

            let deleted = try await call(connection, "delete_comment", ["comment_id": .string(commentID)])
            #expect(deleted.isError != true, "\(text(deleted))")
            #expect(try json(deleted)["comment_id"] as? String == commentID)
            #expect(try await isLive(h, commentID) == false, "a tombstone, recoverable as every deleted comment is")
            #expect(h.undoStack.depth == depth + 1 && h.undoStack.topLabel == "claude-code's comment deletion")
            #expect(h.receipts.value.last?.act.rawValue == "comment deletion")
            let activity = try await h.database.read { try Queries.mcpActivity($0, limit: 1) }
            #expect(activity.first?.act == "delete_comment" && activity.first?.allowed == true)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's comment deletion")
            #expect(try await isLive(h, commentID), "her ⌥⌘Z puts it back")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's comment deletion")
            #expect(try await isLive(h, commentID) == false)
            await h.hangUp(connection)
        }
    }

    /// A comment the record does NOT name as the caller's refuses with HER
    /// sentence, verbatim — hers, another client's, and one with no record
    /// (written before the record existed, or synced from another Mac).
    /// Nothing is deleted, nothing registers, no ask is raised.
    @Test func aCommentNotOnFileAsTheClientsRefusesWithHerSentence() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let codex = try await h.connect(as: "codex")
            _ = try h.approve("codex", spec(.suggest, .book, w.book.id))
            let theirs = try #require(try json(try await call(codex, "add_comment", [
                "block_id": .string(w.block), "text": .string("codex was here."),
            ]))["comment_id"] as? String)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let mine = try #require(try json(try await call(connection, "add_comment", [
                "block_id": .string(w.second), "text": .string("Mine, but unrecorded."),
            ]))["comment_id"] as? String)
            try await h.database.write { db in
                try db.execute(sql: "DELETE FROM mcp_comment_author WHERE comment_id = ?", arguments: [mine])
            }
            let hers = try h.operations.addBlockComment(to: w.block, text: "Her own note.")
            let depth = h.undoStack.depth
            let asks = h.asks.value.count

            for commentID in [hers.id, theirs, mine] {
                let refused = try await call(connection, "delete_comment", ["comment_id": .string(commentID)])
                #expect(refused.isError == true && text(refused) == herSentence, "\(text(refused))")
                #expect(try await isLive(h, commentID), "nothing deleted")
            }
            #expect(h.undoStack.depth == depth && h.asks.value.count == asks, "nothing registered, no ask raised")
            let activity = try await h.database.read { try Queries.mcpActivity($0, limit: 1) }
            #expect(activity.first?.act == "delete_comment" && activity.first?.allowed == false)
            await h.hangUp(codex)
            await h.hangUp(connection)
        }
    }

    /// What the client can NOT read answers the one not-shared shape — a
    /// comment on an unshared note, a deleted comment and an id naming nothing
    /// byte-identical (no oracle); a READ grant hears the rung's refusal and
    /// raises the ask for suggest, as every suggest act.
    @Test func whatTheClientCannotReachAnswersTheOneShape() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let elsewhere = try h.operations.addBlockComment(to: w.unsharedBlock, text: "Not yours to see.")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let own = try #require(try json(try await call(connection, "add_comment", [
                "block_id": .string(w.block), "text": .string("Gone soon."),
            ]))["comment_id"] as? String)
            _ = try await call(connection, "delete_comment", ["comment_id": .string(own)])

            let nothing = try await call(connection, "delete_comment", ["comment_id": .string("no-such-comment")])
            #expect(nothing.isError == true && text(nothing).hasPrefix("That note isn't shared with this client"),
                    "\(text(nothing))")
            for commentID in [elsewhere.id, own] {
                let refused = try await call(connection, "delete_comment", ["comment_id": .string(commentID)])
                #expect(refused.isError == true && text(refused) == text(nothing), "\(text(refused))")
            }

            let reader = try await h.connect(as: "reader")
            _ = try h.approve("reader", spec(.read, .book, w.book.id))
            let hers = try h.operations.addBlockComment(to: w.block, text: "Her note.")
            let tooLow = try await call(reader, "delete_comment", ["comment_id": .string(hers.id)])
            #expect(tooLow.isError == true && text(tooLow).hasPrefix("This client may only read here."), "\(text(tooLow))")
            #expect(h.asks.value.last?.clientName == "reader" && h.asks.value.last?.rung == .suggest)
            await h.hangUp(reader)
            await h.hangUp(connection)
        }
    }
}
