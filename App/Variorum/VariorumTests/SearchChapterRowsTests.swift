//
//  SearchChapterRowsTests.swift
//  VariorumTests
//
//  **VX-1074 — a chapter found by its name shows as a CHAPTER, not as its
//  book.** Her report (2026-11-24): searching the Library for `oct 9 batch`
//  in a wing whose book "Video ideas" has a chapter "Oct 9 batch (V01–V49)" —
//  *"chapter titles are not being found in search, clearly."* They were found
//  (the index holds chapter names, kind `chapter`) and counted, but the
//  answer's Books section drew the hit as its BOOK — the row "Video ideas ·
//  book", nothing naming the chapter — and opening it opened the book
//  wherever it last was.
//
//  The build (PROVISIONAL A-1082-2, `notes/plans/fixes/vx-1082-nov-24-fixes.md`
//  BATCH S): a chapter found by its own name gets its OWN row in the Books
//  section — its name, "chapter", "in ‹book›" — opening the book's Outline at
//  that chapter through the book's existing chapter landing
//  (`ShellRouter.pendingBookChapter`); the band's books count carries it as
//  before (the distinct books the section names — no new facet).
//
//  RED on the pre-fix tree: `aChapterFoundByItsNameIsNotListedAsItsBook` (the
//  book's row stood in for the chapter). GUARDS: a book found by its own name
//  keeps its row; the books count is the same on both trees.
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
@Suite("VX-1074 — a chapter found by its name shows as its own row", .serialized)
struct SearchChapterRowsTests {
    struct Shelf {
        let db: AppDatabase
        let session: AppSession
        let video: Reading
        let chapter: ReadingSection
        let recipes: Reading
    }

    /// Her scenario's shape: "Video ideas" with a chapter "Oct 9 batch
    /// (V01–V49)" holding a member whose words name none of the question's,
    /// beside a second book and a loose note that match nothing.
    private func withHerShelf<T>(_ body: @MainActor (Shelf) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1074))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let video = try ops.createReading(name: "Video ideas", kind: .book)
            let chapter = try ops.createSection(in: video.id, name: "Oct 9 batch (V01\u{2013}V49)")
            let member = try ops.createPost(title: "Opening shot")
            _ = try ops.newBlock(in: member.id, text: "a slow pan across the harbor at dawn")
            try ops.addPostToReading(member.id, to: video.id)
            try ops.assignPostToSection(member.id, in: video.id, section: chapter.id)
            let recipes = try ops.createReading(name: "Recipes", kind: .book)
            let loose = try ops.createPost(title: "Groceries")
            _ = try ops.newBlock(in: loose.id, text: "lemons, salt, thyme")
            return try await body(Shelf(db: db, session: session, video: video, chapter: chapter, recipes: recipes))
        }
    }

    /// The answer the Library lists for `text` under `scope` (the one read the
    /// catalog lands — `LibrarySearchModel.listing`).
    private func listing(
        _ shelf: Shelf, _ text: String, scope: LibraryCatalogModel.Scope = .all,
        visibility: SearchVisibility = .living
    ) async throws -> LibrarySearchListing {
        let question = try #require(LibrarySearchQuestion.read(text, visibility: visibility))
        return try await shelf.db.read { db in
            try LibrarySearchModel.listing(
                db, question: question, scope: scope, wing: "", groupDepth: LibrarySearchModel.groupPageSize)
        }
    }

    /// Her search: the chapter's name finds the chapter — and the Books
    /// section does NOT stand its book in for it. RED on the pre-fix tree
    /// (the section held "Video ideas"'s book row and nothing else). The
    /// band's books count is the same on both trees: one book named.
    @Test func aChapterFoundByItsNameIsNotListedAsItsBook() async throws {
        try await withHerShelf { shelf in
            for scope in [LibraryCatalogModel.Scope.all, .books] {
                let answer = try await listing(shelf, "oct 9 batch", scope: scope)
                #expect(!answer.books.contains { $0.id == shelf.video.id },
                        "\(scope): the chapter's book is not its stand-in row — listed \(answer.books.map(\.title))")
                #expect(answer.counts?.living.books == 1, "\(scope): the band counts the one book the chapter is in")
            }
        }
    }

    /// GUARD (green on both trees): a book found by its OWN name keeps its
    /// book row, and nothing else is listed for it.
    @Test func aBookFoundByItsOwnNameKeepsItsRow() async throws {
        try await withHerShelf { shelf in
            let answer = try await listing(shelf, "video ideas")
            #expect(answer.books.map(\.id) == [shelf.video.id], "the book's own name lists the book")
            #expect(answer.counts?.living.books == 1)
            let none = try await listing(shelf, "harbor dawn")
            #expect(none.books.isEmpty, "a passage inside a member names no book row")
        }
    }

    // MARK: - The chapter row (VX-1074's new face — these compile only with
    // the fix; their red is the behavioral revert's)

    private func chapterRow(_ shelf: Shelf, _ name: String) -> LibrarySearchBookRow {
        .chapter(SearchChapterHit(
            sectionID: shelf.chapter.id, name: name, readingID: shelf.video.id,
            readingName: "Video ideas", isArchived: false))
    }

    /// Her search lists the CHAPTER as its own row — its exact name, the book
    /// it is in — and nothing else; under All and under the Books facet.
    @Test func herSearchListsTheChapterAsItsOwnRow() async throws {
        try await withHerShelf { shelf in
            for scope in [LibraryCatalogModel.Scope.all, .books] {
                let answer = try await listing(shelf, "oct 9 batch", scope: scope)
                #expect(answer.bookRows == [chapterRow(shelf, "Oct 9 batch (V01\u{2013}V49)")],
                        "\(scope): the chapter's own row, listed \(answer.bookRows)")
                #expect(answer.books.isEmpty, "\(scope): no book row stands in for it")
            }
            let notes = try await listing(shelf, "oct 9 batch", scope: .posts)
            #expect(notes.bookRows.isEmpty, "the Notes facet lists no Books section (as before)")
        }
    }

    /// A book found by its own name AND through a chapter lists BOTH rows —
    /// the book once, the chapter once; two chapters of one book are two rows
    /// and ONE book in the band's count.
    @Test func aBookAndItsChaptersListEachOnceAndTheBandCountsTheBooks() async throws {
        try await withHerShelf { shelf in
            let ops = shelf.session.operations
            let second = try ops.createSection(in: shelf.video.id, name: "Oct 16 batch")
            let cooking = try ops.createReading(name: "Batch cooking", kind: .book)
            let soups = try ops.createSection(in: cooking.id, name: "Soups in batch")
            let answer = try await listing(shelf, "batch")
            let ids = answer.bookRows.map(\.id)
            #expect(Set(ids) == [shelf.chapter.id, second.id, cooking.id, soups.id],
                    "two chapters of Video ideas, the cooking book by its own name, and its chapter: \(answer.bookRows)")
            #expect(ids.count == Set(ids).count, "every row once")
            #expect(answer.books.map(\.id) == [cooking.id], "a book row only for a book's own name")
            #expect(answer.counts?.living.books == 2, "the band counts the two books the section names")
        }
    }

    /// An archived book's chapter lists only under the archived facet, and
    /// says so; a deleted chapter lists nowhere.
    @Test func anArchivedBooksChapterWaitsForTheFacetAndADeletedOneIsGone() async throws {
        try await withHerShelf { shelf in
            let ops = shelf.session.operations
            try ops.archiveReading(shelf.video.id)
            let living = try await listing(shelf, "oct 9 batch")
            #expect(living.bookRows.isEmpty, "the living corpus leaves the archived book's chapter out")
            let archived = try await listing(shelf, "oct 9 batch", visibility: .includingArchived)
            #expect(archived.bookRows == [.chapter(SearchChapterHit(
                sectionID: shelf.chapter.id, name: "Oct 9 batch (V01\u{2013}V49)", readingID: shelf.video.id,
                readingName: "Video ideas", isArchived: true))],
                    "under the facet it lists, wearing its book's archived fact")
            try ops.deleteSection(shelf.chapter.id)
            let gone = try await listing(shelf, "oct 9 batch", visibility: .includingArchived)
            #expect(gone.bookRows.isEmpty, "a deleted chapter is not listed")
        }
    }

    // MARK: - What the sheet DRAWS

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval = 0.6) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// The MOUNTED Library, both voices: her search draws the chapter row —
    /// its name, "chapter", "in Video ideas" in the voice's case — and the
    /// band counts the one book (the oracle's `.chapterRow` / `.countsLine`).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theSheetDrawsTheChapterRow(voice: ThemeVoice) async throws {
        #if DEBUG
        try await withHerShelf { shelf in
            let session = shelf.session
            try session.operations.setThemeVoice(voice)
            let suite = "vx-1074-chapter-row-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            LibrarySearchDrawnOracle.reset()
            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: 1_100, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: AnyView(
                LibraryCatalogView(
                    session: session, model: model, library: LibraryViewModel(session: session),
                    tags: TagsViewModel(session: session), onOpen: { _ in },
                    onOpenChapter: { _, _ in })
                .environment(theme)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1_100, height: 700)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            await Self.settle(window, hosting, 1.0)
            model.query = "oct 9 batch"
            await model.search()
            await Self.settle(window, hosting)
            let tokens = theme.tokens(for: .light)
            #expect(LibrarySearchDrawnOracle.drawn(.chapterRow, in: session)
                    == CatalogChapterLine.words(
                        tokens: tokens, name: "Oct 9 batch (V01\u{2013}V49)",
                        detail: SearchAnswerCopy.kindWord(.chapter) ?? "", book: "Video ideas"),
                    "\(voice): the chapter row reads name · chapter · in Video ideas — drew \(LibrarySearchDrawnOracle.drawn(.chapterRow, in: session) ?? "nil")")
            #expect(LibrarySearchDrawnOracle.drawn(.countsLine, in: session)
                    == tokens.chromeLabel(LibrarySearchFace.countsLead(
                        LibrarySearchCopy.counts(.init(books: 1, notes: 0, passages: 0, scraps: 0)), afterEcho: true)),
                    "\(voice): the band counts the one book the chapter is in")
        }
        #endif
    }
}
