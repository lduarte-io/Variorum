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

    @Test func restoreContainerResurrectsTheWholeCascade() throws {
        try withOperations { ops, db in
            // A post with two blocks (one fanned), an edge, tags on the post
            // and a block, a reference, and a reading membership.
            let post = try ops.createPost(title: "phoenix")
            let first = try ops.newBlock(in: post.id, text: "one")
            let second = try ops.newBlock(in: post.id, text: "two")
            let branch = try ops.branchVariant(first.block.id, from: first.variant.id)
            try db.write { db in
                try Fixture.edge(db, id: "e1", source: second.block.id, target: first.block.id)
            }
            let tag = try ops.createTag(name: "kept")
            let postApp = try ops.applyTag(tag.id, toPost: post.id)
            let blockApp = try ops.applyTag(tag.id, toBlock: first.block.id)
            let reference = try ops.addReference(to: post.id, kind: .url, url: "https://x.example")
            let reading = try ops.createReading(name: "r", kind: .curated)
            let membership = try ops.addPostToReading(post.id, to: reading.id)
            // A block deleted BEFORE the post keeps its own stamp and must
            // stay dead through the restore.
            let independent = try ops.newBlock(in: post.id, text: "already gone")
            try ops.deleteBlock(independent.block.id)

            try ops.deleteContainer(post.id)
            try ops.restoreContainer(post.id)

            for (table, id) in [
                ("container", post.id),
                ("block", first.block.id), ("block", second.block.id),
                ("variant", first.variant.id), ("variant", branch.id), ("variant", second.variant.id),
                ("container_block", first.placement.id), ("container_block", second.placement.id),
                ("edge", "e1"), ("post_tag", postApp.id), ("block_tag", blockApp.id),
                ("reference", reference.id), ("reading_post", membership.id),
            ] {
                #expect(try db.deletedAt(table, id) == nil, "\(table) \(id) still dead")
            }
            #expect(try db.deletedAt("block", independent.block.id) != nil)
        }
    }

    @Test func restoreContainerSkipsPointersWhoseParentsDiedMeanwhile() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let tag = try ops.createTag(name: "doomed")
            let postApp = try ops.applyTag(tag.id, toPost: post.id)
            let reading = try ops.createReading(name: "doomed", kind: .curated)
            let membership = try ops.addPostToReading(post.id, to: reading.id)

            try ops.deleteContainer(post.id)
            // The tag and reading die AFTER the post; their pointer rows
            // already carry the post's stamp and must not revive under dead
            // parents.
            try ops.deleteTag(tag.id)
            try ops.deleteReading(reading.id)

            try ops.restoreContainer(post.id)

            #expect(try db.deletedAt("container", post.id) == nil)
            #expect(try db.deletedAt("post_tag", postApp.id) != nil)
            #expect(try db.deletedAt("reading_post", membership.id) != nil)
        }
    }

    @Test func restoreContainerNeverStealsOrDanglesIndependentlyRevivedBlocks() throws {
        // Sweep-found 2026-07-05: blocks can leave the cascade's story
        // between delete and restore, and the placement flip must notice.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let elsewhere = try ops.createPost()
            let moved = try ops.newBlock(in: post.id, text: "re-homed meanwhile")
            let reDeleted = try ops.newBlock(in: post.id, text: "died again meanwhile")
            try ops.deleteContainer(post.id)

            // One block is revived and placed elsewhere; the other is
            // revived then deleted again under its own, newer stamp.
            try ops.restoreBlock(moved.block.id)       // unplaced (post is dead)
            try ops.placeBlock(moved.block.id, in: elsewhere.id)
            try ops.restoreBlock(reDeleted.block.id)
            try ops.deleteBlock(reDeleted.block.id)

            try ops.restoreContainer(post.id)

            // The re-homed block keeps its new home — exactly one live
            // placement, in `elsewhere` (I2).
            let placements = try db.read { db in
                try String.fetchAll(
                    db,
                    sql: "SELECT container_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [moved.block.id])
            }
            #expect(placements == [elsewhere.id])
            // The re-deleted block stays dead, and no live placement points
            // at it.
            #expect(try db.deletedAt("block", reDeleted.block.id) != nil)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [reDeleted.block.id]) == 0)
        }
    }

    @Test func restoreContainerRefusesALiveContainer() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            #expect(throws: OperationError.containerNotDeleted(id: post.id)) {
                try ops.restoreContainer(post.id)
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
