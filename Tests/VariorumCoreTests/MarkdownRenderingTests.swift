import Foundation
import Testing
@testable import VariorumCore

/// The display substring a run covers — so a pin can name the WORDS it means
/// instead of counting characters.
private func text(_ run: MarkdownRendering.Run, in rendered: MarkdownRendering.Rendered) -> String {
    (rendered.text as NSString).substring(
        with: NSRange(location: run.range.lowerBound, length: run.range.count))
}

private func text(_ line: MarkdownRendering.Line, in rendered: MarkdownRendering.Rendered) -> String {
    (rendered.text as NSString).substring(
        with: NSRange(location: line.range.lowerBound, length: line.range.count))
}

@Suite("MarkdownRendering (13g batch 4, L11 — the reading transform)")
struct MarkdownRenderingTests {

    // MARK: - The headline property

    /// **Prose with no markdown renders BYTE-IDENTICALLY**, spacing and all.
    /// The transform is a reading of the text, not a rewriting of it: if the
    /// author never typed a marker, a reading surface shows exactly the
    /// stored characters — which is also what keeps the paged reader's page
    /// arithmetic recognizable against the projection it composes from.
    @Test func proseWithNoMarkdownIsUnchangedByteForByte() {
        for source in [
            "A plain paragraph that says something.",
            "A\n\n\nB\n\nC",  // the 2026-07-12 stored-spacing shapes
            "2 * 3 * 4 = 24, and a hyphen-word is a hyphen-word.",
            "an unclosed **opener stays literal, and so does `this",
            "",
        ] {
            let rendered = MarkdownRendering.render(source)
            #expect(rendered.text == source, "unchanged: \(source.debugDescription)")
            #expect(rendered.runs.isEmpty)
            #expect(rendered.lines.allSatisfy { $0.style == .body })
        }
    }

    // MARK: - The inline four

    @Test func theEmphasisFourHideTheirMarkersAndCarryTheirRun() {
        let cases: [(String, String, MarkdownRendering.Emphasis)] = [
            ("say **this** now", "say this now", .bold),
            ("say *this* now", "say this now", .italic),
            ("say ~~this~~ now", "say this now", .strikethrough),
            ("say `this` now", "say this now", .code),
        ]
        for (source, display, emphasis) in cases {
            let rendered = MarkdownRendering.render(source)
            #expect(rendered.text == display, "\(source)")
            #expect(rendered.runs.count == 1, "\(source)")
            #expect(rendered.runs.first?.emphasis == emphasis, "\(source)")
            #expect(rendered.runs.first.map { text($0, in: rendered) } == "this", "\(source)")
            #expect(rendered.runs.first?.url == nil)
        }
    }

    /// A link's whole `](url)` tail goes with its brackets, and what remains
    /// is the TEXT — carrying the address the surface opens on a plain click
    /// (F-5: Read renders fully formatted, markers hidden, plain click opens).
    @Test func aLinkShowsItsTextAndCarriesItsAddress() {
        let rendered = MarkdownRendering.render("read [the notes](https://x.test/a_(b)) later")
        #expect(rendered.text == "read the notes later")
        #expect(rendered.links.count == 1)
        let link = try! #require(rendered.links.first)
        #expect(text(link, in: rendered) == "the notes")
        // The balanced-parens URL the tokenizer already reads correctly.
        #expect(link.url == "https://x.test/a_(b)")
        #expect(link.emphasis == [])
    }

    // MARK: - The line family

    @Test func headingsBecomeALineSTYLEAndLoseTheirHashes() {
        for (source, level) in [("# One", 1), ("## Two", 2), ("### Three", 3)] {
            let rendered = MarkdownRendering.render(source)
            #expect(rendered.lines.count == 1)
            #expect(rendered.lines.first?.style == .heading(level: level), "\(source)")
            #expect(!rendered.text.contains("#"), "\(source)")
        }
        // `####` is plain text to the tokenizer, so it stays on the page.
        #expect(MarkdownRendering.render("#### Four").text == "#### Four")
    }

    /// The list LEADS are SUBSTITUTED, not merely hidden — a bullet list that
    /// rendered without bullets would read as loose lines, which is not what
    /// "fully formatted" means. (A build-time call; QUESTIONS #50.)
    @Test func listLeadsBecomeGlyphs() {
        let rendered = MarkdownRendering.render("- milk\n- [ ] eggs\n- [x] bread")
        #expect(rendered.text == "\u{2022} milk\n\u{2610} eggs\n\u{2611} bread")
        #expect(rendered.lines.map(\.style) == [
            .bullet, .checkbox(checked: false), .checkbox(checked: true),
        ])
        // Read never toggles a box — it has no editing gesture at all — so
        // the checked state is carried as DISPLAY and nothing else.
        #expect(rendered.runs.isEmpty)
    }

    @Test func aCheckboxWithNoWordsYetStillShowsItsBox() {
        let rendered = MarkdownRendering.render("- [ ]")
        #expect(rendered.text == "\u{2610}")
        #expect(rendered.lines.first?.style == .checkbox(checked: false))
    }

    /// The tokenizer's ONE nesting exception, carried through: a line-leading
    /// span's content IS inline-scanned, so a heading (or a checkbox) can
    /// hold emphasis and the transform composes both.
    @Test func aLineLeadingSpanComposesWithTheEmphasisInsideIt() {
        let heading = MarkdownRendering.render("## a **big** day")
        #expect(heading.text == "a big day")
        #expect(heading.lines.first?.style == .heading(level: 2))
        #expect(heading.runs.count == 1)
        #expect(text(heading.runs[0], in: heading) == "big")

        let task = MarkdownRendering.render("- [x] call [Ada](https://a.test)")
        #expect(task.text == "\u{2611} call Ada")
        #expect(task.lines.first?.style == .checkbox(checked: true))
        #expect(task.links.count == 1)
        #expect(text(task.links[0], in: task) == "Ada")
    }

    // MARK: - Structure

    /// Runs and lines are ABSOLUTE to the display string, ascending and
    /// disjoint, and the lines plus their terminators tile the text exactly —
    /// the properties every consumer (a paginator, an attributed-string
    /// builder) relies on without re-deriving them.
    @Test func runsAndLinesTileTheDisplayTextExactly() {
        let source = """
            # Heading with **bold**
            plain line
            - a *listed* item
            \

            last [link](https://z.test) here
            """
        let rendered = MarkdownRendering.render(source)
        let length = (rendered.text as NSString).length

        var previous = 0
        for run in rendered.runs {
            #expect(run.range.lowerBound >= previous, "runs ascend and never overlap")
            #expect(run.range.upperBound <= length)
            previous = run.range.upperBound
        }

        var cursor = 0
        for line in rendered.lines {
            #expect(line.range.lowerBound == cursor, "a line starts where the last one ended")
            #expect(line.range.upperBound <= length)
            // …plus its terminator, which the transform copies verbatim.
            cursor = line.range.upperBound
            if cursor < length {
                #expect((rendered.text as NSString).substring(
                    with: NSRange(location: cursor, length: 1)) == "\n")
                cursor += 1
            }
        }
        #expect(cursor == length, "the lines and their newlines cover the text exactly")
        #expect(rendered.lines.count == 5)
        #expect(text(rendered.lines[3], in: rendered) == "", "the blank line survives")
    }

    /// Offsets are UTF-16 and never split a grapheme — the structural API's
    /// unit, kept across a transform that DELETES characters (which is the
    /// one place an off-by-a-surrogate would hide).
    @Test func offsetsSurviveGraphemesWiderThanOne() {
        let rendered = MarkdownRendering.render("🇯🇵 **héllo👩‍👩‍👧‍👦** 🇯🇵")
        #expect(rendered.text == "🇯🇵 héllo👩‍👩‍👧‍👦 🇯🇵")
        #expect(rendered.runs.count == 1)
        #expect(text(rendered.runs[0], in: rendered) == "héllo👩‍👩‍👧‍👦")
        let length = (rendered.text as NSString).length
        #expect(rendered.lines.first?.range == 0..<length)
    }

    /// A span never crosses a newline (the tokenizer's law), so neither does
    /// anything this produces: the same markers on two lines are two spans,
    /// and markers that would only pair ACROSS a break stay literal.
    @Test func nothingCrossesALineBreak() {
        let paired = MarkdownRendering.render("**one**\n**two**")
        #expect(paired.text == "one\ntwo")
        #expect(paired.runs.count == 2)
        #expect(paired.runs.allSatisfy { $0.emphasis == .bold })

        let straddling = MarkdownRendering.render("**one\ntwo**")
        #expect(straddling.text == "**one\ntwo**", "literal on both lines")
        #expect(straddling.runs.isEmpty)
    }

    /// **UPDATED BY 13k K8, deliberately and on the record.** This read
    /// "an indented list item is not styled in v1, the known limitation
    /// nested lists will need her word to change" — she gave that word, and
    /// the tokenizer's column-0 law was widened for LIST leads only. So an
    /// indented `- ` is a nested bullet now (its spaces substituted away with
    /// the rest of the lead, the level carried on the line), and an indented
    /// `# ` is STILL plain text — which is the half of the old claim that
    /// survives, and the reason this pin keeps both lines.
    @Test func anIndentedLIST_leadIsALeadNowAndAnIndentedHeadingIsStillNot() {
        let rendered = MarkdownRendering.render("  - indented\n  # not a heading")
        #expect(rendered.text == "\u{2022} indented\n  # not a heading")
        #expect(rendered.lines.map(\.style) == [.bullet, .body])
        #expect(rendered.lines.map(\.indentLevel) == [1, 0])
    }
}
