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
///   travelled to a structural successor, or — VX-260 — one SHE has edited
///   since: her edit makes it hers) — refuses with HER RULED SENTENCE,
///   verbatim (`notYourCommentWords`): a rungTooLow-family refusal, never the
///   not-shared shape, because the client CAN read that comment (13n-c's R2-6
///   precedent). It opens no oracle: it says only that the comment is not on
///   file as this client's. It raises no ask (her words carry no "Variorum has
///   asked" clause — PROVISIONAL P-VX188-1).
///
/// Both are made on the snapshot (the refusal and the ask) and AGAIN inside the
/// act's transaction by the guard, which spends any once grant there (the
/// edit-act pattern).
///
/// **VX-184 U4 (VX-195) — the EDIT clause (R-VX188-1: "at EDIT, any comment"):**
/// the rung a delete needs is SUGGEST for a comment on file as this client's
/// own, EDIT for any other (`deleteRung`). A comment not on file as the caller's
/// is deleted when the caller may EDIT the note; below edit her ruled sentence
/// answers, byte-unchanged (suggest and write-new callers alike, still no ask —
/// P-VX188-1). The guard decides the needed rung on its own rows and spends
/// exactly that rung's once grant — never two.
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
            let comment = try ops.deleteCommentForClient(
                commentID, undoLabel: Operations.MCPWriteAct.commentDelete.undoLabel(client: clientName),
                guardedBy: { db in
                    // The note at SUGGEST first (the one shape / the rung, as
                    // the snapshot), then the rung THIS comment needs — its
                    // once grant, and only its, spent here.
                    let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
                    let facts = try Queries.mcpNoteFacts(
                        db, noteID: try Queries.mcpContainerOf(comment: commentID, db) ?? "")
                    let atSuggest = MCPGrantAuthority.decide(standing, note: facts, rung: .suggest, consumes: true)
                    guard case .allow = atSuggest else { throw Self.refused(atSuggest, .note) }
                    let needed = try deleteRung(db, commentID, clientName)
                    let decision = needed == .suggest
                        ? atSuggest : MCPGrantAuthority.decide(standing, note: facts, rung: needed, consumes: true)
                    guard case .allow(let grantID, let consumesOnce) = decision else {
                        throw Refused(outcome: Outcome(text: Self.notYourCommentWords, isError: true))
                    }
                    if consumesOnce, let grantID { try grants.consumeMCPOnceGrant(db, grantID) }
                })
            return (["comment_id": commentID, "block_id": comment.blockId, "note_id": noteID, "deleted": true],
                    MCPWriteReceipt(clientName: clientName, act: .commentDelete, targetID: noteID, targetTitle: title,
                                    show: .note(noteID: noteID, blockID: comment.blockId, select: nil)))
        }
    }

    /// The rung deleting this comment needs: SUGGEST for one the record names
    /// as this client's own (R-VX188-1), EDIT for any other (VX-195 — the edit
    /// clause). `Queries.mcpCommentAuthor` is the one read.
    func deleteRung(_ db: Database, _ commentID: String, _ clientName: String) throws -> MCPGrantRule.Rung {
        try Queries.mcpCommentAuthor(db, commentID: commentID) == clientName ? .suggest : .edit
    }

    /// May this client delete this comment? Its OWN at suggest (the record
    /// names it as the writer); ANY at edit — the client may EDIT the
    /// comment's note (U4's clause, beside the ownership clause). Decided on
    /// the current standing; the guard decides again inside the act.
    func mayDelete(_ db: Database, _ commentID: String, _ clientName: String) throws -> Bool {
        guard try deleteRung(db, commentID, clientName) == .edit else { return true }
        let facts = try Queries.mcpNoteFacts(db, noteID: try Queries.mcpContainerOf(comment: commentID, db) ?? "")
        let decision = MCPGrantAuthority.decide(
            try MCPGrantAuthority.standing(db, clientName: clientName), note: facts, rung: .edit, consumes: true)
        if case .allow = decision { return true }
        return false
    }
}
