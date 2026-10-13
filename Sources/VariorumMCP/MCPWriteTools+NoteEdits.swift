import Foundation
import GRDB
import MCP
import VariorumCore

/// **THE EDIT RUNG's PARITY INSIDE A NOTE on the wire** (VX-184 U4 — VX-195;
/// her ruling R-VX184-1, "We defined Edit as 'as capable as you at the
/// keyboard', we need to make that true"). Thin projections of
/// `Operations+MCPNoteEdits` — her own doors' acts on a note's comments, takes,
/// commits, title and lenses — each the edit rung's two decisions (AF-10 (a)):
/// the SNAPSHOT (`onNote`, `spendsAfter: false`) speaks the refusal and raises
/// the just-in-time ask — the ONE not-shared answer for anything unreachable (a
/// dead, foreign, version's or scraps id), `rungTooLow` + the asked sentence for
/// a live holder below edit — then a `WriteGuard` re-resolves the note from the
/// act's own rows INSIDE its transaction, decides at EDIT, and spends any once
/// grant there. ONE client-named undo entry per act (P-13nb-U2-4; the record's
/// call 1). Private, Seal and Own stay hers alone (R-VX184-2): nothing here
/// touches them — `lock_take` is a TAKE's lock, never the note's seal.
extension MCPWriteTools {
    enum NoteEditJob: Sendable {
        case editComment(commentID: String, text: String, expectedText: String)
        case restoreComment(commentID: String)

        var tool: String {
            switch self {
            case .editComment: MCPToolCatalog.editComment.name
            case .restoreComment: MCPToolCatalog.restoreComment.name
            }
        }
    }

    // MARK: - The wire's own refusals (P-U4-WORDS, 13s-a sweepable)

    /// `edit_comment`'s stale read (`expected_text` no longer matches).
    static let commentChangedWords =
        "That comment changed since you read it \u{2014} nothing was written. Read the note again "
        + "(read_note with with_ids: true) and edit what it says now."

    /// `restore_comment` on a deleted comment her deleted-comments surface no
    /// longer offers (she chose "Delete forever…").
    static let commentNotRestorableWords =
        "That comment can't be brought back \u{2014} it isn't among the block's deleted comments any more."

    // MARK: - Arguments (parsed BEFORE the executor)

    func parseNoteEdit(_ name: String, _ args: [String: Value]) throws -> NoteEditJob? {
        switch name {
        case MCPToolCatalog.editComment.name:
            let text = try requiredText(args, "text")
            guard let expected = try optionalString(args, "expected_text") else {
                throw ArgumentFailure(message: "expected_text is required: the comment's text exactly as you read it.")
            }
            return .editComment(commentID: try requiredString(args, "comment_id"), text: text, expectedText: expected)
        case MCPToolCatalog.restoreComment.name:
            return .restoreComment(commentID: try requiredString(args, "comment_id"))
        default:
            return nil
        }
    }

    // MARK: - The serial body

    func performNoteEdit(
        _ edit: NoteEditJob, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let label = { (act: Operations.MCPWriteAct) in act.undoLabel(client: clientName) }
        switch edit {
        case .editComment(let commentID, let text, let expected):
            let noteID = try database.read { try Queries.mcpContainerOf(comment: commentID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("comment", commentID), spendsAfter: false) { title in
                let result: Operations.MCPCommentEdit
                do {
                    result = try ops.editCommentForClient(
                        commentID, text: text, expectedText: expected, undoLabel: label(.commentEdit),
                        guardedBy: guardEdit(clientName) { db in [try Queries.mcpContainerOf(comment: commentID, db)] })
                } catch Operations.MCPNoteEditRefusal.commentChangedSinceRead {
                    throw Refused(outcome: Outcome(text: Self.commentChangedWords, isError: true))
                }
                return (["comment_id": commentID, "block_id": result.blockID, "note_id": noteID,
                         "changed": result.changed],
                        result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .commentEdit, targetID: noteID,
                                          targetTitle: title,
                                          show: .note(noteID: noteID, blockID: result.blockID, select: nil))
                        : nil)
            }

        case .restoreComment(let commentID):
            // The comment's home, deleted or live (a live one reaches her
            // restore's own "not deleted" refusal — `put_back`'s precedent).
            let noteID = try database.read { try Queries.mcpCommentHome(commentID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("comment", commentID), spendsAfter: false) { title in
                let decided = guardEdit(clientName) { db in [try Queries.mcpCommentHome(commentID, db)] }
                let comment = try ops.restoreCommentForClient(
                    commentID, undoLabel: label(.commentRestore),
                    guardedBy: { db in
                        try decided(db)
                        // Never a door her surface doesn't offer: a DELETED
                        // comment must be on her block's deleted comments.
                        if try Queries.mcpContainerOf(comment: commentID, db) == nil,
                           try !Queries.mcpCommentIsRestorable(commentID, db) {
                            throw Refused(outcome: Outcome(text: Self.commentNotRestorableWords, isError: true))
                        }
                    })
                return (["comment_id": commentID, "block_id": comment.blockId, "note_id": noteID, "restored": true],
                        MCPWriteReceipt(clientName: clientName, act: .commentRestore, targetID: noteID,
                                        targetTitle: title,
                                        show: .note(noteID: noteID, blockID: comment.blockId, select: nil)))
            }
        }
    }
}
