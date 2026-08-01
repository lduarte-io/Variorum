//
//  PagedReadView.swift
//  Variorum
//
//  READ's second face — TRUE BOOK PAGINATION (13c Batch 2C; committed scope
//  1 / ledger C1, from `notes/plans/phase-13c-uniform-page-view-brief.md`).
//  Her direction of 2026-07-23/24: Read becomes the Apple-Books/Kindle PAIR
//  of modes — **(a) vertical infinite scroll** (`ReadingFlowView`) and
//  **(b) a TWO-PAGE SPREAD of horizontal pages each holding a SET amount of
//  text, with text flowing across identical fixed pages.**
//
//  **Read is NOT editable** (her A43 ruling, and its reasoning: Read's value
//  as a distinct mode is that it is a place to just read, and true
//  pagination plus live editing is the hardest combination in the stack to
//  keep stable — TEXTKIT2 §2). R8/R23 is honored exactly: this is not an
//  editing surface, so nothing here is expected to be editable. Two
//  consequences worth naming, both good:
//
//  - there is **no NSTextView on this surface at all** — a page is a
//    `CTFrame` drawn into a view, so there is no live ring to migrate, no
//    canary to arm, no fallback to fear, and no TK2 geometry to be lied to
//    by (`PagePaginator`'s header has the argument);
//  - **the arrow keys are unconditional** here, unlike Book's (2B had to
//    withdraw them while a page held the live editor — QUESTIONS #44(d));
//    nothing on this surface ever wants an arrow key for anything else.
//
//  The bottom bar STAYS (the brief's instruction — "KEEP the bottom bar on
//  the paginated sub-mode"), and it carries the SLIDER the brief §4 designs
//  over the ESTIMATED page domain. That is deliberately different from Book,
//  where 2B removed the slider on its own brief's instruction and flagged it
//  as QUESTIONS #44(c) — so whichever way she rules, one of the two surfaces
//  already shows her the answer she is choosing between.
//

import AppKit
import CoreText
import SwiftUI
import VariorumCore

struct PagedReadView: View {
    let session: AppSession
    let model: BookViewModel
    let structure: BookStructureModel

    @State private var pages: PagedReadModel
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(session: AppSession, model: BookViewModel, structure: BookStructureModel) {
        self.session = session
        self.model = model
        self.structure = structure
        _pages = State(initialValue: PagedReadModel(session: session))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    private var page: ReadingPageTokens { scheme == .dark ? .dark : .light }
    private var appearance: PagedReadModel.PageAppearance {
        PagedReadModel.PageAppearance(
            ink: NSColor(page.ink), chapterInk: NSColor(page.chapterInk),
            meta: NSColor(page.pageMeta))
    }

    /// Which posts OPEN a chapter — the only structural input pagination
    /// takes. The grouping itself is `BookStructureModel.grouped`, rendered
    /// here and never re-decided (the standing rule for every book surface).
    private var chapterOpeners: [String: String] {
        guard structure.chaptersActive else { return [:] }
        var openers: [String: String] = [:]
        for group in structure.grouped(entries: model.entries) {
            guard let section = group.section, let first = group.entries.first else { continue }
            openers[first.postID] = section.name
        }
        return openers
    }

    var body: some View {
        VStack(spacing: 0) {
            if model.entries.isEmpty {
                Spacer()
                Text("This book has no notes yet.")
                    .foregroundStyle(tokens.muted)
                Spacer()
            } else {
                spread
            }
        }
        .background(tokens.room)
        .safeAreaInset(edge: .bottom) { flipBar }
        .task {
            pages.appearance = appearance
            // 13f W21: a mode switch's landing outranks the book's focus —
            // it IS where she was in the mode she just left. `consumeReveal`
            // before `adopt` so a later delivery cannot re-land it.
            let landing = model.pendingReveal
            if landing != nil { model.consumeReveal() }
            pages.seed(fromFocus: landing ?? model.focusedPostID)
            await pages.adopt(entries: model.entries, chapterOpeners: chapterOpeners)
            model.notePagedAnchor(pages.currentPostID)
        }
        // 13f W21: a reveal arriving while Pages is already on screen.
        .onChange(of: model.pendingReveal) { _, reveal in
            guard let reveal else { return }
            model.consumeReveal()
            pages.showPost(reveal)
        }
        // 13f W21 — THE REPORT, not a decision: the paginated reader owns
        // its own model, so its (post, page-in-post) address has to travel
        // one step to be readable by the carry. Leaving Read ▸ Pages then
        // lands the next mode on the post she was actually reading.
        .onChange(of: pages.currentPostID) { _, postID in
            model.notePagedAnchor(postID)
        }
        .onChange(of: model.entries.map(\.postID)) { _, _ in
            Task { await pages.adopt(entries: model.entries, chapterOpeners: chapterOpeners) }
        }
        .onChange(of: scheme) { _, _ in pages.appearance = appearance }
        // The navigator's post rows jump this surface too (2B's rule: a post
        // already on the spread is left where it is).
        .onChange(of: model.focusedPostID) { _, focused in
            if let focused { pages.showPost(focused) }
        }
        .overlay(alignment: .bottom) {
            if let error = pages.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
    }

    // MARK: - The spread (two leaves of paper)

    private var spread: some View {
        GeometryReader { proxy in
            let scale = pages.geometry.spreadScale(
                in: CGSize(width: proxy.size.width - 48, height: proxy.size.height - 32),
                spine: 18)
            HStack(spacing: 18) {
                ForEach(Array(pages.leaves.enumerated()), id: \.offset) { _, leaf in
                    PageLeafView(
                        leaf: leaf, geometry: pages.geometry, scale: scale,
                        page: page, appearance: appearance,
                        dark: scheme == .dark)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - The bottom bar (KEPT by the brief; the slider is the brief's)

    @ViewBuilder
    private var flipBar: some View {
        if !model.entries.isEmpty {
            HStack(spacing: 10) {
                Button("◀") { pages.turn(by: -2) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    .disabled(!pages.canTurn(by: -2))
                    .help("Turn the leaf back — two pages (←)")
                Slider(
                    value: Binding(
                        get: { pages.scrubFraction },
                        set: { pages.scrub(fraction: $0) }),
                    in: 0...1)
                    .frame(minWidth: 120, maxWidth: 460)
                    .help("Scrub through the book — the page domain is estimated "
                        + "until a page has been read")
                Button("▶") { pages.turn(by: 2) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .disabled(!pages.canTurn(by: 2))
                    .help("Turn the leaf on — two pages (→)")
                Spacer(minLength: 12)
                Text(tokens.chromeLabel(pages.pageLine))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.bar)
        }
    }
}

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
private struct PageLeafView: View {
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
private struct PageFrameView: NSViewRepresentable {
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
