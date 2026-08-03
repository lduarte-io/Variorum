//
//  MobileReadPage.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M8/LK9) — the Read flow's PURE brains: the
//  per-line reading transform and the LK9 chrome strings (chapter caption
//  + centered page meta). Sibling types beside the view; nothing here
//  touches a store or a view.
//
//  THE PARAGRAPH TRANSFORM is a deliberate MIRROR of the Mac's
//  `FlowParagraph` (ReadingFlowView.swift) over the ONE shared law
//  (`MarkdownRendering.render`, core Domain) — the `MobileShelfFaces`
//  precedent: mirror the SEMANTICS, never port the chrome. Mirrored
//  exactly: blank display lines DROP (the flow's own paragraph rule — the
//  paged reader is the face that keeps stored spacing byte for byte);
//  composition walks the transform's ascending/disjoint runs by
//  CONCATENATION (no AttributedString.Index arithmetic against UTF-16
//  offsets); bold/italic/strikethrough/code map to inline presentation
//  intents; the code run wears the reading page's own chip (13k K10 — the
//  page is voice-independent, R2); links carry `.link` ONLY where the
//  openable guard passes (inert addresses read as plain text); list lines
//  sit in per nesting level, drawn-clamped (13k K8). Drift risk recorded
//  for the ladder: a Mac-side change to FlowParagraph does not compile
//  into this file — the pins hold the mirror to the shared law's output.
//
//  THE LINK GUARD mirrors `MarkdownLink.openable` (Mac-side, AppKit file —
//  its rule is pure and tiny): http/https only, trimmed, host required.
//  Inert links render as ordinary text; SwiftUI's default OpenURLAction
//  opens the ones that carry the attribute (only openable ones do).
//
//  CALLOUT FRAMES deliberately do NOT render here — the Mac's own Read
//  flow renders none (renderPost → joinRenderedTexts carries no
//  presentation), and M12's "frames render on the page" is the WRITE
//  page's rule. Mirrored, recorded.
//

import Foundation
import SwiftUI
import VariorumCore

nonisolated enum MobileReadPage {
    // MARK: - The per-line reading transform (the FlowParagraph mirror)

    struct Paragraph: Equatable {
        var text: AttributedString
        var style: MarkdownRendering.LineStyle
        var indentLevel: Int = 0

        /// The line's font on the reading page — the Mac flow's own scale
        /// shape at the page's serif size.
        func font(_ page: ReadingPageTokens) -> Font {
            switch style {
            case .heading(let level):
                let scale: CGFloat = level == 1 ? 1.6 : (level == 2 ? 1.35 : 1.15)
                return .system(size: (16 * scale).rounded(), weight: .semibold, design: .serif)
            case .body, .bullet, .checkbox:
                return page.serif
            }
        }

        /// A list line sits in a little, one step per nesting level,
        /// drawn-clamped (13k K8 — the Mac flow's exact rule).
        var indent: CGFloat {
            switch style {
            case .bullet, .checkbox:
                16 + 16 * CGFloat(min(indentLevel, MarkdownRendering.maxDrawnIndentLevel))
            case .body, .heading: 0
            }
        }
    }

    /// Rendered display lines of one note's rendered text. Blank display
    /// lines drop (the flow's paragraph rule); every surviving line
    /// arrives with its markdown applied and markers hidden (Read is a
    /// reading surface — the F-5 rule).
    static func paragraphs(of source: String, codeTint: Color? = nil) -> [Paragraph] {
        let rendered = MarkdownRendering.render(source)
        let ns = rendered.text as NSString
        var result: [Paragraph] = []
        for line in rendered.lines {
            let raw = ns.substring(
                with: NSRange(location: line.range.lowerBound, length: line.range.count))
            guard !raw.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
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
            result.append(Paragraph(
                text: attributed, style: line.style, indentLevel: line.indentLevel))
        }
        return result
    }

    private static func container(
        for run: MarkdownRendering.Run, codeTint: Color?
    ) -> AttributeContainer {
        var attributes = AttributeContainer()
        var intent: InlinePresentationIntent = []
        if run.emphasis.contains(.bold) { intent.insert(.stronglyEmphasized) }
        if run.emphasis.contains(.italic) { intent.insert(.emphasized) }
        if run.emphasis.contains(.strikethrough) { intent.insert(.strikethrough) }
        if run.emphasis.contains(.code) {
            intent.insert(.code)
            if let codeTint { attributes.backgroundColor = codeTint }
        }
        if !intent.isEmpty { attributes.inlinePresentationIntent = intent }
        if let raw = run.url, let url = openableLink(raw) { attributes.link = url }
        return attributes
    }

    /// The link guard — `MarkdownLink.openable`'s rule, mirrored (http/
    /// https only, trimmed, host required). An address the guard refuses
    /// carries no `.link` attribute and reads as ordinary text.
    static let openableSchemes: Set<String> = ["http", "https"]

    static func openableLink(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              openableSchemes.contains(scheme),
              url.host?.isEmpty == false
        else { return nil }
        return url
    }

    // MARK: - LK9's chrome strings (chapter caption + centered page meta)

    /// Lowercase roman numerals for chapter positions ("the mockup's
    /// 'note 3 of 9 · ii'"). 0 or negative reads empty (no chapter).
    static func roman(_ value: Int) -> String {
        guard value > 0 else { return "" }
        let table: [(Int, String)] = [
            (1000, "m"), (900, "cm"), (500, "d"), (400, "cd"),
            (100, "c"), (90, "xc"), (50, "l"), (40, "xl"),
            (10, "x"), (9, "ix"), (5, "v"), (4, "iv"), (1, "i"),
        ]
        var remainder = value
        var result = ""
        for (amount, glyph) in table {
            while remainder >= amount {
                result += glyph
                remainder -= amount
            }
        }
        return result
    }

    /// The chapter caption over a chapter's first note — the ratified
    /// LK9 frame's "II · THE LONG FIELD" (roman uppercased · the chapter
    /// name's LEAF, uppercased — the K3 leaf doctrine rides section paths
    /// exactly as the book list's headers do).
    static func chapterCaption(index: Int, name: String) -> String {
        let leaf = MobileShelfFaces.leaf(name).uppercased()
        let numeral = roman(index).uppercased()
        return numeral.isEmpty ? leaf : "\(numeral) · \(leaf)"
    }

    /// The centered page meta under every note — "note 3 of 9 · ii";
    /// unsectioned notes carry no chapter numeral. Under the bounded
    /// window's truncation the total is a FLOOR, and the meta says so —
    /// "note 3 of 300+" — never a silent window-as-book (S4 ladder
    /// NIT 2; the true membership count has no standing corpus-flat
    /// read for smart books, so the honest floor is the fix).
    static func pageMeta(
        ordinal: Int, total: Int, chapterIndex: Int?, truncated: Bool = false
    ) -> String {
        let base = "note \(ordinal) of \(total)\(truncated ? "+" : "")"
        guard let chapterIndex, chapterIndex > 0 else { return base }
        return "\(base) · \(roman(chapterIndex))"
    }

    // MARK: - The page assembly (the column's shape, pure)

    struct NoteSlot: Equatable {
        let entry: Queries.ReadingEntry
        /// 1-based across the whole book's window.
        let ordinal: Int
        /// 1-based among SECTIONED chapters in book order; nil unsectioned.
        let chapterIndex: Int?
    }

    struct Chapter: Equatable {
        /// The LK9 caption over the chapter's first note; nil for
        /// unsectioned runs (no header — the book list's own rule).
        let caption: String?
        let notes: [NoteSlot]
    }

    /// The continuous column's shape from the book's grouped assembly
    /// (`MobileBookViewModel.grouped` — the S3 brain, reused): captions at
    /// chapter transitions exactly where the book's order puts them,
    /// ordinals across the whole window, chapter numerals in encounter
    /// order (order-derived — a section name recurring non-adjacently
    /// counts again, deliberately: the column reads top to bottom).
    static func assemble(
        _ groups: [(section: String?, entries: [Queries.ReadingEntry])]
    ) -> [Chapter] {
        var chapters: [Chapter] = []
        var ordinal = 0
        var chapterCounter = 0
        for group in groups {
            let index: Int?
            let caption: String?
            if let section = group.section {
                chapterCounter += 1
                index = chapterCounter
                caption = chapterCaption(index: chapterCounter, name: section)
            } else {
                index = nil
                caption = nil
            }
            let notes = group.entries.map { entry -> NoteSlot in
                ordinal += 1
                return NoteSlot(entry: entry, ordinal: ordinal, chapterIndex: index)
            }
            chapters.append(Chapter(caption: caption, notes: notes))
        }
        return chapters
    }
}
