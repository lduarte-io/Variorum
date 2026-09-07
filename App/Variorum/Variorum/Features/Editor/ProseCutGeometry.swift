//
//  ProseCutGeometry.swift
//  Variorum (Mac)
//
//  **THE CEREMONY'S PROSE, LAID OUT** — 18f batch 2 (the 2026-09-06
//  use-report round, her ledger row 5: *"so ugly with the spacing between
//  the words, the way that you have to scroll to get the different takes,
//  just overall"*).
//
//  The shipped face drew each take as a TOKEN FLOW: a word, a fixed 9-pt
//  slot, a word, a slot… (`CutFlowGeometry`). Every legal cut position
//  occupied real width, so the prose read with a gap between every pair of
//  words — the exact thing she called ugly. The mockup's answer (figure A):
//  **the take reads as prose, and the ✂ is drawn OVER the inter-word gap it
//  sits in.** Nothing in the layout belongs to the cut, so placing or moving
//  the ✂ can never move a word or change a line count.
//
//  This is that layout, as ONE BRAIN — the same doctrine `CutFlowGeometry`
//  was written under (L1, QoL round 2026-07-29) and for the same reason: the
//  view draws from it and the pointer resolves against it, so drawing and
//  hit-testing cannot disagree.
//
//    · **Lines** come from Core Text (`CTTypesetter`), one paragraph at a
//      time so a take's own newlines survive. Nothing here touches TextKit —
//      neither TK1 (forbidden: TEXTKIT2 §4) nor a live TK2 surface: a sheet
//      is chrome, and this is a measurement, not an editor.
//    · **Slots** are the take's legal cut positions (`legalCutPositions`,
//      passed in — never re-derived here, the L1 rule), each placed at its
//      character's x on its line, as a ZERO-WIDTH mark.
//    · **Snapping is `CutFlowGeometry.nearestSlot`, literally** — the slots
//      are handed to that one function, so "row first, then distance, strong
//      slots pull" stays one rule in one place, with its own pins
//      (`CutFlowEndSlotTests`), rather than a second implementation that has
//      to agree with the first.
//
//  Cost: one typesetting pass and one word scan per (text, width, font),
//  cached by the view. Placing a cut reads the cache and draws — it does not
//  re-lay anything out, which is what makes the layout stable under the ✂
//  (pinned in `ProseCutGeometryTests` and, at her scale, in
//  `DivideCeremonyCostTests`).
//

import AppKit
import CoreText
import Foundation

/// One take's text, laid out for the ceremony card: where every line sits,
/// where every legal cut sits, and how many words fall on each side of a cut.
/// (Main-actor, like `CutFlowGeometry` whose snapping brain it calls: the
/// layout happens in the card's body, and the take's own O(text) derivation
/// — boundaries, the strong set — already ran off the main actor when the
/// ceremony opened, which is the cost L1 cared about.)
struct ProseCutGeometry {
    struct Line {
        /// The line's range in the take's full text (UTF-16), including any
        /// trailing newline it consumed.
        let range: NSRange
        /// Top-left of the line's band, in the card's own coordinates.
        let origin: CGPoint
        /// The band's height (ascent + descent + leading, plus the prose gap).
        let height: CGFloat
        /// The baseline's offset from `origin.y`.
        let baseline: CGFloat
        /// Where the line's GLYPHS start inside its band — the air above them
        /// is where the ✂ glyph rides (see `markGlyphAir`).
        let textTop: CGFloat
        /// The drawn width of the line's glyphs.
        let width: CGFloat
        let line: CTLine
    }

    private(set) var lines: [Line] = []
    /// The take's legal cut positions as placed marks — handed to
    /// `CutFlowGeometry.nearestSlot` for every click and drag.
    private(set) var flow = CutFlowGeometry()
    private(set) var size: CGSize = .zero
    /// The UTF-16 offset where each word starts, ascending — the status
    /// line's "41 words above, 38 below" without re-counting per render.
    private(set) var wordStarts: [Int] = []
    private(set) var textLength = 0

    var isEmpty: Bool { lines.isEmpty }

    /// The extra air between prose lines, as a fraction of the font's own
    /// line height — the mockup's 1.55 leading, minus what the font already
    /// carries.
    static let lineGapFactor: CGFloat = 0.26

    /// **The air above every line, where the ✂ glyph rides.** The mockup
    /// draws the glyph over the line's top edge (its `.cut::after`), and prose
    /// at 1.55 leading is what gives it room; without this the glyph lands in
    /// the middle of the line above (walked, 18f batch 2's first look).
    ///
    /// It lives in the LAYOUT rather than in the drawing so the marks, the
    /// drawing and the pointer keep ONE coordinate space — an offset applied
    /// at draw time only would have to be subtracted again at hit-test time,
    /// which is the two-mechanisms class this file exists to avoid.
    static let markGlyphAir: CGFloat = 13

    // MARK: - Making it

    /// Lays `text` out at `width` in `font`. `boundaries` is the take's
    /// cached legal cut list and `strong` its cached strong subset — both
    /// passed in, never derived here (deriving per call is the exact defect
    /// `CutFlowGeometry` was written to kill).
    static func make(
        text: String, boundaries: [Int], strong: Set<Int>,
        width: CGFloat, font: NSFont
    ) -> ProseCutGeometry {
        guard width > 0, !text.isEmpty else { return ProseCutGeometry() }
        var geometry = ProseCutGeometry()
        geometry.textLength = (text as NSString).length
        geometry.wordStarts = wordStartOffsets(in: text)

        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let ns = attributed.string as NSString
        let typesetter = CTTypesetterCreateWithAttributedString(attributed)

        let ascent = font.ascender
        let descent = -font.descender
        let leading = font.leading
        let bandHeight = (ascent + descent + leading).rounded(.up)
        let air = max((bandHeight * lineGapFactor).rounded(), markGlyphAir)
        let lineHeight = bandHeight + air
        let baseline = (air + ascent).rounded()

        var y: CGFloat = 0
        var widest: CGFloat = 0

        // Paragraph by paragraph, because Core Text's typesetter does not
        // break at newlines — and a take's own line structure is content
        // (I4: internal newlines are the block's text).
        var paragraphStart = 0
        while paragraphStart <= geometry.textLength {
            let newline = ns.range(
                of: "\n",
                options: [],
                range: NSRange(
                    location: paragraphStart,
                    length: geometry.textLength - paragraphStart))
            let paragraphEnd = newline.location == NSNotFound
                ? geometry.textLength : newline.location + 1
            var start = paragraphStart
            repeat {
                // An empty paragraph still draws a line: a blank line she
                // typed is part of the take and must be visible in the card.
                let remaining = paragraphEnd - start
                var count = remaining <= 0
                    ? 0
                    : CTTypesetterSuggestLineBreak(typesetter, start, Double(width))
                if remaining > 0, count <= 0 { count = 1 }
                let range = NSRange(location: start, length: max(0, min(count, remaining)))
                let line = CTTypesetterCreateLine(
                    typesetter, CFRangeMake(range.location, range.length))
                let drawn = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
                geometry.lines.append(Line(
                    range: range, origin: CGPoint(x: 0, y: y), height: lineHeight,
                    baseline: baseline, textTop: air, width: drawn, line: line))
                widest = max(widest, drawn)
                y += lineHeight
                start = range.location + range.length
            } while start < paragraphEnd
            if newline.location == NSNotFound { break }
            paragraphStart = paragraphEnd
            // A text ending in a newline has one more (empty) line after it.
            if paragraphStart == geometry.textLength {
                let line = CTTypesetterCreateLine(
                    typesetter, CFRangeMake(geometry.textLength, 0))
                geometry.lines.append(Line(
                    range: NSRange(location: geometry.textLength, length: 0),
                    origin: CGPoint(x: 0, y: y), height: lineHeight,
                    baseline: baseline, textTop: air, width: 0, line: line))
                y += lineHeight
                break
            }
        }

        geometry.size = CGSize(width: min(widest, width), height: y)
        geometry.flow = CutFlowGeometry(
            tokens: [],
            slots: boundaries.compactMap { boundary in
                guard let point = geometry.markFrame(at: boundary) else { return nil }
                return CutFlowGeometry.Slot(
                    boundary: boundary, frame: point, isStrong: strong.contains(boundary))
            },
            size: geometry.size)
        return geometry
    }

    /// The word starts, by the app's ONE word rule (`.byWords`, the same
    /// enumeration `TextMetrics.wordCount` counts with — pinned to agree).
    /// Recorded once per layout so the status line is a binary search, never
    /// a re-count.
    private static func wordStartOffsets(in text: String) -> [Int] {
        var starts: [Int] = []
        text.enumerateSubstrings(
            in: text.startIndex..., options: [.byWords, .substringNotRequired]
        ) { _, range, _, _ in
            starts.append(NSRange(range, in: text).location)
        }
        return starts
    }

    // MARK: - Reading it

    /// The line a cut at `boundary` belongs to: the line containing it, and
    /// for the text's very end (and for a boundary at a soft-wrap point that
    /// no line contains) the last line that reaches it.
    func lineIndex(for boundary: Int) -> Int? {
        guard !lines.isEmpty else { return nil }
        for (i, line) in lines.enumerated()
        where boundary >= line.range.location && boundary < line.range.upperBound {
            return i
        }
        // The end of the text, or the end of the last line before a
        // paragraph break — the mark belongs to the line that ends there.
        for (i, line) in lines.enumerated().reversed()
        where boundary >= line.range.location && boundary <= line.range.upperBound {
            return i
        }
        return boundary <= lines[0].range.location ? 0 : lines.count - 1
    }

    /// Where the ✂ mark sits for `boundary` — a hairline-wide frame spanning
    /// its line's band, in the card's coordinates. Zero-width by design: the
    /// mark is drawn OVER the prose and owns no layout.
    func markFrame(at boundary: Int) -> CGRect? {
        guard let i = lineIndex(for: boundary) else { return nil }
        let line = lines[i]
        let clamped = min(max(boundary, line.range.location), line.range.upperBound)
        var x = CGFloat(CTLineGetOffsetForStringIndex(line.line, clamped, nil))
        // A boundary that lands past this line's drawn glyphs (a trailing
        // newline, the text's end) sits at the line's trailing edge.
        if !x.isFinite { x = line.width }
        x = min(max(0, x), max(line.width, 0))
        return CGRect(
            x: line.origin.x + x - 0.5, y: line.origin.y, width: 1, height: line.height)
    }

    /// **The one snapping brain.** A click or drag resolves through
    /// `CutFlowGeometry.nearestSlot` — row first, then horizontal distance,
    /// with the strong slots' extra catch — over these prose-placed marks.
    func nearestBoundary(to point: CGPoint) -> Int? {
        flow.nearestSlot(to: point)
    }

    /// How many words fall before `cut` (and, by subtraction, after it).
    func wordsBefore(_ cut: Int) -> Int {
        var low = 0
        var high = wordStarts.count
        while low < high {
            let mid = (low + high) / 2
            if wordStarts[mid] < cut { low = mid + 1 } else { high = mid }
        }
        return low
    }

    var wordCount: Int { wordStarts.count }

    /// The two halves' tint rectangles for a cut at `cut`: every line before
    /// it whole, every line after it whole, and the cut's own line split at
    /// the mark. Drawn behind the prose, so the tint is the layout's
    /// passenger and never its cause.
    func halfRects(splitAt cut: Int?) -> (top: [CGRect], bottom: [CGRect]) {
        guard !lines.isEmpty else { return ([], []) }
        guard let cut else { return ([], []) }
        var top: [CGRect] = []
        var bottom: [CGRect] = []
        for line in lines {
            let band = CGRect(
                x: line.origin.x, y: line.origin.y + line.textTop,
                width: max(line.width, 1), height: line.height - line.textTop)
            if line.range.upperBound <= cut {
                top.append(band)
            } else if line.range.location >= cut {
                bottom.append(band)
            } else {
                var x = CGFloat(CTLineGetOffsetForStringIndex(line.line, cut, nil))
                if !x.isFinite { x = line.width }
                x = min(max(0, x), max(line.width, 0))
                if x > 0.5 {
                    top.append(CGRect(
                        x: band.minX, y: band.minY, width: x, height: band.height))
                }
                if band.width - x > 0.5 {
                    bottom.append(CGRect(
                        x: band.minX + x, y: band.minY,
                        width: band.width - x, height: band.height))
                }
            }
        }
        return (top, bottom)
    }
}
