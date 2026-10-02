//
//  TrashBookNotesTests.swift
//  VariorumTests
//
//  13i-c U4 — THE TRASH'S "and N notes" (the sitting record §18.3: "books
//  list in the Trash beside notes, kind-labeled… the delete-book-and-notes
//  road (one stamp) returns WHOLE"; §25 lesson 8's third sentence: "The Trash
//  gives back whatever went in together, together.").
//
//  What is pinned: the row's words (nothing for a book that went alone); the
//  Trash model's per-book count (the exact-stamp count, read beside the
//  listing); Put back's receipt saying it came back WHOLE (the shared road —
//  `TrashPutBack`, both platforms), and the plain receipt for a book-only
//  delete unchanged.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withTrashWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 61))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// The world's clock, not the wall's: the Trash window is 30 days back from
/// `now`, and this world's stamps start at its `start` (U3's lesson).
private let worldNow = Date(timeIntervalSince1970: 1_782_864_000 + 3_600)

@MainActor
@Suite("The Trash's \"and N notes\" (13i-c U4)", .serialized)
struct TrashBookNotesTests {
    @Test func theRowAndTheReceiptSayItWentInAndCameBackTogether() {
        #expect(RecoveryCopy.bookRowNotes(0) == nil, "a book that went alone says nothing more")
        #expect(RecoveryCopy.bookRowNotes(1) == "and 1 note")
        #expect(RecoveryCopy.bookRowNotes(3) == "and 3 notes")
        #expect(RecoveryCopy.bookPutBackWhole("Mine", notes: 3)
                == "\u{201C}Mine\u{201D} is back with its 3 notes.")
        #expect(RecoveryCopy.bookPutBackWhole("Mine", notes: 1)
                == "\u{201C}Mine\u{201D} is back with its note.")
    }

    @Test func aBookDeletedWithItsNotesRowsWithTheCountAndComesBackWhole() async throws {
        try await withTrashWorld { session, db in
            let ops = session.operations
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            for n in [a, b] { _ = try ops.addPostToReading(n.id, to: mine.id) }
            try ops.deleteReadingWithNotes(mine.id)

            let model = RecoveryViewModel(session: session)
            model.adopt(archived: [], trash: try await db.read {
                try Queries.trash($0, now: worldNow)
            })
            await model.loadBookNoteCountsForTests()
            #expect(model.bookNoteCounts[mine.id] == 2)
            #expect(RecoveryCopy.bookRowNotes(model.bookNoteCounts[mine.id] ?? 0) == "and 2 notes")

            let row = try #require(model.trash.first { $0.kind == .book && $0.id == mine.id })
            await model.putBack(row)
            #expect(model.receipt == RecoveryCopy.bookPutBackWhole("Mine", notes: 2))
            let members = try await db.read {
                try Queries.assembleReading($0, readingID: mine.id)
            }.map(\.postID)
            #expect(members == [a.id, b.id], "whatever went in together came back together")
        }
    }

    @Test func aBookDeletedAloneKeepsThePlainRowAndReceipt() async throws {
        try await withTrashWorld { session, db in
            let ops = session.operations
            let plain = try ops.createReading(name: "Plain", kind: .book)
            let a = try ops.createPost(title: "a")
            _ = try ops.addPostToReading(a.id, to: plain.id)
            try ops.deleteReading(plain.id)

            let model = RecoveryViewModel(session: session)
            model.adopt(archived: [], trash: try await db.read {
                try Queries.trash($0, now: worldNow)
            })
            await model.loadBookNoteCountsForTests()
            #expect(model.bookNoteCounts[plain.id] == 0)
            let row = try #require(model.trash.first { $0.kind == .book })
            await model.putBack(row)
            #expect(model.receipt == RecoveryCopy.putBackReceipt(.book))
        }
    }
}
