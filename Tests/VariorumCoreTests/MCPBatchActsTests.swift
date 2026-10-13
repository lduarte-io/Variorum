import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-184 U3 — VX-173's BATCH ACTS (`Operations+MCPBatches`): exact state
// transitions. One transaction per batch — the caller's guard first, then the
// note's seal, then each item through the single door's own row body — so a
// refusal anywhere lands NOTHING and registers nothing; ONE client-named undo
// entry whose inverse and redo each walk every row in ONE transaction.

@Suite("VX-173 — the batch acts: one transaction, one undo entry")
struct MCPBatchActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    private func count(_ db: AppDatabase, _ sql: String) throws -> Int {
        try db.read { try Int.fetchOne($0, sql: sql) ?? -1 }
    }

    @Test func takesLandInOneTransactionAndOneEntryWalksThemAllBack() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "One.")
            let two = try ops.seedBlock(in: note.id, text: "Two.")
            stack.removeAll()
            let before = try count(db, "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL")

            let takes = try ops.addTakes([
                .init(blockID: one.block.id, text: "Uno.", label: "es"),
                .init(blockID: two.block.id, text: ""),
                .init(blockID: one.block.id, text: "Um.", label: "pt"),
            ], inNote: note.id, undoLabel: label(.takes))
            #expect(takes.map(\.workingText) == ["Uno.", "", "Um."])
            #expect(takes.map(\.label) == ["es", nil, "pt"])
            #expect(takes.allSatisfy { $0.parentVariantId == nil && !$0.locked && $0.status == .active })
            let fan = try db.read { try String.fetchAll(
                $0, sql: "SELECT id FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id",
                arguments: [one.block.id]) }
            #expect(fan == [one.variant.id, takes[0].id, takes[2].id], "her take, then the batch's, in item order")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's takes")

            #expect(try stack.undo(with: ops) == "claude-code's takes")
            #expect(try count(db, "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") == before)
            #expect(try stack.redo(with: ops) == "claude-code's takes")
            for take in takes { #expect(try db.deletedAt("variant", take.id) == nil, "the very rows back") }
        }
    }

    /// ALL-OR-NOTHING: an item whose block lives in another note refuses the
    /// batch as `MCPBatchItemRefusal` at ITS index — the items before it never
    /// land; a sealed note refuses as itself (not an item's); a guard refusal
    /// lands nothing. No refusal registers an entry.
    @Test func anyRefusalLandsNothingAndNamesTheItem() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "One.")
            let elsewhere = try ops.createPost(title: "ch 2")
            let foreign = try ops.seedBlock(in: elsewhere.id, text: "Not here.")
            stack.removeAll()
            let takesBefore = try count(db, "SELECT COUNT(*) FROM variant")
            let commentsBefore = try count(db, "SELECT COUNT(*) FROM block_comment")

            do {
                _ = try ops.addTakes([
                    .init(blockID: one.block.id, text: "fine"), .init(blockID: one.block.id, text: "fine"),
                    .init(blockID: foreign.block.id, text: "elsewhere"),
                ], inNote: note.id, undoLabel: label(.takes))
                Issue.record("a foreign block must refuse the batch")
            } catch let refusal as Operations.MCPBatchItemRefusal {
                #expect(refusal.index == 2)
                #expect(refusal.underlying as? OperationError
                        == .blockNotInContainer(blockID: foreign.block.id, containerID: note.id))
            }
            do {
                _ = try ops.addComments([
                    .init(blockID: one.block.id, text: "good"), .init(blockID: one.block.id, text: "  "),
                ], inNote: note.id, undoLabel: label(.comments))
                Issue.record("a blank comment must refuse the batch")
            } catch let refusal as Operations.MCPBatchItemRefusal {
                #expect(refusal.index == 1 && refusal.underlying as? OperationError == .invalidCommentText)
            }
            #expect(throws: OperationError.self, "a guard refusal refuses the act") {
                _ = try ops.addTakes([.init(blockID: one.block.id, text: "x")], inNote: note.id,
                                     undoLabel: label(.takes), guardedBy: { _ in throw OperationError.invalidCommentText })
            }
            try ops.lockPost(note.id)
            #expect(throws: OperationError.lockedPost(id: note.id), "a sealed note refuses as itself") {
                _ = try ops.addTakes([.init(blockID: one.block.id, text: "x")], inNote: note.id, undoLabel: label(.takes))
            }
            #expect(try count(db, "SELECT COUNT(*) FROM variant") == takesBefore, "not one take landed")
            #expect(try count(db, "SELECT COUNT(*) FROM block_comment") == commentsBefore, "not one comment landed")
            #expect(stack.depth == 0, "no refusal registers an entry")
        }
    }

    /// The ONE inverse is all-or-nothing too: a take of the batch she has
    /// CHOSEN since refuses the whole undo (`revertAddedTake`'s guard) — every
    /// take stays, the entry stays for a retry once she chooses another.
    @Test func theUndoRefusesWholeWhileSheHasChosenATakeOfTheBatch() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "One.")
            let two = try ops.seedBlock(in: note.id, text: "Two.")
            stack.removeAll()
            let takes = try ops.addTakes([
                .init(blockID: one.block.id, text: "Uno."), .init(blockID: two.block.id, text: "Dos."),
            ], inNote: note.id, undoLabel: label(.takes))
            try ops.chooseVariant(two.block.id, variantID: takes[1].id)
            stack.removeAll()
            _ = try ops.addTakes([.init(blockID: one.block.id, text: "Ein.")], inNote: note.id, undoLabel: label(.takes))
            _ = try stack.undo(with: ops)  // the third take's own batch, freely
            let entry = try ops.addTakes([
                .init(blockID: one.block.id, text: "A."), .init(blockID: two.block.id, text: "B."),
            ], inNote: note.id, undoLabel: label(.takes))
            try ops.chooseVariant(two.block.id, variantID: entry[1].id)
            #expect(throws: OperationError.variantIsChosen(id: entry[1].id)) { try stack.undo(with: ops) }
            #expect(try db.deletedAt("variant", entry[0].id) == nil, "the refused undo took nothing back")
            #expect(stack.topLabel == "claude-code's takes", "the entry stays for a retry")
            try ops.chooseVariant(two.block.id, variantID: two.variant.id)
            #expect(try stack.undo(with: ops) == "claude-code's takes")
            #expect(try db.deletedAt("variant", entry[0].id) != nil && db.deletedAt("variant", entry[1].id) != nil)
        }
    }
}
