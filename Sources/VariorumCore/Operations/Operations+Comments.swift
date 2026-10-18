import Dependencies
import Foundation
import GRDB

// Block comments (Phase 13, Step A1 — v1_8; author-decided 2026-07-17,
// AppSpec §14 items 6/9): working notes on a BLOCK, never per-take. CRUD +
// the resurrection door — deleted comments are recoverable by design
// ("the feature shouldn't be excessively skimpy").
//
// SEAL POSTURE (PROVISIONAL, Phase 13 — logged in notes/QUESTIONS.md):
// comment writes REFUSE under a sealed post, per the ratified
// everything-UNDER-the-post letter (2026-07-05) — a comment hangs on a block
// under the post, like fan growth and block names (the v1_6 precedent). The
// viewing-isn't-authoring alternative (allow — a comment is a note ABOUT the
// text, not the text; the canvas/lens class) is recorded for the author.
//
// NO undo entries: comments are the tags/locks exclusion class (AppSpec §9 —
// trivially re-toggled), and deletion has its own first-class recovery door
// (`restoreBlockComment` + the deleted-comments surface), which is stronger
// than a session-scoped stack.
extension Operations {
    /// A new comment at the end of the block's note list (display order is
    /// `(created_at, id)`). The block must be live; whitespace-only text
    /// refuses; the text is stored verbatim otherwise (trimming a note would
    /// edit it). Metadata: no touch stamp, no churn — a note about the prose
    /// is not working on the prose (the `setBlockName` doctrine).
    @discardableResult
    public func addBlockComment(to blockID: String, text: String) throws -> BlockComment {
        try database.write { db in try insertBlockComment(db, to: blockID, text: text) }
    }

    /// `addBlockComment`'s row work inside the caller's transaction (VX-184
    /// U3 — extracted byte-for-byte so the MCP door's batch lands each of its
    /// comments through the SAME body, beside its authorship record).
    func insertBlockComment(_ db: Database, to blockID: String, text: String) throws -> BlockComment {
        // VX-357: U+0000 removed before the blank check and the row
        // (`StoredText`) — every comment road (hers, the wire's one and batch
        // doors) lands through this body, and the authorship digest reads
        // the stored text.
        let text = StoredText.stripped(text)
        _ = try liveBlock(db, blockID)
        try ensurePlacementUnlocked(db, blockID: blockID)
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OperationError.invalidCommentText
        }
        let now = date.now
        let comment = BlockComment(
            id: newID(), ownerId: currentOwnerID(), blockId: blockID,
            text: text, createdAt: now, updatedAt: now)
        try comment.insert(db)
        return comment
    }

    /// Rewrites a live comment's text in place. Same refusals as adding;
    /// a no-op edit writes nothing.
    ///
    /// **VX-260 — her edit makes the comment HERS** (VX-184's ladder round 1;
    /// her pick, "Your edit makes it yours"): when the words really change,
    /// the comment's MCP authorship record (`mcp_comment_author`, local-only)
    /// is forgotten in the same transaction, so no client can delete it at
    /// suggest any more — deleting it needs edit, and a suggest caller hears
    /// her R-VX188-2 sentence. A no-op edit and a refused one leave the record
    /// as it was; a client's `edit_comment` never runs this door.
    public func editBlockComment(_ id: String, text: String) throws {
        try database.write { db in
            guard try rewriteComment(db, id, text: text) != nil else { return }
            try forgetMCPCommentAuthor(db, commentID: id)
        }
    }

    /// `editBlockComment`'s row work inside the caller's transaction (VX-184
    /// U4 — extracted byte-for-byte so the MCP door's `edit_comment` runs the
    /// SAME body). `expecting` is that door's stale-read precondition, checked
    /// after her guards and before her no-op (nil on her door — unchanged).
    /// Returns the text it replaced, or nil when nothing was written.
    func rewriteComment(_ db: Database, _ id: String, text: String, expecting: String? = nil) throws -> String? {
        // VX-357: the new words with U+0000 removed (`insertBlockComment`'s
        // reason). `expecting` stays as sent — a precondition compares with
        // what is stored, which never holds a null character.
        let text = StoredText.stripped(text)
        var comment = try liveComment(db, id)
        _ = try liveBlock(db, comment.blockId)
        try ensurePlacementUnlocked(db, blockID: comment.blockId)
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OperationError.invalidCommentText
        }
        if let expecting, comment.text != expecting {
            throw MCPNoteEditRefusal.commentChangedSinceRead(commentID: id)
        }
        guard comment.text != text else { return nil }
        let previous = comment.text
        comment.text = text
        comment.updatedAt = date.now
        try comment.update(db)
        return previous
    }

    /// Tombstone (S2). The comment stays visible on the block's
    /// deleted-comments surface and resurrectable below.
    public func deleteBlockComment(_ id: String) throws {
        try database.write { db in
            var comment = try liveComment(db, id)
            try ensurePlacementUnlocked(db, blockID: comment.blockId)
            let now = date.now
            comment.deletedAt = now
            comment.updatedAt = now
            try comment.update(db)
        }
    }

    /// The resurrection door for an INDIVIDUALLY-deleted comment. A comment
    /// that died with its block (cascade) revives through `restoreBlock` /
    /// `restoreContainer`'s exact-stamp flip, not here — this door requires
    /// the block live (a live comment under a dead block is a state nothing
    /// renders).
    public func restoreBlockComment(_ id: String) throws {
        try database.write { db in try reviveCommentRow(db, id) }
    }

    /// `restoreBlockComment`'s row work inside the caller's transaction
    /// (VX-184 U4 — extracted byte-for-byte so the MCP door's
    /// `restore_comment` runs the SAME body).
    func reviveCommentRow(_ db: Database, _ id: String) throws {
        guard var comment = try BlockComment.fetchOne(db, key: id) else {
            throw OperationError.commentNotFound(id: id)
        }
        guard comment.deletedAt != nil else {
            throw OperationError.commentNotDeleted(id: id)
        }
        _ = try liveBlock(db, comment.blockId)
        try ensurePlacementUnlocked(db, blockID: comment.blockId)
        comment.deletedAt = nil
        comment.updatedAt = date.now
        try comment.update(db)
        // VX-179 — the restore-side belt (13j ladder B, B1): since a
        // deleted comment can carry a purge intent ("Delete forever…"),
        // a restore VOIDS any live intent naming it, inside this
        // transaction, so a leftover intent can never claim her next
        // delete of it (the fence would hide it from the fold and the
        // janitor would take it with no confirm).
        try voidPurgeIntents(db, table: "block_comment", rowID: id)
    }

    // MARK: - Travel (Phase 13, Step A2 — the duplication rule)

    /// Copies the source block's LIVE comments onto a freshly minted
    /// structural successor (her instinct, ratified direction: comments
    /// "duplicate where needed and are easy to resolve"). Fresh IDs; the
    /// source comment's `created_at` is PRESERVED on the copy (a note's date
    /// is part of the note — and it keeps the copied list in the source's
    /// display order); `updated_at` = the operation's clock. Deleted
    /// comments do NOT travel — their recovery surface stays with the
    /// original block. PROVISIONAL (the created_at preservation half) —
    /// logged in notes/QUESTIONS.md.
    func copyLiveComments(
        _ db: Database, from sourceBlockID: String, to targetBlockID: String, now: Date
    ) throws {
        let comments = try BlockComment
            .filter(Column("block_id") == sourceBlockID && Column("deleted_at") == nil)
            .order(Column("created_at"), Column("id"))
            .fetchAll(db)
        for comment in comments {
            try BlockComment(
                id: newID(), ownerId: currentOwnerID(), blockId: targetBlockID,
                text: comment.text, createdAt: comment.createdAt, updatedAt: now)
                .insert(db)
        }
    }

    // MARK: - Internals

    func liveComment(_ db: Database, _ id: String) throws -> BlockComment {
        guard let comment = try BlockComment.fetchOne(db, key: id),
              comment.deletedAt == nil
        else {
            throw OperationError.commentNotFound(id: id)
        }
        return comment
    }
}
