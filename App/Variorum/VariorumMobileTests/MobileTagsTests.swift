//
//  MobileTagsTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C3 — the tags family: the manager
//  (browse · create incl. child tags · rename · delete-with-subtree,
//  her cross-fully ruling) . State-transition tests through the view
//  models against a real in-memory store; every act routes through the
//  existing core tag operations.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile tag manager (parity C3 — her cross-fully ruling)")
struct MobileTagManagerTests {
    /// Browse + create, root and child, through the manager model: rows
    /// arrive in path order (parents before children — the tree IS the
    /// hierarchy), the depth brain indents them, and the refusals speak
    /// phone words (duplicate path, invalid name — no platform named).
    @Test func createBrowseAndChildTagsThroughTheManager() async throws {
        try await withEditorWorld { session, db in
            let model = MobileTagsModel(session: session)

            await model.create(parentID: nil, name: "life")
            #expect(model.tags.map(\.path) == ["life"])
            let life = try #require(model.tags.first)

            await model.create(parentID: life.id, name: "goals")
            #expect(model.tags.map(\.path) == ["life", "life/goals"],
                    "path order — the parent sorts before its child")
            #expect(MobileTagsModel.depth(of: model.tags[0]) == 0)
            #expect(MobileTagsModel.depth(of: model.tags[1]) == 1)
            #expect(model.lastError == nil)

            // The duplicate-path refusal, phone words.
            await model.create(parentID: nil, name: "life")
            #expect(model.lastError == "A tag named “life” already exists.")
            #expect(model.lastError?.contains("Mac") == false)

            // The invalid-name refusal (the op's own guard, spoken).
            await model.create(parentID: nil, name: "a/b")
            #expect(model.lastError == "Tag names can't be empty or contain “/”.")
            #expect(model.tags.count == 2, "refused creates mint nothing")
        }
    }

    /// Rename ripples the whole subtree's materialized paths (the op's
    /// one-transaction contract, exercised through the phone door).
    @Test func renameRipplesTheSubtree() async throws {
        try await withEditorWorld { session, db in
            let lifeID = try await session.runner.run { ops -> String in
                let life = try ops.createTag(name: "life")
                let goals = try ops.createTag(parent: life.id, name: "goals")
                _ = try ops.createTag(parent: goals.id, name: "2026")
                return life.id
            }
            let model = MobileTagsModel(session: session)
            await model.refresh()
            #expect(model.tags.map(\.path) == ["life", "life/goals", "life/goals/2026"])

            await model.rename(lifeID, to: "world")
            #expect(model.tags.map(\.path) == ["world", "world/goals", "world/goals/2026"],
                    "the subtree's paths ripple with the rename")
            #expect(model.lastError == nil)
        }
    }

    /// Delete-with-subtree: the confirm's message NAMES the consequence
    /// (count of sub-tags, that notes lose the tags — never a platform),
    /// and the act tombstones the subtree AND its applications exactly.
    @Test func deleteWithSubtreeNamesTheConsequenceAndLandsExactly() async throws {
        try await withEditorWorld { session, db in
            let (lifeID, seaID, postID) = try await session.runner.run {
                ops -> (String, String, String) in
                let life = try ops.createTag(name: "life")
                let goals = try ops.createTag(parent: life.id, name: "goals")
                _ = try ops.createTag(parent: goals.id, name: "2026")
                let sea = try ops.createTag(name: "sea")
                let post = try ops.createPost(title: "Harbor")
                _ = try ops.applyTag(goals.id, toPost: post.id)
                _ = try ops.applyTag(sea.id, toPost: post.id)
                return (life.id, sea.id, post.id)
            }
            let model = MobileTagsModel(session: session)
            await model.refresh()

            // The consequence brain, both arms (pinned): the leaf arm and
            // the subtree arm carry the count; neither names a platform.
            let life = try #require(model.tags.first { $0.id == lifeID })
            let sea = try #require(model.tags.first { $0.id == seaID })
            #expect(MobileTagsModel.subtreeCount(of: life, in: model.tags) == 2)
            #expect(MobileTagsModel.subtreeCount(of: sea, in: model.tags) == 0)
            let subtreeArm = MobileTagsModel.deleteConsequence(name: "life", subtreeCount: 2)
            #expect(subtreeArm.contains("2 sub-tags"), "the count is named")
            #expect(subtreeArm.contains("loses those tags"), "the application consequence is named")
            let leafArm = MobileTagsModel.deleteConsequence(name: "sea", subtreeCount: 0)
            #expect(leafArm.contains("takes it off every note"))
            for arm in [subtreeArm, leafArm] {
                #expect(!arm.contains("Mac"), "the consequence, never a platform")
            }

            await model.delete(lifeID)
            #expect(model.tags.map(\.path) == ["sea"],
                    "the subtree is gone from the live taxonomy; the sibling survives")
            let liveApplications = try await db.read { db in
                try Queries.postTags(db, postID: postID).map(\.path)
            }
            #expect(liveApplications == ["sea"],
                    "the deleted tag's application tombstoned with it; the sibling's stays")
            let deadTagCount = try await db.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM tag WHERE deleted_at IS NOT NULL") ?? 0
            }
            #expect(deadTagCount == 3, "life + goals + 2026 are tombstones, not gone rows (S2)")
            #expect(model.lastError == nil)
        }
    }
}
