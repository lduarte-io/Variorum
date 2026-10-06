//
//  LibraryViewScopeSwitchTests.swift
//  VariorumTests
//
//  **17y B-WALK W-2 — THE VIEW AND THE SCOPE SWITCH EACH OTHER (her rulings,
//  the walk of 2026-10-05).** Her finding: "Notes [the Cards view] takes away
//  your ability to see books - the other selector should automatically switch
//  from 'All' to 'Notes' in that case" — and, at the walk's full return: "yes
//  to building the cards notes auto switch and if someone clicks on all from
//  inside card view, move them off the card view". The Cards view renders
//  NOTES only, so a scope chip reading "All" over it says something the
//  screen does not show (she fell for it herself on the dev store: "I was on
//  cards the whole time… the confusing user experience of being on 'all' but
//  not seeing books").
//
//  THE TWO SWITCHES (ruled): picking Cards moves the scope All → Notes;
//  picking All while in Cards moves the view off Cards, to List. Every other
//  combination is untouched (the edges are PROVISIONAL — QUESTIONS #188).
//
//  Red-on-old, stated: the source scan was committed AHEAD of the fix and ran
//  red on that tree — both pickers wrote the model's value directly
//  (`model.mode = $0`, `model.scope = $0`), so nothing could switch the
//  other. The rule's own pins (the pure table, the model's two doors) land
//  with the fix.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y B-WALK W-2 — picking Cards moves All to Notes; picking All in Cards moves to List")
struct LibraryViewScopeSwitchTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static func source(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: relative), encoding: .utf8)
    }

    /// Both pickers route through the model's doors — never a bare write that
    /// could not move the other value.
    @Test func bothPickersRouteThroughTheSwitchingDoors() throws {
        let view = try Self.source("Variorum/Features/Library/LibraryCatalogView.swift")
        #expect(!view.contains("model.mode = $0"), "the view picker writes the mode bare")
        #expect(!view.contains("model.scope = $0"), "the scope picker writes the scope bare")
        #expect(view.contains("model.pickMode($0)"), "the view picker picks through the model's door")
        #expect(view.contains("model.pickScope($0)"), "the scope picker picks through the model's door")
    }

    // MARK: - The rule (landed with the fix)

    typealias Model = LibraryCatalogModel

    /// Switch one: picking Cards moves All → Notes — and only All.
    @Test func pickingCardsMovesAllToNotes() {
        #expect(Model.scope(afterPicking: .notes, from: .all) == .posts)
        // Untouched (PROVISIONAL — #188): Cards over Notes, Books, Blocks.
        #expect(Model.scope(afterPicking: .notes, from: .posts) == .posts)
        #expect(Model.scope(afterPicking: .notes, from: .books) == .books)
        #expect(Model.scope(afterPicking: .notes, from: .blocks) == .blocks)
        // Leaving Cards never moves the scope back.
        for scope in Model.Scope.allCases {
            #expect(Model.scope(afterPicking: .list, from: scope) == scope)
            #expect(Model.scope(afterPicking: .timeline, from: scope) == scope)
        }
    }

    /// Switch two: picking All while in Cards moves the view to List — and
    /// only from Cards, and only for All.
    @Test func pickingAllInCardsMovesToList() {
        #expect(Model.mode(afterPicking: .all, from: .notes) == .list)
        #expect(Model.mode(afterPicking: .all, from: .list) == .list)
        #expect(Model.mode(afterPicking: .all, from: .timeline) == .timeline)
        for scope in [Model.Scope.books, .posts, .blocks] {
            for mode in Model.Mode.allCases {
                #expect(Model.mode(afterPicking: scope, from: mode) == mode)
            }
        }
    }

    // MARK: - The model's doors, over a real listing

    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(37) }
                return value
            }
        }
    }

    private func withLibrary<T>(
        _ body: @MainActor (AppSession) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "17y-bwalk-w2-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// Picking Cards under All: the scope reads Notes, the door says a re-read
    /// is owed, and the re-read lists no book (nothing on screen claims one).
    /// Back to All from Cards: the view is List again and the books return.
    @Test func theDoorsSwitchAndTheListingFollows() async throws {
        try await withLibrary { session in
            _ = try session.operations.createReading(name: "a book", kind: .book)
            let note = try session.operations.createPost(title: "a note")
            _ = try session.operations.newBlock(in: note.id, text: "words")
            let model = Model(session: session, defaults: try scrubbed("doors"))
            await model.search()
            #expect(model.bookHits.count == 1 && model.noteHits.count == 1)

            #expect(model.pickMode(.notes), "a moved scope owes a re-read")
            #expect(model.mode == .notes)
            #expect(model.scope == .posts, "Cards moved All to Notes")
            await model.search()
            #expect(model.bookHits.isEmpty, "Cards lists no book")
            #expect(model.noteHits.map(\.id) == [note.id])

            model.pickScope(.all)
            #expect(model.scope == .all)
            #expect(model.mode == .list, "All moved the view off Cards")
            await model.search()
            #expect(model.bookHits.count == 1, "the books are back under All")
        }
    }

    /// The untouched combinations, through the doors: Cards over Books keeps
    /// Books (no re-read owed); Books in Cards keeps Cards; List under All
    /// stays List; the Timeline never moves the scope.
    @Test func theOtherCombinationsAreUntouched() async throws {
        try await withLibrary { session in
            let model = Model(session: session, defaults: try scrubbed("others"))
            model.pickScope(.books)
            #expect(!model.pickMode(.notes), "Cards over Books moves nothing")
            #expect(model.scope == .books && model.mode == .notes)
            model.pickScope(.blocks)
            #expect(model.mode == .notes, "Blocks in Cards keeps Cards")
            #expect(!model.pickMode(.list))
            model.pickScope(.all)
            #expect(model.mode == .list, "All in List stays List")
            #expect(!model.pickMode(.timeline), "the Timeline never moves the scope")
            #expect(model.scope == .all)
            model.pickScope(.all)
            #expect(model.mode == .timeline, "All in the Timeline stays the Timeline")
        }
    }
}
