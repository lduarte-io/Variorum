import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **R-13u-3 — `newBlock` JOINS AppSpec §9's structural-undo list** (author
/// ruling, the 13u1 kickoff sitting; built at UNIT 2). Her ask: *"⌥⌘Z removes
/// an empty block just minted by ⏎."* The inverse is a tombstone flip; the
/// redo is its exact-row mirror.
@Suite("newBlock's structural undo (R-13u-3)")
struct NewBlockUndoTests {

    /// **RED ON OLD by construction:** before this ruling `newBlock`
    /// registered nothing at all, so the stack was empty here and ⌥⌘Z
    /// reached past the mint to whatever came before it.
    @Test func mintingABlockRegistersAnUndoEntryThatTombstonesIt() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "first", at: .end)
            let minted = try ops.newBlock(in: post.id, text: "", at: .end)

            #expect(stack.topLabel == "New Block")
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("block", minted.block.id) != nil,
                    "the inverse is a tombstone flip")
            let live = try db.read { db in
                try Queries.renderPost(db, containerID: post.id).compactMap(\.text)
            }
            #expect(live == ["first"])
        }
    }

    /// Exact-row redo (13c A10): the SAME block id comes back, with its
    /// placement, so undo↔redo ping-pongs without minting anything.
    @Test func redoBringsTheExactSameBlockBack() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "first", at: .end)
            let minted = try ops.newBlock(in: post.id, text: "second", at: .end)

            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)
            let live = try db.read { db in
                try Queries.renderPost(db, containerID: post.id)
            }
            #expect(live.map(\.blockID) == [live[0].blockID, minted.block.id])
            #expect(live.compactMap(\.text) == ["first", "second"])
        }
    }

    /// The insurance doctrine rides in unchanged: an untouched mint VANISHES,
    /// and one she has typed into TRAYS instead of dropping her words.
    @Test func aMintSheTypedIntoTraysInsteadOfVanishing() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "first", at: .end)
            let minted = try ops.newBlock(in: post.id, text: "", at: .end)
            try ops.autosave(minted.variant.id, text: "words she typed", charDelta: 15)

            _ = try stack.undo(with: ops)
            let trayed = try db.read { db in
                try Queries.trayBlocks(db, postID: post.id, now: harnessNow).map(\.blockID)
            }
            #expect(trayed == [minted.block.id],
                    "an edited mint trays — the standing insurance doctrine")
        }
    }

    /// **The ONE named exception.** Type-time crystallization is not a
    /// gesture she made, so it registers nothing — otherwise typing would
    /// fill her stack a paragraph at a time AND clear the redo future on
    /// every one.
    @Test func crystallizationRegistersNothingAndKeepsTheRedoFuture() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            let first = try ops.newBlock(in: post.id, text: "first", at: .end)
            _ = try stack.undo(with: ops)
            #expect(stack.redoDepth == 1, "a redo future exists")

            _ = try ops.newBlock(
                in: post.id, text: "crystallized", at: .end, registeringUndo: false)
            #expect(stack.depth == 0, "nothing was registered")
            #expect(stack.redoDepth == 1, "…and the redo future survives")

            _ = try stack.redo(with: ops)
            let live = try db.read { db in
                try Queries.renderPost(db, containerID: post.id).compactMap(\.text)
            }
            #expect(live.sorted() == ["crystallized", "first"])
            _ = first
        }
    }
}
