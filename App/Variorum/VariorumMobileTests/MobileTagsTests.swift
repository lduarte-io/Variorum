//
//  MobileTagsTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C3 — the tags family: the manager
//  (browse · create incl. child tags · rename · delete-with-subtree,
//  her cross-fully ruling) and tags on a note (apply/remove, the
//  leaf-chip grammar, the typed-path road). State-transition tests
//  through the view models against a real in-memory store; every act
//  routes through the existing core tag operations.
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

    /// FIX-C3a (the C3 ladder): the "+ new tag" door walks the SAME
    /// typed-path road the note-tags sheet does — "life/goals" on an
    /// empty taxonomy creates BOTH tags (the hierarchy on the way), a
    /// partly-existing path creates only the missing tail with slash
    /// noise forgiven, a fully-existing path refuses as the duplicate it
    /// is, and the empty type gets the two surfaces' ONE shared hint.
    /// The empty state's "“/” nests" promise (hoisted, pinned here)
    /// now names a road its own door walks. Revert-verified red-on-old:
    /// the pre-fix door routed the raw string to `createTag`, whose own
    /// guard refuses any "/" — restored, this test fails at its first
    /// assertion ("Tag names can't be empty or contain “/”.", nothing
    /// minted) while the suite's siblings stay green.
    @Test func theNewTagDoorWalksTypedPaths() async throws {
        try await withEditorWorld { session, db in
            let model = MobileTagsModel(session: session)

            await model.createTypedPath("life/goals")
            #expect(model.tags.map(\.path) == ["life", "life/goals"],
                    "the missing hierarchy is created on the way")
            #expect(model.lastError == nil)

            // A partly-existing path creates only the missing tail, and
            // slash noise forgives (the note sheet's own pinned edge).
            await model.createTypedPath("/life//goals/2026/")
            #expect(model.tags.map(\.path) == ["life", "life/goals", "life/goals/2026"],
                    "only the tail is new; the existing prefix anchors it")
            #expect(model.lastError == nil)

            // A fully-existing path refuses as the duplicate it is (the
            // single-segment door's standing refusal — one sentence).
            await model.createTypedPath("life/goals")
            #expect(model.lastError == "A tag named “life/goals” already exists.")
            #expect(model.tags.count == 3, "refused creates mint nothing")

            // The empty type speaks the shared hint (the note sheet's
            // own sentence, one static for both surfaces).
            await model.createTypedPath("   ")
            #expect(model.lastError == MobileTagsModel.emptyTypedPathMessage)
            #expect(model.lastError?.contains("Mac") == false)

            // The empty state's promise, pinned beside the door that
            // keeps it.
            #expect(MobileTagManagerSheet.emptyStateHint.contains("“/” nests"),
                    "the hint teaches exactly the road this door walks")
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

@MainActor
@Suite("Mobile note tags (parity C3 — apply/remove, the leaf-chip grammar)")
struct MobileNoteTagsTests {
    /// The typed-path road end-to-end (the Mac N24 brain mirrored):
    /// "life/goals" on an empty taxonomy creates BOTH tags and applies
    /// the LEAF only; typing it again no-ops politely; slash noise
    /// forgives ("/a//b/" is a/b); an empty type refuses with the hint.
    @Test func typedPathsApplyCreateAndForgive() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: "Harbor")
            }.id
            let model = MobileNoteTagsModel(session: session, postID: postID)
            await model.refresh()

            let landed = await model.applyTypedPath("life/goals")
            #expect(landed == "life/goals")
            #expect(model.allTags.map(\.path) == ["life", "life/goals"],
                    "the missing hierarchy is created on the way")
            #expect(model.applied.map(\.path) == ["life/goals"],
                    "the LEAF is applied — never the ancestors")

            // Typing the same path again is a polite no-op.
            let again = await model.applyTypedPath("life/goals")
            #expect(again == "life/goals")
            #expect(model.applied.map(\.path) == ["life/goals"])
            #expect(model.status == nil)

            // Slash noise forgives (the Mac's pinned edge).
            let forgiven = await model.applyTypedPath("/a//b/")
            #expect(forgiven == "a/b")
            #expect(model.applied.map(\.path) == ["a/b", "life/goals"])

            // An empty type refuses with the hint, and nothing lands.
            let refused = await model.applyTypedPath("   ")
            #expect(refused == nil)
            #expect(model.status == "Type a tag name — “/” makes a hierarchy (life/goals).")
            #expect(model.status?.contains("Mac") == false)
        }
    }

    /// Remove takes the tag off THIS note only — the tag row lives on
    /// for every other use. The chip and suggestion brains are pinned:
    /// chips show the LEAF (K3), the line is nil when bare, and
    /// suggestions drop applied paths, match substrings, and cap.
    @Test func removeTakesTheTagOffTheNoteAndTheBrainsHold() async throws {
        try await withEditorWorld { session, db in
            let (postID, seaID) = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "Harbor")
                let sea = try ops.createTag(name: "sea")
                _ = try ops.applyTag(sea.id, toPost: post.id)
                return (post.id, sea.id)
            }
            let model = MobileNoteTagsModel(session: session, postID: postID)
            await model.refresh()
            let sea = try #require(model.applied.first)

            await model.remove(sea)
            #expect(model.applied.isEmpty, "the application is gone")
            #expect(model.allTags.map(\.id) == [seaID], "the tag itself lives on")
            #expect(model.status == nil)

            // The chip line (K3's leaf grammar), pinned.
            #expect(MobileNoteTagsModel.chipLine(paths: []) == nil)
            #expect(MobileNoteTagsModel.chipLine(paths: ["sea"]) == "#sea")
            #expect(MobileNoteTagsModel.chipLine(paths: ["life/goals/2026", "sea"])
                == "#2026 #sea", "chips show the leaf only")

            // The suggestion rule, pinned: applied dropped, substring
            // match case-insensitive, capped.
            func tag(_ path: String) -> VariorumCore.Tag {
                VariorumCore.Tag(id: path, ownerId: nil, parentId: nil,
                    name: MobileShelfFaces.leaf(path), path: path,
                    createdAt: Date(), updatedAt: Date(), deletedAt: nil,
                    syncVersion: 0)
            }
            let all = [tag("life"), tag("life/goals"), tag("sea"), tag("sky")]
            #expect(MobileNoteTagsModel.suggestions(all, typed: "", applied: ["sea"])
                .map(\.path) == ["life", "life/goals", "sky"])
            #expect(MobileNoteTagsModel.suggestions(all, typed: "GOAL", applied: [])
                .map(\.path) == ["life/goals"])
            #expect(MobileNoteTagsModel.suggestions(all, typed: "", applied: [], limit: 2)
                .count == 2)
        }
    }
}
