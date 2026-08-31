import Foundation
import GRDB
import Testing
@testable import VariorumCore

// pre-13u Act 10 wave 2b — the library-ish surfaces' query layer:
// the searchable note-picker's feed (item 14), the Snippets surface's
// group/all-groups listings and counts (item 17), and the Trash's
// snippet-group arm (the delete-group door's honesty — #77's lesson:
// a deletion road the Trash cannot list is a lie about recoverability).
@Suite("Snippets & note-picker queries (pre-13u Act 10 wave 2b)")
struct SnippetsAndPickerQueryTests {
    // MARK: - The pool listing's new context (item 17)

    @Test func poolListingCarriesItsGroupAndTheRenderedTakesEditStamp() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "field notes")
            let scrap = try ops.newBlock(in: pool.id, text: "a loose idea")
            let listing = try db.read { try Queries.poolListing($0, poolID: pool.id) }
            #expect(listing.count == 1)
            #expect(listing[0].poolID == pool.id)
            let stamp = try db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT updated_at FROM variant WHERE id = ?",
                    arguments: [scrap.variant.id])
            }
            #expect(listing[0].updatedAt == stamp)
            #expect(listing[0].updatedAt != nil)
        }
    }

    @Test func allPoolsListingSpansEveryGroupInStableOrder() throws {
        try withOperations { ops, db in
            let first = try ops.createPool(title: "Snippets")
            let second = try ops.createPool(title: "field guide")
            _ = try ops.newBlock(in: first.id, text: "one")
            _ = try ops.newBlock(in: second.id, text: "two")
            _ = try ops.newBlock(in: first.id, text: "three")
            let all = try db.read { try Queries.allPoolsListing($0) }
            // Groups oldest-first (the pools order), rows in pointer order.
            #expect(all.map(\.poolID) == [first.id, first.id, second.id])
            #expect(all.map(\.block.text) == ["one", "three", "two"])
        }
    }

    @Test func poolCountsCountLiveSnippetsPerGroupOnly() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "Snippets")
            let other = try ops.createPool(title: "field guide")
            let dead = try ops.createPool(title: "gone")
            _ = try ops.newBlock(in: pool.id, text: "one")
            let doomed = try ops.newBlock(in: pool.id, text: "two")
            _ = try ops.newBlock(in: other.id, text: "three")
            _ = try ops.newBlock(in: dead.id, text: "four")
            try ops.deleteBlock(doomed.block.id)
            try ops.deleteContainer(dead.id)
            let counts = try db.read { try Queries.poolCounts($0) }
            #expect(counts[pool.id] == 1)
            #expect(counts[other.id] == 1)
            #expect(counts[dead.id] == nil)
        }
    }

    // MARK: - The note picker's feed (item 14)

    @Test func notePickerIsBoundedRecentFirstAndCarriesSnippets() throws {
        try withOperations { ops, db in
            var ids: [String] = []
            for n in 1...5 {
                let post = try ops.createPost(title: nil)
                _ = try ops.newBlock(in: post.id, text: "opening words of note \(n), then more prose")
                ids.append(post.id)
            }
            let hits = try db.read {
                try Queries.notePickerNotes($0, query: "", limit: 3)
            }
            // Bounded by the limit, most recently touched first.
            #expect(hits.count == 3)
            #expect(hits.map(\.id) == ids.suffix(3).reversed())
            // Five notes may all display the same day — the SNIPPET is what
            // makes them tellable apart, derived at read time, never stored.
            #expect(hits[0].snippet == "opening words of note 5, then more prose")
        }
    }

    @Test func notePickerExcludesTheSubjectMatchesTitlesAndEscapesWildcards() throws {
        try withOperations { ops, db in
            let subject = try ops.createPost(title: "the 100% draft")
            let peer = try ops.createPost(title: "the 100% draft (again)")
            _ = try ops.createPost(title: "unrelated")
            let hits = try db.read {
                try Queries.notePickerNotes($0, query: "100%", excluding: subject.id)
            }
            // `%` is a literal (the searchCatalog escape discipline), and
            // the subject never lists itself.
            #expect(hits.map(\.id) == [peer.id])
        }
    }

    @Test func notePickerNeverListsArchivedOrDeletedNotes() throws {
        try withOperations { ops, db in
            let live = try ops.createPost(title: "alive")
            let archived = try ops.createPost(title: "aside")
            let deleted = try ops.createPost(title: "gone")
            try ops.archiveContainer(archived.id)
            try ops.deleteContainer(deleted.id)
            let hits = try db.read { try Queries.notePickerNotes($0, query: "") }
            #expect(hits.map(\.id) == [live.id])
        }
    }

    // MARK: - The Trash's snippet-group arm (item 17's delete-group honesty)

    @Test func aDeletedSnippetGroupRowsInTheTrashAndPutBackRevivesItWhole() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "drafting")
            _ = try ops.newBlock(in: pool.id, text: "kept line one")
            _ = try ops.newBlock(in: pool.id, text: "kept line two")
            try ops.deleteContainer(pool.id)

            let now = Date(timeIntervalSince1970: 1_782_864_100)
            let rows = try db.read { try Queries.trash($0, now: now) }
            let groupRow = rows.first { $0.kind == .snippetGroup }
            #expect(groupRow?.id == pool.id)
            #expect(groupRow?.title == "drafting")

            // Put back is the ordinary container restore: the group AND its
            // cascade-stamped snippets come back together.
            try ops.restoreContainer(pool.id)
            let listing = try db.read { try Queries.poolListing($0, poolID: pool.id) }
            #expect(listing.map(\.block.text) == ["kept line one", "kept line two"])
            let after = try db.read { try Queries.trash($0, now: now) }
            #expect(!after.contains { $0.kind == .snippetGroup })
        }
    }

    @Test func aNamelessDeletedGroupIsNamedByItsCreatedDayNeverUntitled() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: nil)
            try ops.deleteContainer(pool.id)
            let now = Date(timeIntervalSince1970: 1_782_864_100)
            let row = try db.read { try Queries.trash($0, now: now) }
                .first { $0.kind == .snippetGroup }
            // The one pool display rule (13k K2): title, else its created day.
            let createdStamp = try db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT created_at FROM container WHERE id = ?",
                    arguments: [pool.id])
            }
            #expect(row?.title == DisplayTitle.pool(title: nil, createdAtStamp: createdStamp))
            #expect((row?.title ?? "").isEmpty == false)
        }
    }

    @Test func aPurgeIntentFencesTheGroupRowLikeEveryOtherKind() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "drafting")
            try ops.deleteContainer(pool.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: pool.id)])
            let now = Date(timeIntervalSince1970: 1_782_864_100)
            let rows = try db.read { try Queries.trash($0, now: now) }
            #expect(!rows.contains { $0.kind == .snippetGroup })
        }
    }
}
