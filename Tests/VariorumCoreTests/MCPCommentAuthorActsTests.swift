import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-184 U3 — VX-188's acts (`Operations+MCPCommentAuthors`): the authorship
// record rides the comment's own transaction and outlives an undo; the
// client's delete is her tombstone with ONE entry whose inverse answers only
// for the act's EXACT stamp.

@Suite("VX-188 — the authorship record and the client's comment delete")
struct MCPCommentAuthorActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func author(_ db: AppDatabase, _ id: String) throws -> String? {
        try db.read { try Queries.mcpCommentAuthor($0, commentID: id) }
    }

    @Test func theRecordRidesTheCommentsTransactionAndOutlivesItsUndo() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "One.")
            stack.removeAll()
            let comment = try ops.addComment(toBlock: seeded.block.id, text: "Check.", author: client,
                                             undoLabel: Operations.MCPWriteAct.comment.undoLabel(client: client))
            #expect(try author(db, comment.id) == client)
            #expect(throws: OperationError.invalidCommentText, "a refused comment leaves no record behind") {
                _ = try ops.addComment(toBlock: seeded.block.id, text: " ", author: client, undoLabel: "x")
            }
            #expect(try db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM mcp_comment_author") } == 1)
            _ = try stack.undo(with: ops)
            #expect(try author(db, comment.id) == client, "a fact of who wrote it — kept through the undo")
            let hers = try ops.addBlockComment(to: seeded.block.id, text: "Hers.")
            #expect(try author(db, hers.id) == nil)
            #expect(try db.read { try Queries.mcpContainerOf(comment: hers.id, $0) } == note.id)
            #expect(try db.read { try Queries.mcpContainerOf(comment: comment.id, $0) } == nil, "a deleted comment lives nowhere")
        }
    }

    @Test func theDeleteIsHerTombstoneAndItsUndoAnswersOnlyForItsStamp() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "One.")
            let comment = try ops.addComment(toBlock: seeded.block.id, text: "Mine.", author: client, undoLabel: "x")
            stack.removeAll()
            let label = Operations.MCPWriteAct.commentDelete.undoLabel(client: client)
            #expect(label == "claude-code's comment deletion")

            _ = try ops.deleteCommentForClient(comment.id, undoLabel: label)
            #expect(try db.deletedAt("block_comment", comment.id) != nil)
            #expect(stack.depth == 1 && stack.topLabel == label)
            #expect(try stack.undo(with: ops) == label)
            #expect(try db.deletedAt("block_comment", comment.id) == nil, "back")
            #expect(try stack.redo(with: ops) == label)
            #expect(try db.deletedAt("block_comment", comment.id) != nil, "deleted again, on a fresh stamp")
            #expect(try stack.undo(with: ops) == label)
            #expect(try db.deletedAt("block_comment", comment.id) == nil, "the undo answers for the redo's stamp")

            // A delete of HERS since the act (another stamp) is hers to answer for.
            _ = try ops.deleteCommentForClient(comment.id, undoLabel: label)
            try ops.restoreBlockComment(comment.id)
            try ops.deleteBlockComment(comment.id)
            #expect(try stack.undo(with: ops) == label, "the entry runs…")
            #expect(try db.deletedAt("block_comment", comment.id) != nil, "…and leaves her own delete alone")

            #expect(throws: OperationError.self, "a guard refusal deletes nothing") {
                _ = try ops.deleteCommentForClient(
                    comment.id, undoLabel: label, guardedBy: { _ in throw OperationError.invalidCommentText })
            }
        }
    }
}
