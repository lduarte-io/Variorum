import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's EDIT PARITY INSIDE A NOTE (VX-184 U4 — VX-195; her ruling
// R-VX184-1 at the pre-run sitting, 2026-10-12: "We defined Edit as 'as capable
// as you at the keyboard', we need to make that true"). Twelve acts on the EDIT
// rung, each one of her own doors' row work, run through the SAME extracted
// body her door calls (`rewriteComment`, `reviveCommentRow`, `deleteVariantRows`,
// `deleteBlockRows`, `archiveVariantRows`, `unarchiveVariantRows`,
// `setTakeLabelRows`, `setVariantLockRows`, `restoreCommitRows`,
// `renameCommitRows`, and the lens/title rows), with the server's decision
// handed in as a `WriteGuard` run FIRST inside the act's own write transaction
// (AF-10 (a) — the edit rung's decide/act gap closed, as every edit act).
//
// THE UNDO STORY (the run record's U4 call 1, PROVISIONAL P-VX195-1): every act
// registers exactly ONE client-named entry — R-13n-6 / P-13nb-U2-4's "every MCP
// write is one ⌥⌘Z", carried to the acts her own doors leave off the stack (a
// comment's edit and restore, a label, a lock, a commit's name, a title, a
// lens). Inverses and redos are exact-row from do-time images, never a re-run;
// divergence is QUIET (the world moved past the entry); a seal THROWS and keeps
// the entry. The insurance commits two acts write on the way (`lock_take` on a
// dirty take — her lock's own rule; `restore_commit`'s brackets) STAY when ⌥⌘Z
// walks the act back: commits are append-only (I5), exactly as `edit_take`'s
// brackets stay (P-13nb-U3-2).
//
// These ops decide nothing about clients — who may act is the server's
// per-call rule (`MCPWriteTools+NoteEdits`).
extension Operations {
    /// The two refusals only the wire's own preconditions can meet (the
    /// `MCPBookRuleRefusal` precedent — the wire words them).
    public enum MCPNoteEditRefusal: Error, Equatable, Sendable {
        /// `edit_comment`'s `expected_text` no longer matches the comment.
        case commentChangedSinceRead(commentID: String)
        /// `delete_take`'s road — the take alone, or its block (the take was
        /// the LAST) — is no longer the one the client's read decided.
        case takesChangedSinceRead(takeID: String)
    }

    // MARK: - COMMENTS (R-VX188-1's edit clause: any comment)

    /// What `editCommentForClient` did.
    public struct MCPCommentEdit: Equatable, Sendable {
        public let commentID: String
        public let blockID: String
        /// False when the comment already read as asked — nothing written.
        public let changed: Bool
    }

    /// **`edit_comment`'s act — her comment edit** (`rewriteComment`, her
    /// `editBlockComment`'s body: the comment and its block live, a seal
    /// refuses — #23, blank refuses, the same text writes nothing), with the
    /// wire's precondition: the comment must still read `expectedText` (else
    /// `commentChangedSinceRead` — a stale read writes nothing; P-VX195-2).
    /// The authorship record is untouched (it says who WROTE the comment).
    /// ONE entry: the old text back ONLY while the comment still reads the
    /// act's text (an edit of hers since is hers — quiet), the redo likewise.
    @discardableResult
    public func editCommentForClient(
        _ commentID: String, text: String, expectedText: String, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPCommentEdit {
        let landed: (edit: MCPCommentEdit, previous: String?) = try database.write { db in
            try guardian?(db)
            let previous = try rewriteComment(db, commentID, text: text, expecting: expectedText)
            let comment = try liveComment(db, commentID)
            return (MCPCommentEdit(commentID: commentID, blockID: comment.blockId, changed: previous != nil), previous)
        }
        if let previous = landed.previous {
            undoStack?.register(
                label: undoLabel,
                inverse: { try $0.rewriteCommentIfUnchanged(commentID, from: text, to: previous) },
                redo: { try $0.rewriteCommentIfUnchanged(commentID, from: previous, to: text) })
        }
        return landed.edit
    }

    /// Both halves of the comment-edit entry: `to` written only while the
    /// comment is live on a live block and still reads `from`; a seal refuses
    /// and keeps the entry.
    func rewriteCommentIfUnchanged(_ commentID: String, from: String, to: String) throws {
        try database.write { db in
            guard var comment = try BlockComment.fetchOne(db, key: commentID), comment.deletedAt == nil,
                  comment.text == from,
                  try Block.fetchOne(db, key: comment.blockId)?.deletedAt == nil
            else { return }
            try ensurePlacementUnlocked(db, blockID: comment.blockId)
            comment.text = to
            comment.updatedAt = date.now
            try comment.update(db)
        }
    }

    /// **`restore_comment`'s act — her restore door** (`reviveCommentRow`,
    /// `restoreBlockComment`'s body: a DELETED comment, its block live, a seal
    /// refuses, any purge intent naming it voided — VX-179's belt). Which
    /// deleted comments the door may reach (her block's deleted-comments
    /// surface) is the server's check, in the guard. ONE entry: the comment
    /// deleted again on a fresh stamp (quiet when already gone); the redo
    /// brings it back only while it is deleted on the undo's EXACT stamp.
    @discardableResult
    public func restoreCommentForClient(
        _ commentID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> BlockComment {
        let comment: BlockComment = try database.write { db in
            try guardian?(db)
            try reviveCommentRow(db, commentID)
            return try liveComment(db, commentID)
        }
        let deletedOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                if let stamp = try ops.redeleteComment(commentID) { deletedOn.setValue(stamp) }
            },
            redo: { ops in
                if let stamp = deletedOn.value { try ops.reviveDeletedComment(commentID, deletedOn: stamp) }
            })
        return comment
    }

    // MARK: - TAKES

    /// What `deleteTakeForClient` did.
    public struct MCPTakeDeletion: Equatable, Sendable {
        public let takeID: String
        public let blockID: String
        /// True when the take was its block's LAST — the BLOCK went
        /// (R-VX184-1), by `delete_block`'s road.
        public let wholeBlock: Bool
    }

    /// **I10's "last"**: the take is ACTIVE and its block has no other live
    /// active take — deleting it is not a take operation, it is deleting the
    /// block (AppSpec §5, I10). An archived take is never the last.
    /// The ONE reading of it — `Queries.mcpTakeRoad`, which the wire's
    /// snapshot reads too, so the road decided and the road re-checked can
    /// never drift.
    func isLastActiveTake(_ db: Database, _ variant: Variant) throws -> Bool {
        try Queries.mcpTakeRoad(variant.id, db)?.last ?? false
    }

    /// **`delete_take`'s act.** ONE transaction, the caller's guard first; a
    /// LOCKED take refuses on either road (`lockedVariant` — the lock guards
    /// the take; P-VX195-3); the ROAD the client's read chose (`wholeBlock`) is
    /// re-checked here (`takesChangedSinceRead` when the take stopped or
    /// started being its block's last since — nothing written). Then:
    /// - **the block's LAST take ⇒ the BLOCK** (R-VX184-1): `deleteBlockRows`,
    ///   `delete_block`'s exact road (the block and every take — archived ones
    ///   too — to the tray; I10 holds because the block goes), registered as
    ///   `deleteBlock`'s own entry relabeled `blockUndoLabel`;
    /// - **otherwise her `deleteVariant`** (`deleteVariantRows` — a CHOSEN take
    ///   refuses: choose another first, as at her keyboard; a seal refuses),
    ///   registered as `deleteVariant`'s own entry relabeled `takeUndoLabel`.
    @discardableResult
    public func deleteTakeForClient(
        _ variantID: String, wholeBlock: Bool, takeUndoLabel: String, blockUndoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPTakeDeletion {
        let landed: (deletion: MCPTakeDeletion, wasDefault: Bool) = try database.write { db in
            try guardian?(db)
            let take = try liveVariant(db, variantID)
            guard !take.locked else { throw OperationError.lockedVariant(id: variantID) }
            guard try isLastActiveTake(db, take) == wholeBlock else {
                throw MCPNoteEditRefusal.takesChangedSinceRead(takeID: variantID)
            }
            if wholeBlock {
                try deleteBlockRows(db, take.blockId, quietWhenGone: false, requiring: .none)
                return (MCPTakeDeletion(takeID: variantID, blockID: take.blockId, wholeBlock: true), false)
            }
            let wasDefault = try deleteVariantRows(db, variantID, quietWhenGone: false) ?? false
            return (MCPTakeDeletion(takeID: variantID, blockID: take.blockId, wholeBlock: false), wasDefault)
        }
        let blockID = landed.deletion.blockID
        if landed.deletion.wholeBlock {
            undoStack?.register(
                label: blockUndoLabel,
                inverse: { try $0.revertDeleteBlock(blockID) },
                redo: { try $0.performDeleteBlock(blockID, quietWhenGone: true, requiring: .none) })
        } else {
            let wasDefault = landed.wasDefault
            undoStack?.register(
                label: takeUndoLabel,
                inverse: { try $0.revertDeleteVariant(variantID, wasDefault: wasDefault) },
                redo: { _ = try $0.performDeleteVariant(variantID, quietWhenGone: true) })
        }
        return landed.deletion
    }

    /// **`archive_take`'s act — her `archiveVariant`** (`archiveVariantRows`:
    /// the LAST active take refuses — I10, never turned into a delete; a
    /// chosen take may be archived, the default renders; a seal refuses; an
    /// archived take changes nothing). Her own entry, relabeled. Returns
    /// whether it wrote.
    @discardableResult
    public func archiveTakeForClient(
        _ variantID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> Bool {
        let wasDefault: Bool? = try database.write { db in
            try guardian?(db)
            return try archiveVariantRows(db, variantID, quietWhenGone: false)
        }
        guard let wasDefault else { return false }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertArchiveVariant(variantID, wasDefault: wasDefault) },
            redo: { _ = try $0.performArchiveVariant(variantID, quietWhenGone: true) })
        return true
    }

    /// **`unarchive_take`'s act — her `unarchiveVariant`** (back into the
    /// fan; a seal refuses; an active take changes nothing). ONE entry: the
    /// take archived again through `archiveVariant`'s row work (quiet when
    /// gone; I10 or a seal refuses and keeps the entry), the redo back into
    /// the fan. Returns whether it wrote.
    @discardableResult
    public func unarchiveTakeForClient(
        _ variantID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> Bool {
        let changed = try database.write { db in
            try guardian?(db)
            return try unarchiveVariantRows(db, variantID)
        }
        guard changed else { return false }
        undoStack?.register(
            label: undoLabel,
            inverse: { _ = try $0.performArchiveVariant(variantID, quietWhenGone: true) },
            redo: { try $0.unarchiveTakeQuietly(variantID) })
        return true
    }

    /// The unarchive entry's redo: back into the fan, quiet when the take is
    /// gone; a seal refuses and keeps the entry.
    func unarchiveTakeQuietly(_ variantID: String) throws {
        try database.write { db in
            guard let take = try Variant.fetchOne(db, key: variantID), take.deletedAt == nil else { return }
            _ = try unarchiveVariantRows(db, variantID)
        }
    }

    /// What `labelTakeForClient` did.
    public struct MCPTakeLabel: Equatable, Sendable {
        public let takeID: String
        public let blockID: String
        /// The label as stored now (nil = none).
        public let label: String?
        public let changed: Bool
    }

    /// **`set_take_label`'s act — her `setTakeLabel`** (`setTakeLabelRows`:
    /// trimmed, nil/blank clears, the same label writes nothing, a seal
    /// refuses, a locked or archived take allowed). As given — no client
    /// stamp (P-VX195-5). ONE entry restoring the previous label exactly.
    @discardableResult
    public func labelTakeForClient(
        _ variantID: String, label: String?, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPTakeLabel {
        let landed: (label: MCPTakeLabel, previous: String??) = try database.write { db in
            try guardian?(db)
            let previous = try setTakeLabelRows(db, variantID, label: label)
            let take = try liveVariant(db, variantID)
            return (MCPTakeLabel(takeID: variantID, blockID: take.blockId, label: take.label, changed: previous != nil),
                    previous)
        }
        if case .some(let old) = landed.previous {
            let new = landed.label.label
            undoStack?.register(
                label: undoLabel,
                inverse: { try $0.restoreTakeLabel(variantID, to: old) },
                redo: { try $0.restoreTakeLabel(variantID, to: new) })
        }
        return landed.label
    }

    /// Both halves of the label entry: quiet when the take is gone, a seal
    /// refuses and keeps the entry.
    func restoreTakeLabel(_ variantID: String, to label: String?) throws {
        try database.write { db in
            guard var take = try Variant.fetchOne(db, key: variantID), take.deletedAt == nil else { return }
            try ensurePlacementUnlocked(db, blockID: take.blockId)
            guard take.label != label else { return }
            take.label = label
            take.updatedAt = date.now
            try take.update(db)
        }
    }

    /// What `lockTakeForClient` did.
    public struct MCPTakeLock: Equatable, Sendable {
        public let takeID: String
        public let blockID: String
        public let locked: Bool
        public let changed: Bool
        /// Her lock's insurance: the commit of a take's unsaved words, made
        /// before it locked.
        public let insured: CommitPoint?
    }

    /// **`lock_take` / `unlock_take`'s act — her `lockVariant` /
    /// `unlockVariant`** (`setVariantLockRows`: a dirty take insured by one
    /// quiet auto commit before it locks; a seal refuses; the same state
    /// changes nothing). ONE entry toggling it back (quiet when gone; a seal
    /// refuses and keeps it); the insurance commit STAYS (I5).
    @discardableResult
    public func lockTakeForClient(
        _ variantID: String, locked: Bool, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPTakeLock {
        let landed: MCPTakeLock = try database.write { db in
            try guardian?(db)
            let result = try setVariantLockRows(db, variantID, locked: locked)
            let take = try liveVariant(db, variantID)
            return MCPTakeLock(
                takeID: variantID, blockID: take.blockId, locked: take.locked, changed: result.changed,
                insured: result.insured)
        }
        if landed.changed {
            undoStack?.register(
                label: undoLabel,
                inverse: { try $0.setTakeLockQuietly(variantID, locked: !locked) },
                redo: { try $0.setTakeLockQuietly(variantID, locked: locked) })
        }
        return landed
    }

    /// Both halves of the lock entry.
    func setTakeLockQuietly(_ variantID: String, locked: Bool) throws {
        try database.write { db in
            guard let take = try Variant.fetchOne(db, key: variantID), take.deletedAt == nil else { return }
            _ = try setVariantLockRows(db, variantID, locked: locked)
        }
    }

    // MARK: - COMMITS

    /// `restore_commit`'s two insurance commits' names — THE CLIENT'S NAME,
    /// verbatim (`mcpEditCommitNames`' style). 13s-a sweepable.
    public static func mcpRestoreCommitNames(client: String) -> (before: String, after: String) {
        ("before \(client)'s restore", "after \(client)'s restore")
    }

    /// What `restoreCommitForClient` did.
    public struct MCPCommitRestore: Equatable, Sendable {
        public let take: Variant
        /// "before <client>'s restore" — nil when the take's last commit
        /// already held the text it replaced (the standing dedupe).
        public let before: CommitPoint?
        /// "after <client>'s restore".
        public let after: CommitPoint?
        /// False when the take already read the commit's words.
        public let changed: Bool
    }

    /// **`restore_commit`'s act — her `restoreCommit`, INSURED** (the run
    /// record's call 6, P-VX195-4). ONE transaction: the caller's guard first;
    /// the commit's take must be editable (`editableVariant`: live, active,
    /// unlocked, unsealed); a take already reading the commit's words writes
    /// nothing. Then the eighth occasion's bracket around her row work: a
    /// `kind='auto'` commit "before <client>'s restore" of the text it is
    /// about to replace (deduped — none when the take's last commit holds it),
    /// `restoreCommitRows` (her body — the churn hers exactly), and "after
    /// <client>'s restore" of the restored text, stamped one millisecond later
    /// so the history reads before → after. Her own road writes no savepoint
    /// (it flushes her editor's pending keystrokes first — the wire has none to
    /// flush); the client's insures what would otherwise be reachable only by
    /// ⌥⌘Z while the session lives. ONE entry: the buffer back to its
    /// pre-restore text (the fourth occasion insures a buffer she edited
    /// since), the redo the restore again — exact pre-images. The brackets stay.
    @discardableResult
    public func restoreCommitForClient(
        _ commitID: String, client: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPCommitRestore {
        let names = Self.mcpRestoreCommitNames(client: client)
        let landed: (restore: MCPCommitRestore, preImage: TextPreImage?) = try database.write { db in
            try guardian?(db)
            guard let commitPoint = try CommitPoint.fetchOne(db, key: commitID) else {
                throw OperationError.commitNotFound(id: commitID)
            }
            let variant = try editableVariant(db, commitPoint.variantId)
            guard variant.workingText != commitPoint.text else {
                return (MCPCommitRestore(take: variant, before: nil, after: nil, changed: false), nil)
            }
            let now = date.now
            let before = try isDirty(db, variant)
                ? try insertCommit(db, variant: variant, kind: .auto, message: names.before, now: now)
                : nil
            guard let written = try restoreCommitRows(db, variant.id, commitID: commitID) else {
                return (MCPCommitRestore(take: variant, before: before, after: nil, changed: false), nil)
            }
            let restored = try liveVariant(db, variant.id)
            let after = try isDirty(db, restored)
                ? try insertCommit(
                    db, variant: restored, kind: .auto, message: names.after, now: now.addingTimeInterval(0.001))
                : nil
            return (MCPCommitRestore(take: restored, before: before, after: after, changed: true),
                    TextPreImage(variantID: variant.id, text: written.old, postOpText: written.new))
        }
        if let preImage = landed.preImage {
            undoStack?.register(
                label: undoLabel,
                inverse: {
                    try $0.revertStructural(
                        restoringTexts: [preImage], tombstoningBlocks: [], revivingPlacementRows: [])
                },
                redo: {
                    try $0.reapplyStructural(
                        restoringTexts: [preImage], untombstoningBlocks: [], releasingPlacementRows: [])
                },
                insuring: [preImage])
        }
        return landed.restore
    }

    /// What `renameCommitForClient` did.
    public struct MCPCommitRename: Equatable, Sendable {
        public let commitID: String
        public let takeID: String
        /// The message as stored now (nil = unnamed).
        public let message: String?
        public let changed: Bool
    }

    /// **`rename_commit`'s act — her `renameCommitPoint` exactly**
    /// (`renameCommitRows`: the seal checked FIRST, then the no-op; nil/blank
    /// clears through `SavepointName`; a locked or archived take ALLOWED —
    /// QUESTIONS #121; the text is never touched — I5). The message as given
    /// (P-VX195-5). ONE entry restoring the previous message exactly.
    @discardableResult
    public func renameCommitForClient(
        _ commitID: String, message: String?, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPCommitRename {
        let landed: (rename: MCPCommitRename, previous: String??) = try database.write { db in
            try guardian?(db)
            let previous = try renameCommitRows(db, commitID, message: message)
            let commitPoint = try CommitPoint.fetchOne(db, key: commitID)
            return (MCPCommitRename(
                commitID: commitID, takeID: commitPoint?.variantId ?? "", message: commitPoint?.message,
                changed: previous != nil), previous)
        }
        if case .some(let old) = landed.previous {
            let new = landed.rename.message
            undoStack?.register(
                label: undoLabel,
                inverse: { try $0.restoreCommitMessage(commitID, to: old) },
                redo: { try $0.restoreCommitMessage(commitID, to: new) })
        }
        return landed.rename
    }

    /// Both halves of the commit-name entry: quiet when the commit's take is
    /// gone; a seal refuses and keeps the entry.
    func restoreCommitMessage(_ commitID: String, to message: String?) throws {
        try database.write { db in
            guard var commitPoint = try CommitPoint.fetchOne(db, key: commitID),
                  let take = try Variant.fetchOne(db, key: commitPoint.variantId), take.deletedAt == nil
            else { return }
            try ensurePlacementUnlocked(db, blockID: take.blockId)
            guard commitPoint.message != message else { return }
            commitPoint.message = message
            try commitPoint.update(db)
        }
    }

    // MARK: - THE NOTE

    /// What `renameNoteForClient` did.
    public struct MCPNoteRename: Equatable, Sendable {
        public let noteID: String
        /// The title as stored now (nil = untitled).
        public let title: String?
        public let changed: Bool
    }

    /// **`rename_note`'s act — her title doors** (`renameContainer` as her
    /// two title fields call it: trimmed, a blank title stored as none — her
    /// fields' own rule; on a live NOTE; a title is library metadata, so a
    /// SEAL does not freeze it — `updateFloatingNotes`' doc, her op's posture).
    /// No-op-guarded (the metadata setters' convention). ONE entry restoring
    /// the previous title exactly.
    @discardableResult
    public func renameNoteForClient(
        _ postID: String, title: String?, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPNoteRename {
        let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = (trimmed?.isEmpty ?? true) ? nil : trimmed
        let previous: String?? = try database.write { db in
            try guardian?(db)
            var post = try livePost(db, postID)
            guard post.title != normalized else { return nil }
            let old = post.title
            post.title = normalized
            post.updatedAt = date.now
            try post.update(db)
            return .some(old)
        }
        guard case .some(let old) = previous else {
            return MCPNoteRename(noteID: postID, title: normalized, changed: false)
        }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.restoreNoteTitle(postID, to: old) },
            redo: { try $0.restoreNoteTitle(postID, to: normalized) })
        return MCPNoteRename(noteID: postID, title: normalized, changed: true)
    }

    /// Both halves of the title entry: quiet when the note is gone.
    func restoreNoteTitle(_ postID: String, to title: String?) throws {
        try database.write { db in
            guard var post = try Container.fetchOne(db, key: postID), post.deletedAt == nil,
                  post.title != title
            else { return }
            post.title = title
            post.updatedAt = date.now
            try post.update(db)
        }
    }

    /// **`delete_lens`'s act — her `deleteLens`** (the lens tombstoned, its
    /// picks dying on the same stamp by trigger; the note and its chosen takes
    /// untouched; allowed under a seal — lens CRUD's posture). ONE entry: the
    /// lens back with exactly the picks that died on its stamp (`save_lens`'s
    /// own machinery), the redo deleting it again on a fresh stamp.
    @discardableResult
    public func deleteLensForClient(
        _ lensID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> Lens {
        let (lens, stamp): (Lens, String) = try database.write { db in
            try guardian?(db)
            let lens = try liveLens(db, lensID)
            guard let stamp = try tombstoneSavedLens(db, lensID) else { throw OperationError.lensNotFound(id: lensID) }
            return (lens, stamp)
        }
        let deletedOn = LockIsolated(stamp)
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.reapplySavedLens(lensID, undoneOn: deletedOn.value) },
            redo: { ops in
                if let stamp = try ops.revertSavedLens(lensID) { deletedOn.setValue(stamp) }
            })
        return lens
    }
}

extension Queries {
    /// **The note a commit's take lives in** (VX-195 — `restore_commit` /
    /// `rename_commit`'s address): its take live, its block live-placed in a
    /// note now — else nil (the one-answer refusal, decided on the note).
    public static func mcpContainerOf(commit commitID: String, _ db: Database) throws -> String? {
        guard let takeID = try String.fetchOne(
            db, sql: "SELECT variant_id FROM commit_point WHERE id = ?", arguments: [commitID])
        else { return nil }
        return try mcpContainerOf(take: takeID, db)
    }

    /// **The note a comment's block is live-placed in, the comment live OR
    /// DELETED** (VX-195 — `restore_comment`'s address; a live comment answers
    /// too, so her restore's own "not deleted" refusal speaks — `put_back`'s
    /// precedent). Nil for an id naming nothing or a comment whose block is
    /// gone or unplaced.
    public static func mcpCommentHome(_ commentID: String, _ db: Database) throws -> String? {
        try String.fetchOne(
            db,
            sql: """
                SELECT cb.container_id FROM block_comment c
                JOIN block b ON b.id = c.block_id AND b.deleted_at IS NULL
                JOIN container_block cb ON cb.block_id = c.block_id AND cb.deleted_at IS NULL
                WHERE c.id = ?
                """,
            arguments: [commentID])
    }

    /// **Is this deleted comment on her block's deleted-comments surface?**
    /// (VX-195 — `restore_comment` reaches only what her own restore door
    /// offers: `deletedBlockComments`' population EXACTLY — a comment given
    /// "Delete forever…" is off it.) ∝ the block's deleted comments.
    public static func mcpCommentIsRestorable(_ commentID: String, _ db: Database) throws -> Bool {
        guard let blockID = try String.fetchOne(
            db, sql: "SELECT block_id FROM block_comment WHERE id = ? AND deleted_at IS NOT NULL",
            arguments: [commentID])
        else { return false }
        return try deletedBlockComments(db, blockID: blockID).contains { $0.id == commentID }
    }

    /// **`delete_take`'s road, read** (VX-195): the take's block, and whether
    /// the take is its block's LAST live active take (I10's "last" — then the
    /// BLOCK goes, R-VX184-1). Nil for a take that is not live.
    public static func mcpTakeRoad(_ takeID: String, _ db: Database) throws -> (blockID: String, last: Bool)? {
        guard let row = try Row.fetchOne(
            db, sql: "SELECT block_id, status FROM variant WHERE id = ? AND deleted_at IS NULL", arguments: [takeID])
        else { return nil }
        let blockID: String = row["block_id"]
        guard (row["status"] as String) == VariantStatus.active.rawValue else { return (blockID, false) }
        let others = try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM variant
                WHERE block_id = ? AND id <> ? AND deleted_at IS NULL AND status = 'active'
                """,
            arguments: [blockID, takeID]) ?? 0
        return (blockID, others == 0)
    }
}
