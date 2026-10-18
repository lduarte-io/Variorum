import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-304 (VX-382 U1b) — the book Index's takes badge reads "⑂N", the Outline
// badge's own count, from the TOC row. The count rides the same `renderPost`
// slot `hasFan` comes from: ACTIVE takes only (an archived take is kept, not
// counted — the fan is the set of a block's active variants, OverallModel §2).
@Suite("The TOC row carries the block's active-take count (VX-304)")
struct BlockTOCTakesCountTests {
    @Test func aFannedBlockCountsItsActiveTakesAndAPlainBlockCountsOne() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "a note with a fan")
            let plain = try ops.newBlock(in: post.id, text: "One take only.")
            let fanned = try ops.newBlock(in: post.id, text: "The first take.")
            _ = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            let third = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)

            var rows = try db.read { try Queries.blockTOC($0, post: post.id) }
            let plainRow = try #require(rows.first { $0.blockID == plain.block.id })
            let fanRow = try #require(rows.first { $0.blockID == fanned.block.id })
            #expect(!plainRow.hasFan && plainRow.activeVariantCount == 1)
            #expect(fanRow.hasFan && fanRow.activeVariantCount == 3,
                    "three active takes: \(fanRow.activeVariantCount)")

            // An archived take is kept, never counted.
            try ops.archiveVariant(third.id)
            rows = try db.read { try Queries.blockTOC($0, post: post.id) }
            let after = try #require(rows.first { $0.blockID == fanned.block.id })
            #expect(after.hasFan && after.activeVariantCount == 2)
        }
    }

    /// A row built by hand with no count names the smallest count its
    /// `hasFan` allows, so the two can never contradict each other.
    @Test func aHandBuiltRowsCountAgreesWithItsFanFlag() {
        let fan = Queries.TOCRow(
            blockID: "b", placementID: "p", name: nil, variantID: "v", text: "t",
            hasFan: true, variantLocked: false)
        let plain = Queries.TOCRow(
            blockID: "b", placementID: "p", name: nil, variantID: "v", text: "t",
            hasFan: false, variantLocked: false)
        #expect(fan.activeVariantCount == 2)
        #expect(plain.activeVariantCount == 1)
    }
}
