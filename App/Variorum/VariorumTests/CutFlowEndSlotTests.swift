//
//  CutFlowEndSlotTests.swift
//  VariorumTests
//
//  **LEDGER ROW 3** (the 2026-09-06 use-report round, 18f batch 1) — her
//  words: *"the scissors couldn't be placed at the end of the block"*.
//
//  The plan's §4.4 names three links between "the end is legal by design"
//  and "the ✂ would not go there", and orders them: (i) the legal set
//  itself, (ii) the flow's layout of the END slot, (iii) the pointer
//  resolution right of the last token. These are those three, written
//  BEFORE any fix, so whichever reds is the mechanism and whichever passes
//  is recorded as sound rather than "fixed" on suspicion. The gesture
//  wiring above them (`WCutFlow`'s drag) is a face and is WALKED — the
//  real-click rig cannot mount a whole sheet (KnownIssues row 43).
//
//  These are PURE-BRAIN pins by construction, so 18f batch 2's rebuilt
//  face inherits them unchanged (the batch-2 brief's own promise).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The ceremony's END slot (use-report row 3)")
struct CutFlowEndSlotTests {
    private var font: NSFont { NSFont.preferredFont(forTextStyle: .callout) }

    /// Lays one take's text out exactly as the sheet does.
    private func geometry(of text: String, width: CGFloat) -> (
        CutFlowGeometry, boundaries: [Int], strong: Set<Int>
    ) {
        let boundaries = DivideWCeremony.legalCutPositions(of: text)
        let strong = Set(BoundarySnapping.boundaries(in: text, granularity: .sentence))
            .intersection(boundaries)
            .union([0, text.utf16.count].filter { boundaries.contains($0) })
        let flow = WCutPlacement.flowItems(text: text, boundaries: boundaries)
        return (
            CutFlowGeometry.make(
                flow: flow, strong: strong, width: width, font: font),
            boundaries, strong)
    }

    /// **(i) — the legal set.** `legalCutPositions` is the ruled WORD set
    /// with both ends kept (S4-22's parking slots), so the take's very end
    /// is placeable. `"Alpha beta."` is 11 UTF-16 units; 11 is the end.
    @Test func theEndOfATakeIsALegalCutPosition() {
        let positions = DivideWCeremony.legalCutPositions(of: "Alpha beta.")
        #expect(positions.contains(11), "the end parks a whole take: \(positions)")
        #expect(positions.first == 0, "and so does the start")
        // The end survives every ending shape — a terminator, a trailing
        // space, a trailing newline (the shapes a real take actually ends
        // with, and the ones a "boundaries are word starts" reading would
        // most plausibly drop).
        for text in ["Alpha beta.", "Alpha beta", "Alpha beta. ", "Alpha beta.\n", "One"] {
            #expect(
                DivideWCeremony.legalCutPositions(of: text).last == text.utf16.count,
                "the end of \(text.debugDescription) is placeable")
        }
        // An EMPTY take is the one deliberate exception (0 and the end
        // coincide — "which block gets the blank" is a guess).
        #expect(DivideWCeremony.legalCutPositions(of: "").isEmpty)
    }

    /// **(ii) — the flow's layout.** `CutFlowGeometry.make` ends every
    /// take's flow with `.slot(end)`; the drawn ✂ rides `slotFrame(for:)`,
    /// and the flow is framed to the geometry's own size. §4.4's suspicion:
    /// `size.width = min(widest, width)` could clip the end slot when the
    /// LAST line is the widest. Pinned at a width that wraps, with the
    /// wrap's shape asserted so the pin cannot go vacuous.
    @Test func theEndSlotIsLaidOutInsideTheFlowsOwnSize() throws {
        // Short first line, long last line — the exact shape §4.4 names.
        let text = "One two.\nA rather longer closing line of several words here."
        let width: CGFloat = 420
        let (laid, boundaries, _) = geometry(of: text, width: width)
        let end = try #require(boundaries.last)
        #expect(end == text.utf16.count)

        let frame = try #require(
            laid.slotFrame(for: end), "the flow ends with a placeable end slot")

        // Non-vacuity: the take really did wrap, and its LAST line really is
        // the widest — otherwise this pin would prove nothing about the
        // `min(widest, width)` clip it exists to check.
        let rows = Set(laid.tokens.map { $0.frame.minY } + laid.slots.map { $0.frame.minY })
        #expect(rows.count > 1, "the take wrapped: \(rows.count) row(s)")
        let lastRow = rows.max()!
        func rightEdge(ofRow y: CGFloat) -> CGFloat {
            let tokenEdge = laid.tokens.filter { $0.frame.minY == y }.map(\.frame.maxX).max() ?? 0
            let slotEdge = laid.slots.filter { $0.frame.minY == y }.map(\.frame.maxX).max() ?? 0
            return max(tokenEdge, slotEdge)
        }
        let otherRows = rows.filter { $0 != lastRow }
        #expect(otherRows.allSatisfy { rightEdge(ofRow: $0) <= rightEdge(ofRow: lastRow) },
                "the LAST line is the widest — the shape §4.4 suspects")

        let width2 = laid.size.width
        let height2 = laid.size.height
        #expect(frame.maxX <= width2 + 0.01,
                "the end slot sits inside the flow's width (slot ends at \(frame.maxX), size is \(width2))")
        #expect(frame.maxY <= height2 + 0.01,
                "…and inside its height (slot ends at \(frame.maxY), size is \(height2))")
    }

    /// **(iii) — the pointer.** A click or drag right of the last token, on
    /// the last line, must resolve to the END slot: that is the whole road
    /// from "she dragged the ✂ past the last word" to "the take parks".
    @Test func aPointRightOfTheLastTokenResolvesToTheEndSlot() throws {
        let text = "One two.\nA rather longer closing line of several words here."
        let (laid, boundaries, _) = geometry(of: text, width: 420)
        let end = try #require(boundaries.last)
        let endFrame = try #require(laid.slotFrame(for: end))

        // Just past the last token, on its own row.
        #expect(laid.nearestSlot(to: CGPoint(x: endFrame.midX + 3, y: endFrame.midY)) == end)
        // Far to the right of the row — the "drag off the end" gesture.
        #expect(laid.nearestSlot(to: CGPoint(x: endFrame.maxX + 400, y: endFrame.midY)) == end)
        // And below the last row (a drag that overshoots downward).
        #expect(laid.nearestSlot(
            to: CGPoint(x: endFrame.maxX + 400, y: endFrame.maxY + 40)) == end)
    }

    /// The keyboard road to the same place (←/→ is the accessible placement
    /// path the drawn flow deliberately keeps): stepping forward from
    /// anywhere lands on the end and STAYS there — no wraparound past the
    /// parking slot.
    @Test func steppingForwardReachesTheEndAndParksThere() {
        let text = "Alpha beta gamma delta."
        let boundaries = DivideWCeremony.legalCutPositions(of: text)
        var cut: Int? = boundaries.first
        for _ in 0..<(boundaries.count + 3) {
            cut = WCutPlacement.wordStep(from: cut, boundaries: boundaries, forward: true)
        }
        #expect(cut == text.utf16.count, "→ walks to the end and parks")
    }
}
