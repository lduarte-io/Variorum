//
//  BookMintPlacementTests.swift
//  VariorumCoreTests
//
//  VX-1039 (the VX-1036 run, batch 1 — N-2, her R-1036-8): where a note made
//  inside a book is born. The pure rule (`BookMintPlacement`) as a table, and
//  `newPostInReading`'s placement as exact state transitions, read back through
//  the book's one order (`Queries.assembleReading`) — every arm: a chapter's own
//  "+", after the note she is on (unfiled, in a chapter, beside a pinned note),
//  a stamp order, nothing to stand beside, and a stale anchor. A FEATURE, so its
//  pins are state transitions; the default `at: .end` keeps every existing
//  `newPostInReading` suite byte-unchanged (`ReadingOperationsTests` et al.).
//

import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("VX-1039 — where a note made inside a book is born")
struct BookMintPlacementTests {
    private typealias Shown = BookMintPlacement.Shown

    // MARK: - The rule (pure)

    @Test func aChaptersOwnDoorMakesTheNoteAtThatChaptersEnd() {
        let shown = [Shown(postID: "a", sectionID: "one", pinned: false)]
        #expect(BookMintPlacement.placement(for: .chapter("two"), shown: shown, manualOrder: true)
                == .init(anchor: .end, sectionID: "two"))
        #expect(BookMintPlacement.placement(for: .chapter("two"), shown: shown, manualOrder: false)
                == .init(anchor: .end, sectionID: "two"), "a stamp order changes nothing for the chapter door")
    }

    @Test func withNoNoteToStandBesideTheNoteIsBornAtTheEnd() {
        let shown = [Shown(postID: "a", sectionID: nil, pinned: false)]
        #expect(BookMintPlacement.placement(for: .general(onNote: nil), shown: shown, manualOrder: true) == .end)
        #expect(BookMintPlacement.placement(for: .general(onNote: "gone"), shown: shown, manualOrder: true) == .end,
                "a note the page no longer shows stands beside nothing")
        #expect(BookMintPlacement.placement(for: .general(onNote: "a"), shown: [], manualOrder: true) == .end)
    }

    @Test func theGeneralDoorMakesTheNoteAfterTheNoteSheIsOnInItsChapter() {
        let shown = [
            Shown(postID: "a", sectionID: "one", pinned: false),
            Shown(postID: "b", sectionID: "one", pinned: false),
            Shown(postID: "c", sectionID: nil, pinned: false),
        ]
        #expect(BookMintPlacement.placement(for: .general(onNote: "a"), shown: shown, manualOrder: true)
                == .init(anchor: .after("a"), sectionID: "one"))
        #expect(BookMintPlacement.placement(for: .general(onNote: "c"), shown: shown, manualOrder: true)
                == .init(anchor: .after("c"), sectionID: nil), "an unfiled note's neighbour is unfiled")
    }

    @Test func besideAPinnedNoteTheNoteTakesItsChaptersFirstUnpinnedSlot() {
        let shown = [
            Shown(postID: "p1", sectionID: "one", pinned: true),
            Shown(postID: "p2", sectionID: "one", pinned: true),
            Shown(postID: "a", sectionID: "one", pinned: false),
            Shown(postID: "q", sectionID: "two", pinned: true),
        ]
        #expect(BookMintPlacement.placement(for: .general(onNote: "p1"), shown: shown, manualOrder: true)
                == .init(anchor: .before("a"), sectionID: "one"),
                "a new note is born unpinned: right below the pinned group, before the chapter's first unpinned note")
        #expect(BookMintPlacement.placement(for: .general(onNote: "q"), shown: shown, manualOrder: true)
                == .init(anchor: .end, sectionID: "two"),
                "a chapter of pinned notes only: its end (never another chapter's note)")
        #expect(BookMintPlacement.placement(for: .general(onNote: "p1"), shown: shown, manualOrder: false)
                == .init(anchor: .after("p1"), sectionID: "one"),
                "under a stamp order the drawn sequence is not the hand order — the note itself is the anchor")
    }

    // MARK: - The operation, read back through the book's order

    private func order(_ db: AppDatabase, _ bookID: String) throws -> [Queries.ReadingEntry] {
        try db.read { try Queries.assembleReading($0, readingID: bookID) }
    }

    private func shown(_ db: AppDatabase, _ bookID: String) throws -> [Shown] {
        try order(db, bookID).map { Shown(postID: $0.postID, sectionID: $0.sectionID, pinned: $0.pinned) }
    }

    private func insert(_ anchor: BookMintPlacement.Anchor) -> Operations.InsertPosition {
        switch anchor {
        case .end: .end
        case .after(let id): .after(id)
        case .before(let id): .before(id)
        }
    }

    /// The door's whole road: the rule over what the page shows, then the op.
    private func mint(
        _ ops: Operations, _ db: AppDatabase, _ bookID: String, _ door: BookMintPlacement.Door,
        manual: Bool = true, title: String
    ) throws -> String {
        let placement = BookMintPlacement.placement(for: door, shown: try shown(db, bookID), manualOrder: manual)
        return try ops.newPostInReading(
            bookID, section: placement.sectionID, title: title, at: insert(placement.anchor)).id
    }

    @Test func inAPlainBookTheNoteIsBornRightAfterTheNoteSheIsOn() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "a plain book", kind: .book)
            var ids: [String] = []
            for name in ["A", "B", "C"] {
                let post = try ops.createPost(title: name)
                try ops.addPostToReading(post.id, to: book.id)
                ids.append(post.id)
            }
            let minted = try mint(ops, db, book.id, .general(onNote: ids[1]), title: "new")
            #expect(try order(db, book.id).map(\.postID) == [ids[0], ids[1], minted, ids[2]])
            #expect(try db.fetchString("SELECT section_id FROM reading_post WHERE post_id = ?", [minted]) == nil)

            // Nothing to stand beside: the end — today's place, byte for byte
            // the default's.
            let last = try mint(ops, db, book.id, .general(onNote: nil), title: "last")
            #expect(try order(db, book.id).map(\.postID).last == last)
            let plain = try ops.newPostInReading(book.id, title: "default").id
            #expect(try order(db, book.id).map(\.postID).last == plain, "the default is the end")
        }
    }

    @Test func inAChapteredBookTheNoteIsBornInTheChapterItsDoorNames() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "the allotment year", kind: .book)
            let one = try ops.createSection(in: book.id, name: "spring")
            let two = try ops.createSection(in: book.id, name: "summer")
            var ids: [String] = []
            for name in ["A", "B", "C", "D"] {
                let post = try ops.createPost(title: name)
                try ops.addPostToReading(post.id, to: book.id)
                ids.append(post.id)
            }
            try ops.assignPostToSection(ids[0], in: book.id, section: one.id)
            try ops.assignPostToSection(ids[1], in: book.id, section: one.id)
            try ops.assignPostToSection(ids[2], in: book.id, section: two.id)
            // D unfiled.

            // After the note she is on, in ITS chapter.
            let afterA = try mint(ops, db, book.id, .general(onNote: ids[0]), title: "after A")
            func inChapter(_ id: String) throws -> [String] {
                try order(db, book.id).filter { $0.sectionID == id }.map(\.postID)
            }
            #expect(try inChapter(one.id) == [ids[0], afterA, ids[1]])

            // A chapter's own "+": that chapter, at its end.
            let inTwo = try mint(ops, db, book.id, .chapter(two.id), title: "summer's new note")
            #expect(try inChapter(two.id) == [ids[2], inTwo])

            // Beside an unfiled note: unfiled, after it.
            let afterD = try mint(ops, db, book.id, .general(onNote: ids[3]), title: "after D")
            #expect(try order(db, book.id).filter { $0.sectionID == nil }.map(\.postID) == [ids[3], afterD])
        }
    }

    @Test func besideAPinnedNoteTheNoteIsBornBelowThePinnedGroup() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "pins", kind: .book)
            var ids: [String] = []
            for name in ["P", "A", "B"] {
                let post = try ops.createPost(title: name)
                try ops.addPostToReading(post.id, to: book.id)
                ids.append(post.id)
            }
            try ops.setMembershipPinned(ids[0], in: book.id, pinned: true)   // P pinned: [P, A, B]
            #expect(try order(db, book.id).map(\.postID) == ids)
            let minted = try mint(ops, db, book.id, .general(onNote: ids[0]), title: "new")
            #expect(try order(db, book.id).map(\.postID) == [ids[0], minted, ids[1], ids[2]],
                    "the first unpinned slot — right below the pinned note, never above it")
        }
    }

    @Test func underAStampOrderTheBookShowsTheNoteWhereItsOrderPutsIt() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "by creation", kind: .book)
            var ids: [String] = []
            for name in ["A", "B", "C"] {
                let post = try ops.createPost(title: name)
                try ops.addPostToReading(post.id, to: book.id)
                ids.append(post.id)
            }
            try ops.setReadingSort(book.id, field: .createdAt, direction: .asc)
            let minted = try mint(ops, db, book.id, .general(onNote: ids[0]), manual: false, title: "new")
            #expect(try order(db, book.id).map(\.postID) == ids + [minted],
                    "the order decides where the book shows it (created last ⇒ last)")
            let hand = try db.read {
                try Queries.assembleReading($0, readingID: book.id, order: .init(field: .manual, direction: .asc))
            }
            #expect(hand.map(\.postID) == [ids[0], minted, ids[1], ids[2]],
                    "and the hand order still says after the note she was on")
        }
    }

    @Test func anAnchorThatIsNotThisBooksRefusesAndMintsNothing() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "here", kind: .book)
            let other = try ops.createReading(name: "elsewhere", kind: .book)
            let theirs = try ops.createPost(title: "theirs")
            try ops.addPostToReading(theirs.id, to: other.id)
            let before = try db.fetchInt("SELECT COUNT(*) FROM container") ?? -1
            #expect(throws: OperationError.postNotInReading(postID: theirs.id, readingID: book.id)) {
                _ = try ops.newPostInReading(book.id, title: "stray?", at: .after(theirs.id))
            }
            #expect(throws: OperationError.postNotInReading(postID: "gone", readingID: book.id)) {
                _ = try ops.newPostInReading(book.id, title: "stray?", at: .before("gone"))
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == before,
                    "a refused placement leaves no stray note (one transaction)")
        }
    }

    /// The doors' overload (`newPostInReading(_:placedAt:)`): an anchor that
    /// left the book between the page's read and the write is not a refusal —
    /// the note is born at the end of the same chapter (every door's place
    /// before the rule). A chapter that died meanwhile still refuses.
    @Test func aDoorWhoseNeighbourLeftTheBookStillMakesItsNote() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "the allotment year", kind: .book)
            let one = try ops.createSection(in: book.id, name: "spring")
            let a = try ops.createPost(title: "A")
            let b = try ops.createPost(title: "B")
            for post in [a, b] { try ops.addPostToReading(post.id, to: book.id) }
            try ops.assignPostToSection(a.id, in: book.id, section: one.id)
            let placement = BookMintPlacement.placement(
                for: .general(onNote: a.id), shown: try shown(db, book.id), manualOrder: true)
            #expect(placement == .init(anchor: .after(a.id), sectionID: one.id))
            _ = try ops.removePostFromReading(a.id, from: book.id)   // her neighbour leaves meanwhile
            let minted = try ops.newPostInReading(book.id, placedAt: placement, title: "new").id
            #expect(try order(db, book.id).filter { $0.sectionID == one.id }.map(\.postID) == [minted],
                    "born in the same chapter, at its end")

            try ops.deleteSection(one.id)
            #expect(throws: OperationError.sectionNotFound(id: one.id)) {
                _ = try ops.newPostInReading(book.id, placedAt: placement, title: "orphan?")
            }
        }
    }
}
