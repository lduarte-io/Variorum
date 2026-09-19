//
//  PDFExporter.swift
//  Variorum
//
//  Phase 11b, Step B1 — basic PDF via the attributed-string path (the
//  ratified two-tier sharing: .md + basic PDF for humans without the app;
//  typographic polish is explicitly Phase 13's; the full-fidelity
//  "variorum edition" bundle is Phase 14's). Pure function: projection
//  string in, PDF bytes out — CTFramesetter paginates the attributed
//  string onto US-Letter pages. No panels, no I/O, no store access here.
//
//  **13u3 UNIT F (master-plan item 16) — THE PAGE READS THE MARKDOWN NOW.**
//  Her report: *"the export as pdf is not rendering the markdown formatting
//  you just see the markdown in the text and that should be fixed at some
//  point pre v1 release."* The 11b path predates 13g's markdown-as-content
//  by a phase, so it appended the projection verbatim under one system font
//  and CoreText drew every `**` she had typed.
//
//  The fix is a PROJECTION change on this medium alone: the body goes
//  through the app's OWN reading transform (`MarkdownRendering`, core, pure)
//  and the attributed face the paged reader draws with
//  (`Theme/MarkdownReadingFace`). No parser lives here, no formatting rule
//  is invented here, and whatever the display brain does not style, this
//  page does not style. What is NOT touched: `Queries.renderedText`, the
//  `.md` export projections, the callout→blockquote mapping (its `> ` leads
//  are not in F-3's vocabulary, so they reach the page as the text they
//  are), the fan's "Alternates" shape, and the FONTS — the typographic pass
//  is still 13m's, so this is the same 12 pt system body it has always been
//  with the face on top.
//
//  **A page is paper, not a screen — so it writes NO COLOUR AT ALL.** A
//  dynamic colour would resolve against whatever appearance the app happened
//  to wear when she hit Save, and a PDF written in dark mode would arrive
//  white on white paper; a literal `NSColor.black` would dodge that and trip
//  18j's grep pin, correctly, because a literal is not the answer either.
//  The answer is that a page with no colour attribute cannot depend on an
//  appearance in the first place: the ink is the PDF context's own black,
//  exactly as it has been since 11b. A link is therefore that ink under a
//  rule — print's own affordance, and a PDF carries no link annotations
//  anyway. `PDFExportFaceTests` pins the absence.
//

import AppKit
import CoreText
import Foundation

enum PDFExporter {
    /// US Letter, 1-inch margins — the unstyled functional default.
    private static let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
    private static let contentRect = pageRect.insetBy(dx: 72, dy: 72)

    /// The two fonts the 11b page has always used, NAMED (13u3 UNIT F) so the
    /// face below and its pins scale off the same base the page draws with.
    /// The VALUES are untouched — the typographic pass is still 13m's.
    static let bodyFont = NSFont.systemFont(ofSize: 12)
    static let titleFont = NSFont.boldSystemFont(ofSize: 16)

    /// Paper's own values (see the header): NO colour — neither ink nor link
    /// — no code chip, and no vertical rhythm of the face's own, since the
    /// stored blank lines are this page's paragraph spacing exactly as they
    /// have been since 11b.
    static let paperStyle = MarkdownReadingFace.Style(
        body: bodyFont, lineSpacing: 0, ink: nil, link: nil, codeTint: nil)

    /// The exported document as attributed text: optional bold title line,
    /// then the body RENDERED FOR READING — markdown-as-content read by the
    /// app's own display brain, so the page shows the formatting rather than
    /// the syntax (13u3 UNIT F, item 16).
    ///
    /// The TITLE is not markdown and is never read as any: it is a stored
    /// name, shown the way the masthead shows it. (A book's own `# <name>`
    /// travels inside the body, where it IS a heading and renders as one.)
    static func attributedDocument(title: String?, body: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        if let title, !title.isEmpty {
            result.append(NSAttributedString(
                string: "\(title)\n\n",
                attributes: [.font: titleFont]))
        }
        result.append(MarkdownReadingFace.attributed(body, style: paperStyle))
        return result
    }

    /// Paginates the document into PDF data. Always emits at least one page
    /// (an empty post exports an empty page, not zero bytes). Each frame
    /// consumes at least one character, so pagination always terminates.
    static func pdfData(title: String?, body: String) -> Data {
        let document = attributedDocument(title: title, body: body)
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data as CFMutableData) else {
            return Data()
        }
        var mediaBox = pageRect
        var auxiliary: [CFString: Any] = [kCGPDFContextCreator: "Variorum"]
        if let title, !title.isEmpty {
            auxiliary[kCGPDFContextTitle] = title
        }
        guard let context = CGContext(
            consumer: consumer, mediaBox: &mediaBox, auxiliary as CFDictionary)
        else { return Data() }

        let framesetter = CTFramesetterCreateWithAttributedString(document)
        let path = CGPath(rect: contentRect, transform: nil)
        var location = 0
        repeat {
            context.beginPDFPage(nil)
            let frame = CTFramesetterCreateFrame(
                framesetter, CFRange(location: location, length: 0), path, nil)
            CTFrameDraw(frame, context)
            context.endPDFPage()
            let visible = CTFrameGetVisibleStringRange(frame)
            location += max(visible.length, 1)
        } while location < document.length
        context.closePDF()
        return data as Data
    }
}
