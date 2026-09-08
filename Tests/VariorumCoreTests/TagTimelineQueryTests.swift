import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Tag & timeline queries (Phase 4, Step 4)")
struct TagTimelineQueryTests {
    // MARK: - Tag subtree

    @Test func subtreeMatchesByPathPrefixNotStringPrefix() throws {
        try withOperations { ops, db in
            let art = try ops.createTag(name: "art")
            let painting = try ops.createTag(parent: art.id, name: "painting")
            let oil = try ops.createTag(parent: painting.id, name: "oil")
            _ = try ops.createTag(name: "artifacts")  // shares the string prefix, not the path
            let subtree = try db.read { try Queries.tagSubtree($0, rootID: art.id) }
            #expect(subtree.map(\.path) == ["art", "art/painting", "art/painting/oil"])
            #expect(subtree.map(\.id) == [art.id, painting.id, oil.id])
        }
    }

    @Test func deletedPostsListsTombstonesNewestFirst() throws {
        // Phase 10 (additive): restoreContainer's recovery listing.
        try withOperations { ops, db in
            let a = try ops.createPost(title: "first deleted")
            let b = try ops.createPost(title: "second deleted")
            _ = try ops.createPost(title: "alive")
            let pool = try ops.createPool()
            try ops.deleteContainer(a.id)
            try ops.deleteContainer(b.id)
            try ops.deleteContainer(pool.id)  // pools are not posts
            let deleted = try db.read { try Queries.deletedPosts($0, now: harnessNow) }
            #expect(deleted.map(\.postID) == [b.id, a.id])
            // And restore drops the row from the listing.
            try ops.restoreContainer(a.id)
            let after = try db.read { try Queries.deletedPosts($0, now: harnessNow) }
            #expect(after.map(\.postID) == [b.id])
        }
    }

    // MARK: - Phase 10 additions (the tag-management + folder faces)

    @Test func allTagsListsTheLiveTaxonomyByPath() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            _ = try ops.createTag(parent: life.id, name: "goals")
            let art = try ops.createTag(name: "art")
            let dead = try ops.createTag(name: "dead")
            try ops.deleteTag(dead.id)
            let tags = try db.read { try Queries.allTags($0) }
            #expect(tags.map(\.path) == ["art", "life", "life/goals"])
            _ = art
        }
    }

    /// **The bounded twin** (17o batch d, ledger row 18): the chrome's held
    /// title observation re-fetches on every `container` write, so the names
    /// it resolves must be read by id — never the whole taxonomy. Missing
    /// and tombstoned ids are simply absent, which is exactly how the
    /// chrome's per-kind fallback already reads a name it cannot resolve.
    @Test func tagPathsReadsOnlyTheNamedTagsAndSkipsTheDead() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            _ = try ops.createTag(name: "art")
            let dead = try ops.createTag(name: "dead")
            try ops.deleteTag(dead.id)

            let paths = try db.read {
                try Queries.tagPaths($0, ids: [goals.id, dead.id, "no-such-tag"])
            }
            #expect(paths == [goals.id: "life/goals"],
                    "only what was asked for, and only what is live")
            #expect(try db.read { try Queries.tagPaths($0, ids: []) }.isEmpty,
                    "an empty ask reads nothing at all")
            #expect(try db.read { try Queries.tagPaths($0, ids: [life.id, goals.id]) }
                    == [life.id: "life", goals.id: "life/goals"])
        }
    }

    @Test func taggedPostItemsUseSubtreeSemanticsAndFindArchived() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let tagged = try ops.createPost(title: "tagged at root")
            let subtreeTagged = try ops.createPost(title: "tagged below")
            let archived = try ops.createPost(title: "archived but tagged")
            let untagged = try ops.createPost(title: "untagged")
            let deleted = try ops.createPost(title: "deleted")
            try ops.applyTag(life.id, toPost: tagged.id)
            try ops.applyTag(goals.id, toPost: subtreeTagged.id)
            try ops.applyTag(life.id, toPost: archived.id)
            try ops.applyTag(life.id, toPost: deleted.id)
            try ops.archiveContainer(archived.id)
            try ops.deleteContainer(deleted.id)

            let items = try db.read { try Queries.taggedPostItems($0, tagID: life.id) }
            // Archived posts appear (tag lookups still find them — Phase 4
            // ratification); tombstoned never; untagged never.
            #expect(Set(items.map(\.postID)) == [tagged.id, subtreeTagged.id, archived.id])
            #expect(!items.map(\.postID).contains(untagged.id))

            // Without subtree: only the exact tag's applications.
            let exact = try db.read {
                try Queries.taggedPostItems($0, tagID: life.id, includeSubtree: false)
            }
            #expect(Set(exact.map(\.postID)) == [tagged.id, archived.id])

            // A dead root lists empty (tolerant read).
            try ops.deleteTag(life.id)
            let gone = try db.read { try Queries.taggedPostItems($0, tagID: life.id) }
            #expect(gone.isEmpty)
        }
    }

    @Test func postTagsListsOnePostsLiveApplicationsByPath() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let art = try ops.createTag(name: "art")
            let removed = try ops.createTag(name: "removed")
            let post = try ops.createPost(title: "p")
            try ops.applyTag(life.id, toPost: post.id)
            try ops.applyTag(art.id, toPost: post.id)
            try ops.applyTag(removed.id, toPost: post.id)
            try ops.removeTag(removed.id, fromPost: post.id)
            let tags = try db.read { try Queries.postTags($0, postID: post.id) }
            #expect(tags.map(\.path) == ["art", "life"])
        }
    }

    @Test func subtreeStaysCorrectAfterRenameTag() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let y2026 = try ops.createTag(parent: goals.id, name: "2026")
            try ops.renameTag(life.id, newName: "living")
            let subtree = try db.read { try Queries.tagSubtree($0, rootID: life.id) }
            #expect(subtree.map(\.path) == ["living", "living/goals", "living/goals/2026"])
            _ = y2026
            // And a mid-tree rename keeps the mid-tree subtree coherent.
            try ops.renameTag(goals.id, newName: "aims")
            let midtree = try db.read { try Queries.tagSubtree($0, rootID: goals.id) }
            #expect(midtree.map(\.path) == ["living/aims", "living/aims/2026"])
        }
    }

    @Test func subtreeOfMissingOrDeadRootIsEmpty() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "gone")
            try ops.deleteTag(tag.id)
            try db.read { db in
                let dead = try Queries.tagSubtree(db, rootID: tag.id)
                let missing = try Queries.tagSubtree(db, rootID: "never-arrived")
                #expect(dead.isEmpty)
                #expect(missing.isEmpty)
            }
        }
    }

    // MARK: - Everything tagged X (the UNION)

    @Test func everythingTaggedUnionsPostsAndBlocksDistinct() throws {
        try withOperations { ops, db in
            let root = try ops.createTag(name: "theme")
            let child = try ops.createTag(parent: root.id, name: "sub")
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "tagged block")
            // The post carries BOTH subtree tags — it must appear once.
            try ops.applyTag(root.id, toPost: post.id)
            try ops.applyTag(child.id, toPost: post.id)
            try ops.applyTag(child.id, toBlock: block.block.id)

            let subtreeWide = try db.read {
                try Queries.everythingTagged($0, tagID: root.id, includeSubtree: true)
            }
            #expect(subtreeWide.postIDs == [post.id])
            #expect(subtreeWide.blockIDs == [block.block.id])

            // Exact match only: the block is tagged with the child, not root.
            let exact = try db.read { try Queries.everythingTagged($0, tagID: root.id) }
            #expect(exact.postIDs == [post.id])
            #expect(exact.blockIDs.isEmpty)
        }
    }

    @Test func everythingTaggedFiltersDeadTargetsAndApplications() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "t")
            let keptPost = try ops.createPost()
            let deadPost = try ops.createPost()
            let unTagged = try ops.createPost()
            try ops.applyTag(tag.id, toPost: keptPost.id)
            try ops.applyTag(tag.id, toPost: deadPost.id)
            try ops.applyTag(tag.id, toPost: unTagged.id)
            try ops.deleteContainer(deadPost.id)
            try ops.removeTag(tag.id, fromPost: unTagged.id)
            let items = try db.read { try Queries.everythingTagged($0, tagID: tag.id) }
            #expect(items.postIDs == [keptPost.id].sorted())
        }
    }

    // MARK: - Timeline keyset pagination

    @Test func timelinePagesWalkTheWholeSetWithoutOverlapOrGap() throws {
        try withOperations { ops, db in
            // Seven dated journal entries, two sharing a date (the tie the
            // (stamp, id) sort key must break deterministically).
            var ids: [String] = []
            for day in ["01", "02", "03", "03", "04", "05", "06"] {
                ids.append(try ops.createPost(entryDate: "2026-06-\(day)").id)
            }
            var seen: [String] = []
            var last: Queries.TimelineItem?
            var pages = 0
            while true {
                let page = try db.read {
                    try Queries.timelinePage($0, order: .entryDate, after: last, limit: 3)
                }
                if page.isEmpty { break }
                seen.append(contentsOf: page.map(\.postID))
                last = page.last
                pages += 1
                #expect(pages <= 3)  // 7 items / 3 per page
            }
            #expect(pages == 3)
            #expect(seen.count == 7)          // no gaps, no overlaps
            #expect(Set(seen) == Set(ids))
            // Descending by date; the shared-date pair ordered by id desc.
            let stamps = try db.read {
                try Queries.timelinePage($0, order: .entryDate, limit: 7).map(\.stamp)
            }
            #expect(stamps == stamps.sorted(by: >))
        }
    }

    @Test func timelineExcludesUnstampedArchivedDeletedAndPools() throws {
        try withOperations { ops, db in
            let dated = try ops.createPost(entryDate: "2026-06-01")
            _ = try ops.createPost()  // undated: not on the entry-date timeline
            let archived = try ops.createPost(entryDate: "2026-06-02")
            try ops.archiveContainer(archived.id)
            let deleted = try ops.createPost(entryDate: "2026-06-03")
            try ops.deleteContainer(deleted.id)
            _ = try ops.createPool()
            let page = try db.read { try Queries.timelinePage($0, order: .entryDate) }
            #expect(page.map(\.postID) == [dated.id])
        }
    }

    @Test func lastTouchedTimelineOrdersByEditAndOmitsNeverTouched() throws {
        try withOperations { ops, db in
            let a = try ops.createPost()
            let b = try ops.createPost()
            let untouched = try ops.createPost()
            let blockA = try ops.newBlock(in: a.id, text: "aaa")
            let blockB = try ops.newBlock(in: b.id, text: "bbb")
            try ops.autosave(blockB.variant.id, text: "bbb!", charDelta: 1)
            try ops.autosave(blockA.variant.id, text: "aaa!", charDelta: 1)
            let page = try db.read { try Queries.timelinePage($0, order: .lastTouched) }
            // Most recently touched first; the never-touched post carries no
            // stamp and is not on this timeline (the library lists it).
            #expect(page.map(\.postID) == [a.id, b.id])
            _ = untouched
        }
    }

    // MARK: - Library (the total listing)

    @Test func libraryListsNeverTouchedPostsViaCreatedAtFallback() throws {
        try withOperations { ops, db in
            let touched = try ops.createPost()
            let block = try ops.newBlock(in: touched.id, text: "text")
            let untouched = try ops.createPost()  // created later, never edited
            try ops.autosave(block.variant.id, text: "text!", charDelta: 1)
            let library = try db.read { try Queries.library($0, sort: .lastTouched) }
            // Both present; the autosaved one leads (its stamp is newest).
            #expect(library.map(\.postID) == [touched.id, untouched.id])

            let byCreation = try db.read { try Queries.library($0, sort: .createdAt, direction: .asc) }
            #expect(byCreation.map(\.postID) == [touched.id, untouched.id])

            // The bounded page (what a held observation fetches) is the
            // same listing, truncated.
            let page = try db.read { try Queries.library($0, sort: .lastTouched, limit: 1) }
            #expect(page.map(\.postID) == [touched.id])
        }
    }

    @Test func archivedPostsListingIsTheRecoverySurface() throws {
        // Without this listing, unarchiveContainer would be unreachable
        // through the read layer (review finding): every ambient surface
        // excludes archived posts, and direct render needs the ID.
        try withOperations { ops, db in
            let active = try ops.createPost(title: "active")
            let first = try ops.createPost(title: "shelved first")
            let second = try ops.createPost(title: "shelved second")
            try ops.archiveContainer(first.id)
            try ops.archiveContainer(second.id)
            let deleted = try ops.createPost(title: "gone")
            try ops.archiveContainer(deleted.id)
            try ops.deleteContainer(deleted.id)

            let shelf = try db.read { try Queries.archivedPosts($0) }
            #expect(shelf.map(\.postID) == [second.id, first.id])  // newest archive first
            #expect(!shelf.map(\.postID).contains(active.id))

            try ops.unarchiveContainer(first.id)
            let after = try db.read { try Queries.archivedPosts($0) }
            #expect(after.map(\.postID) == [second.id])
            let library = try db.read { try Queries.library($0) }
            #expect(library.map(\.postID).contains(first.id))  // back in view
        }
    }
}
