//
//  TrailingFlowRowsTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch A — row 58: the masthead's tag
//  cluster became a right-aligned wrapping row (`TrailingFlow`). Its two
//  pure brains are pinned here headlessly: the row rule (byte-compatible
//  with the phone's `MobileChipFlow.rows`, so the Shared/ hoist at the next
//  touch is a move) and the orphan rule the first walk earned — the ＃ door
//  never starts a line by itself.
//

import Foundation
import Testing
@testable import Variorum

@Suite("TrailingFlow's row and orphan rules (correction round, row 58)")
struct TrailingFlowRowsTests {
    /// Greedy fill; break when the next item plus its spacing would cross
    /// the width; an over-wide item takes a line of its own.
    @Test func theRowRuleFillsGreedilyAndNeverDropsAnItem() {
        // 100 + 4 + 100 = 204 ≤ 210; the third (100) would make 308 → wraps.
        #expect(TrailingFlow.rows(widths: [100, 100, 100], available: 210, spacing: 4) == [[0, 1], [2]])
        // An item wider than the line still gets a line.
        #expect(TrailingFlow.rows(widths: [300, 50], available: 210, spacing: 4) == [[0], [1]])
        // Everything fits: one line.
        #expect(TrailingFlow.rows(widths: [50, 50, 50], available: 210, spacing: 4) == [[0, 1, 2]])
        // Nothing: no lines.
        #expect(TrailingFlow.rows(widths: [], available: 210, spacing: 4).isEmpty)
    }

    /// The door (the last item) alone on a new line pulls the last card
    /// down with it; a line that would be left empty keeps its one item.
    @Test func aKeepWithPreviousItemNeverStartsALineAlone() {
        // Five cards fill line 1 exactly; the door (index 5) wrapped alone.
        let wrapped: [[Int]] = [[0, 1, 2, 3, 4], [5]]
        #expect(TrailingFlow.keepingTogether(wrapped, keepWithPrevious: [5]) == [[0, 1, 2, 3], [4, 5]])
        // The door already shares its line: untouched.
        let together: [[Int]] = [[0, 1, 2], [3, 4, 5]]
        #expect(TrailingFlow.keepingTogether(together, keepWithPrevious: [5]) == together)
        // The previous line holds ONE item: it keeps it (a line is never emptied).
        let lone: [[Int]] = [[0], [1]]
        #expect(TrailingFlow.keepingTogether(lone, keepWithPrevious: [1]) == lone)
        // No keep-with-previous items: the rows pass through unchanged.
        #expect(TrailingFlow.keepingTogether(wrapped, keepWithPrevious: []) == wrapped)
    }
}
