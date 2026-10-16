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

    /// **P-U2d-1 (b) — RED ON OLD (R-X).** A targeted row names the slot
    /// BEFORE it — its own index; the end zone names the slot after the last
    /// row; a row off the list, or a list with no rows, names nothing.
    @Test func theTargetedRowNamesTheSlotBeforeItAndTheEndZoneTheLast() {
        for count in 1...8 {
            for row in 0..<count {
                #expect(Drop.gap(for: .row(row), rows: count) == row, "row \(row) of \(count): the slot before it")
            }
            #expect(Drop.gap(for: .row(count), rows: count) == nil, "a row past the list names nothing")
            #expect(Drop.gap(for: .row(-1), rows: count) == nil, "a row before the list names nothing")
            #expect(Drop.gap(for: .end, rows: count) == count, "the end zone: the slot after the last row")
        }
        #expect(Drop.gap(for: .row(0), rows: 0) == nil, "no rows: no slot")
        #expect(Drop.gap(for: .end, rows: 0) == nil, "no rows: no end")
    }

    /// **P-U2d-1 (b), exhaustively — RED ON OLD (R-X).** Every list of 1…6
    /// rows, every dragged row, every target: a drop on another row lands the
    /// dragged row right BEFORE it; a drop in the end zone lands it last; on
    /// its own place — its own row, or the row right after it, and the end
    /// zone when it is already last — nothing moves.
    @Test func everyDropLandsBeforeTheTargetedRow() {
        for count in 1...6 {
            let ids = (0..<count).map { "r\($0)" }
            for (from, dragged) in ids.enumerated() {
                for (row, target) in ids.enumerated() {
                    let after = dropping(dragged, onto: .row(row), in: ids)
                    #expect(Set(after) == Set(ids) && after.count == ids.count, "rows survive")
                    if row == from || row == from + 1 {
                        #expect(after == ids, "\(dragged) onto \(target) (its own place, \(count) rows): nothing moves")
                    } else {
                        #expect(after.firstIndex(of: dragged)! == after.firstIndex(of: target)! - 1,
                                "\(dragged) onto \(target) (\(count) rows) lands right before it: \(after)")
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

    /// **The ticket's three, in F2's terms — RED ON OLD (R-X).** Every slot
    /// the dragged row can move to is reached by exactly one target (the row
    /// that will follow it, or the end zone): the row just below her row is
    /// passed by dropping on the row after it; a long downward drop lands
    /// before the row it is released on; the last slot is the end zone's.
    @Test func everySlotIsReachedByExactlyOneTarget() {
        for count in 1...6 {
            for dragged in 0..<count {
                for gap in 0...count where gap != dragged && gap != dragged + 1 {
                    let targets: [Drop.Hover] = (0..<count).map { .row($0) } + [.end]
                    let naming = targets.filter { Drop.gap(for: $0, rows: count) == gap }
                    #expect(naming.count == 1, "gap \(gap) of \(count) (row \(dragged) dragged): \(naming)")
                    #expect(Drop.destination(gap: gap, dragged: dragged, rows: count) == gap)
                }
            }
        }
        #expect(dropping("a", onto: .row(2), in: rows) == ["b", "a", "c", "d"], "just below b: drop on c")
        #expect(dropping("a", onto: .row(3), in: rows) == ["b", "c", "a", "d"], "released on d: before d")
        #expect(dropping("a", onto: .end, in: rows) == ["b", "c", "d", "a"], "the last slot: the end zone")
        #expect(dropping("d", onto: .row(1), in: rows) == ["a", "d", "b", "c"], "upward: before b")
        #expect(dropping("d", onto: .row(0), in: rows) == ["d", "a", "b", "c"], "the top")
    }

    /// §12's false-offer rule: the dragged row's own two gaps would change
    /// nothing — no destination there (so no line, and no drop); every other
    /// gap moves it.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the last two lines named the
    /// half-row rule's pointer heights; they name the two own-place targets
    /// now (its own row, and the row right after it). The loop is unchanged.
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
        #expect(dropping("b", onto: .row(1), in: rows) == rows, "its own row: nothing moves")
        #expect(dropping("b", onto: .row(2), in: rows) == rows, "the row right after it = b's own lower gap")
    }

    // MARK: - The line (the overlay/sink delivery law: target, scroll, list change)

    private func window(offset: CGFloat = 0, viewport: CGFloat = 120, content: CGFloat = 120)
        -> SidebarLayout.ScrollWindow {
        SidebarLayout.ScrollWindow(offset: offset, viewport: viewport, content: content)
    }

    /// **P-U2d-1 (b) — RED ON OLD (R-X).** The line sits at the TARGETED
    /// row's top, centred on that boundary, in the viewport — held inside the
    /// rows at both ends; the end zone's line at the last row's bottom; none
    /// on the dragged row's own place.
    @Test func theLineSitsAtTheTargetedRowsTop() {
        let w = window()
        #expect(Drop.lineTop(hover: .row(2), dragged: 3, rows: 4, rowHeight: 30, window: w) == 59,
                "c targeted: its top (the b/c boundary) at 60, the 2-pt line from 59")
        #expect(Drop.lineTop(hover: .row(1), dragged: 3, rows: 4, rowHeight: 30, window: w) == 29)
        #expect(Drop.lineTop(hover: .row(0), dragged: 3, rows: 4, rowHeight: 30, window: w) == 0,
                "the first row's top is held inside the rows, never half off the top")
        #expect(Drop.lineTop(hover: .end, dragged: 0, rows: 4, rowHeight: 30, window: w) == 118,
                "the end zone: the last row's bottom, held inside the rows")
        #expect(Drop.lineTop(hover: .row(3), dragged: 3, rows: 4, rowHeight: 30, window: w) == nil,
                "the dragged row targeted: its own place, no line")
        #expect(Drop.lineTop(hover: .row(0), dragged: 0, rows: 4, rowHeight: 30, window: w) == nil)
        #expect(Drop.lineTop(hover: .row(1), dragged: 0, rows: 4, rowHeight: 30, window: w) == nil,
                "the row right after the dragged one: its own lower gap, no line")
    }

    /// **P-U2d-1 (c), the pure half — RED ON OLD (R-X).** A change of target
    /// moves the line: row by row down the list, then the end zone.
    @Test func aTargetChangeMovesTheLine() {
        let w = window()
        let tops = ([.row(0), .row(1), .row(2), .row(3), .end] as [Drop.Hover]).map {
            Drop.lineTop(hover: $0, dragged: 0, rows: 4, rowHeight: 30, window: w)
        }
        #expect(tops == [nil, nil, 59, 89, 118],
                "a's own row and the row right after it offer nothing; then c's top, d's top, the end")
    }

    /// The scroll axis: the line rides its targeted row — read against the
    /// list's offset as it now stands; a top scrolled past the window's top
    /// edge shows AT that edge. RED ON OLD (R-X).
    @Test func theLineRidesTheTargetedRowThroughAScroll() {
        func top(_ offset: CGFloat) -> CGFloat? {
            Drop.lineTop(hover: .row(3), dragged: 9, rows: 10, rowHeight: 30,
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
    /// pointer's height.
    @Test func theLineFollowsAChangeOfTheList() {
        let w = window(viewport: 120, content: 120)
        #expect(Drop.lineTop(hover: .row(2), dragged: 2, rows: 4, rowHeight: 30, window: w) == nil,
                "the dragged row itself targeted")
        #expect(Drop.lineTop(hover: .row(1), dragged: 1, rows: 3, rowHeight: 30, window: w) == nil,
                "a row above it closed: the same row, one place up — still its own")
        #expect(Drop.lineTop(hover: .row(2), dragged: 3, rows: 4, rowHeight: 30, window: w) == 59)
        #expect(Drop.lineTop(hover: .row(2), dragged: 3, rows: 4, rowHeight: 24,
                             window: window(viewport: 96, content: 96)) == 47,
                "at 24 pt c's top is at 48")
    }

    /// Never computed before layout exists: no reading, no pitch, no rows, no
    /// drag of this list's — no line.
    ///
    /// **U2d (P-U2d-1) — edited in place:** the hover is a targeted row.
    @Test func noLineBeforeTheListIsReadOrWithoutADragOfItsOwn() {
        let hover = Drop.Hover.row(1)
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
    @Test func theLineStaysInsideTheWindow() {
        // Row 1 targeted in a window scrolled to 40: its top (30) is 10 pt
        // above the window.
        #expect(Drop.lineTop(hover: .row(1), dragged: 9, rows: 10, rowHeight: 30,
                             window: window(offset: 40, viewport: 120, content: 300)) == 0)
        // …and row 6 in one scrolled to 50: its top (180) is 10 pt below it.
        #expect(Drop.lineTop(hover: .row(6), dragged: 0, rows: 10, rowHeight: 30,
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
    @Test func aDropLandsWhereTheLineWasDrawn() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.targeted(.row("c"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "the line at c's top")
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .row("c"), state: state, workspace: workspace,
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
    @Test func aDropOnItsOwnPlaceOffersNothingAndMovesNothing() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        for target: OpenListDragState.Target in [.row("b"), .row("c")] {
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
        here.targeted(.row("d"), true)
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
        state.targeted(.row("n3"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 89, "n3's top at 90")
        state.read(reading(offset: 30, rows: 10))
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "scrolled 30: the line rode its row up")
        state.targeted(.row("n3"), false)
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
        state.targeted(.row("c"), true)
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
        state.targeted(.row("d"), true)
        state.targeted(.end, true)          // the zone targeted before…
        state.targeted(.row("d"), false)    // …the row's un-target arrived
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 118)
        state.targeted(.row("d"), true)
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
        state.targeted(.row("b"), true)
        let own = SidebarView.OpenNoteDragToken(noteID: "b", listID: state.listID)
        #expect(!OpenListDropDoor.perform([own], onto: .row("b"), state: state, workspace: workspace,
                                          animation: nil))
        #expect(state.dragging == nil)
        state.began("a")
        state.targeted(.row("d"), true)
        #expect(!OpenListDropDoor.perform([], onto: .row("d"), state: state, workspace: workspace,
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
        state.targeted(.row("c"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "c's top")
        state.targeted(.row("d"), true)     // the next row targeted before…
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 89, "the target moved: d's top")
        state.targeted(.row("c"), false)    // …the last one's un-target arrived
        #expect(state.target == .row("d"), "d's target stands")
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 89)
        state.targeted(.row("d"), false)
        #expect(state.target == nil && state.lineTop(rows: ids, rowHeight: 30) == nil, "the drag left the rows")
        state.targeted(.row("b"), true)
        state.targeted(.row("b"), false)    // the other order: the un-target first…
        state.targeted(.row("c"), true)     // …then the next row's target
        #expect(state.target == .row("c"))
        state.targeted(.end, true)
        state.targeted(.row("c"), false)    // a row's late un-target leaves the end zone's
        #expect(state.target == .end)
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
        state.targeted(.row("d"), true)
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .row("d"), state: state, workspace: workspace))
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
        state.targeted(.row("c"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "a's drag with c targeted")
        state.dragSessionUpdated(.active)
        #expect(state.dragging == "a", "a session in flight keeps its drag")
        state.dragSessionUpdated(.ended(.cancel))
        #expect(state.dragging == nil && state.target == nil, "the session ended: the drag is over")
        // A foreign drag (another window's list) targeting a row after the
        // cancel: no line.
        state.targeted(.row("d"), true)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == nil)
        state.targeted(.row("d"), false)
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
        state.targeted(.row("c"), true)               // the line at c's top
        state.dragSessionUpdated(.ended(.copy))       // the source's end FIRST
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .row("c"), state: state, workspace: workspace,
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
        for (name, body, target) in [("OpenListRowDrop", rowDrop, ".row(noteID)"),
                                     ("OpenListEndZoneDrop", endDrop, ".end")] {
            #expect(body.contains(".dropDestination(for: SidebarView.OpenNoteDragToken.self) {"),
                    "\(name): main's per-row Transferable drop")
            #expect(body.contains("} isTargeted: {"), "\(name): isTargeted marks the target")
            #expect(body.contains("OpenListDropDoor.perform(tokens, onto: \(target), state: state, workspace: workspace)"),
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
            drag.began(column.notes[2])
            drag.targeted(.row(column.notes[7]), true)
            await column.settle()
            let first = try #require(column.lineTopInList, "the line is drawn")
            #expect(abs(first - (7 * pitch - 1)) <= 0.5, "at row 8's top: \(first) at pitch \(pitch)")
            #expect(abs(first - (column.lineTopByRule ?? -99)) <= 0.5)

            // The target moves — the next row's target, then the last one's
            // un-target — onto row 10: the line at its top.
            drag.targeted(.row(column.notes[9]), true)
            drag.targeted(.row(column.notes[7]), false)
            await column.settle()
            let moved = try #require(column.lineTopInList)
            #expect(abs(moved - (9 * pitch - 1)) <= 0.5, "at row 10's top: \(moved)")

            // Scroll: the list scrolls 1.5 rows under the same target — the
            // line rides its row, redrawn where the rule now says.
            try await column.scrollList(to: 1.5 * pitch)
            let reading = try #require(column.list?.window)
            #expect(abs(reading.offset - 1.5 * pitch) <= 1, "the list scrolled: \(reading)")
            let scrolled = try #require(column.lineTopInList, "still drawn after the scroll")
            let wanted = try #require(SidebarLayout.OpenListDrop.lineTop(
                hover: .row(9), dragged: 2, rows: 20, rowHeight: pitch, window: reading))
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
            drag.targeted(.row(column.notes[2]), true)
            await column.settle()
            #expect(column.line == nil, "on the dragged row's own place nothing lights")

            // Elsewhere it lights; and when the drag leaves the rows, it goes.
            drag.targeted(.row(column.notes[15]), true)
            await column.settle()
            #expect(column.line != nil)
            drag.targeted(.row(column.notes[15]), false)
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
