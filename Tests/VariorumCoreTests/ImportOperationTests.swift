import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 11b, Step B2 — the import operations: dropped text through the
/// EXISTING bulk-entry pipeline (`bulkSegments`), one transaction per
/// gesture, the source never touched (the app face only reads; pinned
/// there). Round-trip sanity pins the 2026-07-12 spacing ruling end to
/// end: import → export reproduces the dropped bytes (modulo the recorded
/// edge-run drops and single-newline promotion).
@Suite("Import operations (Phase 11b, B2)")
struct ImportOperationTests {
    // MARK: - The library door

    @Test func importPostSegmentsPerTheGlobalDefaultAndRoundTrips() throws {
        try withOperations { ops, db in
            let dropped = "Alpha.\n\nBeta.\n\n\nGamma."
            let result = try ops.importPost(title: "Dropped", text: dropped)
            #expect(result.createdContainer)
            #expect(result.container.title == "Dropped")
            #expect(result.blockIDs.count == 3)

            // The spacing ruling rides the shared pipeline: k newlines
            // between pieces → k−1 trailing on the preceding block.
            let texts = try db.read { database in
                try Queries.renderPost(database, containerID: result.container.id)
                    .map { $0.text ?? "" }
            }
            #expect(texts == ["Alpha.\n", "Beta.\n\n", "Gamma."])

            // Import → export reproduces the dropped bytes exactly.
            let exported = try db.read {
                try Queries.exportPost($0, postID: result.container.id)
            }
            #expect(exported == dropped)

            // Minting text is working on the post (the ratified stamp rule).
            let touched = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?",
                [result.container.id])
            #expect(touched != nil)
        }
    }

    @Test func exportImportExportIsByteStable() throws {
        try withOperations { ops, db in
            // Single newlines between paragraphs promote to the "\n\n"
            // rendering join on first export (the recorded modulo — the
            // pieces store no trailing content); after that the cycle is
            // byte-stable: export → import → export reproduces itself.
            let post = try ops.importPost(title: "Original", text: "One.\nTwo.")
            let firstExport = try db.read { try Queries.exportPost($0, postID: post.container.id) }
            #expect(firstExport == "One.\n\nTwo.")

            let reimported = try ops.importPost(title: "Copy", text: firstExport)
            let secondExport = try db.read {
                try Queries.exportPost($0, postID: reimported.container.id)
            }
            #expect(secondExport == firstExport)

            // Edge runs (leading/trailing blank lines) drop — recorded.
            let edged = try ops.importPost(title: "Edged", text: "\n\nBody.\n\n")
            let edgedExport = try db.read {
                try Queries.exportPost($0, postID: edged.container.id)
            }
            #expect(edgedExport == "Body.")
        }
    }

    @Test func importPostHonorsASentenceGlobalDefault() throws {
        try withOperations { ops, db in
            try db.write { database in
                try database.execute(
                    sql: "UPDATE setting SET value = 'sentence' WHERE key = 'default_segmentation'")
            }
            let result = try ops.importPost(title: nil, text: "One. Two! Three?")
            let texts = try db.read { database in
                try Queries.renderPost(database, containerID: result.container.id)
                    .map { $0.text ?? "" }
            }
            #expect(texts == ["One.", "Two!", "Three?"])
        }
    }

    @Test func whitespaceOnlyTextRefusesBothDoors() throws {
        try withOperations { ops, _ in
            #expect(throws: OperationError.emptyImport) {
                try ops.importPost(title: "Blank", text: " \n\n \n")
            }
            let pool = try ops.createPool(title: "Pool")
            #expect(throws: OperationError.emptyImport) {
                try ops.importBlocks(into: pool.id, text: "   ")
            }
            // The refused library drop minted nothing.
            let count = try ops.database.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post'")
            }
            #expect(count == 0)
        }
    }

    // MARK: - The pool door

    @Test func importBlocksAppendsToThePoolPerItsEffectiveDefault() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "Pool")
            try ops.newBlock(in: pool.id, text: "Existing scrap.")
            let result = try ops.importBlocks(into: pool.id, text: "New one.\n\nNew two.")
            #expect(!result.createdContainer)
            #expect(result.container.id == pool.id)
            #expect(result.blockIDs.count == 2)

            let texts = try db.read { database in
                try Queries.renderPost(database, containerID: pool.id).map { $0.text ?? "" }
            }
            // The "\n\n" between the dropped pieces stores its k−1 trailing
            // newline on the first scrap (the spacing ruling, everywhere).
            #expect(texts == ["Existing scrap.", "New one.\n", "New two."])

            // A one_block override lands the whole drop as ONE scrap.
            try ops.setSegmentationDefault(pool.id, segmentation: .oneBlock)
            let single = try ops.importBlocks(into: pool.id, text: "A.\n\nB.")
            #expect(single.blockIDs.count == 1)
            let last = try db.read { database in
                try Queries.renderPost(database, containerID: pool.id).last?.text
            }
            #expect(last == "A.\n\nB.")
        }
    }

    @Test func aSealedContainerRefusesTheDrop() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "Sealed")
            try ops.newBlock(in: post.id, text: "Body.")
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.importBlocks(into: post.id, text: "Dropped.")
            }
        }
    }

    // MARK: - Undo (the recovery doors stay open)

    @Test func undoTombstonesTheImportedPostRecoverably() throws {
        try withOperations { _, db in
            let undoStack = UndoStack()
            let ops = Operations(undoStack: undoStack)
            let result = try ops.importPost(title: "Undone", text: "Body.")
            try undoStack.undo(with: ops)
            #expect(try db.deletedAt("container", result.container.id) != nil)
            // The cascade took the minted block with the same stamp;
            // restoreContainer stays the recovery door.
            #expect(try db.deletedAt("block", result.blockIDs[0]) != nil)
            try ops.restoreContainer(result.container.id)
            #expect(try db.deletedAt("container", result.container.id) == nil)
            #expect(try db.deletedAt("block", result.blockIDs[0]) == nil)
        }
    }

    @Test func undoTombstonesExactlyThePoolDropsBlocks() throws {
        try withOperations { _, db in
            let undoStack = UndoStack()
            let ops = Operations(undoStack: undoStack)
            let pool = try ops.createPool(title: "Pool")
            try ops.newBlock(in: pool.id, text: "Existing.")
            let result = try ops.importBlocks(into: pool.id, text: "Dropped one.\n\nDropped two.")
            try undoStack.undo(with: ops)

            for blockID in result.blockIDs {
                #expect(try db.deletedAt("block", blockID) != nil)
                // Tray-reachable: the tombstone stamped last_container_id.
                #expect(try db.fetchString(
                    "SELECT last_container_id FROM block WHERE id = ?", [blockID]) == pool.id)
            }
            let texts = try db.read { database in
                try Queries.renderPost(database, containerID: pool.id).map { $0.text ?? "" }
            }
            #expect(texts == ["Existing."])
        }
    }
}
