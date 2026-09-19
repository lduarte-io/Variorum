//
//  MarkdownReadingFace.swift
//  Variorum
//
//  Phase 13u3, UNIT F — the READING FACE's attributed half, hoisted so the
//  app has ONE of it.
//
//  **Two faces, one vocabulary (13g, her rulings F-1/F-2/F-5).** The EDITING
//  face is `MarkdownStyling` → `Shared/MarkdownFace` — display == stored byte
//  for byte, markers dimmed but present, because every editing gesture maps a
//  click to a text offset. The READING face is `MarkdownRendering` (core, pure)
//  — markers HIDDEN, leads substituted, display ≠ stored — which her surface
//  rule permits exactly where no gesture maps a click to an offset. That
//  transform has always returned display text + semantic runs + line styles and
//  deliberately no fonts; THIS file is the other end of it: the one place that
//  turns those runs into AppKit attributes.
//
//  **Why it exists (what this hoist fixed).** That translation lived privately
//  inside `PageComposer` (`Features/BookView/PagePaginator.swift`), so the PDF
//  exporter — the one surface with even less gesture than a reading page —
//  could not reach it and drew the stored characters verbatim: her item 16,
//  *"the export as pdf is not rendering the markdown formatting you just see
//  the markdown in the text."* Moving it here is the whole of that fix; the
//  paged reader's behaviour is byte-unchanged and its pins say so.
//
//  **No second parser, no second vocabulary.** Nothing here tokenizes: every
//  decision arrives as a `MarkdownRendering.Run` or `.Line`. And the two font
//  rules a reading surface needs — a heading's size and a trait union — are
//  `MarkdownFace`'s own (`headingFont`, `adding`), the same functions the
//  editing face calls, so the two faces can never disagree about how big an
//  `##` is. (They agreed by coincidence before this: the same 1.6/1.35/1.15
//  scales were written out twice.)
//
//  **Values, never literals (P-8).** Every colour and font arrives in `Style`
//  from the surface: the page passes the voice's ink and the code chip's tint;
//  the PDF passes paper's black and no chip. A `nil` `codeTint` means the chip
//  is not drawn — the run is still monospaced, which is what makes code read.
//

import AppKit
import Foundation
import VariorumCore

nonisolated enum MarkdownReadingFace {
    /// What a surface tells the face about itself.
    struct Style: Equatable {
        /// The prose font every other size is derived from.
        var body: NSFont
        /// The surface's line spacing — a heading's space above is twice it.
        /// Zero is legal and means "add no vertical rhythm of your own" (the
        /// PDF: its paragraph spacing is the stored blank lines', and
        /// typography is 13m's).
        var lineSpacing: CGFloat
        /// The prose ink, which a strikethrough's rule also wears.
        var ink: NSColor
        /// A link's TEXT colour. A screen gives it the system link colour; a
        /// page of paper gives it the ink and keeps the underline, which is
        /// print's own affordance (a PDF carries no link annotations).
        var link: NSColor
        /// The inline-code chip (13k K10). `nil` ⇒ monospace with no tint.
        var codeTint: NSColor?
    }

    // MARK: - The whole-source door

    /// `source` rendered for reading and returned as attributed text: the
    /// display string (markers hidden — `MarkdownRendering`'s job) carrying
    /// `style`'s base attributes with the face written on top.
    ///
    /// Used by surfaces that draw ONE string with no chrome of their own (the
    /// PDF export). The paged reader composes several blocks with titles,
    /// callout indents and a block map between them, so it renders per block
    /// and calls the two appliers below directly — the transform is
    /// line-scoped, so the two roads produce the same face.
    static func attributed(_ source: String, style: Style) -> NSAttributedString {
        let rendered = MarkdownRendering.render(source)
        var attributes: [NSAttributedString.Key: Any] = [
            .font: style.body, .foregroundColor: style.ink,
        ]
        if style.lineSpacing > 0 {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = style.lineSpacing
            paragraph.paragraphSpacing = style.lineSpacing
            attributes[.paragraphStyle] = paragraph
        }
        let string = NSMutableAttributedString(string: rendered.text, attributes: attributes)
        // Paragraph facts first, then the character runs on top, so a bold
        // word inside a heading keeps the heading's size (the order is the
        // transform's own: a line-leading span's content CONTAINS its inline
        // spans).
        for line in rendered.lines where line.style != .body {
            applyLineStyle(
                line, to: string,
                range: NSRange(location: line.range.lowerBound, length: line.range.count),
                style: style)
        }
        for run in rendered.runs {
            applyRun(
                run, to: string,
                range: NSRange(location: run.range.lowerBound, length: run.range.count),
                style: style)
        }
        return string
    }

    // MARK: - One line, one run (the paged reader's own doors)

    /// A heading is a SIZE (F-3), a list line is a hanging indent so a wrapped
    /// item lines up under its own words. Both are paragraph facts, which is
    /// exactly how the transform models them.
    static func applyLineStyle(
        _ line: MarkdownRendering.Line, to string: NSMutableAttributedString,
        range: NSRange, style: Style
    ) {
        guard range.length > 0, range.upperBound <= string.length else { return }
        let paragraph = NSMutableParagraphStyle()
        paragraph.setParagraphStyle(
            string.attribute(.paragraphStyle, at: range.location, effectiveRange: nil)
                as? NSParagraphStyle ?? .default)
        switch line.style {
        case .body:
            return
        case .heading(let level):
            // The EDITING face's own rule, called rather than re-derived
            // (13u3 UNIT F): the same scales, the same bold union, the same
            // honest fallback when a family ships no bold.
            string.addAttribute(
                .font, value: MarkdownFace.headingFont(level: level, base: style.body),
                range: range)
            paragraph.paragraphSpacingBefore = style.lineSpacing * 2
        case .bullet, .checkbox:
            let space = (" " as NSString)
                .size(withAttributes: [.font: style.body]).width
            // 13k K8: a NESTED item sits in one step per level. The step is
            // the width of the `- ` lead the transform removed, so the surface
            // reproduces the nesting the stored text describes — and it is
            // CLAMPED (ruled) so a runaway nest cannot push words off a fixed
            // page, while the stored text stays uncapped.
            let level = min(line.indentLevel, MarkdownRendering.maxDrawnIndentLevel)
            let nest = space * 2 * CGFloat(level)
            let indent = space * 2.5
            paragraph.firstLineHeadIndent += indent + nest
            paragraph.headIndent += indent * 2 + nest
        }
        string.addAttribute(.paragraphStyle, value: paragraph, range: range)
    }

    /// One character run: bold/italic as TRAITS on whatever font the line
    /// already wears, code as monospace (plus the chip where a surface has
    /// one), strikethrough as a rule in the ink, a link's text coloured and
    /// underlined.
    static func applyRun(
        _ run: MarkdownRendering.Run, to string: NSMutableAttributedString,
        range: NSRange, style: Style
    ) {
        guard range.length > 0, range.upperBound <= string.length else { return }
        let existing = string.attribute(.font, at: range.location, effectiveRange: nil)
            as? NSFont ?? style.body
        var traits = existing.fontDescriptor.symbolicTraits
        if run.emphasis.contains(.bold) { traits.insert(.bold) }
        if run.emphasis.contains(.italic) { traits.insert(.italic) }
        if run.emphasis.contains(.code) {
            string.addAttribute(
                .font,
                value: NSFont.monospacedSystemFont(ofSize: existing.pointSize, weight: .regular),
                range: range)
            // 13k K10: the chip, hugging exactly the code run. A reading face
            // hides the backticks (F-5), so here the run IS the span — which
            // is why the editing face tints markers and this one has none to
            // tint.
            if let codeTint = style.codeTint {
                string.addAttribute(.backgroundColor, value: codeTint, range: range)
            }
        } else if traits != existing.fontDescriptor.symbolicTraits {
            // Again the editing face's own function, not a second copy of it.
            string.addAttribute(
                .font, value: MarkdownFace.adding(traits, to: existing), range: range)
        }
        if run.emphasis.contains(.strikethrough) {
            string.addAttribute(
                .strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            string.addAttribute(.strikethroughColor, value: style.ink, range: range)
        }
        if run.url != nil {
            string.addAttribute(.foregroundColor, value: style.link, range: range)
            string.addAttribute(
                .underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            string.addAttribute(.underlineColor, value: style.link, range: range)
        }
    }
}
