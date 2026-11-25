//
//  BookSearchChapterRowsTests.swift
//  VariorumTests
//
//  **VX-1074, the book's own 🔍 (the architect's D-1082-S1 — proposal (a)).**
//  Searching a book for one of its chapter names, the engine FOUND the chapter
//  (it counts among the composer's `books`), but the book's band said
//  "— nothing in this book matches" over it and the sheet drew "Nothing in
//  this book matches." — the band's counts speak passages and notes only, and
//  the sheet lists note groups only (traced in
//  `notes/plans/fixes/vx-1082-nov-24-fixes.md`, BATCH S). Now the book's own
//  chapters found by name list above the note groups, one click closing the
//  field and landing the Outline at the chapter, and the band counts them as
//  their own kind: "1 chapter · 14 passages in 5 notes" (PROVISIONAL words).
//
//  The rows and the band's words are the MODEL's (`BookSearchModel.chapters`,
//  `.bandCounts` — the band draws `bandCounts` verbatim through the voice's
//  chrome case), so these pins read what the face says. The new API cannot
//  compile on the pre-fix tree; their red is the behavioral revert's (the one
//  chapter read emptied — the record's recipe): RED there —
//  `herSearchInsideTheBookListsTheChapterAndTheBandCountsIt`,
//  `aChapterAndAPassageCountTogether`, `twoChaptersAreTwoRowsAndTwoInTheCount`,
//  `onlyThisBooksChaptersList`. GUARDS, green on both sides: the book's own
//  name is no row; a gathering has no chapter rows; closing clears them; the
//  count words with no chapter say exactly what they said.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1074 — a book's own search lists its chapters found by name, and counts them", .serialized)
struct BookSearchChapterRowsTests {
    struct Shelf {
        let session: AppSession
        let video: Reading
        let chapter: ReadingSection
        let member: String
    }

    /// Her book: "Video ideas" with a chapter "Oct 9 batch (V01–V49)" holding a
    /// member whose words are `memberText`, beside a second book whose chapter
    /// also says "Oct 9 batch".
    private func withHerBook<T>(
        memberText: String = "a slow pan across the harbor at dawn",
        _ body: @MainActor (Shelf) async throws -> T
    ) async throws -> T {
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
            _ = try ops.newBlock(in: member.id, text: memberText)
            try ops.addPostToReading(member.id, to: video.id)
            try ops.assignPostToSection(member.id, in: video.id, section: chapter.id)
            let other = try ops.createReading(name: "Other book", kind: .book)
            _ = try ops.createSection(in: other.id, name: "Oct 9 batch notes")
            return try await body(Shelf(session: session, video: video, chapter: chapter, member: member.id))
        }
    }

    private func search(_ shelf: Shelf, _ text: String, in readingID: String? = nil) async -> BookSearchModel {
        let model = BookSearchModel(session: shelf.session, readingID: readingID ?? shelf.video.id)
        model.open()
        await model.setText(text)
        return model
    }

    /// Her search, inside her book: the chapter is listed (its exact name)
    /// and the band counts it — never "nothing in this book matches" over it.
    @Test func herSearchInsideTheBookListsTheChapterAndTheBandCountsIt() async throws {
        try await withHerBook { shelf in
            let model = await search(shelf, "oct 9 batch")
            #expect(model.isAnswering, "a typed search — the answer covers the book")
            #expect(model.chapters == [SearchChapterHit(
                sectionID: shelf.chapter.id, name: "Oct 9 batch (V01\u{2013}V49)", readingID: shelf.video.id,
                readingName: "Video ideas", isArchived: false)],
                    "the book's own chapter, by its own name: \(model.chapters)")
            #expect(model.groups.isEmpty, "no note's words match")
            #expect(model.bandCounts == "1 chapter", "the band counts the chapter, said \"\(model.bandCounts)\"")
            #expect(model.bandCounts != BookSearchCopy.nothing, "never the false nothing")
        }
    }

    /// A chapter and a member's passage both match: the chapter leads the
    /// band's words, the passages and notes after it.
    @Test func aChapterAndAPassageCountTogether() async throws {
        try await withHerBook(memberText: "the first batch of opening shots") { shelf in
            let model = await search(shelf, "batch")
            #expect(model.chapters.map(\.sectionID) == [shelf.chapter.id], "this book's one chapter")
            #expect(model.groups.map(\.homeID) == [shelf.member], "and the note whose words match")
            #expect(model.bandCounts == "1 chapter \u{00B7} 1 passage in 1 note", "said \"\(model.bandCounts)\"")
        }
    }

    /// Two of the book's chapters match: two rows, "2 chapters".
    @Test func twoChaptersAreTwoRowsAndTwoInTheCount() async throws {
        try await withHerBook { shelf in
            let second = try shelf.session.operations.createSection(in: shelf.video.id, name: "Oct 16 batch")
            let model = await search(shelf, "batch")
            #expect(Set(model.chapters.map(\.sectionID)) == [shelf.chapter.id, second.id], "\(model.chapters)")
            #expect(model.chapters.count == 2, "each once")
            #expect(model.bandCounts == "2 chapters", "said \"\(model.bandCounts)\"")
        }
    }

    /// Another book's chapter of the same words is not this book's.
    @Test func onlyThisBooksChaptersList() async throws {
        try await withHerBook { shelf in
            let model = await search(shelf, "oct 9 batch")
            #expect(model.chapters.map(\.readingID) == [shelf.video.id],
                    "only Video ideas' own chapter, never the other book's: \(model.chapters)")
        }
    }

    // MARK: - Guards (green on both sides)

    /// Searching a book for its OWN name finds nothing in it — as before.
    @Test func theBooksOwnNameIsNoRow() async throws {
        try await withHerBook { shelf in
            let model = await search(shelf, "video ideas")
            #expect(model.chapters.isEmpty)
            #expect(model.groups.isEmpty)
        }
    }

    /// A gathering has no chapters — no chapter row, whatever its rule.
    @Test func aGatheringHasNoChapterRows() async throws {
        try await withHerBook { shelf in
            let ops = shelf.session.operations
            let tag = try ops.createTag(name: "batch")
            _ = try ops.applyTag(tag.id, toPost: shelf.member)
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let gathering = try ops.createReading(name: "Batch gathering", kind: .gathering, querySpec: rule)
            let model = await search(shelf, "batch", in: gathering.id)
            #expect(model.chapters.isEmpty, "\(model.chapters)")
        }
    }

    /// The field closed: the chapters go with the rest of the answer.
    @Test func closingClearsTheChapters() async throws {
        try await withHerBook { shelf in
            let model = await search(shelf, "oct 9 batch")
            model.close()
            #expect(model.chapters.isEmpty && model.groups.isEmpty && model.counts == nil)
        }
    }

    /// The band's words, pure: with no chapter they are exactly what they
    /// were; chapters lead as their own kind.
    @Test func theCountWordsLeadWithTheChapters() {
        let kinds = SearchCounts.Kinds(books: 1, notes: 5, passages: 14, scraps: 0)
        #expect(BookSearchCopy.counts(kinds) == "14 passages in 5 notes", "no chapter: unchanged")
        #expect(BookSearchCopy.counts(kinds, chapters: 1) == "1 chapter \u{00B7} 14 passages in 5 notes")
        #expect(BookSearchCopy.counts(.init(books: 1, notes: 2, passages: 0, scraps: 0), chapters: 2)
                == "2 chapters \u{00B7} 2 notes")
        #expect(BookSearchCopy.counts(.init(books: 1, notes: 0, passages: 0, scraps: 0), chapters: 1) == "1 chapter")
        #expect(BookSearchCopy.counts(.init(books: 1, notes: 0, passages: 0, scraps: 0)) == BookSearchCopy.nothing,
                "a book-name hit alone still says nothing in this book")
    }
}
