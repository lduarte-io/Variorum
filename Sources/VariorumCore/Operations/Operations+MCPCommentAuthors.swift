import Dependencies
import Foundation
import GRDB

// WHO WROTE A COMMENT, AND A CLIENT DELETING ITS OWN (VX-184 U3 — VX-188; her
// rulings R-VX188-1/2 in `notes/plans/mcp-launch-polish-kickoff.md`).
//
// The record (`mcp_comment_author`, v1_27 — LOCAL-ONLY, the grants family's
// road) is written in the SAME transaction as every comment a client adds
// through the door (`addComment`, `addComments`), naming the client as it
// names itself. It is a fact about authorship, never a permission: WHO may
// delete is the server's decision (the pure grant rule on the note, then the
// record — the wire's guard); these ops decide nothing about clients.
// VX-260 (her pick, "Your edit makes it yours"): HER edit of the comment
// (`editBlockComment`, when the words change) forgets the record in its own
// transaction — the comment is hers from then on. Nothing else moves it: not a
// client's `edit_comment`, not an undo or redo, not a delete or restore.
// P-VX260-1, OPTION (b) (VX-246 U1b — v1_29): the record also keeps a DIGEST of
// the words the client wrote (`MCPCommentWords`), and the comment is the
// client's own only while its words still hash to it — so her edit on ANOTHER
// device (arriving by sync, which runs no door here), or any client's rewrite,
// makes deleting it need EDIT too. Acts that change no word leave it as it was.
//
// `deleteCommentForClient` is her own comment delete (`deleteBlockComment`'s
// row body — a tombstone, the comment stays on its block's deleted-comments
// surface and resurrectable) with the caller's guard FIRST inside its
// transaction and ONE client-named undo entry — every MCP write registers one
// (P-13nb-U2-4), though her own comment doors register none.
extension Operations {
    /// The record's write — inside the comment's own transaction. P-VX260-1
    /// (b): with the digest of the words AS STORED (`text`, the inserted row's
    /// own), the proof the comment is still the client's own.
    func recordMCPCommentAuthor(_ db: Database, commentID: String, client: String, text: String) throws {
        try db.execute(
            sql: """
                INSERT INTO mcp_comment_author (comment_id, client_name, recorded_at, text_digest)
                VALUES (?, ?, ?, ?)
                """,
            arguments: [commentID, client, DateFormatter.variorumISO8601.string(from: date.now),
                        MCPCommentWords.digest(text)])
    }

    /// VX-260: her edit made the comment hers — the record is forgotten,
    /// inside her edit's own transaction (`editBlockComment`). A comment with
    /// no record is no client's own (R-VX188-2's refusal at suggest).
    func forgetMCPCommentAuthor(_ db: Database, commentID: String) throws {
        try db.execute(sql: "DELETE FROM mcp_comment_author WHERE comment_id = ?", arguments: [commentID])
    }

    /// **`delete_comment`'s act** — her comment delete, exactly: the comment
    /// live, its block's note not sealed (`ensurePlacementUnlocked` — the
    /// comment seal posture, PROVISIONAL #23), a TOMBSTONE (S2) stamped now.
    /// The caller's guard runs FIRST in the same transaction. ONE undo entry,
    /// `undoLabel`: the comment back, only while it is still deleted on the
    /// act's EXACT stamp (a comment she restored and deleted again since is
    /// hers to answer for — the entry is quiet); the redo deletes it again on
    /// a fresh stamp, which the next undo then answers for.
    @discardableResult
    public func deleteCommentForClient(
        _ commentID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> BlockComment {
        let (comment, stamp): (BlockComment, String) = try database.write { db in
            try guardian?(db)
            return try tombstoneComment(db, commentID)
        }
        let deletedOn = LockIsolated(stamp)
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.reviveDeletedComment(commentID, deletedOn: deletedOn.value) },
            redo: { ops in
                guard let stamp = try ops.redeleteComment(commentID) else { return false }
                deletedOn.setValue(stamp)
                return true
            })
        return comment
    }

    /// `deleteBlockComment`'s row body, returning the stamp it wrote.
    private func tombstoneComment(_ db: Database, _ commentID: String) throws -> (BlockComment, String) {
        var comment = try liveComment(db, commentID)
        try ensurePlacementUnlocked(db, blockID: comment.blockId)
        let now = date.now
        comment.deletedAt = now
        comment.updatedAt = now
        try comment.update(db)
        return (comment, DateFormatter.variorumISO8601.string(from: now))
    }

    /// The inverse: the comment back while it is deleted on `stamp` and its
    /// block lives; a seal refuses and keeps the entry.
    @discardableResult
    func reviveDeletedComment(_ commentID: String, deletedOn stamp: String) throws -> Bool {
        try database.write { db in
            guard var comment = try BlockComment.fetchOne(db, key: commentID),
                  let deletedAt = comment.deletedAt,
                  DateFormatter.variorumISO8601.string(from: deletedAt) == stamp,
                  try Block.fetchOne(db, key: comment.blockId)?.deletedAt == nil
            else { return false }
            try ensurePlacementUnlocked(db, blockID: comment.blockId)
            comment.deletedAt = nil
            comment.updatedAt = date.now
            try comment.update(db)
            try voidPurgeIntents(db, table: "block_comment", rowID: commentID)
            return true
        }
    }

    /// The redo: delete it again while it is live (quiet otherwise); the new
    /// stamp, or nil when nothing was written.
    func redeleteComment(_ commentID: String) throws -> String? {
        try database.write { db in
            guard try BlockComment.fetchOne(db, key: commentID)?.deletedAt == nil else { return nil }
            return try tombstoneComment(db, commentID).1
        }
    }
}

extension Queries {
    /// **Who wrote this comment, as the record has it** (VX-188's one read —
    /// U4's edit rung consults the same fact): the client's name, or nil when
    /// no client is on file for it (hers, one synced from another Mac, one
    /// written before the record existed, one that travelled to a structural
    /// successor — and, since VX-260, one she has edited since). A FACT of
    /// authorship; whether the comment is still the client's OWN is
    /// `mcpCommentIsOwn` (P-VX260-1 (b) — its words unchanged).
    public static func mcpCommentAuthor(_ db: Database, commentID: String) throws -> String? {
        try String.fetchOne(
            db, sql: "SELECT client_name FROM mcp_comment_author WHERE comment_id = ?", arguments: [commentID])
    }

    /// **Is this comment still `client`'s own?** (P-VX260-1, option (b) —
    /// VX-246 U1b): the record names the client AND the comment's words now
    /// still hash to the digest written with them (`MCPCommentWords.isOwn` — a
    /// NULL digest, from before `v1_29`, is unproven: never). One keyed read of
    /// the record and one of the comment (∝ one comment).
    public static func mcpCommentIsOwn(_ db: Database, commentID: String, client: String) throws -> Bool {
        let record = try Row.fetchOne(
            db, sql: "SELECT client_name, text_digest FROM mcp_comment_author WHERE comment_id = ?",
            arguments: [commentID])
        let text = try String.fetchOne(db, sql: "SELECT text FROM block_comment WHERE id = ?", arguments: [commentID])
        return MCPCommentWords.isOwn(
            recordedClient: record?["client_name"], recordedDigest: record?["text_digest"],
            currentText: text, asker: client)
    }

    /// **The note a LIVE comment is on** — its block live-placed in a note
    /// right now — else nil (a deleted comment, a dead or released block, a
    /// stranger's id: the one-answer refusal, decided on the note).
    public static func mcpContainerOf(comment commentID: String, _ db: Database) throws -> String? {
        try String.fetchOne(
            db,
            sql: """
                SELECT cb.container_id FROM block_comment c
                JOIN block b ON b.id = c.block_id AND b.deleted_at IS NULL
                JOIN container_block cb ON cb.block_id = c.block_id AND cb.deleted_at IS NULL
                WHERE c.id = ? AND c.deleted_at IS NULL
                """,
            arguments: [commentID])
    }
}
