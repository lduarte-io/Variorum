//
//  ReadTierClickPlace.swift
//  Variorum
//
//  **18l UNIT U0, item 1 — WHERE A CLICK ON A READ-CHEAP BLOCK LANDS.** Her
//  report (2026-09-25), verbatim: *"When I'm in sherlock holmes and I click on
//  top of a line of text, my cursor moves to the empty paragraph / block
//  between the text and then I have to try clicking again to get onto the
//  actual text."* — and: *"it's a refusal of clicking into the text."*
//
//  **The mechanism (traced, pinned by `IndexClickCaretTests`).** The two
//  index-like surfaces — the book Index and the note's Read ▸ edit — draw a
//  block at rest as read-cheap SwiftUI `Text` and upgrade the clicked one to
//  THE live pane (P-3). The upgrade was a bare `onTapGesture`: it knew WHICH
//  block, never WHERE. So the freshly mounted pane put its caret wherever its
//  host's rule said, not where she clicked — the book Index at the take's END
//  (`PaneCaretLanding.leave`: what `string =` left), which in her note is the
//  EMPTY line under the text, because the sample library keeps the blank line
//  between two paragraphs as CONTENT (211 of *Copper Beeches*' 212 blocks end
//  in `\n`); Read ▸ edit at the take's START (the note's entry rule). The
//  second click worked only because the pane was, by then, a real text view.
//  `PaneCaretLanding`'s own doc says *"a click always keeps the place the click
//  brought"* — true of the read panes that are TK2 surfaces (Takes, the
//  workbench), and simply unreachable from a `Text`.
//
//  **The fix: the click brings its place.** The tap reads its location, and
//  this file answers where in the STORED text that location is: it lays the
//  tapped block out again, off-screen, exactly as the read tier drew it — the
//  same display (`FlowParagraph`, markers hidden), the voice's body font, the
//  read tier's `lineSpacing(4)`, its 8-pt paragraph gap and list indents, at
//  the column's own width — asks TextKit 2's selection navigation which
//  character the point names, and carries that DISPLAY offset back to the
//  stored text through the reading transform's own walk
//  (`MarkdownRendering.sourceOffset(forDisplayOffset:in:)`). The host hands
//  the answer to the pane as its landing (`PaneCaretLanding.offset`).
//
//  **Why a replica rather than the live pane's own hit-test:** the live pane
//  lays the same take out DIFFERENTLY (its markers are shown dimmed, its lines
//  4 pt tighter, its measure narrower) — a point handed through would drift a
//  line per few lines down a long paragraph. The replica answers in the
//  geometry she actually clicked on, and the character it names is the one
//  under her pointer whatever the pane then does with it. Its agreement with
//  what SwiftUI drew is PINNED, not assumed (`IndexClickCaretTests` — the
//  replica's block height against the read tier's measured frame, both
//  voices), so a point release that moves SwiftUI's text metrics goes red.
//
//  **Known approximation, stated:** a HEADING line is measured in the body
//  font (the read tier draws it in the voice's title/heading font, which only
//  SwiftUI holds) — a click inside a heading lands on that heading's line,
//  with its x approximate; a heading-bearing multi-paragraph block stacks the
//  paragraphs under the heading a few points off. Prose, lists and emphasis
//  are measured in their drawn faces. A second assumption, named (ladder
//  round 1, NIT-1): Study's tier font is Dynamic-Type-relative
//  (`relativeTo: .body`, `VoiceTokens`) while the replica measures the fixed
//  `EditorTypography` face — the two agree at the system's DEFAULT text size
//  (dev = acceptance, today's machine), and on a system scaled away from it
//  the fidelity pin below goes red rather than clicks silently drifting.
//  Whether the tier fonts should scale at all is a look call (hers), not
//  this file's.
//
//  Cost: one block laid out, off-screen, per click (P1 — bounded by the block
//  clicked, never the note). TextKit 2 API only (TEXTKIT2 §4.2).
//

import AppKit
import SwiftUI
import VariorumCore

@MainActor
enum ReadTierClickPlace {
    /// The read tier's own metrics — what BOTH index-like read tiers draw a
    /// block with (`BookIndexPaneNote.blockView`, `ReadEditBlock`): each
    /// paragraph a `Text` with `.lineSpacing(4)`, the paragraphs 8 apart in a
    /// `VStack`. **18l-c U5: read from the tiers' ONE vocabulary**
    /// (`IndexProseColumn.lines`, where U0's two named constants were
    /// promoted — byte-same numbers), which the live pane is now handed too.
    /// (The line spacing is read where each paragraph's style is built,
    /// `ParagraphLayout`; the gap is how the paragraphs stack.)
    private static var paragraphSpacing: CGFloat { IndexProseColumn.lines.paragraphGap }

    /// Where a click lands in `source`, as a UTF-16 offset into the STORED
    /// text. `point` is in the TEXT COLUMN's own space — x from the prose's
    /// leading edge, y from the first line's top — and may fall outside it
    /// (a click in the block's padding lands on the nearest line).
    static func sourceOffset(
        at point: CGPoint, in source: String, columnWidth: CGFloat, font: NSFont
    ) -> Int {
        // One render answers both questions (which paragraphs, and where each
        // starts in the display) — one loop cannot disagree with itself about
        // which lines are paragraphs (ladder round 1, MINOR-2).
        let (paragraphs, starts) = FlowParagraph.paragraphsWithStarts(of: source)
        guard !paragraphs.isEmpty, columnWidth > 1 else { return 0 }
        var top: CGFloat = 0
        for (index, paragraph) in paragraphs.enumerated() {
            let layout = ParagraphLayout(
                paragraph, width: max(1, columnWidth - paragraph.indent), font: font)
            let bottom = top + layout.height
            let isLast = index == paragraphs.count - 1
            // In this paragraph, or in the gap under it and nearer to it than
            // to the next one — or there is no next one.
            let gapMiddle = bottom + paragraphSpacing / 2
            if point.y < gapMiddle || isLast {
                let local = CGPoint(
                    x: point.x - paragraph.indent,
                    y: min(max(point.y - top, 0), max(layout.height - 0.5, 0)))
                let display = starts[index] + layout.offset(at: local)
                return MarkdownRendering.sourceOffset(forDisplayOffset: display, in: source)
            }
            top = bottom + paragraphSpacing
        }
        return 0
    }

    /// The HEIGHT the read tier draws `source` at, laid out by the replica —
    /// the pins compare it with what SwiftUI actually drew (the replica's
    /// agreement is measured, never assumed).
    static func height(of source: String, columnWidth: CGFloat, font: NSFont) -> CGFloat {
        let paragraphs = FlowParagraph.paragraphs(of: source)
        guard !paragraphs.isEmpty else { return 0 }
        let heights = paragraphs.map {
            ParagraphLayout($0, width: max(1, columnWidth - $0.indent), font: font).height
        }
        return heights.reduce(0, +) + paragraphSpacing * CGFloat(heights.count - 1)
    }

    /// **The read tier's LINES, laid out by the replica** (18l-c U5) — each
    /// text line's top (from the block's first line, in the column's space)
    /// and where it starts in the DISPLAY text. The tiers' geometry pin
    /// (`IndexTierMetricsTests`) holds the live pane's lines against these;
    /// the replica's agreement with what SwiftUI drew is pinned beside it
    /// (the block's height, ±0.5 pt — `IndexClickCaretTests`).
    static func lines(
        of source: String, columnWidth: CGFloat, font: NSFont
    ) -> [(top: CGFloat, displayStart: Int)] {
        let (paragraphs, starts) = FlowParagraph.paragraphsWithStarts(of: source)
        var result: [(top: CGFloat, displayStart: Int)] = []
        var top: CGFloat = 0
        for (index, paragraph) in paragraphs.enumerated() {
            let layout = ParagraphLayout(
                paragraph, width: max(1, columnWidth - paragraph.indent), font: font)
            for line in layout.lines() {
                result.append((top + line.top, starts[index] + line.start))
            }
            top += layout.height + paragraphSpacing
        }
        return result
    }

    /// One read-tier paragraph, laid out off-screen the way its `Text` was.
    private struct ParagraphLayout {
        let content: NSTextContentStorage
        let manager: NSTextLayoutManager
        let height: CGFloat

        init(_ paragraph: FlowParagraph, width: CGFloat, font: NSFont) {
            let string = String(paragraph.text.characters)
            let attributed = NSMutableAttributedString(string: string)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = IndexProseColumn.lines.lineSpacing
            let whole = NSRange(location: 0, length: (string as NSString).length)
            attributed.addAttributes([.font: font, .paragraphStyle: style], range: whole)
            // The emphasis the `Text` draws in its own faces — bold, italic,
            // code — so the advances match the glyphs she clicked on.
            for run in paragraph.text.runs {
                guard let intent = run.inlinePresentationIntent else { continue }
                let range = NSRange(run.range, in: paragraph.text)
                attributed.addAttribute(
                    .font, value: Self.face(font, for: intent), range: range)
            }
            content = NSTextContentStorage()
            manager = NSTextLayoutManager()
            content.addTextLayoutManager(manager)
            let container = NSTextContainer(
                size: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            container.lineFragmentPadding = 0
            manager.textContainer = container
            content.attributedString = attributed
            var bottom: CGFloat = 0
            manager.enumerateTextLayoutFragments(
                from: manager.documentRange.location, options: [.ensuresLayout]
            ) { fragment in
                let origin = fragment.layoutFragmentFrame.origin.y
                for line in fragment.textLineFragments {
                    bottom = max(bottom, origin + line.typographicBounds.maxY)
                }
                return true
            }
            height = bottom
        }

        /// The DISPLAY offset (UTF-16, into this paragraph) a point names —
        /// TextKit 2's own click-to-caret question (`textSelections(
        /// interactingAt:…)`, the one `NSTextView` asks).
        func offset(at point: CGPoint) -> Int {
            let selections = manager.textSelectionNavigation.textSelections(
                interactingAt: point, inContainerAt: manager.documentRange.location,
                anchors: [], modifiers: [], selecting: false, bounds: .zero)
            guard let location = selections.first?.textRanges.first?.location else { return 0 }
            return content.offset(from: content.documentRange.location, to: location)
        }

        /// Each text line's top (in this paragraph's own space) and its first
        /// character (UTF-16, into this paragraph) — the pin's read.
        func lines() -> [(top: CGFloat, start: Int)] {
            var out: [(top: CGFloat, start: Int)] = []
            manager.enumerateTextLayoutFragments(
                from: manager.documentRange.location, options: [.ensuresLayout]
            ) { fragment in
                let origin = fragment.layoutFragmentFrame.origin.y
                let base = content.offset(
                    from: content.documentRange.location, to: fragment.rangeInElement.location)
                for line in fragment.textLineFragments where line.characterRange.length > 0 {
                    out.append((origin + line.typographicBounds.minY, base + line.characterRange.location))
                }
                return true
            }
            return out
        }

        private static func face(_ font: NSFont, for intent: InlinePresentationIntent) -> NSFont {
            if intent.contains(.code) {
                return .monospacedSystemFont(ofSize: font.pointSize, weight: .regular)
            }
            var traits: NSFontTraitMask = []
            if intent.contains(.stronglyEmphasized) { traits.insert(.boldFontMask) }
            if intent.contains(.emphasized) { traits.insert(.italicFontMask) }
            guard !traits.isEmpty else { return font }
            return NSFontManager.shared.convert(font, toHaveTrait: traits)
        }
    }
}

/// **The read tier's click, carrying its PLACE** (18l U0) — what the two
/// index-like read tiers attach where their bare `onTapGesture` used to be.
/// `textInsets` is where the text column sits inside the view this is
/// attached to (the host's own read-tier padding, `IndexProseColumn`), so the
/// tap's location reads in the column's space; the width is the view's own,
/// measured, never re-derived from layout constants.
struct ReadTierClickTarget: ViewModifier {
    let source: String
    let textInsets: EdgeInsets
    /// The stored-text offset the click names.
    let onClick: (Int) -> Void

    /// The attached view's width — a reference box, so a width report
    /// invalidates nothing (the tap reads it; nothing renders from it).
    @MainActor private final class WidthBox {
        var width: CGFloat = 0
    }
    @State private var box = WidthBox()

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                box.width = width
            }
            .onTapGesture(coordinateSpace: .local) { location in
                let column = CGPoint(
                    x: location.x - textInsets.leading, y: location.y - textInsets.top)
                onClick(ReadTierClickPlace.sourceOffset(
                    at: column, in: source,
                    columnWidth: box.width - textInsets.leading - textInsets.trailing,
                    font: EditorDocument.baseFont))
            }
    }
}
