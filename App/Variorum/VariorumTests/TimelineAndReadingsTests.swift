//
//  TimelineAndReadingsTests.swift
//  VariorumTests
//
//  Phase 10 Step 6 — the timeline's keyset pagination (bounded pages,
//  keyset-stable under inserts, strict-stamp semantics displayed) and the
//  reading CRUD faces (state transitions through the UI path; a UI-built
//  smart spec round-trips through SmartQuerySpec unchanged; curated
//  membership add/remove/reorder).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@Suite("Timeline & readings (Phase 10 Step 6)")
struct TimelineAndReadingsTests {
    @Test func timelinePagesAreBoundedAndKeysetStableUnderInserts() async throws {
        try await withWorld { session, _ in
            // 120 dated entries, days descending as p grows.
            for p in 0..<120 {
                _ = try session.operations.createPost(
                    title: "p\(p)",
                    entryDate: String(
                        format: "2026-%02d-%02d", (p / 28) % 12 + 1, p % 28 + 1))
            }
            let model = TimelineViewModel(session: session)
            await model.setLens(.entryDate)
            #expect(model.items.count == 50)
            #expect(!model.exhausted)
            let firstPage = model.items.map(\.postID)

            // An insert that lands INSIDE page 1's range must not disturb
            // the cursor: the next page continues after the last item —
            // no duplicates, no skipped pre-existing rows (P1: a page
            // costs the page; keyset, never OFFSET).
            _ = try session.operations.createPost(
                title: "latecomer", entryDate: "2026-04-15")
            await model.loadMore()
            #expect(model.items.count == 100)
            let ids = model.items.map(\.postID)
            #expect(Set(ids).count == ids.count, "keyset pages never duplicate")
            #expect(Array(ids.prefix(50)) == firstPage, "loaded rows never reshuffle")

            await model.loadMore()
            #expect(model.exhausted || model.items.count >= 120)
        }
    }

    @Test func strictStampLensesExcludeUnstampedPostsAndTheLibraryLensShowsAll() async throws {
        try await withWorld { session, _ in
            _ = try session.operations.createPost(title: "dated", entryDate: "2026-07-01")
            _ = try session.operations.createPost(title: "undated")
            let model = TimelineViewModel(session: session)
            await model.setLens(.entryDate)
            // Strict-stamp (ratified): an undated post is NOT on the
            // entry-date timeline.
            #expect(model.items.map(\.title) == ["dated"])
            await model.setLens(.library)
            // The total surface shows everything (COALESCE to created_at).
            #expect(Set(model.items.compactMap(\.title)) == ["dated", "undated"])
        }
    }

    @Test func readingCRUDThroughTheUIPathEmitsExactStateTransitions() async throws {
        try await withWorld { session, db in
            let model = ReadingsViewModel(session: session)
            let id = try #require(await model.create(name: "book", kind: .book))
            var readings = try await db.read { try Queries.readings($0) }
            #expect(readings.map(\.name) == ["book"])

            await model.rename(id, to: "the book")
            await model.setSort(id, field: .entryDate, direction: .desc)
            readings = try await db.read { try Queries.readings($0) }
            #expect(readings[0].name == "the book")
            #expect(readings[0].sortField == .entryDate)
            #expect(readings[0].sortDir == .desc)

            await model.delete(id)
            readings = try await db.read { try Queries.readings($0) }
            #expect(readings.isEmpty)
        }
    }

    /// **Rewritten at 13i-b U3** — the face this pinned (`SmartSpecSheet`) and
    /// its v1 draft reader (`Queries.legacyDraft`) RETIRED. The old pin proved
    /// the v1 vocabulary round-tripped THROUGH a lossy draft; the rule editor's
    /// state IS the v2 grammar, so the pin now proves the stronger thing — the
    /// stored rule is exactly the tree she built, a reopened editor shows it
    /// unchanged (and has nothing to save), the assembly applies it, and
    /// clearing it restores match-all.
    @Test func aUIBuiltRuleRoundTripsUnchanged() async throws {
        try await withWorld { session, db in
            let model = ReadingsViewModel(session: session)
            let id = try #require(await model.create(name: "smart", kind: .gathering))
            let tag = try session.operations.createTag(name: "life")
            let goals = try session.operations.createTag(parent: tag.id, name: "goals")

            // life ∧ (life/goals ∨ ★), built through the editor's own edits.
            let editor = RuleEditorModel(session: session, readingID: id)
            await editor.load()
            editor.add(.tag(tag.id), into: nil)
            editor.addGroup(.any, seededWith: .tag(goals.id), into: nil)
            editor.add(.star, into: [1])
            let built = try #require(editor.draft)
            #expect(built == .and([.tag(tag.id), .or([.tag(goals.id), .star])]))
            #expect(await editor.save())

            let stored = try await db.read { try Queries.readings($0) }[0].querySpec
            #expect(RuleGrammar.decode(stored) == built, "stored exactly as built")
            let reopened = RuleEditorModel(session: session, readingID: id)
            await reopened.load()
            #expect(reopened.draft == built)
            #expect(reopened.isDirty == false, "an unedited reopen has nothing to save")

            // And the assembly APPLIES it (subtree matching: `life` hears
            // `life/goals`; the star context is U4's wiring, so here only the
            // tag arm of the any-of can match).
            let match = try session.operations.createPost(title: "m")
            let lifeOnly = try session.operations.createPost(title: "life only")
            try session.operations.applyTag(goals.id, toPost: match.id)
            try session.operations.applyTag(tag.id, toPost: lifeOnly.id)
            let entries = try await db.read { [id] in
                try Queries.assembleReading($0, readingID: id)
            }
            #expect(entries.map(\.postID) == [match.id])

            // Clearing (the root's remove) restores match-all.
            let root = try #require(reopened.rows.first)
            reopened.remove(root)
            #expect(reopened.draft == nil)
            #expect(await reopened.save())
            let all = try await db.read { [id] in
                try Queries.assembleReading($0, readingID: id)
            }
            #expect(all.count == 2)
        }
    }

    @Test func curatedMembershipAddRemoveReorderThroughTheUIPath() async throws {
        try await withWorld { session, db in
            let model = ReadingsViewModel(session: session)
            let id = try #require(await model.create(name: "book", kind: .book))
            let a = try session.operations.createPost(title: "a")
            let b = try session.operations.createPost(title: "b")
            let c = try session.operations.createPost(title: "c")
            for post in [a, b, c] {
                await model.addPost(post.id, to: id)
            }
            func order() async throws -> [String] {
                try await db.read { [id] in
                    try Queries.assembleReading($0, readingID: id).map(\.postID)
                }
            }
            #expect(try await order() == [a.id, b.id, c.id])

            await model.movePost(c.id, in: id, up: true)
            #expect(try await order() == [a.id, c.id, b.id])
            await model.movePost(a.id, in: id, up: false)
            #expect(try await order() == [c.id, a.id, b.id])
            // Boundary moves are no-ops, never errors.
            await model.movePost(c.id, in: id, up: true)
            #expect(try await order() == [c.id, a.id, b.id])
            #expect(model.lastError == nil)

            await model.removePost(a.id, from: id)
            #expect(try await order() == [c.id, b.id])

            // Refusal copy: adding a duplicate speaks.
            await model.addPost(b.id, to: id)
            #expect(model.lastError?.contains("already in this book") == true)
        }
    }
}
