//
//  FlowParagraph.swift
//  Variorum — App/Variorum/Shared (BOTH platforms)
//
//  HOISTED HERE at 13u1 UNIT 1 (the 2026-08-30 tech-debt sweep's **P41**).
//  It lived Mac-app-local — `Features/BookView/ReadingFlowView.swift`, then
//  `Core/Views/` at pre-13u Act 10 wave 2c — while the phone carried a
//  byte-identical MIRROR in `MobileReadPage.swift` whose own header recorded
//  the fork and the drift risk out loud: *"a Mac-side change to
//  FlowParagraph does not compile into this file."* That is MobileSoul §3's
//  drift class, and `KnownIssuesAndTechDebt.md`'s forked-brain row says the
//  fix is always a HOIST, never a patch.
//
//  **What moved and what did NOT.** The paragraph TRANSFORM moved — the
//  blank-line drop, the concatenation walk over the transform's ascending
//  disjoint runs, the emphasis→`InlinePresentationIntent` mapping, the code
//  chip, the link guard's application, and the drawn-clamped list indent.
//  `font(_:)` did NOT: the two platforms deliberately disagree about its
//  base size (15 pt on the Mac, 16 pt on the phone — phone type is bigger),
//  so each target adds its own extension. That is the hoist rule read
//  correctly: the BRAIN is shared, the FACE is not.
//
//  The hoist's proof is that both platforms' pins ride UNMODIFIED — the 3C
//  parity pattern, a zero-test-edit suite on both sides.
//

import SwiftUI
import VariorumCore

/// One display line of a post, ready for `Text`. Built from the pure
/// transform, so nothing about markdown is decided here.
nonisolated struct FlowParagraph: Equatable {
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
