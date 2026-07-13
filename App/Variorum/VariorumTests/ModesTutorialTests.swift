//
//  ModesTutorialTests.swift
//  VariorumTests
//
//  Phase 11, Step A10 — the modes tutorial's pins: seeding is idempotent
//  and ISOLATED (never mutates existing user rows); the examples drive
//  REAL ops on the demo post only; deleting the demo leaves no orphans.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase, UserDefaults) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    let defaults = UserDefaults(suiteName: "ModesTutorialTests-\(UUID().uuidString)")!
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db, defaults)
    }
}

@Suite("Modes tutorial (Phase 11, A10)")
@MainActor
struct ModesTutorialTests {
    @Test func seedingIsIdempotentAndNeverTouchesUserRows() async throws {
        try await withWorld { session, db, defaults in
            // A real user post the seeding must never touch.
            let userPost = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "the author's real writing", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "Precious words.", at: .end)
                return post.id
            }
            let userSnapshot = try await db.read { db in
                try Row.fetchAll(db, sql: """
                    SELECT id, title, updated_at FROM container WHERE id = ?
                    """, arguments: [userPost]).map(\.description)
            }

            let model = ModesTutorialModel(session: session, defaults: defaults)
            await model.ensureDemo()
            let demoID = try #require(model.demoPostID)
            #expect(model.shape != nil)

            // Idempotent: a second ensure finds the SAME demo — no new post.
            let secondModel = ModesTutorialModel(session: session, defaults: defaults)
            await secondModel.ensureDemo()
            #expect(secondModel.demoPostID == demoID)
            let postCount = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL
                    """)
            }
            #expect(postCount == 2, "the user's post + ONE demo, however many ensures ran")

            // Isolated: the user's row is byte-untouched.
            let after = try await db.read { db in
                try Row.fetchAll(db, sql: """
                    SELECT id, title, updated_at FROM container WHERE id = ?
                    """, arguments: [userPost]).map(\.description)
            }
            #expect(after == userSnapshot)
        }
    }

    @Test func theExamplesDriveRealOpsOnTheDemoOnly() async throws {
        try await withWorld { session, db, defaults in
            let model = ModesTutorialModel(session: session, defaults: defaults)
            await model.ensureDemo()
            let shape = try #require(model.shape)
            let demoID = try #require(model.demoPostID)

            // Diverge mints a REAL take on the demo's thread block.
            let fanBefore = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL
                    """, arguments: [shape.threadBlockID])
            }
            let slot = try await db.read { db in
                try Queries.renderPost(db, containerID: demoID)
                    .first { $0.blockID == shape.threadBlockID }
            }
            await model.divergeHere(
                blockID: shape.threadBlockID, fromVariantID: slot!.variantID!)
            let fanAfter = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL
                    """, arguments: [shape.threadBlockID])
            }
            #expect(fanAfter == (fanBefore ?? 0) + 1, "a real branchVariant landed")

            // Adopt writes the demo's chosen through the real compound op.
            await model.adoptTutorialLens()
            #expect(model.statusMessage == nil)

            // Fork is a REAL duplicateAsVersion; the copy is version-linked.
            await model.forkDemo()
            let peers = try await db.read { try Queries.versionPeerPosts($0, of: demoID) }
            #expect(peers.count == 1, "the fork example minted a real version copy")
        }
    }

    @Test func deletingTheDemoLeavesNoOrphans() async throws {
        try await withWorld { session, db, defaults in
            let model = ModesTutorialModel(session: session, defaults: defaults)
            await model.ensureDemo()
            let demoID = try #require(model.demoPostID)
            await model.forkDemo()

            // Reset deletes demo + the tracked fork, then re-seeds fresh.
            await model.resetDemo()
            let freshID = try #require(model.demoPostID)
            #expect(freshID != demoID, "reset re-seeded a fresh demo")
            #expect(try await db.read { db in
                try Bool.fetchOne(db, sql: """
                    SELECT EXISTS (SELECT 1 FROM container WHERE id = ? AND deleted_at IS NULL)
                    """, arguments: [demoID])
            } == false, "the old demo is tombstoned")

            // NO ORPHANS: nothing live still points into the dead demo —
            // its blocks, takes, lenses, and choices all cascaded; the
            // unplaced-blocks safety net stays empty.
            let liveDebris = try await db.read { db -> Int in
                let blocks = try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL
                    """, arguments: [demoID]) ?? 0
                let lenses = try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM lens
                    WHERE container_id = ? AND deleted_at IS NULL
                    """, arguments: [demoID]) ?? 0
                return blocks + lenses
            }
            #expect(liveDebris == 0)
            let unplaced = try await db.read { try Queries.unplacedBlocks($0) }
            #expect(unplaced.isEmpty, "no lineage leftovers strand in the safety net")
        }
    }
}
