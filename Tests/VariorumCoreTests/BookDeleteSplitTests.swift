import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// VX-45 (the VX-914 run, batch 3 — KnownIssues row 102's recorded remedy):
/// `deleteReading` returns the member notes the book held, SPLIT by archive,
/// read in its own transaction before the tombstone — so the book-only
/// receipt can say what the act left where (an archived member stays
/// archived; the rest are in the Pool), never a count read a moment earlier.
@Suite("VX-45 — the book-only delete returns its members split by archive")
struct BookDeleteSplitTests {
    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        try ops.seedBlock(in: post.id, text: "the text of \(title)")
        return post
    }

    /// An OWNED book holding two live notes and one archived one (and a note
    /// that died first, which is held by no one): the act returns 2 + 1, the
    /// two land in the Pool, the archived one stays archived and is NOT in the
    /// Pool — exactly what the receipt now says.
    @Test func anOwnedBooksDeleteReturnsWhatWentToThePoolAndWhatStaysArchived() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(book.id, owned: true)
            let a = try note(ops, "a")
            let b = try note(ops, "b")
            let kept = try note(ops, "kept")
            let dead = try note(ops, "dead")
            for n in [a, b, kept, dead] { try ops.addPostToReading(n.id, to: book.id) }
            try ops.archiveContainer(kept.id)
            try ops.deleteContainer(dead.id)

            #expect(try db.read { try Queries.memberNoteSplit($0, readingID: book.id) }
                    == Queries.MemberNoteSplit(unarchived: 2, archived: 1))
            #expect(try db.read { try Queries.liveMemberNoteCount($0, readingID: book.id) } == 3,
                    "the split is the delete confirm's own set, counted in two")

            let held = try ops.deleteReading(book.id)

            #expect(held == Queries.MemberNoteSplit(unarchived: 2, archived: 1))
            #expect(held.total == 3)
            let pool = try db.read { try Queries.notePoolListing($0, window: 50) }
            let pooled = Set((pool.loose + pool.tucked).map(\.postID))
            #expect(pooled == [a.id, b.id], "the unarchived members are in the Pool")
            #expect(try db.read { try Container.fetchOne($0, key: kept.id) }?.archivedAt != nil,
                    "the archived member stays archived — and the Pool never lists it")
        }
    }

    /// The split counts MEMBERS only: an arrival waiting at the door is no
    /// membership, and a book with no members returns nothing.
    @Test func theSplitCountsMembersOnlyAndAnEmptyBookReturnsNone() throws {
        try withOperations { ops, _ in
            let empty = try ops.createReading(name: "Empty", kind: .book)
            #expect(try ops.deleteReading(empty.id) == .none)

            let plain = try ops.createReading(name: "Plain", kind: .book)
            let member = try note(ops, "member")
            try ops.addPostToReading(member.id, to: plain.id)
            #expect(try ops.deleteReading(plain.id) == Queries.MemberNoteSplit(unarchived: 1, archived: 0),
                    "a plain book's members are counted too (the door decides what to say)")
        }
    }

    /// A missing or already-deleted book still refuses (the split read never
    /// stands in for the guard).
    @Test func aDeadBookStillRefuses() throws {
        try withOperations { ops, _ in
            let book = try ops.createReading(name: "Gone", kind: .book)
            try ops.deleteReading(book.id)
            #expect(throws: (any Error).self) { try ops.deleteReading(book.id) }
        }
    }
}
