//
//  LibrarySearchStateTests.swift
//  VariorumTests
//
//  **13o U2 — the Library's SEARCH STATE** (Direction C, R-13o-15; the
//  plan's U2 RECORD D1–D8). Her rulings these pins hold:
//
//  - R-13o-7 — *"library field should be one giant finder — no new search
//    mode"*: the field's words ARE the search; the shipped title-LIKE
//    narrowing on that road is retired.
//  - R-13o-15 — *"direction C, the answer sheet"*: passages GROUPED under
//    their notes, ranked by their best hit; the band's honest counts.
//  - R-13o-9 — *"block / scrap 40 cap should not exist - the 40 cap with no
//    escape is terrible"*: the 41st named block and the 41st scrap are
//    REACHABLE — groups page, every "all N ›" pages.
//
//  These are BUILD pins for a new road (her design rows, not bug rows): on
//  the pre-change tree they do not compile (`searchState`, `isSearching`,
//  `searchGroupAppeared` did not exist). The cap's old shape is recorded
//  rather than reproduced: the same 45 named blocks listed 40 under "showing
//  the first 40 — narrow the search", with no road to the five.
//
//  Every model gets a scrubbed `UserDefaults` (the suites share the dev-store
//  app's `.standard` — KnownIssues R1-7).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13o U2 — the Library's search state (the answer sheet's brain)", .serialized)
struct LibrarySearchStateTests {
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
            let suite = "13o-u2-search-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            return try await body(session, LibraryCatalogModel(session: session, defaults: defaults))
        }
    }

    // MARK: - The question (pure)

    @Test func theFieldsTextIsReadIntoTheOneAST() {
        let question = LibrarySearchQuestion.read("dream #journal ")
        #expect(question?.hasWords == true)
        #expect(question?.words == "dream")
        #expect(question?.tagPaths == ["journal"])
        #expect(question?.query.text == .word("dream"), "a word followed by space is whole")
        #expect(question?.query.filter == .tagPath("journal"))

        let typing = LibrarySearchQuestion.read("drea")
        #expect(typing?.query.text == .prefix("drea"), "the tail still being typed is a prefix")

        let tagOnly = LibrarySearchQuestion.read("#journal")
        #expect(tagOnly != nil && tagOnly?.hasWords == false, "a tag alone asks, without words")
        #expect(LibrarySearchQuestion.read("   ") == nil, "a blank field asks nothing")

        let range = SearchDayRange(field: .edited, start: "a", end: "b")
        let dated = LibrarySearchQuestion.read("dream ", range: range)
        #expect(dated?.query.filter == .days(range), "the armed range joins the filter half (D5)")
    }

    @Test func eachScopeNarrowsTheQuestionItsOwnWay() throws {
        let question = try #require(LibrarySearchQuestion.read("dream "))
        #expect(question.scoped(.all) == question.query)
        #expect(question.scoped(.posts).filter == .family(.notes))
        #expect(question.scoped(.books).filter == .family(.books))
        #expect(question.scoped(.blocks).filter == .any([.family(.scraps), .docKind(.blockName)]),
                "Blocks = the scraps beside block NAMES (D3)")
    }

    @Test func aTagChipsCrossTakesOnlyThatTag() {
        #expect(LibrarySearchQuestion.removingTag("journal", from: "dream #journal ") == "dream ")
        #expect(LibrarySearchQuestion.removingTag("journal", from: "dream #journal") == "dream ",
                "the word before a removed LAST tag stays whole, never turns into a prefix")
        #expect(LibrarySearchQuestion.removingTag("journal", from: "#journal dream") == "dream",
                "a word still being typed stays a prefix")
        #expect(LibrarySearchQuestion.removingTag("Journal", from: "#journal/ x #work ") == "x #work ")
        #expect(LibrarySearchQuestion.removingTag("nope", from: "dream #journal") == "dream #journal")
    }

    // MARK: - The search state (D1/D2)

    @Test func wordsAreTheAnswerSheetNoteHeadsMirrorTheGroups() async throws {
        try await withLibrary { session, model in
            let ops = session.operations
            let night = try ops.createPost(title: "The Night Office")
            for i in 0..<4 { _ = try ops.newBlock(in: night.id, text: "the dream \(i) still wet") }
            let titled = try ops.createPost(title: "A Dream Within a Dream")
            let unrelated = try ops.createPost(title: "Shopping")
            _ = try ops.newBlock(in: unrelated.id, text: "eggs and bread")
            let book = try ops.createReading(name: "dream journal", kind: .book)
            let pool = try ops.createPool(title: "Heap")
            _ = try ops.newBlock(in: pool.id, text: "the dream economy runs on mornings")

            await model.search()
            #expect(!model.isSearching && !model.searchState.asksAnything)
            #expect(model.noteHits.count == 3, "the shipped listing, unnarrowed")

            model.query = "dream "
            await model.search()
            #expect(model.isSearching)
            let state = model.searchState
            #expect(Set(state.groups.map(\.homeID)) == [night.id, titled.id, pool.id],
                    "passages GROUP under their homes; the shopping note is not an answer")
            #expect(model.noteHits.map(\.id) == state.groups.compactMap(\.note).map(\.id),
                    "the List's note rows ARE the note groups' heads, in rank order (D2)")
            #expect(!model.noteHits.contains { $0.id == pool.id }, "a scraps group is not a note row")
            #expect(model.bookHits.map(\.id) == [book.id], "the Books section: the book a hit names")
            #expect(state.books.map(\.id) == [book.id])
            let counts = try #require(state.counts)
            #expect(counts.living.books == 1 && counts.living.notes == 2
                    && counts.living.passages == 4 && counts.living.scraps == 1)
            #expect(state.groups.first { $0.homeID == night.id }?.lines.count == 3,
                    "a group shows its top three; the fourth waits behind all N ›")

            // The pick and the info panel ride the heads, unchanged.
            model.clickNoteRow(night.id, modifiers: .none)
            #expect(model.infoHit?.id == night.id)

            model.query = ""
            await model.search()
            #expect(!model.isSearching && model.searchState.groups.isEmpty)
            #expect(model.noteHits.count == 3, "a cleared field is the whole Library again")
        }
    }

    @Test func aTagAloneListsNothingUntilWordsJoinIt() async throws {
        try await withLibrary { session, model in
            let note = try session.operations.createPost(title: "dream note")
            _ = try session.operations.newBlock(in: note.id, text: "words")
            model.query = "#dream"
            await model.search()
            #expect(model.searchState.asksAnything, "the band says the question (P-13o-U2-1)")
            #expect(!model.isSearching, "no words, no answer sheet")
            #expect(model.hits.isEmpty, "PROVISIONAL P-13o-U2-6: nothing listed under a tag alone")
            model.removeTypedTag("dream")
            #expect(model.query.isEmpty)
        }
    }

    // MARK: - Scopes (D3) — the counts are the whole question's

    @Test func theScopePickerNarrowsTheSheetNeverTheCounts() async throws {
        try await withLibrary { session, model in
            let ops = session.operations
            let note = try ops.createPost(title: "Ember")
            let named = try ops.newBlock(in: note.id, text: "ember prose")
            try ops.setBlockName(named.block.id, name: "ember name")
            let pool = try ops.createPool(title: "Heap")
            _ = try ops.newBlock(in: pool.id, text: "ember scrap")
            let book = try ops.createReading(name: "Ember Book", kind: .book)
            model.query = "ember "
            await model.search()
            let counts = model.searchState.counts

            model.pickScope(.posts)
            await model.search()
            #expect(model.searchState.groups.map(\.homeID) == [note.id] && model.bookHits.isEmpty)
            #expect(model.searchState.counts == counts, "the band's numbers never move with the scope")

            model.pickScope(.books)
            await model.search()
            #expect(model.searchState.groups.isEmpty && model.bookHits.map(\.id) == [book.id])

            model.pickScope(.blocks)
            await model.search()
            #expect(Set(model.searchState.groups.map(\.homeID)) == [note.id, pool.id])
            #expect(model.searchState.groups.first { $0.homeID == note.id }?.lines.map(\.kind)
                    == [.blockName], "a note under Blocks shows its block NAME only")
            #expect(model.bookHits.isEmpty)
        }
    }

    // MARK: - The cap's death (R-13o-9) — the 41st is reachable

    @Test func theFortyFirstNamedBlockAndTheFortyFirstScrapAreReachable() async throws {
        try await withLibrary { session, model in
            let ops = session.operations
            var named: Set<String> = []
            for i in 0..<45 {
                let note = try ops.createPost(title: "holder \(i)")
                let made = try ops.newBlock(in: note.id, text: "plain words")
                try ops.setBlockName(made.block.id, name: "lantern \(i)")
                named.insert(note.id)
            }
            let pool = try ops.createPool(title: "Heap")
            var scraps: Set<String> = []
            for i in 0..<60 {
                scraps.insert(try ops.newBlock(in: pool.id, text: "a lantern scrap \(i)").variant.id)
            }
            model.query = "lantern "
            model.pickScope(.blocks)
            await model.search()
            let state = model.searchState
            #expect(state.groups.count == LibrarySearchModel.groupPageSize, "a page, never a cap")
            #expect(state.hasMoreGroups)

            // Scroll: every group comes on screen; the next page arrives.
            var rounds = 0
            while state.hasMoreGroups, rounds < 10 {
                let last = try #require(state.groups.last)
                #expect(model.searchGroupAppeared(last, spawning: false), "near the end asks")
                await model.loadMoreSearchGroups()
                rounds += 1
            }
            let homes = state.groups.map(\.homeID)
            #expect(Set(homes) == named.union([pool.id]) && homes.count == 46,
                    "all 45 named blocks' notes and the scraps group — each once")

            // The scraps group: 60 scraps behind one "all N ›".
            let heap = try #require(state.groups.first { $0.homeID == pool.id })
            #expect(heap.lineCount == 60 && heap.lines.count == 3)
            await state.toggleExpansion(pool.id)
            #expect(state.expansions[pool.id]?.lines.count == LibrarySearchModel.linePageSize)
            #expect(state.expansions[pool.id]?.next != nil, "a road to the rest")
            await state.loadMoreLines(pool.id)
            #expect(Set(state.expansions[pool.id]?.lines.map(\.sourceID) ?? []) == scraps,
                    "every scrap, the 41st and the 60th among them")
            #expect(state.expansions[pool.id]?.next == nil)
            await state.toggleExpansion(pool.id)
            #expect(state.expansions[pool.id] == nil, "the same word closes it")
        }
    }

    @Test func aNewQuestionDropsAPageReadUnderTheOldOne() async throws {
        try await withLibrary { session, model in
            for i in 0..<40 {
                let note = try session.operations.createPost(title: "quokka \(i)")
                _ = try session.operations.newBlock(in: note.id, text: "quokka words")
            }
            model.query = "quokka "
            await model.search()
            #expect(model.searchState.hasMoreGroups)
            let stale = Task { await model.loadMoreSearchGroups() }
            model.query = "words "
            await model.search()
            await stale.value
            #expect(model.searchState.question?.words == "words")
            #expect(model.searchState.groups.count == LibrarySearchModel.groupPageSize,
                    "the superseded page never landed on the new answer")
            #expect(Set(model.noteHits.map(\.id)).count == model.noteHits.count, "no head twice")
        }
    }

    @Test func anActReReadsTheSheetInPlaceAtItsDepthWithItsGroupsStillOpen() async throws {
        try await withLibrary { session, model in
            var first = ""
            for i in 0..<40 {
                let note = try session.operations.createPost(title: "quokka \(i)")
                for j in 0..<5 { _ = try session.operations.newBlock(in: note.id, text: "quokka \(j)") }
                if i == 0 { first = note.id }
            }
            model.query = "quokka "
            await model.search()
            await model.loadMoreSearchGroups()
            #expect(model.searchState.groups.count == 40)
            let opened = try #require(model.searchState.groups.first).homeID
            await model.searchState.toggleExpansion(opened)
            #expect(model.searchState.expansions[opened]?.lines.count == 5)

            await model.refresh()
            #expect(model.searchState.groups.count == 40, "the depth she paged to, re-read in place")
            #expect(model.searchState.expansions[opened]?.lines.count == 5,
                    "the group she opened stays open, its lines re-read")
            _ = first
        }
    }

    // MARK: - The archived facet (D4)

    @Test func theArchivedFacetIsOneQuietToggleAndAClearedFieldPutsItBack() async throws {
        try await withLibrary { session, model in
            let living = try session.operations.createPost(title: "orchid living")
            let stored = try session.operations.createPost(title: "orchid stored")
            try session.operations.archiveContainer(stored.id)
            model.query = "orchid "
            await model.search()
            #expect(model.searchState.groups.map(\.homeID) == [living.id])
            #expect(model.searchState.counts?.archivedPlaces == 1, "what the facet would add")

            model.toggleArchivedFacet()
            await model.search()
            #expect(Set(model.searchState.groups.map(\.homeID)) == [living.id, stored.id])
            #expect(model.searchState.groups.first { $0.homeID == stored.id }?.isArchived == true)

            model.query = ""
            await model.search()
            #expect(model.searchState.visibility == .living, "a question she asked once, never remembered")
        }
    }
}
