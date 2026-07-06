import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Observation wiring (Phase 4, Step 5)")
struct ObservationQueryTests {
    @Test func observePostEmitsEditsButConsumersNeverSeeUnrelatedWrites() async throws {
        try await withOperationsAsync { ops, db in
            let post = try ops.createPost()
            let unrelated = try ops.createPost()
            let mine = try ops.newBlock(in: post.id, text: "one")
            let theirs = try ops.newBlock(in: unrelated.id, text: "elsewhere")

            var values = db.observePost(post.id).makeAsyncIterator()
            let initial = try await values.next()
            #expect(initial?.map(\.text) == ["one"])

            // The unrelated edit first, then the real one. Emissions are
            // ordered, and an unrelated write re-fetches an *identical*
            // projection which removeDuplicates drops — so the next value
            // the consumer sees must already be the real edit.
            try ops.autosave(theirs.variant.id, text: "elsewhere!", charDelta: 1)
            try ops.autosave(mine.variant.id, text: "one!", charDelta: 1)
            let next = try await values.next()
            #expect(next?.map(\.text) == ["one!"])
        }
    }

    @Test func observePostFollowsStructuralAndFanChanges() async throws {
        try await withOperationsAsync { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Head part. Tail part.")

            var values = db.observePost(post.id).makeAsyncIterator()
            _ = try await values.next()

            let divided = try ops.divide(a.block.id, cut: 10)
            let afterDivide = try await values.next()
            #expect(afterDivide?.map(\.blockID) == [a.block.id, divided.block.id])
            #expect(afterDivide?.map(\.text) == ["Head part.", "Tail part."])

            let take2 = try ops.branchVariant(a.block.id, from: try #require(afterDivide?[0].variantID))
            try ops.autosave(take2.id, text: "Recast head.", charDelta: 2)
            try ops.chooseVariant(a.block.id, variantID: take2.id)
            // Branch/autosave/choose each change the projection; emissions
            // may coalesce, so drain to the settled state (bounded).
            var afterChoose: [Queries.RenderedBlock]?
            for _ in 0..<4 {
                afterChoose = try await values.next()
                if afterChoose?[0].text == "Recast head." { break }
            }
            #expect(afterChoose?[0].text == "Recast head.")
            #expect(afterChoose?[0].hasFan == true)
        }
    }

    @Test func observeReadingFollowsMembershipAndMemberMetadata() async throws {
        try await withOperationsAsync { ops, db in
            let reading = try ops.createReading(name: "book", kind: .curated)
            let p1 = try ops.createPost(title: "first")
            let p2 = try ops.createPost(title: "second")
            try ops.addPostToReading(p1.id, to: reading.id)

            var values = db.observeReading(reading.id).makeAsyncIterator()
            let initial = try await values.next()
            #expect(initial?.map(\.postID) == [p1.id])

            try ops.addPostToReading(p2.id, to: reading.id)
            let afterAdd = try await values.next()
            #expect(afterAdd?.map(\.postID) == [p1.id, p2.id])

            try ops.renameContainer(p1.id, title: "retitled")
            let afterRename = try await values.next()
            #expect(afterRename?.map(\.title) == ["retitled", "second"])
        }
    }

    @Test func observeLibraryEmitsOnNewAndDeletedPosts() async throws {
        try await withOperationsAsync { ops, db in
            let existing = try ops.createPost()

            var values = db.observeLibrary(sort: .createdAt, direction: .asc).makeAsyncIterator()
            let initial = try await values.next()
            #expect(initial?.map(\.postID) == [existing.id])

            let added = try ops.createPost()
            let afterAdd = try await values.next()
            #expect(afterAdd?.map(\.postID) == [existing.id, added.id])

            try ops.deleteContainer(existing.id)
            let afterDelete = try await values.next()
            #expect(afterDelete?.map(\.postID) == [added.id])
        }
    }

    @Test func observationFetchesNeverTouchTheMainThread() async throws {
        // P2: all DB I/O off the main thread — the observation's fetches run
        // on GRDB's database queue and values are delivered on the
        // cooperative pool, wherever the observation is started from.
        let db = try AppDatabase.inMemory()
        let sawMainThread = LockIsolated(false)
        var values = db.observe { db -> Int in
            if Thread.isMainThread { sawMainThread.setValue(true) }
            return try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container") ?? 0
        }.makeAsyncIterator()

        let first = try await values.next()
        #expect(first == 0)
        try await db.write { db in try Fixture.container(db, id: "p") }
        let second = try await values.next()
        #expect(second == 1)
        #expect(!sawMainThread.value)
    }
}
