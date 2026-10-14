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
        case deleteTake(takeID: String)
        case archiveTake(takeID: String)
        case unarchiveTake(takeID: String)
        case setTakeLabel(takeID: String, label: String?)
        case lockTake(takeID: String, locked: Bool)
        case restoreCommit(commitID: String)
        case renameCommit(commitID: String, message: String?)
        case renameNote(noteID: String, title: String?)
        case deleteLens(lensID: String)

        var tool: String {
            switch self {
            case .editComment: MCPToolCatalog.editComment.name
            case .restoreComment: MCPToolCatalog.restoreComment.name
            case .deleteTake: MCPToolCatalog.deleteTake.name
            case .archiveTake: MCPToolCatalog.archiveTake.name
            case .unarchiveTake: MCPToolCatalog.unarchiveTake.name
            case .setTakeLabel: MCPToolCatalog.setTakeLabel.name
            case .lockTake(_, let locked): locked ? MCPToolCatalog.lockTake.name : MCPToolCatalog.unlockTake.name
            case .restoreCommit: MCPToolCatalog.restoreCommit.name
            case .renameCommit: MCPToolCatalog.renameCommit.name
            case .renameNote: MCPToolCatalog.renameNote.name
            case .deleteLens: MCPToolCatalog.deleteLens.name
            }
        }

        /// VX-275 (`Job.flushesHerEditorFirst`): the note-edit acts that meet
        /// her take's text.
        var flushesHerEditorFirst: Bool {
            switch self {
            // TOMBSTONE: the take (or, its block's last, the block) dies.
            case .deleteTake: true
            // FREEZE: an archived take refuses her flush as a dead one does.
            case .archiveTake: true
            // FREEZE: a locked take refuses her flush; its insurance commit
            // must hold what she typed. Unlocking freezes nothing.
            case .lockTake(_, let locked): locked
            // REWRITE: the restore writes the commit over the STORED row, and
            // its "before" commit insures what it replaces.
            case .restoreCommit: true
            // Comments, labels, commit names, the title and lenses: drafts or
            // metadata, never the take's text.
            case .editComment, .restoreComment, .unarchiveTake, .setTakeLabel, .renameCommit, .renameNote,
                 .deleteLens:
                false
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

    /// `delete_take`'s road moved under the client's read (the take stopped
    /// or started being its block's last).
    static let takesChangedWords =
        "That block's takes changed since you read them \u{2014} nothing was deleted. Read the note again "
        + "and decide on what it holds now."

    /// The receipt's detail on a block deleted by its LAST take (R-VX184-1 —
    /// `delete_block`'s act, said why).
    static let lastTakeDetail = "its last take"

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
        case MCPToolCatalog.deleteTake.name:
            return .deleteTake(takeID: try requiredString(args, "take_id"))
        case MCPToolCatalog.archiveTake.name:
            return .archiveTake(takeID: try requiredString(args, "take_id"))
        case MCPToolCatalog.unarchiveTake.name:
            return .unarchiveTake(takeID: try requiredString(args, "take_id"))
        case MCPToolCatalog.setTakeLabel.name:
            guard args.keys.contains("label") else {
                throw ArgumentFailure(message: "label is required: the take's label, or null to clear it.")
            }
            return .setTakeLabel(takeID: try requiredString(args, "take_id"), label: try optionalString(args, "label"))
        case MCPToolCatalog.lockTake.name:
            return .lockTake(takeID: try requiredString(args, "take_id"), locked: true)
        case MCPToolCatalog.unlockTake.name:
            return .lockTake(takeID: try requiredString(args, "take_id"), locked: false)
        case MCPToolCatalog.restoreCommit.name:
            return .restoreCommit(commitID: try requiredString(args, "commit_id"))
        case MCPToolCatalog.renameCommit.name:
            guard args.keys.contains("message") else {
                throw ArgumentFailure(message: "message is required: the commit's new name, or null to clear it.")
            }
            return .renameCommit(commitID: try requiredString(args, "commit_id"), message: try optionalString(args, "message"))
        case MCPToolCatalog.renameNote.name:
            guard args.keys.contains("title") else {
                throw ArgumentFailure(message: "title is required: the note's new title, or null to clear it.")
            }
            return .renameNote(noteID: try requiredString(args, "note_id"), title: try optionalString(args, "title"))
        case MCPToolCatalog.deleteLens.name:
            return .deleteLens(lensID: try requiredString(args, "lens_id"))
        default:
            return nil
        }
    }

    /// The block a take belongs to (its row, whatever its state).
    func blockOf(take takeID: String) throws -> String? {
        try database.read { db in
            try String.fetchOne(db, sql: "SELECT block_id FROM variant WHERE id = ?", arguments: [takeID])
        }
    }

    /// A take act's in-transaction decision: the take's note re-resolved on
    /// the act's own rows, decided at EDIT.
    func guardTake(_ clientName: String, _ takeID: String) -> Operations.WriteGuard {
        guardEdit(clientName) { db in [try Queries.mcpContainerOf(take: takeID, db)] }
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

        case .deleteTake(let takeID):
            // The ROAD is read here and re-checked inside the act: a block's
            // LAST take deletes the BLOCK (R-VX184-1) — logged on the block,
            // so Activity says the block went.
            let (home, road) = try database.read { db in
                (try Queries.mcpContainerOf(take: takeID, db), try Queries.mcpTakeRoad(takeID, db))
            }
            let wholeBlock = road?.last ?? false
            let logged = wholeBlock && home != nil ? ("block", road?.blockID ?? "") : ("take", takeID)
            return try onNote(home ?? "", rung: .edit, job: job, clientName: clientName,
                              logged: logged, spendsAfter: false) { title in
                let noteID = home ?? ""
                let deletion: Operations.MCPTakeDeletion
                do {
                    deletion = try ops.deleteTakeForClient(
                        takeID, wholeBlock: wholeBlock, takeUndoLabel: label(.takeDelete),
                        blockUndoLabel: label(.delete), guardedBy: guardTake(clientName, takeID))
                } catch Operations.MCPNoteEditRefusal.takesChangedSinceRead {
                    throw Refused(outcome: Outcome(text: Self.takesChangedWords, isError: true))
                }
                return (["take_id": takeID, "block_id": deletion.blockID, "note_id": noteID, "deleted": true,
                         "deleted_block": deletion.wholeBlock],
                        deletion.wholeBlock
                        ? MCPWriteReceipt(clientName: clientName, act: .delete, targetID: noteID, targetTitle: title,
                                          detail: Self.lastTakeDetail,
                                          show: .note(noteID: noteID, blockID: nil, select: nil))
                        : MCPWriteReceipt(clientName: clientName, act: .takeDelete, targetID: noteID,
                                          targetTitle: title, show: .takes(noteID: noteID, blockID: deletion.blockID)))
            }

        case .archiveTake(let takeID), .unarchiveTake(let takeID):
            let archiving: Bool = if case .archiveTake = edit { true } else { false }
            let noteID = try database.read { try Queries.mcpContainerOf(take: takeID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("take", takeID), spendsAfter: false) { title in
                let act: Operations.MCPWriteAct = archiving ? .takeArchive : .takeUnarchive
                let changed = archiving
                    ? try ops.archiveTakeForClient(takeID, undoLabel: label(act), guardedBy: guardTake(clientName, takeID))
                    : try ops.unarchiveTakeForClient(takeID, undoLabel: label(act), guardedBy: guardTake(clientName, takeID))
                let blockID = try blockOf(take: takeID) ?? ""
                return (["take_id": takeID, "block_id": blockID, "note_id": noteID, "archived": archiving,
                         "changed": changed],
                        changed
                        ? MCPWriteReceipt(clientName: clientName, act: act, targetID: noteID, targetTitle: title,
                                          show: .takes(noteID: noteID, blockID: blockID))
                        : nil)
            }

        case .setTakeLabel(let takeID, let takeLabel):
            let noteID = try database.read { try Queries.mcpContainerOf(take: takeID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("take", takeID), spendsAfter: false) { title in
                let result = try ops.labelTakeForClient(
                    takeID, label: takeLabel, undoLabel: label(.takeLabel), guardedBy: guardTake(clientName, takeID))
                return (["take_id": takeID, "block_id": result.blockID, "note_id": noteID,
                         "label": result.label ?? NSNull(), "changed": result.changed],
                        result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .takeLabel, targetID: noteID, targetTitle: title,
                                          detail: result.label,
                                          show: .takes(noteID: noteID, blockID: result.blockID))
                        : nil)
            }

        case .lockTake(let takeID, let locked):
            let noteID = try database.read { try Queries.mcpContainerOf(take: takeID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("take", takeID), spendsAfter: false) { title in
                let act: Operations.MCPWriteAct = locked ? .takeLock : .takeUnlock
                let result = try ops.lockTakeForClient(
                    takeID, locked: locked, undoLabel: label(act), guardedBy: guardTake(clientName, takeID))
                var answer: [String: Any] = [
                    "take_id": takeID, "block_id": result.blockID, "note_id": noteID, "locked": result.locked,
                    "changed": result.changed,
                ]
                if let insured = result.insured { answer["insured_commit_id"] = insured.id }
                return (answer, result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: act, targetID: noteID, targetTitle: title,
                                          show: .takes(noteID: noteID, blockID: result.blockID))
                        : nil)
            }

        case .restoreCommit(let commitID):
            let noteID = try database.read { try Queries.mcpContainerOf(commit: commitID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("commit", commitID), spendsAfter: false) { title in
                let result = try ops.restoreCommitForClient(
                    commitID, client: clientName, undoLabel: label(.commitRestore),
                    guardedBy: guardEdit(clientName) { db in [try Queries.mcpContainerOf(commit: commitID, db)] })
                var answer: [String: Any] = [
                    "commit_id": commitID, "take_id": result.take.id, "block_id": result.take.blockId,
                    "note_id": noteID, "changed": result.changed,
                ]
                if let before = result.before { answer["before_commit_id"] = before.id }
                if let after = result.after { answer["after_commit_id"] = after.id }
                return (answer, result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .commitRestore, targetID: noteID,
                                          targetTitle: title,
                                          show: .note(noteID: noteID, blockID: result.take.blockId, select: nil))
                        : nil)
            }

        case .renameCommit(let commitID, let message):
            let noteID = try database.read { try Queries.mcpContainerOf(commit: commitID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("commit", commitID), spendsAfter: false) { title in
                let result = try ops.renameCommitForClient(
                    commitID, message: message, undoLabel: label(.commitRename),
                    guardedBy: guardEdit(clientName) { db in [try Queries.mcpContainerOf(commit: commitID, db)] })
                let blockID = try blockOf(take: result.takeID)
                return (["commit_id": commitID, "take_id": result.takeID, "note_id": noteID,
                         "message": result.message ?? NSNull(), "changed": result.changed],
                        result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .commitRename, targetID: noteID,
                                          targetTitle: title, detail: result.message,
                                          show: .note(noteID: noteID, blockID: blockID, select: nil))
                        : nil)
            }

        case .renameNote(let noteID, let newTitle):
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { title in
                let result = try ops.renameNoteForClient(
                    noteID, title: newTitle, undoLabel: label(.noteTitle),
                    guardedBy: guardEdit(clientName) { _ in [noteID] })
                // The receipt and the activity line name the note as it now
                // reads (an untitled note reads by its display title).
                let shown = try database.read { db in
                    try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar)
                } ?? title
                return (["note_id": noteID, "title": result.title ?? NSNull(), "changed": result.changed],
                        result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .noteTitle, targetID: noteID,
                                          targetTitle: shown, detail: result.title,
                                          show: .note(noteID: noteID, blockID: nil, select: nil))
                        : nil)
            }

        case .deleteLens(let lensID):
            let noteID = try database.read { try Queries.mcpContainerOf(lens: lensID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("lens", lensID), spendsAfter: false) { title in
                let lens = try ops.deleteLensForClient(
                    lensID, undoLabel: label(.lensDelete),
                    guardedBy: guardEdit(clientName) { db in [try Queries.mcpContainerOf(lens: lensID, db)] })
                return (["lens_id": lensID, "note_id": noteID, "deleted": true],
                        MCPWriteReceipt(clientName: clientName, act: .lensDelete, targetID: noteID, targetTitle: title,
                                        detail: lens.name, show: .note(noteID: noteID, blockID: nil, select: nil)))
            }
        }
    }
}
