import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// P-VX260-1, OPTION (b) — THE WORDS A CLIENT WROTE, at the store (VX-246 U1b;
// the run record `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`). The
// authorship record keeps a digest of the words the client wrote; a comment is
// the client's own only while its words still hash to it. State transitions on
// the new API — the red-first pin is the wire's (`MCPCommentWordsServerTests`).

@Suite("P-VX260-1 (b) — a comment is a client's own only while its words are")
struct MCPCommentWordsTests {
    private func note(_ ops: Operations) throws -> (noteID: String, blockID: String) {
        let note = try ops.createPost(title: "ch 1")
        return (note.id, try ops.newBlock(in: note.id, text: "Her opening.", registeringUndo: false).block.id)
    }

    private func isOwn(_ db: AppDatabase, _ commentID: String, _ client: String = "claude-code") throws -> Bool {
        try db.read { try Queries.mcpCommentIsOwn($0, commentID: commentID, client: client) }
    }

    private func digest(_ db: AppDatabase, _ commentID: String) throws -> String? {
        try db.read {
            try String.fetchOne($0, sql: "SELECT text_digest FROM mcp_comment_author WHERE comment_id = ?",
                                arguments: [commentID])
        }
    }

    /// The words rewritten the way a sync apply lands a row (no door).
    private func arrive(_ db: AppDatabase, _ commentID: String, _ words: String) throws {
        try db.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            try db.execute(sql: "UPDATE block_comment SET text = ? WHERE id = ?", arguments: [words, commentID])
            try db.execute(sql: "DELETE FROM _sync_applying")
        }
    }

    // MARK: - The pure rule

    @Test func theRuleIsTheRecordsClientAndTheSameWords() {
        let d = MCPCommentWords.digest("Check this date.")
        #expect(d.count == 64 && d == MCPCommentWords.digest("Check this date."), "hex SHA-256, deterministic")
        #expect(d != MCPCommentWords.digest("Check this date. "), "byte-exact — no trimming")
        #expect(MCPCommentWords.isOwn(recordedClient: "claude-code", recordedDigest: d,
                                      currentText: "Check this date.", asker: "claude-code"))
        #expect(!MCPCommentWords.isOwn(recordedClient: "claude-code", recordedDigest: d,
                                       currentText: "Check this date — 1971.", asker: "claude-code"),
                "changed words — no longer its own")
        #expect(!MCPCommentWords.isOwn(recordedClient: "codex", recordedDigest: d,
                                       currentText: "Check this date.", asker: "claude-code"), "another client's")
        #expect(!MCPCommentWords.isOwn(recordedClient: "claude-code", recordedDigest: nil,
                                       currentText: "Check this date.", asker: "claude-code"),
                "a record from before the digest is unproven — never its own")
        #expect(!MCPCommentWords.isOwn(recordedClient: nil, recordedDigest: nil,
                                       currentText: "Check this date.", asker: "claude-code"), "no record — hers")
        #expect(!MCPCommentWords.isOwn(recordedClient: "claude-code", recordedDigest: d,
                                       currentText: nil, asker: "claude-code"), "no comment")
    }

    // MARK: - The record's write

    /// Both doors that put a comment on file write the digest of its words AS
    /// STORED, in the comment's own transaction.
    @Test func bothAddDoorsRecordTheWordsDigest() throws {
        try withOperations { ops, db in
            let (noteID, block) = try note(ops)
            let one = try ops.addComment(toBlock: block, text: "Check this date.", author: "claude-code", undoLabel: "x")
            #expect(try digest(db, one.id) == MCPCommentWords.digest(one.text))
            let batch = try ops.addComments(
                [.init(blockID: block, text: "A source?"), .init(blockID: block, text: "Tighten.")],
                inNote: noteID, author: "claude-code", undoLabel: "x")
            for comment in batch {
                #expect(try digest(db, comment.id) == MCPCommentWords.digest(comment.text), "\(comment.text)")
                #expect(try isOwn(db, comment.id))
            }
        }
    }

    // MARK: - What changes it, and what does not

    @Test func changedWordsFromAnyRoadEndItsOwnership() throws {
        try withOperations { ops, db in
            let (_, block) = try note(ops)
            let untouched = try ops.addComment(toBlock: block, text: "Untouched.", author: "claude-code", undoLabel: "x")
            let synced = try ops.addComment(toBlock: block, text: "Check this date.", author: "claude-code", undoLabel: "x")
            let clients = try ops.addComment(toBlock: block, text: "A source?", author: "claude-code", undoLabel: "x")
            #expect(try isOwn(db, untouched.id) && isOwn(db, synced.id) && isOwn(db, clients.id))
            #expect(try !isOwn(db, untouched.id, "codex"), "never another client's")

            // Her edit on another device, arriving by sync (no door here).
            try arrive(db, synced.id, "Check this date — it's 1971, I looked.")
            #expect(try !isOwn(db, synced.id), "her words, from any device, make it hers")
            #expect(try db.read { try Queries.mcpCommentAuthor($0, commentID: synced.id) } == "claude-code",
                    "the authorship FACT stays — only ownership ended")
            // The very words it wrote, back: an unchanged digest means unchanged words.
            try arrive(db, synced.id, "Check this date.")
            #expect(try isOwn(db, synced.id), "its own words again")

            // A client's rewrite (the accepted residual: an edit-rung rewrite
            // also ends suggest-rung ownership).
            _ = try ops.editCommentForClient(clients.id, text: "A source, please?", expectedText: "A source?", undoLabel: "x")
            #expect(try !isOwn(db, clients.id), "rewritten words are not the words it wrote")
            #expect(try isOwn(db, untouched.id), "the untouched comment stays its own")
        }
    }

    @Test func actsThatChangeNoWordLeaveItsOwnershipAlone() throws {
        try withOperations { ops, db in
            let (_, block) = try note(ops)
            let comment = try ops.addComment(toBlock: block, text: "Tighten this.", author: "claude-code", undoLabel: "x")
            try ops.deleteBlockComment(comment.id)
            try ops.restoreBlockComment(comment.id)
            #expect(try isOwn(db, comment.id), "her delete and Put back change no word")
            try arrive(db, comment.id, "Tighten this.")
            #expect(try isOwn(db, comment.id), "a sync arrival of the same words changes none")
            try ops.editBlockComment(comment.id, text: "Tighten this.")
            #expect(try isOwn(db, comment.id), "her no-op edit writes nothing")
        }
    }

    /// A record from before `v1_29` (no digest) is unproven: never the
    /// client's own, whatever its words.
    @Test func aLegacyRecordIsNeverTheClientsOwn() throws {
        try withOperations { ops, db in
            let (_, block) = try note(ops)
            let comment = try ops.addComment(toBlock: block, text: "Old.", author: "claude-code", undoLabel: "x")
            try db.write { try $0.execute(sql: "UPDATE mcp_comment_author SET text_digest = NULL") }
            #expect(try !isOwn(db, comment.id), "unproven — deleting it needs edit")
        }
    }
}
