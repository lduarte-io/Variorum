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

/// A whole fade at `depth`: the full half row at full strength (U1d).
extension SidebarLayout.EdgeFade {
    static func whole(_ depth: CGFloat) -> Self { Self(depth: depth, strength: 1) }
}

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

    @Test func theFadeIsAboutHalfARow() {
        #expect(SidebarLayout.edgeFadeDepth(rowHeight: 30) == 15)
        #expect(SidebarLayout.edgeFadeDepth(rowHeight: 24) == 12)
    }

    /// A whole fade: the full half row at full strength.
    private var full: SidebarLayout.EdgeFade { SidebarLayout.EdgeFade(depth: depth, strength: 1) }

    /// The orchestrator's ruling, in its own words: the top fades only when
    /// scrolled down, the bottom only when more lies below. (U1d: the values
    /// are `EdgeFade`s now — depth AND strength — her ruling on the memo; the
    /// pin's meaning is unchanged.)
    @Test func anEdgeFadesOnlyWhereContentLiesBeyondIt() {
        #expect(SidebarLayout.edgeFades(window(at: 0), depth: depth) == Fades(top: .none, bottom: full),
                "at rest: nothing above, more below")
        #expect(SidebarLayout.edgeFades(window(at: 200), depth: depth) == Fades(top: full, bottom: full),
                "mid-list: more both ways")
        #expect(SidebarLayout.edgeFades(window(at: 350), depth: depth) == Fades(top: full, bottom: .none),
                "at the end: more above, nothing below")
    }

    /// **U1d — her ruling on the memo, *"The fade, reshaped"*** (REWRITTEN from
    /// U1b's `theFadeEasesInWithTheContentBeyondTheEdge`, whose DEPTH eased —
    /// her words now: *"always half a row deep when there's more beyond, easing
    /// in (its strength, not its depth) so it doesn't pop"*). Past the slack the
    /// depth is the whole half row at once; the strength is the content beyond
    /// over that half row, whole from a half row on (PROVISIONAL P-U1d-2).
    /// RED ON OLD (R-J): U1b's rule answered depths of 4 and 8 here.
    ///
    /// **P-U1e-1 changed this pin's NUMBERS in place** (the orchestrator's
    /// ruling on U1d's re-walk — R4 sliced at 7–9 pt short): the strength now
    /// reaches whole over the row's own TEXT PADDING (7 pt at this 30-pt pitch,
    /// `edgeFadeRampDistance`), not over the half row; the depth and the
    /// ease-in are unchanged, so is what the pin holds.
    @Test func theFadeIsAlwaysHalfARowDeepAndItsStrengthEasesIn() {
        let ramp = SidebarLayout.edgeFadeRampDistance(rowHeight: rowHeight)
        #expect(ramp == 7, "the 30-pt row's text padding")
        let four = SidebarLayout.edgeFades(window(at: 4), depth: depth)
        #expect(four.top.depth == 15, "4 pt above: the whole half row, never a 4-pt fade")
        #expect(abs(four.top.strength - 4.0 / 7) < 0.0001, "…at a strength of 4/7: \(four.top.strength)")
        #expect(four.bottom == full)
        let three = SidebarLayout.edgeFades(window(at: 347), depth: depth)
        #expect(three.top == full)
        #expect(three.bottom.depth == 15, "3 pt below: the whole half row")
        #expect(abs(three.bottom.strength - 3.0 / 7) < 0.0001, "…at 3/7: \(three.bottom.strength)")
        #expect(SidebarLayout.edgeFades(window(at: 342), depth: depth).bottom == full,
                "8 pt below — past the 7-pt padding: whole strength")
        #expect(SidebarLayout.edgeFades(window(at: 15), depth: depth).top == full,
                "a half row beyond: whole strength")
        #expect(SidebarLayout.edgeFades(window(at: 0.3), depth: depth) == Fades(top: .none, bottom: full),
                "a rounding hair beyond an edge is not more")
        // It arrives faint (the first fade past the slack is a few percent — no
        // pop), then eases monotonically, with no step, over the first few
        // points of scroll (the padding).
        var last = SidebarLayout.edgeFades(window(at: 0.6), depth: depth).top.strength
        #expect(last > 0 && last < 0.1, "the first fade past the slack: \(last)")
        for tenth in 7...300 {
            let strength = SidebarLayout.edgeFades(window(at: CGFloat(tenth) / 10), depth: depth).top.strength
            #expect(strength >= last && strength - last < 0.1 / ramp + 0.0001,
                    "offset \(CGFloat(tenth) / 10): \(last) → \(strength)")
            last = strength
        }
    }

    /// **P-U1e-1 — the fade is WHOLE before the clip can reach ink** (the
    /// orchestrator's ruling on U1d's re-walk, PROVISIONAL: R4 at 7–9 pt short
    /// cut "export: it's all yours" through its descenders under a fade still
    /// weak, because the strength ramped over the half row, 12–15 pt, while the
    /// clip reaches ink inside the row's own padding). The ramp is the row's
    /// text padding at the drawn pitch — the 13-pt line box (16 pt, both
    /// voices) centred: 7 pt at 30, 4 at 24 — and at the MEASURED first ink
    /// (offscreen, both voices, regular and semibold: 7.25 pt above a 30-pt
    /// row's bottom and 9.25 below its top; 4.25 / 6.25 at 24) each edge's fade
    /// stands at full strength. The walk's R4 states, at 30 pt: 5 pt short
    /// eases (5/7), 7 · 9 · 12 whole. RED under R-N (the half-row ramp).
    @Test func theFadeIsWholeBeforeTheClipReachesInk() {
        #expect(SidebarLayout.rowTextLineHeight == 16, "the 13-pt row title's line box")
        #expect(SidebarLayout.edgeFadeRampDistance(rowHeight: 30) == 7)
        #expect(SidebarLayout.edgeFadeRampDistance(rowHeight: 24) == 4)
        for (pitch, bottomInk, topInk) in [(CGFloat(30), CGFloat(7.25), CGFloat(9.25)), (24, 4.25, 6.25)] {
            let depth = SidebarLayout.edgeFadeDepth(rowHeight: pitch)
            let content = pitch * 20
            #expect(SidebarLayout.edgeFadeRampDistance(rowHeight: pitch) <= min(bottomInk, topInk),
                    "the ramp ends inside the padding at \(pitch) pt")
            let bottom = SidebarLayout.edgeFades(
                Window(offset: content - 200 - bottomInk, viewport: 200, content: content), depth: depth).bottom
            #expect(bottom.depth == depth && bottom.strength == 1,
                    "the clip at the first descender (\(bottomInk) pt short at \(pitch)): whole — \(bottom)")
            let top = SidebarLayout.edgeFades(
                Window(offset: topInk, viewport: 200, content: content), depth: depth).top
            #expect(top.depth == depth && top.strength == 1,
                    "the clip at the first ascender (\(topInk) pt above at \(pitch)): whole — \(top)")
        }
        let depth = SidebarLayout.edgeFadeDepth(rowHeight: 30)
        for (short, strength) in [(CGFloat(5), CGFloat(5) / 7), (7, 1), (9, 1), (12, 1)] {
            let fade = SidebarLayout.edgeFades(
                Window(offset: 600 - 250 - short, viewport: 250, content: 600), depth: depth).bottom
            #expect(fade.depth == 15 && abs(fade.strength - strength) < 0.0001,
                    "R4 at \(short) pt short: \(fade)")
        }
    }

    /// **U1d — never fully solid** (her ruling: *"never fully solid so a hint of
    /// the next row always shows"* — the re-walk's O-3, a partial row erased by
    /// the solid outer half). The cap sits below 1 (PROVISIONAL P-U1d-3, chosen
    /// by eye); no edge in any window paints the room at more than it; a whole
    /// fade paints exactly it. And O-2's state — a few points beyond the edge —
    /// is the full half row, faint (here at the compact pitch: 5 pt beyond).
    /// RED ON OLD (R-J): U1b's fade was solid (1) at the edge, and 5 pt deep.
    @Test func theFadeIsNeverFullySolid() {
        #expect(SidebarLayout.edgeFadeCap < 1 && SidebarLayout.edgeFadeCap > 0.5,
                "the cap: \(SidebarLayout.edgeFadeCap)")
        #expect(full.opacity == SidebarLayout.edgeFadeCap)
        for offset in stride(from: CGFloat(0), through: 350, by: 0.5) {
            let fades = SidebarLayout.edgeFades(window(at: offset), depth: depth)
            #expect(fades.top.opacity <= SidebarLayout.edgeFadeCap && fades.bottom.opacity <= SidebarLayout.edgeFadeCap)
        }
        let compact = SidebarLayout.edgeFadeDepth(rowHeight: 24)
        let shallow = SidebarLayout.edgeFades(Window(offset: 31, viewport: 180, content: 216), depth: compact)
        #expect(shallow.bottom.depth == 12, "5 pt beyond: the whole half row (12 at 24 pt), never 5")
        // P-U1e-1 (numbers changed in place): 5 pt is past the compact row's
        // 4-pt text padding, so the fade is whole there — at its cap, never 1 —
        // and 3 pt beyond is the faint state (3/4 of the cap).
        #expect(abs(shallow.bottom.opacity - SidebarLayout.edgeFadeCap) < 0.0001,
                "…whole, at the cap: \(shallow.bottom.opacity)")
        let faint = SidebarLayout.edgeFades(Window(offset: 33, viewport: 180, content: 216), depth: compact)
        #expect(faint.bottom.depth == 12)
        #expect(abs(faint.bottom.opacity - 3.0 / 4 * SidebarLayout.edgeFadeCap) < 0.0001,
                "3 pt beyond: faint — \(faint.bottom.opacity)")
    }

    @Test func aWindowThatHoldsEverythingFadesNowhere() {
        #expect(SidebarLayout.edgeFades(window(at: 0, viewport: 250, content: 250), depth: depth) == .none)
        #expect(SidebarLayout.edgeFades(window(at: 0, viewport: 300, content: 250), depth: depth) == .none)
        #expect(SidebarLayout.edgeFades(.unmeasured, depth: depth) == .none)
    }

    @Test func aRowClearOfTheFadesIsLeftWhereItIs() {
        // Window 100…350 fades 100…115 and 335…350; row 5 is 150…180.
        #expect(SidebarLayout.revealOffset(
            row: 5, rows: 20, rowHeight: rowHeight, window: window(at: 100), depth: depth) == nil)
        // The first row at rest, the last at the end — nothing beyond either to fade.
        #expect(SidebarLayout.revealOffset(
            row: 0, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == nil)
        #expect(SidebarLayout.revealOffset(
            row: 19, rows: 20, rowHeight: rowHeight, window: window(at: 350), depth: depth) == nil)
    }

    /// **F-2 meets F-1:** a row wholly inside the viewport but under the
    /// bottom fade is NOT in view — it lands one fade's depth above the bottom
    /// edge, at an EXACT offset (P-U1b-6).
    @Test func aRowUnderTheBottomFadeLandsAtTheExactOffsetClearOfIt() {
        // Row 7 is 210…240; the bottom fade covers 235…250. 240 + 15 − 250 = 5.
        #expect(SidebarLayout.revealOffset(
            row: 7, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == 5)
    }

    @Test func aRowAboveLandsOneFadeBelowTheTop() {
        // Window 200…450; row 5 (150…180) lies above: 150 − 15 = 135.
        #expect(SidebarLayout.revealOffset(
            row: 5, rows: 20, rowHeight: rowHeight, window: window(at: 200), depth: depth) == 135)
    }

    @Test func theEndsLandOnTheEdgesAndTheOffsetStaysInsideTheContent() {
        #expect(SidebarLayout.revealOffset(
            row: 19, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == 350,
                "the last row: the content's end, 600 − 250")
        #expect(SidebarLayout.revealOffset(
            row: 0, rows: 20, rowHeight: rowHeight, window: window(at: 300), depth: depth) == 0,
                "the first row: the content's top")
        #expect(SidebarLayout.revealOffset(
            row: 18, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == 335,
                "the row before last keeps its half row of air: 570 + 15 − 250")
    }

    @Test func aWindowShorterThanARowShowsTheRowsTop() {
        let narrow = Window(offset: 0, viewport: 20, content: 600)
        #expect(SidebarLayout.revealOffset(
            row: 10, rows: 20, rowHeight: rowHeight, window: narrow, depth: depth) == 300)
    }

    /// **The pitch flip's two windows** (the re-run's red: Starred's ninth row
    /// after the column went 30 → 24). Each window answers its OWN exact
    /// offset — the 30-pt window 45, the 24-pt window 36 (its content's end) —
    /// so a reveal asked again on the new window's reading lands exactly,
    /// where an answer carried over from the old one would not.
    @Test func thePitchFlipsBeforeAndAfterWindowsEachAnswerExactly() {
        let before = Window(offset: 0, viewport: 225, content: 270)  // 9 rows at 30, 7.5 shown
        let after = Window(offset: 0, viewport: 180, content: 216)   // the same 9 at 24
        #expect(SidebarLayout.revealOffset(
            row: 8, rows: 9, rowHeight: 30, window: before,
            depth: SidebarLayout.edgeFadeDepth(rowHeight: 30)) == 45)
        let landed = SidebarLayout.revealOffset(
            row: 8, rows: 9, rowHeight: 24, window: after,
            depth: SidebarLayout.edgeFadeDepth(rowHeight: 24))
        #expect(landed == 36)
        #expect(SidebarLayout.revealOffset(
            row: 8, rows: 9, rowHeight: 24, window: Window(offset: 34, viewport: 180, content: 216),
            depth: SidebarLayout.edgeFadeDepth(rowHeight: 24)) == 36,
                "the re-run's resting place (34) is not clear, and the exact answer is the end")
        #expect(SidebarLayout.revealOffset(
            row: 8, rows: 9, rowHeight: 24, window: Window(offset: 36, viewport: 180, content: 216),
            depth: SidebarLayout.edgeFadeDepth(rowHeight: 24)) == nil, "…and from there nothing moves")
    }

    /// **Idempotent from every window:** every row lands wholly in view and
    /// clear of both fades, and a second reveal from the result moves nothing.
    @Test func everyRowLandsClearOfTheFadesFromAnyWindow() throws {
        for (viewport, rows, pitch) in [(CGFloat(250), 20, CGFloat(30)), (CGFloat(105), 20, CGFloat(30)),
                                        (CGFloat(225), 9, CGFloat(30)), (CGFloat(180), 9, CGFloat(24))] {
            let content = CGFloat(rows) * pitch
            let depth = SidebarLayout.edgeFadeDepth(rowHeight: pitch)
            for start in stride(from: CGFloat(0), through: max(0, content - viewport), by: 7) {
                let from = Window(offset: start, viewport: viewport, content: content)
                for row in 0..<rows {
                    var landed = from
                    if let target = SidebarLayout.revealOffset(
                        row: row, rows: rows, rowHeight: pitch, window: from, depth: depth) {
                        landed.offset = target
                    }
                    let fades = SidebarLayout.edgeFades(landed, depth: depth)
                    let top = CGFloat(row) * pitch
                    #expect(top >= landed.offset + fades.top.depth - 0.5,
                            "row \(row) from \(start) (window \(viewport)): top \(top) under the top fade")
                    #expect(top + pitch <= landed.offset + viewport - fades.bottom.depth + 0.5,
                            "row \(row) from \(start) (window \(viewport)): bottom under the bottom fade")
                    #expect(SidebarLayout.revealOffset(
                        row: row, rows: rows, rowHeight: pitch, window: landed, depth: depth) == nil,
                            "row \(row) from \(start): a second reveal moves nothing")
                }
            }
        }
    }

    /// **P-U1c-1 — a reading asks only what moves the row:** her scroll (the
    /// offset alone) asks nothing; ANY viewport change — an animated frame's
    /// smallest step included — reveals now; a content change under an
    /// unchanged row count (the pitch flip) is a discrete request; a content
    /// change from a row closing elsewhere asks nothing (P-U1b-7).
    @Test func aReadingAsksOnlyWhatMovesTheRow() {
        let rest = Window(offset: 34, viewport: 180.002, content: 216)
        func ask(_ new: Window, rowsChanged: Bool = false) -> SidebarLayout.ReadingAsk {
            SidebarLayout.readingAsk(old: rest, new: new, rowsChanged: rowsChanged)
        }
        #expect(ask(Window(offset: 12, viewport: 180.002, content: 216)) == .none, "her scroll: the offset alone")
        #expect(ask(Window(offset: 34, viewport: 180, content: 216)) == .revealNow,
                "the beat's last frame, a 0.002-pt step, still reveals")
        #expect(ask(Window(offset: 34, viewport: 225, content: 216)) == .revealNow, "a resize")
        #expect(ask(Window(offset: 34, viewport: 180.002, content: 270)) == .request, "the pitch flip's content change")
        #expect(ask(Window(offset: 34, viewport: 180.002, content: 192), rowsChanged: true) == .none,
                "a row closing elsewhere is no reason (P-U1b-7)")
        #expect(ask(Window(offset: 34, viewport: 180.002, content: 216.3)) == .none, "a rounding hair of content")
    }

    /// **P-U1c-1's clock-free pin (RED ON OLD — R-H).** The rail's implicit
    /// animation, as U1c traced it: the content re-laid at the new pitch in one
    /// step (216 = 9 × 24), then the viewport easing 225 → 180 over the rail's
    /// beat as per-frame readings with its TOP HELD, every reveal landing on the
    /// 0.5-pt pixel grid AppKit scrolls to. At every frame cadence from 500 Hz
    /// down to 60 Hz the ninth row must end the beat exactly at the edge. The old
    /// trigger (a re-ask only when one reading's viewport stepped more than half
    /// a point) ended it short at every cadence finer than 60 Hz — 34.5 of 36 at
    /// the mounted rig's ≈5-ms cadence, U1c's measured number.
    @Test func anEasedShrinkEndsWithTheRowExactlyAtTheEdgeAtEveryCadence() {
        let pitch: CGFloat = 24
        let rows = 9
        let depth = SidebarLayout.edgeFadeDepth(rowHeight: pitch)
        let content = CGFloat(rows) * pitch
        let (from, to): (CGFloat, CGFloat) = (225, 180)
        let beat = SidebarLayout.railTransition
        func eased(_ t: TimeInterval) -> CGFloat {
            let x = min(max(t / beat, 0), 1)
            return CGFloat(3 * x * x - 2 * x * x * x)
        }
        func onPixelGrid(_ y: CGFloat) -> CGFloat { (y * 2).rounded() / 2 }
        for cadence in [0.002, 0.003, 0.004, 0.005, 0.006, 0.00833, 0.010, 0.01667] {
            var frames = Array(stride(from: cadence, to: beat, by: cadence))
            frames.append(beat)
            var offset: CGFloat = 0
            var last = Window(offset: 0, viewport: from, content: content)
            for t in frames {
                let reading = Window(offset: offset, viewport: from + (to - from) * eased(t), content: content)
                if SidebarLayout.readingAsk(old: last, new: reading, rowsChanged: false) != .none,
                   let target = SidebarLayout.revealOffset(
                    row: rows - 1, rows: rows, rowHeight: pitch, window: reading, depth: depth) {
                    offset = onPixelGrid(target)
                }
                last = Window(offset: offset, viewport: reading.viewport, content: content)
            }
            let fades = SidebarLayout.edgeFades(last, depth: depth)
            #expect(offset == content - to && fades.bottom == .none,
                    "at a \(cadence * 1000)-ms cadence the ninth row ends the beat at \(offset) of \(content - to)")
        }
    }

    @Test func nothingIsRevealedBeforeTheWindowIsMeasuredOrForARowThatIsNotThere() {
        #expect(SidebarLayout.revealOffset(
            row: 15, rows: 20, rowHeight: rowHeight, window: .unmeasured, depth: depth) == nil)
        #expect(SidebarLayout.revealOffset(
            row: 20, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == nil)
        #expect(SidebarLayout.revealOffset(
            row: -1, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == nil)
    }
}

// MARK: - Follow, not every change (U1d — her ruling on the memo, R6)

/// **U1d — her ruling on the memo (R6):** *"Only on your next act … once you
/// scroll by hand it stays where you put it until your next one of those;
/// resizing the window never pulls it back."* The re-walk saw the Open list
/// pulled back to the current row seconds after her own scroll, with no input:
/// every viewport or content change re-asked the reveal, whoever had moved the
/// list. The pure follow model decides; these pins play its inputs.
@MainActor
@Suite("U1d — a scrolling section follows on her acts, never after her own scroll")
struct SidebarSectionFollowTests {
    private typealias Window = SidebarLayout.ScrollWindow
    private let pitch: CGFloat = 30
    private var depth: CGFloat { SidebarLayout.edgeFadeDepth(rowHeight: pitch) }

    /// Row 15 of 20 is the current row; `ask` lands it if the follow state lets
    /// the ask through (the modifier's road: the gate, then the exact offset).
    private func land(_ ask: SidebarLayout.ReadingAsk, _ follow: SidebarLayout.SectionFollow,
                      _ window: inout Window) {
        guard follow.gate(ask) != .none,
              let target = SidebarLayout.revealOffset(
                row: 15, rows: 20, rowHeight: pitch, window: window, depth: depth) else { return }
        window.offset = target
    }

    @Test func aSectionFollowsFromItsFirstAppearance() {
        let follow = SidebarLayout.SectionFollow()
        #expect(follow.following)
        #expect(follow.gate(.revealNow) == .revealNow)
        #expect(follow.gate(.request) == .request)
        #expect(follow.gate(.none) == .none)
    }

    /// Her hand ends following; its END (idle) does not resume it, the app's
    /// own animated scroll does not either; only an act does.
    @Test func aHandScrollEndsFollowingUntilHerNextAct() {
        var follow = SidebarLayout.SectionFollow()
        follow.phase(hers: true)
        #expect(!follow.following)
        #expect(follow.gate(.revealNow) == .none, "a viewport reading moves nothing")
        #expect(follow.gate(.request) == .none, "nor the pitch, nor a content change")
        follow.phase(hers: false)
        #expect(!follow.following, "her scroll ending is not an act")
        follow.act()
        #expect(follow.following && follow.gate(.revealNow) == .revealNow, "her next act follows again")
        follow.phase(hers: false)
        #expect(follow.following, "a phase that is not hers never ends following")
    }

    /// Which phases are her hand — the modifier's mapping. U1d's offscreen
    /// measurement: a wheel burst and a trackpad gesture report `.interacting`
    /// before their first offset change; the reveal's unanimated `scrollTo`
    /// reports nothing; an animated scroll reports `.animating`.
    @Test func onlyInteractingAndDeceleratingAreHerHand() {
        #expect(SidebarSectionWindow<String>.isHandScroll(.interacting))
        #expect(SidebarSectionWindow<String>.isHandScroll(.decelerating))
        #expect(!SidebarSectionWindow<String>.isHandScroll(.idle))
        #expect(!SidebarSectionWindow<String>.isHandScroll(.animating), "the app's own scroll")
        #expect(!SidebarSectionWindow<String>.isHandScroll(.tracking), "a touch that has not moved the list")
    }

    /// **The re-walk's R6, played through the model** (RED ON OLD — R-I, where
    /// her hand never ends following, exactly U1c's behaviour). The current row
    /// revealed; she scrolls the list to its top by hand; then every change that
    /// re-asks a following section — a resize shorter and taller, the content
    /// re-laid under the same row count, the pitch's discrete request, the
    /// settled check — leaves her list where she put it. Her next act reveals.
    @Test func herScrollStaysWhereSheLeftItThroughEveryLaterChange() {
        var follow = SidebarLayout.SectionFollow()
        var window = Window(offset: 0, viewport: 351, content: 600)
        follow.act()
        land(.request, follow, &window)
        #expect(window.offset == 144, "the act revealed row 15 (450…480): 480 + 15 − 351")
        follow.phase(hers: true)
        window.offset = 0
        follow.phase(hers: false)
        for (label, next) in [("a resize shorter", Window(offset: 0, viewport: 291, content: 600)),
                              ("the content re-laid under the same count", Window(offset: 0, viewport: 291, content: 606)),
                              ("a resize taller", Window(offset: 0, viewport: 400, content: 606))] {
            let ask = SidebarLayout.readingAsk(old: window, new: next, rowsChanged: false)
            #expect(ask != .none, "\(label) is a change a following section re-asks on")
            window = next
            land(ask, follow, &window)
            #expect(window.offset == 0, "\(label) leaves her list where she put it: \(window.offset)")
        }
        land(.request, follow, &window)
        land(.revealNow, follow, &window)
        #expect(window.offset == 0, "nor the pitch's request, nor the settled check")
        follow.act()
        land(.request, follow, &window)
        #expect(window.offset == 95, "her next act reveals the row: 480 + 15 − 400")
    }

    /// While FOLLOWING, a resize still keeps the row in view (the memo, item 1:
    /// *"While following, anything that moves the row … keeps it wholly in
    /// view"* — P-U1c-1 unchanged).
    @Test func whileFollowingAResizeKeepsTheRowInView() {
        let follow = SidebarLayout.SectionFollow()
        var window = Window(offset: 144, viewport: 351, content: 600)
        let next = Window(offset: 144, viewport: 291, content: 600)
        let ask = SidebarLayout.readingAsk(old: window, new: next, rowsChanged: false)
        window = next
        land(ask, follow, &window)
        #expect(window.offset == 204, "the shorter list re-reveals row 15: 480 + 15 − 291")
    }
}

// MARK: - The column's one transition beat (the orchestrator's ruling on P-U1b-5)

/// The scrolling sections ask their reveal a second time once the rail's
/// animated transition has settled (U1b's stage window: a reveal resolved
/// mid-transition rested short). The ruling: that wait is DERIVED from the
/// rail's own duration, named once — never a free-standing number that drifts
/// silently the day the motion changes.
@MainActor
@Suite("U1b — the column's one transition beat (P-U1b-5, ruled)")
struct SidebarTransitionBeatTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// Code lines only — a comment may name the beat's history.
    private func code(_ relative: String) throws -> [String] {
        try String(contentsOf: Self.appRoot.appendingPathComponent(relative), encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
            .filter {
                let line = $0.trimmingCharacters(in: .whitespaces)
                return !line.hasPrefix("//") && !line.hasPrefix("*")
            }
    }

    @Test func theSecondRevealWaitsStrictlyPastTheRailsTransition() {
        #expect(SidebarLayout.transitionSettleMargin > 0)
        #expect(SidebarLayout.transitionSettle > SidebarLayout.railTransition)
        #expect(SidebarLayout.transitionSettle
                == SidebarLayout.railTransition + SidebarLayout.transitionSettleMargin)
        #expect(SidebarSectionWindow<String>.transitionSettle == .seconds(SidebarLayout.transitionSettle),
                "the section's wait is the derived settle, not a number of its own")
    }

    /// **A source read:** every animation in the sidebar column runs on the one
    /// beat — the rail's and the note box's arrival and departure — and no
    /// literal duration remains; the sections' wait reads the derived settle.
    @Test func theSidebarsRailAnimationsReadTheOneBeat() throws {
        let sidebar = try code("Variorum/Features/Library/SidebarView.swift")
        let animations = sidebar.filter { $0.contains(".animation(") }
        #expect(animations.contains { $0.contains("value: railPostID") }, "the rail's motion")
        #expect(animations.contains { $0.contains("value: noteBox == nil") }, "the note box's motion")
        for line in animations {
            #expect(line.contains("SidebarLayout.railTransition"),
                    "a sidebar animation off the shared beat: \(line)")
        }
        #expect(!sidebar.contains { $0.contains("duration: 0") || $0.contains("duration: 1") },
                "no literal duration in the column")
        let window = try code("Variorum/Features/Library/SidebarSectionWindow.swift")
        #expect(window.contains { $0.contains(".seconds(SidebarLayout.transitionSettle)") })
        #expect(!window.contains { $0.contains(".milliseconds(") || $0.contains("duration: 0") },
                "no free-standing wait in the section window")
    }
}

// MARK: - The mounted pins: what the sections actually DO in a window

/// The column, bound to the workspace exactly as `RootView.selectionBinding`
/// binds it: the sidebar reads the FOCUSED pane's selection, and a pick goes
/// through `WorkspaceModel.select` (the road `ShellRouter.adopt` ends on).
@MainActor
private struct SectionWindowHost: View {
    let session: AppSession
    let workspace: WorkspaceModel
    let stars: StarsModel
    let theme: ThemeStore
    /// The stand-in for the sync footer — `RootView.statusRows`' slot.
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

/// One mounted column and the doors a pin drives it through.
@MainActor
private final class SectionRig {
    let session: AppSession
    let workspace: WorkspaceModel
    let window: NSWindow
    let hosting: NSView
    let key: String
    private(set) var notes: [String]

    init(session: AppSession, workspace: WorkspaceModel, window: NSWindow, hosting: NSView, notes: [String]) {
        self.session = session
        self.workspace = workspace
        self.window = window
        self.hosting = hosting
        self.key = SidebarGeometry.bodyKey(for: workspace)
        self.notes = notes
    }

    /// A synchronous turn of the run loop (`run(until:)` is barred from async
    /// contexts — `OpenListLayoutMountTests`' own helper shape).
    func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    var open: SidebarGeometry.SectionDraw? { SidebarGeometry.sectionDraws[key]?[.open] }
    var starred: SidebarGeometry.SectionDraw? { SidebarGeometry.sectionDraws[key]?[.starred] }

    /// A navigation, through the one door every navigation funnels through.
    func go(_ destination: SidebarSelection) async {
        workspace.select(destination)
        await settle()
    }

    func newNote(_ title: String) throws -> String {
        let id = try session.operations.createPost(title: title).id
        notes.append(id)
        return id
    }

    /// Turns the run loop until the Open list's window has STOPPED MOVING —
    /// and never before the rail's 0.22 s fade has run its course.
    func settle(minimum: TimeInterval = 0.5, until ready: () -> Bool = { true }) async {
        let start = Date()
        var last: SidebarLayout.ScrollWindow?
        var lastFrame: CGRect?
        var lastStar: SidebarLayout.ScrollWindow?
        var still = 0
        for _ in 0..<300 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            let now = open?.window
            let frame = open?.scroll
            let star = starred?.window
            if now != nil, now == last, frame == lastFrame, star == lastStar { still += 1 } else { still = 0 }
            last = now
            lastFrame = frame
            lastStar = star
            if still >= 5, Date().timeIntervalSince(start) >= minimum, ready() { return }
        }
    }

    /// F-2's full depth at the pitch a section is drawing NOW (its window's
    /// content over its rows — the column's pitch flips 30 ↔ 24 as rows come
    /// and go, so a pin reads it after every step).
    func depth(_ draw: SidebarGeometry.SectionDraw?, rows: Int) -> CGFloat {
        SidebarLayout.edgeFadeDepth(rowHeight: (draw?.window?.content ?? 0) / CGFloat(max(rows, 1)))
    }

    /// nil when `noteID`'s Open row stands wholly in the list's window and
    /// clear of its fades (none recorded reads as none drawn); otherwise what
    /// is wrong, for the expectation's message.
    func openRowTrouble(_ noteID: String) -> String? {
        guard let draw = open, let window = draw.window else { return "the list never reported its window" }
        let shown = workspace.openNotes.shown
        guard let row = shown.firstIndex(of: noteID) else { return "\(noteID) has no row" }
        let rowHeight = window.content / CGFloat(max(shown.count, 1))
        let fades = draw.fades ?? .none
        let top = CGFloat(row) * rowHeight
        let bottom = top + rowHeight
        let clearTop = window.offset + fades.top.depth
        let clearBottom = window.offset + window.viewport - fades.bottom.depth
        if top >= clearTop - 0.5, bottom <= clearBottom + 0.5 { return nil }
        return "row \(row + 1) of \(shown.count) spans \(top)…\(bottom); the window shows \(window.offset)…"
            + "\(window.offset + window.viewport) with fades \(fades.top.depth)/\(fades.bottom.depth)"
    }

    /// U1d: a section's AppKit scroll view — the one whose clip view and
    /// document match the section's OWN scroll reading (its visible height is
    /// the clip's, its content height the document's), so no coordinate
    /// convention between SwiftUI and AppKit is assumed.
    func scrollView(_ draw: SidebarGeometry.SectionDraw?) -> NSScrollView? {
        guard let window = draw?.window, window.isMeasured else { return nil }
        func all(_ view: NSView) -> [NSScrollView] {
            var found: [NSScrollView] = []
            if let scroll = view as? NSScrollView { found.append(scroll) }
            for sub in view.subviews { found += all(sub) }
            return found
        }
        return all(hosting).first { scroll in
            abs(scroll.contentView.bounds.height - window.viewport) < 1
                && abs((scroll.documentView?.frame.height ?? -10) - window.content) < 2
        }
    }

    /// **U1d — a HAND scroll, played without a real scroll-wheel event** (the
    /// test host never injects pointer events here): the section's phase seam
    /// is fed `.interacting` — exactly `onScrollPhaseChange`'s road — the
    /// section's clip view moves to `offset` (an offset-only change, which
    /// reports no phase of its own — U1d's offscreen measurement), and the
    /// phase returns to `.idle`, as her wheel's or trackpad's does.
    func handScroll(_ section: SidebarGeometry.ScrollingSection, to offset: CGFloat) async throws {
        let feed = try #require(SidebarGeometry.sectionPhaseFeeds[key]?[section], "the section's phase seam")
        let scroll = try #require(scrollView(section == .open ? open : starred), "the section's scroll view")
        feed(.interacting)
        scroll.contentView.scroll(to: NSPoint(x: scroll.contentView.bounds.origin.x, y: offset))
        scroll.reflectScrolledClipView(scroll.contentView)
        pump(0.05)
        feed(.idle)
        await settle()
    }
}

@MainActor
@Suite("U1b — the scrolling sections' windows, as drawn", .serialized)
struct SidebarSectionWindowMountTests {
    private static let footerHeight: CGFloat = 64

    /// Mounts the column at `height` with `openNotes` open (visited in order)
    /// and `starred` stars, the focused pane on `startOn` (an index into the
    /// notes, or nil for the Library), settled.
    private func withRig(
        height: CGFloat, openNotes: Int, starred: Int = 0, startOn: Int?,
        _ body: @MainActor (SectionRig) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // The LIVE generator: the oracle keys must not collide with a
            // parallel suite's (the DEBUG-oracle keying rule).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1281))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let notes = try (1...max(openNotes, starred)).map {
                try session.operations.createPost(title: "note \($0)").id
            }
            if starred > 0 {
                // `StarredScrollTests`' reason: the geometry, not the cap.
                let keys = notes.prefix(starred).map { StarTarget.post($0).key }
                let json = String(decoding: try JSONEncoder().encode(Array(keys)), as: UTF8.self)
                try await db.write { db in
                    try db.execute(
                        sql: """
                            INSERT INTO setting (key, value) VALUES ('starred', ?)
                            ON CONFLICT(key) DO UPDATE SET value = excluded.value
                            """,
                        arguments: [json])
                }
            }
            let workspace = WorkspaceModel()
            for note in notes.prefix(openNotes) { workspace.visit(.post(note)) }
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
            let hosting = NSHostingView(rootView: SectionWindowHost(
                session: session, workspace: workspace, stars: stars, theme: theme,
                footerHeight: Self.footerHeight))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            let rig = SectionRig(
                session: session, workspace: workspace, window: window, hosting: hosting, notes: notes)
            await rig.settle {
                starred == 0 || (stars.items.count == starred && rig.starred?.window != nil)
            }
            try await body(rig)
        }
    }

    /// **F-1, the deterministic road (RED ON OLD).** On the last row's note,
    /// go to the Library and come back. The Library's taller list (no rail)
    /// takes the rows in; coming back, the rail returns and the list's
    /// viewport shrinks under the row — and the old reveal never ran, because
    /// the note was already the newest (`recency.first` unchanged). RED ON
    /// OLD: the row sits far below the window.
    @Test func returningToTheNoteYouWereInRevealsItsRow() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 18) { rig in
            let last = rig.notes[19]
            await rig.go(.post(last))
            #expect(rig.openRowTrouble(last) == nil, "on the note: \(rig.openRowTrouble(last) ?? "")")
            await rig.go(.library)
            await rig.go(.post(last))
            print("[U1b return] \(String(describing: rig.open?.window)) · \(String(describing: rig.open?.fades))")
            #expect(rig.openRowTrouble(last) == nil,
                    "back on the note, its row is wholly in view: \(rig.openRowTrouble(last) ?? "")")
        }
    }

    /// **F-1's mechanism — a viewport that changes height under the current
    /// row re-reveals it (RED ON OLD, and RED with only that trigger
    /// reverted).** The current row revealed near the bottom, then the window
    /// shortens by 60 pt: the list's viewport shrinks from below, top-anchored,
    /// and only a re-reveal brings the row back.
    @Test func aShorterListKeepsTheCurrentRowInView() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 9) { rig in
            let current = rig.notes[15]
            await rig.go(.post(current))
            #expect(rig.openRowTrouble(current) == nil, "revealed: \(rig.openRowTrouble(current) ?? "")")
            let before = rig.open?.window
            rig.window.setContentSize(NSSize(width: 230, height: 840))
            await rig.settle()
            let after = rig.open?.window
            print("[U1b shorter] \(String(describing: before)) → \(String(describing: after))")
            #expect((after?.viewport ?? 0) < (before?.viewport ?? 0) - 30,
                    "the list's viewport really shrank: \(String(describing: before)) → \(String(describing: after))")
            #expect(rig.openRowTrouble(current) == nil,
                    "after the window shortened: \(rig.openRowTrouble(current) ?? "")")
        }
    }

    /// **F-1, the walker's road** (O-1: a NEW note opened from a place, the
    /// rail arriving and the column's height settling after the reveal). The
    /// old code raced here — usually whole, once in ~40 cut — so this pin is
    /// exact-behaviour for the new code, not a red-on-old proof.
    @Test func aNewNoteOpenedFromThePlacesLandsWhollyInView() async throws {
        try await withRig(height: 900, openNotes: 19, startOn: 18) { rig in
            await rig.go(.library)
            let newcomer = try rig.newNote("note 20")
            await rig.go(.post(newcomer))
            #expect(rig.workspace.openNotes.shown.last == newcomer)
            #expect(rig.openRowTrouble(newcomer) == nil,
                    "the note she just opened: \(rig.openRowTrouble(newcomer) ?? "")")
        }
    }

    /// **F-1 — a ⌘⇧W landing** (the door's road: the workspace closes the
    /// row and names the landing; the shell selects it). The next row sat
    /// under the bottom fade beneath the closed one; it lands clear of it.
    @Test func aCloseNoteLandingRevealsTheNextRowClearOfTheFades() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 9) { rig in
            await rig.go(.post(rig.notes[14]))
            let landing = try #require(rig.workspace.closeFocusedNote())
            #expect(landing == .post(rig.notes[15]))
            await rig.go(landing)
            #expect(rig.openRowTrouble(rig.notes[15]) == nil,
                    "the landing's row: \(rig.openRowTrouble(rig.notes[15]) ?? "")")
        }
    }

    /// **F-2 — the Open list fades only the edges with more beyond them**
    /// (P-U1-6; the oracle reads the fades the overlay draws). At the top
    /// only the bottom fades, mid-list both, at the end only the top — each
    /// half a row deep. RED ON OLD: no fade at all (none recorded).
    @Test func theOpenListFadesOnlyTheEdgesWithMoreBeyond() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 0) { rig in
            _ = try #require(rig.open?.window)
            var depth = rig.depth(rig.open, rows: 20)
            #expect(depth >= 12, "half a row at either pitch: \(depth)")
            // (U1d: the fades are `EdgeFade`s — depth and strength, her ruling
            //  on the memo; every edge here has a half row or more beyond it,
            //  so each fade stands whole.)
            #expect(rig.open?.fades == SidebarLayout.EdgeFades(top: .none, bottom: .whole(depth)),
                    "at the top: \(String(describing: rig.open?.fades))")
            // Row 15 (420…450) lies below the fold of the 351-pt list, so the
            // reveal scrolls it in and leaves rows above AND below. (U1b's
            // window: row 10, the first draft's pick, stood clear at offset 0 —
            // nothing scrolled — a pin fault, recorded.)
            await rig.go(.post(rig.notes[14]))
            depth = rig.depth(rig.open, rows: 20)
            #expect(rig.open?.fades == SidebarLayout.EdgeFades(top: .whole(depth), bottom: .whole(depth)),
                    "mid-list: \(String(describing: rig.open?.fades))")
            await rig.go(.post(rig.notes[19]))
            depth = rig.depth(rig.open, rows: 20)
            #expect(rig.open?.fades == SidebarLayout.EdgeFades(top: .whole(depth), bottom: .none),
                    "at the end: \(String(describing: rig.open?.fades))")
        }
    }

    /// **F-2 — Starred too:** past its ~7 it fades its bottom edge at rest
    /// (its half row reads as "more", softly), and a starred note revealed at
    /// the end fades the top instead; a Starred that holds every row fades
    /// nowhere. RED ON OLD: no fade at all.
    @Test func starredFadesWhereMoreLiesBeyondAndNowhereWhenItHoldsEverything() async throws {
        try await withRig(height: 900, openNotes: 3, starred: 9, startOn: nil) { rig in
            let window = try #require(rig.starred?.window)
            var depth = rig.depth(rig.starred, rows: 9)
            #expect(depth >= 12, "half a row at either pitch: \(depth)")
            // (U1d: `EdgeFade`s now — each edge here has a half row or more beyond.)
            #expect(rig.starred?.fades == SidebarLayout.EdgeFades(top: .none, bottom: .whole(depth)),
                    "at rest: \(String(describing: rig.starred?.fades)) over \(window)")
            // Opening the ninth star's note brings the rail (and may flip the
            // column's pitch): the section reveals it and fades the top instead.
            await rig.go(.post(rig.notes[8]))
            depth = rig.depth(rig.starred, rows: 9)
            #expect(rig.starred?.fades == SidebarLayout.EdgeFades(top: .whole(depth), bottom: .none),
                    "the ninth star revealed: \(String(describing: rig.starred?.fades)) over \(String(describing: rig.starred?.window))")
        }
        try await withRig(height: 900, openNotes: 3, starred: 5, startOn: nil) { rig in
            #expect(rig.starred?.fades == SidebarLayout.EdgeFades.none,
                    "five stars, all shown: \(String(describing: rig.starred?.fades))")
        }
    }

    /// **U1c — P-U1c-1's mounted pin (RED ON OLD — R-H).** The trace's
    /// signature of the defect: the ninth star's row was cut by the rail
    /// transition's TAIL — the viewport's last sub-half-point steps never
    /// re-asked — and only the settled backstop landed it, 0.30 s after the
    /// last request. So: sampled at a fine cadence across the open, the section
    /// must stand where it SETTLES within 100–150 ms of the moment its viewport
    /// reaches its settled height — inside the old per-frame backstop's 300 ms,
    /// so that backstop cannot be what passes it — and where it settles must be
    /// the content's end (the row clear). On the old trigger it went red
    /// whenever the tail left the row cut (2 of 3 runs in U1c's window — the
    /// third a pixel-grid lucky landing); on P-U1c-1 the beat's last reading
    /// lands it.
    @Test func theNinthStarIsClearTheMomentTheBeatEnds() async throws {
        try await withRig(height: 900, openNotes: 3, starred: 9, startOn: nil) { rig in
            let start = ProcessInfo.processInfo.systemUptime
            rig.workspace.select(.post(rig.notes[8]))
            var samples: [(at: TimeInterval, window: SidebarLayout.ScrollWindow?)] = []
            while ProcessInfo.processInfo.systemUptime - start < 1.0 {
                rig.hosting.layoutSubtreeIfNeeded()
                rig.window.displayIfNeeded()
                rig.pump(0.004)
                await Task.yield()
                samples.append((ProcessInfo.processInfo.systemUptime - start, rig.starred?.window))
            }
            let settled = try #require(samples.last?.window, "the section reported its window")
            #expect(settled.offset == settled.content - settled.viewport,
                    "it settles with the ninth star at the content's end: \(SidebarSectionTrace.text(settled))")
            let end = try #require(samples.first { $0.window?.viewport == settled.viewport }?.at,
                                   "the viewport reached its settled height")
            let soon = samples.filter { $0.at >= end + 0.10 && $0.at < end + 0.15 }
            #expect(!soon.isEmpty, "samples 100–150 ms after the beat's end")
            for sample in soon {
                let when = String(format: "+%.3f s (the beat ended at +%.3f s)", sample.at, end)
                let seen = sample.window.map(SidebarSectionTrace.text) ?? "nil"
                #expect(sample.window?.offset == settled.offset,
                        "\(when): \(seen) — it settles at \(SidebarSectionTrace.text(settled))")
            }
        }
    }

    /// **U1d — her ruling on the memo, R6 (RED ON OLD — R-I, her hand never
    /// ending following: U1c's behaviour).** Her words: *"once you scroll by
    /// hand it stays where you put it until your next one of those; resizing
    /// the window never pulls it back."* The current row revealed; her hand
    /// scrolls the list to its top (the phase seam + the clip view — no real
    /// wheel event); the window shortens, then grows back — on U1c's code the
    /// shortening re-revealed the row (P-U1b-2), pulling her list back. Her
    /// next act — another note opened — follows again.
    @Test func aHandScrollIsNeverPulledBackUntilHerNextAct() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 9) { rig in
            let current = rig.notes[15]
            await rig.go(.post(current))
            #expect(rig.openRowTrouble(current) == nil, "revealed: \(rig.openRowTrouble(current) ?? "")")
            try await rig.handScroll(.open, to: 0)
            let scrolled = try #require(rig.open?.window)
            #expect(scrolled.offset < 0.5, "her scroll took the list to its top: \(scrolled)")
            #expect(rig.openRowTrouble(current) != nil, "…with the current row out of view, where she put it")
            rig.window.setContentSize(NSSize(width: 230, height: 840))
            await rig.settle()
            let shorter = try #require(rig.open?.window)
            print("[U1d hand] \(scrolled) → \(shorter)")
            #expect(shorter.viewport < scrolled.viewport - 30,
                    "the list's viewport really shrank: \(scrolled) → \(shorter)")
            #expect(shorter.offset < 0.5, "the resize left her list where she put it: \(shorter)")
            rig.window.setContentSize(NSSize(width: 230, height: 900))
            await rig.settle()
            #expect((rig.open?.window?.offset ?? -1) < 0.5,
                    "and so did growing back: \(String(describing: rig.open?.window))")
            let next = rig.notes[16]
            await rig.go(.post(next))
            #expect(rig.openRowTrouble(next) == nil, "her next act follows: \(rig.openRowTrouble(next) ?? "")")
        }
    }

    /// **U1d — the re-walk's O-2 state, as drawn (RED ON OLD — R-J, U1b's
    /// eased-depth fade).** A few points left beyond the bottom edge drew a
    /// few-point fade, solid at the edge, over the row's descenders — a slice.
    /// Her ruling: *"always half a row deep when there's more beyond, easing in
    /// (its strength, not its depth) … never fully solid"*. So the bottom edge
    /// fades the whole half row, at a strength of what lies beyond over that
    /// half row, under the cap.
    @Test func aShallowOverflowFadesTheWholeHalfRowFaintly() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 0) { rig in
            let window = try #require(rig.open?.window)
            try await rig.handScroll(.open, to: window.content - window.viewport - 5)
            let draw = try #require(rig.open)
            let shallow = try #require(draw.window)
            let beyond = shallow.content - shallow.offset - shallow.viewport
            let depth = rig.depth(draw, rows: 20)
            #expect(beyond >= 3 && beyond <= 7, "a few points beyond the bottom edge: \(shallow)")
            let fade = try #require(draw.fades?.bottom)
            print("[U1d shallow] \(shallow) · \(fade)")
            #expect(fade.depth == depth, "the whole half row (\(depth)), never a \(beyond)-pt fade: \(fade)")
            // P-U1e-1 (changed in place): the strength ramps over the row's
            // text padding at this pitch, not over the half row.
            let ramp = SidebarLayout.edgeFadeRampDistance(rowHeight: depth / SidebarLayout.edgeFadeRows)
            #expect(abs(fade.strength - min(1, beyond / ramp)) < 0.01,
                    "\(beyond) over the \(ramp)-pt padding: \(fade)")
            #expect(fade.opacity < 1, "never fully solid: \(fade.opacity)")
        }
    }

    /// **U1c — the trace leg's harness (env-gated; asserts nothing; KEPT as an
    /// oracle at P-U1c-1 — re-run it with one variable whenever the beat or the
    /// trigger changes).** The
    /// Starred pin's own road — the ninth star's note opened from the Library,
    /// the rail arriving and the pitch flipping 30 → 24 under the column's
    /// implicit animation — with every reading, request, reveal and settled
    /// check of `SidebarSectionWindow` (its DEBUG `SidebarSectionTrace`), the
    /// pin's own oracle per iteration, and AppKit's frame / clip-bounds /
    /// document-frame notifications from Starred's scroll view, all on one
    /// clock. It marks where `SectionRig.settle` WOULD have returned, keeps
    /// turning to 1.5 s, and prints every line prefixed `[U1c]`. Run with
    /// `TEST_RUNNER_VARIORUM_U1C_TRACE=1`.
    @Test(.enabled(if: ProcessInfo.processInfo.environment["VARIORUM_U1C_TRACE"] != nil))
    func traceTheNinthStarsOpen() async throws {
        try await traceTheNinthStar(driven: true)
    }

    /// The same road with NO forced layout: the harness only sleeps, so the
    /// beat's frames come from the display, as they do in use.
    @Test(.enabled(if: ProcessInfo.processInfo.environment["VARIORUM_U1C_TRACE"] != nil))
    func traceTheNinthStarsOpenUndriven() async throws {
        try await traceTheNinthStar(driven: false)
    }

    private func traceTheNinthStar(driven: Bool) async throws {
        try await withRig(height: 900, openNotes: 3, starred: 9, startOn: nil) { rig in
            let trace = U1cTrace()
            SidebarSectionTrace.sink = { trace.lines.append($0) }
            defer { SidebarSectionTrace.sink = nil }
            trace.attach(to: rig.hosting, starredHeight: rig.starred?.window?.viewport ?? 0)
            defer { trace.detach() }
            trace.note("REST oracle \(trace.text(rig.starred?.window)) fades \(String(describing: rig.starred?.fades))")
            let start = ProcessInfo.processInfo.systemUptime
            trace.note("===== FLIP (\(driven ? "driven: SectionRig.settle's forced layout" : "UNDRIVEN: frames from the display only")): select the ninth star's note =====")
            rig.workspace.select(.post(rig.notes[8]))
            var last: SidebarLayout.ScrollWindow?
            var lastStar: SidebarLayout.ScrollWindow?
            var lastFrame: CGRect?
            var still = 0
            var wouldReturn = false
            var iteration = 0
            while ProcessInfo.processInfo.systemUptime - start < 1.5 {
                iteration += 1
                if driven {
                    // `SectionRig.settle`'s own turn, verbatim in shape.
                    rig.hosting.layoutSubtreeIfNeeded()
                    rig.window.layoutIfNeeded()
                    rig.window.displayIfNeeded()
                    rig.pump(0.02)
                    await Task.yield()
                    try? await Task.sleep(for: .milliseconds(10))
                } else {
                    try? await Task.sleep(for: .milliseconds(30))
                }
                let now = rig.open?.window
                let frame = rig.open?.scroll
                let star = rig.starred?.window
                if now != nil, now == last, frame == lastFrame, star == lastStar { still += 1 } else { still = 0 }
                last = now
                lastFrame = frame
                lastStar = star
                let elapsed = ProcessInfo.processInfo.systemUptime - start
                trace.note(String(format: "iteration %d (+%.3f s) still=%d", iteration, elapsed, still)
                    + " oracle \(trace.text(star)) fades \(String(describing: rig.starred?.fades))")
                if !wouldReturn, still >= 5, elapsed >= 0.5 {
                    wouldReturn = true
                    trace.note("===== SectionRig.settle WOULD RETURN HERE: the pin reads \(trace.text(star)) =====")
                }
            }
            trace.note("===== END: oracle \(trace.text(rig.starred?.window)) fades \(String(describing: rig.starred?.fades)) =====")
            for line in trace.lines { print("[U1c] \(line)") }
        }
    }
}

/// U1c's harness instrument: the trace's lines, and AppKit's own account of
/// Starred's scroll view (its frame, its clip view's bounds, its document's
/// frame), by notification, on the trace's clock.
@MainActor
private final class U1cTrace {
    var lines: [String] = []
    private var tokens: [NSObjectProtocol] = []

    func note(_ line: String) {
        lines.append(String(format: "%.4f", ProcessInfo.processInfo.systemUptime) + " [rig] " + line)
    }

    func text(_ window: SidebarLayout.ScrollWindow?) -> String {
        window.map(SidebarSectionTrace.text) ?? "nil"
    }

    private func scrollViews(in view: NSView) -> [NSScrollView] {
        var found: [NSScrollView] = []
        if let scroll = view as? NSScrollView { found.append(scroll) }
        for sub in view.subviews { found += scrollViews(in: sub) }
        return found
    }

    private func describe(_ scroll: NSScrollView) -> String {
        String(format: "frame.h %.3f clip.y %.3f clip.h %.3f doc.h %.3f",
               scroll.frame.height, scroll.contentView.bounds.origin.y,
               scroll.contentView.bounds.height, scroll.documentView?.frame.height ?? -1)
    }

    /// Starred's scroll view: the inner scroll view as tall as Starred's window
    /// (the outer column scroll is the tallest; the Open list's is elsewhere).
    func attach(to root: NSView, starredHeight: CGFloat) {
        let all = scrollViews(in: root)
        note("AppKit scroll views: " + all.map { "\(type(of: $0)) h=\($0.frame.height)" }.joined(separator: ", "))
        guard let starred = all.first(where: { abs($0.frame.height - starredHeight) < 1 }) else {
            note("Starred's scroll view NOT FOUND (window \(starredHeight))")
            return
        }
        starred.postsFrameChangedNotifications = true
        starred.contentView.postsBoundsChangedNotifications = true
        starred.documentView?.postsFrameChangedNotifications = true
        let center = NotificationCenter.default
        let watch: [(NSView?, Notification.Name, String)] = [
            (starred, NSView.frameDidChangeNotification, "frame"),
            (starred.contentView, NSView.boundsDidChangeNotification, "bounds"),
            (starred.documentView, NSView.frameDidChangeNotification, "docFrame"),
        ]
        for (object, name, what) in watch {
            guard let object else { continue }
            tokens.append(center.addObserver(forName: name, object: object, queue: nil) { [weak self, weak starred] _ in
                MainActor.assumeIsolated {
                    guard let self, let starred else { return }
                    self.lines.append(String(format: "%.4f", ProcessInfo.processInfo.systemUptime)
                        + " [appkit] \(what) " + self.describe(starred))
                }
            })
        }
    }

    func detach() {
        for token in tokens { NotificationCenter.default.removeObserver(token) }
        tokens = []
    }
}
