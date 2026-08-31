//
//  FlowParagraph.swift
//  Variorum (Mac) — Core/Views (the shared Mac-chrome home)
//
//  HOISTED from Features/BookView/ReadingFlowView.swift at pre-13u Act 10
//  wave 2c (the hoist-at-next-touch rule, CLAUDE.md): the note READ mode
//  (item 16, W8-1 direction B) is this brain's second consumer, so it
//  moves to the shared home — the address changed, not a byte of the
//  behavior; ReadRenderingTests/FormattingSurfacesTests ride unmodified.
//  (The PHONE keeps its deliberate MIRROR in MobileReadPage.swift — that
//  fork is recorded there and in the forked-brains KnownIssues row; this
//  hoist is Mac-side sharing only and changes nothing about it.)
//

import SwiftUI
import VariorumCore

/// One display line of a post, ready for `Text`. Built from the pure
/// transform, so nothing about markdown is decided here.
struct FlowParagraph: Equatable {
    var text: AttributedString
    var style: MarkdownRendering.LineStyle
    /// 13k K8: the list line's nesting level (0 elsewhere) — the leading
    /// whitespace is gone from `text`, so the level is how the row knows to
    /// sit in.
    var indentLevel: Int = 0

    /// The flow's own paragraph rule, unchanged from before this batch:
    /// blank display lines are DROPPED (the surface has its own spacing —
    /// the paged reader is the face that keeps stored spacing byte for
    /// byte). What is new is that each surviving line arrives rendered.
    /// `codeTint` is 13k K10's chip; nil (the default) keeps every existing
    /// caller and pin composing exactly as it did.
    static func paragraphs(of source: String, codeTint: Color? = nil) -> [FlowParagraph] {
        let rendered = MarkdownRendering.render(source)
        let ns = rendered.text as NSString
        var result: [FlowParagraph] = []
        for line in rendered.lines {
            let raw = ns.substring(
                with: NSRange(location: line.range.lowerBound, length: line.range.count))
            guard !raw.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            // Built by CONCATENATION rather than by indexing into an
            // existing string: the runs are ascending and disjoint (the
            // transform's pinned property), so walking them is exact, and no
            // `AttributedString.Index` arithmetic can drift against UTF-16
            // offsets that came from somewhere else.
            var attributed = AttributedString()
            var cursor = line.range.lowerBound
            for run in rendered.runs
            where run.range.lowerBound >= line.range.lowerBound
                && run.range.upperBound <= line.range.upperBound {
                if run.range.lowerBound > cursor {
                    attributed += AttributedString(ns.substring(with: NSRange(
                        location: cursor, length: run.range.lowerBound - cursor)))
                }
                attributed += AttributedString(
                    ns.substring(with: NSRange(
                        location: run.range.lowerBound, length: run.range.count)),
                    attributes: container(for: run, codeTint: codeTint))
                cursor = run.range.upperBound
            }
            if cursor < line.range.upperBound {
                attributed += AttributedString(ns.substring(with: NSRange(
                    location: cursor, length: line.range.upperBound - cursor)))
            }
            result.append(FlowParagraph(
                text: attributed, style: line.style, indentLevel: line.indentLevel))
        }
        return result
    }

    private static func container(
        for run: MarkdownRendering.Run, codeTint: Color? = nil
    ) -> AttributeContainer {
        var attributes = AttributeContainer()
        var intent: InlinePresentationIntent = []
        if run.emphasis.contains(.bold) { intent.insert(.stronglyEmphasized) }
        if run.emphasis.contains(.italic) { intent.insert(.emphasized) }
        if run.emphasis.contains(.strikethrough) { intent.insert(.strikethrough) }
        if run.emphasis.contains(.code) {
            intent.insert(.code)
            // The chip, hugging exactly the run — Read hides the backticks,
            // so here the run IS the span (13k K10).
            if let codeTint { attributes.backgroundColor = codeTint }
        }
        if !intent.isEmpty { attributes.inlinePresentationIntent = intent }
        // SwiftUI renders a `.link` attribute as a clickable link and routes
        // the click through the environment's `OpenURLAction` — which is
        // where the scheme guard sits. An address the guard refuses simply
        // carries no link attribute at all, so it reads (and behaves) as
        // ordinary text.
        if let raw = run.url, let url = MarkdownLink.openable(raw) { attributes.link = url }
        return attributes
    }

    func font(_ page: ReadingPageTokens) -> Font {
        switch style {
        case .heading(let level):
            let scale: CGFloat = level == 1 ? 1.6 : (level == 2 ? 1.35 : 1.15)
            return .system(size: (15 * scale).rounded(), weight: .semibold, design: .serif)
        case .body, .bullet, .checkbox:
            return page.serif
        }
    }

    /// A list line sits in a little, so a list reads as a list — and one
    /// step further per NESTING level (13k K8), clamped like the paged
    /// reader's so a runaway nest cannot walk off the page.
    var indent: CGFloat {
        switch style {
        case .bullet, .checkbox:
            16 + 16 * CGFloat(min(indentLevel, MarkdownRendering.maxDrawnIndentLevel))
        case .body, .heading: 0
        }
    }
}
