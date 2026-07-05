import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Container operations (Phase 2, Step 4)")
struct ContainerOperationsTests {
    @Test func createPostInsertsTheExpectedRow() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "First entry", entryDate: "2026-07-01")

            let fetched = try db.read { db in try Container.fetchOne(db, key: post.id) }
            #expect(fetched == post)
            #expect(fetched?.kind == .post)
            #expect(fetched?.title == "First entry")
            #expect(fetched?.entryDate == "2026-07-01")
            #expect(fetched?.createdAt == fetched?.updatedAt)
            #expect(fetched?.segmentationDefault == nil)
            #expect(try db.outboxContains("container", post.id))
        }
    }

    @Test func journalProfileSeedsOneBlockSegmentation() throws {
        try withOperations { ops, _ in
            let journal = try ops.createPost(profile: .journal, entryDate: "2026-07-01")
            #expect(journal.segmentationDefault == .oneBlock)

            let blog = try ops.createPost(profile: .blog)
            #expect(blog.segmentationDefault == nil)
        }
    }

    @Test func createPoolGetsPoolKindAndProfile() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "Scraps")
            let fetched = try db.read { db in try Container.fetchOne(db, key: pool.id) }
            #expect(fetched?.kind == .pool)
            #expect(fetched?.profile == .pool)
        }
    }

    @Test func settersUpdateTheirFieldAndAdvanceUpdatedAt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Old")
            try ops.renameContainer(post.id, title: "New")
            try ops.setEntryDate(post.id, entryDate: "2026-07-02")
            try ops.setSegmentationDefault(post.id, segmentation: .sentence)
            try ops.updateFloatingNotes(post.id, notes: "margin thoughts")

            let fetched = try db.read { db in try Container.fetchOne(db, key: post.id) }
            #expect(fetched?.title == "New")
            #expect(fetched?.entryDate == "2026-07-02")
            #expect(fetched?.segmentationDefault == .sentence)
            #expect(fetched?.floatingNotes == "margin thoughts")
            #expect(fetched!.updatedAt > post.updatedAt)
        }
    }

    @Test func floatingNotesRefusedOnALockedPost() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            try db.write { db in
                try db.execute(sql: "UPDATE container SET locked = 1 WHERE id = ?", arguments: [post.id])
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.updateFloatingNotes(post.id, notes: "nope")
            }
        }
    }

    @Test func archiveIsReversibleAndDistinctFromDelete() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            try ops.archiveContainer(post.id)
            #expect(try db.fetchString("SELECT archived_at FROM container WHERE id = ?", [post.id]) != nil)
            #expect(try db.deletedAt("container", post.id) == nil)

            try ops.unarchiveContainer(post.id)
            #expect(try db.fetchString("SELECT archived_at FROM container WHERE id = ?", [post.id]) == nil)
        }
    }

    @Test func deleteContainerTombstonesAndTheTriggerChainCascades() throws {
        try withOperations { ops, db in
            // A post with two placed blocks and their variants, built at the
            // SQL level (block ops arrive in Step 5).
            let post = try ops.createPost()
            try db.write { db in
                for (block, variant, cb) in [("b1", "v1", "cb1"), ("b2", "v2", "cb2")] {
                    try Fixture.block(db, id: block)
                    try Fixture.variant(db, id: variant, blockId: block)
                    try Fixture.containerBlock(db, id: cb, containerId: post.id, blockId: block, position: block)
                }
            }
            try db.clearOutbox()

            try ops.deleteContainer(post.id)

            let stamp = try db.deletedAt("container", post.id)
            #expect(stamp != nil)
            for (table, id) in [
                ("container_block", "cb1"), ("container_block", "cb2"),
                ("block", "b1"), ("block", "b2"),
                ("variant", "v1"), ("variant", "v2"),
            ] {
                // Cascade victims carry the container's exact stamp, and the
                // outbox captured every cascade-produced write.
                #expect(try db.deletedAt(table, id) == stamp, "\(table) \(id)")
                #expect(try db.outboxContains(table, id), "\(table) \(id) missing from outbox")
            }
        }
    }

    @Test func operationsOnMissingOrTombstonedContainersThrow() throws {
        try withOperations { ops, _ in
            #expect(throws: OperationError.containerNotFound(id: "ghost")) {
                try ops.renameContainer("ghost", title: "x")
            }

            let post = try ops.createPost()
            try ops.deleteContainer(post.id)
            #expect(throws: OperationError.containerNotFound(id: post.id)) {
                try ops.deleteContainer(post.id)
            }
        }
    }
}
