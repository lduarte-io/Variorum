import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Step A1 — the sync shaping of the lockstep event: comments and
/// sections crossing the wire as plain metadata (no repair classes — no
/// natural keys), cascades landing whole across devices, and the dangling
/// section pointer converging as a read-time fallback, never a repair.
/// (The §12 version-check refusal itself is pinned generically by
/// `SchemaLockstepTests` — it reads `SyncSchema.lockstepVersion`
/// symbolically, so the 2→3 bump rides free.)
@Suite("Phase 13 tables under sync (A1 — convergence)")
struct Phase13SyncConvergenceTests {
    private func makePair() throws -> (FakeSyncServer, SyncClient, SyncClient) {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)
        return (server, a, b)
    }

    private func syncBoth(_ a: SyncClient, _ b: SyncClient) async throws {
        for _ in 0..<2 {
            for client in [a, b] {
                _ = try await client.pull()
                _ = try await client.push()
            }
        }
    }

    @Test func commentsAndChaptersCrossTheWireAsPlainMetadata() async throws {
        let (_, a, b) = try makePair()
        let world = try a.with { ops, _ -> (blockID: String, readingID: String) in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            _ = try ops.addBlockComment(to: block.id, text: "take 1 preferred")
            let reading = try ops.createReading(
                name: "orbit", kind: .curated, wordTarget: 10_000)
            _ = try ops.addPostToReading(post.id, to: reading.id)
            let chapter = try ops.createSection(in: reading.id, name: "I / leaving")
            try ops.assignPostToSection(post.id, in: reading.id, section: chapter.id)
            try ops.setBlockPresentation(block.id, BlockPresentation(color: "blue", emoji: "💡"))
            return (block.id, reading.id)
        }
        try await syncBoth(a, b)

        #expect(try b.db.fetchInt(
            "SELECT COUNT(*) FROM block_comment WHERE deleted_at IS NULL") == 1)
        #expect(try b.db.fetchInt(
            "SELECT COUNT(*) FROM reading_section WHERE deleted_at IS NULL") == 1)
        #expect(try b.db.fetchString(
            "SELECT presentation FROM block WHERE id = ?", [world.blockID])
            == #"{"color":"blue","emoji":"💡","kind":"callout"}"#)
        #expect(try b.db.fetchInt(
            "SELECT word_target FROM reading WHERE id = ?", [world.readingID]) == 10_000)
        let assignments = try await b.db.read { [readingID = world.readingID] in
            try Queries.sectionAssignments($0, readingID: readingID)
        }
        #expect(assignments.count == 1)
        #expect(try a.syncedDump() == (try b.syncedDump()))
    }

    @Test func aCommentEditRaceConvergesByCASNeverCorruption() async throws {
        let (_, a, b) = try makePair()
        let commentID = try a.with { ops, _ -> String in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            return try ops.addBlockComment(to: block.id, text: "original note").id
        }
        try await syncBoth(a, b)

        // Both devices rewrite the SAME comment offline — metadata CAS
        // (S5 is deliberately scoped to variant.working_text; a comment
        // is a working note, single-author, and either text winning is
        // the recorded acceptable outcome).
        try a.with { ops, _ in try ops.editBlockComment(commentID, text: "A's rewrite") }
        try b.with { ops, _ in try ops.editBlockComment(commentID, text: "B's rewrite") }
        try await syncBoth(a, b)
        try await syncBoth(a, b)

        #expect(try a.syncedDump() == (try b.syncedDump()))
        let converged = try a.db.fetchString(
            "SELECT text FROM block_comment WHERE id = ?", [commentID])
        #expect(converged == "A's rewrite" || converged == "B's rewrite")
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
        #expect(try a.db.fetchInt("SELECT COUNT(*) FROM block_comment") == 1,
                "CAS on one row — no duplicate, no conflict variant (not S5's field)")
    }

    @Test func crossDeviceCascadesLandWholeOnBothSides() async throws {
        let (_, a, b) = try makePair()
        let world = try a.with { ops, _ -> (blockID: String, commentID: String, readingID: String, sectionID: String) in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            _ = try ops.newBlock(in: post.id, text: "Sibling.", at: .end)
            let comment = try ops.addBlockComment(to: block.id, text: "dies with the block")
            let reading = try ops.createReading(name: "orbit", kind: .curated)
            let chapter = try ops.createSection(in: reading.id, name: "I")
            return (block.id, comment.id, reading.id, chapter.id)
        }
        try await syncBoth(a, b)

        // B deletes the block AND the reading; A must converge to dead
        // comments/sections with the parents' exact stamps.
        try b.with { ops, _ in
            try ops.deleteBlock(world.blockID)
            try ops.deleteReading(world.readingID)
        }
        try await syncBoth(a, b)
        try await syncBoth(a, b)

        #expect(try a.db.deletedAt("block_comment", world.commentID) != nil)
        #expect(try a.db.deletedAt("block_comment", world.commentID)
                == (try a.db.deletedAt("block", world.blockID)),
                "the comment carries the block's exact stamp on BOTH devices")
        #expect(try a.db.deletedAt("reading_section", world.sectionID)
                == (try a.db.deletedAt("reading", world.readingID)))
        #expect(try a.syncedDump() == (try b.syncedDump()))
    }

    @Test func aSectionDeleteRacingAnAssignmentDanglesAsUnsectionedEverywhere() async throws {
        let (_, a, b) = try makePair()
        let world = try a.with { ops, _ -> (postID: String, readingID: String, sectionID: String) in
            let post = try ops.createPost(title: "post", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
            let reading = try ops.createReading(name: "orbit", kind: .curated)
            _ = try ops.addPostToReading(post.id, to: reading.id)
            let chapter = try ops.createSection(in: reading.id, name: "I")
            return (post.id, reading.id, chapter.id)
        }
        try await syncBoth(a, b)

        // A assigns the post to the chapter while B deletes the chapter —
        // the classic dangling-pointer race. NO repair fires (the
        // chosen-variant fallback class); both sides converge to a stored
        // pointer that READS as unsectioned.
        try a.with { ops, _ in
            try ops.assignPostToSection(world.postID, in: world.readingID, section: world.sectionID)
        }
        try b.with { ops, _ in
            try ops.deleteSection(world.sectionID)
        }
        try await syncBoth(a, b)
        try await syncBoth(a, b)

        #expect(try a.syncedDump() == (try b.syncedDump()))
        for client in [a, b] {
            let stored = try client.db.fetchString(
                "SELECT section_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [world.postID])
            let assignments = try await client.db.read { [readingID = world.readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }
            #expect(assignments[world.postID] == nil,
                    "\(client.name): the dangling pointer reads as unsectioned")
            // Whichever way the CAS race settled the membership row, the
            // stored state is legal: a pointer at the dead section
            // (dangling — tolerated) or never-assigned nil.
            #expect(stored == world.sectionID || stored == nil)
        }
        #expect(try a.db.deletedAt("reading_section", world.sectionID) != nil)
    }

    @Test func aRestoredBlockRevivesItsCommentsAcrossTheWire() async throws {
        let (_, a, b) = try makePair()
        let world = try a.with { ops, _ -> (blockID: String, commentID: String) in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            _ = try ops.newBlock(in: post.id, text: "Sibling.", at: .end)
            let comment = try ops.addBlockComment(to: block.id, text: "survives the round trip")
            return (block.id, comment.id)
        }
        try await syncBoth(a, b)

        try a.with { ops, _ in try ops.deleteBlock(world.blockID) }
        try await syncBoth(a, b)
        #expect(try b.db.deletedAt("block_comment", world.commentID) != nil)

        try a.with { ops, _ in try ops.restoreBlock(world.blockID) }
        try await syncBoth(a, b)
        try await syncBoth(a, b)

        #expect(try b.db.deletedAt("block_comment", world.commentID) == nil,
                "the exact-stamp revival propagates — the note is back on both devices")
        #expect(try a.syncedDump() == (try b.syncedDump()))
    }
}
