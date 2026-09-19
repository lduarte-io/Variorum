//
//  PagePaginator.swift
//  Variorum
//
//  READ's TRUE PAGINATION — the EXACT tier (13c Batch 2C; the uniform-page
//  brief §3.2). One post's rendered prose, composed into an attributed
//  string and sliced into page-sized frames by CoreText — the 11b PDF
//  exporter's proven path (`CTFramesetterCreateFrame` +
//  `CTFrameGetVisibleStringRange`), which is pure CoreText and lives
//  entirely OUTSIDE the editor stack.
//
//  Three reasons this is CoreText and not a read-tier TK2 view per page
//  (the brief's Q3, answered here and recorded in the batch record):
//
//  1. **The break and the drawing are the same computation.** A page must
//     show EXACTLY the range the pagination assigned it; two layout engines
//     asked the same question at different times are two chances to
//     disagree, and the disagreement's shape is text visibly cut off or
//     doubled at a page seam.
//  2. **TK2 must not be asked for geometry here** (Stage 4 lesson 8, and
//     1C's over-report). A `CTFrame`'s visible range is measured, not
//     estimated; there is no `.estimatedUsageBounds` state to be caught by.
//  3. **A realized page costs a frame, not an NSTextView** — no canary, no
//     fallback surface, no first-responder, nothing to keep live (P3, and
//     Read is deliberately not an editing surface — her A43 ruling).
//
//  What it costs: selection and copy, which a CoreText page does not get for
//  free. Read's OTHER sub-mode (the reading flow) has never offered them
//  either — its `Text` rows are not selectable — so the pair is consistent,
//  and the roads to the text are the editing surfaces and export.
//

import AppKit
import CoreText
import Foundation
import VariorumCore

/// One clickable link on a page: the range in the COMPOSED string, and the
/// address it opens (13g batch 4 — L10/L11).
struct PageLink: Equatable {
    let range: NSRange
    let url: String
}

/// **Row 82 (the Act 10 correction round, batch G):** one block's range in
/// the composed string — the map a plain click hit-tests against AFTER the
/// links, so a click on a page can name the block under it (the note's
/// `pages` face flips to `edit` at that block; the book's paged Read lands
/// its Index there — the one scrolled-open door, `LandingTarget`).
struct PageBlockRange: Equatable {
    let blockID: String
    let range: NSRange
}

/// One post, composed for the page: the attributed prose plus the plain
/// string it renders (kept so tests can pin it against `renderedText`).
struct ComposedPost {
    let attributed: NSAttributedString
    /// The BODY as plain text — exactly `Queries.renderedText`'s projection.
    ///
    /// **This is the STORED text, markers and all**, and it stays that way
    /// deliberately: it is the drift guard on the join conditional
    /// (`theComposedBodyIsTheRatifiedProjection` pins it byte-equal to
    /// `Queries.renderedText`). What the page DRAWS is `attributed`, which
    /// since 13g batch 4 carries the RENDERED face — markers hidden, per her
    /// F-5 surface rule, because Read has no editing gesture that maps a
    /// click to a text offset.
    let body: String
    /// The characters of opening chrome (chapter opener + title) prepended
    /// before the body, so a caller can map back into the projection.
    let chromeLength: Int
    /// Every link on this post's pages, in composed-string offsets — the map
    /// a plain click hit-tests against (13g batch 4, L10).
    var links: [PageLink] = []
    /// Row 82: every block's range, in the same composed-string offsets —
    /// the map a plain click that hit no link resolves to a BLOCK by.
    var blocks: [PageBlockRange] = []
}

enum PageComposer {
    /// The chrome a post's first page carries, in LINES — the estimator's
    /// `headingLines` input. The two must agree or every short post in the
    /// book is estimated wrong (the estimator has no other way to know a
    /// title is there).
    static func headingLines(hasChapter: Bool) -> Double {
        (hasChapter ? 3.5 : 0) + 2.5
    }

    /// Compose one post for the page.
    ///
    /// The BODY is the ratified projection and nothing else: `renderPost`'s
    /// slots, blank takes and gaps skipped, joined with the 2026-07-12
    /// conditional — and PINNED byte-equal to `Queries.renderedText` (the
    /// one join brain's output) by `theComposedBodyIsTheRatifiedProjection`,
    /// which is the guard that keeps this walk's join from ever drifting
    /// from `joinRenderedTexts` (13c K6, K3). Stored spacing therefore
    /// reaches the page exactly as it reaches export, which the reading
    /// flow's paragraph-splitting deliberately does not do.
    ///
    /// A CALLOUT block (`block.presentation`) reads as an indented passage.
    /// That is a presentation transform over the same characters — no glyph
    /// is added and no character is changed, so the page's text is still the
    /// projection byte for byte. (Export's blockquote mapping ADDS "> "
    /// characters and is therefore a different transform for a different
    /// medium; neither one touches `renderedText`.)
    static func compose(
        slots: [Queries.RenderedBlock],
        presentations: [String: BlockPresentation],
        title: String?, chapter: String?,
        typography: PageTypography, ink: NSColor, chapterInk: NSColor,
        // 13k K10: the reading page's inline-code chip. Defaulted so every
        // existing caller and pin composes exactly as it did.
        codeTint: NSColor? = nil
    ) -> ComposedPost {
        let result = NSMutableAttributedString()
        if let chapter, !chapter.isEmpty {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            style.paragraphSpacing = 12
            result.append(NSAttributedString(
                string: "\(chapter.uppercased())\n",
                attributes: [
                    .font: typography.chapter, .foregroundColor: chapterInk,
                    .kern: 2.0, .paragraphStyle: style,
                ]))
        }
        if let title, !title.isEmpty {
            let style = NSMutableParagraphStyle()
            style.paragraphSpacing = 10
            result.append(NSAttributedString(
                string: "\(title)\n",
                attributes: [
                    .font: typography.title, .foregroundColor: ink,
                    .paragraphStyle: style,
                ]))
        }
        let chromeLength = result.length

        // The projection AND the block ranges, from ONE walk (13c K6
        // review, K3). The body used to be a separate `joinRenderedTexts`
        // call BESIDE this walk's copy of the join conditional — two
        // strings built by two code paths, with ranges computed on one and
        // attributes applied to the other. Byte-equal at the time, but a
        // future change to the one join brain would have drifted them
        // silently: the mild shape is a callout indented on the wrong
        // characters, the worst an out-of-bounds `addAttribute`
        // (NSRangeException). With the walk's own output AS the body there
        // is one string — and the body-equality pin
        // (`theComposedBodyIsTheRatifiedProjection`: body == `renderedText`)
        // becomes a real drift guard on this conditional instead of a
        // tautology. The blank-take skip is `renderedText`'s own rule — a
        // chosen-but-empty take contributes nothing, not even a join.
        // 13g batch 4 (L11): the walk now builds TWO strings from ONE set of
        // decisions — the stored `body` (the ratified projection, and the
        // drift guard on this conditional) and the DISPLAY string the page
        // draws, which is the same text with its markdown rendered. The
        // transform is line-scoped, so rendering per block and joining is
        // identical to rendering the joined body — and doing it per block is
        // what keeps every block's DISPLAY range known without a mapping
        // table (the callout indent rides those ranges).
        var ranges: [(blockID: String, range: NSRange)] = []
        var runs: [(range: NSRange, run: MarkdownRendering.Run)] = []
        var lineStyles: [(range: NSRange, line: MarkdownRendering.Line)] = []
        var links: [PageLink] = []
        var composed = ""
        var display = ""
        for slot in slots {
            guard let text = slot.text, !text.isEmpty else { continue }
            if !composed.isEmpty {
                // ONE decision, two strings: the join is read off the STORED
                // text (renderedText's own rule) and applied to both.
                let separator = composed.hasSuffix("\n") ? "\n" : Queries.blockJoinSeparator
                composed += separator
                display += separator
            }
            composed += text
            let start = (display as NSString).length
            let rendered = MarkdownRendering.render(text)
            display += rendered.text
            let length = (rendered.text as NSString).length
            ranges.append((slot.blockID, NSRange(location: start, length: length)))
            for run in rendered.runs {
                runs.append((
                    NSRange(location: start + run.range.lowerBound, length: run.range.count), run))
                if let url = run.url {
                    links.append(PageLink(
                        range: NSRange(
                            location: start + run.range.lowerBound, length: run.range.count),
                        url: url))
                }
            }
            for line in rendered.lines where line.style != .body {
                lineStyles.append((
                    NSRange(location: start + line.range.lowerBound, length: line.range.count),
                    line))
            }
        }
        let body = composed

        let plainStyle = NSMutableParagraphStyle()
        plainStyle.lineSpacing = typography.lineSpacing
        plainStyle.paragraphSpacing = typography.lineSpacing
        plainStyle.hyphenationFactor = 0.9
        let bodyString = NSMutableAttributedString(
            string: display,
            attributes: [
                .font: typography.body, .foregroundColor: ink,
                .paragraphStyle: plainStyle,
            ])
        for (blockID, range) in ranges {
            guard let presentation = presentations[blockID],
                  presentation.kind == BlockPresentation.calloutKind,
                  // Bounds-guarded like every other attribute write in the
                  // app (`MarkdownStyling.write`'s rule): the ranges above
                  // are computed on the very string being written, so this
                  // can only fire if that ever stops being true — and the
                  // failure it prevents is an NSRangeException, i.e. a crash
                  // rather than a wrong look. (Measured: a revert that
                  // computed these ranges on the STORED offsets took the
                  // test host down instead of failing a pin.)
                  range.length > 0, range.upperBound <= bodyString.length
            else { continue }
            let style = NSMutableParagraphStyle()
            style.lineSpacing = typography.lineSpacing
            style.paragraphSpacing = typography.lineSpacing
            style.hyphenationFactor = 0.9
            style.firstLineHeadIndent = 22
            style.headIndent = 22
            style.tailIndent = -22
            bodyString.addAttribute(.paragraphStyle, value: style, range: range)
        }
        // The rendered face: paragraph facts first (a heading's size, a list
        // line's hanging indent), then the character runs on top, so a bold
        // word inside a heading keeps the heading's size.
        //
        // 13u3 UNIT F: the two appliers MOVED to `Theme/MarkdownReadingFace`
        // — byte-identical, and now reachable by the PDF exporter, which is a
        // reading surface with even less gesture than this one and had been
        // drawing her markdown raw. The page's values are unchanged: the
        // voice's ink, the system link colour, this page's own code tint.
        let face = MarkdownReadingFace.Style(
            body: typography.body, lineSpacing: typography.lineSpacing,
            ink: ink, link: .linkColor, codeTint: codeTint)
        for (range, line) in lineStyles {
            MarkdownReadingFace.applyLineStyle(line, to: bodyString, range: range, style: face)
        }
        for (range, run) in runs {
            MarkdownReadingFace.applyRun(run, to: bodyString, range: range, style: face)
        }
        result.append(bodyString)
        // Shifted past the chrome, and BOUNDS-GUARDED for the same reason the
        // callout indent is: these ranges are computed on the very string
        // they name, so the guard can only fire if that stops being true —
        // and what it prevents is a caller's `substring` raising rather than
        // a link landing on the wrong words.
        let displayLength = (display as NSString).length
        return ComposedPost(
            attributed: result, body: body, chromeLength: chromeLength,
            links: links.compactMap { link in
                guard link.range.length > 0, link.range.upperBound <= displayLength
                else { return nil }
                return PageLink(
                    range: NSRange(
                        location: link.range.location + chromeLength, length: link.range.length),
                    url: link.url)
            },
            // Row 82: the blocks' DISPLAY ranges, rebased onto the composed
            // string exactly as the links are.
            blocks: ranges.compactMap { blockID, range in
                guard range.upperBound <= displayLength else { return nil }
                return PageBlockRange(
                    blockID: blockID,
                    range: NSRange(location: range.location + chromeLength, length: range.length))
            })
    }

    // MARK: - The rendered face (13g batch 4 — L11)
    //
    // MOVED at 13u3 UNIT F to `Theme/MarkdownReadingFace.swift`, byte for
    // byte, because the PDF exporter needed the same translation and a second
    // copy of it would have been the drift class this file's own header
    // argues against ("two layout engines asked the same question at
    // different times are two chances to disagree"). The page's call site
    // above supplies exactly the values these functions used to read off
    // `PageTypography` + `ink` + `codeTint`; a link is still `NSColor
    // .linkColor` here, because a page is drawn by CoreText, which has no
    // link handling of its own — the colour is the affordance and
    // `ComposedPost.links` is the hit map (`PageFrameNSView.mouseDown`).
}

/// One post's pages, sliced lazily and cached.
///
/// **The cost shape, MEASURED (13c 2C, on this machine — Debug, macOS
/// 26.4.1):** CoreText typesets per PARAGRAPH, so a frame's cost is
/// proportional to the paragraph it starts inside, not to the post.
///
/// | one post, real paragraphs | pages | paginate it ALL | one deep frame |
/// |---|---|---|---|
/// | 2,438 chars | 3 | 0.1 ms | 0.02 ms |
/// | 39,038 chars | 46 | 0.9 ms | 0.02 ms |
/// | 156,158 chars (26k words) | 183 | 3.5 ms | 0.02 ms |
///
/// …and the pathological shape, which is why this slices LAZILY rather than
/// paginating a post up front: the SAME text as ONE unbroken paragraph — a
/// long message pasted as a single block, exactly the A3/A41 case — costs
/// 105 ms at 37,760 chars and **1.67 s at 151,040**, because every frame
/// inside a giant paragraph re-typesets that paragraph from its start.
///
/// So: pages are sliced only as far as the reader has actually walked, and a
/// post's page count is EXACT only once slicing has reached its end. Cost is
/// ∝ what she is reading (P1's letter), and the pathological block costs a
/// pathological amount only for the pages of it she actually turns to.
final class PagePaginator {
    let composed: ComposedPost
    let contentRect: CGRect
    private let framesetter: CTFramesetter
    /// Page starts (UTF-16 locations). Always begins with 0.
    private var starts: [Int] = [0]
    private var complete = false
    /// A guard against a pathological post pinning the main thread forever;
    /// far past anything real (a 400-page post is ~200k words).
    static let pageCap = 400

    init(composed: ComposedPost, contentRect: CGRect) {
        self.composed = composed
        self.contentRect = contentRect
        framesetter = CTFramesetterCreateWithAttributedString(composed.attributed)
    }

    private var length: Int { composed.attributed.length }

    /// Pages discovered so far. A LOWER BOUND on the post's real count until
    /// `isComplete`.
    var knownPageCount: Int { max(1, starts.count) }
    /// True once slicing has reached the end of the post — only then is the
    /// page count exact.
    var isComplete: Bool { complete }

    /// Slice forward until page `index` is known (or the post ends). Exactly
    /// that far: the ONE page of lookahead a turn needs is the caller's
    /// business, so the cost of a spread is legible at its call site.
    func slice(through index: Int) {
        let path = CGPath(rect: contentRect, transform: nil)
        while !complete, starts.count <= index, starts.count < Self.pageCap {
            guard let last = starts.last, last < length else { complete = true; break }
            let frame = CTFramesetterCreateFrame(
                framesetter, CFRange(location: last, length: 0), path, nil)
            let visible = CTFrameGetVisibleStringRange(frame)
            // Every page consumes at least one character, so this terminates
            // even if CoreText reports nothing visible (the PDF exporter's
            // same guard).
            let next = last + max(visible.length, 1)
            if next >= length {
                complete = true
            } else {
                starts.append(next)
            }
        }
        if starts.count >= Self.pageCap { complete = true }
    }

    /// The exact page count — pagination run to the END of the post.
    ///
    /// **Deliberately not on the reading path.** The surface slices only as
    /// far as the reader walks (see the cost table above); this exists for
    /// the pins and for a caller that genuinely needs the whole count.
    func pageCount() -> Int {
        slice(through: Self.pageCap)
        return knownPageCount
    }

    /// The frame for page `index`, or nil past the end.
    func frame(forPage index: Int) -> CTFrame? {
        guard index >= 0 else { return nil }
        slice(through: index)
        guard index < starts.count else { return nil }
        let path = CGPath(rect: contentRect, transform: nil)
        return CTFramesetterCreateFrame(
            framesetter, CFRange(location: starts[index], length: 0), path, nil)
    }

    /// The range page `index` shows — the pin surface for "the pages cover
    /// the post exactly once, in order, with no gap and no overlap".
    func range(forPage index: Int) -> NSRange? {
        guard let frame = frame(forPage: index) else { return nil }
        let visible = CTFrameGetVisibleStringRange(frame)
        return NSRange(location: starts[index], length: max(visible.length, 0))
    }
}
