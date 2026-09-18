//
//  BookOutlineHeights.swift
//  Variorum
//
//  **Phase 13u2b UNIT 1 — the book Outline's answer to "what is this row
//  tall", and how it gets better.** The arithmetic is the pure
//  `BookHeightManifest` / `BookOutlineHeightModel` (`Surface/`); this is the
//  part that has to touch the world: it measures the voice's type once per
//  width, and it LEARNS — every row that renders real content reports its
//  height, and the column believes what it saw over anything it modelled.
//
//  **Why learning is the whole trick.** A modelled card height is a guess
//  about fonts, paddings and wrapping; a measured one is what the column
//  actually drew. The Outline realizes a screenful of rows within the first
//  frames of a book opening, so by the time she clicks a far chapter — her
//  gesture is *"open the book, click a chapter"* — the model has already
//  been replaced by measurements for every shape on screen. What is left
//  modelled is the first frame of the first book of the session, and that is
//  the one case a landing does not happen in.
//
//  **Learning is by ROW and by SHAPE.** A row's own measurement is the truth
//  about that row. A SHAPE's measurement — a chapter heading; a card whose
//  preview wraps to N lines — is the truth about every row that looks like
//  it, because those rows differ in nothing that changes their height. One
//  realized chapter heading therefore tells the column what all 13 of
//  Sherlock's chapter headings are tall, before any of them is drawn.
//
//  **Everything is per WIDTH and per VOICE, and nothing survives either
//  moving** — a card wraps differently at another measure, and Study's 16-pt
//  Iowan is not Terminal's 14-pt monospace. The stamp is the same shape
//  `SurfaceSizeMemory.Record` carries, and for the same reason.
//
//  Not observed, deliberately: it is written at GEOMETRY cadence (every
//  report while a column loads) and read at a row's own body — an observed
//  property here would re-render the book per report, which is the 7 Hz loop
//  row 53 already paid for once. The one thing views DO observe is the
//  column's width (`BookViewModel.outlineContentWidth`), which changes when
//  the window does and not otherwise.
//

import AppKit
import Foundation
import VariorumCore

@MainActor
final class BookOutlineHeights {
    typealias Shape = BookOutlineHeightModel.Shape

    /// The width + voice these answers stand at. When it changes, everything
    /// learned under the old one is dropped in the same breath — a height
    /// measured at another measure is not this row's height here.
    private var stamp = ""
    private(set) var width: CGFloat = 0
    private(set) var metrics = BookOutlineHeightModel.Metrics()
    /// What each ROW reported while rendering real content.
    private var measured: [String: CGFloat] = [:]
    /// What each SHAPE reported — a heading, a card of N preview lines.
    private var byShape: [Shape: CGFloat] = [:]
    /// Each note's card shape, derived once (see `cardShape`).
    private var cardShapes: [String: Shape] = [:]

    /// Stand at this width (and the voice now in force), re-measuring the
    /// type and dropping what was learned elsewhere. Idempotent: the same
    /// width and voice re-stamps nothing.
    ///
    /// Returns whether anything moved, so the caller can decide whether the
    /// column owes itself a re-land.
    @discardableResult
    func stand(at width: CGFloat) -> Bool {
        let stamp = Self.stamp(width: width)
        guard stamp != self.stamp else { return false }
        self.stamp = stamp
        self.width = width
        self.metrics = Self.metrics(columnWidth: width)
        measured = [:]
        byShape = [:]
        cardShapes = [:]
        return true
    }

    /// A row reported its height while rendering REAL content. Recorded for
    /// the row and for its shape; a placeholder's height is never learned
    /// (it would teach the column what the column already guessed).
    func learn(_ id: String, shape: Shape, height: CGFloat) {
        guard height.isFinite, height > 0 else { return }
        // Only a real change is written: the guard is what keeps this off the
        // hot path — a row re-reporting the same height during a scroll costs
        // two comparisons and no write.
        if let known = measured[id], abs(known - height) <= 0.5 { return }
        measured[id] = height
        if case .expandedNote = shape { return }  // every note is its own length
        if let known = byShape[shape], abs(known - height) <= 0.5 { return }
        byShape[shape] = height
    }

    /// What the column should stand this row at — the manifest's precedence,
    /// asked for ONE row.
    ///
    /// `remembered` is the persisted answer where one exists (an expanded
    /// note's `SurfaceSizeMemory` record at this width); `derived` overrides
    /// the shape model where the caller has a better derivation (an expanded
    /// note's estimate from its blocks' lengths).
    func height(_ id: String, shape: Shape, remembered: CGFloat? = nil, derived: CGFloat? = nil) -> CGFloat {
        BookHeightManifest.resolve(input(id, shape: shape, remembered: remembered, derived: derived)).0
    }

    /// The same answer as an `Input`, for the whole-column manifest — one
    /// precedence brain, asked per row and per column.
    func input(
        _ id: String, shape: Shape, remembered: CGFloat? = nil, derived: CGFloat? = nil
    ) -> BookHeightManifest.Input {
        BookHeightManifest.Input(
            id: id,
            measured: measured[id],
            // A sibling of the same shape is a measurement too — of this
            // column, at this width, this session — so it sits in the
            // REMEMBERED tier rather than the derived one, above a persisted
            // record only because the persisted record may be a launch old.
            remembered: byShape[shape] ?? remembered,
            derived: derived ?? BookOutlineHeightModel.modelled(shape, metrics: metrics))
    }

    /// The card's shape at this width (its preview's wrapped line count),
    /// **memoized per note** — the column asks for every note's shape on
    /// every one of its own body evaluations, and deriving it means counting
    /// the preview's characters, so the uncached form is ∝ the book's
    /// previews per pass (P1's own shape of wrong). A preview is read once
    /// per note per book and refreshed only when a note that was open closes,
    /// which is where the cache is dropped (`forgetCardShape`); a width or
    /// voice change drops all of them with everything else learned.
    ///
    /// The excerpt is an `@autoclosure` so the cached path does not even ask
    /// the model for the string.
    func cardShape(_ postID: String, excerpt: @autoclosure () -> String) -> Shape {
        if let cached = cardShapes[postID] { return cached }
        let shape = BookOutlineHeightModel.cardShape(excerpt: excerpt(), metrics: metrics)
        cardShapes[postID] = shape
        return shape
    }

    /// This note's preview has been re-read — its shape may have changed with
    /// it, and its old row measurement was taken at the old shape.
    func forgetCardShape(_ postID: String) {
        cardShapes[postID] = nil
    }

    /// How many rows the column has actually measured — the DEBUG story's
    /// "how cold is this book" number.
    var learnedRowCount: Int { measured.count }

    // MARK: - The type, measured off the real font

    private static func stamp(width: CGFloat) -> String {
        "\(Int(width.rounded()))|\(EditorTypography.fingerprint ?? "-")"
    }

    /// The metrics at a column width. Only the WIDTH-dependent numbers and
    /// the prose model are measured off the font; the card's chrome and line
    /// pitch keep the traced constants (`BookOutlineHeightModel.Metrics`'
    /// defaults — 46 and 19 pt, read off the real Sherlock book), because
    /// those are measurements of the shipped surface and a font-derived model
    /// of them would be a guess REPLACING a measurement. They are in any case
    /// superseded by this column's own report within the first frames.
    static func metrics(columnWidth: CGFloat) -> BookOutlineHeightModel.Metrics {
        var metrics = BookOutlineHeightModel.Metrics()
        let resolved = EditorTypography.current
        let font = resolved.font
        // The average advance, measured the way the flow's estimate measures
        // it (`FlowHeightEstimate.metrics`) — off the real font, never a
        // constant per family.
        let sample = "the quick brown fox jumps over a lazy dog and keeps going "
        let advance = (sample as NSString)
            .size(withAttributes: [.font: font]).width / CGFloat(sample.count)
        let lineHeight = font.ascender - font.descender + font.leading
        let cardInner = max(80, columnWidth - 2 * BookOutlineHeights.cardHorizontalPadding)
        metrics.cardCharsPerLine = max(8, Double(cardInner / max(advance, 1)))
        // The expanded note's prose: the editor's own type, on the editor's
        // own measure (the Outline renders Write's surface at Write's
        // column — 13c 2A), with the paragraph gap the surface lays out with.
        let prose = min(columnWidth, EditorTypography.maxColumnWidth)
        metrics.prose = BookOutlineHeightModel.ProseMetrics(
            charsPerLine: max(8, Double(prose / max(advance, 1))),
            linePitch: lineHeight,
            lineSpacing: 0,
            paragraphGap: EditorTypography.laidOutParagraphSpacing(resolved))
        return metrics
    }

    /// The card's own horizontal padding (`collapsedPostCard`), so the
    /// preview's measure is the text's measure and not the row's.
    static let cardHorizontalPadding: CGFloat = 16
    /// The gap the Outline's column puts between rows — its `VStack(spacing:)`
    /// at both levels (the segments' and each run's), so the manifest's
    /// offsets are the column's own arithmetic and not a second number.
    static let rowSpacing: CGFloat = 10
}

#if DEBUG
/// 13u2b UNIT 1's P1 pin support: how many times the Outline ran the LENGTHS
/// query. A book opened and read with everything collapsed must never run it
/// at all — a card's height has nothing to do with its note's length — and a
/// book whose stories are opened runs it ONCE (the read is cached for the
/// book, beside the flow's).
///
/// **Keyed by the BOOK** (the 18d batch-3 rule, and `DebugProbeScope`'s own
/// reason): Swift Testing runs suites in parallel, so a counter that says
/// "the Outline" rather than "MY Outline" is a pin that can go red because
/// someone else opened a book.
@MainActor
enum BookOutlineExtentReads {
    static var byBook: [String: Int] = [:]
    static func count(_ readingID: String) -> Int { byBook[readingID] ?? 0 }
}
#endif
