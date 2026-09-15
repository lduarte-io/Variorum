//
//  DebugOracleScopingTests.swift
//  VariorumTests
//
//  13u2 UNIT E — **the DEBUG geometry oracles' scoping, as arithmetic**
//  (`KnownIssuesAndTechDebt` row 50).
//
//  The defect the sweep closed cannot be reproduced by a test, and saying so
//  is more honest than pretending otherwise: it is two SUITES running at once
//  and writing into one static, which a pin inside one suite cannot stage. So
//  the pins below assert the CONSTRUCTION instead — that two scopes are two
//  worlds, and that a reader never sees a writer it does not own. That is the
//  property "a cross-suite bleed can no longer occur" reduces to, and it is
//  checkable in one turn with no mount at all.
//
//  There is no red-on-old here and there could not be: before the sweep these
//  oracles had no scope to give, so the claim could not be written down. The
//  evidence that the sweep changed no behaviour is the other kind — the
//  eighteen suites that read these six oracles riding green with their
//  assertions unmodified.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

#if DEBUG
@MainActor
@Suite("Two scopes are two worlds (13u2 UNIT E — KnownIssues row 50)")
struct DebugOracleScopingTests {
    private func rect(_ x: CGFloat) -> CGRect { CGRect(x: x, y: 0, width: 10, height: 10) }

    /// The masthead: the biggest of the six, and the one whose per-subject
    /// keys (tag cards, per-note stamps) ride UNDER the scope rather than
    /// beside it — so the pin checks both layers.
    @Test func theMastheadsRectanglesBelongToTheirOwnMount() {
        let mine = MastheadGeometry.reader("scope-A")
        let theirs = MastheadGeometry.reader("scope-B")
        mine.resetRowTwo(); mine.resetTitleRow()
        theirs.resetRowTwo(); theirs.resetTitleRow()

        MastheadGeometry.record(.pathChip, rect(1), in: "scope-A")
        MastheadGeometry.record(.card("tag-1"), rect(2), in: "scope-A")
        MastheadGeometry.record(.stamp("note-1"), rect(3), in: "scope-A")
        MastheadGeometry.recordTitle(rect(4), in: "scope-A")

        #expect(mine.pathChipFrame == rect(1))
        #expect(mine.cardFrames["tag-1"] == rect(2))
        #expect(mine.stampFrames["note-1"] == rect(3))
        #expect(mine.titleFrame == rect(4))

        // The same SUBJECT ids — which `.incrementing` uuids make identical
        // in every test world at once — and the other mount sees nothing.
        #expect(theirs.pathChipFrame == nil)
        #expect(theirs.cardFrames["tag-1"] == nil)
        #expect(theirs.stampFrames["note-1"] == nil)
        #expect(theirs.titleFrame == nil)

        // …and a reset clears ITS OWN scope and no other (the whole-oracle
        // wipe the 18d ladder's MINOR-2 removed from the note box's statics).
        theirs.resetRowTwo()
        theirs.resetTitleRow()
        #expect(mine.pathChipFrame == rect(1), "another mount's reset is not ours")
        #expect(mine.titleFrame == rect(4))
        mine.resetRowTwo(); mine.resetTitleRow()
    }

    /// Row 59's report count is per scope too — otherwise one suite's layout
    /// storm would keep another's quiescence clause from ever settling.
    @Test func theMastheadsReportCountIsPerMountAsWell() {
        let mine = MastheadGeometry.reader("scope-C")
        let theirs = MastheadGeometry.reader("scope-D")
        mine.resetRowTwo(); theirs.resetRowTwo()
        let before = theirs.reports
        MastheadGeometry.record(.pathChip, rect(1), in: "scope-C")
        MastheadGeometry.record(.card("t"), rect(2), in: "scope-C")
        #expect(mine.reports >= 2)
        #expect(theirs.reports == before, "a neighbour's layout never moves our settle")
        mine.resetRowTwo()
    }

    @Test func theCompareAndLensesBoardsBelongToTheirOwnMount() {
        let mineC = CompareGeometry.reader("scope-A")
        let theirsC = CompareGeometry.reader("scope-B")
        mineC.reset(); theirsC.reset()
        CompareGeometry.record(.board, rect(1), in: "scope-A")
        #expect(mineC.frames[.board] == rect(1))
        #expect(theirsC.frames[.board] == nil)
        mineC.reset()

        let mineL = LensesGeometry.reader("scope-A")
        let theirsL = LensesGeometry.reader("scope-B")
        mineL.reset(); theirsL.reset()
        LensesGeometry.record(.firstCell, rect(1), in: "scope-A")
        #expect(mineL.frames[.firstCell] == rect(1))
        #expect(theirsL.frames[.firstCell] == nil)
        mineL.reset()
    }

    /// The take card's list is scoped AND BOUNDED (row 47's second
    /// oracle-hygiene item: it was append-only and grew for a DEBUG
    /// process's whole life).
    @Test func theTakeCardsReportsBelongToTheirOwnBoardAndCannotGrowForever() {
        let mine = TakeCardGeometry.reader("scope-A")
        let theirs = TakeCardGeometry.reader("scope-B")
        mine.reset(); theirs.reset()

        TakeCardGeometry.record(.card, rect(1), in: "scope-A")
        #expect(mine.tallest(.card) != nil)
        #expect(theirs.tallest(.card) == nil, "another board's cards are not ours")

        for i in 0..<(TakeCardGeometry.reportLimit + 50) {
            TakeCardGeometry.record(.card, rect(CGFloat(i)), in: "scope-A")
        }
        #expect(mine.reports.count == TakeCardGeometry.reportLimit,
                "bounded: \(mine.reports.count) of \(TakeCardGeometry.reportLimit)")
        #expect(mine.latest(.card) == rect(CGFloat(TakeCardGeometry.reportLimit + 49)),
                "…and it is the OLDEST that goes, so the current board is what answers")
        mine.reset()
        #expect(mine.reports.isEmpty)
    }

    @Test func theWorkbenchBelongsToItsOwnMount() {
        let mine = BlocksWorkbenchOracle.reader("scope-A")
        let theirs = BlocksWorkbenchOracle.reader("scope-B")
        mine.reset(); theirs.reset()

        BlocksWorkbenchOracle.recordFocus("block-1", in: "scope-A")
        BlocksWorkbenchOracle.recordPanel(true, in: "scope-A")
        BlocksWorkbenchOracle.recordRow("block-1", rect(1), in: "scope-A")

        #expect(mine.focusedBlockID == "block-1")
        #expect(mine.panelMounted)
        #expect(mine.rowFrames["block-1"] == rect(1))
        #expect(mine.firstRowPaintedAt != nil)

        #expect(theirs.focusedBlockID == nil)
        #expect(theirs.panelMounted == false, "a neighbour's open panel is not ours")
        #expect(theirs.rowFrames["block-1"] == nil)
        #expect(theirs.firstRowPaintedAt == nil)
        mine.reset()
    }

    /// The sidebar's HEADER oracles — the four `SidebarGeometry` fields keyed
    /// by a TITLE every window shares (`"this note"`, the Open header), which
    /// is why a scope above the title was the only thing that could separate
    /// them.
    @Test func theSidebarsHeaderFramesBelongToTheirOwnColumn() {
        let mine = SidebarGeometry.headers("scope-A")
        let theirs = SidebarGeometry.headers("scope-B")
        mine.resetHeaders(); theirs.resetHeaders()

        SidebarGeometry.recordHeaderText("this note", rect(1), in: "scope-A")
        SidebarGeometry.recordFirstRowContent("this note", rect(2), in: "scope-A")
        SidebarGeometry.recordFirstRowBox("this note", rect(3), in: "scope-A")
        SidebarGeometry.recordOpenRowHeight(24, in: "scope-A")

        #expect(mine.headerTextFrames["this note"] == rect(1))
        #expect(mine.firstRowContentFrames["this note"] == rect(2))
        #expect(mine.firstRowBoxFrames["this note"] == rect(3))
        #expect(mine.openRowHeight == 24)

        #expect(theirs.headerTextFrames["this note"] == nil)
        #expect(theirs.firstRowContentFrames["this note"] == nil)
        #expect(theirs.firstRowBoxFrames["this note"] == nil)
        #expect(theirs.openRowHeight == nil)

        // The wipe that used to reach every column reaches one now.
        theirs.resetHeaders()
        #expect(mine.headerTextFrames["this note"] == rect(1),
                "another column's reset is not ours — the class the 18d ladder named")
        mine.resetHeaders()
    }

    /// Two live sessions name two scopes — the property the whole sweep rests
    /// on, since a pin reads `session.debugProbeScope` and a concurrent suite
    /// has a session of its own.
    @Test func twoLiveSessionsNameTwoScopes() async throws {
        let one = try AppDatabase.inMemory()
        let two = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = one
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let a = AppSession(database: one)
            let b = AppSession(database: two)
            #expect(a.debugProbeScope != b.debugProbeScope)
            #expect(a.debugProbeScope == a.debugProbeScope,
                    "and it is stable for a session's life")
        }
    }
}
#endif
