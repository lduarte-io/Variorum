//
//  LibrarySearchJoinTests.swift
//  VariorumTests
//
//  **13o U3 — the Library's Books section reads the TAG-ASSOCIATION JOIN,
//  and the band carries the MODE FACETS** (the 13i sitting record §12, her
//  ruled inputs to this phase: *"a tag's results surface the
//  books/gatherings associated with it (intake/auto-tag), top-ranked"* — and
//  *"mode facets as search filters — gathering · living · owned · finished ·
//  sealed (facts on the row, NEVER tags)"*). The mockup's row: *"dream
//  journal  #dream flows here"*.
//
//  BUILD pins for new roads (her design rows, not bug rows): on the pre-U3
//  tree they do not compile (`bookReasons`, `armBookState`,
//  `offersBookState`, `SearchBookState` did not exist), and a typed tag
//  alone listed nothing (U2's P-13o-U2-6, narrowed here).
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13o U3 — the join in the Books section, the mode facets in the band", .serialized)
struct LibrarySearchJoinTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(7) }
                return value
            }
        }
    }

    private func withLibrary<T>(
        _ body: @MainActor (AppSession, LibraryCatalogModel) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let suite = "13o-u3-join-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            return try await body(session, LibraryCatalogModel(session: session, defaults: defaults))
        }
    }

    /// A dream library: a book and a gathering whose rules collect #dream, a
    /// book whose outflow tags #dream/lucid, a book NAMED dream but unrelated,
    /// and a note tagged #dream that says "harbor".
    private struct Shelf {
        let journal: Reading, gathering: Reading, outflow: Reading, named: Reading
        let note: Container
    }

    private func shelf(_ ops: Operations) throws -> Shelf {
        let dream = try ops.createTag(name: "dream")
        let lucid = try ops.createTag(parent: dream.id, name: "lucid")
        let spec = try RuleGrammar.encode(.tag(dream.id))
        let journal = try ops.createReading(name: "Dream journal", kind: .book, querySpec: spec)
        let gathering = try ops.createReading(name: "All dreams", kind: .gathering, querySpec: spec)
        let outflow = try ops.createReading(name: "Lucid log", kind: .book, autoTagIDs: [lucid.id])
        let named = try ops.createReading(name: "Harbor dreams", kind: .book)
        let note = try ops.createPost(title: "Night")
        _ = try ops.newBlock(in: note.id, text: "the harbor at night")
        _ = try ops.applyTag(dream.id, toPost: note.id)
        return Shelf(journal: journal, gathering: gathering, outflow: outflow, named: named, note: note)
    }

    // MARK: - The join

    @Test func aTypedTagAloneListsItsAssociatedBooksSayingWhy() async throws {
        try await withLibrary { session, model in
            let s = try shelf(session.operations)
            model.query = "#dream"
            await model.search()
            let state = model.searchState
            #expect(!model.isSearching, "no words: no passages, no groups")
            #expect(state.answersAnything, "…but the tag answers with its books")
            #expect(model.bookHits.map(\.id) == [s.gathering.id, s.journal.id, s.outflow.id],
                    "flows-in by name, then the outflow — never the merely NAMED book")
            // JUSTIFIED EDIT (VX-84a): this read `noteHits.isEmpty` — "notes
            // still ask for words (P-13o-U2-6, narrowed)". Her report
            // superseded it (D-1: a tag alone narrows the Library), so the
            // tagged note lists under the associated books.
            #expect(model.noteHits.map(\.id) == [s.note.id], "the note the tag names, listed (D-1)")
            #expect(state.bookReasons[s.journal.id].map(LibrarySearchCopy.association) == "#dream flows here",
                    "the mockup's own words")
            #expect(state.bookReasons[s.outflow.id].map(LibrarySearchCopy.association)
                    == "notes here are tagged #dream/lucid")
            #expect(state.counts?.living.books == 3 && state.counts?.living.notes == 1,
                    "the band counts them — and the tagged note (VX-84a)")
        }
    }

    @Test func withWordsTheAssociatedBooksLeadTheNameHits() async throws {
        try await withLibrary { session, model in
            let s = try shelf(session.operations)
            model.query = "harbor "
            await model.search()
            #expect(model.bookHits.map(\.id) == [s.named.id], "control: words alone — the name hit")
            #expect(model.searchState.bookReasons.isEmpty)

            model.query = "harbor #dream "
            await model.search()
            #expect(model.bookHits.map(\.id) == [s.gathering.id, s.journal.id, s.outflow.id],
                    "the typed tag's books lead; a tag narrows the name hits away (the filter half)")
            #expect(model.noteHits.map(\.id) == [s.note.id], "the tagged note's passage, grouped")
            model.query = ""
            await model.search()
            #expect(model.searchState.bookReasons.isEmpty, "a cleared field forgets the reasons")
        }
    }

    // MARK: - The mode facets

    @Test func theBookStateFacetNarrowsTheBooksAndMovesTheScope() async throws {
        try await withLibrary { session, model in
            let s = try shelf(session.operations)
            try session.operations.lockReading(s.outflow.id)
            model.query = "#dream"
            await model.search()
            #expect(model.offersBookState, "the chip is offered while the sheet answers")

            model.pickScope(.posts)
            model.armBookState(.living)
            #expect(model.scope == .books, "a facet names BOOKS — the day's mirror moves the scope")
            await model.search()
            #expect(model.searchState.question?.query.filter == .all([.tagPath("dream"), .bookState(.living)]),
                    "the facet is a leaf of the one filter half")
            #expect(model.bookHits.map(\.id) == [s.journal.id], "only the living book (intake on)")

            model.armBookState(.finished)
            await model.search()
            #expect(model.bookHits.map(\.id) == [s.outflow.id], "the finished outflow book")

            model.armBookState(.gathering)
            await model.search()
            #expect(model.bookHits.map(\.id) == [s.gathering.id])

            model.armBookState(nil)
            await model.search()
            #expect(model.bookHits.count == 3, "the ✕ gives every associated book back")

            model.pickScope(.all)
            model.armBookState(.owned)
            #expect(model.scope == .all, "All stays All (the day's own rule)")
            await model.search()
            #expect(model.bookHits.isEmpty, "no owned book is associated")
        }
    }

    @Test func aDayAndABookStateNeverStandTogether() async throws {
        try await withLibrary { session, model in
            _ = try shelf(session.operations)
            model.query = "harbor "
            await model.search()
            model.armBookState(.living)
            #expect(model.searchState.bookState == .living)
            model.setEditedRange(LibraryDayRange(day: "2026-07-01"))
            #expect(model.searchState.bookState == nil, "the day she arms takes the facet's place")
            #expect(!model.offersBookState, "under a day the facet could never act — not offered (P-2)")
            model.setEditedRange(nil)
            #expect(model.offersBookState)

            model.armBookState(.sealed)
            model.query = ""
            await model.search()
            #expect(model.searchState.bookState == nil, "a cleared field forgets the facet, as the archived one")
        }
    }

    // MARK: - The faces' words

    @Test func theChipsAndReasonsSayWhatTheyAre() {
        #expect(LibrarySearchCopy.bookStateOff == "+ book state", "the mockup's chip")
        #expect(SearchBookState.allCases.map(LibrarySearchCopy.bookStateChoice)
                == ["gathering", "living", "owned", "finished", "sealed"],
                "the mockup's own five, in its order")
        #expect(LibrarySearchCopy.bookStateChip(.living) == "living books")
        #expect(LibrarySearchCopy.bookStateChip(.gathering) == "gatherings")
        #expect(LibrarySearchCopy.association(.flowsIn(path: "dream")) == "#dream flows here")
    }

    @Test(arguments: [ThemeVoice.terminal, .study], [false, true])
    func theBandWithTheFacetLaysOutInEveryRoom(voice: ThemeVoice, dark: Bool) throws {
        let tokens = VoiceTokens.resolve(voice: voice, dark: dark)
        let question = try #require(LibrarySearchQuestion.read("dream #journal ", bookState: .living))
        for armed in [SearchBookState?.none, .living] {
            let band = LibrarySearchBand(
                tokens: tokens, question: question,
                counts: .init(books: 3, notes: 0, passages: 0, scraps: 0),
                visibility: .living, wingName: "Home",
                onRemoveTag: { _ in }, onToggleArchived: {},
                bookState: armed, offersBookState: true, onPickBookState: { _ in })
            let host = NSHostingView(rootView: band.frame(width: 900))
            host.frame = NSRect(x: 0, y: 0, width: 900, height: 60)
            host.layoutSubtreeIfNeeded()
            let fitting = host.fittingSize
            #expect(fitting.height > 16 && fitting.height < 60, "one quiet line: \(fitting)")
        }
    }
}
