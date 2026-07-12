//
//  BlockTint.swift
//  Variorum
//
//  Pure color assignment for the "Show Blocks" tint mode (Phase 9d, author
//  2026-07-09). Her rule, verbatim intent: NOT an alternating zebra — "every
//  new block will cause a rippling zebra effect" — so the color is a stable
//  function of the block's ID, locally bumped so the same color is never
//  adjacent. Inserting a block never recolors the document: everything
//  before it keeps its color by construction, and a following block changes
//  only if its own bump condition changed (bounded, rare).
//

import CoreGraphics
import Foundation

nonisolated enum BlockTint {
    static let paletteCount = 5

    /// The container→view geometry mapping (Phase 10 Step 8 — the traced
    /// KnownIssues mis-registration): TK2 fragment frames are relative to
    /// the TEXT CONTAINER; the tint overlay views live in the TEXT VIEW,
    /// whose container sits at `textContainerOrigin` (the inset). The 9d
    /// tint emitted container coordinates unconverted, so every stripe sat
    /// one inset (8 px ≈ half a line) ABOVE its text — block boundaries
    /// crossed lines mid-way, which is exactly the author's "colors change
    /// where no block boundary is / every line its own pastel". A block's
    /// stripe spans its first fragment's top to its last fragment's
    /// bottom, converted.
    static func viewRect(
        containerTop: CGFloat, containerBottom: CGFloat,
        containerOrigin: CGPoint, viewWidth: CGFloat
    ) -> CGRect {
        CGRect(
            x: 0,
            y: containerTop + containerOrigin.y,
            width: viewWidth,
            height: max(containerBottom - containerTop, 0))
    }

    /// FNV-1a 64 over UTF-8 — deliberately NOT `String.hashValue`, which is
    /// per-process seeded: a block's color must be stable across launches.
    static func stableHash(_ id: String) -> UInt64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in id.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        return hash
    }

    /// The palette index for one block given its predecessor's resolved
    /// index. With paletteCount ≥ 2 the bump guarantees adjacent-distinct.
    static func tintIndex(blockID: String, previous: Int?) -> Int {
        var index = Int(stableHash(blockID) % UInt64(paletteCount))
        if index == previous { index = (index + 1) % paletteCount }
        return index
    }

    /// Resolved indices for a whole post, in order.
    static func indices(for blockIDs: [String]) -> [Int] {
        var previous: Int?
        return blockIDs.map { id in
            let index = tintIndex(blockID: id, previous: previous)
            previous = index
            return index
        }
    }
}
