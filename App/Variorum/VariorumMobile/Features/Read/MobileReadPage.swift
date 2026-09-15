//
//  MobileReadPage.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M8/LK9) — the Read flow's PURE brains: the
//  per-line reading transform and the LK9 chrome strings (chapter caption
//  + centered page meta). Sibling types beside the view; nothing here
//  touches a store or a view.
//
//  THE PARAGRAPH TRANSFORM AND THE LINK GUARD USED TO LIVE HERE as a
//  deliberate MIRROR of the Mac's `FlowParagraph` and `MarkdownLink` —
//  statement for statement, over the ONE shared law
//  (`MarkdownRendering.render`, core Domain) — and this header recorded the
//  drift risk in its own words: *"a Mac-side change to FlowParagraph does
//  not compile into this file."* **Both HOISTED to `App/Variorum/Shared/`
//  at 13u1 UNIT 1** (the 2026-08-30 sweep's P41), so a Mac-side change now
//  compiles into this file by construction. What remains below is three
//  forwarders and the phone's own type scale; what the shared brain
//  guarantees, unchanged, is: blank display lines DROP (the flow's own
//  paragraph rule — the paged reader is the face that keeps stored spacing
//  byte for byte); composition walks the transform's ascending/disjoint runs
//  by CONCATENATION (no AttributedString.Index arithmetic against UTF-16
//  offsets); bold/italic/strikethrough/code map to inline presentation
//  intents; the code run wears the reading page's own chip (13k K10 — the
//  page is voice-independent, R2); links carry `.link` ONLY where the
//  openable guard passes (inert addresses read as plain text); list lines
//  sit in per nesting level, drawn-clamped (13k K8).
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
    // MARK: - The per-line reading transform (13u1 UNIT 1: the fork HOISTED)

    /// **The mirror is gone.** The transform and the link guard moved to
    /// `App/Variorum/Shared/` at 13u1 UNIT 1 (the 2026-08-30 sweep's P41):
    /// this file used to carry `FlowParagraph.paragraphs`/`container`/
    /// `indent` and `MarkdownLink.openable`/`openableSchemes`
    /// statement-for-statement, and its own header recorded the drift risk
    /// out loud — *"a Mac-side change to FlowParagraph does not compile into
    /// this file."* Now it does.
    ///
    /// These three are FORWARDERS, kept so every phone call site and every
    /// phone pin reads exactly as it did (the hoist's zero-test-edit proof).
    typealias Paragraph = FlowParagraph

    static func paragraphs(of source: String, codeTint: Color? = nil) -> [FlowParagraph] {
        FlowParagraph.paragraphs(of: source, codeTint: codeTint)
    }

    /// The link guard — ONE rule now, not a mirror of one.
    static var openableSchemes: Set<String> { MarkdownLink.openableSchemes }

    static func openableLink(_ raw: String) -> URL? { MarkdownLink.openable(raw) }

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

// MARK: - The phone's FACE on the shared brain (13u1 UNIT 1)

/// The reading page's type scale, which the two platforms deliberately
/// disagree about: 16 pt base here against the Mac's 15 — phone type is
/// bigger. The BRAIN is shared; the FACE is not, which is the hoist rule
/// read correctly rather than flattened.
extension FlowParagraph {
    func font(_ page: ReadingPageTokens) -> Font {
        switch style {
        case .heading(let level):
            let scale: CGFloat = level == 1 ? 1.6 : (level == 2 ? 1.35 : 1.15)
            return .system(size: (16 * scale).rounded(), weight: .semibold, design: .serif)
        case .body, .bullet, .checkbox:
            return page.serif
        }
    }
}
