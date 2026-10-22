//
//  EncryptionExplainedDrillTests.swift
//  VariorumTests
//
//  pre-13x batch 5a — THE DRILL (the brief's item 6), as a standing suite:
//  a fresh store seeds the tutorial WITH the new "keeping it private"
//  chapter AND both seeded books (Sherlock + *Encryption Explained*) on the
//  shelf; Help ▸ Restore Tutorial's road re-seeds; and *Encryption
//  Explained*'s Chapter 1 mounts on the projection tier (the read-cheap
//  `ReadPostViewModel` + `ReadPostView` the book's Read mode draws) showing
//  its first paragraph VERBATIM — copy §7b's, as the seed stored it. The
//  two-copies dedupe half of the drill is core's
//  `SampleLibraryDedupeListTests`.
//
//  The DEV store's own re-seed is the orchestrator's walk (the Debug build
//  on its fenced store); her real store's is her morning act.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private final class DrillMark {
    var value = false
    var load: () -> Bool { { [self] in value } }
    var save: (Bool) -> Void { { [self] in value = $0 } }
}

@MainActor
@Suite("The 5a drill — the tutorial's chapter + both seeded books + Chapter 1 on the projection tier", .serialized)
struct EncryptionExplainedDrillTests {
    private func withDrillWorld<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_783_036_800)
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    /// The Mac's launch shape, headless: the tutorial (the seed road Help ▸
    /// Restore Tutorial takes), then both books — in seeding order.
    private func seedEverything(_ session: AppSession) async throws -> [String: String] {
        _ = try await TutorialSeeder.restore(session: session)
        var books: [String: String] = [:]  // keyed by the book's reserved name
        for book in SampleLibrarySeeder.Book.all {
            let mark = DrillMark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected \(book.name) to seed, got \(outcome)")
                continue
            }
            books[book.name] = bookID
        }
        return books
    }

    @Test("A fresh store seeds the tutorial with the new chapter AND both books; Help ▸ Restore Tutorial re-seeds")
    func aFreshStoreSeedsTheTutorialWithTheNewChapterAndBothBooksAndRestoreReseeds() async throws {
        try await withDrillWorld { session, db in
            let books = try await seedEverything(session)
            // 18l-c U6 (re-armed, a changed fact of that unit): `Book.all`
            // grew a THIRD seeded book — the takemania book — so the Mac's
            // launch shape seeds three.
            #expect(books.count == SampleLibrarySeeder.Book.all.count && books.count == 3)

            // THE SHELF: the field guide + the seeded books.
            let shelf = try await db.read { db in try Queries.readings(db).map(\.name) }
            #expect(shelf.contains(TutorialSeeder.bookName))
            #expect(shelf.contains(SampleLibrarySeeder.bookName))
            #expect(shelf.contains(SampleLibraryEncryptionBook.name))
            #expect(shelf.contains(SampleLibraryJekyllBook.name))

            // THE CHAPTER: the road's three lessons under "keeping it private" (VX-329 U1: copy §7's two left with today's
            // road — every store seeds the road's chapter now).
            let guide = try await db.read { db in
                try #require(Queries.readings(db).first { $0.name == TutorialSeeder.bookName })
            }
            let chapterLessons = try await db.read { db -> [String] in
                try Queries.assembleReading(db, readingID: guide.id)
                    .filter { $0.sectionPath == "keeping it private" }
                    .compactMap(\.title)
            }
            #expect(chapterLessons == [ProtectionWords.guideKeyLessonTitle, ProtectionWords.guidePosturesLessonTitle,
                                       ProtectionWords.guideCopiesLessonTitle])

            // THE BOOK: nine notes, Chapter 1 first after the front matter.
            let encryption = try #require(books[SampleLibraryEncryptionBook.name])
            let entries = try await db.read { db in try Queries.assembleReading(db, readingID: encryption) }
            #expect(entries.count == 9)
            #expect(entries.first?.title == SampleLibraryEncryptionBook.frontMatterTitle)
            #expect(entries[1].title == "Chapter 1 — What is encrypted, and with what")
            // No seeded note of the two books is bookless (the tutorial's own
            // scraps lesson mints a bookless practice note by design, so the
            // Pool is not blank on a store that holds the field guide).
            let bookless = try await db.read { db in Set(try Queries.poolPosts(db, limit: 200).map(\.postID)) }
            #expect(entries.allSatisfy { !bookless.contains($0.postID) }, "every chapter note is a member of its book")
            let sherlock = try #require(books[SampleLibrarySeeder.bookName])
            let sherlockEntries = try await db.read { db in try Queries.assembleReading(db, readingID: sherlock) }
            #expect(sherlockEntries.count == 13 && sherlockEntries.allSatisfy { !bookless.contains($0.postID) })

            // HELP ▸ RESTORE TUTORIAL's road (the door's own two steps —
            // discover, then the wholesale replace) re-seeds the chapter and
            // touches neither seeded book.
            let existing = try await db.read { db in try TutorialSeeder.discover(db) }
            #expect(!existing.isEmpty, "a live guide is what the confirm gates on")
            let fresh = try await TutorialSeeder.restore(session: session, existing: existing)
            #expect(fresh != guide.id, "a wholesale replace — a fresh book")
            let again = try await db.read { db -> [String] in
                try Queries.assembleReading(db, readingID: fresh)
                    .filter { $0.sectionPath == "keeping it private" }
                    .compactMap(\.title)
            }
            #expect(again == [ProtectionWords.guideKeyLessonTitle, ProtectionWords.guidePosturesLessonTitle,
                              ProtectionWords.guideCopiesLessonTitle])
            let shelfAfter = try await db.read { db in
                try Queries.readings(db).filter { $0.deletedAt == nil }.map(\.name)
            }
            #expect(shelfAfter.filter { $0 == TutorialSeeder.bookName }.count == 1)
            #expect(shelfAfter.contains(SampleLibrarySeeder.bookName)
                    && shelfAfter.contains(SampleLibraryEncryptionBook.name))
            let stillNine = try await db.read { db in try Queries.assembleReading(db, readingID: encryption).count }
            #expect(stillNine == 9, "the seeded books are untouched by the tutorial's replace")
        }
    }

    @Test("Chapter 1 mounts on the projection tier and shows its first paragraph verbatim")
    func chapterOneMountsOnTheProjectionTierShowingItsFirstParagraphVerbatim() async throws {
        try await withDrillWorld { session, db in
            let mark = DrillMark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: .encryptionExplained, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let chapterOne = try await db.read { db in
                try #require(Queries.assembleReading(db, readingID: bookID)
                    .first { $0.title == "Chapter 1 — What is encrypted, and with what" })
            }
            // The first paragraph, from the bundled copy §7b text itself —
            // never re-typed here.
            let chapters = try SampleLibrarySeeder.loadStories(for: .encryptionExplained)
            let firstParagraph = try #require(
                chapters.first?.text.split(separator: "\n").first.map(String.init))
            #expect(firstParagraph.hasPrefix("Your library is one file."))

            // The projection tier: the read-cheap model over the store's
            // projection (what the book's Read mode draws), with a real read
            // surface attached.
            let model = ReadPostViewModel(session: session, postID: chapterOne.postID)
            let textView = ReadPostTextView.makeReadSurface()
            textView.frame = NSRect(x: 0, y: 0, width: 640, height: 400)
            model.attach(textView: textView)
            model.applyProjection(try await db.read { db in
                try Queries.renderPost(db, containerID: chapterOne.postID)
            })
            let shown = textView.string
            #expect(shown.hasPrefix(firstParagraph), "the tier shows Chapter 1's first paragraph verbatim, first")
            #expect(shown.contains("The server stores and passes along what it cannot read."))

            // …and the view the tier renders through mounts in a real window.
            await SurfaceComposition.host(
                ReadPostView(session: session, postID: chapterOne.postID),
                size: NSSize(width: 640, height: 400))
        }
    }
}
