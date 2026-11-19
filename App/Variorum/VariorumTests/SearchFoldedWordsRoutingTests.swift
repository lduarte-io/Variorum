//
//  SearchFoldedWordsRoutingTests.swift
//  VariorumTests
//
//  VX-954 · VX-955 (the VX-980 run, batch 1; `notes/plans/fixes/vx-980-search-fixes.md`)
//  — the APP's routing reads the ONE core predicate (`SearchComposer.asksWords`).
//
//  A dash beside a tag answered less than the tag alone because the app
//  routed on `query.text != nil` in THREE places — the Library's `hasWords`,
//  the book's band (`BookSearchModel`), and ⌘K's passages
//  (`PaletteModel.passageQuestion`) — while the core's text-less readers were
//  guarded the same way. These pins hold every face to the core predicate:
//  `— #flora` (and VX-888's other shapes, `+ #flora` among them) IS `#flora`
//  in the Library's whole routed answer, in the book's band and in ⌘K; a
//  symbol word beside real words is words (VX-955); and a field of ONLY
//  punctuation or symbols keeps today's reading (PROVISIONAL P-980-1 (a)).
//
//  The core pins (`SearchFoldedWordsBesideATagTests`, `SearchSymbolWordTests`,
//  `SearchTokenizerSweepTests`) ran red on the pre-fix tree; these were
//  written with the fix and are run at the orchestrator's gate.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-954 — every face routes a folded word beside a tag as the tag alone", .serialized)
struct SearchFoldedWordsRoutingTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(7) }
                return value
            }
        }
    }

    private func withSession<T>(_ body: @MainActor (AppSession) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    /// VX-888's fixture: `flora` on two notes (one also on a block of its
    /// own), on a scrap's block, and the rule of one living book — plus tags
    /// named by the punctuation itself, so a face still treating it as words
    /// would offer them.
    private func flora(_ ops: Operations) throws {
        let flora = try ops.createTag(name: "flora")
        let rose = try ops.createPost(title: "Rose")
        let inRose = try ops.newBlock(in: rose.id, text: "a red one")
        _ = try ops.applyTag(flora.id, toPost: rose.id)
        _ = try ops.applyTag(flora.id, toBlock: inRose.block.id)
        let lily = try ops.createPost(title: "Lily")
        _ = try ops.newBlock(in: lily.id, text: "a white one")
        _ = try ops.applyTag(flora.id, toPost: lily.id)
        let pool = try ops.createPool(title: "Heap")
        let scrap = try ops.newBlock(in: pool.id, text: "a loose petal")
        _ = try ops.applyTag(flora.id, toBlock: scrap.block.id)
        _ = try ops.createReading(
            name: "Garden", kind: .book, querySpec: try RuleGrammar.encode(.tag(flora.id)))
        for name in ["—", "…", "-", "+"] { _ = try ops.createTag(name: name) }
    }

    private static let foldedBesideATag = ["— #flora", "#flora —", "\"—\" #flora", "… #flora", "- #flora", "+ #flora"]

    // MARK: - The question (pure)

    /// The Library's `hasWords` IS the core predicate, shape by shape.
    @Test(arguments: [
        "— #flora", "#flora —", "\"—\" #flora", "… #flora", "- #flora", "+ #flora",
        "#flora", "red", "red +", "red $", "1 + 1", "—", "+", "#", "…", "red #flora", "+ red #flora",
    ])
    func theLibrarysWordsAreTheCorePredicate(_ text: String) throws {
        let question = try #require(LibrarySearchQuestion.read(text))
        #expect(question.hasWords == SearchComposer.asksWords(question.query))
    }

    /// The three routing sites, read without a store: a folded word beside a
    /// tag has no words and still answers (its tag); a symbol beside real
    /// words is words; a field of only punctuation keeps today's reading —
    /// the words road, and ⌘K keeps its "all matches" row (P-980-1 (a)).
    @Test func everyRoutingSiteReadsTheOnePredicate() {
        for text in Self.foldedBesideATag {
            let question = LibrarySearchQuestion.read(text)
            #expect(question?.hasWords == false && question?.answers == true, "\(text): the tag road")
            #expect(PaletteModel.passageQuestion(text) == nil, "\(text): ⌘K asks the index nothing, as #flora")
        }
        for text in ["red +", "red $", "red ©", "1 + 1"] {
            #expect(LibrarySearchQuestion.read(text)?.hasWords == true, "\(text): words")
            #expect(PaletteModel.passageQuestion(text) != nil, "\(text): ⌘K asks the index")
        }
        for text in ["—", "+", "#", "…", "\"—\"", "$ ©"] {
            #expect(LibrarySearchQuestion.read(text)?.hasWords == true, "\(text): today's reading (P-980-1 (a))")
            #expect(PaletteModel.passageQuestion(text) != nil, "\(text): ⌘K keeps today's all-matches row")
        }
    }

    // MARK: - The Library's whole routed answer

    /// The catalog's ONE read (`LibraryCatalogModel.listing` — the notes, the
    /// blocks, the books, the band's counts, the offers), under every scope:
    /// a folded word beside a tag answers exactly what the tag alone answers.
    @Test(arguments: ["— #flora", "#flora —", "\"—\" #flora", "… #flora", "- #flora", "+ #flora"])
    func theLibrarysListingForAFoldedWordBesideATagIsTheTagAlones(_ text: String) async throws {
        try await withSession { session in
            try flora(session.operations)
            for scope in [LibraryCatalogModel.Scope.all, .posts, .books, .blocks] {
                let (alone, beside) = try await session.database.read { db in
                    func read(_ text: String) throws -> LibraryCatalogModel.Listing {
                        try LibraryCatalogModel.listing(
                            db, question: LibrarySearchQuestion.read(text), scope: scope,
                            sort: .lastTouched, direction: .desc, day: nil, wing: "",
                            noteDepth: LibraryCatalogModel.pageSize, groupDepth: LibrarySearchModel.groupPageSize)
                    }
                    return (try read("#flora"), try read(text))
                }
                #expect(beside.notes.map(\.id) == alone.notes.map(\.id), "\(text) under \(scope): the notes")
                #expect(beside.blocks.map(\.id) == alone.blocks.map(\.id), "\(text) under \(scope): the blocks")
                #expect(beside.books.map(\.id) == alone.books.map(\.id), "\(text) under \(scope): the books")
                #expect(beside.search?.counts == alone.search?.counts, "\(text) under \(scope): the band")
                #expect(beside.search?.tagOffers == alone.search?.tagOffers, "\(text) under \(scope): the offers")
                #expect((beside.narrowing == nil) == (alone.narrowing == nil), "\(text) under \(scope): narrowed")
            }
        }
    }

    // MARK: - The book's band

    /// The book's band answers on the one predicate: a symbol beside a word
    /// finds the word's note (VX-955); a folded word beside a tag is the tag
    /// alone — the book's content stays (VX-954); a field of only punctuation
    /// keeps today's reading, an answer that finds nothing (P-980-1 (a)).
    @Test func theBooksBandReadsTheOnePredicate() async throws {
        try await withSession { session in
            let ops = session.operations
            let book = try ops.createReading(name: "The Work", kind: .book)
            let member = try ops.createPost(title: "Night office")
            _ = try ops.newBlock(in: member.id, text: "woke with a red dream")
            _ = try ops.addPostToReading(member.id, to: book.id)

            let search = BookSearchModel(session: session, readingID: book.id)
            search.open()
            await search.setText("red +")
            #expect(search.isAnswering && search.groups.map(\.homeID) == [member.id],
                    "a symbol beside a word finds the word's note")
            await search.setText("#dream")
            #expect(!search.isAnswering)
            for text in ["— #dream", "+ #dream", "#dream —"] {
                await search.setText(text)
                #expect(!search.isAnswering, "\(text) is the tag alone — the book's content stays")
            }
            await search.setText("—")
            #expect(search.isAnswering && search.groups.isEmpty, "a field of only punctuation: today's reading")
        }
    }

    // MARK: - ⌘K

    /// ⌘K's list: a folded word beside a tag lists no passage and no "all
    /// matches" row, as the tag alone; a symbol beside real words lists the
    /// word's passage; a field of only punctuation keeps its row (today's).
    @Test func thePalettesListReadsTheOnePredicate() async throws {
        try await withSession { session in
            let ops = session.operations
            let note = try ops.createPost(title: "Garden diary")
            _ = try ops.newBlock(in: note.id, text: "a red rose by the gate")
            let model = PaletteModel(session: session)

            model.query = "red +"
            await model.refresh()
            #expect(model.items.contains { $0.kind == .passage && $0.homeContainerID == note.id })
            #expect(model.items.contains { $0.kind == .allMatches })

            for text in ["#flora", "— #flora", "+ #flora"] {
                model.query = text
                await model.refresh()
                #expect(!model.items.contains { $0.kind == .passage || $0.kind == .allMatches },
                        "\(text): no passage, no all-matches row")
            }

            model.query = "—"
            await model.refresh()
            #expect(model.items.contains { $0.kind == .allMatches }, "today's all-matches row stays")
            #expect(!model.items.contains { $0.kind == .passage })
        }
    }
}
