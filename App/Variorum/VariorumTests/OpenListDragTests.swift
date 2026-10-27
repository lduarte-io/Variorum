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
//  The traced jank (the U2 record): main's road — each row its own drop, every
//  drop landing in the gap BEFORE the row it was released on — showed nothing
//  while she dragged, moved without a settle, and had no slot after the last
//  row at all.
//
//  **U2d — the orchestrator's P-U2d-1: F2, the book navigator's road on MAIN's
//  own per-row API.** No synthetic road reaches a drop in the sidebar, on main
//  too (the U2c main-build control), so the drop stays on the API her hands
//  have used — each Open row a classic `dropDestination(for:action:isTargeted:)`
//  — and gains what she asked for: the TARGETED row draws the 2-pt line at its
//  top and the drop lands before it (main's own landing) with the settle; the
//  end zone takes the last slot; the dragged row's own place (its own row and
//  the row right after it) draws no line and moves nothing. The half-row
//  refinement, the macOS 26 session form and the move configuration are gone,
//  and so are their pins — each named in the record's "### U2d — the build"
//  ("retired by P-U2d-1"): `theHalfOfTheRowUnderThePointerNamesTheGap`,
//  `theRowJustBelowIsReachable`, `aDownwardDropNoLongerLandsOneRowShort`,
//  `theLastSlotIsReachable`, `anUpwardDropLandsWhereItLooks`,
//  `everyDropLandsBesideTheRowUnderThePointer`,
//  `aRowsOwnLocationNamesTheGapForEveryRowAndBothHalves`,
//  `theLineSitsOnTheBoundaryTheHoverNames`, `theLineFollowsTheHover`,
//  `theLineFollowsAScrollUnderAStillPointer`,
//  `aScrollUnderAStillPointerMovesTheGap`,
//  `aRowsOwnLocationDrawsTheLineAndLandsThere`,
//  `movingBetweenRowsNeverBlanksTheHover`,
//  `eachRowIsATransferableDropAndItsSourceAllowsTheMove`.
//
//  The pins, each red-on-old by its own named revert (the record): (a) the
//  wiring, read — R-W; (b) the pure rule, the targeted row → the line and the
//  gap, the own place, the end zone — R-X; (c) the state and the door — an
//  un-target clears only the target it set (R-Y), the source session's end
//  clears the drag (R-Z), the action lands before the targeted row with the
//  settle (R-X); and P-U2d-2's end zone, which takes the column's bottom padding
//  so it is never absent — R-Q. Delivery itself — that AppKit offers a real drag
//  to the rows — has no headless pin and no synthetic road: her hand proves it.
//
//  **VX-424 (the VX-439 run, A-439-15) — the HALF ROW, back on main's road.** Her
//  report: the drag "lifts a card … and the drop does nothing", down AND up. The
//  traced mechanism (the run record's instrument over this very rule): a row
//  named only the slot BEFORE it, so dragging DOWN by one place could never land
//  (the row below named the dragged row's own lower gap) and every up-drag landed
//  on the hovered row's top whichever half the pointer was in. Each row now has
//  TWO targets (`OpenListRowHalves`, each a classic `dropDestination(…isTargeted:)`
//  — the half IS the target, no hover location needed): its upper half names the
//  slot before it, its lower half the slot after it; one boundary's two halves
//  name one slot (no line flicker). EDITED IN PLACE, deliberately (each annotated
//  "VX-424"): every pin that named a target `.row(i)` now names `.before(i)` —
//  the same slot, so those pins' meaning is unchanged — and the four pins whose
//  SUBJECT was "a row names the slot before it, whichever half" now state the two
//  halves (`aRowsUpperHalfNamesTheSlotBeforeIt…`, `everyDropLandsOnTheSideOfTheRow
//  ItsHalfNames`, `everySlotIsReachedAndOneBoundarysTwoHalvesNameOneSlot`,
//  `theLineSitsOnTheBoundaryTheHalfNames`). NEW, red on old by the named revert
//  R-H (`gap(for: .after(i))` → `i`, the pre-VX-424 rule exactly: a row's either
//  half names the slot before it): `aDownByOneDropLands`,
//  `anUpwardDropLandsOnTheHalfItIsReleasedOn`, `oneBoundarysTwoHalvesDrawOneLine`,
//  and the door's `aDownByOneReleaseLandsWhereTheLineWas` /
//  `anUpDragReleasedOnARowsLowerHalfLandsJustBelowIt`; the face pin
//  `eachRowsTwoHalvesAreDropsOnMainsRoadLiveOnlyWhileItsDragIsInFlight` (revert
//  R-O: the overlay removed); the mount pins `theRowsTwoHalvesSplitItAtItsMidline
//  AndReachTheListsEdges` (R-O) and the guard `atRestTheHalvesTakeNoClickSoTheRows
//  DoorsAct` (revert R-G: the halves always hit-testable — they would eat the ✕).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private typealias Drop = SidebarLayout.OpenListDrop

/// Drops `dragged` onto `hover` — a row (by its index) or the end zone — over
/// `ids` the way the list's drop does: the gap the target names, the
/// destination it means. Returns the order after (unchanged where the drop
/// would change nothing).
private func dropping(_ dragged: String, onto hover: Drop.Hover, in ids: [String]) -> [String] {
    var open = OpenNotes()
    for id in ids { open.opened(id) }
    guard let from = ids.firstIndex(of: dragged),
          let gap = Drop.gap(for: hover, rows: ids.count),
          let to = Drop.destination(gap: gap, dragged: from, rows: ids.count)
    else { return open.ids }
    open.move(fromOffsets: IndexSet(integer: from), toOffset: to)
    return open.ids
}

@Suite("VX-288 — the Open list's drop lands where it looks (the pure rule)")
struct OpenListDropRuleTests {
    private let rows = ["a", "b", "c", "d"]

    /// **P-U2d-1 (b) → VX-424 — RED ON OLD (R-H).** A row's UPPER half names
    /// the slot BEFORE it — its own index; its LOWER half the slot AFTER it —
    /// the next index; the end zone names the slot after the last row; a row
    /// off the list, or a list with no rows, names nothing.
    ///
    /// **VX-424 — edited in place** (was `theTargetedRowNamesTheSlotBeforeIt
    /// AndTheEndZoneTheLast`, whose one target per row named the slot before
    /// it whichever half the pointer was in — the traced mechanism).
    @Test func aRowsUpperHalfNamesTheSlotBeforeItItsLowerHalfTheSlotAfterAndTheEndZoneTheLast() {
        for count in 1...8 {
            for row in 0..<count {
                #expect(Drop.gap(for: .before(row), rows: count) == row, "row \(row) of \(count), upper half: the slot before it")
                #expect(Drop.gap(for: .after(row), rows: count) == row + 1, "row \(row) of \(count), lower half: the slot after it")
            }
            #expect(Drop.gap(for: .before(count), rows: count) == nil, "a row past the list names nothing")
            #expect(Drop.gap(for: .after(count), rows: count) == nil, "a row past the list names nothing")
            #expect(Drop.gap(for: .before(-1), rows: count) == nil, "a row before the list names nothing")
            #expect(Drop.gap(for: .after(-1), rows: count) == nil, "a row before the list names nothing")
            #expect(Drop.gap(for: .end, rows: count) == count, "the end zone: the slot after the last row")
        }
        #expect(Drop.gap(for: .before(0), rows: 0) == nil, "no rows: no slot")
        #expect(Drop.gap(for: .after(0), rows: 0) == nil, "no rows: no slot")
        #expect(Drop.gap(for: .end, rows: 0) == nil, "no rows: no end")
    }

    /// **VX-424 — DOWN BY ONE — RED ON OLD (R-H).** Her "nothing reorders":
    /// row a released on the LOWER half of the row right below it (b) lands
    /// just below b — the one move the old rule could never make (b named a's
    /// own lower gap, so the chip slid back) — for every row of every list.
    @Test func aDownByOneDropLands() {
        #expect(dropping("a", onto: .after(1), in: rows) == ["b", "a", "c", "d"], "a below b")
        #expect(dropping("c", onto: .after(3), in: rows) == ["a", "b", "d", "c"], "c below d — the last slot")
        for count in 2...6 {
            let ids = (0..<count).map { "r\($0)" }
            for from in 0..<(count - 1) {
                let after = dropping(ids[from], onto: .after(from + 1), in: ids)
                #expect(after.firstIndex(of: ids[from]) == from + 1 && after[from] == ids[from + 1],
                        "\(ids[from]) one place down (\(count) rows): \(after)")
            }
        }
    }

    /// **VX-424 — AN UPWARD DRAG — RED ON OLD (R-H).** Her "it happens trying
    /// to move it up as well": an up-drag released on a row's LOWER half lands
    /// just BELOW that row — where the line is — never above it (the old rule
    /// landed it on the hovered row's top whichever half: one place too high);
    /// and released on a row's UPPER half it lands just above it. For every row
    /// of every list.
    @Test func anUpwardDropLandsOnTheHalfItIsReleasedOn() {
        #expect(dropping("d", onto: .after(1), in: rows) == ["a", "b", "d", "c"], "d up to just below b")
        #expect(dropping("d", onto: .before(2), in: rows) == ["a", "b", "d", "c"], "the same slot, from c's upper half")
        #expect(dropping("d", onto: .before(1), in: rows) == ["a", "d", "b", "c"], "d up to just above b")
        #expect(dropping("d", onto: .after(0), in: rows) == ["a", "d", "b", "c"], "the same slot, from a's lower half")
        #expect(dropping("d", onto: .before(0), in: rows) == ["d", "a", "b", "c"], "the top")
        for count in 3...6 {
            let ids = (0..<count).map { "r\($0)" }
            for from in 2..<count {
                for row in 0..<(from - 1) {
                    let below = dropping(ids[from], onto: .after(row), in: ids)
                    #expect(below.firstIndex(of: ids[from]) == row + 1 && below[row] == ids[row],
                            "\(ids[from]) up onto \(ids[row])'s lower half (\(count) rows) lands just below it: \(below)")
                }
            }
        }
    }

    /// **P-U2d-1 (b), exhaustively → VX-424 — RED ON OLD (R-H).** Every list
    /// of 1…6 rows, every dragged row, every half of every row: a drop on
    /// another row's UPPER half lands the dragged row right BEFORE it, on its
    /// LOWER half right AFTER it; a drop in the end zone lands it last; on its
    /// own place — its own row's either half, the upper half of the row right
    /// after it, the lower half of the row right before it, and the end zone
    /// when it is already last — nothing moves.
    ///
    /// **VX-424 — edited in place** (was `everyDropLandsBeforeTheTargetedRow`).
    @Test func everyDropLandsOnTheSideOfTheRowItsHalfNames() {
        for count in 1...6 {
            let ids = (0..<count).map { "r\($0)" }
            for (from, dragged) in ids.enumerated() {
                for (row, target) in ids.enumerated() {
                    let above = dropping(dragged, onto: .before(row), in: ids)
                    #expect(Set(above) == Set(ids) && above.count == ids.count, "rows survive")
                    if row == from || row == from + 1 {
                        #expect(above == ids, "\(dragged) onto \(target)'s upper half (its own place, \(count) rows): nothing moves")
                    } else {
                        #expect(above.firstIndex(of: dragged)! == above.firstIndex(of: target)! - 1,
                                "\(dragged) onto \(target)'s upper half (\(count) rows) lands right before it: \(above)")
                    }
                    let below = dropping(dragged, onto: .after(row), in: ids)
                    #expect(Set(below) == Set(ids) && below.count == ids.count, "rows survive")
                    if row == from || row == from - 1 {
                        #expect(below == ids, "\(dragged) onto \(target)'s lower half (its own place, \(count) rows): nothing moves")
                    } else {
                        #expect(below.firstIndex(of: dragged)! == below.firstIndex(of: target)! + 1,
                                "\(dragged) onto \(target)'s lower half (\(count) rows) lands right after it: \(below)")
                    }
                }
                let atEnd = dropping(dragged, onto: .end, in: ids)
                if from == count - 1 {
                    #expect(atEnd == ids, "the last row onto the end zone: nothing moves")
                } else {
                    #expect(atEnd.last == dragged && atEnd.count == ids.count,
                            "\(dragged) onto the end zone (\(count) rows) lands last: \(atEnd)")
                }
            }
        }
    }

    /// **The ticket's slots, in the half-row's terms → VX-424 — RED ON OLD
    /// (R-H).** Every slot the dragged row can move to is reached, and by
    /// EXACTLY the targets on its boundary: the first slot by the first row's
    /// upper half; a slot between two rows by the upper row's LOWER half and
    /// the lower row's UPPER half (one boundary, one slot — the line never
    /// jumps between them); the last slot by the last row's lower half and the
    /// end zone.
    ///
    /// **VX-424 — edited in place** (was `everySlotIsReachedByExactlyOneTarget`,
    /// whose one target per slot was the row that would follow it).
    @Test func everySlotIsReachedAndOneBoundarysTwoHalvesNameOneSlot() {
        for count in 1...6 {
            for dragged in 0..<count {
                for gap in 0...count where gap != dragged && gap != dragged + 1 {
                    let targets: [Drop.Hover] = (0..<count).flatMap { [.before($0), .after($0)] } + [.end]
                    let naming = targets.filter { Drop.gap(for: $0, rows: count) == gap }
                    let boundary: [Drop.Hover] = gap == 0 ? [.before(0)]
                        : gap == count ? [.after(count - 1), .end]
                        : [.after(gap - 1), .before(gap)]
                    #expect(naming == boundary, "gap \(gap) of \(count) (row \(dragged) dragged): \(naming)")
                    #expect(Drop.destination(gap: gap, dragged: dragged, rows: count) == gap)
                }
            }
        }
        #expect(dropping("a", onto: .after(1), in: rows) == ["b", "a", "c", "d"], "just below b: b's lower half")
        #expect(dropping("a", onto: .before(2), in: rows) == ["b", "a", "c", "d"], "…or c's upper half")
        #expect(dropping("a", onto: .before(3), in: rows) == ["b", "c", "a", "d"], "released on d's top: before d")
        #expect(dropping("a", onto: .end, in: rows) == ["b", "c", "d", "a"], "the last slot: the end zone")
        #expect(dropping("a", onto: .after(3), in: rows) == ["b", "c", "d", "a"], "…or the last row's lower half")
        #expect(dropping("d", onto: .before(1), in: rows) == ["a", "d", "b", "c"], "upward: before b")
        #expect(dropping("d", onto: .before(0), in: rows) == ["d", "a", "b", "c"], "the top")
    }

    /// §12's false-offer rule: the dragged row's own two gaps would change
    /// nothing — no destination there (so no line, and no drop); every other
    /// gap moves it.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the last two lines named the
    /// half-row rule's pointer heights; they name the two own-place targets
    /// now (its own row, and the row right after it). The loop is unchanged.
    ///
    /// **VX-424 — edited in place:** the own place is FOUR halves now — its own
    /// row's both, the upper half of the row right after it, the lower half of
    /// the row right before it. The loop is unchanged.
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
        #expect(dropping("b", onto: .before(1), in: rows) == rows, "its own row's upper half: nothing moves")
        #expect(dropping("b", onto: .after(1), in: rows) == rows, "its own row's lower half: nothing moves")
        #expect(dropping("b", onto: .before(2), in: rows) == rows, "the upper half of the row right after it = b's own lower gap")
        #expect(dropping("b", onto: .after(0), in: rows) == rows, "the lower half of the row right before it = b's own upper gap")
    }

    // MARK: - The line (the overlay/sink delivery law: target, scroll, list change)

    private func window(offset: CGFloat = 0, viewport: CGFloat = 120, content: CGFloat = 120)
        -> SidebarLayout.ScrollWindow {
        SidebarLayout.ScrollWindow(offset: offset, viewport: viewport, content: content)
    }

    /// **P-U2d-1 (b) → VX-424 — RED ON OLD (R-H).** The line sits on the
    /// boundary the target names — an upper half at its row's TOP, a lower
    /// half at its row's BOTTOM — centred on that boundary, in the viewport,
    /// held inside the rows at both ends; the end zone's line at the last row's
    /// bottom; none on the dragged row's own place.
    ///
    /// **VX-424 — edited in place** (was `theLineSitsAtTheTargetedRowsTop`).
    @Test func theLineSitsOnTheBoundaryTheHalfNames() {
        let w = window()
        #expect(Drop.lineTop(hover: .before(2), dragged: 3, rows: 4, rowHeight: 30, window: w) == 59,
                "c's upper half: its top (the b/c boundary) at 60, the 2-pt line from 59")
        #expect(Drop.lineTop(hover: .after(1), dragged: 3, rows: 4, rowHeight: 30, window: w) == 59,
                "b's lower half: its bottom — the same b/c boundary, the same line")
        #expect(Drop.lineTop(hover: .before(1), dragged: 3, rows: 4, rowHeight: 30, window: w) == 29)
        #expect(Drop.lineTop(hover: .before(0), dragged: 3, rows: 4, rowHeight: 30, window: w) == 0,
                "the first row's top is held inside the rows, never half off the top")
        #expect(Drop.lineTop(hover: .after(0), dragged: 3, rows: 4, rowHeight: 30, window: w) == 29,
                "a's lower half: the a/b boundary")
        #expect(Drop.lineTop(hover: .end, dragged: 0, rows: 4, rowHeight: 30, window: w) == 118,
                "the end zone: the last row's bottom, held inside the rows")
        #expect(Drop.lineTop(hover: .after(3), dragged: 0, rows: 4, rowHeight: 30, window: w) == 118,
                "the last row's lower half: the same last boundary as the end zone")
        #expect(Drop.lineTop(hover: .before(3), dragged: 3, rows: 4, rowHeight: 30, window: w) == nil,
                "the dragged row's upper half: its own place, no line")
        #expect(Drop.lineTop(hover: .after(3), dragged: 3, rows: 4, rowHeight: 30, window: w) == nil,
                "the dragged row's lower half: its own place, no line")
        #expect(Drop.lineTop(hover: .before(0), dragged: 0, rows: 4, rowHeight: 30, window: w) == nil)
        #expect(Drop.lineTop(hover: .before(1), dragged: 0, rows: 4, rowHeight: 30, window: w) == nil,
                "the upper half of the row right after the dragged one: its own lower gap, no line")
        #expect(Drop.lineTop(hover: .after(1), dragged: 0, rows: 4, rowHeight: 30, window: w) == 59,
                "…and that row's LOWER half lights — the down-by-one slot (VX-424)")
        #expect(Drop.lineTop(hover: .after(1), dragged: 2, rows: 4, rowHeight: 30, window: w) == nil,
                "the lower half of the row right before the dragged one: its own upper gap, no line")
    }

    /// **VX-424 — NO FLICKER — RED ON OLD (R-H).** One boundary's two halves
    /// (row k's lower, row k+1's upper) draw ONE line, in every list, for every
    /// dragged row; the last row's lower half draws the end zone's — so a
    /// pointer crossing a boundary never moves the line.
    @Test func oneBoundarysTwoHalvesDrawOneLine() {
        let w = window(viewport: 240, content: 240)
        for count in 2...8 {
            for dragged in 0..<count {
                for k in 0..<(count - 1) {
                    let lower = Drop.lineTop(hover: .after(k), dragged: dragged, rows: count, rowHeight: 30, window: w)
                    let upper = Drop.lineTop(hover: .before(k + 1), dragged: dragged, rows: count, rowHeight: 30, window: w)
                    #expect(lower == upper, "the boundary under row \(k) of \(count) (row \(dragged) dragged): \(String(describing: lower)) vs \(String(describing: upper))")
                }
                #expect(Drop.lineTop(hover: .after(count - 1), dragged: dragged, rows: count, rowHeight: 30, window: w)
                        == Drop.lineTop(hover: .end, dragged: dragged, rows: count, rowHeight: 30, window: w),
                        "the last row's lower half and the end zone (\(count) rows, row \(dragged) dragged)")
            }
        }
    }

    /// **P-U2d-1 (c), the pure half → VX-424 — RED ON OLD (R-H).** A change of
    /// target moves the line: half by half down the list, then the end zone —
    /// and crossing a boundary (a lower half to the next upper half) leaves it
    /// where it is.
    ///
    /// **VX-424 — edited in place:** the walk is over halves (was rows).
    @Test func aTargetChangeMovesTheLine() {
        let w = window()
        let walk: [Drop.Hover] = [.before(0), .after(0), .before(1), .after(1), .before(2), .after(2),
                                  .before(3), .after(3), .end]
        let tops = walk.map { Drop.lineTop(hover: $0, dragged: 0, rows: 4, rowHeight: 30, window: w) }
        #expect(tops == [nil, nil, nil, 59, 59, 89, 89, 118, 118],
                "a's own row and the row right after it offer nothing; then the b/c, c/d boundaries, the end: \(tops)")
    }

    /// The scroll axis: the line rides its targeted row — read against the
    /// list's offset as it now stands; a top scrolled past the window's top
    /// edge shows AT that edge. RED ON OLD (R-X).
    ///
    /// **VX-424 — edited in place:** `.row(3)` reads `.before(3)` (the same
    /// slot — a row's upper half, or its own drop).
    @Test func theLineRidesTheTargetedRowThroughAScroll() {
        func top(_ offset: CGFloat) -> CGFloat? {
            Drop.lineTop(hover: .before(3), dragged: 9, rows: 10, rowHeight: 30,
                         window: window(offset: offset, viewport: 120, content: 300))
        }
        #expect(top(0) == 89, "row 3's top at 90")
        #expect(top(20) == 69, "scrolled 20: 20 pt higher on screen")
        #expect(top(60) == 29, "scrolled 60")
        #expect(top(100) == 0, "its top 10 pt above the window: the line at the window's top edge")
    }

    /// List-change axis: the rows, the pitch and the dragged row's place are
    /// inputs too — a row closing above the dragged one moves its own place;
    /// the pitch flipping 30 → 24 re-reads the targeted row's top.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the targets are rows now, not a
    /// pointer's height. **VX-424 — edited in place:** `.row(i)` reads
    /// `.before(i)` (the same slot).
    @Test func theLineFollowsAChangeOfTheList() {
        let w = window(viewport: 120, content: 120)
        #expect(Drop.lineTop(hover: .before(2), dragged: 2, rows: 4, rowHeight: 30, window: w) == nil,
                "the dragged row itself targeted")
        #expect(Drop.lineTop(hover: .before(1), dragged: 1, rows: 3, rowHeight: 30, window: w) == nil,
                "a row above it closed: the same row, one place up — still its own")
        #expect(Drop.lineTop(hover: .before(2), dragged: 3, rows: 4, rowHeight: 30, window: w) == 59)
        #expect(Drop.lineTop(hover: .before(2), dragged: 3, rows: 4, rowHeight: 24,
                             window: window(viewport: 96, content: 96)) == 47,
                "at 24 pt c's top is at 48")
    }

    /// Never computed before layout exists: no reading, no pitch, no rows, no
    /// drag of this list's — no line.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the hover is a targeted row.
    /// **VX-424 — edited in place:** `.row(1)` reads `.before(1)`.
    @Test func noLineBeforeTheListIsReadOrWithoutADragOfItsOwn() {
        let hover = Drop.Hover.before(1)
        #expect(Drop.lineTop(hover: hover, dragged: 3, rows: 4, rowHeight: 30, window: .unmeasured) == nil)
        #expect(Drop.lineTop(hover: hover, dragged: 3, rows: 4, rowHeight: 0, window: window()) == nil)
        #expect(Drop.lineTop(hover: hover, dragged: 0, rows: 0, rowHeight: 30, window: window()) == nil)
        #expect(Drop.lineTop(hover: hover, dragged: nil, rows: 4, rowHeight: 30, window: window()) == nil,
                "a drag that did not begin in this list draws nothing")
        #expect(Drop.lineTop(hover: nil, dragged: 3, rows: 4, rowHeight: 30, window: window()) == nil)
    }

    /// A targeted row's top past a scrolled edge shows AT that edge — the line
    /// never draws outside the window. RED ON OLD (R-X), its first half.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the targets are rows now.
    /// **VX-424 — edited in place:** `.row(i)` reads `.before(i)`.
    @Test func theLineStaysInsideTheWindow() {
        // Row 1 targeted in a window scrolled to 40: its top (30) is 10 pt
        // above the window.
        #expect(Drop.lineTop(hover: .before(1), dragged: 9, rows: 10, rowHeight: 30,
                             window: window(offset: 40, viewport: 120, content: 300)) == 0)
        // …and row 6 in one scrolled to 50: its top (180) is 10 pt below it.
        #expect(Drop.lineTop(hover: .before(6), dragged: 0, rows: 10, rowHeight: 30,
                             window: window(offset: 50, viewport: 120, content: 300)) == 118)
    }

    // MARK: - The end zone

    /// **P-U2d-2 — RED ON OLD (R-Q).** The end zone is the room the list
    /// leaves under its rows, capped at 28 pt (the book navigator's end zone),
    /// PLUS the column's bottom padding, which moves into it while the list
    /// shows — so the column's layout is unchanged and the zone is never
    /// absent: a list that scrolls keeps the padding's 12 pt as its last-slot
    /// target. No rows, no list: no zone.
    ///
    /// **U2d — edited in place by P-U2d-2** (was
    /// `theEndZoneIsTheRoomUnderTheRowsCapped`, whose zone vanished once the
    /// rows filled the list — F2 has no half row to stand in for it).
    @Test func theEndZoneIsTheRoomUnderTheRowsCappedAndTheBottomPadding() {
        func zone(_ rows: Int, visible: CGFloat = 800, top: CGFloat = 300) -> CGFloat {
            Drop.endZoneHeight(visibleHeight: visible, listTop: top, bottomPadding: 12, rows: rows, rowHeight: 30)
        }
        #expect(zone(5) == 40, "plenty of room: the whole 28 pt, and the padding under it")
        #expect(zone(16) == 20, "488 − 480: the 8 pt that are there, and the padding")
        #expect(zone(17) == 12, "the rows fill the list: the padding alone — the zone is never absent")
        #expect(zone(5, visible: 0) == 12, "unmeasured: the padding alone (the layout never loses it)")
        #expect(zone(5, top: 0) == 12, "unmeasured: the padding alone")
        #expect(zone(0) == 0, "no rows, no list: no zone (the column keeps its own padding)")
        #expect(Drop.endZoneMaxHeight == 28 && Drop.lineThickness == 2, "the book navigator's numbers")
    }
}

// MARK: - The door: the drag state, the release, the landing (no mount)

@MainActor
@Suite("VX-288 — the Open list's drop lands where its line was drawn (the door)")
struct OpenListDropDoorTests {
    private func workspace(_ ids: [String]) -> WorkspaceModel {
        let workspace = WorkspaceModel()
        for id in ids { workspace.visit(.post(id)) }
        return workspace
    }

    private func reading(offset: CGFloat = 0, rows: Int = 4) -> SidebarLayout.ScrollWindow {
        SidebarLayout.ScrollWindow(offset: offset, viewport: 120, content: CGFloat(rows) * 30)
    }

    /// **RED ON OLD (R-X).** A drag of row a with c targeted draws the line at
    /// c's top — and the release on c lands a exactly there.
    ///
    /// **U2d (P-U2d-1) — edited in place:** a targeted row, not a pointer's
    /// half, names the slot; the release names its own row.
    ///
    /// **VX-424 — edited in place, the whole suite:** every `.row(x)` target
    /// reads `.before(x)` — the same slot (a row's upper half, or the row's own
    /// drop under its halves), so each pin's meaning is unchanged; the two new
    /// pins below name the lower halves.
    @Test func aDropLandsWhereTheLineWasDrawn() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.targeted(.before("c"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "the line at c's top")
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .before("c"), state: state, workspace: workspace,
                                         animation: nil))
        #expect(workspace.openNotes.ids == ["b", "a", "c", "d"])
    }

    /// The end zone names the last slot, and the release lands there.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the zone is targeted, and the
    /// last row over it is refused at the release (no proposal exists on
    /// main's API).
    @Test func theEndZoneLandsTheLastSlot() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("b")
        state.targeted(.end, true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 118, "the line at the list's end")
        let token = SidebarView.OpenNoteDragToken(noteID: "b", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .end, state: state, workspace: workspace, animation: nil))
        #expect(workspace.openNotes.ids == ["a", "c", "d", "b"])
        // …and the last row over the end zone would change nothing: no line,
        // and the release moves nothing.
        state.began("b")
        state.targeted(.end, true)
        #expect(state.lineTop(rows: ["a", "c", "d", "b"], rowHeight: 30) == nil)
        #expect(!OpenListDropDoor.perform([token], onto: .end, state: state, workspace: workspace, animation: nil))
        #expect(workspace.openNotes.ids == ["a", "c", "d", "b"])
    }

    /// §12's false-offer rule at the door: on the dragged row's own place —
    /// its own row, and the row right after it — no line is drawn and the
    /// release moves nothing (the image slides back). RED ON OLD (R-X), the
    /// row-after half.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the own place is two targets now.
    /// **VX-424 — edited in place:** …and four halves: b's own two, c's upper,
    /// a's lower.
    @Test func aDropOnItsOwnPlaceOffersNothingAndMovesNothing() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        for target: OpenListDragState.Target in [.before("b"), .after("b"), .before("c"), .after("a")] {
            state.began("b")
            state.targeted(target, true)
            #expect(state.lineTop(rows: ids, rowHeight: 30) == nil, "no line on \(target)")
            let token = SidebarView.OpenNoteDragToken(noteID: "b", listID: state.listID)
            #expect(!OpenListDropDoor.perform([token], onto: target, state: state, workspace: workspace,
                                              animation: nil))
        }
        #expect(workspace.openNotes.ids == ids)
    }

    /// PROVISIONAL P-U2-3: a drop acts only on the list its drag began in — a
    /// row dragged from another window's Open list moves nothing here, even
    /// when this list holds the same note.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the hover at the end is a targeted
    /// row (d — the gap the old pointer height named).
    @Test func aDropActsOnlyOnTheListItsDragBeganIn() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let here = OpenListDragState()
        let elsewhere = OpenListDragState()
        let foreign = SidebarView.OpenNoteDragToken(noteID: "a", listID: elsewhere.listID)
        #expect(!OpenListDropDoor.land(foreign, atGap: 3, listID: here.listID, in: workspace, animation: nil))
        #expect(workspace.openNotes.ids == ids)
        // And no line is drawn here for a drag this list never saw begin.
        here.read(reading())
        here.targeted(.before("d"), true)
        #expect(here.lineTop(rows: ids, rowHeight: 30) == nil)
    }

    /// The scroll axis through the state: the line rides its targeted row as
    /// the list scrolls (the window is copied in only while a target stands —
    /// an ordinary scroll re-renders nothing). RED ON OLD (R-X).
    @Test func aScrollMovesTheLineWithItsTargetedRow() {
        let ids = (0..<10).map { "n\($0)" }
        let state = OpenListDragState()
        state.read(reading(offset: 0, rows: 10))
        state.began("n9")
        state.targeted(.before("n3"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 89, "n3's top at 90")
        state.read(reading(offset: 30, rows: 10))
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "scrolled 30: the line rode its row up")
        state.targeted(.before("n3"), false)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == nil, "the drag left: no line")
        state.read(reading(offset: 60, rows: 10))
        #expect(state.window.offset == 30, "with no target a scroll is not copied in")
    }

    /// The target is the row's NOTE, so a change of the list re-derives the
    /// line from where that row now stands — and a target whose row closed
    /// draws nothing. A guard of the per-row road (holding the row by its
    /// note, as main's landing names it).
    @Test func theTargetIsTheRowsNoteSoAListChangeRederivesTheLine() {
        let state = OpenListDragState()
        state.read(reading())
        state.began("d")
        state.targeted(.before("c"), true)
        #expect(state.lineTop(rows: ["a", "b", "c", "d"], rowHeight: 30) == 59, "c is row 2")
        #expect(state.lineTop(rows: ["b", "c", "d"], rowHeight: 30) == 29, "a closed: c is row 1 now")
        #expect(state.lineTop(rows: ["b", "d"], rowHeight: 30) == nil, "c closed: its target is gone")
    }

    /// Leaving a row for the end zone (or back) never blanks the line in
    /// between, whichever of the two `isTargeted` calls arrives last. RED ON
    /// OLD (R-Y).
    ///
    /// **U2d (P-U2d-1) — edited in place:** the row is targeted (d), so its
    /// line is d's top, not the end's.
    @Test func movingBetweenTheRowsAndTheEndZoneKeepsTheLine() {
        let ids = ["a", "b", "c", "d"]
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.targeted(.before("d"), true)
        state.targeted(.end, true)          // the zone targeted before…
        state.targeted(.before("d"), false)    // …the row's un-target arrived
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 118)
        state.targeted(.before("d"), true)
        state.targeted(.end, false)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 89)
    }

    /// The release lands the PAYLOAD (the whole road a real drop takes after
    /// SwiftUI decodes it, short of the pointer): the target the drop names,
    /// the token, the move — and the drop ends the drag.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the last slot is the end zone's.
    @Test func aReleaseReadsThePayloadAndLandsIt() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.targeted(.end, true)
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .end, state: state, workspace: workspace, animation: nil))
        #expect(state.dragging == nil && state.target == nil, "the drop ends the drag")
        #expect(workspace.openNotes.ids == ["b", "c", "d", "a"])
    }

    /// A release with no payload, or on the dragged row's own place, refuses
    /// (the image slides back) — and either way the drag is over.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the releases name their rows.
    @Test func aReleaseThatOffersNothingRefuses() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("b")
        state.targeted(.before("b"), true)
        let own = SidebarView.OpenNoteDragToken(noteID: "b", listID: state.listID)
        #expect(!OpenListDropDoor.perform([own], onto: .before("b"), state: state, workspace: workspace,
                                          animation: nil))
        #expect(state.dragging == nil)
        state.began("a")
        state.targeted(.before("d"), true)
        #expect(!OpenListDropDoor.perform([], onto: .before("d"), state: state, workspace: workspace,
                                          animation: nil))
        #expect(workspace.openNotes.ids == ids)
    }

    /// **P-U2d-1 (c) — RED ON OLD (R-Y).** A change of target moves the line,
    /// and an un-target clears only the target IT set: each row is its own
    /// drop, so the next row's `isTargeted(true)` may arrive before this row's
    /// `false` — in either order, the newest target stands.
    @Test func aTargetChangeMovesTheLineAndAnUntargetClearsOnlyItsOwn() {
        let ids = ["a", "b", "c", "d"]
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.targeted(.before("c"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "c's top")
        state.targeted(.before("d"), true)     // the next row targeted before…
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 89, "the target moved: d's top")
        state.targeted(.before("c"), false)    // …the last one's un-target arrived
        #expect(state.target == .before("d"), "d's target stands")
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 89)
        state.targeted(.before("d"), false)
        #expect(state.target == nil && state.lineTop(rows: ids, rowHeight: 30) == nil, "the drag left the rows")
        state.targeted(.before("b"), true)
        state.targeted(.before("b"), false)    // the other order: the un-target first…
        state.targeted(.before("c"), true)     // …then the next row's target
        #expect(state.target == .before("c"))
        state.targeted(.end, true)
        state.targeted(.before("c"), false)    // a row's late un-target leaves the end zone's
        #expect(state.target == .end)
        // VX-424: crossing a boundary — b's lower half to c's upper half, one
        // slot — in either order of the two calls: the line never moves.
        state.targeted(.end, false)
        state.targeted(.after("b"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "b's lower half: the b/c boundary")
        state.targeted(.before("c"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "c's upper half: the same boundary, the same line")
        state.targeted(.after("b"), false)
        #expect(state.target == .before("c") && state.lineTop(rows: ids, rowHeight: 30) == 59)
        state.targeted(.after("c"), true)
        state.targeted(.before("c"), false)
        #expect(state.target == .after("c") && state.lineTop(rows: ids, rowHeight: 30) == 89, "c's lower half")
    }

    /// **VX-424 — DOWN BY ONE, at the door — RED ON OLD (R-H).** Row a dragged
    /// over the LOWER half of the row right below it (b): the line lights at
    /// the b/c boundary, and the release there lands a just below b — where the
    /// old rule drew no line and slid the chip back.
    @Test func aDownByOneReleaseLandsWhereTheLineWas() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.targeted(.before("b"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == nil, "b's upper half: a's own lower gap, no line")
        state.targeted(.after("b"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "b's lower half: the line at the b/c boundary")
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .after("b"), state: state, workspace: workspace,
                                         animation: nil))
        #expect(workspace.openNotes.ids == ["b", "a", "c", "d"], "one place down")
    }

    /// **VX-424 — AN UP-DRAG, at the door — RED ON OLD (R-H).** Row d dragged
    /// up over a's LOWER half: the line at the a/b boundary, and the release
    /// lands d just below a — never above it (the old rule's one-too-high
    /// landing on the hovered row's top).
    @Test func anUpDragReleasedOnARowsLowerHalfLandsJustBelowIt() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("d")
        state.targeted(.after("a"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 29, "a's lower half: the a/b boundary")
        let token = SidebarView.OpenNoteDragToken(noteID: "d", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .after("a"), state: state, workspace: workspace,
                                         animation: nil))
        #expect(workspace.openNotes.ids == ["a", "d", "b", "c"], "just below a")
    }

    /// **P-U2d-1 (c) — RED ON OLD (R-X).** The action lands the dragged row
    /// BEFORE the targeted row, inside the settle (the door's default — the
    /// rows' and the zone's actions pass no animation; pin (a) reads that).
    @Test func theActionLandsBeforeTheTargetedRowWithTheSettle() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.targeted(.before("d"), true)
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .before("d"), state: state, workspace: workspace))
        #expect(workspace.openNotes.ids == ["b", "c", "a", "d"], "before d")
        #expect(OpenListDropDoor.lastLanding
                == OpenListDropDoor.Landing(from: 0, to: 3, animation: OpenListDropDoor.settle),
                "the move rode the settle: \(String(describing: OpenListDropDoor.lastLanding))")
        #expect(OpenListDropDoor.settle == Animation.snappy(duration: SidebarLayout.railTransition),
                "the settle: a snap on the column's one beat (P-U2-4)")
    }

    /// **P-T3-3 → P-U2d-1 (c) — RED ON OLD (R-Z).** The drag SESSION's end
    /// clears the list's drag — a release anywhere (a cancel off the list, a
    /// drop elsewhere, a landed drop) — while a session still in flight keeps
    /// it. After a cancel, a row dragged in from ANOTHER window's list draws no
    /// line here.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the targets are rows; a landed
    /// drop's session ends in a COPY on main's API.
    @Test func theDragSessionsEndClearsTheDrag() {
        let ids = ["a", "b", "c", "d"]
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.targeted(.before("c"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "a's drag with c targeted")
        state.dragSessionUpdated(.active)
        #expect(state.dragging == "a", "a session in flight keeps its drag")
        state.dragSessionUpdated(.ended(.cancel))
        #expect(state.dragging == nil && state.target == nil, "the session ended: the drag is over")
        // A foreign drag (another window's list) targeting a row after the
        // cancel: no line.
        state.targeted(.before("d"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == nil)
        state.targeted(.before("d"), false)
        // A landed drop's session end clears it too.
        state.began("b")
        state.dragSessionUpdated(.ended(.copy))
        #expect(state.dragging == nil)
    }

    /// The source's session end and the drop's action may arrive in either
    /// order; the drop lands either way, because the action names its OWN row
    /// and `land` decides on the payload. A guard (green on both sides of R-Z
    /// by design).
    ///
    /// **U2d (P-U2d-1) — edited in place:** the action names its row.
    @Test func aSessionEndBeforeTheDropsActionStillLands() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.targeted(.before("c"), true)               // the line at c's top
        state.dragSessionUpdated(.ended(.copy))       // the source's end FIRST
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .before("c"), state: state, workspace: workspace,
                                         animation: nil))  // …then the drop on c
        #expect(workspace.openNotes.ids == ["b", "a", "c", "d"])
    }
}

// MARK: - The chip and the doors, read

@MainActor
@Suite("VX-288 — the Open row drags its title chip at the grab point; the list is the one drop")
struct OpenListDragFaceTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// The chip (her VX-70 ruling: on the Open list's rows) at the GRAB POINT —
    /// centred over the row, the chip's ink sits on the grab (R-LWP-3's
    /// precedent, `BookcaseDragFaceTests`), compact and never cut.
    @Test func theOpenRowsChipIsItsTitleAtTheGrabPoint() throws {
        let row = CGSize(width: 206, height: 30)
        let chip = SidebarView.openRowChip("The Long Way Home", tokens: .studyLight)
        let bare = try BookcaseDragFaceTests.inkBox(chip.padding(4))
        for grab in [CGPoint(x: 30, y: 15), CGPoint(x: 190, y: 4), CGPoint(x: 103, y: 28)] {
            let (canvas, ink) = try BookcaseDragFaceTests.render(DragChipCanvas(source: row, grab: grab) {
                SidebarView.openRowChip("The Long Way Home", tokens: .studyLight)
            })
            let offset = CGPoint(x: ink.midX - canvas.width / 2, y: ink.midY - canvas.height / 2)
            let wanted = CGPoint(x: grab.x - row.width / 2, y: grab.y - row.height / 2)
            #expect(abs(offset.x - wanted.x) <= 1.5 && abs(offset.y - wanted.y) <= 1.5,
                    "the chip sits on the grab \(grab) (ink \(ink), canvas \(canvas))")
            #expect(abs(ink.width - bare.width) <= 1 && abs(ink.height - bare.height) <= 1,
                    "the whole chip — never cut (ink \(ink.size), bare \(bare.size))")
            #expect(ink.height < 40, "compact — one line (\(ink.height) pt)")
        }
    }

    /// The wiring, read from the source (a drag cannot be posted in the test
    /// host): the Open row drags through the shared chip source with its title
    /// chip, and is its own drop; the end zone sits under the rows, the line
    /// lies over the list.
    ///
    /// **U2c (P-U2b-1) — edited in place by the ruling** (was
    /// `theRowDragsItsChipAndTheListIsTheOneDrop`): its "no row is its own drop
    /// target" assertion INVERTS — the rows are the targets again, and the
    /// location inside a row now decides the half (U2's traced bug was the row
    /// under the pointer deciding alone, never the per-row target itself); the
    /// assertion that the list's content carried ONE delegate is withdrawn
    /// (that delegate was never consulted — U2b's trace).
    ///
    /// **U2d (P-U2d-1):** the assertions stand unchanged; only the second
    /// message's half-row clause is withdrawn (the TARGETED row decides now),
    /// and P-T3-1, which this note pointed to, is retired — pin (a) below
    /// reads the road in full.
    @Test func theRowDragsItsChipAndIsItsOwnDrop() throws {
        let source = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Library/SidebarView.swift"),
            encoding: .utf8)
        let start = try #require(source.range(of: "private func openRow("))
        let row = String(source[start.upperBound...].prefix(9_000))
        #expect(row.contains("ChipDragSource(") && row.contains("Self.openRowChip("),
                "the row's drag image is its title chip at the grab point")
        #expect(row.contains(".modifier(OpenListRowDrop("),
                "each row is its own drop (P-U2b-1; the targeted row decides — P-U2d-1)")
        #expect(source.contains("openListEndZone(shown)"), "the end zone sits under the rows")
        #expect(source.contains(".overlay { openListLine(shown) }"), "the line lies over the list")
        let shelf = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Shelf/ShelfView.swift"),
            encoding: .utf8)
        #expect(shelf.contains("ChipDragSource(") && shelf.contains("DragChipCanvas("),
                "the Bookcase reads the same shared chip machinery (one home)")
        #expect(!shelf.contains("struct GrabCanvas"), "no second copy of the canvas")
    }

    /// A function's (or a type's) body, read from the source: from `header`
    /// to the first line closing at `indent`.
    private static func body(of header: String, in source: String, indent: String = "    ") throws -> String {
        let start = try #require(source.range(of: header), "\(header) is in the source")
        let rest = source[start.upperBound...]
        let end = rest.range(of: "\n\(indent)}\n")?.lowerBound ?? rest.endIndex
        return String(rest[..<end])
    }

    /// **P-U2d-1 (a) — RED ON OLD (R-W).** The Open list's drop is MAIN's own
    /// per-row road, the one her hands have used: each row a classic
    /// Transferable `dropDestination(for:action:isTargeted:)` named by its
    /// note, the end zone a drop of the same kind, each landing through the
    /// door with its settle (no animation argument — the door's default). The
    /// source keeps its half: the payload's evaluation arms the drag and the
    /// drag session's end clears it. And none of what P-U2d-1 dropped remains
    /// on the list — the macOS 26 session form, the move configuration, a
    /// legacy drop, U2b's instrument.
    @Test func eachRowIsATargetedDropOnMainsRoadAndNoSessionFormRemains() throws {
        let sidebar = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Library/SidebarView.swift"),
            encoding: .utf8)
        let drag = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Library/OpenListDrag.swift"),
            encoding: .utf8)
        let row = try Self.body(of: "private func openRow(", in: sidebar)
        let group = try Self.body(of: "private var openGroup: some View {", in: sidebar)
        let endZone = try Self.body(of: "private func openListEndZone(", in: sidebar)
        let rowDrop = try Self.body(of: "struct OpenListRowDrop: ViewModifier {", in: drag, indent: "")
        let endDrop = try Self.body(of: "struct OpenListEndZoneDrop: ViewModifier {", in: drag, indent: "")

        #expect(row.contains(".modifier(OpenListRowDrop(state: openListDrag, noteID: noteID"),
                "each Open row is its own drop, named by its note")
        #expect(row.contains("openListDrag.began(noteID)"), "the payload's evaluation arms the drag")
        #expect(row.contains(".onDragSessionUpdated {") && row.contains("openListDrag.dragSessionUpdated("),
                "the source's drag session reaches the list's state (its end clears the drag)")
        #expect(endZone.contains(".modifier(OpenListEndZoneDrop("), "the end zone is a per-zone drop")
        // VX-424 — edited in place: the row's own drop names `.before(noteID)`
        // (the same slot `.row(noteID)` named — it stays as the row's floor
        // under its two halves, which the next pin reads).
        for (name, body, target) in [("OpenListRowDrop", rowDrop, ".before(noteID)"),
                                     ("OpenListEndZoneDrop", endDrop, ".end")] {
            #expect(body.contains(".dropDestination(for: SidebarView.OpenNoteDragToken.self) {"),
                    "\(name): main's per-row Transferable drop")
            #expect(body.contains("} isTargeted: {"), "\(name): isTargeted marks the target")
            // VX-589 — edited deliberately: each drop hands the door the rows
            // the list DRAWS (`displayed: rows`), so a list hiding its starred
            // notes lands among what she sees.
            #expect(body.contains("OpenListDropDoor.perform(tokens, onto: \(target), displayed: rows, state: state, workspace: workspace)"),
                    "\(name): lands through the door with its settle")
        }
        for gone in ["onDropSessionUpdated", "dropConfiguration", "DragConfiguration", "dragConfiguration",
                     "isEnabled:"] {
            #expect(!row.contains(gone) && !group.contains(gone) && !endZone.contains(gone) && !drag.contains(gone),
                    "no \(gone) on the Open list (P-U2d-1)")
        }
        #expect(!group.contains("onDrop(of:") && !endZone.contains("onDrop(of:"), "no legacy drop on the Open list")
        #expect(!drag.contains(": DropDelegate"), "no legacy drop delegate remains")
        #expect(!sidebar.contains("OpenListDragTrace") && !drag.contains("OpenListDragTrace"),
                "U2b's instrument is stripped (P-U2d-1)")
        #expect(!sidebar.contains("OpenListHoverLog") && !drag.contains("OpenListHoverLog"),
                "VX-424's temporary hand-drag log is stripped (A-439-15)")
    }

    /// **VX-424 — the row's TWO HALVES, read — RED ON OLD (R-O: the overlay
    /// removed).** Each Open row wears `OpenListRowHalves` as an overlay INSIDE
    /// its gestures and its own drop (so the halves are nearer the pointer than
    /// the row's drop, and their hits are still the row's to click and drag):
    /// an upper half naming the slot before the row and a lower half the slot
    /// after it, each main's classic Transferable drop with `isTargeted`,
    /// landing through the door; reaching the list's side margins; and taking
    /// hits ONLY while this list's own drag is in flight.
    @Test func eachRowsTwoHalvesAreDropsOnMainsRoadLiveOnlyWhileItsDragIsInFlight() throws {
        let sidebar = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Library/SidebarView.swift"),
            encoding: .utf8)
        let drag = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Library/OpenListDrag.swift"),
            encoding: .utf8)
        let row = try Self.body(of: "private func openRow(", in: sidebar)
        let halves = try Self.body(of: "struct OpenListRowHalves: View {", in: drag, indent: "")
        let overlay = try #require(row.range(of: ".overlay { openRowHalves(noteID"), "the row wears its halves")
        for outer in [".onTapGesture", ".modifier(ChipDragSource(", ".modifier(OpenListRowDrop(", ".contextMenu {"] {
            let at = try #require(row.range(of: outer), "\(outer) is on the row")
            #expect(overlay.lowerBound < at.lowerBound, "the halves sit INSIDE \(outer)")
        }
        let helper = try Self.body(of: "private func openRowHalves(", in: sidebar)
        #expect(helper.contains("reach: Self.scrollingSectionMargin"), "the halves reach the list's side margins")
        #expect(halves.contains("half(.before(noteID))") && halves.contains("half(.after(noteID))"),
                "an upper half before the row, a lower half after it")
        #expect(halves.range(of: "half(.before(noteID))")!.lowerBound < halves.range(of: "half(.after(noteID))")!.lowerBound,
                "the upper half first")
        #expect(halves.contains("VStack(spacing: 0) {"), "the two halves stack with no gap between them")
        #expect(halves.contains(".dropDestination(for: SidebarView.OpenNoteDragToken.self) {")
                && halves.contains("} isTargeted: {"), "each half is main's classic per-target drop")
        #expect(halves.contains("OpenListDropDoor.perform(tokens, onto: target, displayed: rows, state: state, workspace: workspace)"),
                "each half lands through the door with its settle")
        #expect(halves.contains(".padding(.horizontal, -reach)"), "the halves reach into the margins")
        #expect(halves.contains(".allowsHitTesting(state.dragging != nil)"),
                "the halves take hits only while this list's own drag is in flight")
    }
}

// MARK: - The mounted pins: what the drag DRAWS and what a drop DOES in a window

/// The column, bound to the workspace exactly as `RootView.selectionBinding`
/// binds it (`SidebarSectionWindowTests`' host shape).
@MainActor
private struct OpenListDragHost: View {
    let session: AppSession
    let workspace: WorkspaceModel
    let stars: StarsModel
    let theme: ThemeStore
    let footerHeight: CGFloat

    var body: some View {
        SidebarView(
            session: session, model: LibraryViewModel(session: session),
            pool: PoolViewModel(session: session),
            workspace: workspace, stars: stars,
            selection: Binding(
                get: { workspace.selections[workspace.focusedPane] },
                set: { picked in if let picked { workspace.select(picked) } }),
            noteBox: nil,
            bottom: AnyView(Color.clear.frame(height: footerHeight)))
            .frame(width: 230)
            .environment(theme)
    }
}

/// One mounted column, its drag state and the oracles a pin reads.
@MainActor
private final class DragColumn {
    let session: AppSession
    let workspace: WorkspaceModel
    let window: NSWindow
    let hosting: NSView
    let key: String
    let notes: [String]

    init(session: AppSession, workspace: WorkspaceModel, window: NSWindow, hosting: NSView, notes: [String]) {
        self.session = session
        self.workspace = workspace
        self.window = window
        self.hosting = hosting
        self.key = SidebarGeometry.bodyKey(for: workspace)
        self.notes = notes
    }

    var list: SidebarGeometry.SectionDraw? { SidebarGeometry.sectionDraws[key]?[.open] }
    var drag: OpenListDragState? { SidebarGeometry.openListDrags[key] }
    var line: CGRect? { SidebarGeometry.openListLines[key] }
    var endZone: CGRect? { SidebarGeometry.openListEndZones[key] }
    var column: CGRect? { SidebarGeometry.columnScrollFrames[key] }
    /// VX-424: the first row's two drop halves, and its ✕, as laid out.
    var firstRowHalves: (upper: CGRect, lower: CGRect)? { SidebarGeometry.openListFirstRowHalves[key] }
    var firstRowClose: CGRect? { SidebarGeometry.openListFirstRowCloses[key] }

    /// A click — down, a beat, up — at a point in the hosting view's y-down
    /// (SwiftUI global) space, posted through the app's own event road
    /// (`BlocksWorkbenchFaceTests`' / `MCPSharedIconClickTests`' rig shape).
    ///
    /// (Stage-run correction, 2026-10-27: the first cut mapped SwiftUI's
    /// global space onto the hosting view by its height and landed ONE ROW
    /// LOW — the titled window's chrome sits between the two. The map is now
    /// ANCHORED on the list's own AppKit scroll view: its SwiftUI frame (the
    /// oracle's) and its window frame (AppKit's) name the same rectangle.)
    func click(at point: CGPoint) async {
        window.makeKeyAndOrderFront(nil)
        guard let scroll = listScrollView(), let global = list?.scroll else { return }
        let anchor = scroll.convert(scroll.bounds, to: nil)  // window space, y up
        let inWindow = NSPoint(
            x: anchor.minX + (point.x - global.minX),
            y: anchor.maxY - (point.y - global.minY))
        for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
            if let event = NSEvent.mouseEvent(
                with: type, location: inWindow, modifierFlags: [],
                timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window.windowNumber, context: nil,
                eventNumber: 1, clickCount: 1, pressure: type == .leftMouseUp ? 0 : 1) {
                NSApp.sendEvent(event)
            }
            pump(0.03)
        }
        await settle(minimum: 0.2)
    }

    /// The pitch the list draws at NOW (its content over its rows).
    var pitch: CGFloat {
        (list?.window?.content ?? 0) / CGFloat(max(workspace.openNotes.shown.count, 1))
    }

    func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Turns the run loop until the list, its line and its end zone have
    /// stopped moving — and never before the rail's fade has run its course.
    func settle(minimum: TimeInterval = 0.5) async {
        let start = Date()
        var last: String?
        var still = 0
        for _ in 0..<300 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            let now = "\(String(describing: list?.window))|\(String(describing: list?.scroll))|"
                + "\(String(describing: line))|\(String(describing: endZone))|\(workspace.openNotes.ids)"
            if list?.window != nil, now == last { still += 1 } else { still = 0 }
            last = now
            if still >= 5, Date().timeIntervalSince(start) >= minimum { return }
        }
    }

    /// The list's AppKit scroll view — found by its OWN reading (clip height =
    /// viewport, document height = content), no coordinate convention assumed
    /// (U1d's rig rule).
    func listScrollView() -> NSScrollView? {
        guard let reading = list?.window, reading.isMeasured else { return nil }
        func all(_ view: NSView) -> [NSScrollView] {
            var found: [NSScrollView] = []
            if let scroll = view as? NSScrollView { found.append(scroll) }
            for sub in view.subviews { found += all(sub) }
            return found
        }
        return all(hosting).first { scroll in
            abs(scroll.contentView.bounds.height - reading.viewport) < 1
                && abs((scroll.documentView?.frame.height ?? -10) - reading.content) < 2
        }
    }

    /// Scrolls the list's clip view to `offset` — an offset-only change (no
    /// phase, no act): the line's scroll axis.
    func scrollList(to offset: CGFloat) async throws {
        let scroll = try #require(listScrollView(), "the list's scroll view")
        scroll.contentView.scroll(to: NSPoint(x: scroll.contentView.bounds.origin.x, y: offset))
        scroll.reflectScrolledClipView(scroll.contentView)
        await settle()
    }

    /// The line as drawn, in the list's VIEWPORT (its top), or nil.
    var lineTopInList: CGFloat? {
        guard let line, let scroll = list?.scroll else { return nil }
        return line.minY - scroll.minY
    }

    /// What the pure rule says the line's top is, from the state as it stands.
    var lineTopByRule: CGFloat? {
        drag?.lineTop(rows: workspace.openNotes.shown, rowHeight: pitch)
    }
}

@MainActor
@Suite("VX-288 — the Open list's drag, as drawn", .serialized)
struct OpenListDragMountTests {
    private static let footerHeight: CGFloat = 64

    private func withColumn(
        height: CGFloat, openNotes: Int, startOn: Int?,
        _ body: @MainActor (DragColumn) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // The LIVE generator: the oracle keys must not collide with a
            // parallel suite's (the DEBUG-oracle keying rule).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 288))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let notes = try (1...openNotes).map {
                try session.operations.createPost(title: "note \($0)").id
            }
            let workspace = WorkspaceModel()
            for note in notes { workspace.visit(.post(note)) }
            workspace.select(startOn.map { .post(notes[$0]) } ?? .library)
            let stars = StarsModel(session: session)
            let observing = Task { await stars.start() }
            defer { observing.cancel() }
            let theme = ThemeStore(session: session)
            SidebarGeometry.forgetSections(for: workspace)
            defer { SidebarGeometry.forgetSections(for: workspace) }

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 230, height: height),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: OpenListDragHost(
                session: session, workspace: workspace, stars: stars, theme: theme,
                footerHeight: Self.footerHeight))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            let column = DragColumn(
                session: session, workspace: workspace, window: window, hosting: hosting, notes: notes)
            await column.settle()
            try await body(column)
        }
    }

    /// **The overlay/sink delivery law, as drawn** — the line lies where the
    /// rule says, and RE-DERIVES on every input axis: the target moving, the
    /// list scrolling under it, the list changing under it; it lights nowhere
    /// a drop would change nothing, and goes when the drag leaves.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the drag targets ROWS (by their
    /// notes), and the line sits at the targeted row's top.
    @Test func theLineDrawsWhereTheDropWouldLandOnEveryAxis() async throws {
        // 700 pt: twenty rows overflow the list by several rows (it scrolls).
        try await withColumn(height: 700, openNotes: 20, startOn: nil) { column in
            let drag = try #require(column.drag, "the column's drag state")
            let pitch = column.pitch
            #expect(pitch >= 24, "the list is laid out: \(pitch)")
            #expect(column.line == nil, "no drag, no line")

            // Target: row 3 dragged, row 8 targeted → the line at row 8's top.
            // (VX-424 — edited in place: `.row(x)` reads `.before(x)` throughout,
            // the same slot; the lower-half leg below is new.)
            drag.began(column.notes[2])
            drag.targeted(.before(column.notes[7]), true)
            await column.settle()
            let first = try #require(column.lineTopInList, "the line is drawn")
            #expect(abs(first - (7 * pitch - 1)) <= 0.5, "at row 8's top: \(first) at pitch \(pitch)")
            #expect(abs(first - (column.lineTopByRule ?? -99)) <= 0.5)

            // The target moves — the next row's target, then the last one's
            // un-target — onto row 10: the line at its top.
            drag.targeted(.before(column.notes[9]), true)
            drag.targeted(.before(column.notes[7]), false)
            await column.settle()
            let moved = try #require(column.lineTopInList)
            #expect(abs(moved - (9 * pitch - 1)) <= 0.5, "at row 10's top: \(moved)")

            // VX-424: row 9's LOWER half names the same boundary as row 10's
            // upper half — the line does not move as the pointer crosses it.
            drag.targeted(.after(column.notes[8]), true)
            drag.targeted(.before(column.notes[9]), false)
            await column.settle()
            let crossed = try #require(column.lineTopInList, "row 9's lower half lights")
            #expect(abs(crossed - moved) <= 0.5, "the same boundary, the same line: \(crossed) vs \(moved)")
            drag.targeted(.before(column.notes[9]), true)
            drag.targeted(.after(column.notes[8]), false)
            await column.settle()

            // Scroll: the list scrolls 1.5 rows under the same target — the
            // line rides its row, redrawn where the rule now says.
            try await column.scrollList(to: 1.5 * pitch)
            let reading = try #require(column.list?.window)
            #expect(abs(reading.offset - 1.5 * pitch) <= 1, "the list scrolled: \(reading)")
            let scrolled = try #require(column.lineTopInList, "still drawn after the scroll")
            let wanted = try #require(SidebarLayout.OpenListDrop.lineTop(
                hover: .before(9), dragged: 2, rows: 20, rowHeight: pitch, window: reading))
            #expect(abs(scrolled - wanted) <= 0.5, "re-derived on the scroll: \(scrolled) vs \(wanted)")
            #expect(abs((moved - scrolled) - 1.5 * pitch) <= 1, "it rode its row up: \(moved) → \(scrolled)")

            // List change: a row above closes — the target is the row's note,
            // so the line re-derives from where that row now stands…
            column.workspace.closeNote(column.notes[0])
            await column.settle()
            let afterClose = try #require(column.lineTopInList, "still drawn after a row closed")
            #expect(abs(afterClose - (column.lineTopByRule ?? -99)) <= 0.5,
                    "re-derived on the list's change: \(afterClose) vs \(String(describing: column.lineTopByRule))")
            // …and when the list changes so the targeted row is the one right
            // after the dragged row, the line goes: a drop there changes nothing.
            let shown = column.workspace.openNotes.shown
            let targetAt = try #require(shown.firstIndex(of: column.notes[9]))
            let draggedAt = try #require(shown.firstIndex(of: column.notes[2]))
            column.workspace.moveOpenNotes(fromOffsets: IndexSet(integer: draggedAt), toOffset: targetAt)
            await column.settle()
            #expect(column.workspace.openNotes.shown.firstIndex(of: column.notes[2]) == targetAt - 1)
            #expect(column.line == nil, "the target is the row right after the dragged one now: no line")

            // The dragged row itself targeted — no line either.
            drag.targeted(.before(column.notes[2]), true)
            await column.settle()
            #expect(column.line == nil, "on the dragged row's own place nothing lights")

            // Elsewhere it lights; and when the drag leaves the rows, it goes.
            drag.targeted(.before(column.notes[15]), true)
            await column.settle()
            #expect(column.line != nil)
            drag.targeted(.before(column.notes[15]), false)
            await column.settle()
            #expect(column.line == nil, "the drag left: no line")
        }
    }

    /// **PROVISIONAL P-U2-1 — a drop never moves the list.** The rows settle
    /// into their new order in place: the list's window stays where it stood
    /// (no reveal fires — a drop is neither her act nor her hand), whether the
    /// list was following the current note or she had scrolled it away.
    @Test func aDropSettlesInPlaceAndNeverMovesTheList() async throws {
        try await withColumn(height: 900, openNotes: 20, startOn: 15) { column in
            let drag = try #require(column.drag)
            let before = try #require(column.list?.window)
            #expect(before.offset > 0, "the current row (16) is revealed — the list scrolled: \(before)")
            // Row 18 (under the current row) dropped at the very top: the current
            // row shifts one row DOWN, toward the bottom edge.
            let token = SidebarView.OpenNoteDragToken(noteID: column.notes[17], listID: drag.listID)
            #expect(OpenListDropDoor.land(token, atGap: 0, listID: drag.listID, in: column.workspace))
            await column.settle()
            #expect(column.workspace.openNotes.shown.first == column.notes[17], "it landed")
            let after = try #require(column.list?.window)
            #expect(abs(after.offset - before.offset) < 0.5, "the list did not move: \(before) → \(after)")
            #expect(column.workspace.focusedSelection == .post(column.notes[15]), "the current note is untouched")

            // Scrolled away by hand (an offset-only change here; U1d's own pins
            // carry the phase road): a drop leaves it there too.
            try await column.scrollList(to: 0)
            let token2 = SidebarView.OpenNoteDragToken(noteID: column.notes[3], listID: drag.listID)
            #expect(OpenListDropDoor.land(token2, atGap: 20, listID: drag.listID, in: column.workspace))
            await column.settle()
            #expect((column.list?.window?.offset ?? -1) < 0.5,
                    "still at its top: \(String(describing: column.list?.window))")
            #expect(column.workspace.openNotes.shown.last == column.notes[3])
        }
    }

    /// **VX-424 — the row's two halves, as laid out — RED ON OLD (R-O).** The
    /// first Open row's upper half covers exactly its top half and its lower
    /// half its bottom half — meeting at the row's midline, with no gap — and
    /// both reach across the list's whole width (the side margins, dead room
    /// before VX-424).
    @Test func theRowsTwoHalvesSplitItAtItsMidlineAndReachTheListsEdges() async throws {
        try await withColumn(height: 900, openNotes: 4, startOn: nil) { column in
            let halves = try #require(column.firstRowHalves, "the first row wears its two halves")
            let row = try #require(column.list?.firstRow, "the first row's box")
            let list = try #require(column.list?.scroll, "the list's scroll view")
            let (upper, lower) = halves
            #expect(abs(upper.minY - row.minY) <= 0.5 && abs(lower.maxY - row.maxY) <= 0.5,
                    "together they cover the row: \(upper) + \(lower) over \(row)")
            #expect(abs(upper.maxY - lower.minY) <= 0.5 && abs(upper.maxY - row.midY) <= 0.5,
                    "they meet at the row's midline, no gap: \(upper.maxY) / \(lower.minY) / \(row.midY)")
            #expect(abs(upper.height - lower.height) <= 0.5, "two equal halves")
            for half in [upper, lower] {
                #expect(abs(half.minX - list.minX) <= 0.5 && abs(half.maxX - list.maxX) <= 0.5,
                        "each half reaches the list's side edges (the margins): \(half) in \(list)")
            }
        }
    }

    /// **VX-424 — a GUARD: at rest the halves take no hit, so the row's own
    /// doors act** (red under revert R-G, the halves always hit-testable: the
    /// ✕'s click would reach the half, whose only door is the row's tap). With
    /// no drag in flight a click on the first row's ✕ closes that row, and a
    /// click on a row's title opens its note — exactly as before VX-424.
    @Test func atRestTheHalvesTakeNoClickSoTheRowsDoorsAct() async throws {
        try await withColumn(height: 900, openNotes: 4, startOn: nil) { column in
            let drag = try #require(column.drag)
            #expect(drag.dragging == nil, "no drag in flight")
            let close = try #require(column.firstRowClose, "the first row's ✕")
            await column.click(at: CGPoint(x: close.midX, y: close.midY))
            #expect(column.workspace.openNotes.shown == Array(column.notes.dropFirst()),
                    "the ✕ closed its row: \(column.workspace.openNotes.shown)")
            let row = try #require(column.list?.firstRow, "the new first row's box")
            await column.click(at: CGPoint(x: row.minX + 24, y: row.midY))
            #expect(column.workspace.focusedSelection == .post(column.notes[1]),
                    "a click on the row opened its note: \(String(describing: column.workspace.focusedSelection))")
        }
    }

    /// **P-U2d-2 — the end zone, as laid out; RED ON OLD (R-Q).** Directly
    /// under the rows, inside the column, never past the sync footer: with
    /// room, the book navigator's 28 pt and the column's bottom padding under
    /// it; when the rows fill the list (it scrolls), the padding's 12 pt — a
    /// list that scrolls keeps its last-slot target.
    ///
    /// **U2d — edited in place by P-U2d-2** (was
    /// `theEndZoneTakesTheRoomUnderTheRowsAndNothingMore`, whose zone was
    /// absent once the rows filled the list).
    @Test func theEndZoneIsAlwaysUnderTheRowsAndNeverPastTheFooter() async throws {
        try await withColumn(height: 900, openNotes: 4, startOn: 0) { column in
            let zone = try #require(column.endZone, "a short list has an end zone")
            let list = try #require(column.list?.scroll)
            let outer = try #require(column.column)
            let whole = SidebarLayout.OpenListDrop.endZoneMaxHeight + SidebarLayout.contentBottomPadding
            #expect(abs(zone.height - whole) <= 0.5, "28 pt and the padding: \(zone)")
            #expect(abs(zone.minY - list.maxY) <= 0.5, "right under the rows: zone \(zone), list \(list)")
            #expect(zone.maxY <= outer.maxY + 0.5, "inside the column: zone \(zone), column \(outer)")
        }
        try await withColumn(height: 900, openNotes: 20, startOn: 0) { column in
            let zone = try #require(column.endZone, "a list that scrolls keeps its end zone (P-U2d-2)")
            let list = try #require(column.list?.scroll)
            let outer = try #require(column.column)
            #expect(abs(zone.height - SidebarLayout.contentBottomPadding) <= 0.5, "the padding's 12 pt: \(zone)")
            #expect(abs(zone.minY - list.maxY) <= 0.5, "right under the list: zone \(zone), list \(list)")
            #expect(abs(zone.maxY - outer.maxY) <= 1.5, "down to the footer's edge: zone \(zone), column \(outer)")
        }
    }
}
