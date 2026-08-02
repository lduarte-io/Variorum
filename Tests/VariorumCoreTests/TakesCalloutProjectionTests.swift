import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **Phase 13k, K9 — the callout frame reaches Take mode.**
///
/// Her instruction (2026-08-01): *"callouts are supposed to be added to take
/// mode as well."* The DOOR has routed from the boards since 13c R2-2, but
/// the frame drew only in Write's decoration overlay, because nothing the
/// boards read carried the presentation at all — so setting one from a take
/// card changed a row and nothing on the glass.
///
/// What is pinned here is the read half: the takes projection carries the
/// post's frames, from the SAME query Write's decoration layer has always
/// used (`blockPresentations`), so the two surfaces can never disagree about
/// which blocks are framed or in what colour.
@Suite("Callout frames in the takes projection (13k K9)")
struct TakesCalloutProjectionTests {

    /// DISCRIMINATING REVERT: drop the `presentations:` argument from
    /// `Queries.takesProjection` and every expectation below that names a
    /// frame fails (the map reads empty) while the plain-block expectations
    /// stay green — i.e. the revert is exactly the missing read.
    @Test func theProjectionCarriesTheBlocksFrames() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let framed = try ops.newBlock(in: post.id, text: "A warning.", at: .end)
            let plain = try ops.newBlock(in: post.id, text: "Ordinary prose.", at: .end)
            try ops.setBlockPresentation(
                framed.block.id, BlockPresentation(color: "sand", emoji: "⚠️"))

            let projection = try db.read { try Queries.takesProjection($0, post: post.id) }
            #expect(projection.presentations[framed.block.id]
                    == BlockPresentation(color: "sand", emoji: "⚠️"))
            #expect(projection.presentations[plain.block.id] == nil,
                    "a plain block carries no frame — absent, never a default one")

            // ONE brain with Write's decoration feed: the projection's map IS
            // `blockPresentations`, not a second read that could drift.
            let editorFeed = try db.read {
                try Queries.blockPresentations($0, containerID: post.id)
            }
            #expect(projection.presentations == editorFeed)
        }
    }

    @Test func removingTheFrameRemovesItFromTheProjection() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let mint = try ops.newBlock(in: post.id, text: "A warning.", at: .end)
            try ops.setBlockPresentation(mint.block.id, BlockPresentation(color: "rose"))
            #expect(try db.read {
                try Queries.takesProjection($0, post: post.id)
            }.presentations[mint.block.id] != nil)

            try ops.setBlockPresentation(mint.block.id, nil)
            #expect(try db.read {
                try Queries.takesProjection($0, post: post.id)
            }.presentations[mint.block.id] == nil,
                    "un-framing is what the board must stop drawing")
        }
    }

    /// The fail-open doctrine, inherited rather than re-decided: malformed
    /// stored JSON reads as a PLAIN block on both surfaces (losing a frame
    /// renders prose; it never renders a crash).
    @Test func malformedStoredJSONIsAPlainBlockHereToo() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let mint = try ops.newBlock(in: post.id, text: "text", at: .end)
            try db.write { database in
                try database.execute(
                    sql: "UPDATE block SET presentation = ? WHERE id = ?",
                    arguments: ["{not json", mint.block.id])
            }
            let projection = try db.read { try Queries.takesProjection($0, post: post.id) }
            #expect(projection.presentations[mint.block.id] == nil)
            #expect(projection.slots.count == 1, "and the slot itself is unharmed")
        }
    }
}
