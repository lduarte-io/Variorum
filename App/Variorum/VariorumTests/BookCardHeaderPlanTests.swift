//
//  BookCardHeaderPlanTests.swift
//  VariorumTests
//
//  **VX-1038 (T-1) — where a book card header's pills go**, as a pure plan:
//  the round-2 mockup's frame 1 — two pills beside a short title (1a); many
//  pills wrapping inside the trailing area (1b); a title that fills the line
//  putting them on their own row (1c); a tagless note's "+" alone (1d); the
//  switch hidden — the title has the line. A FEATURE, so these are layout
//  pins, not red-on-old. Pure (no model, no store), so they also run headless
//  against `BookCardHeaderLine.swift` alone.
//

import CoreGraphics
import Foundation
import Testing
@testable import Variorum

@Suite("VX-1038 — the card header's pills, placed (T-1)")
struct BookCardHeaderPlanTests {
    // MARK: - T-1's plan (pure)

    private func arrange(
        width: CGFloat = 600, lead: CGFloat, trailing: CGFloat = 50, pills: [CGFloat]
    ) -> BookCardHeaderPlan.Arrangement {
        BookCardHeaderPlan.arrange(
            width: width, leadIdeal: lead, trailing: trailing, pills: pills,
            gap: 8, spacing: 4, ownRowIndent: 18)
    }

    @Test func withTheSwitchHiddenTheTitleHasTheLine() {
        #expect(arrange(lead: 200, pills: []) == .titleOnly)
    }

    @Test func aShortTitleKeepsItsPillsOnItsLineAtTheTrailingSide() {
        // frame 1a: a short title, two pills and the "+".
        #expect(arrange(lead: 150, pills: [60, 50, 14])
                == .besideTitle(area: 60 + 50 + 14 + 8, rows: [[0, 1, 2]]))
    }

    @Test func aTagLessNoteShowsThePlusAlone() {
        // frame 1d: the "+" alone, beside the title.
        #expect(arrange(lead: 150, pills: [14]) == .besideTitle(area: 14, rows: [[0]]))
    }

    @Test func manyPillsWrapInsideTheTrailingArea() {
        // frame 1b: the title keeps its place; the pills wrap in what is left.
        // width 600 − (50 + 8) = 542 available; the title 250 → area 284.
        let pills: [CGFloat] = [80, 60, 70, 75, 65, 60, 70, 14]
        guard case .besideTitle(let area, let rows) = arrange(lead: 250, pills: pills) else {
            Issue.record("the pills should stay beside the title"); return
        }
        #expect(area == CGFloat(542 - 250 - 8), "the line less the door, the title and the gap")
        #expect(rows.count > 1, "they wrap")
        #expect(rows.flatMap { $0 } == Array(pills.indices), "every pill, in order, once")
        #expect(rows.last?.last == pills.count - 1, "the + ends the last row")
        #expect((rows.last?.count ?? 0) >= 2, "…and never stands on a row alone (the masthead's orphan rule)")
    }

    @Test func aTitleThatFillsTheLinePutsThePillsOnTheirOwnRow() {
        // frame 1c: the title would leave less than the area's floor.
        #expect(arrange(lead: 520, pills: [60, 50, 14]) == .ownRow(rows: [[0, 1, 2]]))
    }

    @Test func theAreasFloorKeepsAOnePillColumnFromHappening() {
        // 542 available: a title leaving 140 for six pills (single 333) is
        // under the floor (a third of the line, 180.7) — own row, not a column.
        let pills: [CGFloat] = [50, 50, 50, 50, 50, 58]
        if case .ownRow = arrange(lead: 400, pills: pills) {} else {
            Issue.record("a long title with many pills takes the own row")
        }
        // …while the same pills beside a title leaving 290 wrap beside it.
        if case .besideTitle = arrange(lead: 250, pills: pills) {} else {
            Issue.record("room past the floor keeps them beside the title")
        }
    }

    @Test func theOpenHeaderWithNoTrailingDoorUsesTheWholeLine() {
        #expect(arrange(lead: 300, trailing: 0, pills: [100, 100, 14])
                == .besideTitle(area: 222, rows: [[0, 1, 2]]))
    }
}
