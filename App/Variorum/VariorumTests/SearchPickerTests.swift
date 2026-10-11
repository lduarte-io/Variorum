//
//  SearchPickerTests.swift
//  VariorumTests
//
//  17y B3 item (g) — THE RULE EDITOR'S TAG PICKERS GROW UP (her walk, the
//  field-guide rule sheet: "this is the exact sort of selector that looks
//  really bad when you have a lot of different options — we should build for
//  the need to search through tags now"; and the "+ tag ▾" menus must let her
//  CREATE A NEW TAG in place). R-17y-3 rules the scope: ONE control on the
//  ruled three surfaces (the rule builder's tag terms, the outflow chooser,
//  item (o)'s add-to-book picker), every other picker at its next touch.
//
//  What these hold: the control's BRAIN (filter · the create offer · what
//  Return does), and the rule editor's make-in-place road (the typed-path
//  grammar, in the BOOK's wing, the term added to the draft only Save
//  writes). A ruled BUILD (no red-on-old owed); the walk captures the face.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withPickerWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@Suite("17y (g) — the one picker: its brain")
struct SearchPickerBrainTests {
    private let tags = [
        SearchPickerOption(id: "1", label: "#life", searchText: "life"),
        SearchPickerOption(id: "2", label: "#life/goals", searchText: "life/goals"),
        SearchPickerOption(id: "3", label: "#Work", searchText: "Work"),
    ]

    @Test func typingFiltersAndAnEmptyQueryShowsEverything() {
        #expect(SearchPickerBrain.filter(tags, query: "").map(\.id) == ["1", "2", "3"])
        #expect(SearchPickerBrain.filter(tags, query: "GOAL").map(\.id) == ["2"],
                "contains, case-insensitively")
        #expect(SearchPickerBrain.filter(tags, query: "#li").map(\.id) == ["1", "2"],
                "a leading # is read the way the tag reads")
        #expect(SearchPickerBrain.filter(tags, query: "zzz").isEmpty)
    }

    @Test func theCreateRowIsOfferedOnlyForWhatDoesNotExist() {
        let key = SearchPickerCopy.tagKey(_:)
        #expect(SearchPickerBrain.createOffer(query: "", options: tags, key: key) == nil)
        #expect(SearchPickerBrain.createOffer(query: "  ", options: tags, key: key) == nil)
        #expect(SearchPickerBrain.createOffer(query: "LIFE/goals", options: tags, key: key) == nil,
                "an existing path — case aside — is picked, never re-made")
        #expect(SearchPickerBrain.createOffer(query: "/life//goals/", options: tags, key: key) == nil,
                "slash noise collapses (the typed-path grammar)")
        #expect(SearchPickerBrain.createOffer(query: "#life/plans", options: tags, key: key)
                == "life/plans")
        #expect(SearchPickerCopy.newTag("life//plans") == "New tag \u{201C}#life/plans\u{201D}")
    }

    @Test func returnTakesTheFirstMatchElseTheCreateRow() {
        let key = SearchPickerCopy.tagKey(_:)
        #expect(SearchPickerBrain.returnChoice(
            query: "goal", options: tags, canCreate: true, key: key) == .pick("2"))
        #expect(SearchPickerBrain.returnChoice(
            query: "plans", options: tags, canCreate: true, key: key) == .create("plans"))
        #expect(SearchPickerBrain.returnChoice(
            query: "plans", options: tags, canCreate: false, key: key) == .nothing)
    }

    /// 13n-c Stage B R1 B8: an empty SOURCED panel (the grant sheet's note
    /// feed) says nothing while its first answer is on its way, then its host's
    /// empty sentence before typing and "Nothing matches." after — never
    /// "Nothing matches." before she typed. A flat panel is unchanged.
    @Test func anEmptyPanelSaysItsOwnSentenceBeforeTypingAndNoMatchAfter() {
        #expect(SearchPickerBrain.emptyState(query: "", sourced: true, loaded: false) == nil,
                "the first load is not a no-match")
        #expect(SearchPickerBrain.emptyState(query: "", sourced: true, loaded: true) == .empty,
                "an empty feed before typing says the host's sentence")
        #expect(SearchPickerBrain.emptyState(query: "zzz", sourced: true, loaded: true) == .noMatch)
        #expect(SearchPickerBrain.emptyState(query: "", sourced: false, loaded: false) == .empty,
                "a flat panel, as before")
        #expect(SearchPickerBrain.emptyState(query: "zzz", sourced: false, loaded: false) == .noMatch)
    }
}

@MainActor
@Suite("17y (g) — making a tag in place from the rule editor", .serialized)
struct RuleEditorMakeTagTests {
    /// A typed path makes its missing chain IN THE BOOK'S WING (the typed-path
    /// grammar), refreshes the picker's options, and its term joins the DRAFT
    /// — only Save writes the rule.
    @Test func aTypedPathIsMadeInTheBooksWingAndJoinsTheDraft() async throws {
        try await withPickerWorld { session, db in
            let ops = session.operations
            let studio = try ops.createWing(name: "Studio")
            let life = try ops.createTag(name: "life", wingID: studio.id)
            let book = try ops.createReading(name: "plans", kind: .book, wingId: studio.id)
            let model = RuleEditorModel(session: session, readingID: book.id)
            await model.load()
            #expect(model.tagOptions.map(\.label) == ["#life"])

            let made = try #require(await model.createTag("life/plans/2027"))
            model.add(.tag(made), into: nil)
            let tag = try #require(try await db.read { try VariorumCore.Tag.fetchOne($0, key: made) })
            #expect(tag.path == "life/plans/2027")
            #expect(tag.wingId == studio.id, "born in the book's wing, never Home")
            #expect(model.tagOptions.contains { $0.id == made }, "the picker offers it at once")
            #expect(try await db.read { try Queries.reading($0, id: book.id) }?.querySpec == nil,
                    "the rule is the draft's until Save")

            #expect(await model.save())
            let spec = try await db.read { try Queries.reading($0, id: book.id) }?.querySpec
            #expect(RuleGrammar.tagIDs(of: RuleGrammar.decode(spec)) == [made])
            _ = life
        }
    }

    /// An existing whole path is picked, not re-made; nothing typed refuses
    /// in the typed-path grammar's own words.
    @Test func anExistingPathIsReusedAndNothingTypedRefuses() async throws {
        try await withPickerWorld { session, db in
            let ops = session.operations
            let life = try ops.createTag(name: "life")
            let book = try ops.createReading(name: "plans", kind: .book)
            let model = RuleEditorModel(session: session, readingID: book.id)
            await model.load()
            let before = try await db.read { try Queries.allTags($0) }.count
            #expect(await model.createTag("#life") == life.id)
            #expect(try await db.read { try Queries.allTags($0) }.count == before, "nothing minted")
            #expect(await model.createTag(" / ") == nil)
            #expect(session.status.current?.text == TypedTagPath.emptyMessage)
        }
    }

    /// The MINT sheet (Create Gathering) makes the tag in the wing the
    /// gathering will be minted in.
    @Test func theMintSheetMakesTheTagInItsWing() async throws {
        try await withPickerWorld { session, db in
            let studio = try session.operations.createWing(name: "Studio")
            let model = RuleEditorModel(session: session, mintingIn: studio.id)
            await model.load()
            let made = try #require(await model.createTag("found"))
            let tag = try #require(try await db.read { try VariorumCore.Tag.fetchOne($0, key: made) })
            #expect(tag.wingId == studio.id)
        }
    }
}
