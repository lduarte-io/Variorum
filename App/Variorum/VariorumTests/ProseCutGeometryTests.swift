//
//  ProseCutGeometryTests.swift
//  VariorumTests
//
//  **18f batch 2 — THE FACE'S PINS** (the 2026-09-06 use-report round,
//  ledger row 5 + mockup figure A). Her verdict on the shipped sheet:
//  *"so ugly with the spacing between the words, the way that you have to
//  scroll to get the different takes, just overall"*.
//
//  The rebuilt card draws the take as PROSE and overlays the ✂ on the
//  inter-word gap it sits in. These pin the four promises §5.2 names for
//  that surface:
//
//    · natural spacing — no slot occupies width (RED on the token flow,
//      asserted here side by side against `CutFlowGeometry` itself);
//    · the hit test — a click at a character lands the nearest legal cut,
//      through the ONE snapping brain (row first, then distance);
//    · the END is reachable by click and by a drag past the last word
//      (ledger row 3's road, on the new surface);
//    · the geometry never moves when the ✂ does — the layout is a pure
//      function of (text, width, font) and knows nothing about the cut.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The ceremony card's prose layout (18f batch 2)")
struct ProseCutGeometryTests {
    private var font: NSFont { .systemFont(ofSize: 14) }

    private func laid(_ text: String, width: CGFloat) -> ProseCutGeometry {
        let boundaries = DivideWCeremony.legalCutPositions(of: text)
        let strong = Set(BoundarySnapping.boundaries(in: text, granularity: .sentence))
            .intersection(boundaries)
            .union([0, text.utf16.count].filter { boundaries.contains($0) })
        return ProseCutGeometry.make(
            text: text, boundaries: boundaries, strong: strong, width: width, font: font)
    }

    /// **HER ROW 5, pinned — RED ON THE SHIPPED FLOW.** The take reads as
    /// prose: the laid width is what the font measures for the text, not the
    /// text plus a 9-pt slot between every pair of words. The token flow's
    /// own width for the same string is asserted beside it so this can never
    /// go vacuous — that difference IS *"the spacing between the words"*.
    @Test func theProseIsLaidOutAtItsNaturalWidth() throws {
        let text = "Alpha beta gamma delta epsilon."
        let natural = (text as NSString)
            .size(withAttributes: [.font: font]).width
        let prose = laid(text, width: 2000)
        #expect(prose.lines.count == 1, "one line at a generous width")
        #expect(abs(prose.size.width - natural) < 2,
                "the prose is its own measure (\(prose.size.width) vs \(natural))")

        let boundaries = DivideWCeremony.legalCutPositions(of: text)
        let flow = CutFlowGeometry.make(
            flow: WCutPlacement.flowItems(text: text, boundaries: boundaries),
            strong: [], width: 2000, font: font)
        #expect(flow.size.width > prose.size.width + 30,
                """
                non-vacuity: the SHIPPED flow was \(flow.size.width) wide for the \
                same sentence — one 9-pt slot per legal cut — against the prose's \
                \(prose.size.width)
                """)
    }

    /// A click at a character lands the nearest legal cut. The resolution is
    /// `CutFlowGeometry.nearestSlot` itself (one brain, its own pins), fed
    /// prose-placed marks instead of flow slots.
    @Test func aClickAtACharacterLandsTheNearestLegalCut() throws {
        let text = "Alpha beta gamma delta epsilon."
        let prose = laid(text, width: 2000)
        let boundaries = DivideWCeremony.legalCutPositions(of: text)
        #expect(boundaries.count > 3, "non-vacuity: several legal cuts")

        for boundary in boundaries {
            let frame = try #require(prose.markFrame(at: boundary))
            #expect(prose.nearestBoundary(
                to: CGPoint(x: frame.midX, y: frame.midY)) == boundary,
                    "a click on the mark at \(boundary) lands there")
        }
        // And a click a couple of points off still lands on the same one —
        // the gentle settle, not a pixel hunt.
        let middle = boundaries[boundaries.count / 2]
        let frame = try #require(prose.markFrame(at: middle))
        #expect(prose.nearestBoundary(
            to: CGPoint(x: frame.midX + 2, y: frame.midY)) == middle)
    }

    /// **LEDGER ROW 3 on the NEW surface** — her *"the scissors couldn't be
    /// placed at the end of the block"*. A click right of the last word, a
    /// drag far past it, and a drag that overshoots downward all park the ✂
    /// at the take's end.
    @Test func aDragPastTheLastWordParksTheCutAtTheEnd() throws {
        let text = "One two.\nA rather longer closing line of several words here."
        let prose = laid(text, width: 240)
        #expect(prose.lines.count > 2, "non-vacuity: the take wrapped")
        let end = text.utf16.count
        let frame = try #require(prose.markFrame(at: end), "the end has a mark")

        #expect(prose.nearestBoundary(
            to: CGPoint(x: frame.midX + 3, y: frame.midY)) == end)
        #expect(prose.nearestBoundary(
            to: CGPoint(x: frame.maxX + 400, y: frame.midY)) == end,
                "dragging far off the end of the line parks there")
        #expect(prose.nearestBoundary(
            to: CGPoint(x: frame.maxX + 400, y: frame.maxY + 60)) == end,
                "…and so does overshooting downward")
    }

    /// The snapping rule is the flow's, unchanged: the row the pointer is on
    /// wins outright, before any horizontal distance.
    @Test func theRowWinsBeforeTheHorizontalDistance() throws {
        let text = "One two three four five six seven eight nine ten eleven twelve."
        let prose = laid(text, width: 150)
        #expect(prose.lines.count > 1, "non-vacuity: several rows")
        let second = prose.lines[1]
        // A point at the far right of the SECOND row: the boundary it lands
        // on must live on that row, even though the first row's trailing
        // boundary may be horizontally nearer.
        let landed = try #require(prose.nearestBoundary(
            to: CGPoint(x: 400, y: second.origin.y + second.height / 2)))
        let landedFrame = try #require(prose.markFrame(at: landed))
        #expect(abs(landedFrame.midY - (second.origin.y + second.height / 2)) < 1,
                "the landing sits on the row the pointer was on")
    }

    /// **THE GEOMETRY PIN §5.2 names: the ✂ overlay never changes the take's
    /// line count.** The layout is a pure function of (text, width, font) —
    /// the cut is not one of its inputs — and every legal cut's mark sits
    /// inside its own line's band, so nothing can be pushed anywhere.
    @Test func theLayoutNeverMovesWhenTheCutDoes() throws {
        let text = "One two three four five six seven eight nine ten eleven twelve."
        let prose = laid(text, width: 160)
        #expect(prose.lines.count > 1, "non-vacuity: the take wrapped")
        let boundaries = DivideWCeremony.legalCutPositions(of: text)

        for boundary in boundaries {
            let frame = try #require(prose.markFrame(at: boundary))
            let line = try #require(
                prose.lines.first { frame.midY >= $0.origin.y
                    && frame.midY < $0.origin.y + $0.height })
            #expect(frame.minY >= line.origin.y - 0.01
                && frame.maxY <= line.origin.y + line.height + 0.01,
                    "the mark at \(boundary) stays inside its own line's band")
            #expect(frame.maxX <= prose.size.width + 1,
                    "…and inside the laid width, so nothing re-wraps around it")
        }
        // The same text laid again is the same layout — the cut was never an
        // input, so there is nothing for it to change.
        let again = laid(text, width: 160)
        #expect(again.lines.count == prose.lines.count)
        #expect(again.size == prose.size)
    }

    /// The two halves' tints split exactly at the mark, and cover the lines
    /// on either side of it — the mockup's "shown, not explained".
    @Test func theTwoHalvesSplitExactlyAtTheMark() throws {
        let text = "One two three four five six seven eight nine ten eleven twelve."
        let prose = laid(text, width: 160)
        let boundaries = DivideWCeremony.legalCutPositions(of: text)
        let cut = try #require(boundaries.dropFirst(3).first)
        let mark = try #require(prose.markFrame(at: cut))
        let halves = prose.halfRects(splitAt: cut)

        #expect(!halves.top.isEmpty && !halves.bottom.isEmpty,
                "an interior cut tints both halves")
        // A tint band sits inside its line's box (the box carries the air
        // above the glyphs where the ✂ rides), so "same row" is containment.
        func sameRow(_ rect: CGRect) -> Bool {
            rect.minY >= mark.minY - 0.01 && rect.maxY <= mark.maxY + 0.01
        }
        for rect in halves.top {
            #expect(rect.maxY <= mark.minY + 0.01
                || (sameRow(rect) && rect.maxX <= mark.midX + 0.6),
                    "a top rect is above the mark, or left of it on its own row")
        }
        for rect in halves.bottom {
            #expect(rect.minY >= mark.maxY - 0.01
                || (sameRow(rect) && rect.minX >= mark.midX - 0.6),
                    "a bottom rect is below the mark, or right of it on its own row")
        }
        // No cut placed ⇒ no tint at all (an unplaced take is not half-anything).
        let none = prose.halfRects(splitAt: nil)
        #expect(none.top.isEmpty && none.bottom.isEmpty)
    }

    /// The status line's counts come from the app's ONE word rule — the same
    /// `.byWords` enumeration `TextMetrics.wordCount` counts with, recorded
    /// once per layout so a render is a binary search.
    @Test func theWordCountsAgreeWithTheAppsOneWordRule() {
        let text = "Alpha beta gamma. Delta epsilon zeta eta."
        let prose = laid(text, width: 2000)
        #expect(prose.wordCount == TextMetrics.wordCount(text))
        #expect(prose.wordsBefore(0) == 0)
        #expect(prose.wordsBefore(text.utf16.count) == TextMetrics.wordCount(text))
        let mid = (text as NSString).range(of: "Delta").location
        #expect(prose.wordsBefore(mid) == 3, "three words above the cut")
        #expect(prose.wordCount - prose.wordsBefore(mid) == 4, "…and four below")
    }

    /// A take's own newlines are content (I4) and survive as lines in the
    /// card — an outline-shaped take still reads as an outline.
    @Test func theTakesOwnNewlinesSurviveAsLines() {
        let text = "First line.\nSecond line.\n\nFourth line."
        let prose = laid(text, width: 2000)
        #expect(prose.lines.count == 4,
                "four display lines, blank one included (\(prose.lines.count))")
        #expect(prose.size.height > 0)
    }

    /// An empty take lays out to nothing — the card shows its "there's no cut
    /// to place" message instead, exactly as the shipped sheet did.
    @Test func anEmptyTakeLaysOutToNothing() {
        let prose = laid("", width: 400)
        #expect(prose.isEmpty)
        #expect(prose.nearestBoundary(to: .zero) == nil)
        #expect(prose.markFrame(at: 0) == nil)
    }
}

/// **The card's ONE status line, and the destination it names** (§5.2: *"one
/// status line per take"*). Pure copy over a pure rule, pinned rather than
/// read off a screenshot — `FannedDefaultsCopy`'s doctrine: a sentence may
/// only claim what the operation will actually do.
@MainActor
@Suite("The ceremony card's status line (18f batch 2)")
struct CeremonyCardCopyTests {
    private func destination(
        _ arrangement: DivideWCeremony.Arrangement, isSeed: Bool = false,
        marked: Bool = true, isEmpty: Bool = false, cut: Int? = 5,
        parkedAtEnd: Bool = false, parkedAtStart: Bool = false
    ) -> CeremonyDestination {
        CeremonyCardCopy.destination(
            arrangement: arrangement, isSeed: isSeed, marked: marked,
            isEmpty: isEmpty, cut: cut, parkedAtEnd: parkedAtEnd,
            parkedAtStart: parkedAtStart)
    }

    /// The seed splits under every arrangement; a parked ✂ names the block the
    /// whole take rides to, in the ruled direction (S4-22: end ⇒ the FIRST
    /// block, start ⇒ the second).
    @Test func theStatusLineNamesWhereEachTakeGoes() {
        #expect(destination(.keepOnTop, isSeed: true) == .split)
        #expect(destination(.perTake, parkedAtEnd: true) == .top)
        #expect(destination(.perTake, cut: 0, parkedAtStart: true) == .bottom)
        #expect(destination(.copyToBoth) == .both, "a non-seed take under copy-to-both")
        #expect(destination(.copyToBoth, isSeed: true) == .split, "…but the seed still splits")
        #expect(destination(.perTake, marked: false) == .original)
        #expect(destination(.perTake, cut: nil) == .unplaced)
        #expect(destination(.perTake, isEmpty: true) == .empty)
        #expect(destination(.keepOnTop, isEmpty: true) == .original,
                "an empty take under a preset can't be placed, so it stays behind")

        #expect(CeremonyCardCopy.status(.top, words: nil)
            .contains("stays on the top block"))
        #expect(CeremonyCardCopy.status(.bottom, words: nil)
            .contains("goes to the bottom block"))
        #expect(CeremonyCardCopy.status(.split, words: (41, 38))
            == "\u{2702} splits here — 41 words above, 38 below",
                "the mockup's own sentence, in counts")
        #expect(CeremonyCardCopy.status(.split, words: (1, 9))
            .contains("1 word above"), "singular is spoken")
        #expect(CeremonyCardCopy.status(.original, words: nil).contains("lineage"))
    }

    /// The footer's swatches say the same thing the status line does — one
    /// answer, two voices, so a card can never claim two destinations.
    @Test func theFooterAgreesWithTheStatusLine() {
        #expect(CeremonyCardCopy.footer(.split).count == 2)
        #expect(CeremonyCardCopy.footer(.top) == ["top block · whole"])
        #expect(CeremonyCardCopy.footer(.bottom) == ["bottom block · whole"])
        #expect(CeremonyCardCopy.footer(.both).count == 2)
        #expect(CeremonyCardCopy.footer(.original).isEmpty)
        #expect(CeremonyCardCopy.footerNote(.original) == "original block · lineage")
        #expect(CeremonyCardCopy.footerNote(.split) == nil)
    }

    /// The two sheets' resting lines name the canon path the originals go to
    /// (13f W10a's promise; `TrayPath.originalsPath` is the one home).
    @Test func theRestingLinesNameTheCanonPath() {
        #expect(CeremonyCardCopy.divideRestingLine.contains(TrayPath.originalsPath))
        #expect(CeremonyCardCopy.mergeRestingLine(blocks: 2).contains("Both original blocks"))
        #expect(CeremonyCardCopy.mergeRestingLine(blocks: 4)
            .contains(TrayPath.originalsPath))
    }

    /// The option cards' one-liners exist for every option of both rows, and
    /// **the word U-4 removed is in none of them** (batch 1 took "ceremony"
    /// out of every UI string; the mockup's own text for the fourth option
    /// still carried it).
    @Test func everyOptionCardHasALineAndNoneSaysCeremony() {
        for option in DivideWCeremony.Arrangement.allCases {
            #expect(!option.detail.isEmpty)
            #expect(!option.detail.lowercased().contains("ceremony"))
            #expect(!option.title.lowercased().contains("ceremony"))
        }
        for option in MergeArrangement.allCases {
            for blocks in [2, 4] {
                #expect(!option.detail(blocks: blocks).isEmpty)
                #expect(!option.detail(blocks: blocks).lowercased().contains("ceremony"))
            }
        }
    }
}
