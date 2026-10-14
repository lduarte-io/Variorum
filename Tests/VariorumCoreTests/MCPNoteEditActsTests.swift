import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-184 U4 — VX-195's TWELVE ACTS (`Operations+MCPNoteEdits`): exact state
// transitions, each act HER door's row work through the SAME extracted body her
// door calls, the caller's guard FIRST inside the act's own transaction, and ONE
// client-named entry whose inverse and redo round-trip the same rows. Who may
// act is the server's per-call rule (the `MCP*EditServerTests`). Her own doors'
// suites run UNMODIFIED as the extractions' parity proof.

private struct GuardRefused: Error, Equatable {}

@Suite("VX-195 — edit parity inside a note: the acts")
struct MCPNoteEditActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    private let refuse: Operations.WriteGuard = { _ in throw GuardRefused() }

    /// A note: block 1 fanned (her chosen take + a second take), block 2 one
    /// take, block 3 one active take and one archived; a comment of hers on
    /// block 1; a lens showing the second take; a commit of block 1's take.
    private struct World {
        let noteID: String
        let block1: String
        let hers1: String
        let other1: String
        let block2: String
        let hers2: String
        let block3: String
        let hers3: String
        let archived3: String
        let commentID: String
        let lensID: String
        let commitID: String
    }

    private func world(_ ops: Operations) throws -> World {
        let note = try ops.createPost(title: "ch 1")
        let one = try ops.seedBlock(in: note.id, text: "Her opening.")
        let commit = try ops.commit(one.variant.id, message: "first")
        try ops.autosave(one.variant.id, text: "Her opening, revised.", charDelta: 9)
        let other = try ops.branchVariant(one.block.id, from: one.variant.id)
        try ops.autosave(other.id, text: "A bolder opening.", charDelta: 4)
        let two = try ops.seedBlock(in: note.id, text: "Her close.")
        let three = try ops.seedBlock(in: note.id, text: "Her coda.")
        let old = try ops.branchVariant(three.block.id, from: three.variant.id)
        try ops.archiveVariant(old.id)
        let comment = try ops.addBlockComment(to: one.block.id, text: "Her note.")
        let lens = try ops.createLens(post: note.id, name: "the bold cut")
        _ = try ops.setLensChoice(lens: lens.id, block: one.block.id, variant: other.id)
        return World(noteID: note.id, block1: one.block.id, hers1: one.variant.id, other1: other.id,
                     block2: two.block.id, hers2: two.variant.id, block3: three.block.id, hers3: three.variant.id,
                     archived3: old.id, commentID: comment.id, lensID: lens.id, commitID: commit.id)
    }

    // MARK: - Every act: the guard first, nothing written when it refuses

    @Test func everyActRunsTheGuardFirstAndARefusalWritesNothing() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            try ops.deleteBlockComment(w.commentID)
            let deleted = try ops.addBlockComment(to: w.block1, text: "Another.")
            try ops.restoreBlockComment(w.commentID)
            try ops.deleteBlockComment(deleted.id)
            stack.removeAll()
            let tables = ["block", "variant", "block_comment", "commit_point", "lens", "lens_choice", "container"]
            func snapshot() throws -> [String] {
                try db.read { db in
                    try tables.flatMap { try Row.fetchAll(db, sql: "SELECT * FROM \($0) ORDER BY id").map(\.description) }
                }
            }
            let before = try snapshot()
            let acts: [(String, () throws -> Void)] = [
                ("edit", { _ = try ops.editCommentForClient(w.commentID, text: "x", expectedText: "Her note.",
                                                           undoLabel: "x", guardedBy: refuse) }),
                ("restore comment", { _ = try ops.restoreCommentForClient(deleted.id, undoLabel: "x", guardedBy: refuse) }),
                ("delete take", { _ = try ops.deleteTakeForClient(w.other1, wholeBlock: false, takeUndoLabel: "x",
                                                                  blockUndoLabel: "x", guardedBy: refuse) }),
                ("delete last", { _ = try ops.deleteTakeForClient(w.hers2, wholeBlock: true, takeUndoLabel: "x",
                                                                  blockUndoLabel: "x", guardedBy: refuse) }),
                ("archive", { _ = try ops.archiveTakeForClient(w.other1, undoLabel: "x", guardedBy: refuse) }),
                ("unarchive", { _ = try ops.unarchiveTakeForClient(w.archived3, undoLabel: "x", guardedBy: refuse) }),
                ("label", { _ = try ops.labelTakeForClient(w.other1, label: "x", undoLabel: "x", guardedBy: refuse) }),
                ("lock", { _ = try ops.lockTakeForClient(w.other1, locked: true, undoLabel: "x", guardedBy: refuse) }),
                ("restore commit", { _ = try ops.restoreCommitForClient(w.commitID, client: client, undoLabel: "x",
                                                                      guardedBy: refuse) }),
                ("rename commit", { _ = try ops.renameCommitForClient(w.commitID, message: "x", undoLabel: "x",
                                                                    guardedBy: refuse) }),
                ("rename note", { _ = try ops.renameNoteForClient(w.noteID, title: "x", undoLabel: "x", guardedBy: refuse) }),
                ("delete lens", { _ = try ops.deleteLensForClient(w.lensID, undoLabel: "x", guardedBy: refuse) }),
            ]
            for (name, act) in acts {
                #expect(throws: GuardRefused.self, "\(name)") { try act() }
            }
            #expect(try snapshot() == before, "a refused guard writes nothing, anywhere")
            #expect(stack.depth == 0)
        }
    }

    // MARK: - Comments

    @Test func aCommentEditIsHerEditWithAStaleReadRefusedAndAQuietUndoOverHerLaterEdit() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            stack.removeAll()
            let text = { try db.fetchString("SELECT text FROM block_comment WHERE id = ?", [w.commentID]) }
            #expect(throws: Operations.MCPNoteEditRefusal.commentChangedSinceRead(commentID: w.commentID)) {
                _ = try ops.editCommentForClient(w.commentID, text: "x", expectedText: "stale", undoLabel: "x")
            }
            #expect(throws: OperationError.invalidCommentText) {
                _ = try ops.editCommentForClient(w.commentID, text: " ", expectedText: "Her note.", undoLabel: "x")
            }
            let edit = try ops.editCommentForClient(
                w.commentID, text: "Her note, tightened.", expectedText: "Her note.", undoLabel: label(.commentEdit))
            #expect(edit.changed && edit.blockID == w.block1)
            #expect(try text() == "Her note, tightened.")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's comment edit")
            let same = try ops.editCommentForClient(
                w.commentID, text: "Her note, tightened.", expectedText: "Her note, tightened.", undoLabel: "x")
            #expect(!same.changed && stack.depth == 1, "the same text: nothing written, nothing registered")
            #expect(try stack.undo(with: ops) == "claude-code's comment edit")
            #expect(try text() == "Her note.")
            #expect(try stack.redo(with: ops) == "claude-code's comment edit")
            #expect(try text() == "Her note, tightened.")
            // She edits it after the act: the entry's undo leaves HER edit alone.
            try ops.editBlockComment(w.commentID, text: "Her own last word.")
            _ = try stack.undo(with: ops)
            #expect(try text() == "Her own last word.", "an edit of hers since is hers")
        }
    }

    @Test func aCommentRestoreIsHerRestoreAndItsUndoDeletesItAgain() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            try ops.deleteBlockComment(w.commentID)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: w.commentID)])
            stack.removeAll()
            _ = try ops.restoreCommentForClient(w.commentID, undoLabel: label(.commentRestore))
            #expect(try db.deletedAt("block_comment", w.commentID) == nil)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM purge_intent WHERE row_id = ? AND deleted_at IS NULL", [w.commentID]) == 0,
                    "her restore's belt rides: any intent naming it is voided")
            #expect(throws: OperationError.commentNotDeleted(id: w.commentID)) {
                _ = try ops.restoreCommentForClient(w.commentID, undoLabel: "x")
            }
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's comment restore")
            #expect(try stack.undo(with: ops) == "claude-code's comment restore")
            #expect(try db.deletedAt("block_comment", w.commentID) != nil)
            #expect(try stack.redo(with: ops) == "claude-code's comment restore")
            #expect(try db.deletedAt("block_comment", w.commentID) == nil)
        }
    }

    // MARK: - Takes

    @Test func deletingATakeIsHerDeleteAndTheLastTakeIsTheBlockByDeleteBlocksRoad() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            stack.removeAll()
            // The road the read decided is re-checked inside the transaction.
            #expect(throws: Operations.MCPNoteEditRefusal.takesChangedSinceRead(takeID: w.other1)) {
                _ = try ops.deleteTakeForClient(w.other1, wholeBlock: true, takeUndoLabel: "x", blockUndoLabel: "x")
            }
            #expect(throws: Operations.MCPNoteEditRefusal.takesChangedSinceRead(takeID: w.hers2)) {
                _ = try ops.deleteTakeForClient(w.hers2, wholeBlock: false, takeUndoLabel: "x", blockUndoLabel: "x")
            }
            #expect(throws: OperationError.variantIsChosen(id: w.hers1), "choose another first, as at her keyboard") {
                _ = try ops.deleteTakeForClient(w.hers1, wholeBlock: false, takeUndoLabel: "x", blockUndoLabel: "x")
            }
            #expect(stack.depth == 0)

            let one = try ops.deleteTakeForClient(
                w.other1, wholeBlock: false, takeUndoLabel: label(.takeDelete), blockUndoLabel: label(.delete))
            #expect(!one.wholeBlock)
            #expect(try db.deletedAt("variant", w.other1) != nil)
            #expect(try db.deletedAt("block", w.block1) == nil)
            #expect(stack.topLabel == "claude-code's take deletion")

            let last = try ops.deleteTakeForClient(
                w.hers3, wholeBlock: true, takeUndoLabel: label(.takeDelete), blockUndoLabel: label(.delete))
            #expect(last.wholeBlock && last.blockID == w.block3)
            let blockStamp = try db.deletedAt("block", w.block3)
            #expect(blockStamp != nil, "the block went")
            #expect(try db.deletedAt("variant", w.archived3) == blockStamp, "every take rode with it, on its stamp")
            #expect(try db.fetchString("SELECT last_container_id FROM block WHERE id = ?", [w.block3]) == w.noteID,
                    "the tray holds it, as delete_block's")
            #expect(stack.topLabel == "claude-code's delete", "delete_block's own entry, the client's name")

            #expect(try stack.undo(with: ops) == "claude-code's delete")
            #expect(try db.deletedAt("block", w.block3) == nil)
            #expect(try db.deletedAt("variant", w.archived3) == nil)
            #expect(try stack.undo(with: ops) == "claude-code's take deletion")
            #expect(try db.deletedAt("variant", w.other1) == nil)
            #expect(try stack.redo(with: ops) == "claude-code's take deletion")
            #expect(try db.deletedAt("variant", w.other1) != nil)

            try ops.lockVariant(w.hers2)
            #expect(throws: OperationError.lockedVariant(id: w.hers2), "a locked LAST take refuses too (P-VX195-3)") {
                _ = try ops.deleteTakeForClient(w.hers2, wholeBlock: true, takeUndoLabel: "x", blockUndoLabel: "x")
            }
        }
    }

    @Test func archiveUnarchiveLabelAndLockAreHerDoorsOneEntryEach() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            stack.removeAll()
            let status = { (id: String) in try db.fetchString("SELECT status FROM variant WHERE id = ?", [id]) }
            #expect(throws: OperationError.lastActiveVariant(id: w.hers2), "I10 — never turned into a delete") {
                _ = try ops.archiveTakeForClient(w.hers2, undoLabel: "x")
            }
            #expect(try ops.archiveTakeForClient(w.other1, undoLabel: label(.takeArchive)))
            #expect(try status(w.other1) == "archived" && stack.topLabel == "claude-code's take archiving")
            #expect(try ops.archiveTakeForClient(w.other1, undoLabel: "x") == false && stack.depth == 1)
            #expect(try ops.unarchiveTakeForClient(w.archived3, undoLabel: label(.takeUnarchive)))
            #expect(try status(w.archived3) == "active")
            #expect(try ops.unarchiveTakeForClient(w.archived3, undoLabel: "x") == false && stack.depth == 2)
            #expect(try stack.undo(with: ops) == "claude-code's take unarchiving")
            #expect(try status(w.archived3) == "archived")
            #expect(try stack.undo(with: ops) == "claude-code's take archiving")
            #expect(try status(w.other1) == "active")

            let labeled = try ops.labelTakeForClient(w.other1, label: "  bold  ", undoLabel: label(.takeLabel))
            #expect(labeled.changed && labeled.label == "bold")
            #expect(try !ops.labelTakeForClient(w.other1, label: "bold", undoLabel: "x").changed)
            #expect(try stack.undo(with: ops) == "claude-code's take label")
            #expect(try db.fetchString("SELECT label FROM variant WHERE id = ?", [w.other1]) == nil)
            #expect(try stack.redo(with: ops) == "claude-code's take label")
            #expect(try db.fetchString("SELECT label FROM variant WHERE id = ?", [w.other1]) == "bold")

            // Her lock: the dirty take insured first; ⌥⌘Z unlocks, the commit stays.
            let commits = { try db.fetchInt("SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [w.other1]) }
            let lock = try ops.lockTakeForClient(w.other1, locked: true, undoLabel: label(.takeLock))
            #expect(lock.changed && lock.locked && lock.insured?.kind == .auto)
            #expect(try commits() == 1)
            #expect(try !ops.lockTakeForClient(w.other1, locked: true, undoLabel: "x").changed)
            #expect(try stack.undo(with: ops) == "claude-code's take lock")
            #expect(try db.fetchInt("SELECT locked FROM variant WHERE id = ?", [w.other1]) == 0)
            #expect(try commits() == 1)
            #expect(try stack.redo(with: ops) == "claude-code's take lock")
            #expect(try db.fetchInt("SELECT locked FROM variant WHERE id = ?", [w.other1]) == 1)
            let unlock = try ops.lockTakeForClient(w.other1, locked: false, undoLabel: label(.takeUnlock))
            #expect(unlock.changed && !unlock.locked && unlock.insured == nil)
        }
    }

    // MARK: - Commits

    @Test func aCommitRestoreIsHerRestoreInsuredBothSidesAndUndoesToTheReplacedWords() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            stack.removeAll()
            let buffer = { try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [w.hers1]) }
            let restore = try ops.restoreCommitForClient(w.commitID, client: client, undoLabel: label(.commitRestore))
            #expect(restore.changed)
            #expect(try buffer() == "Her opening.")
            #expect(restore.before?.message == "before claude-code's restore" && restore.before?.text == "Her opening, revised.")
            #expect(restore.after?.message == "after claude-code's restore" && restore.after?.text == "Her opening.")
            #expect(restore.before?.kind == .auto && restore.after?.kind == .auto, "insurance-class, quiet")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's commit restore")
            let again = try ops.restoreCommitForClient(w.commitID, client: client, undoLabel: "x")
            #expect(!again.changed && again.before == nil && stack.depth == 1, "already reading it: nothing")
            #expect(try stack.undo(with: ops) == "claude-code's commit restore")
            #expect(try buffer() == "Her opening, revised.")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [w.hers1]) == 3,
                    "commits stay (I5)")
            #expect(try stack.redo(with: ops) == "claude-code's commit restore")
            #expect(try buffer() == "Her opening.")
            try ops.lockVariant(w.hers1)
            #expect(throws: OperationError.lockedVariant(id: w.hers1)) {
                _ = try ops.restoreCommitForClient(w.commitID, client: client, undoLabel: "x")
            }
        }
    }

    @Test func aCommitRenameIsHerRenameAsGivenWithTheSealCheckedFirst() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            stack.removeAll()
            let message = { try db.fetchString("SELECT message FROM commit_point WHERE id = ?", [w.commitID]) }
            let renamed = try ops.renameCommitForClient(w.commitID, message: "  the first draft ", undoLabel: label(.commitRename))
            #expect(renamed.changed && renamed.message == "the first draft" && renamed.takeID == w.hers1)
            #expect(try message() == "the first draft", "as given — no client prefix (P-VX195-5)")
            #expect(try !ops.renameCommitForClient(w.commitID, message: "the first draft", undoLabel: "x").changed)
            try ops.lockVariant(w.hers1)
            #expect(try ops.renameCommitForClient(w.commitID, message: nil, undoLabel: label(.commitRename)).changed,
                    "a locked take's commit may be renamed (#121)")
            #expect(try message() == nil)
            #expect(try stack.undo(with: ops) == "claude-code's commit name")
            #expect(try stack.undo(with: ops) == "claude-code's commit name")
            #expect(try message() == "first")
            try ops.unlockVariant(w.hers1)
            try ops.lockPost(w.noteID)
            #expect(throws: OperationError.lockedPost(id: w.noteID), "the seal, before the no-op") {
                _ = try ops.renameCommitForClient(w.commitID, message: "first", undoLabel: "x")
            }
        }
    }

    // MARK: - The note

    @Test func aRenameIsHerTitleDoorAndALensDeleteTakesItsPicksOnItsStamp() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            stack.removeAll()
            let title = { try db.fetchString("SELECT title FROM container WHERE id = ?", [w.noteID]) }
            try ops.lockPost(w.noteID)
            let renamed = try ops.renameNoteForClient(w.noteID, title: "  Chapter one ", undoLabel: label(.noteTitle))
            #expect(renamed.changed && renamed.title == "Chapter one",
                    "trimmed; a seal leaves the title free (her op's posture)")
            #expect(try title() == "Chapter one")
            #expect(try !ops.renameNoteForClient(w.noteID, title: "Chapter one", undoLabel: "x").changed)
            #expect(try ops.renameNoteForClient(w.noteID, title: " ", undoLabel: label(.noteTitle)).title == nil)
            #expect(try stack.undo(with: ops) == "claude-code's note title")
            #expect(try stack.undo(with: ops) == "claude-code's note title")
            #expect(try title() == "ch 1")
            let pool = try ops.createPool(title: "scraps")
            #expect(throws: OperationError.wrongContainerKind(id: pool.id, expected: .post)) {
                _ = try ops.renameNoteForClient(pool.id, title: "x", undoLabel: "x")
            }

            let lens = try ops.deleteLensForClient(w.lensID, undoLabel: label(.lensDelete))
            #expect(lens.name == "the bold cut")
            let stamp = try db.deletedAt("lens", w.lensID)
            #expect(stamp != nil)
            #expect(try db.fetchString("SELECT deleted_at FROM lens_choice WHERE lens_id = ?", [w.lensID]) == stamp,
                    "its pick died on its stamp")
            #expect(stack.topLabel == "claude-code's lens deletion")
            #expect(try stack.undo(with: ops) == "claude-code's lens deletion")
            #expect(try db.deletedAt("lens", w.lensID) == nil)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens_choice WHERE lens_id = ? AND deleted_at IS NULL",
                                    [w.lensID]) == 1)
            #expect(try stack.redo(with: ops) == "claude-code's lens deletion")
            #expect(try db.deletedAt("lens", w.lensID) != nil)
            #expect(try stack.undo(with: ops) == "claude-code's lens deletion", "the redo's stamp is answered for")
            #expect(try db.deletedAt("lens", w.lensID) == nil)
        }
    }

    // MARK: - The address reads

    @Test func theAddressReadsAnswerOnlyForLivePlacedRows() throws {
        try withUndo { ops, _, db in
            let w = try world(ops)
            let road = { (id: String) in
                try db.read { try Queries.mcpTakeRoad(id, $0) }.map { [$0.blockID, "\($0.last)"] }
            }
            #expect(try db.read { try Queries.mcpContainerOf(commit: w.commitID, $0) } == w.noteID)
            #expect(try db.read { try Queries.mcpContainerOf(commit: "nothing", $0) } == nil)
            #expect(try db.read { try Queries.mcpCommentHome(w.commentID, $0) } == w.noteID)
            #expect(try road(w.other1) == [w.block1, "false"])
            #expect(try road(w.hers2) == [w.block2, "true"])
            #expect(try road(w.archived3) == [w.block3, "false"], "an archived take is never the last")
            try ops.deleteBlockComment(w.commentID)
            #expect(try db.read { try Queries.mcpCommentHome(w.commentID, $0) } == w.noteID, "deleted, still home")
            #expect(try db.read { try Queries.mcpCommentIsRestorable(w.commentID, $0) })
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: w.commentID)])
            #expect(try db.read { try Queries.mcpCommentIsRestorable(w.commentID, $0) } == false,
                    "off her surface once she chose to delete it for good")
            try ops.deleteBlock(w.block1)
            #expect(try db.read { try Queries.mcpContainerOf(commit: w.commitID, $0) } == nil)
            #expect(try db.read { try Queries.mcpCommentHome(w.commentID, $0) } == nil)
        }
    }
}
