import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-761 (the VX-771 run, batch 2 — the run record's BATCH 2 RECORD, the seam proposed
// there): edit_take's REPLACE form as an op-level arm of the one act,
// `editTakeUnderInsurance(_:rewrite: .replacing(old:new:) …)`. The passage is resolved
// against the take's STORED text inside the act's own transaction; the landed act is
// the whole form's road byte for byte — the before/after bracket (deduped), touch +
// churn, ONE client-named undo entry; a locked take, an archived take and a sealed
// post refuse as ever; zero or several occurrences refuse naming the count; a blank
// result refuses. New API — green by construction (the wire pins carry red-on-old).

private struct GuardRefused: Error, Equatable {}

@Suite("VX-761 — edit_take's replace form, inside the act's transaction")
struct MCPReplaceTakeActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label() -> String { Operations.MCPWriteAct.edit.undoLabel(client: client) }

    private func replacing(_ old: String, _ new: String) -> Operations.MCPTakeRewrite { .replacing(old: old, new: new) }

    private func text(_ db: AppDatabase, _ variantID: String) throws -> String? {
        try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [variantID])
    }

    private func churnOf(_ db: AppDatabase, _ noteID: String) throws -> Double? {
        try db.read { db in
            try Double.fetchOne(db, sql: "SELECT churn_accumulator FROM container WHERE id = ?", arguments: [noteID])
        }
    }

    private func commits(_ db: AppDatabase, _ variantID: String) throws -> [Row] {
        try db.read { db in
            try Row.fetchAll(
                db, sql: "SELECT * FROM commit_point WHERE variant_id = ? ORDER BY created_at, id",
                arguments: [variantID])
        }
    }

    @Test func aUniquePassageLandsBracketedTouchedChurnedAndUndoesInOne() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "The first line. The second line. The third line.")
            let touched = try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id])
            let churn = try churnOf(db, note.id)

            let edit = try ops.editTakeUnderInsurance(
                seeded.variant.id, rewrite: replacing("The second line.", "A better second line."),
                client: client, undoLabel: label())
            #expect(edit.changed)
            let landed = "The first line. A better second line. The third line."
            #expect(edit.take.workingText == landed)
            #expect(try text(db, seeded.variant.id) == landed)
            let history = try commits(db, seeded.variant.id)
            #expect(history.map { $0["message"] as String? } == ["before claude-code's edit", "after claude-code's edit"])
            #expect(history.map { $0["text"] as String } == [
                "The first line. The second line. The third line.", landed,
            ])
            #expect(history.allSatisfy { ($0["kind"] as String) == "auto" })
            #expect(try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id]) != touched,
                    "a replacement touches the note like any text edit")
            #expect(try churnOf(db, note.id) != churn, "and churns")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's edit")

            #expect(try stack.undo(with: ops) == "claude-code's edit")
            #expect(try text(db, seeded.variant.id) == "The first line. The second line. The third line.")
            #expect(try commits(db, seeded.variant.id).count == 2, "the bracket stays (I5)")
            #expect(try stack.redo(with: ops) == "claude-code's edit")
            #expect(try text(db, seeded.variant.id) == landed)
        }
    }

    /// The churn is exactly the whole form's for the same resulting text: two
    /// identical notes, one edited whole, one by its passage.
    @Test func theChurnIsTheWholeFormsForTheSameResult() throws {
        #expect(Operations.churnCost(from: "a b c", to: "a XY c") == 3, "the shared rule (one deleted, two inserted)")
        try withUndo { ops, _, db in
            let whole = try ops.createPost(title: "whole")
            let passage = try ops.createPost(title: "passage")
            let one = try ops.seedBlock(in: whole.id, text: "a b c")
            let two = try ops.seedBlock(in: passage.id, text: "a b c")
            let before = (try churnOf(db, whole.id), try churnOf(db, passage.id))
            #expect(before.0 == before.1)
            try ops.editTakeUnderInsurance(
                one.variant.id, rewrite: .whole(text: "a XY c", expectedText: "a b c"), client: client,
                undoLabel: label())
            try ops.editTakeUnderInsurance(
                two.variant.id, rewrite: replacing("b", "XY"), client: client, undoLabel: label())
            #expect(try text(db, two.variant.id) == "a XY c")
            #expect(try churnOf(db, whole.id) == churnOf(db, passage.id), "the same buffer edit, the same churn")
            #expect(try churnOf(db, passage.id) != before.1)
        }
    }

    @Test func zeroOrSeveralOccurrencesRefuseNamingTheCountAndWriteNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "the cat, the hat, the mat")
            let touched = try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id])
            #expect(throws: Operations.MCPTakeReplacementRefusal.occurrences(0)) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, rewrite: replacing("the dog", "a dog"), client: client, undoLabel: label())
            }
            #expect(throws: Operations.MCPTakeReplacementRefusal.occurrences(3)) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, rewrite: replacing("the", "a"), client: client, undoLabel: label())
            }
            #expect(try text(db, seeded.variant.id) == "the cat, the hat, the mat")
            #expect(try commits(db, seeded.variant.id).isEmpty, "no bracket for a refused replacement")
            #expect(try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id]) == touched)
            #expect(stack.depth == 0)
        }
    }

    @Test func aReplacementLeavingTheTakeBlankRefuses() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: " her only words \n")
            #expect(throws: Operations.MCPTakeReplacementRefusal.wouldEmptyTake) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, rewrite: replacing("her only words", ""), client: client, undoLabel: label())
            }
            #expect(try text(db, seeded.variant.id) == " her only words \n")
            #expect(stack.depth == 0)
        }
    }

    /// U+0000 in the replacement is removed before it lands (VX-357); the
    /// passage is a locator, compared with the stored text as sent.
    @Test func aNullInTheReplacementIsStrippedAndAPassageHoldingOneMatchesNothing() throws {
        try withUndo { ops, _, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "her line")
            let edit = try ops.editTakeUnderInsurance(
                seeded.variant.id, rewrite: replacing("line", "li\u{0}ne!"), client: client, undoLabel: label())
            #expect(edit.take.workingText == "her line!")
            #expect(try text(db, seeded.variant.id) == "her line!")
            #expect(throws: Operations.MCPTakeReplacementRefusal.occurrences(0)) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, rewrite: replacing("li\u{0}ne", "x"), client: client, undoLabel: label())
            }
        }
    }

    /// A passage replaced by itself writes nothing — the whole form's no-op.
    @Test func aPassageReplacedByItselfIsTheNoOp() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "same words")
            let edit = try ops.editTakeUnderInsurance(
                seeded.variant.id, rewrite: replacing("words", "words"), client: client, undoLabel: label())
            #expect(!edit.changed && edit.before == nil && edit.after == nil && !edit.spellingDiffers)
            #expect(try commits(db, seeded.variant.id).isEmpty && stack.depth == 0)
        }
    }

    /// A before commit is deduped exactly as the whole form's: her own commit
    /// already holds the words replaced.
    @Test func theBeforeCommitIsDedupedAsTheWholeForms() throws {
        try withUndo { ops, _, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "saved text")
            try ops.commit(seeded.variant.id, message: "tightened")
            let edit = try ops.editTakeUnderInsurance(
                seeded.variant.id, rewrite: replacing("saved", "new"), client: client, undoLabel: label())
            #expect(edit.before == nil && edit.after != nil)
            #expect(try commits(db, seeded.variant.id).map { $0["message"] as String? }
                    == ["tightened", "after claude-code's edit"])
        }
    }

    @Test func aLockedTakeAnArchivedTakeAndASealRefuseBeforeThePassageIsRead() throws {
        try withUndo { ops, _, _ in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "guarded")
            let other = try ops.branchVariant(seeded.block.id, from: seeded.variant.id)
            try ops.lockVariant(seeded.variant.id)
            // A passage that isn't there: the take's guard speaks first.
            #expect(throws: OperationError.lockedVariant(id: seeded.variant.id)) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, rewrite: replacing("absent", "x"), client: client, undoLabel: label())
            }
            try ops.archiveVariant(other.id)
            #expect(throws: OperationError.archivedVariant(id: other.id)) {
                try ops.editTakeUnderInsurance(
                    other.id, rewrite: replacing("guarded", "x"), client: client, undoLabel: label())
            }
            try ops.unlockVariant(seeded.variant.id)
            try ops.lockPost(note.id)
            #expect(throws: OperationError.lockedPost(id: note.id)) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, rewrite: replacing("guarded", "x"), client: client, undoLabel: label())
            }
        }
    }

    /// **Race-free by construction:** the passage is resolved against the text
    /// the act's OWN transaction reads. A guard that rewrites the take inside
    /// that transaction (standing in for any write that landed first) is what
    /// the replacement meets — a door that pre-computed the text outside would
    /// have written over it. And a refusing guard rolls the whole act back.
    @Test func thePassageIsResolvedInsideTheActsTransaction() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "alpha beta")
            let landedFirst: Operations.WriteGuard = { db in
                try db.execute(
                    sql: "UPDATE variant SET working_text = 'alpha gamma' WHERE id = ?", arguments: [seeded.variant.id])
            }
            let edit = try ops.editTakeUnderInsurance(
                seeded.variant.id, rewrite: replacing("gamma", "delta"), client: client, undoLabel: label(),
                guardedBy: landedFirst)
            #expect(edit.take.workingText == "alpha delta")
            #expect(try text(db, seeded.variant.id) == "alpha delta")

            let refusing: Operations.WriteGuard = { db in
                try db.execute(sql: "UPDATE container SET title = 'moved by the guard' WHERE id = ?", arguments: [note.id])
                throw GuardRefused()
            }
            let depth = stack.depth
            #expect(throws: GuardRefused()) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, rewrite: replacing("delta", "epsilon"), client: client, undoLabel: label(),
                    guardedBy: refusing)
            }
            #expect(try db.fetchString("SELECT title FROM container WHERE id = ?", [note.id]) == "ch 1")
            #expect(try text(db, seeded.variant.id) == "alpha delta")
            #expect(stack.depth == depth)
        }
    }

    /// The whole form is byte-unchanged through the new body (its old
    /// signature forwards `.whole`).
    @Test func theWholeFormIsTheSameAct() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "her words")
            #expect(throws: OperationError.bufferChangedSinceGesture(variantID: seeded.variant.id)) {
                try ops.editTakeUnderInsurance(
                    seeded.variant.id, rewrite: .whole(text: "x", expectedText: "her"), client: client,
                    undoLabel: label())
            }
            let edit = try ops.editTakeUnderInsurance(
                seeded.variant.id, rewrite: .whole(text: "new words", expectedText: "her words"), client: client,
                undoLabel: label())
            #expect(edit.changed && edit.take.workingText == "new words" && stack.depth == 1)
            #expect(try text(db, seeded.variant.id) == "new words")
        }
    }
}
