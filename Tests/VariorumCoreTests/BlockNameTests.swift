import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 11, Step A1 — migration v1_6 (`block.name`) and `setBlockName`.
/// The name is a block-identity-level HANDLE (AppSpec §14, 2026-07-07):
/// plain metadata under sync, never copied, never derived-and-stored.
@Suite("block.name & setBlockName (Phase 11, A1)")
struct BlockNameTests {
    @Test func setBlockNameSetsClearsAndNormalizesWhitespace() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Some prose.", at: .end).block

            try ops.setBlockName(block.id, name: "The thesis")
            #expect(try db.fetchString(
                "SELECT name FROM block WHERE id = ?", [block.id]) == "The thesis")

            try ops.setBlockName(block.id, name: "   ")
            #expect(try db.fetchString(
                "SELECT name FROM block WHERE id = ?", [block.id]) == nil,
                "whitespace-only normalizes to clearing")

            try ops.setBlockName(block.id, name: "  padded  ")
            #expect(try db.fetchString(
                "SELECT name FROM block WHERE id = ?", [block.id]) == "padded")
        }
    }

    @Test func namingIsMetadataNeverATouchStampOrChurn() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Some prose.", at: .end).block
            let touchedBefore = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
            let churnBefore = try db.fetchString(
                "SELECT churn_accumulator FROM container WHERE id = ?", [post.id])

            try ops.setBlockName(block.id, name: "A name")

            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id]) == touchedBefore,
                "naming never reshuffles the touched sort")
            #expect(try db.fetchString(
                "SELECT churn_accumulator FROM container WHERE id = ?", [post.id]) == churnBefore)
        }
    }

    @Test func namingRidesTheExistingBlockOutboxTriggers() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Some prose.", at: .end).block
            try db.clearOutbox()

            try ops.setBlockName(block.id, name: "handle")
            #expect(try db.outboxContains("block", block.id),
                    "the name UPDATE is captured by the existing block triggers (verified, not assumed)")
        }
    }

    @Test func aSealedPostRefusesBlockNaming() throws {
        // PROVISIONAL posture (QUESTIONS bundle): the everything-under-the-
        // post letter — a block is under the post.
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Some prose.", at: .end).block
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.setBlockName(block.id, name: "too late")
            }
        }
    }

    @Test func deadBlocksRefuse() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Some prose.", at: .end).block
            try ops.deleteBlock(block.id)
            #expect(throws: OperationError.blockNotFound(id: block.id)) {
                try ops.setBlockName(block.id, name: "gone")
            }
        }
    }

    @Test func aNoOpRenameWritesNothing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Some prose.", at: .end).block
            try ops.setBlockName(block.id, name: "same")
            let updatedBefore = try db.fetchString(
                "SELECT updated_at FROM block WHERE id = ?", [block.id])
            try db.clearOutbox()

            try ops.setBlockName(block.id, name: "same")
            #expect(try db.fetchString(
                "SELECT updated_at FROM block WHERE id = ?", [block.id]) == updatedBefore)
            #expect(!(try db.outboxContains("block", block.id)),
                    "an identical name never dirties the row")
        }
    }
}
