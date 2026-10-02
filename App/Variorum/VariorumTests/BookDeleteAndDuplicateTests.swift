//
//  BookDeleteAndDuplicateTests.swift
//  VariorumTests
//
//  13i-c U4 — DELETE (three arms) and DUPLICATE BOOK… (the sitting record §6
//  and §18.3; §25 lesson 8; the 13i-c plan §6; F-U2-7, F-U3-2).
//
//  What is pinned: the three delete confirms as static copy (lesson 8's first
//  sentence on a plain book; the owned book's TWO choices; the gathering's
//  U3 words); the shelf's delete door routing through the one confirm road
//  and choosing the arm by the book's facts; each arm's act and receipt
//  (book only → the owned book's notes in the Pool; with its notes → one
//  stamp, the Trash's "and N notes"; a plain book's notes untouched); and
//  Duplicate's two shapes, its owned-book rule (copies only) and E13's name
//  guard (refuse and keep).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withBooksWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 53))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func members(_ db: AppDatabase, _ readingID: String) async throws -> [String] {
    try await db.read { try Queries.assembleReading($0, readingID: readingID) }.map(\.postID)
}

@MainActor
private func isLive(_ db: AppDatabase, _ postID: String) async throws -> Bool {
    try await db.read { try Queries.containerIsLive($0, id: postID) }
}

@MainActor
@Suite("Delete (three arms) and Duplicate Book… (13i-c U4)", .serialized)
struct BookDeleteAndDuplicateTests {
    // MARK: - The words

    @Test func theThreeDeleteConfirmsSayLessonEight() {
        let plain = BookStateCopy.deletePlainBook(readingID: "p", name: "Plain", notes: 3)
        // Lesson 8's first sentence, at the door.
        #expect(plain.lines.first?.hasPrefix("Deleting a plain book never touches a note") == true)
        #expect(plain.lines.contains(BookStateCopy.trashLine))
        #expect(plain.alternateLabel == nil, "a plain book's delete never offers note deletion")
        #expect(plain.confirmLabel == "Delete Book")

        let owned = BookStateCopy.deleteOwnedBook(readingID: "o", name: "Mine", notes: 2)
        #expect(owned.lines.first
                == "\u{201C}Mine\u{201D} owns its notes. Delete the book only, and its 2 notes go "
                + "back to the Pool \u{2014} or delete the book and its 2 notes together.")
        #expect(owned.confirmLabel == "Delete Book Only")
        #expect(owned.alternateLabel == "Delete Book and Its 2 Notes")
        #expect(owned.lines.last?.contains("whatever went in together, together") == true,
                "lesson 8's third sentence")
        // An owned book with no notes has nothing to choose.
        #expect(BookStateCopy.deleteOwnedBook(readingID: "o", name: "Mine", notes: 0)
            .alternateLabel == nil)

        // The receipts.
        #expect(BookStateCopy.deletedBookOnly("Mine", released: 2)
                == "Deleted \u{201C}Mine\u{201D} \u{2014} it\u{2019}s in the Trash; its 2 notes are "
                + "in the Pool now.")
        #expect(BookStateCopy.deletedWithNotes("Mine", notes: 2).hasPrefix(
            "Deleted \u{201C}Mine\u{201D} and its 2 notes"))
        #expect(BookStateCopy.deletedPlainBook("Plain").hasSuffix("Its notes are untouched."))
    }

    // MARK: - The three arms through the one road

    @Test func thePlainBooksDeleteNeverTouchesANote() async throws {
        try await withBooksWorld { session, db in
            let ops = session.operations
            let plain = try ops.createReading(name: "Plain", kind: .book)
            let other = try ops.createReading(name: "Other", kind: .book)
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            for n in [a, b] { _ = try ops.addPostToReading(n.id, to: plain.id) }
            _ = try ops.addPostToReading(a.id, to: other.id)

            let doors = BookStateDoors(session: session)
            await doors.open(.deleteBook, readingID: plain.id)
            #expect(doors.pending == BookStateCopy.deletePlainBook(
                readingID: plain.id, name: "Plain", notes: 2))
            await doors.confirm()
            #expect(try await db.read { try Reading.fetchOne($0, key: plain.id) }?.deletedAt != nil,
                    "the book went to the Trash")
            let aLive = try await isLive(db, a.id)
            let bLive = try await isLive(db, b.id)
            #expect(aLive && bLive, "no note touched")
            #expect(try await members(db, other.id) == [a.id])
            #expect(session.status.spoken?.text == BookStateCopy.deletedPlainBook("Plain"))
        }
    }

    @Test func theOwnedBooksBookOnlyArmReleasesItsNotesToThePool() async throws {
        try await withBooksWorld { session, db in
            let ops = session.operations
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let a = try ops.createPost(title: "a")
            _ = try ops.addPostToReading(a.id, to: mine.id)

            let doors = BookStateDoors(session: session)
            await doors.open(.deleteBook, readingID: mine.id)
            let asked = try #require(doors.pending)
            #expect(asked == BookStateCopy.deleteOwnedBook(readingID: mine.id, name: "Mine", notes: 1))
            await doors.confirm()   // the first choice: the book only
            #expect(try await isLive(db, a.id))
            #expect(try await db.read { try Queries.poolListing($0, window: 10) }.loose
                .map(\.postID) == [a.id], "its note went back to the Pool")
            #expect(session.status.spoken?.text == BookStateCopy.deletedBookOnly("Mine", released: 1))
        }
    }

    @Test func theOwnedBooksSecondArmTakesItsNotesOnOneStamp() async throws {
        try await withBooksWorld { session, db in
            let ops = session.operations
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            for n in [a, b] { _ = try ops.addPostToReading(n.id, to: mine.id) }

            let doors = BookStateDoors(session: session)
            await doors.open(.deleteBook, readingID: mine.id)
            await doors.confirm(alternate: true)
            let aLive = try await isLive(db, a.id)
            let bLive = try await isLive(db, b.id)
            #expect(!aLive && !bLive, "both notes went to the Trash with the book")
            #expect(try await db.read {
                try Queries.trashBookNoteCount($0, readingID: mine.id)
            } == 2, "the Trash's book row says \"and 2 notes\"")
            #expect(session.status.spoken?.text == BookStateCopy.deletedWithNotes("Mine", notes: 2))
        }
    }

    @Test func theGatheringsArmIsU3s() async throws {
        try await withBooksWorld { session, _ in
            let ops = session.operations
            let tag = try ops.createTag(name: "t")
            let g = try ops.createReading(
                name: "G", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let doors = BookStateDoors(session: session)
            await doors.open(.deleteBook, readingID: g.id)
            #expect(doors.pending == BookStateCopy.deleteGathering(readingID: g.id, name: "G"))
        }
    }

    @Test func theConfirmSheetDrawsTheSecondChoice() async throws {
        try await withBooksWorld { _, _ in
            BookStateProbe.shown = nil
            let item = BookStateCopy.deleteOwnedBook(readingID: "o", name: "Mine", notes: 2)
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 600, height: 400),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            window.contentView = NSHostingView(rootView: BookStateConfirmSheet(
                confirm: item, onConfirm: {}, onAlternate: {}))
            window.orderFrontRegardless()
            for _ in 0..<20 where BookStateProbe.shown == nil {
                pump(0.03)
                await Task.yield()
            }
            #expect(BookStateProbe.shown?.alternateLabel == "Delete Book and Its 2 Notes")
        }
    }

    // MARK: - Duplicate

    @Test func duplicateWordsFollowTheBook() {
        #expect(DuplicateBookCopy.verb(owned: false) == "Duplicate Book\u{2026}")
        #expect(DuplicateBookCopy.verb(owned: true) == "Duplicate with Copies\u{2026}")
        #expect(CapabilityRegistry.capability(.duplicateBook).verb == DuplicateBookCopy.verb)
        #expect(ShelfView.contextMenuCapabilities.contains(.duplicateBook))
        #expect(DuplicateBookCopy.duplicated(name: "X copy", notes: 3, deep: false)
                == "\u{201C}X copy\u{201D} \u{2014} 3 notes, the same notes.")
        #expect(DuplicateBookCopy.duplicated(name: "X copy", notes: 3, deep: true)
                == "\u{201C}X copy\u{201D} \u{2014} 3 copies.")
        #expect(DuplicateBookOffer(readingID: "o", name: "Mine", owned: true).offersShallow == false)
        #expect(DuplicateBookCopy.lines(name: "Mine", owned: true, deep: true).first?
            .contains("owns its notes, so its duplicate carries copies") == true)
    }

    @Test func aShallowDuplicateIsTheSameNotesAndADeepOneIsCopies() async throws {
        try await withBooksWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Poems", kind: .book)
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            for n in [a, b] { _ = try ops.addPostToReading(n.id, to: book.id) }
            let offer = DuplicateBookOffer(readingID: book.id, name: "Poems", owned: false)

            let shallow = await DuplicateBookDoor.perform(
                session: session, offer: offer, name: "Poems copy", deep: false)
            #expect(shallow == .landed("\u{201C}Poems copy\u{201D} \u{2014} 2 notes, the same notes."))
            let copyID = try #require(try await db.read {
                try Queries.readings($0).first { $0.name == "Poems copy" }?.id
            })
            #expect(try await members(db, copyID) == [a.id, b.id])

            let deep = await DuplicateBookDoor.perform(
                session: session, offer: offer, name: "Poems fork", deep: true)
            #expect(deep == .landed("\u{201C}Poems fork\u{201D} \u{2014} 2 copies."))
            let forkID = try #require(try await db.read {
                try Queries.readings($0).first { $0.name == "Poems fork" }?.id
            })
            #expect(Set(try await members(db, forkID)).isDisjoint(with: [a.id, b.id]))

            // E13's guard — refuse and keep.
            let taken = await DuplicateBookDoor.perform(
                session: session, offer: offer, name: "poems COPY", deep: false)
            guard case .refused = taken else {
                Issue.record("a taken name must refuse")
                return
            }
        }
    }

    @Test func anOwnedBookDuplicatesWithCopiesOnly() async throws {
        try await withBooksWorld { session, db in
            let ops = session.operations
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let a = try ops.createPost(title: "a")
            _ = try ops.addPostToReading(a.id, to: mine.id)
            let offer = DuplicateBookOffer(readingID: mine.id, name: "Mine", owned: true)
            // Even asked shallow, the door duplicates WITH copies (the op
            // refuses a shallow duplicate of an owned book — never offered).
            let outcome = await DuplicateBookDoor.perform(
                session: session, offer: offer, name: "Mine copy", deep: false)
            #expect(outcome == .landed("\u{201C}Mine copy\u{201D} \u{2014} 1 copy."))
            let dup = try #require(try await db.read {
                try Queries.readings($0).first { $0.name == "Mine copy" }
            })
            #expect(dup.owned == false, "the duplicate is born non-owned (§6)")
            #expect(try await members(db, mine.id) == [a.id], "the owned book keeps its note")
        }
    }
}
