//
//  PageDomain.swift
//  Variorum
//
//  READ's TRUE PAGINATION — the page domain (13c Batch 2C; the uniform-page
//  brief §3's "two-tier pagination: ESTIMATED globally, MEASURED locally").
//  Everything in this file is PURE: geometry constants, the extent→pages
//  estimator, and the page index that turns a book into a numbered domain.
//  Nothing here draws, fetches, or asks a layout engine anything.
//
//  ── THE ARCHITECTURE, in one paragraph, because it is the batch's whole
//  claim ──────────────────────────────────────────────────────────────────
//  A page is addressed by **(post, page-within-post)**, never by a global
//  page number. The global number is a LABEL computed from this domain. That
//  is what makes the two tiers safe to mix: when an estimate is replaced by
//  a measurement, the label under the reader may change — the CONTENT of the
//  page she is looking at cannot, because the address that produced it did
//  not move. (The Phase 6 spike's accepted height story, exactly: "estimates
//  revise, content never regresses".)
//
//  ── WHY NOTHING HERE READS TK2 GEOMETRY (the batch brief's explicit
//  cross-check against 1C's finding) ──────────────────────────────────────
//  1C measured TK2's estimated geometry OVER-reporting by 367 pt on one
//  3,000-word block (4,964 pt guessed vs 4,597 pt laid out), and 1E built
//  the remedy for the editor. **This surface cannot inherit that defect,
//  because it never enters that path**: the estimated tier's inputs are
//  CHARACTER COUNTS out of SQLite (`Queries.blockExtents`), and the exact
//  tier is CoreText (`PagePaginator`), which lays out synchronously and
//  completely for the range it is handed — `CTFrameGetVisibleStringRange`
//  is a measured fact, not a guess. There is no `NSTextLayoutFragment` on a
//  paginated page, so there is no estimated→laidOut flip to be caught by.
//  What DOES flip here is this domain's own estimate → measurement, and the
//  address rule above is what bounds its blast radius to the page LABEL.
//

import AppKit
import Foundation
import VariorumCore

// MARK: - The page (a fixed logical rectangle)

/// The leaf: a FIXED logical page (brief §7's ruling — a window resize
/// SCALES the paper rather than repaginating it). Chars-per-page is a
/// function of this rectangle and the page font, so the domain is stable
/// under every window size.
struct PageGeometry: Equatable {
    var size: CGSize
    var margin: CGFloat

    /// A 3:4-ish leaf at a comfortable book measure. Deliberately not
    /// US Letter (that is the PDF exporter's print target, not a reading
    /// page) and deliberately not derived from the window.
    static let standard = PageGeometry(size: CGSize(width: 470, height: 660), margin: 46)

    var contentRect: CGRect {
        CGRect(
            x: margin, y: margin,
            width: size.width - 2 * margin, height: size.height - 2 * margin)
    }

    /// The scale that fits ONE page into `available` height while a spread of
    /// two pages fits its width — aspect preserved, never above 1 (a page
    /// blown up past its logical size reads as a zoom, not as paper).
    func spreadScale(in available: CGSize, spine: CGFloat) -> CGFloat {
        guard available.width > 0, available.height > 0 else { return 1 }
        let byWidth = (available.width - spine) / (2 * size.width)
        let byHeight = available.height / size.height
        return max(0.2, min(1, min(byWidth, byHeight)))
    }
}

/// The page's type — the reading-flow serif, at a page measure. One font for
/// body, one for the post title, one for a chapter opener.
struct PageTypography: Equatable {
    var body: NSFont
    var title: NSFont
    var chapter: NSFont
    var lineSpacing: CGFloat

    static let standard = PageTypography(
        body: NSFont(descriptor: NSFont.systemFont(ofSize: 13).fontDescriptor
            .withDesign(.serif) ?? NSFont.systemFont(ofSize: 13).fontDescriptor,
            size: 13) ?? NSFont.systemFont(ofSize: 13),
        title: NSFont(descriptor: NSFont.systemFont(ofSize: 17, weight: .semibold)
            .fontDescriptor.withDesign(.serif)
            ?? NSFont.systemFont(ofSize: 17).fontDescriptor, size: 17)
            ?? NSFont.boldSystemFont(ofSize: 17),
        chapter: NSFont(descriptor: NSFont.systemFont(ofSize: 12, weight: .medium)
            .fontDescriptor.withDesign(.serif)
            ?? NSFont.systemFont(ofSize: 12).fontDescriptor, size: 12)
            ?? NSFont.systemFont(ofSize: 12),
        lineSpacing: 4)

    /// The page's line height, and the characters an average line holds —
    /// MEASURED off the real font rather than guessed, then handed to the
    /// estimator as its calibration seed.
    func metrics(for geometry: PageGeometry) -> PageMetrics {
        let sample = "the quick brown fox jumps over a lazy dog and keeps going "
        let width = (sample as NSString)
            .size(withAttributes: [.font: body]).width / CGFloat(sample.count)
        let lineHeight = body.ascender - body.descender + body.leading + lineSpacing
        let content = geometry.contentRect
        return PageMetrics(
            charsPerLine: max(8, Double(content.width / max(width, 1))),
            linesPerPage: max(4, Double(floor(content.height / max(lineHeight, 1)))))
    }
}

/// What the estimator needs to know about a page.
struct PageMetrics: Equatable {
    var charsPerLine: Double
    var linesPerPage: Double
}

// MARK: - The estimator (pure arithmetic over stored lengths)

enum PageEstimator {
    /// The lines one block occupies, modelled rather than measured.
    ///
    /// Two facts drive the model and neither is optional: **a block is always
    /// its own paragraph** (the R26/R33 clarifier), and **newlines inside it
    /// are content** (I4) — so a block of k internal newlines is k+1
    /// paragraphs. Each paragraph ends mid-line, wasting half a line on
    /// average; that ragged tail is why character count alone under-counts a
    /// post of many short blocks by a wide margin.
    static func lines(characters: Int, newlines: Int, metrics: PageMetrics) -> Double {
        guard characters > 0 else { return 0 }
        let paragraphs = Double(newlines + 1)
        let full = Double(characters) / metrics.charsPerLine
        return max(paragraphs, full + paragraphs * 0.5)
    }

    /// A post's page count from its blocks' extents. `headingLines` is the
    /// room its opening chrome takes (title, and a chapter opener where the
    /// post begins one) — the composer and the estimator must agree about
    /// that or the estimate is biased for every short post in the book.
    ///
    /// **Always at least one page:** an empty post is a blank leaf, never
    /// zero pages (a post with no pages could not be addressed at all).
    static func pages(
        extents: [Queries.BlockExtent], headingLines: Double,
        metrics: PageMetrics, calibration: Double
    ) -> Int {
        let total = extents.reduce(headingLines) { sum, extent in
            sum + lines(
                characters: extent.characters, newlines: extent.newlines, metrics: metrics)
        }
        let scaled = total * calibration
        return max(1, Int(ceil(scaled / metrics.linesPerPage)))
    }
}

// MARK: - The page index (the book's numbered domain)

/// The book as a sequence of pages: one entry per post, each carrying an
/// ESTIMATED page count until the post has actually been paginated, after
/// which it carries the MEASURED one and never changes again.
struct PageIndex: Equatable {
    struct Entry: Equatable {
        let postID: String
        /// The estimate, recomputed whenever calibration moves.
        var estimated: Int
        /// The exact count, once slicing has reached the END of this post.
        /// Write-once: a measurement is never re-guessed.
        var measured: Int?
        /// Pages slicing has ALREADY discovered — a lower bound while the
        /// post is only partly paginated. It is what keeps a re-estimate
        /// from claiming a post is shorter than pages the reader has been
        /// shown (the "never regresses" contract, under lazy slicing).
        var floor = 1
        var pages: Int { max(floor, max(1, measured ?? estimated)) }
        var isMeasured: Bool { measured != nil }
    }

    /// A page's ADDRESS. The whole design rests on this being the identity
    /// of a page rather than its global number.
    struct Position: Equatable, Hashable {
        var postIndex: Int
        var pageInPost: Int
    }

    private(set) var entries: [Entry] = []
    private(set) var metrics: PageMetrics
    /// The running correction from measured posts to the raw estimate.
    /// Seeded at 1 (trust the font measurement) and bounded, so one
    /// pathological post cannot wreck the domain.
    private(set) var calibration: Double = 1
    private(set) var calibrationSamples = 0
    /// The raw (uncalibrated) estimate per post, kept so calibration can be
    /// re-derived rather than compounded.
    private var rawEstimate: [String: Int] = [:]
    private var extentsByPost: [String: [Queries.BlockExtent]] = [:]
    private var headingLinesByPost: [String: Double] = [:]

    static let calibrationBounds = 0.5...2.0

    init(metrics: PageMetrics) {
        self.metrics = metrics
    }

    /// Build (or rebuild) the domain from the book's post order and the
    /// extent index. Posts already MEASURED keep their measurement across a
    /// rebuild — a book whose membership changed must not re-estimate pages
    /// the reader has already been shown.
    mutating func adopt(
        postIDs: [String], extents: [Queries.BlockExtent],
        headingLines: [String: Double]
    ) {
        let measured = Dictionary(
            uniqueKeysWithValues: entries.compactMap { entry in
                entry.measured.map { (entry.postID, $0) }
            })
        let floors = Dictionary(
            uniqueKeysWithValues: entries.map { ($0.postID, $0.floor) })
        extentsByPost = Dictionary(grouping: extents, by: \.containerID)
        headingLinesByPost = headingLines
        entries = postIDs.map { postID in
            Entry(
                postID: postID,
                estimated: estimate(postID),
                measured: measured[postID],
                floor: floors[postID] ?? 1)
        }
    }

    private func estimate(_ postID: String) -> Int {
        PageEstimator.pages(
            extents: extentsByPost[postID] ?? [],
            headingLines: headingLinesByPost[postID] ?? 0,
            metrics: metrics, calibration: calibration)
    }

    private func rawPages(_ postID: String) -> Int {
        PageEstimator.pages(
            extents: extentsByPost[postID] ?? [],
            headingLines: headingLinesByPost[postID] ?? 0,
            metrics: metrics, calibration: 1)
    }

    /// A post has been paginated exactly: adopt its real count, and let it
    /// teach the estimator.
    ///
    /// **Only posts of two pages or more calibrate.** A short post's page
    /// count is dominated by the "at least one page" floor, so it reports a
    /// ratio that says nothing about how much text a page holds — a book of
    /// one-paragraph journal entries would otherwise drag the constant to
    /// nonsense.
    /// Slicing has discovered `pages` pages of this post but has NOT reached
    /// its end: raise the floor, leave the estimate free to move.
    mutating func noteAtLeast(postID: String, pages: Int) {
        guard let i = entries.firstIndex(where: { $0.postID == postID }) else { return }
        entries[i].floor = max(entries[i].floor, max(1, pages))
    }

    mutating func adoptMeasured(postID: String, pages: Int) {
        guard let i = entries.firstIndex(where: { $0.postID == postID }) else { return }
        let exact = max(1, pages)
        entries[i].measured = exact
        // The exact count REPLACES the floor: a post that turned out shorter
        // than slicing's lower bound cannot happen (the bound came from
        // slicing), but a post whose measurement is authoritative should not
        // be inflated by anything.
        entries[i].floor = exact
        if exact >= 2 {
            let raw = Double(rawPages(postID))
            if raw > 0 {
                let observed = Double(exact) / raw
                let n = Double(calibrationSamples)
                let updated = (calibration * n + observed) / (n + 1)
                calibration = min(
                    Self.calibrationBounds.upperBound,
                    max(Self.calibrationBounds.lowerBound, updated))
                calibrationSamples += 1
            }
        }
        // Re-estimate the posts nobody has visited. A MEASURED entry is
        // never touched: that is the "never regresses" half of the contract.
        for j in entries.indices where !entries[j].isMeasured {
            entries[j].estimated = estimate(entries[j].postID)
        }
    }

    // MARK: - The domain

    var totalPages: Int { entries.reduce(0) { $0 + $1.pages } }
    /// True while any post's count is still a guess — the label wears a "~"
    /// (R112's honesty rule applied to a number).
    var isApproximate: Bool { entries.contains { !$0.isMeasured } }
    var isEmpty: Bool { entries.isEmpty }

    /// The 1-based page number a position carries in the whole book. This is
    /// a LABEL — it moves when an earlier post's estimate is corrected, and
    /// nothing about the page's content moves with it.
    func pageNumber(of position: Position) -> Int? {
        guard entries.indices.contains(position.postIndex) else { return nil }
        let before = entries[..<position.postIndex].reduce(0) { $0 + $1.pages }
        return before + position.pageInPost + 1
    }

    /// The address a global page number resolves to (the scrubber's landing).
    func position(atPageNumber number: Int) -> Position? {
        guard !entries.isEmpty else { return nil }
        var remaining = max(1, min(number, totalPages)) - 1
        for (i, entry) in entries.enumerated() {
            if remaining < entry.pages { return Position(postIndex: i, pageInPost: remaining) }
            remaining -= entry.pages
        }
        return Position(postIndex: entries.count - 1, pageInPost: entries[entries.count - 1].pages - 1)
    }

    /// Clamp an address into the domain (a post whose measured count came in
    /// SHORTER than its estimate can leave the reader addressing a page that
    /// no longer exists — she lands on that post's last page, never nowhere).
    func clamped(_ position: Position) -> Position? {
        guard !entries.isEmpty else { return nil }
        let postIndex = min(max(position.postIndex, 0), entries.count - 1)
        let pageInPost = min(max(position.pageInPost, 0), entries[postIndex].pages - 1)
        return Position(postIndex: postIndex, pageInPost: pageInPost)
    }

    /// Walk `pages` forward (or back) through the book, crossing posts.
    /// Returns nil when the walk would leave the book — which is what makes
    /// a flip control at the cover honestly dead (P-2).
    func advance(_ position: Position, by pages: Int) -> Position? {
        guard let here = pageNumber(of: position) else { return nil }
        let target = here + pages
        guard target >= 1, target <= totalPages else { return nil }
        return self.position(atPageNumber: target)
    }

    /// The address AFTER this one, or nil at the end of the book — the right
    /// leaf of a spread, which may be the first page of the next post.
    func next(_ position: Position) -> Position? { advance(position, by: 1) }
}
