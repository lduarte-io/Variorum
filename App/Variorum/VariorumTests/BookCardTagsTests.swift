//
//  BookCardTagsTests.swift
//  VariorumTests
//
//  **VX-1038 (the VX-1036 run, batch 2) — a note's tags in a book's card
//  headers.** The switch's per-book memory, the model's pills per position,
//  and its read's REGION (post_tag + tag only — a keystroke's autosave never
//  wakes it). T-1's layout is `BookCardHeaderPlanTests`. A FEATURE, so its
//  pins are state, not red-on-old.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private typealias Tag = VariorumCore.Tag

@MainActor
@Suite("VX-1038 — tags in a book's card headers", .serialized)
struct BookCardTagsTests {
    // MARK: - The switch's memory (per book, this Mac)

    private func scratchDefaults() -> UserDefaults {
        let name = "BookCardTagsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func theSwitchIsRememberedPerBookAndHiddenIsTheDefault() {
        let defaults = scratchDefaults()
        let a = BookCardTagsModel(readingID: "book-a", defaults: defaults)
        #expect(a.position == .hidden, "T-5: hidden by default")
        a.setPosition(.otherTags)
        #expect(BookCardTagsModel(readingID: "book-a", defaults: defaults).position == .otherTags,
                "remembered for this book")
        #expect(BookCardTagsModel(readingID: "book-b", defaults: defaults).position == .hidden,
                "another book keeps its own")
        a.setPosition(.allTags)
        #expect(BookCardTagsModel(readingID: "book-a", defaults: defaults).position == .allTags)
        a.setPosition(.hidden)
        #expect(defaults.string(forKey: BookTagsShownPrefs.key("book-a")) == nil, "hidden is no key at all")
    }

    @Test func hidingTagsPutsAnOpenFieldAway() {
        let tags = BookCardTagsModel(readingID: "b", defaults: scratchDefaults())
        tags.setPosition(.allTags)
        tags.fieldPostID = "n"
        tags.setPosition(.hidden)
        #expect(tags.fieldPostID == nil, "no + to hang it from")
    }

    // MARK: - The pills per position

    private static let day = Date(timeIntervalSince1970: 0)
    private func tag(_ id: String, _ path: String) -> Tag {
        Tag(id: id, name: path, path: path, createdAt: Self.day, updatedAt: Self.day)
    }

    @Test func eachPositionDrawsTheNotesPillsAndOtherTagsLeavesThePlacingOnesOff() {
        let tags = BookCardTagsModel(readingID: "g", defaults: scratchDefaults())
        let week = tag("week", "week"), todo = tag("todo", "todo"), plumber = tag("plumber", "plumber")
        tags.adopt(.init(worn: ["n": [plumber, todo, week]], vocabulary: [], ruleTags: ["week": week]))
        tags.rule = .tag("week")   // the gathering collects #week
        #expect(tags.pills(for: "n") == nil, "hidden: nothing")
        tags.setPosition(.allTags)
        #expect(tags.pills(for: "n")?.map(\.id) == ["plumber", "todo", "week"])
        tags.setPosition(.otherTags)
        #expect(tags.pills(for: "n")?.map(\.id) == ["plumber", "todo"], "#week places the note here")
        tags.rule = nil            // a plain book
        #expect(tags.pills(for: "n")?.map(\.id) == ["plumber", "todo", "week"],
                "in a plain book the middle position shows everything")
        #expect(tags.pills(for: "tagless") == [], "a tagless note: the + alone")
    }

    @Test func aFieldLosingFocusOnATaggedNotePutsItAwayButATaglessNoteKeepsIt() {
        let tags = BookCardTagsModel(readingID: "b", defaults: scratchDefaults())
        tags.adopt(.init(worn: ["tagged": [tag("t", "t")]], vocabulary: [], ruleTags: [:]))
        tags.fieldPostID = "tagged"
        tags.fieldLostFocus(on: "tagged")
        #expect(tags.fieldPostID == nil)
        tags.fieldPostID = "bare"
        tags.fieldLostFocus(on: "bare")
        #expect(tags.fieldPostID == "bare", "nothing yet for the template to sit beside")
    }

    // MARK: - The read

    private func world<T>(_ body: @MainActor (AppSession) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            // A living book's backfill and the seat place through the
            // fractional index's `\.withRandomNumberGenerator`: provided the
            // house way (a seeded generator), so the host's test context never
            // meets an unimplemented dependency.
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1038))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    @Test func theReadIsTheWindowsNotesTagsTheWingsVocabularyAndTheRulesTags() async throws {
        try await world { session in
            let ops = session.operations
            let a = try ops.createPost(title: "A"), b = try ops.createPost(title: "B")
            let week = try ops.createTag(name: "week")
            let todo = try ops.createTag(name: "todo")
            _ = try ops.applyTag(week.id, toPost: a.id)
            _ = try ops.applyTag(todo.id, toPost: a.id)
            let snapshot = try await session.database.read { db in
                try BookCardTagsModel.fetch(db, postIDs: [a.id, b.id], wingID: "", ruleTagIDs: [week.id])
            }
            #expect(snapshot.worn[a.id]?.map(\.path) == ["todo", "week"])
            #expect(snapshot.worn[b.id] == nil)
            #expect(Set(snapshot.vocabulary.map(\.id)) == [week.id, todo.id])
            #expect(snapshot.ruleTags.keys.sorted() == [week.id])
        }
    }

    /// P1: the held read's REGION never includes `container` or `variant`
    /// — a keystroke's autosave never wakes it — while a tagging act does
    /// (`TagFamilySectionsTests`' pattern).
    @Test func theReadsRegionIsTagsOnlySoAKeystrokeNeverWakesIt() async throws {
        // The store's own DDL for the tables the fetch reads (the migrator is
        // the core's; the app pin copies its result — the masthead pin's way).
        let store = try AppDatabase.inMemory()
        let ddl = try await store.read { db in
            try String.fetchAll(db, sql: """
                SELECT sql FROM sqlite_master
                WHERE type = 'table' AND name IN ('tag', 'post_tag', 'wing') ORDER BY name DESC
                """)
        }
        #expect(ddl.count == 3)
        let queue = try DatabaseQueue()
        try await queue.write { db in
            for statement in ddl { try db.execute(sql: statement) }
        }
        let region = LockIsolated<DatabaseRegion?>(nil)
        let observation = ValueObservation
            .tracking { try BookCardTagsModel.fetch($0, postIDs: ["p"], wingID: "", ruleTagIDs: ["r"]) }
            .handleEvents(willTrackRegion: { tracked in region.setValue(tracked) })
        var values = observation.values(in: queue).makeAsyncIterator()
        _ = try await values.next()
        let tracked = try #require(region.value)
        #expect(!tracked.isModified(byEventsOfKind: .update(
            tableName: "container", columnNames: ["last_touched_at", "updated_at", "churn_accumulator", "title"])))
        #expect(!tracked.isModified(byEventsOfKind: .update(
            tableName: "variant", columnNames: ["working_text", "updated_at"])))
        #expect(tracked.isModified(byEventsOfKind: .insert(tableName: "post_tag")))
        #expect(tracked.isModified(byEventsOfKind: .insert(tableName: "tag")))
    }

    // MARK: - The "+" field's road (T-3)

    /// T-3: ⏎ adopts-or-mints the typed path in the note's wing and applies
    /// it through the ONE application road, so a living book that collects
    /// the tag hears it (it seats the note — the dial's default join).
    @Test func theFieldsTagIsHeardByALivingBookAndANewPathIsMinted() async throws {
        try await world { session in
            let ops = session.operations
            let week = try ops.createTag(name: "week")
            let spec = try #require(try RuleGrammar.encode(.tag(week.id)))
            let living = try ops.createReading(name: "this week", kind: .book, querySpec: spec)
            let note = try ops.createPost(title: "the plumber")
            let tags = BookCardTagsModel(readingID: "elsewhere", defaults: UserDefaults(suiteName: "BookCardTagsTests.road")!)
            tags.fieldPostID = note.id

            tags.apply("week", to: note.id, session: session)
            #expect(tags.fieldPostID == nil, "the field closes after an apply (the masthead's rule)")
            try await settleUntil {
                try await session.database.read { db in
                    try Queries.assembleReading(db, readingID: living.id).map(\.postID)
                } == [note.id]
            }

            tags.apply("garden/rhubarb", to: note.id, session: session)
            try await settleUntil {
                try await session.database.read { db in
                    try Queries.postTags(db, postID: note.id).map(\.path)
                } == ["garden/rhubarb", "week"]
            }
            #expect(try await session.database.read { db in
                try Queries.allTags(db, wingID: "").map(\.path)
            }.contains("garden"), "the missing parent was made on the way (the typed-path road)")
        }
    }

    private func settleUntil(_ condition: () async throws -> Bool) async throws {
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            if try await condition() { return }
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(try await condition(), "settled within 3 s")
    }
}
