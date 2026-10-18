//
//  VX349ListHeaderRuleTests.swift
//  VariorumTests (Mac)
//
//  VX-349 (the VX-348 run, U3) — the new seam's own pins, pure: the List
//  header floats only while it is pinned AND content lies under it, and the
//  scroll reader's reading of "content under the top edge". New API — not in
//  the red product (its mounted twin, `VX349ListHeaderRestTests`, is the
//  red-on-old pin).
//

import CoreGraphics
import Testing
@testable import Variorum

@Suite("VX-349 — the List header floats only over content (pure)")
struct VX349ListHeaderRuleTests {
    /// The decision, pure (VX-349's new seam): the floating face only while the
    /// header is pinned AND content lies under it.
    @Test func theFloatingFaceNeedsContentUnderTheHeader() {
        #expect(!LibraryListHeader.floats(pinned: true, contentBeneath: false), "at rest at the top: the resting face")
        #expect(LibraryListHeader.floats(pinned: true, contentBeneath: true), "scrolled under: floats")
        #expect(!LibraryListHeader.floats(pinned: false, contentBeneath: true), "mid-list: the resting face")
        #expect(!LibraryListHeader.floats(pinned: false, contentBeneath: false))
        #expect(!LibraryListScrollReader.contentBeneath(offsetY: 0, topInset: 0), "rest")
        #expect(!LibraryListScrollReader.contentBeneath(offsetY: -12, topInset: 0), "the elastic pull past the top")
        #expect(LibraryListScrollReader.contentBeneath(offsetY: 1, topInset: 0), "scrolled a point")
        #expect(!LibraryListScrollReader.contentBeneath(offsetY: -10, topInset: 10), "rest under a top inset")
    }
}
