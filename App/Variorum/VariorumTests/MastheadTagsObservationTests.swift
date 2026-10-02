//
//  MastheadTagsObservationTests.swift
//  VariorumTests
//
//  13i-d U3 — KnownIssues row 112 (13i-d U2's F-U2-2, walk capture
//  `u2/14`): the note masthead's TAG CARDS loaded ONCE per note, so a tag
//  taken off by ANOTHER door on the same screen — 13i-c's membership-chip
//  "remove #tag", U2's Book Panel gathering line — kept its card until the
//  note was reopened. The cards' read is one HELD observation now
//  (`MastheadTagsModel`, the row-104 shape), over `post_tag` + `tag` only.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Row 112 — the masthead's tag cards are observed (13i-d U3)", .serialized)
struct MastheadTagsObservationTests {
    private func world<T>(
        _ body: @MainActor (AppSession) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    /// **RED ON OLD** (the one-shot read): the note is open with two cards;
    /// ANOTHER door takes one tag off (the chip's / the Book Panel's "remove
    /// #tag" both land as this op), and the cards in hand follow — no reopen.
    @Test func aTagRemovedByAnotherDoorWhileTheNoteIsOpenLeavesTheCards() async throws {
        try await world { session in
            let ops = session.operations
            let note = try ops.createPost(title: "the open note")
            let keep = try ops.createTag(name: "keep")
            let gone = try ops.createTag(name: "gone")
            _ = try ops.applyTag(keep.id, toPost: note.id)
            _ = try ops.applyTag(gone.id, toPost: note.id)

            let model = MastheadTagsModel()
            let task = Task { await model.track(session: session, postID: note.id) }
            defer { task.cancel() }
            try await settle { model.tags(for: note.id).count == 2 }

            try ops.removeTag(gone.id, fromPost: note.id)
            try await settle { model.tags(for: note.id).map(\.id) == [keep.id] }
            #expect(model.tags(for: note.id).map(\.id) == [keep.id],
                    "the removed tag's card leaves while the note is open")
        }
    }

    /// The other half of the same class: a tag put ON by another door (an
    /// intake-adjacent act, a second window) shows without a reopen — and the
    /// inline field's suggestions learn a tag minted meanwhile.
    @Test func aTagAddedByAnotherDoorShowsAndTheTaxonomyFollows() async throws {
        try await world { session in
            let ops = session.operations
            let note = try ops.createPost(title: "the open note")
            let model = MastheadTagsModel()
            let task = Task { await model.track(session: session, postID: note.id) }
            defer { task.cancel() }
            try await settle { model.subject == note.id }
            #expect(model.tags(for: note.id).isEmpty)

            let fresh = try ops.createTag(name: "fresh")
            _ = try ops.applyTag(fresh.id, toPost: note.id)
            try await settle { model.tags(for: note.id).map(\.id) == [fresh.id] }
            #expect(model.tags(for: note.id).map(\.id) == [fresh.id])
            #expect(model.allTags.map(\.id).contains(fresh.id),
                    "the field's suggestions see the newly minted tag")
        }
    }

    /// The subject guard: a previous note's cards never answer for another.
    @Test func anotherNotesCardsNeverAnswerForThisOne() async throws {
        try await world { session in
            let ops = session.operations
            let tagged = try ops.createPost(title: "tagged")
            let other = try ops.createPost(title: "other")
            let tag = try ops.createTag(name: "t")
            _ = try ops.applyTag(tag.id, toPost: tagged.id)
            let model = MastheadTagsModel()
            let task = Task { await model.track(session: session, postID: tagged.id) }
            defer { task.cancel() }
            try await settle { !model.tags(for: tagged.id).isEmpty }
            #expect(model.tags(for: other.id).isEmpty)
        }
    }

    /// P1 (the cost named on KnownIssues row 13's class): the held read's
    /// REGION is `post_tag` + `tag` — a keystroke's autosave (`variant`,
    /// `container`) never wakes it; a tagging act does.
    @Test func theHeldReadIsBlindToAutosave() async throws {
        // The store's own DDL for the two tables the fetch reads (the
        // migrator is the core's; the app pin copies its result).
        let store = try AppDatabase.inMemory()
        let ddl = try await store.read { db in
            try String.fetchAll(db, sql: """
                SELECT sql FROM sqlite_master
                WHERE type = 'table' AND name IN ('tag', 'post_tag') ORDER BY name DESC
                """)
        }
        #expect(ddl.count == 2)
        let queue = try DatabaseQueue()
        try await queue.write { db in
            for statement in ddl { try db.execute(sql: statement) }
        }
        let region = LockIsolated<DatabaseRegion?>(nil)
        let observation = ValueObservation
            .tracking { try MastheadTagsModel.fetch($0, postID: "p") }
            .handleEvents(willTrackRegion: { tracked in region.setValue(tracked) })
        var values = observation.values(in: queue).makeAsyncIterator()
        _ = try await values.next()
        let tracked = try #require(region.value)
        #expect(!tracked.isModified(byEventsOfKind: .update(
            tableName: "variant", columnNames: ["working_text", "updated_at"])),
            "a keystroke's buffer write must not wake the cards")
        #expect(!tracked.isModified(byEventsOfKind: .update(
            tableName: "container",
            columnNames: ["last_touched_at", "updated_at", "churn_accumulator"])),
            "…nor its touch stamps")
        #expect(tracked.isModified(byEventsOfKind: .insert(tableName: "post_tag")),
                "…while a tagging act does")
        #expect(tracked.isModified(byEventsOfKind: .insert(tableName: "tag")),
                "…and so does a minted tag (the field's suggestions)")
    }
}

/// Poll until a condition holds (the row-104 pin's harness, restated).
@MainActor
private func settle(
    within seconds: Double = 3, _ condition: () async throws -> Bool
) async throws {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if try await condition() { return }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
    #expect(try await condition(), "condition never settled")
}
