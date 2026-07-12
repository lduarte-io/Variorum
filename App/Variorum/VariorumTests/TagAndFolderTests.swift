//
//  TagAndFolderTests.swift
//  VariorumTests
//
//  Phase 10 Step 5 — the tag management/application faces and the folder
//  view: UI-path operations emit exactly the Phase 2 ops (row-level
//  state-transition assertions), refusal copy surfaces (duplicate path,
//  invalid name), and the folder model renders the query verbatim. Plus
//  the journal section's notebook-rule door (create-or-open).
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

@Suite("Tags & folder (Phase 10 Step 5)")
struct TagAndFolderTests {
    @Test func tagCRUDThroughTheUIPathEmitsExactlyThePhase2Ops() async throws {
        try await withWorld { session, db in
            let model = TagsViewModel(session: session)
            await model.createTag(parentID: nil, name: "life")
            let life = try #require(try await db.read { try Queries.allTags($0).first })
            #expect(life.path == "life")
            #expect(model.lastError == nil)

            await model.createTag(parentID: life.id, name: "goals")
            var tags = try await db.read { try Queries.allTags($0) }
            #expect(tags.map(\.path) == ["life", "life/goals"])

            // Rename rewrites the SUBTREE path (renameTag's first face).
            await model.renameTag(life.id, to: "living")
            tags = try await db.read { try Queries.allTags($0) }
            #expect(tags.map(\.path) == ["living", "living/goals"])

            // Delete tombstones the tag AND its subtree.
            await model.deleteTag(life.id)
            tags = try await db.read { try Queries.allTags($0) }
            #expect(tags.isEmpty)
            let tombstones = try await db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM tag WHERE deleted_at IS NOT NULL") ?? 0
            }
            #expect(tombstones == 2)
        }
    }

    @Test func refusalCopySurfacesForDuplicatePathAndInvalidName() async throws {
        try await withWorld { session, _ in
            let model = TagsViewModel(session: session)
            await model.createTag(parentID: nil, name: "life")
            await model.createTag(parentID: nil, name: "life")
            #expect(model.lastError?.contains("already exists") == true)

            await model.createTag(parentID: nil, name: "a/b")
            #expect(model.lastError?.contains("can't be empty or contain") == true)

            await model.createTag(parentID: nil, name: "")
            #expect(model.lastError?.contains("can't be empty or contain") == true)

            // A successful op clears the message.
            await model.createTag(parentID: nil, name: "fine")
            #expect(model.lastError == nil)
        }
    }

    @Test func assignmentTogglesEmitExactlyApplyAndRemove() async throws {
        try await withWorld { session, db in
            let post = try session.operations.createPost(title: "p")
            let tag = try session.operations.createTag(name: "life")
            let model = TagAssignmentViewModel(session: session, postID: post.id)
            await model.load()
            #expect(model.allTags.map(\.id) == [tag.id])
            #expect(!model.isApplied(tag.id))

            await model.toggle(tag.id)
            #expect(model.isApplied(tag.id))
            var rows = try await db.read {
                try Row.fetchAll($0, sql: "SELECT * FROM post_tag")
            }
            #expect(rows.count == 1)
            #expect(rows[0]["deleted_at"] == nil)

            await model.toggle(tag.id)
            #expect(!model.isApplied(tag.id))
            rows = try await db.read {
                try Row.fetchAll($0, sql: "SELECT * FROM post_tag")
            }
            // The removal is a tombstone, never a row removal (S2).
            #expect(rows.count == 1)
            #expect(rows[0]["deleted_at"] != nil)
        }
    }

    @Test func folderModelRendersTheQueryVerbatim() async throws {
        try await withWorld { session, db in
            let tag = try session.operations.createTag(name: "life")
            let a = try session.operations.createPost(title: "a")
            let b = try session.operations.createPost(title: "b")
            try session.operations.applyTag(tag.id, toPost: a.id)
            try session.operations.applyTag(tag.id, toPost: b.id)
            let expected = try await db.read { [tagID = tag.id] in
                try Queries.taggedPostItems($0, tagID: tagID)
            }
            let model = FolderViewModel(session: session, tagID: tag.id)
            model.adopt(expected)
            #expect(model.posts == expected)
            #expect(model.posts.count == 2)
        }
    }

    @Test func treeDepthFollowsThePath() async throws {
        try await withWorld { session, _ in
            let model = TagsViewModel(session: session)
            let root = try session.operations.createTag(name: "life")
            let child = try session.operations.createTag(parent: root.id, name: "goals")
            let grand = try session.operations.createTag(parent: child.id, name: "2026")
            model.adopt(try await session.database.read { try Queries.allTags($0) })
            let depths = model.tags.map { model.depth(of: $0) }
            #expect(depths == [0, 1, 2])
            _ = grand
        }
    }

    @Test func theJournalDoorCreatesThenOpensTheSameDay() async throws {
        try await withWorld { session, db in
            let model = LibraryViewModel(session: session)
            let first = await model.openJournalEntry(day: "2026-07-12")
            let second = await model.openJournalEntry(day: "2026-07-12")
            #expect(first != nil)
            #expect(first == second, "the notebook rule: one entry per day, opened not re-minted")
            let count = try await db.read {
                try Int.fetchOne(
                    $0,
                    sql: "SELECT COUNT(*) FROM container WHERE profile = 'journal' AND deleted_at IS NULL"
                ) ?? 0
            }
            #expect(count == 1)
            // A malformed day refuses at the ops boundary and speaks.
            let bad = await model.openJournalEntry(day: "2026-7-12")
            #expect(bad == nil)
            #expect(model.lastError != nil)
        }
    }
}
