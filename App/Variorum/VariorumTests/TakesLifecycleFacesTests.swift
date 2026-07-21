//
//  TakesLifecycleFacesTests.swift
//  VariorumTests
//
//  13b Stage 3, Batch 3D (T5 — N1/N6): the takes-lifecycle faces.
//  - The ARCHIVED LISTING on the Takes board (N1's vanish trap dies): the
//    fans query stays active-only; the archived listing is its own read
//    (`refreshArchived`), the "archived · n" door reveals it, Unarchive is
//    the act, and the ⌘⇧A speech names the road back.
//  - The TAKE-LABEL faces (N6): the 3B `setTakeLabel` op reached through
//    the model's request/set pair the card menus and the bar door share.
//
//  Red-on-old: the archived-listing pins were verified RED by behavioral
//  revert (the old model had NO archived read — `archivedCounts` reverted
//  to an always-empty computation leaves the door with nothing to render
//  and the pins fail); the label pins likewise against a request that
//  never resolves the current label.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWorld<T>(
    seed: UInt64 = 7,
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A two-block post; block 1 fanned (3 takes), block 2 single.
@MainActor
private struct FacesWorld {
    let postID: String
    let fannedBlock: String
    let singleBlock: String
    let chosen: String
    let takeB: String
    let takeC: String

    static func make(_ session: AppSession) async throws -> FacesWorld {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "faces post", profile: .blog)
            let m1 = try ops.newBlock(in: post.id, text: "Fanned block, take one.", at: .end)
            let m2 = try ops.newBlock(in: post.id, text: "Single block.", at: .end)
            let b = try ops.branchVariant(m1.block.id, from: m1.variant.id)
            try ops.autosave(b.id, text: "Fanned block, take two.", charDelta: 4)
            let c = try ops.branchVariant(m1.block.id, from: m1.variant.id)
            try ops.autosave(c.id, text: "Fanned block, take three.", charDelta: 4)
            return FacesWorld(
                postID: post.id, fannedBlock: m1.block.id, singleBlock: m2.block.id,
                chosen: m1.variant.id, takeB: b.id, takeC: c.id)
        }
    }
}

@MainActor
@Suite("Archived takes reach the Takes board (13b 3D — N1)")
struct ArchivedListingTests {
    private func freshModel(
        _ session: AppSession, _ world: FacesWorld, name: String
    ) -> TakesViewModel {
        let defaults = UserDefaults(suiteName: "TakesLifecycleFaces-\(name)")!
        defaults.removePersistentDomain(forName: "TakesLifecycleFaces-\(name)")
        return TakesViewModel(session: session, postID: world.postID, defaults: defaults)
    }

    @Test func archivedCountsAndRowsFeedTheDoorAndUnarchiveReturnsToTheFan() async throws {
        try await withWorld { session, db in
            let world = try await FacesWorld.make(session)
            let model = freshModel(session, world, name: "listing")
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            // Nothing archived yet — the door has nothing to render.
            await model.refreshArchived()
            #expect(model.archivedCounts.isEmpty, "no archived takes, no door")

            await model.archiveTake(world.takeB)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            await model.refreshArchived()

            // The fan is active-only (unchanged by design)…
            #expect(model.projection.fans[world.fannedBlock]?.contains { $0.id == world.takeB }
                    == false, "the fans query stays active-only")
            // …and the archived listing is its own read, feeding the door.
            #expect(model.archivedCounts[world.fannedBlock] == 1,
                    "the \u{201C}archived \u{B7} n\u{201D} door's count is real")
            #expect(model.archivedTakes[world.fannedBlock]?.map(\.id) == [world.takeB])

            // The reveal toggle (session-only, like blooms).
            #expect(!model.revealedArchived.contains(world.fannedBlock))
            model.toggleArchivedRevealed(world.fannedBlock)
            #expect(model.revealedArchived.contains(world.fannedBlock))

            // Unarchive — the act, right on the listing's card.
            await model.unarchiveTake(world.takeB)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            await model.refreshArchived()
            #expect(model.projection.fans[world.fannedBlock]?.contains { $0.id == world.takeB }
                    == true, "back in the fan")
            #expect(model.archivedCounts[world.fannedBlock] == nil,
                    "the door disappears when nothing is archived")
        }
    }

    @Test func everyArchiveDoorSpeaksTheRoadBack() async throws {
        try await withWorld { session, db in
            let world = try await FacesWorld.make(session)
            let model = freshModel(session, world, name: "speech")
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            // The Takes host names the in-board road (N1/R118: the road
            // back lives in Takes).
            model.host = .takes
            await model.archiveTake(world.takeB)
            #expect(model.statusMessage?.contains("archived \u{B7} n") == true,
                    "the ⌘⇧A/menu speech names the door: \(model.statusMessage ?? "nil")")

            // The Lenses host points at the Takes board instead of
            // promising a door it doesn't render.
            model.host = .lenses
            await model.archiveTake(world.takeC)
            #expect(model.statusMessage?.contains("Takes board") == true,
                    "the Lenses copy points across: \(model.statusMessage ?? "nil")")

            // Unarchive confirms out loud too.
            await model.unarchiveTake(world.takeB)
            #expect(model.statusMessage?.contains("unarchived") == true)

            // A refusal still outranks the road speech (fire-and-speak:
            // the ops' own refusal, never a false success line).
            try await session.runner.run { [postID = world.postID] ops in
                try ops.lockPost(postID)
            }
            await model.archiveTake(world.chosen)
            #expect(model.statusMessage?.contains("sealed") == true,
                    "sealed refusal wins: \(model.statusMessage ?? "nil")")
        }
    }

    @Test func refusalsSurfaceInsteadOfFalseRoadSpeech() async throws {
        try await withWorld { session, db in
            let world = try await FacesWorld.make(session)
            let model = freshModel(session, world, name: "refusal")
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            // I10: the single block's ONLY take refuses to archive — the
            // refusal speaks; the road copy must not overwrite it.
            let single = try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT id FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                        """,
                    arguments: [world.singleBlock])
            }
            await model.archiveTake(single ?? "")
            #expect(model.statusMessage?.contains("archived \u{B7} n") != true,
                    "no road speech on a refused archive")
            #expect(model.statusMessage != nil, "the refusal itself speaks")
        }
    }
}

@MainActor
@Suite("Take labels get their faces (13b 3D — N6)")
struct TakeLabelFaceTests {
    @Test func requestResolvesTheCurrentLabelAndSetReachesTheStore() async throws {
        try await withWorld { session, db in
            let world = try await FacesWorld.make(session)
            let defaults = UserDefaults(suiteName: "TakesLifecycleFaces-label")!
            defaults.removePersistentDomain(forName: "TakesLifecycleFaces-label")
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: defaults)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            // A fresh take: the prompt opens empty.
            model.requestTakeLabel(variantID: world.takeB)
            #expect(model.takeLabelRequest?.variantID == world.takeB)
            #expect(model.takeLabelRequest?.currentLabel == nil)

            // Set through the face's one door — the 3B op does the work.
            await model.setTakeLabel(world.takeB, label: "the bolder one")
            let stored = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT label FROM variant WHERE id = ?",
                    arguments: [world.takeB])
            }
            #expect(stored == "the bolder one")

            // Re-request: the prompt now carries the current label (the
            // change/clear flow starts from truth).
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            model.requestTakeLabel(variantID: world.takeB)
            #expect(model.takeLabelRequest?.currentLabel == "the bolder one")

            // Clear (nil) — the op NULLs.
            await model.setTakeLabel(world.takeB, label: nil)
            let cleared = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT label FROM variant WHERE id = ?",
                    arguments: [world.takeB])
            }
            #expect(cleared == nil)
        }
    }

    @Test func anArchivedTakeCanStillBeLabeledFromItsListing() async throws {
        // The 3B judgment call made a face fact: labels are allowed on
        // archived takes (the archived listing is where labels help most).
        try await withWorld { session, db in
            let world = try await FacesWorld.make(session)
            let defaults = UserDefaults(suiteName: "TakesLifecycleFaces-archlabel")!
            defaults.removePersistentDomain(forName: "TakesLifecycleFaces-archlabel")
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: defaults)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            await model.archiveTake(world.takeC)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            await model.refreshArchived()

            await model.setTakeLabel(world.takeC, label: "the archived draft")
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            await model.refreshArchived()

            // The request resolves the label from the ARCHIVED listing
            // (the fan no longer carries the take).
            model.requestTakeLabel(variantID: world.takeC)
            #expect(model.takeLabelRequest?.currentLabel == "the archived draft")
            // And it stays archived — labeling never resurrects (3B pin's
            // face-side mirror).
            let status = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT status FROM variant WHERE id = ?",
                    arguments: [world.takeC])
            }
            #expect(status == "archived")
        }
    }
}
