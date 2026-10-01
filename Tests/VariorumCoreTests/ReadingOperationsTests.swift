import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Reading operations (Phase 2, Step 4)")
struct ReadingOperationsTests {
    /// Live member post IDs in reading order — the traversal a book view uses.
    private func memberPostIDs(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT post_id FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL
                    ORDER BY position, id
                    """,
                arguments: [readingID])
        }
    }

    @Test func createReadingInsertsTheExpectedRow() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(
                name: "2026 Journal", kind: .book, profile: "journal",
                sortField: .entryDate, maxPosts: 365)
            let fetched = try db.read { db in try Reading.fetchOne(db, key: reading.id) }
            #expect(fetched == reading)
            #expect(fetched?.sortField == .entryDate)
            #expect(fetched?.maxPosts == 365)
            #expect(try db.outboxContains("reading", reading.id))
        }
    }

    @Test func newPostInReadingMintsPostAndMembershipAtomically() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "Orbit", kind: .book)
            let existing = try ops.createPost(title: "already here")
            _ = try ops.addPostToReading(existing.id, to: reading.id)
            let section = try ops.createSection(in: reading.id, name: "Part One")

            // The happy path: post + membership + chapter in ONE gesture.
            let post = try ops.newPostInReading(
                reading.id, section: section.id, title: "born inside")
            #expect(try memberPostIDs(db, reading.id) == [existing.id, post.id],
                    "the new post lands at the book's end")
            let sectionID = try db.fetchString(
                "SELECT section_id FROM reading_post WHERE post_id = ?", [post.id])
            #expect(sectionID == section.id)

            // A refusal mints NO stray post (the assertReadingAcceptsPosts
            // doctrine, with the mint inside the guard).
            let containersBefore = try db.fetchInt("SELECT COUNT(*) FROM container") ?? 0
            try ops.lockReading(reading.id)
            #expect(throws: OperationError.lockedReading(id: reading.id)) {
                _ = try ops.newPostInReading(reading.id, title: "stray?")
            }
            try ops.unlockReading(reading.id)
            let other = try ops.createReading(name: "Elsewhere", kind: .book)
            let foreignSection = try ops.createSection(in: other.id, name: "Foreign")
            #expect(throws: OperationError.sectionNotInReading(
                sectionID: foreignSection.id, readingID: reading.id)) {
                _ = try ops.newPostInReading(reading.id, section: foreignSection.id)
            }
            let smart = try ops.createReading(name: "Smart", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            #expect(throws: OperationError.wrongReadingKind(id: smart.id, expected: .book)) {
                _ = try ops.newPostInReading(smart.id)
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == containersBefore,
                    "every refusal left zero stray posts behind")

            // Capacity refuses the mint the same way.
            try ops.setReadingMaxPosts(reading.id, maxPosts: 2)
            #expect(throws: OperationError.readingAtCapacity(id: reading.id)) {
                _ = try ops.newPostInReading(reading.id, title: "over")
            }
        }
    }

    @Test func addPostAppendsInOrderAndReturnsTheMembership() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "Book", kind: .book)
            let first = try ops.createPost(title: "one")
            let second = try ops.createPost(title: "two")
            let third = try ops.createPost(title: "three")

            try ops.addPostToReading(first.id, to: reading.id)
            try ops.addPostToReading(second.id, to: reading.id)
            let membership = try ops.addPostToReading(third.id, to: reading.id, at: .start)

            #expect(membership.readingId == reading.id)
            #expect(membership.postId == third.id)
            #expect(try memberPostIDs(db, reading.id) == [third.id, first.id, second.id])
        }
    }

    @Test func addPostRefusalPaths() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let pool = try ops.createPool()

            // Smart readings assemble by query, never by hand.
            let smart = try ops.createReading(name: "S", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            #expect(throws: OperationError.wrongReadingKind(id: smart.id, expected: .book)) {
                try ops.addPostToReading(post.id, to: smart.id)
            }

            let curated = try ops.createReading(name: "C", kind: .book)

            // Only posts are members; a pool is not a post.
            #expect(throws: OperationError.wrongContainerKind(id: pool.id, expected: .post)) {
                try ops.addPostToReading(pool.id, to: curated.id)
            }

            // Double-add of a live membership.
            try ops.addPostToReading(post.id, to: curated.id)
            #expect(throws: OperationError.alreadyInReading(postID: post.id, readingID: curated.id)) {
                try ops.addPostToReading(post.id, to: curated.id)
            }

            // Extent constraint: a full fixed-length reading refuses.
            let bounded = try ops.createReading(name: "B", kind: .book, maxPosts: 1)
            try ops.addPostToReading(post.id, to: bounded.id)
            let overflow = try ops.createPost()
            #expect(throws: OperationError.readingAtCapacity(id: bounded.id)) {
                try ops.addPostToReading(overflow.id, to: bounded.id)
            }

            // A locked reading is frozen.
            try ops.lockReading(curated.id)
            let late = try ops.createPost()
            #expect(throws: OperationError.lockedReading(id: curated.id)) {
                try ops.addPostToReading(late.id, to: curated.id)
            }
        }
    }

    @Test func removeTombstonesAndReAddingWorksUnderTheLiveUniqueIndex() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "R", kind: .book)
            let post = try ops.createPost()

            let original = try ops.addPostToReading(post.id, to: reading.id)
            try ops.removePostFromReading(post.id, from: reading.id)
            #expect(try db.deletedAt("reading_post", original.id) != nil)
            #expect(try memberPostIDs(db, reading.id) == [])

            // The tombstone must not pin the pair (live-unique index, §6).
            let recreated = try ops.addPostToReading(post.id, to: reading.id)
            #expect(recreated.id != original.id)
            #expect(try memberPostIDs(db, reading.id) == [post.id])
        }
    }

    @Test func removeMissingMembershipThrows() throws {
        try withOperations { ops, _ in
            let reading = try ops.createReading(name: "R", kind: .book)
            let post = try ops.createPost()
            #expect(throws: OperationError.postNotInReading(postID: post.id, readingID: reading.id)) {
                try ops.removePostFromReading(post.id, from: reading.id)
            }
        }
    }

    @Test func reorderMovesAMembershipBetweenNeighbors() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "R", kind: .book)
            let posts = try (0..<4).map { _ in try ops.createPost() }
            for post in posts {
                try ops.addPostToReading(post.id, to: reading.id)
            }

            try ops.reorderReadingPost(posts[3].id, in: reading.id, to: .after(posts[0].id))
            #expect(try memberPostIDs(db, reading.id) == [posts[0].id, posts[3].id, posts[1].id, posts[2].id])

            try ops.reorderReadingPost(posts[0].id, in: reading.id, to: .end)
            #expect(try memberPostIDs(db, reading.id) == [posts[3].id, posts[1].id, posts[2].id, posts[0].id])

            try ops.reorderReadingPost(posts[2].id, in: reading.id, to: .before(posts[3].id))
            #expect(try memberPostIDs(db, reading.id) == [posts[2].id, posts[3].id, posts[1].id, posts[0].id])
        }
    }

    @Test func lockedReadingFreezesRemovalAndReorder() throws {
        try withOperations { ops, _ in
            let reading = try ops.createReading(name: "R", kind: .book)
            let post = try ops.createPost()
            try ops.addPostToReading(post.id, to: reading.id)
            try ops.lockReading(reading.id)

            #expect(throws: OperationError.lockedReading(id: reading.id)) {
                try ops.removePostFromReading(post.id, from: reading.id)
            }
            #expect(throws: OperationError.lockedReading(id: reading.id)) {
                try ops.reorderReadingPost(post.id, in: reading.id, to: .start)
            }

            // For non-manual readings the sort field IS the order — frozen.
            #expect(throws: OperationError.lockedReading(id: reading.id)) {
                try ops.setReadingSort(reading.id, field: .entryDate, direction: .desc)
            }

            // Reversible: unlock and the same ops succeed.
            try ops.unlockReading(reading.id)
            try ops.setReadingSort(reading.id, field: .entryDate, direction: .desc)
            try ops.reorderReadingPost(post.id, in: reading.id, to: .start)
            try ops.removePostFromReading(post.id, from: reading.id)
        }
    }

    @Test func deleteReadingCascadesToMembershipsButNeverPosts() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "R", kind: .book)
            let post = try ops.createPost()
            let membership = try ops.addPostToReading(post.id, to: reading.id)

            try ops.deleteReading(reading.id)

            #expect(try db.deletedAt("reading", reading.id) != nil)
            #expect(try db.deletedAt("reading_post", membership.id) != nil)
            // Non-owning pointers: the post itself is untouched.
            #expect(try db.deletedAt("container", post.id) == nil)
        }
    }
}
