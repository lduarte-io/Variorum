//
//  OpenListDragTests.swift
//  VariorumTests
//
//  **VX-288 — the Open list's drag, the light version (the VX-283 run, U2).**
//  Her words (2026-10-13): *"the dragging between open notes in there needs to
//  be smoother - it should be as smooth as the editor drag with a nice little
//  line showing as you hover and a nice fit / snap into place because right now
//  it feels janky to use."* Her ruling on the shape: the light version first.
//
//  The traced bug under the jank (the U2 record): every drop landed in the gap
//  BEFORE the row under the pointer, whatever half of it the pointer was on — so
//  the row just below was unreachable, every downward drop landed one row short,
//  and the slot after the last row could not be reached.
//
//  Red-on-old, stated: these pins run against `SidebarLayout.OpenListDrop`; the
//  behavioural revert R-K puts the old rule back into `gap(at:)` (the row under
//  the pointer, no end slot) and the pins that name it go red. The rows' own
//  move arithmetic (`OpenNotes.move`) is unchanged and keeps its own pins
//  (`WorkspaceNavigationTests`).
//

import Foundation
import SwiftUI
import Testing
@testable import Variorum

private typealias Drop = SidebarLayout.OpenListDrop

/// Drops `dragged` at a pointer `y` over `ids` (rows `rowHeight` tall) the way
/// the list's drop does — the gap the pointer names, the destination it means —
/// and returns the order after (unchanged where the drop would change nothing).
private func dropping(_ dragged: String, atY y: CGFloat, in ids: [String], rowHeight: CGFloat = 30) -> [String] {
    var open = OpenNotes()
    for id in ids { open.opened(id) }
    guard let from = ids.firstIndex(of: dragged),
          let gap = Drop.gap(at: y, rowHeight: rowHeight, rows: ids.count),
          let to = Drop.destination(gap: gap, dragged: from, rows: ids.count)
    else { return open.ids }
    open.move(fromOffsets: IndexSet(integer: from), toOffset: to)
    return open.ids
}

@Suite("VX-288 — the Open list's drop lands where it looks (the pure rule)")
struct OpenListDropRuleTests {
    private let rows = ["a", "b", "c", "d"]

    /// The half of the row decides: the lower half is the gap after it, the
    /// upper half the gap before it; above the rows the first gap, below them
    /// the end.
    @Test func theHalfOfTheRowUnderThePointerNamesTheGap() {
        #expect(Drop.gap(at: 10, rowHeight: 30, rows: 4) == 0, "a's upper half: before a")
        #expect(Drop.gap(at: 15, rowHeight: 30, rows: 4) == 1, "a's midpoint counts as lower: after a")
        #expect(Drop.gap(at: 44, rowHeight: 30, rows: 4) == 1, "b's upper half: before b")
        #expect(Drop.gap(at: 46, rowHeight: 30, rows: 4) == 2, "b's lower half: after b")
        #expect(Drop.gap(at: 119, rowHeight: 30, rows: 4) == 4, "d's lower half: the end")
        #expect(Drop.gap(at: 500, rowHeight: 30, rows: 4) == 4, "below the rows: the end")
        #expect(Drop.gap(at: -5, rowHeight: 30, rows: 4) == 0, "above the rows: the first gap")
        #expect(Drop.gap(at: 30, rowHeight: 24, rows: 4) == 1, "the compact pitch reads its own halves")
        #expect(Drop.gap(at: 10, rowHeight: 0, rows: 4) == nil, "nothing laid out: no gap")
        #expect(Drop.gap(at: 10, rowHeight: 30, rows: 0) == nil, "no rows: no gap")
    }

    /// **RED ON OLD (R-K).** A drop on the lower half of the row just below
    /// lands the dragged row after it — the old rule's drop there changed
    /// nothing (`move([0], toOffset: 1)`).
    @Test func theRowJustBelowIsReachable() {
        #expect(dropping("a", atY: 50, in: rows) == ["b", "a", "c", "d"],
                "a dropped on b's lower half lands after b")
    }

    /// **RED ON OLD (R-K).** A long downward drop lands where it looks — on
    /// d's lower half, after d — never one row short (the old [b, c, a, d]).
    @Test func aDownwardDropNoLongerLandsOneRowShort() {
        #expect(dropping("a", atY: 105, in: rows) == ["b", "c", "d", "a"], "after d")
        #expect(dropping("a", atY: 80, in: rows) == ["b", "c", "a", "d"], "c's lower half: after c")
        #expect(dropping("b", atY: 110, in: rows) == ["a", "c", "d", "b"], "d's lower half: after d")
        #expect(dropping("b", atY: 100, in: rows) == ["a", "c", "b", "d"], "d's upper half: before d")
    }

    /// **RED ON OLD (R-K).** The slot after the last row is reachable — below
    /// the rows (the end zone's road) and on the last row's lower half.
    @Test func theLastSlotIsReachable() {
        #expect(dropping("b", atY: 125, in: rows) == ["a", "c", "d", "b"], "below the rows")
        #expect(Drop.gap(for: .end, offset: 0, rowHeight: 30, rows: 4) == 4, "the end zone names the end")
        #expect(Drop.destination(gap: 4, dragged: 1, rows: 4) == 4)
    }

    /// An upward drop lands before the row on its upper half and after it on
    /// its lower half (the old rule had the upper half right — exact behaviour).
    @Test func anUpwardDropLandsWhereItLooks() {
        #expect(dropping("d", atY: 35, in: rows) == ["a", "d", "b", "c"], "b's upper half: before b")
        #expect(dropping("d", atY: 50, in: rows) == ["a", "b", "d", "c"], "b's lower half: after b")
        #expect(dropping("d", atY: 2, in: rows) == ["d", "a", "b", "c"], "the top")
    }

    /// §12's false-offer rule: the dragged row's own two gaps would change
    /// nothing — no destination there (so no line, and no drop); every other
    /// gap moves it.
    @Test func theDraggedRowsOwnGapsOfferNothing() {
        for dragged in 0..<4 {
            for gap in 0...4 {
                let own = gap == dragged || gap == dragged + 1
                #expect((Drop.destination(gap: gap, dragged: dragged, rows: 4) == nil) == own,
                        "row \(dragged) at gap \(gap)")
            }
        }
        #expect(Drop.destination(gap: 5, dragged: 0, rows: 4) == nil, "off the list")
        #expect(Drop.destination(gap: 0, dragged: 4, rows: 4) == nil, "a row that is not there")
        #expect(dropping("b", atY: 40, in: rows) == rows, "its own upper half: nothing moves")
        #expect(dropping("b", atY: 65, in: rows) == rows, "c's upper half = b's own lower gap")
    }

    /// **"Drops land where they look", exhaustively** — every list of 1…6 rows,
    /// every dragged row, every target row and both its halves at several
    /// depths: after the drop the dragged row sits right AFTER the target (its
    /// lower half) or right BEFORE it (its upper half); on its own row nothing
    /// moves. RED ON OLD (R-K) — every lower-half drop.
    @Test func everyDropLandsBesideTheRowUnderThePointer() {
        for count in 1...6 {
            let ids = (0..<count).map { "r\($0)" }
            for dragged in ids {
                for (row, target) in ids.enumerated() {
                    for fraction in [0.05, 0.3, 0.49, 0.5, 0.7, 0.95] {
                        let y = (CGFloat(row) + CGFloat(fraction)) * 30
                        let after = dropping(dragged, atY: y, in: ids)
                        #expect(Set(after) == Set(ids) && after.count == ids.count, "rows survive")
                        guard target != dragged else {
                            #expect(after == ids, "on its own row nothing moves")
                            continue
                        }
                        let movedTo = after.firstIndex(of: dragged)!
                        let targetAt = after.firstIndex(of: target)!
                        if fraction >= 0.5 {
                            #expect(movedTo == targetAt + 1,
                                    "\(dragged) on \(target)'s lower half (\(count) rows): \(after)")
                        } else {
                            #expect(movedTo == targetAt - 1,
                                    "\(dragged) on \(target)'s upper half (\(count) rows): \(after)")
                        }
                    }
                }
            }
        }
    }

    // MARK: - The line (the overlay/sink delivery law: hover, scroll, list change)

    private func window(offset: CGFloat = 0, viewport: CGFloat = 120, content: CGFloat = 120)
        -> SidebarLayout.ScrollWindow {
        SidebarLayout.ScrollWindow(offset: offset, viewport: viewport, content: content)
    }

    /// The line sits centred on the boundary the hover names, in the viewport.
    @Test func theLineSitsOnTheBoundaryTheHoverNames() {
        let w = window()
        #expect(Drop.lineTop(hover: .rows(viewportY: 50), dragged: 3, rows: 4, rowHeight: 30, window: w) == 59,
                "b's lower half: the b/c boundary at 60, the 2-pt line from 59")
        #expect(Drop.lineTop(hover: .rows(viewportY: 35), dragged: 3, rows: 4, rowHeight: 30, window: w) == 29)
        #expect(Drop.lineTop(hover: .rows(viewportY: 2), dragged: 3, rows: 4, rowHeight: 30, window: w) == 0,
                "the first gap is held inside the rows, never half off the top")
        #expect(Drop.lineTop(hover: .end, dragged: 0, rows: 4, rowHeight: 30, window: w) == 118,
                "the end is held inside the rows, never half off the bottom")
        #expect(Drop.lineTop(hover: .rows(viewportY: 110), dragged: 0, rows: 4, rowHeight: 30, window: w) == 118,
                "the last row's lower half draws the same end line")
    }

    /// Hover axis: the pointer moves, the line moves with the gap it names.
    @Test func theLineFollowsTheHover() {
        let w = window()
        let tops = [10, 25, 40, 55, 70, 85, 100].map {
            Drop.lineTop(hover: .rows(viewportY: CGFloat($0)), dragged: 0, rows: 4, rowHeight: 30, window: w)
        }
        #expect(tops == [nil, nil, nil, 59, 59, 89, 89],
                "a's own gaps (0, 1) and b's upper half (= 1) offer nothing; then 2, 2, 3, 3")
    }

    /// Scroll axis: a scroll under a STILL pointer moves the gap it names —
    /// the line follows the rows, read against the offset as it now stands.
    @Test func theLineFollowsAScrollUnderAStillPointer() {
        let still = Drop.Hover.rows(viewportY: 50)
        func top(_ offset: CGFloat) -> CGFloat? {
            Drop.lineTop(hover: still, dragged: 9, rows: 10, rowHeight: 30,
                         window: window(offset: offset, viewport: 120, content: 300))
        }
        #expect(top(0) == 59, "content 50: b's lower half — the boundary at 60")
        #expect(top(20) == 39, "content 70: c's upper half — the same boundary, 20 pt higher on screen")
        #expect(top(30) == 59, "content 80: c's lower half — the next boundary (90) at 60 on screen")
        #expect(top(90) == 59, "content 140: e's lower half — the boundary at 150")
    }

    /// List-change axis: the rows, the pitch and the dragged row's place are
    /// inputs too — a row closing above the dragged one moves its no-offer
    /// gaps; the pitch flipping 30 → 24 re-reads the halves.
    @Test func theLineFollowsAChangeOfTheList() {
        let w = window(viewport: 120, content: 120)
        let hover = Drop.Hover.rows(viewportY: 50)
        #expect(Drop.lineTop(hover: hover, dragged: 2, rows: 4, rowHeight: 30, window: w) == nil,
                "gap 2 is row 2's own")
        #expect(Drop.lineTop(hover: hover, dragged: 1, rows: 3, rowHeight: 30, window: w) == nil,
                "a row above it closed: the dragged row is row 1 now, and gap 2 is still its own")
        #expect(Drop.lineTop(hover: hover, dragged: 3, rows: 4, rowHeight: 30, window: w) == 59)
        #expect(Drop.lineTop(hover: hover, dragged: 3, rows: 4, rowHeight: 24,
                             window: window(viewport: 96, content: 96)) == 47,
                "at 24 pt the pointer is on c's upper half: the b/c boundary at 48")
    }

    /// Never computed before layout exists: no reading, no pitch, no rows, no
    /// drag of this list's — no line.
    @Test func noLineBeforeTheListIsReadOrWithoutADragOfItsOwn() {
        let hover = Drop.Hover.rows(viewportY: 50)
        #expect(Drop.lineTop(hover: hover, dragged: 3, rows: 4, rowHeight: 30, window: .unmeasured) == nil)
        #expect(Drop.lineTop(hover: hover, dragged: 3, rows: 4, rowHeight: 0, window: window()) == nil)
        #expect(Drop.lineTop(hover: hover, dragged: 0, rows: 0, rowHeight: 30, window: window()) == nil)
        #expect(Drop.lineTop(hover: hover, dragged: nil, rows: 4, rowHeight: 30, window: window()) == nil,
                "a drag that did not begin in this list draws nothing")
        #expect(Drop.lineTop(hover: nil, dragged: 3, rows: 4, rowHeight: 30, window: window()) == nil)
    }

    /// A boundary half a row past a scrolled edge shows AT that edge — the
    /// line never draws outside the window.
    @Test func theLineStaysInsideTheWindow() {
        // The pointer at the very top of a window scrolled to 40: content 42 —
        // b's upper half, whose boundary (30) is 10 pt above the window.
        #expect(Drop.lineTop(hover: .rows(viewportY: 2), dragged: 9, rows: 10, rowHeight: 30,
                             window: window(offset: 40, viewport: 120, content: 300)) == 0)
        // …and at the very bottom of one scrolled to 50: content 169 — f's
        // lower half, whose boundary (180) is 10 pt below the window.
        #expect(Drop.lineTop(hover: .rows(viewportY: 119), dragged: 0, rows: 10, rowHeight: 30,
                             window: window(offset: 50, viewport: 120, content: 300)) == 118)
    }

    // MARK: - The end zone

    /// The room the list leaves under its rows, capped at 28 pt (the book
    /// navigator's end zone); none when the rows fill the list, or before the
    /// column is measured.
    @Test func theEndZoneIsTheRoomUnderTheRowsCapped() {
        func zone(_ rows: Int, visible: CGFloat = 800, top: CGFloat = 300) -> CGFloat {
            Drop.endZoneHeight(visibleHeight: visible, listTop: top, bottomPadding: 12, rows: rows, rowHeight: 30)
        }
        #expect(zone(5) == 28, "plenty of room: the whole zone")
        #expect(zone(16) == 8, "488 − 480: the room that is there, no more")
        #expect(zone(17) == 0, "the rows fill the list: no zone (the last row's lower half is the end)")
        #expect(zone(5, visible: 0) == 0, "unmeasured")
        #expect(zone(5, top: 0) == 0, "unmeasured")
        #expect(zone(0) == 0, "no rows")
        #expect(Drop.endZoneMaxHeight == 28 && Drop.lineThickness == 2, "the book navigator's numbers")
    }
}
