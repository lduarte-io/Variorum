//
//  ReadRenderingTests.swift
//  VariorumTests
//
//  Phase 13g, batch 4 (L11) — READ RENDERS MARKDOWN FULLY FORMATTED.
//
//  The transform itself is pinned in the core suite
//  (`MarkdownRenderingTests`); what is pinned here is everything that only
//  exists in the app, and it is all one claim in three places:
//
//  - the PAGED face composes the RENDERED text while `body` stays the
//    ratified projection (the drift guard on the join conditional is not
//    weakened by the transform — it is what keeps the two apart);
//  - a CALLOUT's indent still lands on its own block after an earlier block
//    got SHORTER, which is the arithmetic hazard the per-block render exists
//    to remove;
//  - the SCROLL face renders the same way and lets SwiftUI open the links,
//    behind the same scheme guard every other surface asks.
//
//  And the addressing rule from 13c K1 is untouched throughout: pagination
//  measures the TRANSFORMED text, and a page is still addressed by
//  (post, page-in-post), never by an index into anything.
//

import AppKit
import CoreText
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Read renders markdown (13g batch 4 — L11)")
struct ReadRenderingTests {
    private let typography = PageTypography.standard
    private let geometry = PageGeometry.standard

    private func slot(_ id: String, _ text: String) -> Queries.RenderedBlock {
        Queries.RenderedBlock(
            blockID: id, placementID: "p\(id)", position: id, variantID: "v\(id)",
            text: text, activeVariantCount: 1, liveVariantCount: 1, commentCount: 0,
            variantLocked: false)
    }

    private func compose(
        _ slots: [Queries.RenderedBlock],
        presentations: [String: BlockPresentation] = [:],
        title: String? = nil
    ) -> ComposedPost {
        PageComposer.compose(
            slots: slots, presentations: presentations, title: title, chapter: nil,
            typography: typography, ink: .black, chapterInk: .gray)
    }

    // MARK: - The page draws the rendered face; the body stays the projection

    /// **The two strings, and why there are two.** `body` is the STORED text
    /// — the ratified projection, byte-equal to `Queries.renderedText`, which
    /// is what makes it a drift guard on the join conditional. `attributed`
    /// is what the page DRAWS, and since her F-5 surface rule Read may hide
    /// the markers because it has no gesture that maps a click to an offset.
    ///
    /// DISCRIMINATING REVERT: in `PageComposer.compose`, append the raw
    /// `text` to `display` instead of `MarkdownRendering.render(text).text`
    /// and this fails on its first expectation — the page shows `**bold**`
    /// again.
    @Test func thePageDrawsTheRenderedTextWhileTheBodyStaysTheStoredProjection() {
        let source = "# A heading\n\nwith **bold** and a [link](https://x.test) in it"
        let post = compose([slot("a", source)])
        #expect(post.attributed.string
                == "A heading\n\nwith bold and a link in it")
        #expect(post.body == source, "the STORED text is untouched — markers and all")
        #expect(post.chromeLength == 0)
    }

    /// Prose with no markdown is byte-identical on both sides, which is the
    /// honest default: nothing about this batch changes what an unformatted
    /// note looks like on a page.
    @Test func prosePageIsUnchangedWhenThereIsNoMarkdown() {
        let source = "A plain paragraph.\n\nAnd a second one, after a stored blank line."
        let post = compose([slot("a", source)])
        #expect(post.attributed.string == source)
        #expect(post.body == source)
    }

    /// The rendered face is really ON the page: a heading is bigger, bold is
    /// bold, a link is coloured. (The FONTS are the app's choice; what is
    /// pinned is that the transform's runs reached the string.)
    @Test func theRenderedFaceReachesTheAttributedString() throws {
        let post = compose([slot("a", "## Big\n\nsay **this** and `that`")])
        let string = post.attributed.string as NSString

        let heading = string.range(of: "Big")
        let headingFont = try #require(
            post.attributed.attribute(.font, at: heading.location, effectiveRange: nil) as? NSFont)
        #expect(headingFont.pointSize > typography.body.pointSize, "a heading is a SIZE (F-3)")

        let bold = string.range(of: "this")
        let boldFont = try #require(
            post.attributed.attribute(.font, at: bold.location, effectiveRange: nil) as? NSFont)
        #expect(boldFont.fontDescriptor.symbolicTraits.contains(.bold))

        let code = string.range(of: "that")
        let codeFont = try #require(
            post.attributed.attribute(.font, at: code.location, effectiveRange: nil) as? NSFont)
        #expect(codeFont.isFixedPitch)
    }

    // MARK: - The hazard the per-block render removes

    /// **A callout's indent still lands on its own block after an earlier
    /// block got SHORTER.** This is the one real arithmetic hazard the
    /// transform introduces: block ranges used to be computed on the stored
    /// text, and the drawn string is now a different length. Rendering PER
    /// BLOCK is what makes the display range known without a mapping table.
    ///
    /// DISCRIMINATING REVERT: compute `ranges` from the stored `composed`
    /// offsets (`let start = (composed as NSString).length` before appending
    /// `text`, as it was before this batch) and the indent slides onto the
    /// wrong words — with a long enough first block it walks off the end of
    /// the string entirely, which is an `NSRangeException`, not a wrong look.
    @Test func aCalloutStaysOnItsOwnBlockAfterAnEarlierBlockShortens() throws {
        let slots = [
            slot("a", "**Lots** of **markers** in **this** *first* ~~block~~ `here`."),
            slot("b", "The framed block."),
            slot("c", "After it."),
        ]
        let post = compose(
            slots, presentations: ["b": BlockPresentation(kind: BlockPresentation.calloutKind)])
        let string = post.attributed.string as NSString
        #expect(string.length < (post.body as NSString).length, "the display really is shorter")

        let framed = string.range(of: "The framed block.")
        let style = post.attributed.attribute(
            .paragraphStyle, at: framed.location, effectiveRange: nil) as? NSParagraphStyle
        #expect(style?.headIndent ?? 0 > 0, "the framed block is indented")

        for neighbour in ["Lots", "After it."] {
            let range = string.range(of: neighbour)
            let plain = post.attributed.attribute(
                .paragraphStyle, at: range.location, effectiveRange: nil) as? NSParagraphStyle
            #expect(plain?.headIndent ?? 0 == 0, "\(neighbour) is not indented")
        }
    }

    // MARK: - The link map

    /// The map a plain click hit-tests against: display offsets, past the
    /// chrome, naming exactly the words the reader sees.
    @Test func theLinkMapNamesTheWordsItCoversEvenBehindATitle() {
        let slots = [
            slot("a", "**bold** first, then [the docs](https://x.test/a)."),
            slot("b", "and [more](https://y.test) after."),
        ]
        for title in [nil, "A Titled Note"] as [String?] {
            let post = compose(slots, title: title)
            let string = post.attributed.string as NSString
            #expect(post.links.map(\.url) == ["https://x.test/a", "https://y.test"])
            #expect(post.links.map { string.substring(with: $0.range) } == ["the docs", "more"])
            if title != nil {
                #expect(post.chromeLength > 0)
                #expect(post.links[0].range.location > post.chromeLength)
            }
        }
    }

    // MARK: - Pagination measures the TRANSFORMED text

    /// The pages tile the DRAWN string exactly once, in order — the 13c 2C
    /// correctness property, re-run over text the transform shortened. The
    /// ADDRESS rule is untouched by construction: a page is still named
    /// (post, page-in-post), and nothing here is an index into a projection.
    @Test func thePagesCoverTheRENDEREDTextExactlyOnceInOrder() throws {
        let paragraph = "This is **ordinary** prose with a [link](https://x.test) and "
            + "some ~~struck~~ words, running on for a reasonable while before it stops. "
        let post = compose([slot("a", (0..<40).map { _ in paragraph }.joined(separator: "\n\n"))])
        #expect(post.attributed.length < (post.body as NSString).length)

        let paginator = PagePaginator(composed: post, contentRect: geometry.contentRect)
        let pages = paginator.pageCount()
        #expect(pages > 3, "a long post flows across several pages: \(pages)")
        var cursor = 0
        for i in 0..<pages {
            let range = try #require(paginator.range(forPage: i))
            #expect(range.location == cursor, "page \(i) starts where page \(i - 1) ended")
            cursor = range.location + range.length
        }
        #expect(cursor == post.attributed.length,
                "the last page ends at the end of the RENDERED post")
    }

    // MARK: - The paged leaf's plain click, through real CoreText geometry

    /// **A plain click on a page resolves to the character under it** — and
    /// the index comes from CoreText itself, so the hit test is answered by
    /// the engine that laid the page out.
    ///
    /// DISCRIMINATING REVERT: use `origins[i]` directly instead of rebasing
    /// it onto the frame path's bounding box, and this fails. It is not a
    /// hypothetical: the first draft DID compare them directly, and this pin
    /// caught it — a click on the first word resolved to the SEVENTH
    /// character, because `CTFrameGetLineOrigins` reports origins relative to
    /// the path's bounding box rather than to the page.
    @Test func aPointOnThePageResolvesToTheCharacterUnderIt() throws {
        let post = compose([slot("a", "Open [the docs](https://x.test/a) to begin.")])
        let paginator = PagePaginator(composed: post, contentRect: geometry.contentRect)
        let view = PageFrameNSView()
        view.frame = NSRect(origin: .zero, size: geometry.size)
        let ctFrame = try #require(paginator.frame(forPage: 0))
        view.ctFrame = ctFrame
        view.geometry = geometry
        view.links = post.links
        view.scale = 1

        let linkRange = try #require(post.links.first).range
        let found = Self.point(resolvingInto: linkRange, of: view)
        let onLink = try #require(found, "some point on the page lands inside the link")
        // …and the geometry is real: a point at the line's left edge lands
        // BEFORE the link, not inside it.
        let atStart = view.characterIndex(at: NSPoint(x: geometry.margin + 1,
                                                      y: onLink.y))
        #expect(atStart != nil)
        #expect(atStart.map { $0 < linkRange.location } == true,
                "the first word is not the link")

        // A point far below the text block is off the page's lines.
        #expect(view.characterIndex(at: NSPoint(x: geometry.margin + 4, y: 2)) == nil)
    }

    /// The page SCALES to the window (13c 2C's ruling — a resize never
    /// repaginates), so the hit test has to undo that scale. Halve it and the
    /// same character sits under half the coordinates.
    @Test func theHitTestUndoesThePagesScale() throws {
        let post = compose([slot("a", "Open [the docs](https://x.test/a) to begin.")])
        let paginator = PagePaginator(composed: post, contentRect: geometry.contentRect)
        let view = PageFrameNSView()
        let ctFrame = try #require(paginator.frame(forPage: 0))
        view.ctFrame = ctFrame
        view.geometry = geometry
        view.scale = 1
        let linkRange = try #require(post.links.first).range
        let full = try #require(Self.point(resolvingInto: linkRange, of: view))
        let index = try #require(view.characterIndex(at: full))

        view.scale = 0.5
        let halved = NSPoint(x: full.x / 2, y: full.y / 2)
        #expect(view.characterIndex(at: halved) == index)
    }

    // MARK: - The scroll face

    /// The flow renders the same way — and keeps its own paragraph rule
    /// (blank display lines are dropped; the paged reader is the face that
    /// keeps stored spacing byte for byte).
    @Test func theFlowRendersItsParagraphsAndDropsTheBlankOnes() {
        let paragraphs = FlowParagraph.paragraphs(
            of: "## Heading\n\nsome **bold** text\n\n- a list item")
        #expect(paragraphs.count == 3, "the blank lines are the flow's spacing, not content")
        #expect(paragraphs.map { String($0.text.characters) }
                == ["Heading", "some bold text", "\u{2022} a list item"])
        #expect(paragraphs.map(\.style)
                == [.heading(level: 2), .body, .bullet])
        #expect(paragraphs[0].indent == 0)
        #expect(paragraphs[2].indent > 0, "a list line sits in")
    }

    /// A link becomes a real `AttributedString` link — which is what makes
    /// SwiftUI's `Text` open it on a plain click — and the SCHEME GUARD sits
    /// in front of it, so an address the app will not follow simply carries
    /// no link attribute and reads as ordinary text.
    ///
    /// DISCRIMINATING REVERT: drop the scheme check from
    /// `MarkdownLink.openable` and the second half fails — a `file:` address
    /// becomes a live, clickable link on a reading surface.
    @Test func aFlowLinkIsClickableOnlyWhenItsSchemeIsOne() throws {
        let good = try #require(FlowParagraph.paragraphs(
            of: "read [the docs](https://x.test/a) now").first)
        let links = good.text.runs.compactMap { $0.link }
        #expect(links.map(\.absoluteString) == ["https://x.test/a"])
        #expect(String(good.text.characters) == "read the docs now")

        // An `ftp:` address is well-formed and HAS a host — so only the
        // scheme allowlist can refuse it, which is what makes this the
        // discriminating case (a `file:` or `mailto:` URL is already refused
        // for having no host at all).
        let inert = try #require(FlowParagraph.paragraphs(
            of: "read [the file](ftp://files.test/doc) now").first)
        #expect(inert.text.runs.allSatisfy { $0.link == nil },
                "an address this app will not open is not a link")
        #expect(String(inert.text.characters) == "read the file now",
                "…but it still READS as its words — the markers are still markdown")
    }

    /// Emphasis survives into the flow's attributed text (SwiftUI's `Text`
    /// renders the presentation intents; the pin asserts they are there).
    @Test func theFlowCarriesItsEmphasisAsPresentationIntent() throws {
        let paragraph = try #require(
            FlowParagraph.paragraphs(of: "say **this** and *that*").first)
        var intents: [InlinePresentationIntent] = []
        for run in paragraph.text.runs {
            if let intent = run.inlinePresentationIntent { intents.append(intent) }
        }
        #expect(intents.contains(.stronglyEmphasized))
        #expect(intents.contains(.emphasized))
    }

    // MARK: - Fixtures

    /// A point over the page whose CoreText index lands inside `range`,
    /// found by sweeping the page's own geometry — the `MarkdownActsTests`
    /// pattern, so the pin exercises point → line → index rather than
    /// re-deriving it from a font metric.
    private static func point(resolvingInto range: NSRange, of view: PageFrameNSView) -> NSPoint? {
        let rect = view.geometry.contentRect
        var y = rect.maxY
        while y > rect.minY {
            var x = rect.minX
            while x < rect.maxX {
                let candidate = NSPoint(x: x, y: y)
                if let index = view.characterIndex(at: candidate),
                   index >= range.location, index < range.upperBound {
                    return candidate
                }
                x += 1
            }
            y -= 2
        }
        return nil
    }
}

// MARK: - The Act 10 correction round, batch G — row 82

extension ReadRenderingTests {
    /// **Row 82: a plain click on a page names the BLOCK under it — after
    /// the links.** Her bar: "a click that does nothing is a defect"; a
    /// `CTFrame` page opened links only. The decision is `hit(at:)`, pure:
    /// a point on a link is the link (L10's door, unchanged); a point on
    /// prose is its block; a point off the text is nothing. RED ON OLD: no
    /// block map existed — `blocks` empty, every prose click nothing.
    @Test func aPointOnThePageNamesTheBlockUnderItAfterTheLinks() throws {
        let post = compose([
            slot("a", "Open [the docs](https://x.test/a) to begin."),
            slot("b", "A second paragraph, plain prose with no link in it at all."),
        ])
        #expect(post.blocks.map(\.blockID) == ["a", "b"], "the composed post carries every block's range")
        let paginator = PagePaginator(composed: post, contentRect: geometry.contentRect)
        let view = PageFrameNSView()
        view.frame = NSRect(origin: .zero, size: geometry.size)
        let ctFrame = try #require(paginator.frame(forPage: 0))
        view.ctFrame = ctFrame
        view.geometry = geometry
        view.links = post.links
        view.blocks = post.blocks
        view.scale = 1

        // A point on the link is the LINK, never its block.
        let linkRange = try #require(post.links.first).range
        let onLink = try #require(Self.point(resolvingInto: linkRange, of: view))
        #expect(view.hit(at: onLink) == .link(post.links[0]))
        // A point in the second block's prose is that BLOCK.
        let second = try #require(post.blocks.last).range
        let onProse = try #require(Self.point(resolvingInto: second, of: view))
        #expect(view.hit(at: onProse) == .block("b"))
        // A point in the first block's prose, off the link, is block "a".
        let atStart = NSPoint(x: geometry.margin + 1, y: onLink.y)
        #expect(view.hit(at: atStart) == .block("a"))
        // Off the text: nothing.
        #expect(view.hit(at: NSPoint(x: geometry.margin + 4, y: 2)) == nil)
    }
}
