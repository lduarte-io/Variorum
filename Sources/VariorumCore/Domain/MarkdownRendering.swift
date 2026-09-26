import Foundation

/// The READING transform: markdown-as-content → what a reading surface shows
/// (Phase 13g, batch 4 — L11, over the author's ruling **F-5** and the
/// SURFACE RULE her clarifying question pinned).
///
/// **The surface rule, restated because this file is the half that depends on
/// it.** EDITING surfaces — and the read-cheap tier, whose click seeds a caret
/// offset — render the DIMMED-MARKER face (`MarkdownStyling`), where display
/// == stored byte for byte and no offset ever needs translating. READ-ONLY
/// surfaces with NO editing gestures may render FULLY FORMATTED, markers
/// hidden: display ≠ stored is safe exactly where no gesture maps a click to a
/// text offset. Read is A43's reading surface, so this is where the second
/// face lives, and it lives NOWHERE else.
///
/// **What this is, and what it can never be.** A pure function, no GRDB and no
/// AppKit: text in, a DISPLAY STRING plus semantic runs and per-line styles
/// out. It never returns a font, a color, or a point size — those are the
/// app's, chosen from the voice tokens (P-8). It writes nothing, decides no
/// product behavior, and is not a second source of truth: the stored text is
/// untouched, `renderedText`/export never see this, and a reader
/// who hides a marker has changed only what is on the glass.
///
/// **Offsets are UTF-16 code units** in the DISPLAY string (`text`), the
/// structural API's unit throughout. Every range is grapheme-aligned by
/// construction: offsets accumulate per grapheme cluster, and the tokenizer's
/// own ranges are already aligned.
///
/// **Line-scoped, like everything in this family.** `MarkdownSyntax` never
/// lets a span cross a newline, so every replacement here sits inside one
/// line — which is also why a rendered line can be handed to a layout engine
/// on its own (the reading flow does exactly that).
public enum MarkdownRendering {
    // MARK: - What a reading surface is told

    /// Character-level emphasis on a run of display text. An option set
    /// because the app composes it onto a font; in v1 the tokenizer's
    /// no-nesting rule means at most one bit is ever set, and the set shape
    /// is what lets a future nesting rule arrive without a new type.
    public struct Emphasis: OptionSet, Equatable, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static let bold = Emphasis(rawValue: 1 << 0)
        public static let italic = Emphasis(rawValue: 1 << 1)
        public static let strikethrough = Emphasis(rawValue: 1 << 2)
        public static let code = Emphasis(rawValue: 1 << 3)
    }

    /// What a whole display LINE is. The line-leading kinds are paragraph
    /// facts (a size, a list lead), never character runs — which is exactly
    /// how the tokenizer models them.
    public enum LineStyle: Equatable, Sendable {
        case body
        case heading(level: Int)
        case bullet
        /// Read shows a box; it never toggles one (Read edits nothing).
        case checkbox(checked: Bool)
    }

    /// One styled run of display text. `url` is non-nil exactly on a link's
    /// text — the range a plain click opens on a reading surface.
    public struct Run: Equatable, Sendable {
        public let range: Range<Int>
        public let emphasis: Emphasis
        public let url: String?

        public init(range: Range<Int>, emphasis: Emphasis, url: String? = nil) {
            self.range = range
            self.emphasis = emphasis
            self.url = url
        }
    }

    /// One display line, its terminator EXCLUDED from `range`.
    public struct Line: Equatable, Sendable {
        public let range: Range<Int>
        public let style: LineStyle
        /// **13k K8 — the list line's NESTING LEVEL** (0 for everything
        /// else). The leading whitespace is part of the lead, so it is gone
        /// from `text` and the level is how a reading surface knows to sit
        /// the line in: an INDENT, never spaces (spaces would be a second
        /// indent on top of the first).
        ///
        /// Uncapped here, deliberately — the transform reports what the text
        /// says. A surface may CLAMP what it draws (ruled: Read clamps at 6,
        /// so a runaway nest cannot push words off a fixed page); that is a
        /// look decision and it lives with the look.
        public let indentLevel: Int

        public init(range: Range<Int>, style: LineStyle, indentLevel: Int = 0) {
            self.range = range
            self.style = style
            self.indentLevel = indentLevel
        }
    }

    /// The deepest level a reading surface DRAWS (ruled — the stored text is
    /// never clamped). Here rather than in a view so both Read faces indent
    /// alike.
    public static let maxDrawnIndentLevel = 6

    /// The whole answer for one text.
    public struct Rendered: Equatable, Sendable {
        /// What the surface DRAWS. Not the stored text — that is the point.
        public let text: String
        /// Ascending, disjoint, and only where something is not plain.
        public let runs: [Run]
        /// Every line, in order, blank ones included (a reading surface that
        /// keeps stored spacing needs them; one that drops it can filter).
        public let lines: [Line]

        public init(text: String, runs: [Run], lines: [Line]) {
            self.text = text
            self.runs = runs
            self.lines = lines
        }

        /// The clickable runs, in order — a reading surface's link map.
        public var links: [Run] { runs.filter { $0.url != nil } }
    }

    // MARK: - The substituted leads

    /// A bullet's lead. TWO display characters for the two source ones
    /// (`"- "`), which is a small gift rather than a design: nothing here
    /// depends on lengths matching.
    public static let bulletLead = "\u{2022} "
    /// A checkbox's box, unchecked and checked. Read DISPLAYS these; clicking
    /// one does nothing, because Read is not an editing surface (her A43
    /// ruling) — the tick lives on the surfaces that can take an edit.
    public static let uncheckedBox = "\u{2610}"
    public static let checkedBox = "\u{2611}"

    // MARK: - The one entry point

    /// Render `source` for a reading surface.
    ///
    /// **Cost is ∝ `source`**, one tokenizer scan and one walk — so a caller
    /// gets P1 by rendering only what it draws. Both Read faces do: the paged
    /// reader composes the posts a spread needs (at most two), and the flow
    /// renders inside a `LazyVStack` row's own task.
    public static func render(_ source: String) -> Rendered {
        guard !source.isEmpty else { return Rendered(text: "", runs: [], lines: []) }

        var display = ""
        display.reserveCapacity(source.utf16.count)
        var displayLength = 0
        var runs: [Run] = []
        var lines: [Line] = []
        walkLines(source) { line, _ in
            let rendered = line.rendered
            display += rendered.text
            let lineLower = displayLength
            displayLength += rendered.text.utf16.count
            lines.append(Line(
                range: lineLower..<displayLength, style: rendered.style,
                indentLevel: rendered.indentLevel))
            for run in rendered.runs {
                runs.append(Run(
                    range: (run.range.lowerBound + lineLower)..<(run.range.upperBound + lineLower),
                    emphasis: run.emphasis, url: run.url))
            }
            if let terminator = line.terminator {
                // The terminator is copied VERBATIM — a "\r\n" is one
                // Character and stays one.
                display.append(terminator)
                displayLength += terminator.utf16Width
            }
            return true
        }
        return Rendered(text: display, runs: runs, lines: lines)
    }

    /// **Where a DISPLAY offset came from in the stored text** (18l UNIT U0 —
    /// her report: *"I click on top of a line of text [in the book Index] and
    /// my cursor moves to the empty paragraph"*). The read-cheap tiers of the
    /// two Index surfaces draw THIS transform's display — markers hidden — and
    /// a click on them now seeds the live pane's caret, which is exactly the
    /// case the surface rule above names as needing a translation. This is
    /// that translation, read off the SAME walk `render` builds the display
    /// from (`walkLines`), so the two can never disagree about a line.
    ///
    /// The rule, per line: the answer is the LAST source boundary that landed
    /// at or before `displayOffset` — so a caret shown just before a word lands
    /// just before that word, inside any marker that precedes it (`**bold**`:
    /// display 0 → source 2, after the opening `**`), and a caret after the
    /// word lands after its closing marker. A display offset past the end
    /// answers the text's end; one inside a multi-unit terminator answers its
    /// line's end. UTF-16 in, UTF-16 out, both grapheme-aligned.
    public static func sourceOffset(forDisplayOffset displayOffset: Int, in source: String) -> Int {
        guard !source.isEmpty else { return 0 }
        let target = max(0, displayOffset)
        var answer = source.utf16.count
        var displayLength = 0
        walkLines(source) { line, offsets in
            let lower = displayLength
            let length = line.rendered.text.utf16.count
            let next = lower + length + (line.terminator?.utf16Width ?? 0)
            displayLength = next
            guard target < next || line.terminator == nil else { return true }
            let local = min(target - lower, length)
            // `landed` is non-decreasing over the line's source boundaries.
            var boundary = 0
            for (index, landed) in line.rendered.landed.enumerated() where landed <= local {
                boundary = index
            }
            answer = offsets[line.sourceStart + boundary]
            return false
        }
        return answer
    }

    /// One source line as `render` walks it: its rendering, the CHARACTER
    /// index its first character has in the source (the rendering's `landed`
    /// table counts boundaries from there; the walk hands the visitor the
    /// source's UTF-16 offset per character boundary), and the terminator
    /// that ended it (nil on the last line).
    private struct WalkedLine {
        let rendered: RenderedLine
        let sourceStart: Int
        let terminator: Character?
    }

    /// THE walk (18l U0 — factored out of `render`, byte-for-byte the loop it
    /// was): one tokenizer scan, then every line in order, blank ones
    /// included. `visit` returns false to stop early.
    private static func walkLines(
        _ source: String, _ visit: (WalkedLine, _ offsets: [Int]) -> Bool
    ) {
        let chars = Array(source)
        var offsets: [Int] = [0]
        offsets.reserveCapacity(chars.count + 1)
        for char in chars { offsets.append(offsets[offsets.count - 1] + char.utf16Width) }

        // ONE scan of the whole text; spans arrive in APPLICATION ORDER (a
        // line's leading span first, then its inline spans left to right),
        // which is exactly the order a line needs them in.
        let spans = MarkdownSyntax.spans(in: source)
        var spanIndex = 0

        var lineStart = 0
        var index = 0
        while index <= chars.count {
            guard index == chars.count || chars[index].isNewline else {
                index += 1
                continue
            }
            let lineUpper = offsets[index]
            var mine: [MarkdownSyntax.Span] = []
            while spanIndex < spans.count, spans[spanIndex].range.lowerBound < lineUpper {
                mine.append(spans[spanIndex])
                spanIndex += 1
            }
            let rendered = renderLine(
                chars, offsets, from: lineStart, to: index, spans: mine)
            let line = WalkedLine(
                rendered: rendered, sourceStart: lineStart,
                terminator: index < chars.count ? chars[index] : nil)
            guard visit(line, offsets) else { return }
            lineStart = index + 1
            index += 1
        }
    }

    // MARK: - One line

    private struct RenderedLine {
        let text: String
        let runs: [Run]
        let style: LineStyle
        var indentLevel: Int = 0
        /// Where each of the line's source character BOUNDARIES landed in the
        /// line's display (index 0 = the line's start, the last = its end) —
        /// the table the walk already built to place spans, kept so
        /// `sourceOffset(forDisplayOffset:in:)` can read it back (18l U0).
        var landed: [Int] = []
    }

    /// One replacement inside a line, in CHARACTER indices (so the walk that
    /// builds the display can compare against its own cursor).
    private struct Replacement {
        let from: Int
        let to: Int
        let text: String
    }

    private static func renderLine(
        _ chars: [Character], _ offsets: [Int],
        from start: Int, to end: Int, spans: [MarkdownSyntax.Span]
    ) -> RenderedLine {
        var style = LineStyle.body
        var indentLevel = 0
        var replacements: [Replacement] = []

        func replace(_ range: Range<Int>, with text: String) {
            let from = charIndex(range.lowerBound, offsets)
            let to = charIndex(range.upperBound, offsets)
            guard from < to else { return }
            replacements.append(Replacement(from: from, to: to, text: text))
        }

        for span in spans {
            switch span.kind {
            case .heading(let level):
                style = .heading(level: level)
                for marker in span.markers { replace(marker, with: "") }
            case .bullet:
                style = .bullet
                // 13k K8: `markers[0]` is the INDENT + `"- "`, so substituting
                // it strips the whitespace and the level rides `indentLevel`
                // — the surface draws ONE indent, not spaces plus an indent.
                indentLevel = span.indentLevel
                for marker in span.markers { replace(marker, with: bulletLead) }
            case .checkbox(let checked):
                style = .checkbox(checked: checked)
                indentLevel = span.indentLevel
                // `markers[0]` is the `"- "` lead and `markers[1]` is the box
                // (the tokenizer's own split): the lead goes, the box becomes
                // a glyph, and the ordinary space after it — which belongs to
                // neither marker — separates the box from the words exactly
                // as it did in the source.
                if let lead = span.markers.first { replace(lead, with: "") }
                if span.markers.count > 1 {
                    replace(span.markers[1], with: checked ? checkedBox : uncheckedBox)
                }
            case .bold, .italic, .strikethrough, .code, .link:
                for marker in span.markers { replace(marker, with: "") }
                if let url = span.url { replace(url, with: "") }
            }
        }
        replacements.sort { $0.from < $1.from }

        // Build the display text, remembering where each source character
        // boundary LANDED so a span's content range can be re-read in display
        // offsets. (An index inside a replaced run maps to that run's start;
        // no content range ever begins there, since content is by definition
        // outside its markers.)
        var text = ""
        var landed = [Int](repeating: 0, count: max(end - start + 1, 1))
        var length = 0
        var cursor = start
        var next = 0
        while cursor < end {
            landed[cursor - start] = length
            // Replacements are disjoint and ascending by construction (a
            // line-leading span's markers sit at the line's start, inline
            // spans begin after its content does); the skip is belt-and-
            // braces so a future kind can never wedge this walk.
            while next < replacements.count, replacements[next].from < cursor { next += 1 }
            if next < replacements.count, replacements[next].from == cursor {
                let replacement = replacements[next]
                text += replacement.text
                length += replacement.text.utf16.count
                // Characters the replacement swallowed land at its END; the
                // boundary where it STARTED keeps the offset before it, which
                // is the honest answer for "where did this source offset go".
                for skipped in (cursor + 1)..<replacement.to {
                    landed[skipped - start] = length
                }
                cursor = replacement.to
                next += 1
                continue
            }
            text.append(chars[cursor])
            length += chars[cursor].utf16Width
            cursor += 1
        }
        landed[end - start] = length

        var runs: [Run] = []
        for span in spans {
            let emphasis: Emphasis
            var url: String?
            switch span.kind {
            case .bold: emphasis = .bold
            case .italic: emphasis = .italic
            case .strikethrough: emphasis = .strikethrough
            case .code: emphasis = .code
            case .link:
                emphasis = []
                if let range = span.url {
                    let from = charIndex(range.lowerBound, offsets)
                    let to = charIndex(range.upperBound, offsets)
                    url = String(chars[from..<to])
                }
            case .heading, .bullet, .checkbox:
                continue  // a paragraph fact, carried by `style`
            }
            let from = landed[charIndex(span.content.lowerBound, offsets) - start]
            let to = landed[charIndex(span.content.upperBound, offsets) - start]
            guard from < to else { continue }
            runs.append(Run(range: from..<to, emphasis: emphasis, url: url))
        }
        runs.sort { $0.range.lowerBound < $1.range.lowerBound }
        return RenderedLine(
            text: text, runs: runs, style: style, indentLevel: indentLevel, landed: landed)
    }

    /// The character index a UTF-16 offset names (binary search — `offsets`
    /// is ascending). An offset inside a surrogate pair cannot occur: every
    /// offset here comes from this table or from a `MarkdownSyntax` range,
    /// and both accumulate per GRAPHEME.
    private static func charIndex(_ offset: Int, _ offsets: [Int]) -> Int {
        var low = 0
        var high = offsets.count - 1
        while low < high {
            let mid = (low + high) / 2
            if offsets[mid] < offset { low = mid + 1 } else { high = mid }
        }
        return low
    }
}
