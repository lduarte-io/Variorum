import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-168 U2 — THE MCP DOOR's DELIBERATE EDIT-RUNG ACTS (VX-169 `save_commit`;
// VX-174 `choose_take` / `adopt_lens` — R-MERGE-1): exact state transitions,
// each act HER door's row work (her commit, her ✓, her "✓ Make this the
// note"), the guard run first inside the act's own transaction, the two
// pointer acts ONE client-named undo entry each whose inverse and redo
// round-trip the same rows, and the commit registering NONE (append-only —
// as her own commit). Who may act is the server's per-call rule
// (`MCPDeliberateServerTests`).

private struct GuardRefused: Error, Equatable {}

@Suite("VX-168 U2 — the MCP door's deliberate acts: a client's commit, a chosen take, a lens made the note")
struct MCPDeliberateActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    private func chosen(_ db: AppDatabase, _ blockID: String) throws -> String? {
        try db.fetchString(
            "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL", [blockID])
    }

    private func commits(_ db: AppDatabase, _ variantID: String) throws -> [Row] {
        try db.read { db in
            try Row.fetchAll(
                db, sql: "SELECT * FROM commit_point WHERE variant_id = ? ORDER BY created_at, id",
                arguments: [variantID])
        }
    }

    /// A note of two blocks, the first fanned (her take + a second take), and
    /// a lens that shows the second take on block 1.
    private struct World {
        let noteID: String
        let block1: String
        let hers1: String
        let other1: String
        let block2: String
        let hers2: String
        let lensID: String
    }

    private func world(_ ops: Operations) throws -> World {
        let note = try ops.createPost(title: "ch 1")
        let one = try ops.seedBlock(in: note.id, text: "Her opening.")
        let other = try ops.branchVariant(one.block.id, from: one.variant.id)
        try ops.autosave(other.id, text: "A bolder opening.", charDelta: 4)
        let two = try ops.seedBlock(in: note.id, text: "Her close.")
        let lens = try ops.createLens(post: note.id, name: "claude's cut")
        _ = try ops.setLensChoice(lens: lens.id, block: one.block.id, variant: other.id)
        return World(noteID: note.id, block1: one.block.id, hers1: one.variant.id, other1: other.id,
                     block2: two.block.id, hers2: two.variant.id, lensID: lens.id)
    }

    // MARK: - VX-169: save_commit — her commit, the client's name prefixed

    @Test func theClientsMessageIsPrefixedWithItsNameThroughTheOneRule() {
        #expect(Operations.mcpCommitMessage(client: "claude-code", message: "  fact-checked  ")
                == "claude-code: fact-checked")
        #expect(Operations.mcpCommitMessage(client: "codex", message: " \n ") == "codex", "a blank message leaves the name")
        #expect(SavepointName.normalized(Operations.mcpCommitMessage(client: "codex", message: "ok")) == "codex: ok",
                "the one savepoint-name rule keeps it as it is")
    }

    @Test func aClientsCommitLandsManualNamedAndAppendOnlyWithNoUndoEntry() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            let revisedBefore = try db.fetchString("SELECT last_major_revision_at FROM container WHERE id = ?", [w.noteID])
            let commit = try ops.commitTakeForClient(w.hers1, message: "fact-checked, no changes", client: client)
            #expect(commit.kind == .manual, "kind='manual' — the settled kind (a third is a §12 lockstep event)")
            #expect(commit.message == "claude-code: fact-checked, no changes")
            #expect(commit.text == "Her opening.", "the take's buffer, exactly")
            #expect(try db.fetchString("SELECT last_major_revision_at FROM container WHERE id = ?", [w.noteID])
                    != revisedBefore, "a manual commit stamps a major revision (AppSpec §10), as hers does")
            #expect(stack.depth == 0, "NO undo entry: append-only, as her own commit (R-13n-6, AppSpec §9)")

            // Appended ALWAYS — her ⌘S never dedupes against the last commit
            // (PROVISIONAL P-VX168-U2-1).
            _ = try ops.commitTakeForClient(w.hers1, message: "checked again", client: client)
            #expect(try commits(db, w.hers1).map { $0["message"] as String? }
                    == ["claude-code: fact-checked, no changes", "claude-code: checked again"])
            #expect(try commits(db, w.hers1).allSatisfy { ($0["kind"] as String) == "manual" })
            #expect(stack.depth == 0)
        }
    }

    @Test func aClientsCommitRefusesWhereHersDoesAndAnArchivedTakeMayCommit() throws {
        try withUndo { ops, _, db in
            let w = try world(ops)
            try ops.archiveVariant(w.other1)
            _ = try ops.commitTakeForClient(w.other1, message: "kept for the record", client: client)
            #expect(try commits(db, w.other1).count == 1, "an archived take may commit (her 2026-07-05 ratification)")
            try ops.lockVariant(w.hers2)
            #expect(throws: OperationError.lockedVariant(id: w.hers2)) {
                try ops.commitTakeForClient(w.hers2, message: "x", client: client)
            }
            try ops.lockPost(w.noteID)
            #expect(throws: OperationError.lockedPost(id: w.noteID)) {
                try ops.commitTakeForClient(w.hers1, message: "x", client: client)
            }
            #expect(try commits(db, w.hers2).filter { ($0["kind"] as String) == "manual" }.isEmpty,
                    "a refused commit appends nothing (the seal's own auto commits aside)")
        }
    }

    @Test func theCommitsGuardRunsFirstInItsOwnTransaction() throws {
        try withUndo { ops, _, db in
            let w = try world(ops)
            let revised = try db.fetchString("SELECT last_major_revision_at FROM container WHERE id = ?", [w.noteID])
            #expect(throws: GuardRefused()) {
                try ops.commitTakeForClient(w.hers1, message: "x", client: client, guardedBy: { _ in throw GuardRefused() })
            }
            #expect(try commits(db, w.hers1).isEmpty)
            #expect(try db.fetchString("SELECT last_major_revision_at FROM container WHERE id = ?", [w.noteID]) == revised)
        }
    }

    // MARK: - VX-174: choose_take — her ✓, one client-named undo

    @Test func choosingATakeMovesThePointerAndUndoesAndRedoesExactly() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            let touched = try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [w.noteID])
            let choice = try ops.chooseTake(w.other1, undoLabel: label(.choice))
            #expect(choice == .init(takeID: w.other1, blockID: w.block1, changed: true))
            #expect(try chosen(db, w.block1) == w.other1)
            #expect(try db.read { try Queries.renderedText($0, containerID: w.noteID) } == "A bolder opening.\n\nHer close.")
            #expect(try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [w.noteID]) == touched,
                    "a pointer move: no touch, no churn — as her ✓")
            #expect(try commits(db, w.other1).isEmpty && (try commits(db, w.hers1)).isEmpty, "no text written, no commit")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's take choice")

            #expect(try stack.undo(with: ops) == "claude-code's take choice")
            #expect(try chosen(db, w.block1) == w.hers1, "her take is chosen again")
            #expect(try stack.redo(with: ops) == "claude-code's take choice")
            #expect(try chosen(db, w.block1) == w.other1)
        }
    }

    @Test func choosingTheTakeAlreadyChosenWritesNothingAndRegistersNothing() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            let before = try db.snapshotRow(
                "container_block", try #require(try db.fetchString(
                    "SELECT id FROM container_block WHERE block_id = ?", [w.block1])), excluding: [])
            let choice = try ops.chooseTake(w.hers1, undoLabel: label(.choice))
            #expect(!choice.changed)
            #expect(try db.snapshotRow(
                "container_block", try #require(try db.fetchString(
                    "SELECT id FROM container_block WHERE block_id = ?", [w.block1])), excluding: []) == before,
                    "the slot's row is byte-identical — updated_at included")
            #expect(stack.depth == 0)
        }
    }

    @Test func undoingAChoiceRestoresANilPointerExactly() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET chosen_variant_id = NULL WHERE block_id = ?",
                               arguments: [w.block1])
            }
            _ = try ops.chooseTake(w.hers1, undoLabel: label(.choice))
            #expect(try chosen(db, w.block1) == w.hers1, "a nil pointer naming the default IS a change (the row moves)")
            _ = try stack.undo(with: ops)
            #expect(try chosen(db, w.block1) == nil, "the exact pre-image — nil, not the default")
        }
    }

    @Test func choosingRefusesWhereHerCheckmarkDoesAndALockedTakeMayBeChosen() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            // (archiveVariant registers its OWN structural entry — the
            // fixture lands before the act's depth is read.)
            let archived = try ops.branchVariant(w.block2, from: w.hers2)
            try ops.archiveVariant(archived.id)
            #expect(throws: OperationError.archivedVariant(id: archived.id)) {
                try ops.chooseTake(archived.id, undoLabel: label(.choice))
            }
            let depth = stack.depth
            try ops.lockVariant(w.other1)
            #expect(try ops.chooseTake(w.other1, undoLabel: label(.choice)).changed, "the lock guards the buffer only")
            #expect(stack.depth == depth + 1 && stack.topLabel == "claude-code's take choice")
            try ops.lockPost(w.noteID)
            #expect(throws: OperationError.lockedPost(id: w.noteID)) {
                try ops.chooseTake(w.hers1, undoLabel: label(.choice))
            }
            // The entry survives the seal: undoing it under the seal refuses
            // and keeps it (the pointer brain's rule).
            #expect(throws: OperationError.lockedPost(id: w.noteID)) { try stack.undo(with: ops) }
            #expect(try stack.depth == depth + 1 && chosen(db, w.block1) == w.other1)
        }
    }

    @Test func choosingATakeOfAnUnplacedBlockRefuses() throws {
        try withUndo { ops, _, _ in
            let w = try world(ops)
            let merged = try ops.merge(w.block1, w.block2)
            #expect(throws: OperationError.blockNotPlaced(id: w.block1)) {
                try ops.chooseTake(w.other1, undoLabel: label(.choice))
            }
            _ = merged
        }
    }

    @Test func theChoicesGuardRunsFirstInItsOwnTransaction() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            #expect(throws: GuardRefused()) {
                try ops.chooseTake(w.other1, undoLabel: label(.choice), guardedBy: { _ in throw GuardRefused() })
            }
            #expect(try chosen(db, w.block1) == w.hers1 && stack.depth == 0)
        }
    }

    // MARK: - VX-174: adopt_lens — her "✓ Make this the note", one client-named undo

    @Test func adoptingALensSwapsAndPreservesAndOneUndoWalksTheWholeActBack() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            let lensesBefore = try db.fetchInt("SELECT COUNT(*) FROM lens WHERE deleted_at IS NULL")
            let adoption = try ops.adoptLensAsNote(w.lensID, undoLabel: label(.lensAdoption))
            #expect(adoption.changed && adoption.moved == 1 && adoption.noteID == w.noteID)
            let kept = try #require(adoption.keptAs)
            #expect(kept.name.hasPrefix("chosen until "), "her door's preservation lens (R92)")
            #expect(try chosen(db, w.block1) == w.other1 && (try chosen(db, w.block2)) == w.hers2)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens_choice WHERE lens_id = ? AND deleted_at IS NULL",
                                    [kept.id]) == 2, "full-fidelity: every renderable slot kept")
            #expect(try db.fetchString("SELECT variant_id FROM lens_choice WHERE lens_id = ? AND block_id = ?",
                                       [kept.id, w.block1]) == w.hers1, "the OUTGOING chosen is kept")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's lens adoption")

            #expect(try stack.undo(with: ops) == "claude-code's lens adoption")
            #expect(try chosen(db, w.block1) == w.hers1, "her chosen, back")
            #expect(try db.deletedAt("lens", kept.id) != nil, "the act's preservation lens walks back with it")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens WHERE deleted_at IS NULL") == lensesBefore)
            #expect(try db.deletedAt("lens", w.lensID) == nil, "the adopted lens itself is untouched")

            #expect(try stack.redo(with: ops) == "claude-code's lens adoption")
            #expect(try chosen(db, w.block1) == w.other1)
            #expect(try db.deletedAt("lens", kept.id) == nil, "exactly that lens revives")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens_choice WHERE lens_id = ? AND deleted_at IS NULL",
                                    [kept.id]) == 2, "with the choices that died on the undo's stamp")
        }
    }

    @Test func aLensThatAgreesWithTheNoteWritesNothingNotEvenAPreservationLens() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            let agreeing = try ops.createLens(post: w.noteID, name: "agrees")
            _ = try ops.setLensChoice(lens: agreeing.id, block: w.block1, variant: w.hers1)
            let lenses = try db.fetchInt("SELECT COUNT(*) FROM lens")
            let adoption = try ops.adoptLensAsNote(agreeing.id, undoLabel: label(.lensAdoption))
            #expect(!adoption.changed && adoption.keptAs == nil)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens") == lenses, "no lens minted")
            #expect(stack.depth == 0)
            // Her own door (parity, unchanged): it mints the preservation
            // lens even when nothing moves — the recorded difference.
            _ = try ops.adoptLensPreservingChosen(agreeing.id)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens") == (lenses ?? 0) + 1)
        }
    }

    @Test func adoptingRefusesUnderASealAndItsUndoRefusesThereAndKeepsTheEntry() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            _ = try ops.adoptLensAsNote(w.lensID, undoLabel: label(.lensAdoption))
            try ops.lockPost(w.noteID)
            #expect(throws: OperationError.lockedPost(id: w.noteID)) { try stack.undo(with: ops) }
            #expect(try stack.depth == 1 && chosen(db, w.block1) == w.other1, "refused whole, entry kept")
            let second = try ops.createLens(post: w.noteID, name: "another")
            _ = try ops.setLensChoice(lens: second.id, block: w.block1, variant: w.hers1)
            #expect(throws: OperationError.lockedPost(id: w.noteID)) {
                try ops.adoptLensAsNote(second.id, undoLabel: label(.lensAdoption))
            }
            try ops.unlockPost(w.noteID)
            #expect(try stack.undo(with: ops) == "claude-code's lens adoption", "resolvable once unsealed")
            #expect(try chosen(db, w.block1) == w.hers1)
        }
    }

    @Test func aPreservationLensSheDeletedSinceStaysDeletedOnRedo() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            let kept = try #require(try ops.adoptLensAsNote(w.lensID, undoLabel: label(.lensAdoption)).keptAs)
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            try ops.deleteLens(kept.id)
            let herStamp = try db.deletedAt("lens", kept.id)
            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("lens", kept.id) == herStamp, "her own deletion stands")
            #expect(try chosen(db, w.block1) == w.other1)
        }
    }

    @Test func theAdoptionsGuardRunsFirstInItsOwnTransaction() throws {
        try withUndo { ops, stack, db in
            let w = try world(ops)
            let lenses = try db.fetchInt("SELECT COUNT(*) FROM lens")
            #expect(throws: GuardRefused()) {
                try ops.adoptLensAsNote(w.lensID, undoLabel: label(.lensAdoption), guardedBy: { _ in throw GuardRefused() })
            }
            #expect(try chosen(db, w.block1) == w.hers1 && stack.depth == 0)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens") == lenses)
        }
    }

    @Test func theNewActsWordsAndWhichOnesUndo() {
        #expect(Operations.MCPWriteAct.choice.undoLabel(client: "codex") == "codex's take choice")
        #expect(Operations.MCPWriteAct.lensAdoption.undoLabel(client: "codex") == "codex's lens adoption")
        #expect(Operations.MCPWriteAct.allCases.filter { !$0.isUndoable } == [.commit],
                "a commit is the one act ⌥⌘Z never walks back")
    }

    @Test func theLensResolverAnswersOnlyForALiveLens() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "n")
            let lens = try ops.createLens(post: note.id, name: "l")
            #expect(try db.read { try Queries.mcpContainerOf(lens: lens.id, $0) } == note.id)
            #expect(try db.read { try Queries.mcpContainerOf(lens: "nobody", $0) } == nil)
            try ops.deleteLens(lens.id)
            #expect(try db.read { try Queries.mcpContainerOf(lens: lens.id, $0) } == nil)
        }
    }
}
