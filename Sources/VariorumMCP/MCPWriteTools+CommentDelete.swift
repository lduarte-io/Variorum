import Foundation
import GRDB
import MCP
import VariorumCore

/// **`delete_comment` — a client deleting its OWN comment, at SUGGEST**
/// (VX-184 U3 — VX-188; her rulings R-VX188-1/2). A thin projection of
/// `Operations.deleteCommentForClient` (her comment delete — a tombstone,
/// recoverable — with ONE client-named undo entry).
///
/// **Two decisions, the suggest rung's own and then the record's:**
/// - the comment's NOTE at SUGGEST through the ordinary rule — a comment on a
///   note the client cannot reach (and a deleted comment, and an id naming
///   nothing) answers the ONE not-shared shape (no oracle); a note it reads
///   but cannot suggest in hears the rung's refusal and raises the ask;
/// - then the LOCAL-ONLY authorship record (`Queries.mcpCommentAuthor`) must
///   name THIS client. Anything else — her comment, another client's, one with
///   no record (written before the record existed, synced from another Mac,
///   travelled to a structural successor) — refuses with HER RULED SENTENCE,
///   verbatim (`notYourCommentWords`): a rungTooLow-family refusal, never the
///   not-shared shape, because the client CAN read that comment (13n-c's R2-6
///   precedent). It opens no oracle: it says only that the comment is not on
///   file as this client's. It raises no ask (her words carry no "Variorum has
///   asked" clause — PROVISIONAL P-VX188-1).
///
/// Both are made on the snapshot (the refusal and the ask) and AGAIN inside the
/// act's transaction by the guard, which spends any once grant there (the
/// edit-act pattern). **For U4 (VX-195):** the edit rung's any-comment delete is
/// a second clause beside the ownership clause in `mayDelete` — until it lands,
/// an EDIT-rung client deleting a comment not on file as its own hears her
/// sentence too.
extension MCPWriteTools {
    /// Her words (R-VX188-2, RULED 2026-10-12 — "permissions" → "permission"
    /// her only edit). Verbatim; never re-voiced here.
    static let notYourCommentWords =
        "You don't have permission to delete that comment. Suggest raising your permission level to edit."

    func performCommentDelete(
        _ commentID: String, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let noteID = try database.read { try Queries.mcpContainerOf(comment: commentID, $0) } ?? ""
        return try onNote(noteID, rung: .suggest, job: job, clientName: clientName,
                          logged: ("comment", commentID), spendsAfter: false) { title in
            guard try database.read({ try mayDelete($0, commentID, clientName) }) else {
                throw Refused(outcome: Outcome(text: Self.notYourCommentWords, isError: true))
            }
            let suggestGuard = guardNotes(clientName, rung: .suggest) { db in
                [try Queries.mcpContainerOf(comment: commentID, db)]
            }
            let comment = try ops.deleteCommentForClient(
                commentID, undoLabel: Operations.MCPWriteAct.commentDelete.undoLabel(client: clientName),
                guardedBy: { db in
                    try suggestGuard(db)
                    guard try mayDelete(db, commentID, clientName) else {
                        throw Refused(outcome: Outcome(text: Self.notYourCommentWords, isError: true))
                    }
                })
            return (["comment_id": commentID, "block_id": comment.blockId, "note_id": noteID, "deleted": true],
                    MCPWriteReceipt(clientName: clientName, act: .commentDelete, targetID: noteID, targetTitle: title,
                                    show: .note(noteID: noteID, blockID: comment.blockId, select: nil)))
        }
    }

    /// May this client delete this comment? At suggest: only when the record
    /// names it as the comment's writer. (U4's edit arm joins here.)
    func mayDelete(_ db: Database, _ commentID: String, _ clientName: String) throws -> Bool {
        try Queries.mcpCommentAuthor(db, commentID: commentID) == clientName
    }
}
