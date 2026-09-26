import Foundation
import Testing
@testable import VariorumCore

/// **18l UNIT U0 — the inverse of the reading transform, for a click.** The
/// two Index surfaces draw their read-cheap blocks through `MarkdownRendering`
/// (markers hidden), and a click there now seeds the live pane's caret — so a
/// DISPLAY offset has to be carried back to the STORED text it came from.
/// `sourceOffset(forDisplayOffset:in:)` reads the answer off the very walk
/// `render` builds the display from; these pins state the rule on the shapes
/// the transform treats differently.
@Suite("MarkdownRendering.sourceOffset (18l U0 — a display offset back to the stored text)")
struct MarkdownRenderingSourceOffsetTests {
    /// The display offset of `needle`'s first unit in the rendered text.
    private func displayOffset(of needle: String, in source: String) -> Int {
        let display = MarkdownRendering.render(source).text as NSString
        return display.range(of: needle).location
    }

    /// The stored offset of `needle`'s first unit.
    private func sourceOffset(of needle: String, in source: String) -> Int {
        (source as NSString).range(of: needle).location
    }

    /// **Plain prose is the identity, at EVERY offset** — the Sherlock shape
    /// (her report's note), a trailing newline and blank lines included.
    @Test func plainProseMapsEveryOffsetToItself() {
        for source in [
            "To Sherlock Holmes she is always the woman.\n",
            "A\n\n\nB\n\nC",
            "one line",
            "“Curly quotes,” an em dash — and an emoji 🔍 in it.",
        ] {
            let units = source.utf16.count
            for offset in 0...units {
                // An offset inside a surrogate pair is not a display offset
                // any surface can produce; skip it.
                let ns = source as NSString
                if offset > 0, offset < units,
                   UTF16.isTrailSurrogate(ns.character(at: offset)) { continue }
                #expect(MarkdownRendering.sourceOffset(forDisplayOffset: offset, in: source) == offset,
                        "identity at \(offset) of \(source.debugDescription)")
            }
        }
    }

    /// Emphasis: a caret shown just before a word lands just before it —
    /// INSIDE the opening marker; after the word, after its closing marker.
    @Test func aWordInsideMarkersMapsInsideThem() {
        let source = "Some **bold** words and _italic_ ones."
        #expect(MarkdownRendering.sourceOffset(
            forDisplayOffset: displayOffset(of: "bold", in: source), in: source)
            == sourceOffset(of: "bold", in: source))
        #expect(MarkdownRendering.sourceOffset(
            forDisplayOffset: displayOffset(of: " words", in: source), in: source)
            == sourceOffset(of: " words", in: source), "after the closing ** — before the space")
        #expect(MarkdownRendering.sourceOffset(
            forDisplayOffset: displayOffset(of: "talic", in: source), in: source)
            == sourceOffset(of: "talic", in: source), "a mid-word caret, one to one")
        #expect(MarkdownRendering.sourceOffset(
            forDisplayOffset: displayOffset(of: "Some", in: source), in: source) == 0)
    }

    /// Line leads: a heading's hidden `#` run, a bullet's substituted lead.
    @Test func headingsAndBulletsMapPastTheirLeads() {
        let heading = "## A Title\nBody text here."
        #expect(MarkdownRendering.sourceOffset(forDisplayOffset: 0, in: heading) == 3,
                "the display's first character is the title's — after '## '")
        #expect(MarkdownRendering.sourceOffset(
            forDisplayOffset: displayOffset(of: "Body", in: heading), in: heading)
            == sourceOffset(of: "Body", in: heading), "the next line, one to one")

        let bullets = "- first item\n- second item"
        #expect(MarkdownRendering.sourceOffset(
            forDisplayOffset: displayOffset(of: "second", in: bullets), in: bullets)
            == sourceOffset(of: "second", in: bullets))
        #expect(MarkdownRendering.sourceOffset(
            forDisplayOffset: displayOffset(of: "item", in: bullets), in: bullets)
            == sourceOffset(of: "item", in: bullets))
    }

    /// A link shows its label; a caret in the label lands in the label.
    @Test func aLinkLabelMapsIntoTheLabel() {
        let source = "See [the docs](https://example.com) for more."
        #expect(MarkdownRendering.sourceOffset(
            forDisplayOffset: displayOffset(of: "docs", in: source), in: source)
            == sourceOffset(of: "docs", in: source))
        #expect(MarkdownRendering.sourceOffset(
            forDisplayOffset: displayOffset(of: " for", in: source), in: source)
            == sourceOffset(of: " for", in: source), "after the whole link syntax")
    }

    /// The edges: the end, past the end, an empty text, negative input.
    @Test func theEdgesClampToTheText() {
        let source = "**x** y"
        let display = MarkdownRendering.render(source).text.utf16.count
        #expect(MarkdownRendering.sourceOffset(forDisplayOffset: display, in: source)
                == source.utf16.count)
        #expect(MarkdownRendering.sourceOffset(forDisplayOffset: display + 40, in: source)
                == source.utf16.count)
        #expect(MarkdownRendering.sourceOffset(forDisplayOffset: -3, in: source) == 2,
                "clamped to the display's start, which lands after the opening **")
        #expect(MarkdownRendering.sourceOffset(forDisplayOffset: 5, in: "") == 0)
    }

    /// `render` itself is byte-unchanged by the walk being factored out: the
    /// display and the per-line ranges still tile the text, terminators
    /// included (the suite beside this one pins the transform's content).
    @Test func theSharedWalkStillTilesTheDisplay() {
        let source = "# Head\n\n- a **b**\nplain\r\nend"
        let rendered = MarkdownRendering.render(source)
        var cursor = 0
        for line in rendered.lines {
            #expect(line.range.lowerBound >= cursor)
            cursor = line.range.upperBound
        }
        #expect(cursor <= rendered.text.utf16.count)
        #expect(rendered.text == "Head\n\n\u{2022} a b\nplain\r\nend")
    }
}
