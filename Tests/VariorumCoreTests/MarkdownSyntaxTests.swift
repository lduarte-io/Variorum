import Foundation
import Testing
@testable import VariorumCore

/// The substring a UTF-16 range names — so every pin below reads as the text
/// it means rather than as arithmetic.
private func slice(_ text: String, _ range: Range<Int>) -> String {
    (text as NSString).substring(
        with: NSRange(location: range.lowerBound, length: range.count))
}

/// A span flattened for assertion: kind, marker texts, content, url.
private func shape(
    _ text: String, _ span: MarkdownSyntax.Span
) -> (MarkdownSyntax.Kind, [String], String, String?) {
    (span.kind,
     span.markers.map { slice(text, $0) },
     slice(text, span.content),
     span.url.map { slice(text, $0) })
}

private func spans(_ text: String) -> [MarkdownSyntax.Span] {
    MarkdownSyntax.spans(in: text)
}

private func kinds(_ text: String) -> [MarkdownSyntax.Kind] {
    spans(text).map(\.kind)
}

@Suite("MarkdownSyntax (13g batch 2, L7 — the tokenizer; F-1/F-3)")
struct MarkdownSyntaxTests {

    // MARK: - The inline vocabulary (F-3)

    @Test func boldItalicStrikeAndCodeCarryTheirMarkersAndContent() throws {
        let bold = "say **this** now"
        try #require(spans(bold).count == 1)
        let (boldKind, boldMarkers, boldContent, boldURL) = shape(bold, spans(bold)[0])
        #expect(boldKind == .bold)
        #expect(boldMarkers == ["**", "**"])
        #expect(boldContent == "this")
        #expect(boldURL == nil)
        // Exact offsets, once, so the arithmetic is pinned and not only the
        // substrings it produces.
        #expect(spans(bold)[0].range == 4..<12)
        #expect(spans(bold)[0].markers == [4..<6, 10..<12])
        #expect(spans(bold)[0].content == 6..<10)

        #expect(shape("a *it* b", spans("a *it* b")[0]).0 == .italic)
        #expect(shape("a *it* b", spans("a *it* b")[0]).2 == "it")
        #expect(shape("~~gone~~", spans("~~gone~~")[0]).0 == .strikethrough)
        #expect(shape("~~gone~~", spans("~~gone~~")[0]).2 == "gone")
        #expect(shape("`let x`", spans("`let x`")[0]).0 == .code)
        #expect(shape("`let x`", spans("`let x`")[0]).2 == "let x")
    }

    @Test func linksCarryTextAndURLSeparately() throws {
        let text = "see [the notes](https://x.test/a) today"
        try #require(spans(text).count == 1)
        let (kind, markers, content, url) = shape(text, spans(text)[0])
        #expect(kind == .link)
        #expect(markers == ["[", "](", ")"])
        #expect(content == "the notes")
        #expect(url == "https://x.test/a")
    }

    @Test func aURLMayCONTAINParentheses() throws {
        // Balanced-paren matching, deliberately: Wikipedia-shaped addresses
        // are the everyday case a naive first-`)` scan gets wrong.
        let text = "[wiki](https://x.test/Foo_(bar))"
        try #require(spans(text).count == 1)
        #expect(shape(text, spans(text)[0]).3 == "https://x.test/Foo_(bar)")
        #expect(spans(text)[0].range == 0..<32)
    }

    // MARK: - The line-leading vocabulary (F-3)

    @Test func headingsRunOneToThreeAndNeedTheirSpace() {
        #expect(kinds("# One") == [.heading(level: 1)])
        #expect(kinds("## Two") == [.heading(level: 2)])
        #expect(kinds("### Three") == [.heading(level: 3)])
        #expect(shape("## Two", spans("## Two")[0]).1 == ["## "])
        #expect(shape("## Two", spans("## Two")[0]).2 == "Two")

        // DECISIONS, each pinned:
        #expect(kinds("#### Four").isEmpty, "F-3 names three sizes; a fourth is text")
        #expect(kinds("#hashtag").isEmpty, "no space ⇒ not a heading")
        #expect(kinds("  # indented").isEmpty, "a construct starts the line or it is text")
        // The marker typed, the words not yet — still a heading, so the face
        // appears the moment she commits to it.
        #expect(kinds("# ") == [.heading(level: 1)])
        #expect(shape("# ", spans("# ")[0]).2 == "")
    }

    @Test func bulletsAreTheHyphenAndNothingElse() {
        #expect(kinds("- milk") == [.bullet])
        #expect(shape("- milk", spans("- milk")[0]).1 == ["- "])
        #expect(shape("- milk", spans("- milk")[0]).2 == "milk")

        #expect(kinds("-milk").isEmpty, "no space ⇒ a hyphenated word, not a list")
        #expect(kinds("-").isEmpty)
        #expect(kinds("- ") == [.bullet], "the marker typed, the item not yet")
        // `*` is deliberately NOT a bullet in v1 — it would collide with
        // italic at a line's start.
        #expect(kinds("* starred").isEmpty)
    }

    @Test func checkboxesReadBothStatesAndFallBackToBulletsWhenMalformed() {
        #expect(kinds("- [ ] wash up") == [.checkbox(checked: false)])
        #expect(kinds("- [x] wash up") == [.checkbox(checked: true)])
        #expect(kinds("- [X] wash up") == [.checkbox(checked: true)], "capital X reads as done")

        let done = "- [x] wash up"
        let (_, markers, content, _) = shape(done, spans(done)[0])
        #expect(markers == ["- ", "[x]"], "markers[1] is the BOX — the range a toggle rewrites")
        #expect(content == "wash up", "the space after the box is text, not a marker")
        #expect(spans(done)[0].markers[1] == 2..<5)

        // Malformed boxes degrade to the bullet they still are — never to
        // nothing, so the list keeps its shape while she types.
        #expect(kinds("- [] wash up") == [.bullet])
        #expect(kinds("- [?] wash up") == [.bullet])
        #expect(kinds("- [x]wash up") == [.bullet], "the box needs a space or the line's end")
        // A box with no item yet is still a box.
        #expect(kinds("- [ ]") == [.checkbox(checked: false)])
        #expect(shape("- [ ]", spans("- [ ]")[0]).2 == "")
    }

    // MARK: - What stays literal

    @Test func unclosedMarkersArePlainText() {
        #expect(kinds("**unfinished").isEmpty)
        #expect(kinds("*unfinished").isEmpty)
        #expect(kinds("~~unfinished").isEmpty)
        #expect(kinds("`unfinished").isEmpty)
        #expect(kinds("[text](unclosed").isEmpty)
        #expect(kinds("[text] (spaced)").isEmpty, "`](` must be adjacent")
        #expect(kinds("[text]").isEmpty)
    }

    @Test func emptyContentIsAlwaysLiteral() {
        // ONE rule across the family: a span must contain something.
        #expect(kinds("****").isEmpty)
        #expect(kinds("~~~~").isEmpty)
        #expect(kinds("``").isEmpty)
        #expect(kinds("[](https://x.test)").isEmpty)
        #expect(kinds("[text]()").isEmpty, "a link to nowhere is not a link")
    }

    @Test func theFlankingRuleKeepsArithmeticArithmetic() {
        // The one false positive a prose writer actually hits.
        #expect(kinds("2 * 3 * 4").isEmpty)
        #expect(kinds("a ~~ b ~~ c").isEmpty)
        #expect(kinds("* *").isEmpty)
        #expect(kinds("**bold** and 2 * 3") == [.bold], "the rule is per-candidate, not per-line")
    }

    @Test func midWordEmphasisIsAllowed() {
        // CommonMark allows it for `*`, and `un*bloody*likely` is a real
        // thing a writer types.
        #expect(kinds("a*b*c") == [.italic])
        #expect(shape("a*b*c", spans("a*b*c")[0]).2 == "b")
    }

    @Test func aFailedBoldStillLetsTheItalicInsideItMatch() {
        // `**a*b*` — bold finds no closing `**`, so scanning advances ONE
        // character and the italic at offset 1 is found. Pinned because the
        // "advance by one" rule is what makes it true.
        let text = "**a*b*"
        #expect(kinds(text) == [.italic])
        #expect(spans(text)[0].markers == [1..<2, 3..<4])
        #expect(shape(text, spans(text)[0]).2 == "a")
    }

    // MARK: - No nesting (the documented first-match rule)

    @Test func aSpansContentIsNotRescanned() {
        #expect(kinds("`*a*`") == [.code], "code content stays literal — the point of code")
        #expect(kinds("**a *b* c**") == [.bold])
        #expect(shape("**a *b* c**", spans("**a *b* c**")[0]).2 == "a *b* c")
    }

    @Test func aLineLeadingSpansContentIS_inlineScanned() {
        // The one deliberate exception: `# **Big**` and `- [ ] **task**` are
        // exactly what a writer means.
        let heading = "# **Big**"
        #expect(kinds(heading) == [.heading(level: 1), .bold])
        // Application order: the leading span first, the inline one inside
        // its content — so a styler composing in order gets a bold heading.
        let spansHere = spans(heading)
        #expect(spansHere[0].content.lowerBound <= spansHere[1].range.lowerBound)
        #expect(spansHere[0].content.upperBound >= spansHere[1].range.upperBound)

        #expect(kinds("- [ ] **task**") == [.checkbox(checked: false), .bold])
        #expect(kinds("- see [docs](https://x.test)") == [.bullet, .link])
    }

    // MARK: - Line scoping (P1's mechanism AND the block-seam guarantee)

    /// DISCRIMINATING REVERT: drop `|| chars[index].isNewline` from
    /// `spans(in:)`'s line walk. Verified RED — all three cases match across
    /// the newline.
    @Test func aSpanNeverCrossesANewline() {
        // Load-bearing twice over: it is what makes a per-paragraph rescan
        // correct, and — because the editor surface joins blocks with a
        // single "\n" — it is why markdown styling can never cross a BLOCK
        // SEAM and disagree with block identity.
        #expect(kinds("**bold\nmore**").isEmpty)
        #expect(kinds("[text\n](url)").isEmpty)
        #expect(kinds("`code\nspan`").isEmpty)
    }

    @Test func everyLineIsScannedAndOffsetsStayAbsolute() {
        let text = "# Title\nplain line\n- [x] done **now**"
        let all = spans(text)
        #expect(all.map(\.kind)
            == [.heading(level: 1), .checkbox(checked: true), .bold])
        #expect(slice(text, all[0].content) == "Title")
        #expect(slice(text, all[1].content) == "done **now**")
        #expect(slice(text, all[2].content) == "now")
        // Absolute offsets: the bold span sits on line three.
        #expect(all[2].range.lowerBound == (text as NSString)
            .range(of: "**now**").location)
    }

    @Test func emptyLinesAndAnEmptyTextScanCleanly() {
        #expect(spans("").isEmpty)
        #expect(spans("\n\n\n").isEmpty)
        #expect(kinds("\n\n**bold**\n\n") == [.bold])
    }

    // MARK: - Offsets are UTF-16 and grapheme-aligned

    @Test func offsetsAreUTF16AndNeverSplitAGrapheme() throws {
        let text = "👋 **héllo 👨‍👩‍👧** ✅"
        try #require(spans(text).count == 1)
        let span = spans(text)[0]
        #expect(slice(text, span.content) == "héllo 👨‍👩‍👧")
        #expect(slice(text, span.markers[0]) == "**")
        #expect(slice(text, span.markers[1]) == "**")
        // The whole span, read back through UTF-16, is exactly what was typed.
        #expect(slice(text, span.range) == "**héllo 👨‍👩‍👧**")
        // And the ranges are inside the text's UTF-16 length.
        #expect(span.range.upperBound <= text.utf16.count)
    }

    // MARK: - Structural properties

    @Test func inlineSpansNeverOverlapAndAscend() {
        let text = """
        # A **bold** heading with `code` and [a link](https://x.test/p(q))
        - [ ] a *task* with ~~strike~~ and **bold**
        plain prose with 2 * 3 and a stray ] bracket
        """
        let all = spans(text)
        #expect(!all.isEmpty)
        // Every span is well-formed: markers and content inside the range,
        // ascending, and the content non-negative.
        for span in all {
            #expect(span.range.lowerBound <= span.content.lowerBound)
            #expect(span.content.upperBound <= span.range.upperBound)
            for marker in span.markers {
                #expect(span.range.lowerBound <= marker.lowerBound)
                #expect(marker.upperBound <= span.range.upperBound)
            }
        }
        // The INLINE spans (everything that is not line-leading) are
        // pairwise disjoint and ascending.
        let inline = all.filter { span in
            switch span.kind {
            case .heading, .bullet, .checkbox: return false
            default: return true
            }
        }
        for (a, b) in zip(inline, inline.dropFirst()) {
            #expect(a.range.upperBound <= b.range.lowerBound)
        }
    }

    @Test func shiftingRebasesEveryRangeTogether() {
        let span = spans("**b**")[0]
        let moved = span.shifted(by: 100)
        #expect(moved.kind == .bold)
        #expect(moved.range == 100..<105)
        #expect(moved.markers == [100..<102, 103..<105])
        #expect(moved.content == 102..<103)
        #expect(moved.url == nil)

        let link = spans("[t](u)")[0].shifted(by: 7)
        #expect(link.url == (11..<12))
    }

    // MARK: - The P1 instrument

    #if DEBUG  // MarkdownScanCount is a DEBUG-only oracle (VX-345)
    @Test func theScannerCountsExactlyWhatItWasHanded() {
        // The counter is the editing face's P1 pin (a keystroke must rescan
        // the edited line, never the note) — so its own arithmetic is pinned
        // here, on the scanner, where the shipped code calls it.
        MarkdownScanCount.reset()
        #expect(MarkdownScanCount.current == 0)
        _ = spans("**bold**")
        #expect(MarkdownScanCount.current == 8)
        _ = spans("hi 👋")   // the emoji is TWO UTF-16 units
        #expect(MarkdownScanCount.current == 8 + 5)
        MarkdownScanCount.reset()
        #expect(MarkdownScanCount.current == 0)
    }
    #endif

    // MARK: - The Act 10 correction round, batch G — row 84 (R-cor-10(4))

    /// **`_italic_` joins the vocabulary** — Gutenberg's emphasis, which the
    /// sample library reads raw without it — with a WORD BOUNDARY on both
    /// sides: an underscore inside an identifier never opens or closes a
    /// span. RED ON OLD: `_the_` was plain text.
    @Test func underscoreEmphasisIsItalicAtWordBoundariesOnly() throws {
        let plain = "she _really_ meant it"
        try #require(spans(plain).count == 1)
        let (kind, markers, content, url) = shape(plain, spans(plain)[0])
        #expect(kind == .italic)
        #expect(markers == ["_", "_"])
        #expect(content == "really")
        #expect(url == nil)
        #expect(spans(plain)[0].range == 4..<12)

        // The text's edges and punctuation are word boundaries.
        #expect(kinds("_the_") == [.italic])
        #expect(kinds("(_so_)") == [.italic])
        #expect(shape("(_so_)", spans("(_so_)")[0]).2 == "so")
        #expect(kinds("\u{201C}_quoted_\u{201D}") == [.italic])
        // Identifiers stay literal: an underscore after a letter or a digit
        // neither opens nor closes.
        #expect(kinds("snake_case_name") == [])
        #expect(kinds("a_b_c") == [])
        #expect(kinds("x_1 and y_2") == [])
        #expect(kinds("_lead_ing") == [], "a closer glued to a following word is not a closer")
        // The star's flanking rule applies: no whitespace after the opener,
        // none before the closer; empty content is literal; a run of two
        // underscores is not an opener.
        #expect(kinds("_ spaced _") == [])
        #expect(kinds("__") == [])
        #expect(kinds("__bold__") == [], "double underscores are not bold in this vocabulary")
        // Ladder R1-11 — the corner ruled: content that ENDS in an underscore
        // never italicizes (`_a__` is literal; an italic `a_` is nonsense),
        // as content that STARTS with one never opens. An underscore INSIDE
        // the content is content (`_a_b_` italicizes `a_b`).
        #expect(kinds("_a__") == [], "content ending in an underscore is literal")
        #expect(kinds("_ab__ cd") == [])
        #expect(kinds("_a_b_") == [.italic])
        #expect(shape("_a_b_", spans("_a_b_")[0]).2 == "a_b")
        // Beside the star form, on one line.
        #expect(kinds("*a* and _b_") == [.italic, .italic])
        #expect(shape("*a* and _b_", spans("*a* and _b_")[1]).2 == "b")
    }
}
