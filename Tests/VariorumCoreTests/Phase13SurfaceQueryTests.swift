import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Stage C1 — the writing surface's read-side additions: the
/// per-container decoration feeds (comments + callout frames) and the
/// callout → blockquote EXPORT mapping, with the load-bearing negative
/// pin: `renderedText` (the one join brain; once the Fragments bridge's pushed body)
/// NEVER maps — a callout stays plain prose everywhere truth flows.
@Suite("Phase 13 C1 — surface queries + the callout export mapping")
struct Phase13SurfaceQueryTests {
    @Test func containerCommentsGroupsLiveNotesPerBlock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let a = try ops.newBlock(in: post.id, text: "First.", at: .end).block
            let b = try ops.newBlock(in: post.id, text: "Second.", at: .end).block
            _ = try ops.newBlock(in: post.id, text: "Uncommented.", at: .end)
            _ = try ops.addBlockComment(to: a.id, text: "note one")
            _ = try ops.addBlockComment(to: a.id, text: "note two")
            let dead = try ops.addBlockComment(to: b.id, text: "gone")
            try ops.deleteBlockComment(dead.id)
            _ = try ops.addBlockComment(to: b.id, text: "kept")

            let map = try db.read { try Queries.containerComments($0, containerID: post.id) }
            #expect(map.count == 2, "uncommented blocks are absent")
            #expect(map[a.id]?.map(\.text) == ["note one", "note two"])
            #expect(map[b.id]?.map(\.text) == ["kept"], "tombstoned notes never feed the surface")

            // Another container's comments never leak in.
            let other = try ops.createPost(title: "q", profile: .generic)
            let elsewhere = try ops.newBlock(in: other.id, text: "Away.", at: .end).block
            _ = try ops.addBlockComment(to: elsewhere.id, text: "foreign")
            let again = try db.read { try Queries.containerComments($0, containerID: post.id) }
            #expect(again.count == 2)
        }
    }

    @Test func blockPresentationsMapsOnlyFramedBlocks() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let plain = try ops.newBlock(in: post.id, text: "Plain.", at: .end).block
            let framed = try ops.newBlock(in: post.id, text: "Framed.", at: .end).block
            try ops.setBlockPresentation(
                framed.id, BlockPresentation(color: "sand", emoji: "💡"))

            let map = try db.read { try Queries.blockPresentations($0, containerID: post.id) }
            #expect(map.count == 1)
            #expect(map[plain.id] == nil)
            #expect(map[framed.id]?.color == "sand")
            #expect(map[framed.id]?.emoji == "💡")

            // Clearing the frame empties the feed.
            try ops.setBlockPresentation(framed.id, nil)
            let cleared = try db.read { try Queries.blockPresentations($0, containerID: post.id) }
            #expect(cleared.isEmpty)
        }
    }

    @Test func updateBlockPresentationTransformsTheStoredFrameInOneTransaction() throws {
        // The partial-edit doors ("set the emoji, keep the color") must
        // read the STORED frame, never a projection cache — the Stage B
        // round-2 designation-read precedent.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Framed.", at: .end).block
            try ops.setBlockPresentation(block.id, BlockPresentation(color: "sand"))
            try ops.updateBlockPresentation(block.id) { existing in
                BlockPresentation(color: existing?.color ?? "blue", emoji: "💡")
            }
            let frame = try db.read {
                try Queries.blockPresentations($0, containerID: post.id)[block.id]
            }
            #expect(frame?.color == "sand", "the transform saw the stored color")
            #expect(frame?.emoji == "💡")

            // An empty transformed kind still refuses.
            #expect(throws: OperationError.self) {
                try ops.updateBlockPresentation(block.id) { _ in
                    BlockPresentation(kind: "  ")
                }
            }
        }
    }

    // MARK: - The export mapping (C1's "export maps to blockquote")

    @Test func calloutBlocksExportAsBlockquotesWithTheEmojiLeading() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Before.", at: .end)
            let callout = try ops.newBlock(
                in: post.id, text: "goal <3\nlike this", at: .end).block
            _ = try ops.newBlock(in: post.id, text: "After.", at: .end)
            try ops.setBlockPresentation(
                callout.id, BlockPresentation(color: "blue", emoji: "💡"))

            let exported = try db.read { try Queries.exportPost($0, postID: post.id) }
            #expect(exported == "Before.\n\n> 💡 goal <3\n> like this\n\nAfter.")

            // The single-block export maps the same way.
            let blockExport = try db.read { try Queries.exportBlock($0, blockID: callout.id) }
            #expect(blockExport == "> 💡 goal <3\n> like this")
        }
    }

    @Test func renderedTextNeverMapsCallouts() throws {
        // THE load-bearing negative pin: `renderedText` is the ONE join
        // brain — the diff/export fast path reads it (the retired Fragments
        // bridge's pushed body did too). A callout frame is presentation; truth stays
        // plain prose.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Before.", at: .end)
            let callout = try ops.newBlock(in: post.id, text: "framed text", at: .end).block
            let before = try db.read { try Queries.renderedText($0, containerID: post.id) }
            try ops.setBlockPresentation(
                callout.id, BlockPresentation(color: "rose", emoji: "🌹"))
            let after = try db.read { try Queries.renderedText($0, containerID: post.id) }
            #expect(before == after, "framing a block never changes rendering truth")
            #expect(after == "Before.\n\nframed text")
        }
    }

    @Test func frameFreePostsKeepTheExportEqualsRenderedTextPin() throws {
        // The Phase 11b pin's scope after the mapping landed: WITHOUT
        // callouts the plain export remains byte-identical to
        // `renderedText` (the fast path returns it directly).
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "One.\n\ntrailing spaced\n", at: .end)
            _ = try ops.newBlock(in: post.id, text: "Two.", at: .end)
            let exported = try db.read { try Queries.exportPost($0, postID: post.id) }
            let rendered = try db.read { try Queries.renderedText($0, containerID: post.id) }
            #expect(exported == rendered)
        }
    }

    @Test func readingAndBulkExportBodiesCarryTheMapping() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Framed Post", profile: .generic)
            let callout = try ops.newBlock(in: post.id, text: "the aside", at: .end).block
            try ops.setBlockPresentation(callout.id, BlockPresentation(color: "green"))
            let reading = try ops.createReading(name: "Book", kind: .book)
            try ops.addPostToReading(post.id, to: reading.id, at: .end)

            let readingExport = try db.read {
                try Queries.exportReading($0, readingID: reading.id)
            }
            #expect(readingExport.contains("> the aside"))

            let manifest = try db.read { try Queries.bulkExportManifest($0) }
            let file = manifest.first { $0.relativePath.contains("Framed Post") }
            // VX-126 (option A) — a DELIBERATE byte-pin update: the note's
            // file is Copy full text's text, header line first; the callout
            // still maps to a blockquote in the body.
            #expect(file?.contents == "{t:\"Framed Post\"}\n\n> the aside")
        }
    }

    @Test func unknownFrameKindsExportAsPlainProse() throws {
        // The unknown-kinds doctrine: a future client's frame family
        // round-trips undamaged and exports as prose here.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "future frame", at: .end).block
            try ops.setBlockPresentation(
                block.id, BlockPresentation(kind: "sidebar", color: "blue"))
            let exported = try db.read { try Queries.exportPost($0, postID: post.id) }
            #expect(exported == "future frame")
        }
    }

    // MARK: - Stage C3 (R40): the canvas projection's fans feed

    /// The minimal takes switcher's feed: `canvasProjection.fans` carries
    /// exactly the FANNED blocks' live ACTIVE takes in fan order — archived
    /// and tombstoned takes excluded, single-take blocks absent, other
    /// containers never leaking in (cost ∝ this container, P1).
    @Test func canvasProjectionCarriesActiveFansForFannedBlocksOnly() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "spatial", profile: .generic)
            let fanned = try ops.newBlock(in: post.id, text: "take one", at: .end)
            let single = try ops.newBlock(in: post.id, text: "alone", at: .end).block
            let second = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(second.id, text: "take two", charDelta: 4)
            // Branch the third FROM the second (a branch lands beside its
            // source, so this keeps the fan order legible).
            let third = try ops.branchVariant(fanned.block.id, from: second.id)
            try ops.autosave(third.id, text: "take three", charDelta: 4)
            let archived = try ops.branchVariant(fanned.block.id, from: third.id)
            try ops.archiveVariant(archived.id)

            // A fanned block in ANOTHER container never leaks in.
            let other = try ops.createPost(title: "elsewhere", profile: .generic)
            let foreign = try ops.newBlock(in: other.id, text: "far", at: .end)
            _ = try ops.branchVariant(foreign.block.id, from: foreign.variant.id)

            let projection = try db.read {
                try Queries.canvasProjection($0, container: post.id)
            }
            #expect(Set(projection.fans.keys) == [fanned.block.id],
                    "fanned blocks only — the single-take block is absent")
            #expect(projection.fans[single.id] == nil)
            #expect(projection.fans[fanned.block.id]?.map(\.id)
                        == [fanned.variant.id, second.id, third.id],
                    "fan order, active-only (the archived take is out)")
            #expect(projection.cards.count == 2, "the cards half is unchanged")
        }
    }
}
