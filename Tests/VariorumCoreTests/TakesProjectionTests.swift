import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 11, Step A3 — the takes board's combined read traversal and the
/// fan-style setting (spike record item 1: a user SETTING, synced).
@Suite("Takes projection & fan style (Phase 11, A3)")
struct TakesProjectionTests {
    @Test func fanStyleDefaultsToStackAndRoundTripsAsASyncedSetting() throws {
        try withOperations { ops, db in
            #expect(try db.read { try Queries.fanStyle($0) } == .stack,
                    "the recorded build-time default")
            try ops.setFanStyle(.carousel)
            #expect(try db.read { try Queries.fanStyle($0) } == .carousel)
            try ops.setFanStyle(.slotSplit)
            #expect(try db.read { try Queries.fanStyle($0) } == .slotSplit)
            // The setting row is SYNCED (upsert-only, like segmentation).
            #expect(try db.outboxContains("setting", "fan_style"))
        }
    }

    @Test func activeFansAndContainerTitleAreTheOneTestedHomes() throws {
        // Round 1 NIT 9: the view models read these through Queries, never
        // re-typed SQL — pinned equal to takesProjection's own fan view.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the title", profile: .blog)
            let m = try ops.newBlock(in: post.id, text: "One.", at: .end)
            let alt = try ops.branchVariant(m.block.id, from: m.variant.id)
            let archived = try ops.branchVariant(m.block.id, from: m.variant.id)
            try ops.archiveVariant(archived.id)

            try db.read { database in
                let fans = try Queries.activeFans(database, blockIDs: [m.block.id])
                #expect(fans[m.block.id]?.map(\.id) == [m.variant.id, alt.id],
                        "live ACTIVE takes in fan order — archived stays out")
                let projection = try Queries.takesProjection(database, post: post.id)
                #expect(projection.fans == fans, "one brain — takesProjection reads through it")
                #expect(try Queries.containerTitle(database, id: post.id) == "the title")
                #expect(try Queries.containerTitle(database, id: "missing") == nil,
                        "tolerant read")
            }
        }
    }

    @Test func takesProjectionCarriesSlotsFansLensesAndSeal() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let m1 = try ops.newBlock(in: post.id, text: "One.", at: .end)
            let alt = try ops.branchVariant(m1.block.id, from: m1.variant.id)
            let archived = try ops.branchVariant(m1.block.id, from: m1.variant.id)
            try ops.archiveVariant(archived.id)
            _ = try ops.newBlock(in: post.id, text: "Two.", at: .end)
            let lens = try ops.createLens(post: post.id, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: m1.block.id, variant: alt.id)

            var projection = try db.read { try Queries.takesProjection($0, post: post.id) }
            #expect(projection.slots.count == 2)
            #expect(projection.fans[m1.block.id]?.map(\.id) == [m1.variant.id, alt.id],
                    "the fan is the live ACTIVE takes in fan order — archived stays history")
            #expect(projection.lenses.map(\.id) == [lens.id])
            #expect(projection.lensSelections[lens.id] == [m1.block.id: alt.id])
            #expect(projection.sealed == false)
            #expect(projection.fanStyle == .stack)

            try ops.lockPost(post.id)
            projection = try db.read { try Queries.takesProjection($0, post: post.id) }
            #expect(projection.sealed == true)
        }
    }
}
