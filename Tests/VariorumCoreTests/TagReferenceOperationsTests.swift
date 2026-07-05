import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Tags & references (Phase 2, Step 7)")
struct TagReferenceOperationsTests {
    private func path(_ db: AppDatabase, _ tagID: String) throws -> String? {
        try db.fetchString("SELECT path FROM tag WHERE id = ?", [tagID])
    }

    // MARK: Tag creation

    @Test func createTagBuildsMaterializedPaths() throws {
        try withOperations { ops, _ in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let year = try ops.createTag(parent: goals.id, name: "2024")
            #expect(life.path == "life")
            #expect(goals.path == "life/goals")
            #expect(year.path == "life/goals/2024")
            #expect(year.parentId == goals.id)
        }
    }

    @Test func duplicateLivePathRefusedButTombstonedPathIsReusable() throws {
        try withOperations { ops, _ in
            let tag = try ops.createTag(name: "ideas")
            #expect(throws: OperationError.duplicateTagPath(path: "ideas")) {
                try ops.createTag(name: "ideas")
            }
            try ops.deleteTag(tag.id)
            let recreated = try ops.createTag(name: "ideas")
            #expect(recreated.id != tag.id)
        }
    }

    @Test func invalidTagNamesRefused() throws {
        try withOperations { ops, _ in
            #expect(throws: OperationError.invalidTagName(name: "")) {
                try ops.createTag(name: "")
            }
            #expect(throws: OperationError.invalidTagName(name: "a/b")) {
                try ops.createTag(name: "a/b")
            }
        }
    }

    // MARK: renameTag

    @Test func renameTagRewritesTheWholeSubtreeExactly() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let year = try ops.createTag(parent: goals.id, name: "2024")
            let deep = try ops.createTag(parent: year.id, name: "q1")
            let other = try ops.createTag(parent: life.id, name: "other")

            try ops.renameTag(goals.id, newName: "aims")

            #expect(try path(db, goals.id) == "life/aims")
            #expect(try path(db, year.id) == "life/aims/2024")
            #expect(try path(db, deep.id) == "life/aims/2024/q1")
            // Siblings and the parent are untouched.
            #expect(try path(db, other.id) == "life/other")
            #expect(try path(db, life.id) == "life")
            #expect(try db.fetchString("SELECT name FROM tag WHERE id = ?", [goals.id]) == "aims")
        }
    }

    @Test func renameTagRefusesACollidingSiblingPath() throws {
        try withOperations { ops, _ in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            _ = try ops.createTag(parent: life.id, name: "aims")
            #expect(throws: OperationError.duplicateTagPath(path: "life/aims")) {
                try ops.renameTag(goals.id, newName: "aims")
            }
        }
    }

    @Test func renameRootTagRewritesDescendantsToo() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let child = try ops.createTag(parent: work.id, name: "projects")
            try ops.renameTag(work.id, newName: "career")
            #expect(try path(db, work.id) == "career")
            #expect(try path(db, child.id) == "career/projects")
        }
    }

    // MARK: deleteTag

    @Test func deleteTagTombstonesSubtreeAndApplications() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let year = try ops.createTag(parent: goals.id, name: "2024")
            let other = try ops.createTag(parent: life.id, name: "other")

            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "b")
            let postApp = try ops.applyTag(goals.id, toPost: post.id)
            let blockApp = try ops.applyTag(year.id, toBlock: made.block.id)

            try ops.deleteTag(goals.id)

            // The subtree is gone (ops-layer loop)…
            #expect(try db.deletedAt("tag", goals.id) != nil)
            #expect(try db.deletedAt("tag", year.id) != nil)
            // …applications went with their tags (per-tag trigger)…
            #expect(try db.deletedAt("post_tag", postApp.id) != nil)
            #expect(try db.deletedAt("block_tag", blockApp.id) != nil)
            // …and the rest of the tree stands.
            #expect(try db.deletedAt("tag", life.id) == nil)
            #expect(try db.deletedAt("tag", other.id) == nil)
        }
    }

    // MARK: Application

    @Test func applyAndRemoveTagOnPostsAndBlocks() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "t")
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "b")

            let postApp = try ops.applyTag(tag.id, toPost: post.id)
            let blockApp = try ops.applyTag(tag.id, toBlock: made.block.id)
            #expect(try db.outboxContains("post_tag", postApp.id))
            #expect(try db.outboxContains("block_tag", blockApp.id))

            // Live duplicates refused.
            #expect(throws: OperationError.alreadyTagged(tagID: tag.id, targetID: post.id)) {
                try ops.applyTag(tag.id, toPost: post.id)
            }

            // Remove, then re-apply under the live-unique index.
            try ops.removeTag(tag.id, fromPost: post.id)
            #expect(try db.deletedAt("post_tag", postApp.id) != nil)
            let again = try ops.applyTag(tag.id, toPost: post.id)
            #expect(again.id != postApp.id)

            try ops.removeTag(tag.id, fromBlock: made.block.id)
            #expect(throws: OperationError.tagNotApplied(tagID: tag.id, targetID: made.block.id)) {
                try ops.removeTag(tag.id, fromBlock: made.block.id)
            }
        }
    }

    @Test func postTagsRefuseNonPostTargets() throws {
        try withOperations { ops, _ in
            let tag = try ops.createTag(name: "t")
            let pool = try ops.createPool()
            #expect(throws: OperationError.wrongContainerKind(id: pool.id, expected: .post)) {
                try ops.applyTag(tag.id, toPost: pool.id)
            }
        }
    }

    // MARK: References

    @Test func referenceLifecycle() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let pdf = try ops.addReference(
                to: post.id, kind: .file, name: "Sources.pdf", fileBookmark: Data([1, 2]))
            let link = try ops.addReference(
                to: post.id, kind: .url, name: "Essay", url: "https://example.org")
            let first = try ops.addReference(to: post.id, kind: .url, url: "https://a.example", at: .start)

            func orderedIDs() throws -> [String] {
                try db.read { db in
                    try String.fetchAll(
                        db,
                        sql: """
                            SELECT id FROM reference
                            WHERE container_id = ? AND deleted_at IS NULL
                            ORDER BY position, id
                            """,
                        arguments: [post.id])
                }
            }
            #expect(try orderedIDs() == [first.id, pdf.id, link.id])

            try ops.reorderReference(link.id, to: .before(pdf.id))
            #expect(try orderedIDs() == [first.id, link.id, pdf.id])

            try ops.updateReferenceViewState(pdf.id, viewState: #"{"page":12}"#)
            #expect(try db.fetchString(
                "SELECT view_state FROM reference WHERE id = ?", [pdf.id]) == #"{"page":12}"#)

            try ops.removeReference(first.id)
            #expect(try orderedIDs() == [link.id, pdf.id])
            #expect(throws: OperationError.referenceNotFound(id: first.id)) {
                try ops.removeReference(first.id)
            }
        }
    }

    @Test func referencesAttachOnlyToPosts() throws {
        try withOperations { ops, _ in
            let pool = try ops.createPool()
            #expect(throws: OperationError.wrongContainerKind(id: pool.id, expected: .post)) {
                try ops.addReference(to: pool.id, kind: .url, url: "https://x.example")
            }
        }
    }
}
