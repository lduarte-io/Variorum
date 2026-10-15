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

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
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

    /// **RED ON OLD (R-K).** A drag of row a, hovering b's lower half, draws the
    /// line after b — and the release lands a exactly there.
    @Test func aDropLandsWhereTheLineWasDrawn() throws {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.hoverRows(contentY: 50)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "the line after b")
        #expect(OpenListDropDoor.proposal(state, rows: ids, rowHeight: 30).operation == .move)
        let gap = try #require(state.gap(rows: ids.count, rowHeight: 30))
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.land(token, atGap: gap, listID: state.listID, in: workspace, animation: nil))
        #expect(workspace.openNotes.ids == ["b", "a", "c", "d"])
    }

    /// The end zone names the last slot, and the release lands there.
    @Test func theEndZoneLandsTheLastSlot() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("b")
        state.hoverEnd()
        #expect(state.gap(rows: 4, rowHeight: 30) == 4)
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 118, "the line at the list's end")
        let token = SidebarView.OpenNoteDragToken(noteID: "b", listID: state.listID)
        #expect(OpenListDropDoor.land(token, atGap: 4, listID: state.listID, in: workspace, animation: nil))
        #expect(workspace.openNotes.ids == ["a", "c", "d", "b"])
        // …and the last row over the end zone would change nothing: no offer.
        state.began("b")
        state.hoverEnd()
        #expect(OpenListDropDoor.proposal(state, rows: ["a", "c", "d", "b"], rowHeight: 30).operation
                == .forbidden)
    }

    /// §12's false-offer rule at the door: on the dragged row's own place the
    /// drop offers nothing (the image slides back) and the landing moves
    /// nothing.
    @Test func aDropOnItsOwnPlaceOffersNothingAndMovesNothing() throws {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("b")
        for y: CGFloat in [32, 44, 46, 58, 62, 70] {  // b's halves and c's upper half
            state.hoverRows(contentY: y)
            #expect(state.lineTop(rows: ids, rowHeight: 30) == nil, "no line at \(y)")
            #expect(OpenListDropDoor.proposal(state, rows: ids, rowHeight: 30).operation == .forbidden)
            let gap = try #require(state.gap(rows: 4, rowHeight: 30))
            let token = SidebarView.OpenNoteDragToken(noteID: "b", listID: state.listID)
            #expect(!OpenListDropDoor.land(token, atGap: gap, listID: state.listID, in: workspace, animation: nil))
        }
        #expect(workspace.openNotes.ids == ids)
    }

    /// PROVISIONAL P-U2-3: a drop acts only on the list its drag began in — a
    /// row dragged from another window's Open list moves nothing here, even
    /// when this list holds the same note.
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
        here.hoverRows(contentY: 80)
        #expect(here.lineTop(rows: ids, rowHeight: 30) == nil)
    }

    /// The scroll axis through the state: a scroll under a still pointer moves
    /// the gap (the window is copied in only while a drag hovers).
    @Test func aScrollUnderAStillPointerMovesTheGap() {
        let ids = (0..<10).map { "n\($0)" }
        let state = OpenListDragState()
        state.read(reading(offset: 0, rows: 10))
        state.began("n9")
        state.hoverRows(contentY: 50)  // viewport 50
        #expect(state.gap(rows: 10, rowHeight: 30) == 2)
        state.read(reading(offset: 30, rows: 10))
        #expect(state.gap(rows: 10, rowHeight: 30) == 3, "content 80 now: c's lower half")
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 59, "the boundary at 90, 60 on screen")
        state.leftRows()
        #expect(state.lineTop(rows: ids, rowHeight: 30) == nil, "the drag left: no line")
    }

    /// Leaving the rows for the end zone (or back) never blanks the line in
    /// between, whichever exit arrives last.
    @Test func movingBetweenTheRowsAndTheEndZoneKeepsTheLine() {
        let ids = ["a", "b", "c", "d"]
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.hoverRows(contentY: 110)
        state.hoverEnd()      // the zone entered before…
        state.leftRows()      // …the rows' exit arrived
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 118)
        state.hoverRows(contentY: 110)
        state.leftEnd()
        #expect(state.lineTop(rows: ids, rowHeight: 30) == 118)
    }

    /// The release reads the PAYLOAD and lands it (the whole road a real drop
    /// takes after AppKit, short of the pointer): the gap the line named, the
    /// token loaded from its item provider, the move.
    @Test func aReleaseReadsThePayloadAndLandsIt() async throws {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("a")
        state.hoverRows(contentY: 105)  // d's lower half: the end
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        let provider = NSItemProvider()
        provider.register(token)
        #expect(OpenListDropDoor.perform([provider], state: state, rows: ids, rowHeight: 30, workspace: workspace))
        #expect(state.dragging == nil && state.hover == nil, "the drop ends the drag")
        for _ in 0..<200 where workspace.openNotes.ids == ids {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(workspace.openNotes.ids == ["b", "c", "d", "a"])
    }

    /// A release with no payload, or where the line offered nothing, refuses
    /// (the image slides back) — and either way the drag is over.
    @Test func aReleaseThatOffersNothingRefuses() {
        let ids = ["a", "b", "c", "d"]
        let workspace = workspace(ids)
        let state = OpenListDragState()
        state.read(reading())
        state.began("b")
        state.hoverRows(contentY: 40)  // its own upper half
        let own = SidebarView.OpenNoteDragToken(noteID: "b", listID: state.listID)
        let provider = NSItemProvider()
        provider.register(own)
        #expect(!OpenListDropDoor.perform([provider], state: state, rows: ids, rowHeight: 30, workspace: workspace))
        #expect(state.dragging == nil)
        state.began("a")
        state.hoverRows(contentY: 80)
        #expect(!OpenListDropDoor.perform([], state: state, rows: ids, rowHeight: 30, workspace: workspace))
        #expect(workspace.openNotes.ids == ids)
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
    /// chip and is NOT its own drop target any more; the list's content is the
    /// one drop, the end zone sits under it, the line lies over it.
    @Test func theRowDragsItsChipAndTheListIsTheOneDrop() throws {
        let source = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Library/SidebarView.swift"),
            encoding: .utf8)
        let start = try #require(source.range(of: "private func openRow("))
        let row = String(source[start.upperBound...].prefix(9_000))
        #expect(row.contains("ChipDragSource(") && row.contains("Self.openRowChip("),
                "the row's drag image is its title chip at the grab point")
        #expect(!row.contains("dropDestination("), "no row is its own drop target (each landed before itself)")
        #expect(source.contains("delegate: OpenListRowsDrop("), "the list's rows are one drop target")
        #expect(source.contains("openListEndZone(shown)"), "the end zone sits under the rows")
        #expect(source.contains(".overlay { openListLine(shown) }"), "the line lies over the list")
        let shelf = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Shelf/ShelfView.swift"),
            encoding: .utf8)
        #expect(shelf.contains("ChipDragSource(") && shelf.contains("DragChipCanvas("),
                "the Bookcase reads the same shared chip machinery (one home)")
        #expect(!shelf.contains("struct GrabCanvas"), "no second copy of the canvas")
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
    /// rule says, and RE-DERIVES on every input axis: the hover moving, the
    /// list scrolling under a still pointer, the list changing under it; it
    /// lights nowhere a drop would change nothing, and goes when the drag
    /// leaves.
    @Test func theLineDrawsWhereTheDropWouldLandOnEveryAxis() async throws {
        // 700 pt: twenty rows overflow the list by several rows (it scrolls).
        try await withColumn(height: 700, openNotes: 20, startOn: nil) { column in
            let drag = try #require(column.drag, "the column's drag state")
            let pitch = column.pitch
            #expect(pitch >= 24, "the list is laid out: \(pitch)")
            #expect(column.line == nil, "no drag, no line")

            // Hover: row 3 dragged, the pointer on row 7's lower half → the
            // line on the boundary after row 7.
            drag.began(column.notes[2])
            drag.hoverRows(contentY: 6.7 * pitch)
            await column.settle()
            let first = try #require(column.lineTopInList, "the line is drawn")
            #expect(abs(first - (7 * pitch - 1)) <= 0.5, "after row 7: \(first) at pitch \(pitch)")
            #expect(abs(first - (column.lineTopByRule ?? -99)) <= 0.5)

            // Hover moves: onto row 9's upper half → the boundary before row 9.
            let pointer = 8.2 * pitch
            drag.hoverRows(contentY: pointer)
            await column.settle()
            let moved = try #require(column.lineTopInList)
            #expect(abs(moved - (8 * pitch - 1)) <= 0.5, "before row 9: \(moved)")

            // Scroll: the list scrolls 1.5 rows under the STILL pointer — the
            // gap under it changes, and the line is redrawn where the rule
            // now says (never left where the old reading put it).
            try await column.scrollList(to: 1.5 * pitch)
            let reading = try #require(column.list?.window)
            #expect(abs(reading.offset - 1.5 * pitch) <= 1, "the list scrolled: \(reading)")
            let scrolled = try #require(column.lineTopInList, "still drawn after the scroll")
            let wanted = try #require(SidebarLayout.OpenListDrop.lineTop(
                hover: .rows(viewportY: pointer), dragged: 2, rows: 20, rowHeight: pitch, window: reading))
            #expect(abs(scrolled - wanted) <= 0.5, "re-derived on the scroll: \(scrolled) vs \(wanted)")
            #expect(abs(scrolled - moved) >= pitch / 2 - 0.5, "it really moved: \(moved) → \(scrolled)")

            // List change: a row above closes — the line re-derives from the
            // rows as they now stand…
            column.workspace.closeNote(column.notes[0])
            await column.settle()
            let afterClose = try #require(column.lineTopInList, "still drawn after a row closed")
            #expect(abs(afterClose - (column.lineTopByRule ?? -99)) <= 0.5,
                    "re-derived on the list's change: \(afterClose) vs \(String(describing: column.lineTopByRule))")
            // …and when the list changes so the gap under the pointer becomes
            // the dragged row's own (the row now sits just before it), the
            // line goes: a drop there would change nothing.
            let gap = try #require(drag.gap(rows: column.workspace.openNotes.shown.count, rowHeight: column.pitch))
            let draggedAt = try #require(column.workspace.openNotes.shown.firstIndex(of: column.notes[2]))
            column.workspace.moveOpenNotes(fromOffsets: IndexSet(integer: draggedAt), toOffset: gap)
            await column.settle()
            #expect(column.workspace.openNotes.shown.firstIndex(of: column.notes[2]) == gap - 1)
            #expect(column.line == nil, "the gap under the pointer is the dragged row's own now: no line")

            // The pointer on the dragged row itself — no line either.
            let draggedRow = gap - 1
            drag.hoverRows(contentY: (CGFloat(draggedRow) + 0.3) * column.pitch)
            await column.settle()
            #expect(column.line == nil, "on the dragged row's own place nothing lights")

            // Elsewhere it lights; and when the drag leaves the list, it goes.
            drag.hoverRows(contentY: (CGFloat(draggedRow) + 3.7) * column.pitch)
            await column.settle()
            #expect(column.line != nil)
            drag.leftRows()
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

    /// **The end zone, as laid out** — directly under the rows when the
    /// column has room, the book navigator's 28 pt, never pushing the column
    /// past the sync footer; absent when the rows fill the list.
    @Test func theEndZoneTakesTheRoomUnderTheRowsAndNothingMore() async throws {
        try await withColumn(height: 900, openNotes: 4, startOn: 0) { column in
            let zone = try #require(column.endZone, "a short list has an end zone")
            let list = try #require(column.list?.scroll)
            let outer = try #require(column.column)
            #expect(abs(zone.height - SidebarLayout.OpenListDrop.endZoneMaxHeight) <= 0.5, "28 pt: \(zone)")
            #expect(abs(zone.minY - list.maxY) <= 0.5, "right under the rows: zone \(zone), list \(list)")
            #expect(zone.maxY <= outer.maxY - SidebarLayout.contentBottomPadding + 0.5,
                    "inside the column, above the footer's air: zone \(zone), column \(outer)")
        }
        try await withColumn(height: 900, openNotes: 20, startOn: 0) { column in
            #expect(column.endZone == nil, "the rows fill the list: the last row's lower half is the end")
        }
    }
}
