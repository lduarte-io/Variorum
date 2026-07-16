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

import AppKit
import CoreText
import Foundation

enum PDFExporter {
    /// US Letter, 1-inch margins — the unstyled functional default.
    private static let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
    private static let contentRect = pageRect.insetBy(dx: 72, dy: 72)

    /// The exported document as attributed text: optional bold title line,
    /// then the body verbatim (the projection already carries the rendered
    /// joins). System fonts, zero styling investment (Phase 13 owns beauty).
    static func attributedDocument(title: String?, body: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        if let title, !title.isEmpty {
            result.append(NSAttributedString(
                string: "\(title)\n\n",
                attributes: [.font: NSFont.boldSystemFont(ofSize: 16)]))
        }
        result.append(NSAttributedString(
            string: body,
            attributes: [.font: NSFont.systemFont(ofSize: 12)]))
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
