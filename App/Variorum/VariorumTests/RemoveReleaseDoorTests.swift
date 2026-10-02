//
//  RemoveReleaseDoorTests.swift
//  VariorumTests
//
//  13i-c U4 — THE REMOVE / RELEASE DOORS (the sitting record §20; §25 lesson
//  5; the 13i-c plan §3's remove/release line and the U4 brief's item 5).
//
//  What is pinned: the vocabulary (one act, its word the book's — Remove on a
//  plain book, Release on an owned one), the receipts verbatim and their
//  bookless clause, the refusals named for the book's road (finished → reopen,
//  sealed → unseal), the gathering's honest door (the worn rule tags by
//  subtree; its receipt says whether the gathering still shows the note), and
//  the act's declaration on every renderer (the walk names them).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withRemoveWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 43))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func book(_ db: AppDatabase, _ id: String) async throws -> Reading {
    try #require(try await db.read { try Queries.reading($0, id: id) })
}

@MainActor
@Suite("The remove / release doors (13i-c U4)", .serialized)
struct RemoveReleaseDoorTests {
    @Test func theWordFollowsTheBook() {
        #expect(RemoveFromBookCopy.verb(owned: false) == "Remove from This Book")
        #expect(RemoveFromBookCopy.verb(owned: true) == "Release from This Book")
        #expect(RemoveFromBookCopy.rowWord(owned: false) == "remove")
        #expect(RemoveFromBookCopy.rowWord(owned: true) == "release")
        // The brief's receipts, verbatim.
        #expect(RemoveFromBookCopy.removed(book: "X", bookless: false)
                == "Removed from \u{201C}X\u{201D} \u{2014} the note itself is untouched.")
        #expect(RemoveFromBookCopy.released(book: "X")
                == "Released from \u{201C}X\u{201D} \u{2014} it\u{2019}s in the Pool now.")
        // A plain remove that leaves the note in no book says where it is.
        #expect(RemoveFromBookCopy.removed(book: "X", bookless: true)
                .hasSuffix("It\u{2019}s in the Pool now."))
        #expect(RemoveFromBookCopy.removeTagVerb(path: "video/ideas")
                == "Remove the #video/ideas tag")
        // ONE act, declared with the plain book's verb; the gathering's
        // honest door is its own act.
        #expect(CapabilityRegistry.capability(.removeFromBook).verb
                == RemoveFromBookCopy.removeVerb)
        #expect(CapabilityRegistry.capability(.removeFromBook).doors == [.contextMenu, .surface])
        #expect(CapabilityRegistry.capability(.removeRuleTag).doors == [.surface])
        // Every renderer declares it (the walk holds the union exact).
        #expect(BookView.contextMenuCapabilities.contains(.removeFromBook))
        #expect(SidebarNoteBox.contextMenuCapabilities.contains(.removeFromBook))
        #expect(MembershipChip.surfaceCapabilities.contains(.removeFromBook))
        #expect(MembershipChip.surfaceCapabilities.contains(.removeRuleTag))
        #expect(BookIndexColumn.surfaceCapabilities.contains(.removeFromBook))
        #expect(ManageReadingPostsSheet.surfaceCapabilities.contains(.removeFromBook))
    }

    @Test func removingFromAPlainBookLeavesTheNoteUntouched() async throws {
        try await withRemoveWorld { session, db in
            let ops = session.operations
            let plain = try ops.createReading(name: "Plain", kind: .book)
            let other = try ops.createReading(name: "Other", kind: .book)
            let note = try ops.createPost(title: "n")
            _ = try ops.addPostToReading(note.id, to: plain.id)
            _ = try ops.addPostToReading(note.id, to: other.id)

            let outcome = await RemoveFromBookDoor.remove(
                session: session, postID: note.id, book: try await book(db, plain.id))
            #expect(outcome == .receipt(RemoveFromBookCopy.removed(book: "Plain", bookless: false)))
            #expect(session.status.spoken?.text == outcome.text)

            // The last book: the plain receipt says where it is now.
            let last = await RemoveFromBookDoor.remove(
                session: session, postID: note.id, book: try await book(db, other.id))
            #expect(last == .receipt(RemoveFromBookCopy.removed(book: "Other", bookless: true)))
        }
    }

    /// Lesson 5's third sentence — "Remove it and it goes back to the Pool,
    /// whole" — said by the door on an owned book, and true of the store.
    @Test func releasingFromAnOwnedBookReturnsTheNoteToThePool() async throws {
        try await withRemoveWorld { session, db in
            let ops = session.operations
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let note = try ops.createPost(title: "n")
            _ = try ops.addPostToReading(note.id, to: mine.id)

            let outcome = await RemoveFromBookDoor.remove(
                session: session, postID: note.id, book: try await book(db, mine.id))
            #expect(outcome == .receipt(RemoveFromBookCopy.released(book: "Mine")))
            let pool = try await db.read { try Queries.notePoolListing($0, window: 50) }
            #expect(pool.loose.map(\.postID).contains(note.id), "it's in the Pool now")
        }
    }

    /// 13i-d U4 — an ARCHIVED note leaving a book is NOT in the Pool (the
    /// Pool is every live, UN-archived bookless note), so the receipt must
    /// not say it is: the archived line's Remove door (and any remove door
    /// reaching an archived note — the Book Panel on an opened archived note)
    /// says it stays archived. Red-on-old: the shared door said "It's in the
    /// Pool now." / "it's in the Pool now." — false of the store.
    @Test func anArchivedNoteRemovedOrReleasedStaysArchivedNeverThePool() async throws {
        try await withRemoveWorld { session, db in
            let ops = session.operations
            let plain = try ops.createReading(name: "Plain", kind: .book)
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            _ = try ops.addPostToReading(a.id, to: plain.id)
            _ = try ops.addPostToReading(b.id, to: mine.id)
            try ops.archiveContainer(a.id)
            try ops.archiveContainer(b.id)

            let removed = await RemoveFromBookDoor.remove(
                session: session, postID: a.id, book: try await book(db, plain.id))
            #expect(!removed.text.contains("Pool"), "an archived note is not in the Pool")
            #expect(removed == .receipt(RemoveFromBookCopy.receipt(
                book: "Plain", owned: false, bookless: true, archived: true)))
            #expect(removed.text.hasSuffix("It stays archived."))

            let released = await RemoveFromBookDoor.remove(
                session: session, postID: b.id, book: try await book(db, mine.id))
            #expect(!released.text.contains("Pool"))
            #expect(released == .receipt(RemoveFromBookCopy.receipt(
                book: "Mine", owned: true, bookless: true, archived: true)))

            let pool = try await db.read { try Queries.notePoolListing($0, window: 50) }
            #expect(!pool.loose.map(\.postID).contains(a.id), "and the store agrees")
            #expect(!pool.loose.map(\.postID).contains(b.id))
        }
    }

    @Test func aFinishedOrSealedBookRefusesNamingItsRoad() async throws {
        try await withRemoveWorld { session, db in
            let ops = session.operations
            let done = try ops.createReading(name: "Done", kind: .book)
            let note = try ops.createPost(title: "n")
            _ = try ops.addPostToReading(note.id, to: done.id)
            try ops.lockReading(done.id)
            let finished = await RemoveFromBookDoor.remove(
                session: session, postID: note.id, book: try await book(db, done.id))
            #expect(finished == .refusal(
                "\u{201C}Done\u{201D} is finished \u{2014} reopen it first."))
            #expect(session.status.current?.text == finished.text)

            try ops.unlockReading(done.id)
            try ops.sealReading(done.id)
            let sealed = await RemoveFromBookDoor.remove(
                session: session, postID: note.id, book: try await book(db, done.id))
            #expect(sealed == .refusal(
                "\u{201C}Done\u{201D} is sealed \u{2014} unseal it first (that reopens it too)."))
            #expect(try await db.read {
                try Queries.assembleReading($0, readingID: done.id)
            }.map(\.postID) == [note.id], "nothing left the frozen book")
        }
    }

    @Test func aGatheringsHonestDoorIsTheWornRuleTag() async throws {
        try await withRemoveWorld { session, db in
            let ops = session.operations
            let video = try ops.createTag(name: "video")
            let ideas = try ops.createTag(parent: video.id, name: "ideas")
            let other = try ops.createTag(name: "other")
            let gathering = try ops.createReading(
                name: "Videos", kind: .gathering,
                querySpec: try RuleGrammar.encode(.or([.tag(video.id), .tag(other.id)])))
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(ideas.id, toPost: note.id)
            _ = try ops.applyTag(other.id, toPost: note.id)

            let g = try await book(db, gathering.id)
            let worn = try await db.read {
                try RemoveFromBookDoor.wornRuleTags($0, postID: note.id, gathering: g)
            }
            // Subtree matching (§19): #video/ideas is under the rule's #video.
            #expect(worn.map(\.path) == ["other", "video/ideas"])

            // Removing one: the gathering still shows it through the other.
            let first = await RemoveFromBookDoor.removeTag(
                session: session, postID: note.id, tag: worn[0], gathering: g)
            #expect(first == .receipt(RemoveFromBookCopy.removedTag(
                path: "other", gathering: "Videos", stillShows: true)))
            let second = await RemoveFromBookDoor.removeTag(
                session: session, postID: note.id, tag: worn[1], gathering: g)
            #expect(second == .receipt(RemoveFromBookCopy.removedTag(
                path: "video/ideas", gathering: "Videos", stillShows: false)))

            // A star-only rule offers no tag door (there is no tag to take off).
            let starred = try ops.createReading(
                name: "Stars", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let s = try await book(db, starred.id)
            #expect(try await db.read {
                try RemoveFromBookDoor.wornRuleTags($0, postID: note.id, gathering: s)
            }.isEmpty)
        }
    }
}
