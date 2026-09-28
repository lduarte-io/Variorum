//
//  BookIndexPaneHeights.swift
//  Variorum
//
//  **Phase 13u4 UNIT F3 — the book INDEX pane's answer to "what is this row
//  tall", and how it gets better.** The twin of `BookOutlineHeights` (13u2b
//  UNIT 1), on the surface that adopted only the other half of that phase's
//  answer.
//
//  **Why it exists, in one measured sentence** (UNIT F1's residual, and this
//  unit's own pre-fix baseline): a row of this pane is a whole NOTE standing
//  at a title and a blank line — about 40 pt — until `observeBlockTOC` returns
//  and at thousands afterwards, so in the first seconds after a book opens the
//  column's own height oscillates (measured in the app at
//  39k → 56k → 143k → 80k → 115k points inside six seconds) and a landing's
//  first aim, even when it is EXACT, is overtaken by the column moving under
//  it. **6 of 6 cold deep chapter clicks stalled** against that. A height the
//  column ASSERTS cannot do that.
//
//  **The three sources are the manifest's** (`BookHeightManifest`, pure):
//  MEASURED (what this very row reported while rendering REAL text) >
//  REMEMBERED (a sibling of the same shape, for the small rows) > DERIVED
//  (arithmetic over the note's blocks' stored LENGTHS — AppSpec §4's own
//  designed fallback, *"stored per-block length estimates, not live
//  geometry"*, through the ONE `ProseHeightModel` the Outline and the reading
//  flow already read).
//
//  **The pure model lives here rather than in `Surface/`**, beside the class
//  that feeds it, on `FlowHeightEstimate`'s precedent (which sits inside
//  `ReadingFlowView.swift` for the same reason): it is one surface's
//  arithmetic, it is `nonisolated` so a pin reads it without a window, and the
//  shared part — the paragraph model and the precedence — is already hoisted
//  (`ProseHeightModel`, `BookHeightManifest`). Stated rather than left to be
//  noticed, since the Outline's twin is split across two files.
//
//  Not observed, deliberately: written at GEOMETRY cadence (every report while
//  a column loads) and read in a row's own body — an observed property here
//  would re-render the pane per report, which is the 7 Hz loop row 53 paid for
//  once. The one thing views DO observe is the column's width
//  (`BookViewModel.indexContentWidth`) and the lengths' generation.
//

import AppKit
import CoreGraphics
import Foundation
import VariorumCore

/// The DERIVED arm's arithmetic for the book Index pane: what a row is tall
/// when nothing has measured it yet. Pure, and parameterized by METRICS the
/// caller measures off the real font (the `FlowHeightEstimate.metrics` /
/// `BookOutlineHeights.metrics` pattern, which exists so the model can be
/// pinned without a window).
nonisolated enum BookIndexPaneHeightModel {
    /// The type and chrome facts a pane row needs. Everything here is a
    /// measurement of the SHIPPED surface — the constants are read off
    /// `BookIndexView`'s own padding stack, named at each line, never guessed.
    struct Metrics: Equatable {
        /// How the note's prose wraps: the voice's body font at the pane's
        /// measure, its `lineSpacing(4)`, and the 8-pt gap the block column
        /// puts between paragraphs and between blocks.
        var prose: ProseHeightModel.Metrics = ProseHeightModel.Metrics(
            charsPerLine: 76, linePitch: 21, lineSpacing: 4, paragraphGap: 8)
        /// One block row's own vertical padding (`readTierTop` + `restingTop`
        /// in `BookIndexPaneNote.blockView`).
        var blockChrome: CGFloat = 12
        /// A block that renders nothing still occupies its one blank line
        /// (`blockView`'s `Text(" ")`).
        var emptyBlockLine: CGFloat = 21
        /// The note's own chrome: the title/date header row with its padding,
        /// the `VStack(spacing: 8)` under it, and the note's own vertical
        /// padding.
        var noteChrome: CGFloat = 60
        /// A note with nothing renderable at all: the one blank line the body
        /// falls back to.
        var emptyNote: CGFloat = 21
        /// A chapter heading row in the pane (the `.padding(.top, 26)` plus
        /// the title's own line).
        var heading: CGFloat = 52
        /// What a note stands at before the lengths have landed — the read is
        /// in flight for a few tens of milliseconds at most, and this is the
        /// Outline's and the flow's own never-measured prior, so the cold case
        /// is never worse than it was.
        var unknownNote: CGFloat = 800
    }

    /// One note's height from its blocks' stored LENGTHS — never its prose
    /// (`Queries.blockExtents` computes the lengths in SQL and no text
    /// crosses the boundary; P1: ∝ blocks, never ∝ text).
    ///
    /// The paragraph arithmetic is the ONE model (`ProseHeightModel`); what
    /// stays here is this surface's own half of the sentence — its per-block
    /// chrome, its blank line and its header — which are facts about this
    /// pane and not about prose.
    static func noteHeight(extents: [Queries.BlockExtent], metrics: Metrics) -> CGFloat {
        guard !extents.isEmpty else { return (metrics.noteChrome + metrics.emptyNote).rounded() }
        let empties = extents.filter { $0.characters <= 0 }.count
        let chrome = metrics.noteChrome
            + CGFloat(extents.count) * metrics.blockChrome
            + CGFloat(empties) * metrics.emptyBlockLine
        guard let prose = ProseHeightModel.height(extents: extents, metrics: metrics.prose) else {
            // Every block is blank: the chrome and the blank lines are the
            // whole of it.
            return chrome.rounded()
        }
        return (chrome + prose).rounded()
    }
}

/// What the Index pane has LEARNED about its own rows, and the type it
/// measured to derive the rest. One per book model; dropped whole when the
/// width or the voice moves.
@MainActor
final class BookIndexPaneHeights {
    /// The width + voice these answers stand at. When it changes, everything
    /// learned under the old one goes with it — a height measured at another
    /// measure is not this row's height here.
    private var stamp = ""
    private(set) var width: CGFloat = 0
    private(set) var metrics = BookIndexPaneHeightModel.Metrics()
    /// What each ROW reported while rendering REAL content, by anchor id.
    private var measured: [String: CGFloat] = [:]
    /// The derived answer per NOTE, memoized — the column asks for every
    /// row's height on every body pass, and deriving one means walking that
    /// note's blocks, so the uncached form is ∝ the book's BLOCKS per pass
    /// (P1's own shape of wrong: Sherlock is ~2,700 blocks).
    private var derivedNotes: [String: CGFloat] = [:]
    /// What a chapter heading reported — one measurement teaches all of them
    /// (they differ in nothing that changes their height).
    private var headingHeight: CGFloat?

    /// Stand at this width and this voice, re-measuring the type and dropping
    /// what was learned elsewhere. Idempotent. Returns whether anything moved.
    @discardableResult
    func stand(at width: CGFloat) -> Bool {
        let stamp = Self.stamp(width: width)
        guard stamp != self.stamp else { return false }
        self.stamp = stamp
        self.width = width
        self.metrics = Self.metrics(columnWidth: width)
        measured = [:]
        derivedNotes = [:]
        headingHeight = nil
        return true
    }

    /// A row reported its height while rendering REAL content. A placeholder's
    /// or a reservation's height is never learned — it would teach the column
    /// what the column already guessed.
    func learn(_ anchorID: String, height: CGFloat, isHeading: Bool) {
        guard height.isFinite, height > 0 else { return }
        if let known = measured[anchorID], abs(known - height) <= 0.5 { return }
        measured[anchorID] = height
        if isHeading { headingHeight = height }
    }

    /// The LENGTHS landed (or landed again for a new entry set): every
    /// derivation taken before them was taken over a different answer. What a
    /// row MEASURED is untouched — a measurement is what the column drew, and
    /// no arithmetic outranks it.
    func forgetDerived() {
        derivedNotes = [:]
    }

    /// The derived height of one NOTE row, memoized. `extents` nil means the
    /// lengths read has not come back yet.
    func derived(_ postID: String, extents: [Queries.BlockExtent]?) -> CGFloat {
        guard let extents else { return metrics.unknownNote }
        let key = "bip-\(postID)"
        if let cached = derivedNotes[key] { return cached }
        let height = BookIndexPaneHeightModel.noteHeight(extents: extents, metrics: metrics)
        derivedNotes[key] = height
        return height
    }

    /// The precedence for one row, as a manifest `Input` — ONE brain, asked
    /// per row (what a far row stands at) and per column (the offsets a
    /// landing reads), so the two can never disagree.
    func input(_ anchorID: String, derived: CGFloat, isHeading: Bool) -> BookHeightManifest.Input {
        BookHeightManifest.Input(
            id: anchorID,
            measured: measured[anchorID],
            // A sibling heading's measurement is a measurement of THIS column
            // at THIS width in THIS session, so it sits in the remembered
            // tier — above arithmetic, below this row's own report.
            remembered: isHeading ? headingHeight : nil,
            derived: derived)
    }

    /// The same answer as one number.
    func height(_ anchorID: String, derived: CGFloat, isHeading: Bool) -> CGFloat {
        BookHeightManifest.resolve(input(anchorID, derived: derived, isHeading: isHeading)).0
    }

    /// How many rows the column has actually measured — the DEBUG story's
    /// "how cold is this book" number.
    var learnedRowCount: Int { measured.count }

    // MARK: - The type, measured off the real font

    private static func stamp(width: CGFloat) -> String {
        "\(Int(width.rounded()))|\(EditorTypography.fingerprint ?? "-")"
    }

    /// The pane's own spacing constants, named where `BookIndexView` sets
    /// them so a reader can check each one against the surface:
    /// the block column's `VStack(spacing: 8)` and each paragraph's
    /// `.lineSpacing(4)`; the note's `.padding(.horizontal, 10)`; the block
    /// row's `readTierLeading` / `resting` / `readTierTop` / `readTierBottom`.
    /// 18l-c U5: the paragraphs' line spacing is READ from the tiers' one
    /// vocabulary (`IndexProseColumn.lines`) rather than restated — the live
    /// pane lays out with the same number now, and two copies of one number
    /// is the drift seam that vocabulary closes. (`blockGap` is the note's
    /// own block column, a host spacing, not a line metric.)
    static let blockGap: CGFloat = 8
    static let paragraphLineSpacing: CGFloat = IndexProseColumn.lines.lineSpacing
    static let noteHorizontalPadding: CGFloat = 10

    /// The metrics at a pane content width.
    ///
    /// **The font is `EditorTypography.current`'s and that is not a
    /// convenience:** this pane's read tier draws at `tokens.body`, which
    /// `VoiceTokens` sets to `.system(size: 14, design: .monospaced)` in
    /// Terminal and `.custom("Iowan Old Style", size: 16)` in Study — the
    /// SAME two faces `EditorTypography.resolve` produces. Reading them from
    /// the one resolved place keeps a single answer to "what is this voice's
    /// body font" rather than a second copy that could drift.
    static func metrics(columnWidth: CGFloat) -> BookIndexPaneHeightModel.Metrics {
        var metrics = BookIndexPaneHeightModel.Metrics()
        let font = EditorTypography.current.font
        let sample = "the quick brown fox jumps over a lazy dog and keeps going "
        let advance = (sample as NSString)
            .size(withAttributes: [.font: font]).width / CGFloat(sample.count)
        let lineHeight = font.ascender - font.descender + font.leading
        // The prose's own measure: the column, less the note's padding and
        // the block row's leading/trailing.
        let blockLeading = IndexProseColumn.readTierLeading(
            resting: IndexProseColumn.bookIndexResting,
            paneInset: PaneTextView.proseLeadingInset)
        let prose = max(
            80,
            columnWidth - 2 * noteHorizontalPadding
                - blockLeading - IndexProseColumn.bookIndexResting)
        metrics.prose = ProseHeightModel.Metrics(
            charsPerLine: max(8, Double(prose / max(advance, 1))),
            linePitch: lineHeight + paragraphLineSpacing,
            lineSpacing: paragraphLineSpacing,
            paragraphGap: blockGap,
            // 18l-c U5's rider: the tier shows its stored blank lines now.
            blankLines: IndexProseColumn.blankLines)
        // A block row's OWN vertical padding, and only that: the 8-pt gap
        // BETWEEN blocks is `ProseHeightModel`'s `paragraphGap`, which it
        // already adds once per seam. (Counting it here too was this unit's
        // own first arithmetic error — ~8 pt × every block in the book, which
        // on Sherlock's 2,700 blocks is 21,000 points of phantom column.)
        let blockTop = IndexProseColumn.readTierTop(
            resting: IndexProseColumn.bookIndexRestingTop,
            paneInset: PaneTextView.proseTopInset)
        metrics.blockChrome = blockTop + IndexProseColumn.readTierBottom(
            resting: IndexProseColumn.bookIndexRestingTop,
            paneInset: PaneTextView.proseBottomInset)
        metrics.emptyBlockLine = lineHeight + paragraphLineSpacing
        metrics.emptyNote = lineHeight + paragraphLineSpacing
        return metrics
    }

    /// The gap the pane's column puts between ROWS (`LazyVStack(spacing: 6)`
    /// before this unit; the plain column keeps the same number), so the
    /// manifest's offsets are the column's own arithmetic and not a second
    /// one.
    static let rowSpacing: CGFloat = 6
}

#if DEBUG
/// 13u4 UNIT F3's P1 pin support: how many times the INDEX ran the lengths
/// query. Opening a book in Index runs it ONCE; a re-entry over the book's
/// cache adds nothing, and nothing at autosave rate ever reaches it.
///
/// **Keyed by the BOOK** (the 18d batch-3 rule): Swift Testing runs suites in
/// parallel, so a counter that says "the Index" rather than "MY Index" is a
/// pin that can go red because someone else opened a book.
@MainActor
enum BookIndexExtentReads {
    static var byBook: [String: Int] = [:]
    static func count(_ readingID: String) -> Int { byBook[readingID] ?? 0 }
}
#endif
