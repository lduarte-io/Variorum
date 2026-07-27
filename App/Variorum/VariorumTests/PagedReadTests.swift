//
//  PagedReadTests.swift
//  VariorumTests
//
//  13c Batch 2C — READ's true pagination (committed scope C1, the
//  uniform-page brief). Three tiers of pin, in the brief §9's own order:
//
//  - PURE, on the estimator and the domain: the extent→pages arithmetic,
//    blocks longer than a page, the calibration rule, and THE headline
//    property — an estimate giving way to a measurement moves the page
//    LABEL and never the page's content.
//  - PURE, on the exact tier: the pages cover the post exactly once, in
//    order, with no gap and no overlap; the composed body IS the ratified
//    projection; a callout is indented without a character changing.
//  - HOSTED, on realization: a 60-post book draws TWO leaves and paginates
//    at most two posts, and Read carries NO editor of any kind (her A43
//    ruling made structural).
//

import AppKit
import CoreText
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withPagedWorld<T>(
    posts: Int, blocksPerPost: Int = 3, blockText: ((Int, Int) -> String)? = nil,
    _ body: @MainActor (
        AppSession, AppDatabase, _ readingID: String, _ postIDs: [String]
    ) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "paged book", kind: .curated)
        var postIDs: [String] = []
        for p in 0..<posts {
            let post = try session.operations.createPost(title: "post \(p)")
            for b in 0..<blocksPerPost {
                let text = blockText?(p, b)
                    ?? ("Sentence one of block \(b) in post \(p). It carries on for a "
                        + "while so the buffer resembles real prose on a real page.")
                _ = try session.operations.newBlock(in: post.id, text: text)
            }
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        return try await body(session, db, reading.id, postIDs)
    }
}

@MainActor
private func count<V: NSView>(_ type: V.Type, in view: NSView) -> Int {
    var n = view is V ? 1 : 0
    for sub in view.subviews { n += count(type, in: sub) }
    return n
}

// MARK: - The estimated tier

@MainActor
@Suite("Read pagination — the estimated domain (13c 2C)")
struct PageDomainTests {
    private let metrics = PageMetrics(charsPerLine: 50, linesPerPage: 20)

    private func extent(_ characters: Int, newlines: Int = 0) -> Queries.BlockExtent {
        Queries.BlockExtent(
            containerID: "p", blockID: UUID().uuidString,
            characters: characters, newlines: newlines)
    }

    /// The model's whole reason to exist: characters alone do not say how
    /// many lines prose occupies, because **a block is its own paragraph**
    /// (R26/R33) and **its internal newlines are content** (I4). One block of
    /// 1,000 characters is far shorter on the page than twenty blocks of 50.
    @Test func theEstimatorCountsParagraphsNotOnlyCharacters() {
        // The claim at line level, where the model actually lives.
        #expect(PageEstimator.lines(characters: 1000, newlines: 0, metrics: metrics) == 20.5)
        #expect(PageEstimator.lines(characters: 50, newlines: 0, metrics: metrics) == 1.5,
                "a one-line paragraph still ends ragged")
        #expect(PageEstimator.lines(characters: 1000, newlines: 19, metrics: metrics) == 30,
                "twenty paragraphs inside one block cost twenty ragged tails")

        // …and at page level, where she sees it: the same 5,000 characters
        // are five pages as one block and eight as a hundred short ones.
        let oneLongBlock = [extent(5000)]
        let hundredShortBlocks = (0..<100).map { _ in extent(50) }
        let long = PageEstimator.pages(
            extents: oneLongBlock, headingLines: 0, metrics: metrics, calibration: 1)
        let short = PageEstimator.pages(
            extents: hundredShortBlocks, headingLines: 0, metrics: metrics, calibration: 1)
        #expect(long == 6)
        #expect(short > long,
                "same characters, a hundred ragged paragraph ends: \(short) vs \(long)")

        // Internal newlines split ONE block into paragraphs, and the estimate
        // must feel it (a multi-paragraph block is I4's core case).
        let paragraphed = PageEstimator.pages(
            extents: [extent(5000, newlines: 99)], headingLines: 0,
            metrics: metrics, calibration: 1)
        #expect(paragraphed > long)

        // An empty post is a blank leaf, never zero pages — a post with no
        // pages could not be addressed at all.
        #expect(PageEstimator.pages(
            extents: [], headingLines: 0, metrics: metrics, calibration: 1) == 1)
        #expect(PageEstimator.pages(
            extents: [extent(0)], headingLines: 0, metrics: metrics, calibration: 1) == 1)
    }

    /// The brief §7's floor case: a block longer than a page contributes
    /// ⌈extent⌉ pages, not one.
    @Test func aBlockLongerThanAPageContributesSeveralPages() {
        // 20 lines/page × 50 chars/line = 1,000 chars/page, plus the ragged
        // tail — 10,000 characters is ten-ish pages, never one.
        let pages = PageEstimator.pages(
            extents: [extent(10_000)], headingLines: 0, metrics: metrics, calibration: 1)
        #expect(pages >= 10, "one huge block still paginates: \(pages)")
    }

    /// **THE headline property.** A measurement replacing an estimate moves
    /// the page LABEL under the reader and never the page's content, because
    /// a page is addressed by (post, page-in-post) and the address does not
    /// move. This is the two-tier design's entire safety argument, stated as
    /// a test so a future change has to break it deliberately.
    @Test func aCorrectionMovesTheLabelAndNeverThePage() {
        var index = PageIndex(metrics: metrics)
        index.adopt(
            postIDs: ["a", "b", "c"],
            extents: (0..<3).flatMap { i in
                [Queries.BlockExtent(
                    containerID: ["a", "b", "c"][i], blockID: "b\(i)",
                    characters: 4000, newlines: 0)]
            },
            headingLines: ["a": 0, "b": 0, "c": 0])
        let estimated = index.entries.map(\.pages)
        #expect(estimated.allSatisfy { $0 > 1 }, "each post estimates several pages")

        // The reader is on post "c", page 2 — an ADDRESS.
        let address = PageIndex.Position(postIndex: 2, pageInPost: 1)
        let labelBefore = index.pageNumber(of: address)

        // Post "a" turns out to be much shorter than estimated. That teaches
        // the estimator, so every UNVISITED post re-estimates — including c.
        index.adoptMeasured(postID: "a", pages: 2)

        #expect(index.pageNumber(of: address) != labelBefore,
                "the LABEL moved: the pages before her were re-counted")
        #expect(index.clamped(address) == address,
                "…and her ADDRESS did not move, so the page under her is the same page")

        // The invariant that makes that safe in the running app: **the post
        // the reader is IN is always the one that has been sliced**, so it is
        // measured (or floored past her page) and can never be re-estimated
        // out from under her. Once c is measured, nothing moves it.
        index.adoptMeasured(postID: "c", pages: 4)
        let measuredC = index.entries[2].pages
        index.adoptMeasured(postID: "b", pages: 9)
        #expect(index.entries[2].pages == measuredC, "a measured post is final")

        // And the floor does the same job while a post is only PARTLY sliced:
        // an estimate can never claim fewer pages than the reader has seen.
        var partial = PageIndex(metrics: metrics)
        partial.adopt(postIDs: ["x"], extents: [], headingLines: [:])
        partial.noteAtLeast(postID: "x", pages: 3)
        #expect(partial.entries[0].pages == 3)
        #expect(!partial.entries[0].isMeasured, "a floor is not a measurement")
        partial.adopt(postIDs: ["x"], extents: [], headingLines: [:])
        #expect(partial.entries[0].pages == 3, "a rebuild keeps the floor")
    }

    /// The calibration rule, including the part that is easy to get wrong: a
    /// ONE-PAGE post teaches nothing (its count is the floor, not a
    /// measurement of how much text a page holds), and a measured post is
    /// never re-estimated afterwards.
    @Test func onlyRealPostsCalibrateAndAMeasurementIsFinal() {
        var index = PageIndex(metrics: metrics)
        index.adopt(
            postIDs: ["a", "b"],
            extents: [
                Queries.BlockExtent(containerID: "a", blockID: "1", characters: 4000, newlines: 0),
                Queries.BlockExtent(containerID: "b", blockID: "2", characters: 4000, newlines: 0),
            ],
            headingLines: [:])

        // A one-page post does not calibrate.
        index.adoptMeasured(postID: "a", pages: 1)
        #expect(index.calibrationSamples == 0)
        #expect(index.calibration == 1)
        #expect(index.entries[0].pages == 1, "the measurement stands")

        // A real post does — and it re-estimates its unmeasured neighbours.
        var second = PageIndex(metrics: metrics)
        second.adopt(
            postIDs: ["a", "b"],
            extents: [
                Queries.BlockExtent(containerID: "a", blockID: "1", characters: 4000, newlines: 0),
                Queries.BlockExtent(containerID: "b", blockID: "2", characters: 4000, newlines: 0),
            ],
            headingLines: [:])
        let raw = second.entries[1].pages
        second.adoptMeasured(postID: "a", pages: raw * 2)
        #expect(second.calibrationSamples == 1)
        #expect(second.calibration > 1)
        #expect(second.entries[1].pages > raw, "the neighbour re-estimates upward")
        #expect(second.entries[0].pages == raw * 2, "the measured post is untouched")

        // A pathological sample cannot wreck the domain.
        var wild = PageIndex(metrics: metrics)
        wild.adopt(
            postIDs: ["a"],
            extents: [Queries.BlockExtent(
                containerID: "a", blockID: "1", characters: 4000, newlines: 0)],
            headingLines: [:])
        wild.adoptMeasured(postID: "a", pages: 10_000)
        #expect(PageIndex.calibrationBounds.contains(wild.calibration))

        // A rebuild (membership changed) keeps measurements.
        second.adopt(
            postIDs: ["a", "b"],
            extents: [
                Queries.BlockExtent(containerID: "a", blockID: "1", characters: 4000, newlines: 0),
                Queries.BlockExtent(containerID: "b", blockID: "2", characters: 4000, newlines: 0),
            ],
            headingLines: [:])
        #expect(second.entries[0].isMeasured, "a rebuild never re-guesses a read post")
    }

    /// The domain's walk: turning the leaf crosses posts, the covers are
    /// honestly dead (P-2 — no live door that cannot act), and a scrub
    /// resolves a number to an address.
    @Test func theDomainWalksAcrossPostsAndDiesAtTheCovers() {
        var index = PageIndex(metrics: metrics)
        index.adopt(postIDs: ["a", "b", "c"], extents: [], headingLines: [:])
        // Three one-page posts (no extents = a blank leaf each).
        #expect(index.totalPages == 3)
        #expect(index.isApproximate)

        let first = PageIndex.Position(postIndex: 0, pageInPost: 0)
        #expect(index.pageNumber(of: first) == 1)
        #expect(index.next(first) == PageIndex.Position(postIndex: 1, pageInPost: 0),
                "the next page is the next POST's first page")
        #expect(index.advance(first, by: 2) == PageIndex.Position(postIndex: 2, pageInPost: 0))
        #expect(index.advance(first, by: -1) == nil, "the front cover turns nowhere")
        #expect(index.advance(
            PageIndex.Position(postIndex: 2, pageInPost: 0), by: 2) == nil,
            "the back cover turns nowhere")
        #expect(index.position(atPageNumber: 2) == PageIndex.Position(postIndex: 1, pageInPost: 0))
        #expect(index.position(atPageNumber: 99) == PageIndex.Position(postIndex: 2, pageInPost: 0),
                "a scrub past the end lands on the last page, never nowhere")

        // A measured post SHORTER than its address clamps the reader onto its
        // last page rather than into nothing.
        var deep = PageIndex(metrics: metrics)
        deep.adopt(
            postIDs: ["a"],
            extents: [Queries.BlockExtent(
                containerID: "a", blockID: "1", characters: 40_000, newlines: 0)],
            headingLines: [:])
        let far = PageIndex.Position(postIndex: 0, pageInPost: 30)
        #expect(deep.clamped(far) == far)
        deep.adoptMeasured(postID: "a", pages: 4)
        #expect(deep.clamped(far) == PageIndex.Position(postIndex: 0, pageInPost: 3))

        // Once every post is measured the total stops wearing a tilde.
        var exact = PageIndex(metrics: metrics)
        exact.adopt(postIDs: ["a"], extents: [], headingLines: [:])
        exact.adoptMeasured(postID: "a", pages: 1)
        #expect(!exact.isApproximate)
    }
}

// MARK: - The exact tier

@MainActor
@Suite("Read pagination — the measured tier (13c 2C)")
struct PagePaginatorTests {
    private let typography = PageTypography.standard
    private let geometry = PageGeometry.standard

    private func composed(_ text: String, title: String? = nil) -> ComposedPost {
        PageComposer.compose(
            slots: [Queries.RenderedBlock(
                blockID: "b", placementID: "p", position: "a", variantID: "v", text: text,
                activeVariantCount: 1, liveVariantCount: 1, commentCount: 0,
                variantLocked: false)],
            presentations: [:], title: title, chapter: nil,
            typography: typography, ink: .black, chapterInk: .gray)
    }

    /// The correctness pin for the exact tier: **the pages cover the post
    /// exactly once, in order, with no gap and no overlap.** A page that
    /// starts where the previous one ended is what "the text flows across
    /// identical fixed pages" means, mechanically.
    @Test func thePagesCoverThePostExactlyOnceInOrder() {
        let paragraph = "This is a sentence of ordinary prose that runs on for a "
            + "reasonable while, as prose does when it is being read rather than "
            + "skimmed, and then it stops. "
        let post = composed(String(repeating: paragraph, count: 40))
        let paginator = PagePaginator(composed: post, contentRect: geometry.contentRect)
        let pages = paginator.pageCount()
        #expect(pages > 3, "a long post flows across several pages: \(pages)")

        var cursor = 0
        for i in 0..<pages {
            let range = try! #require(paginator.range(forPage: i))
            #expect(range.location == cursor,
                    "page \(i) starts exactly where page \(i - 1) ended")
            #expect(range.length > 0, "no empty page in the middle of prose")
            cursor = range.location + range.length
        }
        #expect(cursor == post.attributed.length,
                "the last page ends at the end of the post — nothing dropped")

        // Past the end is nil, not a blank page forever.
        #expect(paginator.frame(forPage: pages) == nil)
        // The count is stable when asked twice (it is cached, not re-sliced).
        #expect(paginator.pageCount() == pages)
    }

    /// A short post is ONE page, and an empty post is one blank page rather
    /// than zero (the address rule needs every post to have a first page).
    @Test func aShortPostIsOnePageAndAnEmptyPostIsABlankOne() {
        #expect(PagePaginator(
            composed: composed("A short thought."),
            contentRect: geometry.contentRect).pageCount() == 1)
        #expect(PagePaginator(
            composed: composed(""), contentRect: geometry.contentRect).pageCount() == 1)
    }

    /// The page renders the RATIFIED projection and nothing else: blank
    /// takes skip, gaps skip, and stored spacing survives byte for byte
    /// (the 2026-07-12 ruling) — which the reading flow's paragraph-splitting
    /// deliberately does not do. Pinned against `renderedText` itself, so the
    /// page and the export can never disagree about what the post says.
    @Test func theComposedBodyIsTheRatifiedProjection() async throws {
        try await withPagedWorld(posts: 1, blocksPerPost: 0) { session, db, _, _ in
            let post = try session.operations.createPost(title: "Spaced")
            try session.operations.newBlock(in: post.id, text: "A\n\n")
            try session.operations.newBlock(in: post.id, text: "B")
            try session.operations.newBlock(in: post.id, text: "")  // a blank take skips
            try session.operations.newBlock(in: post.id, text: "C")

            let slots = try await db.read { [id = post.id] in
                try Queries.renderPost($0, containerID: id)
            }
            let rendered = try await db.read { [id = post.id] in
                try Queries.renderedText($0, containerID: id)
            }
            let composed = PageComposer.compose(
                slots: slots, presentations: [:], title: nil, chapter: nil,
                typography: PageTypography.standard, ink: .black, chapterInk: .gray)
            #expect(composed.body == rendered)
            #expect(composed.body == "A\n\n\nB\n\nC")
            #expect(composed.chromeLength == 0, "no title, no chrome")

            // With chrome, the body still follows it verbatim.
            let titled = PageComposer.compose(
                slots: slots, presentations: [:], title: "Spaced", chapter: "One",
                typography: PageTypography.standard, ink: .black, chapterInk: .gray)
            #expect(titled.body == rendered)
            #expect(titled.attributed.string.hasSuffix(rendered))
            #expect(titled.chromeLength > 0)
        }
    }

    /// A CALLOUT reads as an indented passage on the page — a presentation
    /// transform over the same characters. **No character is added or
    /// changed** (export's blockquote mapping adds "> " and is a different
    /// transform for a different medium; neither touches `renderedText`).
    @Test func aCalloutIsIndentedWithoutAnyCharacterChanging() {
        func slot(_ id: String, _ text: String) -> Queries.RenderedBlock {
            Queries.RenderedBlock(
                blockID: id, placementID: "p\(id)", position: id, variantID: "v\(id)",
                text: text, activeVariantCount: 1, liveVariantCount: 1, commentCount: 0,
                variantLocked: false)
        }
        let slots = [slot("a", "Plain block."), slot("b", "Framed block."), slot("c", "After.")]
        let framed = PageComposer.compose(
            slots: slots,
            presentations: ["b": BlockPresentation(kind: BlockPresentation.calloutKind)],
            title: nil, chapter: nil, typography: PageTypography.standard,
            ink: .black, chapterInk: .gray)
        let plain = PageComposer.compose(
            slots: slots, presentations: [:], title: nil, chapter: nil,
            typography: PageTypography.standard, ink: .black, chapterInk: .gray)
        #expect(framed.body == plain.body, "the callout changed no character")

        let range = (framed.attributed.string as NSString).range(of: "Framed block.")
        let style = framed.attributed.attribute(
            .paragraphStyle, at: range.location, effectiveRange: nil) as? NSParagraphStyle
        #expect(style?.headIndent ?? 0 > 0, "the framed block is indented")
        let plainRange = (framed.attributed.string as NSString).range(of: "Plain block.")
        let plainStyle = framed.attributed.attribute(
            .paragraphStyle, at: plainRange.location, effectiveRange: nil) as? NSParagraphStyle
        #expect(plainStyle?.headIndent ?? 0 == 0, "…and its neighbours are not")
    }

    /// The cost shape, MEASURED rather than argued (the 1C precedent: a
    /// re-runnable measurement is worth more than a number in a document) —
    /// and it is the measurement that decided the architecture.
    ///
    /// CoreText typesets per PARAGRAPH. Ordinary Variorum prose is many
    /// paragraphs (every block is one), so paginating a whole post is
    /// milliseconds. **The same text as ONE unbroken block is a different
    /// animal** — a long message pasted in one piece, the A3/A41 shape —
    /// because every frame inside a giant paragraph re-typesets it from the
    /// start. That is why `PagedReadModel` slices lazily instead of
    /// paginating a post on arrival.
    @Test func paginationCostIsParagraphShapedAndPrintsItsNumbers() {
        let paragraph = "Prose that runs on for a reasonable while before it stops. "
        var brokenPerPage: [Double] = []
        var unbrokenPerPage: [Double] = []
        for count in [40, 160, 640] {
            for broken in [true, false] {
                let text = broken
                    ? (0..<count).map { _ in paragraph }.joined(separator: "\n\n")
                    : String(repeating: paragraph, count: count)
                let post = composed(text)
                let clock = ContinuousClock()
                let paginator = PagePaginator(composed: post, contentRect: geometry.contentRect)
                var pages = 0
                let elapsed = clock.measure { pages = paginator.pageCount() }
                let ms = Double(elapsed.components.attoseconds) / 1e15
                let perPage = ms / Double(max(pages, 1))
                if broken { brokenPerPage.append(perPage) } else { unbrokenPerPage.append(perPage) }
                print("2C pagination [\(broken ? "paragraphs" : "ONE block")]: "
                    + "\(post.attributed.length) chars → \(pages) pages in "
                    + "\(String(format: "%.1f", ms)) ms "
                    + "(\(String(format: "%.2f", perPage)) ms/page)")
                #expect(pages > 0)
            }
        }
        // The structural claim, not a timing threshold: per-page cost stays
        // FLAT as ordinary prose grows, and CLIMBS as one block grows.
        #expect(brokenPerPage[2] < brokenPerPage[0] * 4,
                "paragraphed prose paginates at a flat rate: \(brokenPerPage)")
        #expect(unbrokenPerPage[2] > unbrokenPerPage[0] * 4,
                "one giant paragraph does not — which is why slicing is lazy: \(unbrokenPerPage)")
    }
}

// MARK: - Realization (hosted)

@MainActor
@Suite("Read pagination — the surface (13c 2C)", .serialized)
struct PagedReadViewTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func withHostedPages<T>(
        posts: Int, blocksPerPost: Int = 3, width: CGFloat = 1500, height: CGFloat = 900,
        _ body: @MainActor (
            AppSession, _ postIDs: [String], _ window: NSWindow,
            _ hosting: NSHostingView<PagedReadView>, _ model: BookViewModel,
            _ structure: BookStructureModel
        ) async throws -> T
    ) async throws -> T {
        try await withPagedWorld(posts: posts, blocksPerPost: blocksPerPost) {
            session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let structure = BookStructureModel(session: session, readingID: readingID)
            structure.readForm = .pages
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: width, height: height),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: PagedReadView(session: session, model: model, structure: structure))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            return try await body(session, postIDs, window, hosting, model, structure)
        }
    }

    /// P3 + Stage 4 lesson 6: the paginated spread realizes THE SPREAD.
    /// A 60-post book draws two leaves and paginates at most two POSTS — the
    /// rest of the book is a row of numbers in the domain, never composed and
    /// never laid out.
    ///
    /// Red-on-old by behavioral revert: realizing every entry (a `ForEach`
    /// over the book instead of the spread's two addresses) draws 60.
    @Test func thePaginatedReadRealizesTheSpreadNotTheBook() async throws {
        try await withHostedPages(posts: 60) { _, _, window, hosting, _, _ in
            PagedReadMaterialization.count = 0
            await settle(window, hosting, until: { count(PageFrameNSView.self, in: hosting) >= 2 })
            #expect(count(PageFrameNSView.self, in: hosting) == 2,
                    "two leaves — never the book's extent")
            let materialized = PagedReadMaterialization.count
            #expect(materialized < 8,
                    "a 60-post book materializes the spread's leaves, not 60: \(materialized)")
        }
    }

    /// Her A43 ruling, made structural: **Read is not an editing surface.**
    /// There is no live editor here, no read-tier text view, no NSTextView of
    /// any kind — a page is a drawn `CTFrame`. That is also what keeps this
    /// surface out of the TK2 geometry path 1C measured lying (a page can
    /// never be framed by an estimate, because nothing here estimates).
    @Test func readCarriesNoTextViewAtAll() async throws {
        try await withHostedPages(posts: 6) { _, postIDs, window, hosting, model, _ in
            await settle(window, hosting, until: { count(PageFrameNSView.self, in: hosting) >= 2 })
            #expect(count(EditorTextView.self, in: hosting) == 0, "no live editor in Read")
            #expect(count(ReadPostTextView.self, in: hosting) == 0, "no read-tier text view")
            #expect(count(NSTextView.self, in: hosting) == 0, "no NSTextView at all")

            // …and focusing a post (the navigator's jump) does not mint one:
            // in Read, focus is a page address, not a live ring.
            model.focus(postIDs[3])
            await settle(window, hosting, until: { count(EditorTextView.self, in: hosting) > 0 })
            #expect(count(EditorTextView.self, in: hosting) == 0)
        }
    }

    /// The bottom bar, as the brief §4 designs it: flip controls, the SCRUBBER
    /// over the estimated page domain, and a total that says "~" while it is
    /// still a guess (R112's honesty rule, applied to a number).
    ///
    /// Deliberately different from Book, where 2B removed the slider on its
    /// own brief's instruction and flagged it (QUESTIONS #44(c)/#45(c)).
    @Test func theBarKeepsItsScrubberAndSpeaksApproximately() async throws {
        try await withHostedPages(posts: 12) { session, _, window, hosting, model, _ in
            await settle(window, hosting, until: { count(PageFrameNSView.self, in: hosting) >= 2 })
            #expect(count(NSSlider.self, in: hosting) == 1,
                    "the paginated sub-mode keeps a scrubber over the page domain")

            // The bar's line, read off the model that computes it: the total
            // wears a "~" while any post is still a guess (R112's honesty
            // rule applied to a number), and loses it when none is.
            let pages = PagedReadModel(session: session)
            await pages.adopt(entries: model.entries, chapterOpeners: [:])
            #expect(pages.pageLine.contains("of ~"),
                    "still estimating: \(pages.pageLine)")
            #expect(pages.pageLine.contains("pages 1–2"))

            // Read the whole book, and the guess becomes a fact — no seam,
            // just the pages being turned.
            for _ in 0..<20 where pages.canTurn(by: 2) {
                pages.turn(by: 2)
                await settle(window, hosting, until: { !pages.index.isApproximate })
            }
            #expect(!pages.index.isApproximate)
            #expect(!pages.pageLine.contains("~"),
                    "every post measured — the total is exact: \(pages.pageLine)")
        }
    }

    /// **Slicing is LAZY.** Opening a book whose first post runs to dozens of
    /// pages must cut the pages she is looking at and stop — not paginate the
    /// post. Red-on-old by behavioral revert: `realize` calling
    /// `paginator.pageCount()` (the eager shape this batch started with)
    /// slices the whole post on arrival and this fails.
    ///
    /// The measurement behind the rule is in `PagePaginator`'s header: for a
    /// long message pasted as ONE block, whole-post pagination is 1.67 s at
    /// 25k words, because CoreText re-typesets a paragraph from its start.
    @Test func openingABookSlicesTheSpreadNotThePost() async throws {
        let long = String(
            repeating: "A paragraph of ordinary prose that carries on for a while. ", count: 300)
        try await withPagedWorld(posts: 3, blocksPerPost: 1, blockText: { _, _ in long }) {
            session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let pages = PagedReadModel(session: session)
            await pages.adopt(entries: model.entries, chapterOpeners: [:])

            let sliced = try #require(pages.slicedPages(of: postIDs[0]))
            #expect(sliced <= 3,
                    "the first post was sliced to the spread, not to its end: \(sliced)")
            #expect(pages.index.entries[0].pages > sliced,
                    "…and the domain still carries an ESTIMATE for the rest of it")
            #expect(pages.index.isApproximate, "so the total is honestly approximate")

            // Reading forward discovers pages one turn at a time.
            pages.turn(by: 2)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(50))
            let after = try #require(pages.slicedPages(of: postIDs[0]))
            #expect(after > sliced, "a turn cut the next pages: \(sliced) → \(after)")
            #expect(after <= sliced + 4, "…and only the next pages")
        }
    }

    /// 13c K6 review, K1 (MAJOR — red-on-old by behavioral revert: remove
    /// the postID re-anchor from `PagedReadModel.adopt` and BOTH halves
    /// fail, the page under the reader silently becoming another post's).
    ///
    /// The address rule's letter: a page is addressed by (post,
    /// page-in-post) — post IDENTITY, not a position in the membership
    /// list. `Position.postIndex` is an index, so before this fix a
    /// membership insertion (the Fragments bridge shelving today's entry —
    /// 1D's own work) or an A31 order flip (2D's own order menu, two
    /// clicks away) shifted every later index and left the address naming
    /// a DIFFERENT post. The existing address pin
    /// (`aCorrectionMovesTheLabelAndNeverThePage`) never varies the postID
    /// list, which is why this one exists.
    @Test func theAddressSurvivesMembershipAndOrderChangesByIdentity() async throws {
        try await withPagedWorld(posts: 3) { session, db, readingID, postIDs in
            let pages = PagedReadModel(session: session)
            let entries = try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            }
            await pages.adopt(entries: entries, chapterOpeners: [:])
            // The reader is IN post 1 (seed, not showPost — showPost
            // deliberately no-ops when the post is already a spread leaf,
            // and post 1 may be page one's right leaf on a short book).
            pages.seed(fromFocus: postIDs[1])
            #expect(pages.leaves.first??.postID == postIDs[1])

            // A membership INSERTION before her post (a sync round, the
            // bridge's daily shelving): every later index shifts.
            let landed = Queries.ReadingEntry(
                postID: "landed-mid-read", title: "today's entry",
                entryDate: nil, sectionPath: nil)
            await pages.adopt(entries: [landed] + entries, chapterOpeners: [:])
            #expect(pages.leaves.first??.postID == postIDs[1],
                    "an insertion re-anchors the address — the page under her is the same post")

            // An ORDER flip (the A31 menu): the list reorders wholesale.
            await pages.adopt(
                entries: ([landed] + entries).reversed(), chapterOpeners: [:])
            #expect(pages.leaves.first??.postID == postIDs[1],
                    "a reorder re-anchors too — the address is identity, not a number")

            // Her post REMOVED: the clamp is all that is left — she lands
            // on a page that exists, never nowhere.
            await pages.adopt(
                entries: entries.filter { $0.postID != postIDs[1] },
                chapterOpeners: [:])
            let shown = pages.leaves.first??.postID
            #expect(shown != nil && shown != postIDs[1],
                    "a removed post cannot be shown; the clamp lands a real page")
        }
    }

    /// Turning the leaf walks the DOMAIN (two pages), the covers are dead,
    /// and the reader's address survives a re-adoption of the same book.
    @Test func theLeafTurnsTwoPagesAndTheCoversAreDead() async throws {
        try await withHostedPages(posts: 8) { session, postIDs, window, hosting, model, structure in
            let pages = PagedReadModel(session: session)
            await pages.adopt(entries: model.entries, chapterOpeners: [:])
            #expect(!pages.canTurn(by: -2), "the front cover turns nowhere")
            #expect(pages.canTurn(by: 2))
            let before = pages.position
            pages.turn(by: 2)
            await settle(window, hosting, until: { pages.position != before })
            #expect(pages.position != before)
            #expect(pages.index.pageNumber(of: pages.position) == 3,
                    "a leaf is two pages")

            // The navigator's jump lands a post's FIRST page without leaving
            // the reading surface.
            pages.showPost(postIDs[6])
            await settle(window, hosting, until: { pages.position.postIndex == 6 })
            #expect(pages.position == PageIndex.Position(postIndex: 6, pageInPost: 0))
            // A post already on the spread is left where it is (2B's rule).
            let held = pages.position
            pages.showPost(postIDs[6])
            #expect(pages.position == held)

            // Only the spread's posts were ever realized (the P1 half, read
            // off the model rather than the view hierarchy).
            #expect(pages.realizedPostCount <= PagedReadModel.cacheLimit)
            #expect(PagedReadModel.neededPosts(
                at: pages.position, index: pages.index, entries: pages.entries).count <= 2)
        }
    }
}
