import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Pool, tray & unplaced queries (Phase 4, Step 4)")
struct PoolTrayQueryTests {
    // MARK: - Pool listing

    @Test func poolsListsLivePoolsOldestFirst() throws {
        // Phase 10 (additive): the shell's pool section finds THE pool.
        try withOperations { ops, db in
            let first = try ops.createPool(title: "inspiration")
            let second = try ops.createPool(title: "later")
            let dead = try ops.createPool(title: "gone")
            try ops.deleteContainer(dead.id)
            _ = try ops.createPost(title: "not a pool")
            let pools = try db.read { try Queries.pools($0) }
            #expect(pools.map(\.id) == [first.id, second.id])
        }
    }

    @Test func poolListingRendersScrapsWithTheirTags() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool()
            let idea = try ops.newBlock(in: pool.id, text: "a loose idea")
            let plain = try ops.newBlock(in: pool.id, text: "an untagged scrap")
            let theme = try ops.createTag(name: "theme")
            let sub = try ops.createTag(parent: theme.id, name: "sub")
            try ops.applyTag(theme.id, toBlock: idea.block.id)
            try ops.applyTag(sub.id, toBlock: idea.block.id)

            let listing = try db.read { try Queries.poolListing($0, poolID: pool.id) }
            #expect(listing.map(\.block.blockID) == [idea.block.id, plain.block.id])
            #expect(listing[0].block.text == "a loose idea")
            #expect(listing[0].tagPaths == ["theme", "theme/sub"])
            #expect(listing[1].tagPaths.isEmpty)
        }
    }

    @Test func poolListingIgnoresTombstonedTagsAndApplications() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool()
            let scrap = try ops.newBlock(in: pool.id, text: "scrap")
            let kept = try ops.createTag(name: "kept")
            let removed = try ops.createTag(name: "removed")
            let deadTag = try ops.createTag(name: "dead")
            try ops.applyTag(kept.id, toBlock: scrap.block.id)
            try ops.applyTag(removed.id, toBlock: scrap.block.id)
            try ops.applyTag(deadTag.id, toBlock: scrap.block.id)
            try ops.removeTag(removed.id, fromBlock: scrap.block.id)
            try ops.deleteTag(deadTag.id)
            let listing = try db.read { try Queries.poolListing($0, poolID: pool.id) }
            #expect(listing[0].tagPaths == ["kept"])
        }
    }

    // MARK: - The per-post tray (owns the KnownIssues "tray semantics" entry)

    @Test func trayListsExactlyTheIndividuallyDeleted() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let otherPost = try ops.createPost()
            let deletedHere = try ops.newBlock(in: post.id, text: "deleted from post")
            let stillLive = try ops.newBlock(in: post.id, text: "alive")
            let deletedElsewhere = try ops.newBlock(in: otherPost.id, text: "other tray")
            try ops.deleteBlock(deletedHere.block.id)
            try ops.deleteBlock(deletedElsewhere.block.id)

            let tray = try db.read { try Queries.trayBlocks($0, postID: post.id) }
            #expect(tray.map(\.blockID) == [deletedHere.block.id])
            #expect(tray[0].text == "deleted from post")
            let otherTray = try db.read { try Queries.trayBlocks($0, postID: otherPost.id) }
            #expect(otherTray.map(\.blockID) == [deletedElsewhere.block.id])
            _ = stillLive
        }
    }

    @Test func releasedThenDeletedBlocksTrayInTheirLastHome() throws {
        // divide-W/merge release stamps last_container_id (Phase 3 review
        // fix) — a released block deleted later trays home.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let first = try ops.newBlock(in: post.id, text: "First piece.")
            let second = try ops.newBlock(in: post.id, text: "Second piece.")
            let merged = try ops.merge(first.block.id, second.block.id)
            _ = merged
            // Both sources are now live-unplaced lineage; delete one.
            try ops.deleteBlock(first.block.id)
            let tray = try db.read { try Queries.trayBlocks($0, postID: post.id) }
            #expect(tray.map(\.blockID) == [first.block.id])
        }
    }

    @Test func containerCascadeVictimsAreNotTrayItems() throws {
        // A block whose stale last_container_id points at a post it once
        // trayed in, later taken down by THAT post's own deletion cascade:
        // restoreContainer's business, never the tray's.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "cycles through")
            // Individually delete + restore: last_container_id now = post.
            try ops.deleteBlock(block.block.id)
            try ops.restoreBlock(block.block.id)
            // The whole post goes: the cascade tombstones the block with the
            // post's exact stamp.
            try ops.deleteContainer(post.id)
            let tray = try db.read { try Queries.trayBlocks($0, postID: post.id) }
            #expect(tray.isEmpty)
            // And restoreContainer brings it back — the tray stays empty.
            try ops.restoreContainer(post.id)
            let after = try db.read { try Queries.trayBlocks($0, postID: post.id) }
            #expect(after.isEmpty)
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.map(\.blockID) == [block.block.id])
        }
    }

    @Test func trayOrdersNewestDeletionFirst() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let older = try ops.newBlock(in: post.id, text: "older")
            let newer = try ops.newBlock(in: post.id, text: "newer")
            try ops.deleteBlock(older.block.id)
            try ops.deleteBlock(newer.block.id)
            let tray = try db.read { try Queries.trayBlocks($0, postID: post.id) }
            #expect(tray.map(\.blockID) == [newer.block.id, older.block.id])
        }
    }

    @Test func trayPreviewShowsOnlyWhatRestoreWouldRevive() throws {
        // restoreBlock revives children by exact-stamp match; a default
        // variant that died independently under a different stamp stays
        // dead, so it must not preview either (review finding).
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "cascade text")
            try ops.deleteBlock(block.block.id)
            let cascade = try db.read { try Queries.trayBlocks($0, postID: post.id) }
            #expect(cascade[0].text == "cascade text")  // same-stamp victim previews

            // Re-stamp the default variant as an independent deletion.
            try db.write { db in
                try db.execute(
                    sql: "UPDATE variant SET deleted_at = '2026-07-06T23:59:59.000Z' WHERE id = ?",
                    arguments: [block.variant.id])
            }
            let foreign = try db.read { try Queries.trayBlocks($0, postID: post.id) }
            #expect(foreign[0].blockID == block.block.id)
            #expect(foreign[0].text == nil)  // restore wouldn't bring it back
        }
    }

    // MARK: - Unplaced blocks (the safety net)

    @Test func unplacedPopulatesAfterDivideWAndMerge() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let fanned = try ops.newBlock(in: post.id, text: "Alpha one. Beta one.")
            let take2 = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            _ = try ops.divideW(
                fanned.block.id,
                cuts: [fanned.variant.id: 10, take2.id: 10])
            // A is preserved whole, released live-unplaced.
            let afterW = try db.read { try Queries.unplacedBlocks($0) }
            #expect(afterW.map(\.blockID) == [fanned.block.id])
            #expect(afterW[0].text == "Alpha one. Beta one.")

            // Merge releases both sources.
            let other = try ops.createPost()
            let b = try ops.newBlock(in: other.id, text: "Left half.")
            let c = try ops.newBlock(in: other.id, text: "Right half.")
            _ = try ops.merge(b.block.id, c.block.id)
            let afterMerge = try db.read { try Queries.unplacedBlocks($0) }
            #expect(Set(afterMerge.map(\.blockID)) == [fanned.block.id, b.block.id, c.block.id])

            // placeBlock (W-reversibility) removes it from the population.
            try ops.placeBlock(fanned.block.id, in: post.id, at: .end)
            let afterRestore = try db.read { try Queries.unplacedBlocks($0) }
            #expect(Set(afterRestore.map(\.blockID)) == [b.block.id, c.block.id])
        }
    }

    @Test func unplacedIgnoresPlacedAndDeletedBlocks() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let placed = try ops.newBlock(in: post.id, text: "placed")
            let deleted = try ops.newBlock(in: post.id, text: "deleted")
            try ops.deleteBlock(deleted.block.id)  // tombstoned ≠ unplaced
            let unplaced = try db.read { try Queries.unplacedBlocks($0) }
            #expect(unplaced.isEmpty)
            _ = placed
        }
    }
}
