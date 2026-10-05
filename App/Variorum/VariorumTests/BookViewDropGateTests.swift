//
//  BookViewDropGateTests.swift
//  VariorumTests
//
//  17y B3 item 11 — F-B2-7 (re-owned here at the B2 ladder's round 1,
//  MINOR-2(ii)): THE BOOK VIEW'S OWN navigator/Outline drop re-placed a note
//  inside its own chapter of a STAMP-ordered book as a SILENT no-op — the
//  exact sibling of item (e)'s gate, fixed in B2 on the Book Panel only.
//
//  The mechanism (traced in the B3 RECORD before the fix): `acceptDrop` →
//  `filePost(…, reposition: false)` (`repositionsOnDrop` is false whenever the
//  order she is looking through is not Manual) → `postDropPlan` drops the
//  `before` anchor, leaving `.file(the chapter it is ALREADY in, before: nil)`
//  → `assignPostToSection` to its own chapter: a write that changes nothing,
//  under a hairline that promised "lands right above", and nothing speaks.
//
//  The fix mirrors the panel's gate WITH B2's two settled orderings:
//  (1) the LOCK consult answers first — a frozen (finished/sealed) book's plan
//  runs as it is so the op's own refusal speaks (reopen / unseal), never the
//  sort advice (the B2 ladder's MAJOR-1); (2) a drop already satisfied — onto
//  the note's immediate SHOWN successor — is `.nothing`, never a refusal
//  (NIT-4). Everything else in a stamp order that would re-place inside the
//  note's own chapter refuses with the road: `BookPanelCopy.needsManualOrder`.
//
//  Red-on-old, stated: the re-place pin and the dispatcher pin see
//  `lastError == nil` on the pre-fix tree (silent). The successor, frozen and
//  cross-chapter pins are CONTROLS (green on both trees by design — they
//  guard the gate's orderings and its reach).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withGateSession<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("17y item 11 (F-B2-7) — the book view's own drop gate speaks", .serialized)
struct BookViewDropGateTests {
    /// A book sorted by CREATED ↓: chapters I (p1, p2) and II (p3, p4). In
    /// that order each chapter SHOWS its later note first — I reads p2, p1.
    @MainActor
    private struct Book {
        let session: AppSession
        let database: AppDatabase
        let structure: BookStructureModel
        let readingID: String
        let sections: [String]
        let posts: [String]

        func refresh() async throws -> [Queries.ReadingEntry] {
            let (snapshot, entries) = try await database.read { [readingID] db in
                (BookStructureModel.Snapshot(
                    reading: try Queries.reading(db, id: readingID),
                    sections: try Queries.readingSections(db, readingID: readingID),
                    deletedSections: try Queries.deletedReadingSections(db, readingID: readingID),
                    assignments: try Queries.sectionAssignments(db, readingID: readingID)),
                 try Queries.assembleReading(db, readingID: readingID))
            }
            structure.adopt(snapshot)
            return entries
        }

        func positions() async throws -> [String: String] {
            try await database.read { [readingID] db in
                let rows = try Row.fetchAll(
                    db,
                    sql: """
                        SELECT post_id, position FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [readingID])
                return Dictionary(uniqueKeysWithValues: rows.map {
                    ($0["post_id"] as String, $0["position"] as String)
                })
            }
        }
    }

    private func withStampBook<T>(
        _ body: @MainActor (Book) async throws -> T
    ) async throws -> T {
        try await withGateSession { session, db in
            let (readingID, sections, posts) = try await session.runner.run { ops in
                let reading = try ops.createReading(name: "orbit", kind: .book)
                let one = try ops.createSection(in: reading.id, name: "I")
                let two = try ops.createSection(in: reading.id, name: "II")
                var posts: [String] = []
                for i in 1...4 {
                    let post = try ops.createPost(title: "p\(i)")
                    _ = try ops.addPostToReading(post.id, to: reading.id)
                    try ops.assignPostToSection(
                        post.id, in: reading.id, section: i <= 2 ? one.id : two.id)
                    posts.append(post.id)
                }
                try ops.setReadingSort(reading.id, field: .createdAt, direction: .desc)
                return (reading.id, [one.id, two.id], posts)
            }
            let book = Book(
                session: session, database: db,
                structure: BookStructureModel(session: session, readingID: readingID),
                readingID: readingID, sections: sections, posts: posts)
            let entries = try await book.refresh()
            // The world as she sees it: chapter I shows p2 ABOVE p1.
            let shownOne = book.structure.grouped(entries: entries)
                .first { $0.section?.id == sections[0] }?.entries.map(\.postID)
            #expect(shownOne == [posts[1], posts[0]], "created ↓ shows p2 first")
            return try await body(book)
        }
    }

    /// THE DEFECT: p1 dropped onto p2 — a real re-place inside chapter I (in
    /// manual order it would land right above p2). Under created ↓ it used
    /// to write nothing and say nothing.
    @Test func aStampOrderedReplaceInsideItsChapterRefusesWithTheRoad() async throws {
        try await withStampBook { book in
            let entries = try await book.refresh()
            let before = try await book.positions()
            await book.structure.filePost(
                book.posts[0], onto: .post(book.posts[1]), entries: entries, reposition: false)
            let said = try #require(book.structure.lastError,
                                    "the drop speaks — never a silent no-op")
            #expect(said.contains("Manual order"), "\(said)")
            #expect(said.contains("Created \u{2193}"), "names the order she is looking through: \(said)")
            #expect(said.contains("orbit"), "\(said)")
            _ = try await book.refresh()
            #expect(book.structure.assignments[book.posts[0]] == book.sections[0])
            #expect(try await book.positions() == before, "nothing moved")
        }
    }

    /// The same drop through the ONE dispatcher both hosts call (the
    /// navigator and Outline's rows).
    @Test func theDispatcherCarriesTheGate() async throws {
        try await withStampBook { book in
            let entries = try await book.refresh()
            #expect(book.structure.acceptDrop(
                [BookStructureModel.BookDrag.post(book.posts[0]).payload],
                chapter: .post(book.posts[1]), post: .post(book.posts[1]),
                entries: entries, viewOrder: nil))
            for _ in 0..<200 where book.structure.lastError == nil {
                try await Task.sleep(for: .milliseconds(5))
            }
            #expect(book.structure.lastError?.contains("Manual order") == true,
                    "\(String(describing: book.structure.lastError))")
        }
    }

    /// CONTROL (NIT-4's ordering): p2 dropped onto p1 — its own immediate
    /// shown successor — would land right where it stands. Nothing is asked
    /// for, so nothing is written and nothing is said.
    @Test func aStampOrderedDropOntoItsOwnSuccessorAsksForNothing() async throws {
        try await withStampBook { book in
            let entries = try await book.refresh()
            let before = try await book.positions()
            await book.structure.filePost(
                book.posts[1], onto: .post(book.posts[0]), entries: entries, reposition: false)
            #expect(book.structure.lastError == nil)
            #expect(try await book.positions() == before)
        }
    }

    /// CONTROL (MAJOR-1's ordering): a FROZEN book answers with its own lock
    /// — reopen / unseal — never the sort advice, whose road (save a Manual
    /// order) is impossible there.
    @Test(arguments: [false, true])
    func aFrozenStampOrderedBookSpeaksItsOwnRefusalNotManualOrder(sealed: Bool) async throws {
        try await withStampBook { book in
            try await book.session.runner.run { [readingID = book.readingID] ops in
                if sealed { _ = try ops.sealReading(readingID) } else { try ops.lockReading(readingID) }
            }
            let entries = try await book.refresh()
            await book.structure.filePost(
                book.posts[0], onto: .post(book.posts[1]), entries: entries, reposition: false)
            let said = try #require(book.structure.lastError)
            #expect(!said.contains("Manual order"), "\(said)")
            #expect(said.contains(sealed ? "unseal" : "reopen"), "\(said)")
        }
    }

    /// CONTROL — the gate's reach: filing into ANOTHER chapter under a stamp
    /// order still files (the book view's ruling — "the chapter half of the
    /// drop always happens"), silently.
    @Test func aStampOrderedDropIntoAnotherChapterStillFiles() async throws {
        try await withStampBook { book in
            let entries = try await book.refresh()
            await book.structure.filePost(
                book.posts[0], onto: .post(book.posts[3]), entries: entries, reposition: false)
            _ = try await book.refresh()
            #expect(book.structure.lastError == nil)
            #expect(book.structure.assignments[book.posts[0]] == book.sections[1])
        }
    }
}
