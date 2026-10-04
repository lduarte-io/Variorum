import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13i-e U2 — the two small core READS the faces needed (recorded in the 13i-e
// plan's U2 RECORD): the Archived surface's held books observation, and the
// wing's contents counting its ARCHIVED books and gatherings apart (F-U1-8's
// copy rider — the Delete Wing refusal says where they are).

@Suite("13i-e U2 — the faces' core reads")
struct BookArchiveFacesCoreTests {
    /// The archived ones are counted INSIDE books/gatherings (they are kept —
    /// a wing holding only archived books is not empty) and ALSO apart.
    @Test func wingContentsCountsArchivedReadingsApart() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Away")
            let kept = try ops.createReading(name: "Kept", kind: .book, wingId: wing.id)
            _ = try ops.createReading(name: "Shown", kind: .book, wingId: wing.id)
            let t = try ops.createTag(name: "t", wingID: wing.id)
            let tagRule = try #require(try RuleGrammar.encode(.tag(t.id)))
            let g = try ops.createReading(
                name: "G", kind: .gathering,
                querySpec: tagRule, wingId: wing.id)
            try ops.archiveReading(kept.id)
            try ops.archiveReading(g.id)
            let contents = try db.read { try Queries.wingContents($0, wingID: wing.id) }
            #expect(contents.books == 2 && contents.gatherings == 1)
            #expect(contents.archivedBooks == 1 && contents.archivedGatherings == 1)
            #expect(!contents.isEmpty)
            #expect(contents == Queries.WingContents(
                notes: 0, books: 2, gatherings: 1, tags: 1, archivedBooks: 1, archivedGatherings: 1))
        }
    }

    /// The held observation lists exactly the archived readings of the wing,
    /// newest archive first, and follows an unarchive.
    @Test func theArchivedBooksObservationFollowsArchiveAndUnarchive() async throws {
        try await withOperationsAsync { ops, db in
            let a = try ops.createReading(name: "A", kind: .book)
            let b = try ops.createReading(name: "B", kind: .book)
            try ops.archiveReading(a.id)
            try ops.archiveReading(b.id)
            var iterator = db.observeArchivedReadings(limit: 10, wingID: "").makeAsyncIterator()
            #expect(try await iterator.next()?.map(\.id) == [b.id, a.id])
            _ = try ops.unarchiveReading(b.id)
            #expect(try await iterator.next()?.map(\.id) == [a.id])
        }
    }
}
