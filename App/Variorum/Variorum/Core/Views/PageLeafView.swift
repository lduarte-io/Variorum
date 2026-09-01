//
//  PageLeafView.swift
//  Variorum (Mac) — Core/Views (the shared Mac-chrome home)
//
//  HOISTED from Features/BookView/PagedReadView.swift at the Act 10
//  correction round, batch C (the hoist-at-next-touch rule, CLAUDE.md):
//  the NOTE's Read mode gained a `read ▸ pages` face (R-cor-5/7 — "the
//  book's paged view reused", never a second pager), so the leaf — the
//  paper, the drawn `CTFrame`, its folio, the plain-click link door — is
//  this brain's second consumer and moves to the shared home. The address
//  changed, not a byte of the behavior; the book's `PagedReadView` composes
//  these exactly as before and its pins ride unmodified.
//

import AppKit
import CoreText
import SwiftUI
import VariorumCore

#if DEBUG
/// 13c 2C's realization pin support (the `BookSpreadMaterialization`
/// precedent, Stage 4 lesson 6): counts drawn leaves so the P3 pin can
/// assert a paginated book realizes THE SPREAD — two pages and at most two
/// posts' pagination — never the book.
@MainActor
enum PagedReadMaterialization {
    static var count = 0
}
#endif

/// One leaf: paper, the drawn page, its number. A nil leaf is the blank half
/// at the end of the book (2B's rule — a blank leaf is honest, a wrapped
/// page is a lie about where you are).
struct PageLeafView: View {
    let leaf: PagedReadModel.Leaf?
    let geometry: PageGeometry
    let scale: CGFloat
    let page: ReadingPageTokens
    let appearance: PagedReadModel.PageAppearance
    let dark: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(page.paper)
                .shadow(color: .black.opacity(dark ? 0 : 0.12), radius: 10, y: 3)
            if let leaf {
                PageFrameView(
                    frame: leaf.frame, pageNumber: leaf.pageNumber, scale: scale,
                    geometry: geometry, meta: appearance.meta, links: leaf.links)
            } else {
                Text("end of the book")
                    .font(.system(size: 11, design: .serif))
                    .foregroundStyle(page.pageMeta)
            }
        }
        .frame(width: geometry.size.width * scale, height: geometry.size.height * scale)
    }
}

/// The drawn page — a `CTFrame` and its folio, scaled from the logical page
/// onto the screen. A window resize SCALES the paper; it never repaginates
/// (the brief §7's ruling, QUESTIONS #45(d)).
struct PageFrameView: NSViewRepresentable {
    let frame: CTFrame?
    let pageNumber: Int
    let scale: CGFloat
    let geometry: PageGeometry
    let meta: NSColor
    var links: [PageLink] = []

    func makeNSView(context: Context) -> PageFrameNSView {
        #if DEBUG
        PagedReadMaterialization.count += 1
        #endif
        let view = PageFrameNSView()
        apply(to: view)
        return view
    }

    func updateNSView(_ view: PageFrameNSView, context: Context) {
        apply(to: view)
    }

    private func apply(to view: PageFrameNSView) {
        view.ctFrame = frame
        view.pageNumber = pageNumber
        view.scale = scale
        view.geometry = geometry
        view.meta = meta
        view.links = links
        view.needsDisplay = true
    }
}

/// The page's drawing surface. Deliberately NOT an NSTextView: this is the
/// exact tier's own output, drawn by the engine that computed the break.
final class PageFrameNSView: NSView {
    var ctFrame: CTFrame?
    var pageNumber = 0
    var scale: CGFloat = 1
    var geometry = PageGeometry.standard
    var meta: NSColor = .tertiaryLabelColor
    /// 13g batch 4 (L10): this post's links, in composed-string offsets.
    var links: [PageLink] = []
    /// The range this leaf draws — read by the pins, so "what is on this
    /// page" is inspectable without a text view.
    var visibleRange: NSRange {
        guard let ctFrame else { return NSRange(location: 0, length: 0) }
        let range = CTFrameGetVisibleStringRange(ctFrame)
        return NSRange(location: range.location, length: range.length)
    }

    override var isOpaque: Bool { false }

    // MARK: - L10: a PLAIN click opens a link

    /// **Read opens links on a plain click** — her ruling F-5's other half.
    /// It can, because Read has no competing gesture at all: no caret to
    /// place, no selection to drag, nothing editable. (A writing surface is
    /// the opposite, which is why ⌘-click is the gesture there.)
    ///
    /// The index comes from CoreText itself — `CTLineGetStringIndexForPosition`
    /// on the line the point landed in — so the hit test is answered by the
    /// engine that laid the page out, exactly as `PagePaginator`'s header
    /// argues page BREAKS must be.
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if let index = characterIndex(at: point),
           let link = links.first(where: {
               $0.range.location <= index && index < $0.range.upperBound
           }),
           MarkdownLink.open(link.url) {
            return
        }
        super.mouseDown(with: event)
    }

    /// The composed-string index under a point in this view's coordinates,
    /// or nil where the point is off the text. The view is unflipped, and
    /// `draw` scales by `scale` before drawing the frame — so undoing that
    /// scale puts the point in the page's own coordinate space, which is the
    /// frame's.
    func characterIndex(at point: NSPoint) -> Int? {
        guard let ctFrame, scale > 0 else { return nil }
        let inPage = CGPoint(x: point.x / scale, y: point.y / scale)
        guard let lines = CTFrameGetLines(ctFrame) as? [CTLine], !lines.isEmpty
        else { return nil }
        var origins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(ctFrame, CFRange(location: 0, length: 0), &origins)
        // **Line origins are relative to the frame path's BOUNDING BOX**, not
        // to the page — so they have to be rebased before they can be
        // compared with a point in the page's own space. (Measured, not
        // assumed: the first draft compared them directly and a click on the
        // first word resolved to the seventh character. The pin that caught
        // it asserts a point at the line's left edge lands BEFORE the link.)
        let box = CTFrameGetPath(ctFrame).boundingBoxOfPath
        for (i, line) in lines.enumerated() {
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
            let origin = CGPoint(x: origins[i].x + box.minX, y: origins[i].y + box.minY)
            let bounds = CGRect(
                x: origin.x, y: origin.y - descent, width: width, height: ascent + descent)
            guard bounds.contains(inPage) else { continue }
            let index = CTLineGetStringIndexForPosition(
                line, CGPoint(x: inPage.x - origin.x, y: 0))
            return index == kCFNotFound ? nil : index
        }
        return nil
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.saveGState()
        context.scaleBy(x: scale, y: scale)
        if let ctFrame { CTFrameDraw(ctFrame, context) }
        // The folio, in the bottom margin — a page that says which page it is.
        let folio = NSAttributedString(
            string: "\(pageNumber)",
            attributes: [
                .font: NSFont.systemFont(ofSize: 9), .foregroundColor: meta,
            ])
        let size = folio.size()
        folio.draw(at: CGPoint(
            x: (geometry.size.width - size.width) / 2,
            y: geometry.margin / 2 - size.height / 2))
        context.restoreGState()
    }
}
