import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// P-VX260-1, REBUILT AS OPTION (b) (VX-246 U1b piece 3 — THE ORCHESTRATOR ON
// U1's HAND-BACK; the run record `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`).
// Her rule (VX-260): "Once she has edited an AI's comment, deleting it needs
// EDIT." U1 built option (a) — her edit on THIS Mac forgets the local-only
// authorship record — so her edit on the phone or the Air, which arrives by
// sync and never runs her edit door here, left the record naming the client,
// and a suggest client could still delete the comment she had rewritten.
// Option (b): the record keeps a digest of the words the client wrote; ANY
// change to the words — from any device or client — makes the comment no
// longer the client's own, so deleting it needs EDIT.
//
// The pin changes the words with NO DOOR, the way a sync apply lands a row
// (`_sync_applying` set inside the transaction, the row written directly),
// then the suggest client's delete must hear her R-VX188-2 sentence. Pre-fix
// API only — it compiles on the pre-fix tree, where it is watched RED.

@Suite("P-VX260-1 (b) — changed words make an AI's comment no longer its own", .serialized)
struct MCPCommentWordsServerTests {
    private func isLive(_ h: ServerHarness, _ commentID: String) async throws -> Bool {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block_comment WHERE id = ? AND deleted_at IS NULL",
                             arguments: [commentID]) == 1
        }
    }

    /// The comment's words rewritten the way a sync apply writes a row — no
    /// door of this Mac runs (her edit on another device, arriving).
    private func rewriteAsSyncArrives(_ h: ServerHarness, _ commentID: String, to words: String) async throws {
        try await h.database.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            try db.execute(
                sql: "UPDATE block_comment SET text = ?, updated_at = ?, sync_version = sync_version + 1 WHERE id = ?",
                arguments: [words, "2026-10-14T12:00:00.000Z", commentID])
            try db.execute(sql: "DELETE FROM _sync_applying")
        }
    }

    @Test func aSuggestClientCannotDeleteItsCommentOnceItsWordsChangedElsewhere() async throws {
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

            // She rewrites the first on her phone; the row arrives by sync.
            let rewritten = ids[0]
            try await rewriteAsSyncArrives(h, rewritten, to: "Check this date — it's 1971, I looked.")
            #expect(try await h.database.read { try BlockComment.fetchOne($0, key: rewritten)?.text }
                    == "Check this date — it's 1971, I looked.", "premise: the words changed with no door")
            let refused = try await connection.client.callTool(name: "delete_comment", arguments: [
                "comment_id": .string(ids[0]),
            ])
            #expect(refused.isError == true && text(refused) == MCPWriteTools.notYourCommentWords,
                    "her words, from any device, make it hers: \(text(refused))")
            #expect(try await isLive(h, ids[0]), "her words stand")

            // The one whose words never changed is still the client's own.
            let deleted = try await connection.client.callTool(name: "delete_comment", arguments: [
                "comment_id": .string(ids[1]),
            ])
            #expect(deleted.isError != true, "its own, its words untouched: \(text(deleted))")
            #expect(try await isLive(h, ids[1]) == false)
            await h.hangUp(connection)
        }
    }

    /// The control (green on both sides — what option (b) must NOT do; option
    /// (c), the `updated_at` compare, would): acts that change no word — her
    /// delete and Put back, a sync arrival of the same words — leave the
    /// comment the client's own.
    @Test func actsThatChangeNoWordLeaveItTheClientsOwn() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "ch 2")
            let block = try h.operations.newBlock(in: note.id, text: "Her page.", registeringUndo: false).block.id
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .suggest, scopeKind: .note, scopeID: note.id, duration: .always))
            let added = try await connection.client.callTool(name: "add_comment", arguments: [
                "block_id": .string(block), "text": .string("Tighten this."),
            ])
            let id = try #require(try json(added)["comment_id"] as? String)

            try h.operations.deleteBlockComment(id)
            try h.operations.restoreBlockComment(id)
            try await rewriteAsSyncArrives(h, id, to: "Tighten this.")
            let deleted = try await connection.client.callTool(name: "delete_comment", arguments: [
                "comment_id": .string(id),
            ])
            #expect(deleted.isError != true, "no word changed — still its own: \(text(deleted))")
            #expect(try await isLive(h, id) == false)
            await h.hangUp(connection)
        }
    }

    /// **VX-197 (VX-336 U8a): delete_comment's description says VX-260.** Its
    /// VX-184 words said a suggest client may delete any comment "you left";
    /// since VX-260 (option (b), the words' digest) a comment it left whose
    /// words have changed since — the author's edit on any device, another
    /// client's rewrite — is refused at suggest too, and a record from before
    /// the digest is unproven. The two pins above run the mechanics; this one
    /// holds the words to them (red on the old description).
    @Test func deleteCommentsDescriptionSaysChangedWordsNeedEdit() {
        let words = MCPToolCatalog.deleteComment.description
        #expect(words.contains(
            "With suggest you may delete only a comment you left (with add_comment or add_comments) whose "
                + "words no one has changed since you wrote them;"), "\(words)")
        #expect(words.contains(
            "one left before Variorum kept a record of its words, or one whose words were changed after you "
                + "wrote them (by the author on any device, or by another client)"), "\(words)")
        #expect(words.contains("With edit on the note you may delete any comment."))
    }
}
