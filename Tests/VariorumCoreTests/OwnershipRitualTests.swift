import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-c U2 — **THE TUTORIAL'S SENTENCES, HEADLESS** (the sitting record §25:
/// "every lesson is a sentence the field guide must be able to say TRUTHFULLY
/// of the shipped build — if the build makes any sentence false, the build is
/// wrong, not the sentence"). This phase's sentences — ritual R4 and lessons
/// 5, 6 and 8 — each pinned as the store sees it. (The faces that SAY them are
/// U3/U4's and the chapter is 13i-d's; these pins are the truth underneath.)
@Suite("13i-c U2 — the R4 ritual + lessons 5 · 6 · 8, headless")
struct OwnershipRitualTests {
    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        try ops.seedBlock(in: post.id, text: "Every word of \(title), whole.")
        return post
    }

    private func members(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    private func pool(_ db: AppDatabase) throws -> [String] {
        try db.read { try Queries.notePoolListing($0, window: 50).loose.map(\.postID) }
    }

    private func text(_ db: AppDatabase, _ postID: String) throws -> String {
        try db.read { try Queries.renderedText($0, containerID: postID) }
    }

    /// **R4 — ownership's boundary** (§25): "flip a book to Owned; try adding
    /// one of its notes to another book and meet the copy choice; remove a
    /// note and find it in the Pool."
    @Test func r4_flipToOwned_meetTheCopyChoice_removeAndFindItInThePool() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "my book", kind: .book)
            let first = try note(ops, "first")
            let second = try note(ops, "second")
            try ops.addPostToReading(first.id, to: book.id)
            try ops.addPostToReading(second.id, to: book.id)
            let other = try ops.createReading(name: "another book", kind: .book)

            // Flip a book to Owned.
            #expect(try ops.setReadingOwned(book.id, owned: true).copied.isEmpty)
            // Try adding one of its notes to another book → the copy choice.
            #expect(throws: OperationError.noteOwnedElsewhere(
                postID: first.id, readingID: other.id, owner: book.id)) {
                try ops.addPostToReading(first.id, to: other.id)
            }
            let copy = try ops.copyPostIntoReading(first.id, into: other.id).copy
            #expect(try members(db, other.id) == [copy.id])
            #expect(try members(db, book.id) == [first.id, second.id])
            // Remove a note and find it in the Pool.
            #expect(try ops.removePostFromReading(second.id, from: book.id) == true)
            #expect(try pool(db).contains(second.id))
        }
    }

    /// **Lesson 5 — Owned**: "Put a note in an owned book and that book is its
    /// home. Want it elsewhere too? You'll get a copy, and you'll know. Remove
    /// it and it goes back to the Pool, whole."
    @Test func lesson5_ownedIsItsHome_elsewhereIsAKnownCopy_removedGoesBackWhole() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let elsewhere = try ops.createReading(name: "elsewhere", kind: .book)
            let n = try note(ops, "the note")
            let before = try text(db, n.id)

            // "…that book is its home."
            try ops.addPostToReading(n.id, to: owned.id)
            #expect(try db.read { try Queries.ownershipFacts($0, postIDs: [n.id]) }[n.id]?
                .ownedBy?.id == owned.id)
            // "Want it elsewhere too? You'll get a copy, and you'll know." —
            // the plain pointer is REFUSED (never silent), and the copy is a
            // copy: a different note that remembers where it came from.
            #expect(throws: OperationError.noteOwnedElsewhere(
                postID: n.id, readingID: elsewhere.id, owner: owned.id)) {
                try ops.addPostToReading(n.id, to: elsewhere.id)
            }
            let copy = try ops.copyPostIntoReading(n.id, into: elsewhere.id).copy
            #expect(copy.id != n.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM edge WHERE type = 'version_of' AND deleted_at IS NULL") == 1)
            // "Remove it and it goes back to the Pool, whole."
            try ops.removePostFromReading(n.id, from: owned.id)
            #expect(try pool(db).contains(n.id))
            #expect(try text(db, n.id) == before)
        }
    }

    /// **Lesson 6 — Finished and Sealed**: "Finished means the table of
    /// contents is done — the writing inside can still change. Sealed means
    /// the book is done."
    @Test func lesson6_finishedFreezesTheContents_sealedFreezesTheBook() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            let post = try ops.createPost(title: "inside")
            let take = try ops.seedBlock(in: post.id, text: "a sentence").variant.id
            try ops.addPostToReading(post.id, to: book.id)

            try ops.lockReading(book.id)                      // FINISHED
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.removePostFromReading(post.id, from: book.id)   // contents done
            }
            try ops.autosave(take, text: "a sentence, still changing", charDelta: 16)

            try ops.sealReading(book.id)                      // SEALED
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.autosave(take, text: "no more", charDelta: 3)  // the book is done
            }
            #expect(try members(db, book.id) == [post.id])
        }
    }

    /// **Lesson 8 — Deleting**: "Deleting a plain book never touches a note.
    /// Deleting an owned book asks: keep the notes (they go to the Pool) or
    /// take them too. The Trash gives back whatever went in together,
    /// together."
    @Test func lesson8_plainDeleteNeverTouchesANote_ownedAsks_theTrashGivesBackTogether() throws {
        try withOperations { ops, db in
            // A plain book's delete never touches a note.
            let plain = try ops.createReading(name: "plain", kind: .book)
            let p = try note(ops, "plain's note")
            try ops.addPostToReading(p.id, to: plain.id)
            try ops.deleteReading(plain.id)
            #expect(try db.deletedAt("container", p.id) == nil)

            // An owned book: keep the notes — they go to the Pool…
            let keep = try ops.createReading(name: "keep", kind: .book)
            try ops.setReadingOwned(keep.id, owned: true)
            let k = try note(ops, "kept note")
            try ops.addPostToReading(k.id, to: keep.id)
            try ops.deleteReading(keep.id)
            #expect(try pool(db).contains(k.id))

            // …or take them too.
            let take = try ops.createReading(name: "take", kind: .book)
            try ops.setReadingOwned(take.id, owned: true)
            let t1 = try note(ops, "taken one")
            let t2 = try note(ops, "taken two")
            try ops.addPostToReading(t1.id, to: take.id)
            try ops.addPostToReading(t2.id, to: take.id)
            try ops.deleteReadingWithNotes(take.id)
            #expect(try db.deletedAt("container", t1.id) != nil)
            #expect(try db.deletedAt("container", t2.id) == db.deletedAt("reading", take.id))

            // The Trash gives back whatever went in together, together.
            try ops.restoreReading(take.id)
            #expect(try members(db, take.id) == [t1.id, t2.id])
            #expect(try db.deletedAt("container", t1.id) == nil)
        }
    }
}
