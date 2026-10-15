//
//  SidebarSectionWindowTests.swift
//  VariorumTests
//
//  VX-283 run, U1b — the fix leg of U1, from the orchestrator's eye on U1's
//  walk:
//  · F-1 (the walker's O-1) — the note she had just opened could sit with its
//    highlighted Open-list row cut at the list's bottom edge. The reveal was
//    one minimal `scrollTo` per newest note, issued against whatever viewport
//    stood when it ran; the list's viewport is a function of measurements that
//    land a pass later, and returning to the note she was already in never
//    revealed at all (its recency did not change).
//  · F-2 (PROVISIONAL P-U1-6, the orchestrator's ruling) — a scrolled section
//    sliced its partial row through the letters under its header. Both
//    scrolling sections now fade each edge over about half a row, only where
//    content lies beyond it.
//
//  This file holds the PURE rules (`SidebarLayout`'s window brain). The
//  mounted pins — what the sections actually do in a window, red on old by
//  behavioural revert — are below them (the U1b record names the reverts).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure rules

@Suite("U1b — a scrolling section's window: the edge fades (F-2) and the reveal (F-1)")
struct SidebarSectionWindowRuleTests {
    private typealias Window = SidebarLayout.ScrollWindow
    private typealias Fades = SidebarLayout.EdgeFades

    private let rowHeight: CGFloat = 30
    private var depth: CGFloat { SidebarLayout.edgeFadeDepth(rowHeight: rowHeight) }

    /// Twenty rows (600 pt) under a 250-pt window — eight and a third rows.
    private func window(at offset: CGFloat, viewport: CGFloat = 250, content: CGFloat = 600) -> Window {
        Window(offset: offset, viewport: viewport, content: content)
    }

    /// What `ScrollViewProxy.scrollTo(_:anchor:)` does with the anchor: the
    /// row's top lands `y × (viewport − rowHeight)` below the window's top,
    /// clamped to the content (a scroll view never scrolls past its ends).
    private func landing(row: Int, anchor: CGFloat, in start: Window) -> Window {
        let top = CGFloat(row) * rowHeight
        let wanted = top - anchor * (start.viewport - rowHeight)
        let limit = max(0, start.content - start.viewport)
        return Window(offset: min(max(wanted, 0), limit), viewport: start.viewport, content: start.content)
    }

    @Test func theFadeIsAboutHalfARow() {
        #expect(SidebarLayout.edgeFadeDepth(rowHeight: 30) == 15)
        #expect(SidebarLayout.edgeFadeDepth(rowHeight: 24) == 12)
    }

    /// The orchestrator's ruling, in its own words: the top fades only when
    /// scrolled down, the bottom only when more lies below.
    @Test func anEdgeFadesOnlyWhereContentLiesBeyondIt() {
        #expect(SidebarLayout.edgeFades(window(at: 0), depth: depth) == Fades(top: 0, bottom: 15),
                "at rest: nothing above, more below")
        #expect(SidebarLayout.edgeFades(window(at: 200), depth: depth) == Fades(top: 15, bottom: 15),
                "mid-list: more both ways")
        #expect(SidebarLayout.edgeFades(window(at: 350), depth: depth) == Fades(top: 15, bottom: 0),
                "at the end: more above, nothing below")
    }

    /// The depth is the content beyond the edge, capped at the half row — so
    /// the fade eases in as the list starts to move instead of popping in.
    @Test func theFadeEasesInWithTheContentBeyondTheEdge() {
        #expect(SidebarLayout.edgeFades(window(at: 4), depth: depth) == Fades(top: 4, bottom: 15))
        #expect(SidebarLayout.edgeFades(window(at: 342), depth: depth) == Fades(top: 15, bottom: 8))
        #expect(SidebarLayout.edgeFades(window(at: 0.3), depth: depth) == Fades(top: 0, bottom: 15),
                "a rounding hair beyond an edge is not more")
    }

    @Test func aWindowThatHoldsEverythingFadesNowhere() {
        #expect(SidebarLayout.edgeFades(window(at: 0, viewport: 250, content: 250), depth: depth) == .none)
        #expect(SidebarLayout.edgeFades(window(at: 0, viewport: 300, content: 250), depth: depth) == .none)
        #expect(SidebarLayout.edgeFades(.unmeasured, depth: depth) == .none)
    }

    @Test func aRowClearOfTheFadesIsLeftWhereItIs() {
        // Window 100…350 fades 100…115 and 335…350; row 5 is 150…180.
        #expect(SidebarLayout.revealAnchor(
            row: 5, rows: 20, rowHeight: rowHeight, window: window(at: 100), depth: depth) == nil)
        // The first row at rest, the last at the end — nothing beyond either to fade.
        #expect(SidebarLayout.revealAnchor(
            row: 0, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == nil)
        #expect(SidebarLayout.revealAnchor(
            row: 19, rows: 20, rowHeight: rowHeight, window: window(at: 350), depth: depth) == nil)
    }

    /// **F-2 meets F-1:** a row wholly inside the viewport but under the
    /// bottom fade is NOT in view — the minimal `scrollTo` the old reveal used
    /// would leave it there, half washed out. It is revealed one fade's depth
    /// above the bottom edge.
    @Test func aRowUnderTheBottomFadeIsRevealedClearOfIt() throws {
        // Row 7 is 210…240; the bottom fade covers 235…250.
        let start = window(at: 0)
        let anchor = try #require(SidebarLayout.revealAnchor(
            row: 7, rows: 20, rowHeight: rowHeight, window: start, depth: depth))
        #expect(abs(anchor - (220 - 15) / 220) < 0.0001)
        let landed = landing(row: 7, anchor: anchor, in: start)
        #expect(abs(landed.offset - 5) < 0.001, "the row's bottom lands 15 pt above the window's: offset \(landed.offset)")
    }

    @Test func theLastRowLandsOnTheBottomEdgeAndTheFirstOnTheTop() {
        #expect(SidebarLayout.revealAnchor(
            row: 19, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == 1)
        #expect(SidebarLayout.revealAnchor(
            row: 0, rows: 20, rowHeight: rowHeight, window: window(at: 300), depth: depth) == 0)
    }

    /// **The reveal is a fixed point:** from any window, every row lands
    /// wholly in view and clear of both fades, and asking again asks nothing.
    @Test func everyRowLandsClearOfTheFadesFromAnyWindow() throws {
        for (viewport, rows) in [(CGFloat(250), 20), (CGFloat(105), 20), (CGFloat(225), 9)] {
            let content = CGFloat(rows) * rowHeight
            for start in stride(from: CGFloat(0), through: max(0, content - viewport), by: 7) {
                let from = window(at: start, viewport: viewport, content: content)
                for row in 0..<rows {
                    var landed = from
                    if let anchor = SidebarLayout.revealAnchor(
                        row: row, rows: rows, rowHeight: rowHeight, window: from, depth: depth) {
                        landed = landing(row: row, anchor: anchor, in: from)
                    }
                    let fades = SidebarLayout.edgeFades(landed, depth: depth)
                    let top = CGFloat(row) * rowHeight
                    #expect(top >= landed.offset + fades.top - 0.5,
                            "row \(row) from \(start) (window \(viewport)): top \(top) under the top fade")
                    #expect(top + rowHeight <= landed.offset + viewport - fades.bottom + 0.5,
                            "row \(row) from \(start) (window \(viewport)): bottom under the bottom fade")
                    #expect(SidebarLayout.revealAnchor(
                        row: row, rows: rows, rowHeight: rowHeight, window: landed, depth: depth) == nil,
                            "row \(row) from \(start): a second ask moves nothing")
                }
            }
        }
    }

    @Test func nothingIsRevealedBeforeTheWindowIsMeasuredOrForARowThatIsNotThere() {
        #expect(SidebarLayout.revealAnchor(
            row: 15, rows: 20, rowHeight: rowHeight, window: .unmeasured, depth: depth) == nil)
        #expect(SidebarLayout.revealAnchor(
            row: 20, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == nil)
        #expect(SidebarLayout.revealAnchor(
            row: -1, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == nil)
    }
}
