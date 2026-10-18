import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-255 (VX-336 U5b — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U5b D4/D6): `insertBlocks`, the act under `insert_blocks`, as exact state transitions
// — where the run lands and in what order, what each block is born with, the touch,
// the ONE undo entry on newBlock's road (an untouched run vanishes, a block she worked
// on trays, the redo returns the very rows), and its refusals. (The wire pins are
// `MCPInsertBlocksServerTests`.) New API, so green by construction: state transitions,
// the house's rule for a pure addition.

@Suite("VX-255 — insertBlocks, the act (core)")
struct MCPInsertBlocksActsTests {
    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func order(_ db: AppDatabase, _ noteID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db, sql: """
                    SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL
                    ORDER BY position, id
                    """, arguments: [noteID])
        }
    }

    @Test func theRunLandsWhereAskedInItsOwnOrder() throws {
        try withUndo { ops, _, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "Um.")
            let two = try ops.seedBlock(in: note.id, text: "Dois.")
            let end = try ops.insertBlocks([.init(text: "Três."), .init(text: "Quatro.")], intoNote: note.id,
                                           at: .end, undoLabel: "u")
            #expect(try order(db, note.id) == [one.block.id, two.block.id] + end.map(\.blockID))
            let start = try ops.insertBlocks([.init(text: "Zero."), .init(text: "Meio.")], intoNote: note.id,
                                             at: .start, undoLabel: "u")
            #expect(try order(db, note.id) == start.map(\.blockID) + [one.block.id, two.block.id] + end.map(\.blockID))
            let after = try ops.insertBlocks([.init(text: "A."), .init(text: "B.")], intoNote: note.id,
                                             at: .after(one.block.id), undoLabel: "u")
            #expect(try order(db, note.id)
                    == start.map(\.blockID) + [one.block.id] + after.map(\.blockID) + [two.block.id] + end.map(\.blockID),
                    "right after the anchor, the run in its own order")
        }
    }

    @Test func eachBlockIsBornAsGivenAndTheNoteIsTouched() throws {
        try withUndo { ops, _, db in
            let note = try ops.createPost(title: "ch 1")
            _ = try ops.seedBlock(in: note.id, text: "Um.")
            let touchedBefore = try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id])
            let minted = try ops.insertBlocks([
                .init(text: "Olá.\n\nAinda o mesmo bloco.", name: "  greeting  ",
                      takes: [.init(label: "english", text: "Hello."), .init(label: nil, text: "")]),
                .init(text: "", name: "   "),
            ], intoNote: note.id, at: .end, undoLabel: "u")
            #expect(minted.map(\.takes.count) == [3, 1], "a blank take is a take (R-VX171-2)")
            let first = minted[0]
            #expect(first.takes.map(\.label) == [nil, "english", nil], "labels as given")
            let fan = try db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT id FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id",
                    arguments: [first.blockID])
            }
            #expect(first.takes.map(\.id) == fan, "the record is the fan, in order")
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [first.shownTakeID])
                    == "Olá.\n\nAinda o mesmo bloco.", "ONE block — a blank line stays inside (I4)")
            #expect(try db.fetchString("SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [first.blockID])
                    == first.shownTakeID)
            #expect(try db.fetchString("SELECT default_variant_id FROM block WHERE id = ?", [first.blockID])
                    == first.shownTakeID, "the shown take chosen AND default")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM variant WHERE block_id = ? AND locked = 1", [first.blockID]) == 0)
            #expect(try db.fetchString("SELECT name FROM block WHERE id = ?", [first.blockID]) == "greeting")
            #expect(try db.fetchString("SELECT name FROM block WHERE id = ?", [minted[1].blockID]) == nil,
                    "a blank name is none")
            let touchedAfter = try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id])
            #expect(touchedAfter != nil && touchedAfter != touchedBefore, "minting text is working on the post")
        }
    }

    @Test func oneEntryWalksTheRunBackAndTheRedoReturnsTheVeryRows() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let hers = try ops.seedBlock(in: note.id, text: "Um.")
            let minted = try ops.insertBlocks([.init(text: "Dois."), .init(text: "Três.")], intoNote: note.id,
                                              at: .end, undoLabel: "claude-code's blocks")
            let ids = minted.map(\.blockID)
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's blocks")

            #expect(try stack.undo(with: ops) == "claude-code's blocks")
            #expect(try order(db, note.id) == [hers.block.id])
            for id in ids {
                #expect(try db.deletedAt("block", id) != nil)
                #expect(try db.fetchString("SELECT last_container_id FROM block WHERE id = ?", [id]) == nil,
                        "an untouched mint vanishes — never the tray")
            }
            #expect(try stack.redo(with: ops) == "claude-code's blocks")
            #expect(try order(db, note.id) == [hers.block.id] + ids, "the same ids, in place")

            // She types into the second one; the next ⌥⌘Z trays it, the first vanishes.
            try ops.autosave(minted[1].shownTakeID, text: "Três, and hers.", charDelta: 9)
            #expect(try stack.undo(with: ops) == "claude-code's blocks")
            #expect(try db.fetchString("SELECT last_container_id FROM block WHERE id = ?", [ids[0]]) == nil)
            #expect(try db.fetchString("SELECT last_container_id FROM block WHERE id = ?", [ids[1]]) == note.id,
                    "a block she worked on lands in the note's tray (the insurance doctrine)")
        }
    }

    @Test func itsRefusalsMintNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "Um.")
            let other = try ops.createPost(title: "another")
            let theirs = try ops.seedBlock(in: other.id, text: "Not this note's.")
            let blocks = "SELECT COUNT(*) FROM block"
            let before = try db.fetchInt(blocks)

            #expect(throws: OperationError.emptyImport) {
                try ops.insertBlocks([], intoNote: note.id, at: .end, undoLabel: "u")
            }
            #expect(throws: OperationError.blockNotPlaced(id: theirs.block.id), "an anchor of another note") {
                try ops.insertBlocks([.init(text: "x")], intoNote: note.id, at: .after(theirs.block.id), undoLabel: "u")
            }
            let gone = try ops.seedBlock(in: note.id, text: "Gone.")
            try ops.deleteBlock(gone.block.id)
            let afterDelete = try db.fetchInt(blocks)
            #expect(throws: OperationError.blockNotPlaced(id: gone.block.id), "a dead anchor") {
                try ops.insertBlocks([.init(text: "x")], intoNote: note.id, at: .after(gone.block.id), undoLabel: "u")
            }
            #expect(try db.fetchInt(blocks) == afterDelete && afterDelete == (before ?? 0) + 1)
            let undoDepth = stack.depth

            // A locked take at the anchor never refuses; a sealed note always does.
            try ops.lockVariant(one.variant.id)
            let landed = try ops.insertBlocks([.init(text: "Below.")], intoNote: note.id, at: .after(one.block.id),
                                              undoLabel: "u")
            #expect(try order(db, note.id) == [one.block.id] + landed.map(\.blockID))
            try ops.lockPost(note.id)
            let sealedBefore = try db.fetchInt(blocks)
            #expect(throws: OperationError.lockedPost(id: note.id)) {
                try ops.insertBlocks([.init(text: "x")], intoNote: note.id, at: .end, undoLabel: "u")
            }
            #expect(try db.fetchInt(blocks) == sealedBefore && stack.depth == undoDepth + 1, "the seal mints nothing")
        }
    }
}
