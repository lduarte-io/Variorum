import Foundation
import GRDB
import Testing
@testable import VariorumCore

// pre-13u Act 10 wave 2c — item 16's Blocks workbench (W8-1 direction C:
// "blocks as objects"): the query layer that gives every row its FACTS —
// takes, comments, lock, words, edited stamp, tags — derived at read time,
// never stored.
@Suite("Block workbench query (pre-13u Act 10 wave 2c)")
struct WorkbenchQueryTests {
    @Test func rowsCarryTheFactsInReadingOrder() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "workbench")
            let a = try ops.newBlock(in: post.id, text: "One two three.")
            let b = try ops.newBlock(in: post.id, text: "Second block here now.")
            // A fan on A (two active takes) + a comment + a name + a tag.
            _ = try ops.branchVariant(a.block.id, from: a.variant.id)
            _ = try ops.addBlockComment(to: a.block.id, text: "a note")
            try ops.setBlockName(a.block.id, name: "opener")
            let tag = try ops.createTag(name: "voice")
            _ = try ops.applyTag(tag.id, toBlock: a.block.id)

            let rows = try db.read { try Queries.blockWorkbench($0, post: post.id) }
            #expect(rows.map(\.blockID) == [a.block.id, b.block.id])

            let first = rows[0]
            #expect(first.name == "opener")
            #expect(first.activeVariantCount == 2)
            #expect(first.hasFan)
            #expect(first.commentCount == 1)
            #expect(first.wordCount == 3)
            #expect(first.tagPaths == ["voice"])
            #expect(first.editedAt != nil)

            let second = rows[1]
            #expect(second.name == nil)
            #expect(second.activeVariantCount == 1)
            #expect(!second.hasFan)
            #expect(second.commentCount == 0)
            #expect(second.wordCount == 4)
            #expect(second.tagPaths.isEmpty)
        }
    }

    @Test func editedStampIsTheRenderedTakesOwnRow() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: nil)
            let a = try ops.newBlock(in: post.id, text: "before")
            try ops.autosave(a.variant.id, text: "after the edit", charDelta: 8)
            let rows = try db.read { try Queries.blockWorkbench($0, post: post.id) }
            let stamp = try db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT updated_at FROM variant WHERE id = ?",
                    arguments: [a.variant.id])
            }
            #expect(rows[0].editedAt == stamp)
            #expect(rows[0].editedAt != nil)
        }
    }

    @Test func deadTagsAndDeadCommentsNeverCount() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: nil)
            let a = try ops.newBlock(in: post.id, text: "text")
            let comment = try ops.addBlockComment(to: a.block.id, text: "gone soon")
            try ops.deleteBlockComment(comment.id)
            let tag = try ops.createTag(name: "dead")
            _ = try ops.applyTag(tag.id, toBlock: a.block.id)
            try ops.removeTag(tag.id, fromBlock: a.block.id)
            let rows = try db.read { try Queries.blockWorkbench($0, post: post.id) }
            #expect(rows[0].commentCount == 0)
            #expect(rows[0].tagPaths.isEmpty)
        }
    }
}
