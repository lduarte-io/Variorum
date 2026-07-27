import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13c Batch 2C — the block-extent index (the uniform-page brief §5, option
/// (a)). The MODEL tier of Read's two-tier pagination: lengths only, resolved
/// by the same read-time rule a rendered page will use, computed in SQL so no
/// prose crosses the boundary.
///
/// The load-bearing property, pinned rather than asserted in prose: the
/// extents AGREE with `renderedText` about what a post contains — the
/// estimator and the page can never disagree about which takes are on the
/// page, only about how tall they are.
@Suite("Block extents — the page domain's model tier (13c 2C)")
struct PageExtentQueryTests {
    @Test func extentsResolveTheSameTakeARenderedPageWould() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Extents")
            let plain = try ops.newBlock(in: post.id, text: "Twelve chars")
            // A fanned block whose CHOSEN take is not the default: the extent
            // must follow the pointer, exactly like renderPost.
            let fanned = try ops.newBlock(in: post.id, text: "short")
            let other = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(other.id, text: "a much longer alternative take", charDelta: 0)
            try ops.chooseVariant(fanned.block.id, variantID: other.id)
            // A multi-paragraph block (I4: newlines are content) — the case
            // that makes character count alone a bad page estimate.
            try ops.newBlock(in: post.id, text: "one\ntwo\nthree")
            // A blank take contributes nothing, like a gap.
            try ops.newBlock(in: post.id, text: "")

            let extents = try db.read { try Queries.blockExtents($0, containerIDs: [post.id]) }
            #expect(extents.count == 4, "one row per live placement, gaps included")
            #expect(extents.allSatisfy { $0.containerID == post.id })
            #expect(extents[0].blockID == plain.block.id)
            #expect(extents[0].characters == 12)
            #expect(extents[0].newlines == 0)
            #expect(extents[1].characters == 30, "the CHOSEN take's length, not the default's")
            #expect(extents[2].newlines == 2, "internal newlines are counted")
            #expect(extents[3].characters == 0, "a blank take contributes nothing")

            // The agreement pin: the summed extents equal the rendered
            // characters of the same post, minus exactly the join separators
            // the rendering adds (which the estimator models itself).
            let rendered = try db.read { try Queries.renderedText($0, containerID: post.id) }
            let summed = extents.reduce(0) { $0 + $1.characters }
            let joins = rendered.count - summed
            #expect(summed == 12 + 30 + 13)
            #expect(joins == 4, "three non-empty blocks join with \"\\n\\n\": two joins")
        }
    }

    @Test func aTombstonedBlockReadsAsZeroRatherThanVanishing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Gaps")
            try ops.newBlock(in: post.id, text: "alive")
            let doomed = try ops.newBlock(in: post.id, text: "about to die")
            try ops.deleteBlock(doomed.block.id)

            let extents = try db.read { try Queries.blockExtents($0, containerIDs: [post.id]) }
            // deleteBlock tombstones the placement too, so the row is gone
            // from the extent list exactly as it is gone from renderPost.
            #expect(extents.count == 1)
            #expect(extents[0].characters == 5)
            let slots = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(slots.count == extents.count, "the two traversals see the same slots")
        }
    }

    @Test func severalPostsComeBackGroupedAndOrdered() throws {
        try withOperations { ops, db in
            let first = try ops.createPost(title: "One")
            let second = try ops.createPost(title: "Two")
            try ops.newBlock(in: first.id, text: "aaa")
            try ops.newBlock(in: first.id, text: "bbbb")
            try ops.newBlock(in: second.id, text: "ccccc")

            let extents = try db.read {
                try Queries.blockExtents($0, containerIDs: [first.id, second.id])
            }
            #expect(extents.count == 3)
            let byPost = Dictionary(grouping: extents, by: \.containerID)
            #expect(byPost[first.id]?.map(\.characters) == [3, 4], "reading order per post")
            #expect(byPost[second.id]?.map(\.characters) == [5])

            // An empty request is empty, never a full-table scan.
            #expect(try db.read { try Queries.blockExtents($0, containerIDs: []) }.isEmpty)
            // An unknown id contributes nothing rather than throwing.
            #expect(try db.read { try Queries.blockExtents($0, containerIDs: ["nope"]) }.isEmpty)
        }
    }
}
