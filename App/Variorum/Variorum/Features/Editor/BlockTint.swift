//
//  BlockTint.swift
//  Variorum
//
//  What survives of the 9d "Show Blocks" tint mode after Phase 13 C1
//  retired its LOOK (R6: "we shouldn't have all the blocks as different
//  colors" — dotted seams are THE boundary mechanism now; the toggle's
//  face became seam visibility):
//
//  - `stableHash` — the stable per-block color identity, still the
//    same-ORIGIN signal behind the takes/aligned views' lineage stripes
//    (FNV-1a, deliberately NOT `String.hashValue`, which is per-process
//    seeded: a block's color must be stable across launches);
//  - `viewRect` — the container→view geometry mapping (Phase 10 Step 8's
//    traced mis-registration fix), now feeding the decoration layer's
//    frame walk (`refreshDecorations`).
//
//  The pastel palette + never-adjacent index machinery retired with the
//  look.
//

import CoreGraphics
import Foundation

nonisolated enum BlockTint {
    /// The container→view geometry mapping (Phase 10 Step 8 — the traced
    /// KnownIssues mis-registration): TK2 fragment frames are relative to
    /// the TEXT CONTAINER; overlay views live in the TEXT VIEW, whose
    /// container sits at `textContainerOrigin` (the inset). A block's
    /// frame spans its first fragment's top to its last fragment's
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

    /// FNV-1a 64 over UTF-8 — a block's identity color, stable across
    /// launches and devices.
    static func stableHash(_ id: String) -> UInt64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in id.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        return hash
    }
}
