//
//  WingToolbarLabelTests.swift
//  VariorumTests (Mac)
//
//  VX-833 (2) + VX-844 (the VX-828 run, batch B). Her two asks about the
//  toolbar's "in ‹wing›" (the wing switcher's door): it sits RIGHT-ALIGNED in
//  the sidebar's top bar, never crossing the vertical divider (VX-833); a name
//  longer than its space SCROLLS within it, car-radio style — no ellipsis
//  (VX-844, her ruling).
//
//  THE MECHANISM BEFORE (traced, B0): the label carried
//  `.frame(maxWidth: 160, alignment: .leading)` + a tail truncation — leading,
//  wide enough to cross the column's line, blind to the column. VX-736
//  measured its leading edge at ≈ 174 pt with the line at the column's width.
//
//  THE PINS: the space rule (pure — the line, the air, the item's edge; the
//  floor; the hidden sidebar); the marquee's plan (pure — still while it fits:
//  NO loop exists, the "no standing timer" rule as a state; the ticker's
//  numbers; Reduce Motion); and a HOSTED geometry pin of the placement view —
//  the item takes exactly its space (so its right edge is the line less the
//  air, never past it) and the words sit flush at its trailing edge; a long
//  name keeps the item's width and clips inside it; plus the composition by
//  source (the toolbar item rides the slot and the marquee).
//
//  RED ON OLD: new layout seams — compile-red on the pre-fix tree. The
//  behavioral revert (R-B3, the record): make `WingLabelPlacementView`'s
//  `.column` arm draw the OLD shape — the words leading at their natural width
//  — and the hosted pin's "exactly its space" and "flush trailing" lines go
//  red while the pure pins stay green.
//

import AppKit
import Foundation
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("VX-833 (2) + VX-844 — the toolbar's wing label: right-aligned in the column, a ticker when long")
struct WingToolbarLabelTests {
    // MARK: - The space (pure)

    @Test func theSpaceIsTheColumnLineLessTheAirLessTheItemsEdge() {
        let fresh = WingLabelSpace.placement(sidebarShown: true, columnLine: 240, origin: 169)
        #expect(fresh == .column(63), "the fresh 240-pt column: 240 − 8 − 169")
        #expect(WingLabelSpace.placement(sidebarShown: true, columnLine: 360, origin: 169) == .column(183),
                "a wide column gives the label more room — it follows the seam")
        #expect(WingLabelSpace.placement(sidebarShown: true, columnLine: 240, origin: 150) == .column(82),
                "the item's edge is read, never assumed (full screen drops the traffic lights)")
        #expect(WingLabelSpace.placement(sidebarShown: true, columnLine: 240, origin: nil)
                    == .column(240 - WingLabelSpace.air - WingLabelSpace.fallbackOrigin),
                "before the first read: VX-736's measured edge")
        // Never past the line: the item's right edge is the line less the air.
        for line in stride(from: CGFloat(200), through: 360, by: 20) {
            if case .column(let width) = WingLabelSpace.placement(sidebarShown: true, columnLine: line, origin: 169) {
                #expect(169 + width + WingLabelSpace.air == line, "at \(line): flush with the air, never across")
            }
        }
    }

    /// P-828-2's two edges: under 24 pt nothing is drawn; with the sidebar
    /// hidden there is no line — the old place and the old 160-pt cap.
    @Test func theTwoEdgesTheFloorAndTheHiddenSidebar() {
        #expect(WingLabelSpace.placement(sidebarShown: true, columnLine: 180, origin: 169) == .hidden,
                "the 180-pt minimum column leaves no room for a letter")
        #expect(WingLabelSpace.placement(sidebarShown: true, columnLine: 200, origin: 169) == .hidden, "23 pt")
        #expect(WingLabelSpace.placement(sidebarShown: true, columnLine: 201, origin: 169) == .column(24),
                "24 pt is drawn")
        #expect(WingLabelSpace.placement(sidebarShown: false, columnLine: 240, origin: 169)
                    == .loose(wordsCap: 160))
        #expect(WingLabelSpace.wordsMaxWidth(in: .column(63), washInset: 5) == 53, "the wash's insets come off")
        #expect(WingLabelSpace.wordsMaxWidth(in: .loose(wordsCap: 160), washInset: 5) == 160)
        #expect(WingLabelSpace.wordsMaxWidth(in: .hidden, washInset: 5) == 0)
    }

    // MARK: - The marquee's plan (pure — P-828-2 (a), the ticker)

    /// **The words fit ⇒ NO loop exists** — the P-8 rule ("no standing timer
    /// on the common case") as a state the view keys its task on.
    @Test func aNameThatFitsHasNoLoop() {
        let fits = WingMarqueePlan.plan(words: 45, viewport: 53, reduceMotion: false)
        #expect(fits == .still && !fits.loops)
        #expect(WingMarqueePlan.plan(words: 53, viewport: 53, reduceMotion: false) == .still, "exactly fits")
        #expect(WingMarqueePlan.plan(words: 53.4, viewport: 53, reduceMotion: false) == .still,
                "sub-point noise is not an overflow")
        #expect(WingMarqueePlan.plan(words: 0, viewport: 53, reduceMotion: false) == .still, "unmeasured")
        #expect(WingMarqueePlan.plan(words: 90, viewport: 0, reduceMotion: false) == .still, "no window to scroll in")
    }

    /// The ticker's numbers: one pass travels the words and the 24-pt gap (so
    /// the copy behind them lands where the start rested) at 25 pt/s, after a
    /// 2.5-s rest on the start.
    @Test func aLongNameTicks() {
        let long = WingMarqueePlan.plan(words: 101, viewport: 53, reduceMotion: false)
        #expect(long.loops)
        #expect(long == .ticker(.init(travel: 125, duration: 5, rest: 2.5)), "\(long)")
        #expect(WingMarqueePlan.rest == 2.5 && WingMarqueePlan.speed == 25 && WingMarqueePlan.gap == 24,
                "the ruled numbers (PROVISIONAL)")
    }

    /// Reduce Motion: no movement — the start, clipped.
    @Test func reduceMotionNeverTicks() {
        #expect(WingMarqueePlan.plan(words: 101, viewport: 53, reduceMotion: true) == .still)
    }

    /// The loop's key carries the name, the space and the plan — a rename, a
    /// resize or a fit restarts or ends the loop.
    @Test func theLoopKeyCarriesNameSpaceAndPlan() {
        let ticking = WingMarqueePlan.plan(words: 101, viewport: 53, reduceMotion: false)
        let key = WingMarqueePlan.LoopKey(words: "in walk wing", space: 53, plan: ticking)
        #expect(key != WingMarqueePlan.LoopKey(words: "in walk wings", space: 53, plan: ticking))
        #expect(key != WingMarqueePlan.LoopKey(words: "in walk wing", space: 60, plan: ticking))
        #expect(key != WingMarqueePlan.LoopKey(words: "in walk wing", space: 53, plan: .still))
    }

    // MARK: - The hosted geometry (the placement view, mounted)

    nonisolated private static let slotSpace = "vx833-slot"

    private final class Frames {
        var item: CGRect = .zero
        var words: CGRect = .zero
    }

    /// The production placement view, holding the production marquee inside a
    /// quiet-style button stand-in (the wash = the insets), with the words'
    /// frame read in the item's own space.
    private func mount(_ placement: WingLabelSpace.Placement, words: String) async -> Frames {
        let frames = Frames()
        let root = WingLabelPlacementView(placement: placement) { wordsMax in
            WingMarquee(words: words, maxWidth: wordsMax)
                .font(.system(size: 11.5))
                .lineLimit(1)
                .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named(Self.slotSpace)) }) {
                    frames.words = $0
                }
                .padding(.horizontal, VoicedButtonStyle.labelInset)
        }
        .coordinateSpace(name: Self.slotSpace)
        .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .local) }) { frames.item = $0 }
        .fixedSize()
        let host = NSHostingView(rootView: root)
        host.frame = NSRect(x: 0, y: 0, width: 400, height: 40)
        for _ in 0..<20 {
            host.layoutSubtreeIfNeeded()
            try? await Task.sleep(for: .milliseconds(10))
        }
        return frames
    }

    /// **The pin (R-B3 makes it red).** A short name in the fresh column's 63-pt
    /// space: the item is EXACTLY its space wide (its right edge is the line
    /// less the air — never past it), and the words stand flush at its
    /// trailing edge, the wash's inset beyond them.
    ///
    /// **The trailing tolerance is the pixel grid's, not layout slack** (the
    /// stage window's red, batch B part 1 — traced): the words' natural width
    /// is fractional ("in Home" in SF 11.5 advances 44.93 pt — VX-736's
    /// CoreText measure), so the Spacer absorbs a fraction and SwiftUI snaps
    /// each frame to the backing grid on its own; the window measured the
    /// words at (12.5, 45.0) — maxX 57.5, half a point short of 58. Two edges
    /// each snapped by up to a quarter point at 2× (a half at 1×) can sit up
    /// to a point apart, so the line allows ≤ 1 pt; R-B3's old leading shape
    /// misses by ≈ 8 pt and stays red.
    @Test func aShortNameStandsFlushRightInItsSpace() async {
        let frames = await mount(.column(63), words: "in Home")
        #expect(abs(frames.item.width - 63) < 0.5, "the item takes exactly its space: \(frames.item)")
        #expect(frames.words.width > 20 && frames.words.width < 53, "premise: the words fit: \(frames.words)")
        #expect(abs(frames.words.maxX + VoicedButtonStyle.labelInset - 63) <= 1,
                "the words flush at the trailing edge, within the pixel grid: \(frames.words)")
    }

    /// A long name keeps the item's width (never wider — never across the
    /// line) and its words' window is the space less the wash's insets.
    @Test func aLongNameKeepsTheSpaceAndClipsInsideIt() async {
        let frames = await mount(.column(63), words: "in a wing with a very long name indeed")
        #expect(abs(frames.item.width - 63) < 0.5, "never wider than its space: \(frames.item)")
        #expect(abs(frames.words.width - (63 - 2 * VoicedButtonStyle.labelInset)) < 0.5,
                "the words' window is the space less the insets: \(frames.words)")
    }

    /// Below the floor nothing is drawn — one clear point keeps the item.
    @Test func belowTheFloorNothingIsDrawn() async {
        let frames = await mount(.hidden, words: "in Home")
        #expect(frames.words == .zero, "no words laid out")
        #expect(frames.item.width <= 1, "\(frames.item)")
    }

    // MARK: - The composition (by source — the `QuickEntryWingLabelTests` precedent)

    @Test func theToolbarItemRidesTheSlotAndTheMarquee() throws {
        let root = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/RootView.swift"),
            encoding: .utf8)
        let newNote = try #require(root.range(of: "Button(\"New Note\", systemImage: \"square.and.pencil\")"))
        let after = String(root[newNote.upperBound...])
        let item = try #require(after.range(of: "ToolbarItem(placement: .navigation) {"))
        let label = String(after[item.lowerBound...].prefix(1_200))
        #expect(label.contains("WingToolbarSlot(sidebarShown: router.sidebarShown)"), "the column's space")
        #expect(label.contains("WingMarquee("), "the ticker, never a truncation")
        #expect(!label.contains(".truncationMode(.tail)"), "no ellipsis (VX-844 — declined)")
        #expect(!label.contains("frame(maxWidth: 160"), "no column-blind cap in the column")
    }
}
