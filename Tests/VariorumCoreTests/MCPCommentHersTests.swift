import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-260 — HER EDIT MAKES AN AI'S COMMENT HERS, at the store (the run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — "VX-260"): her
// comment edit (`editBlockComment`) clears the comment's authorship record in its
// own transaction — only when the words really changed; a client's
// `edit_comment` (`editCommentForClient`) never does (it did not make the
// comment hers); a refused edit clears nothing. Pre-fix API only — the first
// test compiles on the pre-fix tree, where it was watched RED.

@Suite("VX-260 — her edit clears the comment's authorship record")
struct MCPCommentHersTests {
    private func author(_ db: AppDatabase, _ commentID: String) throws -> String? {
        try db.read { try Queries.mcpCommentAuthor($0, commentID: commentID) }
    }

    private func note(_ ops: Operations) throws -> String {
        let note = try ops.createPost(title: "ch 1")
        return try ops.newBlock(in: note.id, text: "Her opening.", registeringUndo: false).block.id
    }

    @Test func herEditClearsTheRecordAndANoOpEditDoesNot() throws {
        try withOperations { ops, db in
            let block = try note(ops)
            let edited = try ops.addComment(toBlock: block, text: "Check this date.", author: "claude-code", undoLabel: "x")
            let same = try ops.addComment(toBlock: block, text: "A source?", author: "claude-code", undoLabel: "x")
            #expect(try author(db, edited.id) == "claude-code" && author(db, same.id) == "claude-code")

            try ops.editBlockComment(edited.id, text: "Check this date — it's 1971.")
            #expect(try author(db, edited.id) == nil, "her edit made it hers")
            try ops.editBlockComment(same.id, text: "A source?")
            #expect(try author(db, same.id) == "claude-code", "a no-op edit writes nothing — still the client's")
        }
    }

    @Test func aClientsEditAndARefusedEditOfHersKeepTheRecord() throws {
        try withOperations { ops, db in
            let block = try note(ops)
            let comment = try ops.addComment(toBlock: block, text: "Check this date.", author: "claude-code", undoLabel: "x")
            _ = try ops.editCommentForClient(
                comment.id, text: "Check this date, please.", expectedText: "Check this date.", undoLabel: "x")
            #expect(try author(db, comment.id) == "claude-code", "a client's edit is not hers")

            #expect(throws: OperationError.invalidCommentText) { try ops.editBlockComment(comment.id, text: "   ") }
            #expect(try author(db, comment.id) == "claude-code", "a refused edit clears nothing")
        }
    }
}
