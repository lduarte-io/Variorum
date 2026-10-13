//
//  CommentCard.swift
//  Variorum
//
//  **VX-179 U2 — THE GUTTER COMMENT CARD, re-formed for STACKED ENTRIES**
//  (her rulings at the VX-179 kickoff, 2026-10-12: R-VX179-1 — a block's card
//  holds each comment as its own entry, stamp-ordered, thin separators, never
//  the joined string, and when the entries overflow the card you scroll
//  INSIDE it; R-VX179-2 — the card may grow to the block's own height, which
//  is `BlockDecor.leftCardRect`'s half). Her words behind both: *"sometimes a
//  block is several paragraphs but the comment is always just one line. it
//  would be helpful if they were easier to read while on the side / had a
//  scroll inside the comments. it could be handled well when there are
//  multiple comments too."*
//
//  The card is still a POOLED OVERLAY SUBVIEW of the text view (never a
//  rendering attribute — TEXTKIT2 §3; the ~0.04 ms decoration budget), still
//  a READ face and a door (R-13u3-6: editing lives in the panel), and the
//  strip and badge arms are the shipped single label, unchanged. What is new
//  lives only inside the margin-card arm:
//
//  - one wrapping label per comment, pooled INSIDE the card, separated by the
//    panel's own 1 pt hairline (`tokens.line`), placed by the pure
//    `CommentCardLayout.arrange` (pinned by table);
//  - a small `NSScrollView` hosting them, so content taller than the card
//    scrolls inside it;
//  - the card is ONE door: a press hit-tests as the card itself (the labels
//    and the clip view never take her click; a press on the scroller lane
//    belongs to the scroller), and a WHEEL is hit-tested to the scroll view
//    that owns it — the card's own when `CommentCardLayout.wheelOwner` says
//    the card can move that way, the page's otherwise — so a card with
//    nothing to scroll never steals the page's scroll (the U2 fix leg:
//    `CommentCardLayout.hitAnswer`);
//  - `present` is idempotent and labels are measured only when the entries
//    or the width change — an unchanged decoration pass does no text work.
//
//  The READ TIER builds its controller with no comments door, so its cards
//  answer `hitTest → nil` exactly as before (click-through, the round-3
//  MINOR): they receive no wheel either, and therefore show what fits
//  without scrolling — the recorded consequence, strictly more than the old
//  four truncated lines.
//

import AppKit

// MARK: - The pure arrangement (every decision here is pinned by table)

nonisolated enum CommentCardLayout {
    /// The air between an entry and a separator, on each side.
    static let entryAir: CGFloat = 4
    /// The separator: ONE hairline — the panel's own (`tokens.line`, 1 pt),
    /// so the two faces of a block's comments speak one visual language.
    static let separatorThickness: CGFloat = 1
    /// Half a point of slack before "more than fits": a measured height that
    /// rounds onto the viewport is not an overflow.
    static let overflowSlack: CGFloat = 0.5

    /// Where each entry and each separator sits in the card's (flipped)
    /// document view, top-down in the order given.
    struct Arrangement: Equatable {
        var entryFrames: [CGRect]
        var separatorFrames: [CGRect]
        /// The stack's own height: entries, separators, and their air.
        var contentHeight: CGFloat
        /// The document view's height — the content, or the viewport when
        /// the content is shorter (a document never smaller than its clip).
        var documentHeight: CGFloat
        /// Whether the entries need the card's inner scroll.
        var overflows: Bool
    }

    /// **The stack** (R-VX179-1): each comment its own entry, in the order
    /// the briefs arrive — the panel's `(created_at, id)` order, which both
    /// suppliers deliver (`Queries.containerComments` orders by it and
    /// `Dictionary(grouping:)` keeps it). A separator only BETWEEN entries.
    static func arrange(
        entryHeights: [CGFloat], width: CGFloat, viewportHeight: CGFloat
    ) -> Arrangement {
        var entries: [CGRect] = []
        var separators: [CGRect] = []
        var y: CGFloat = 0
        for (index, raw) in entryHeights.enumerated() {
            let height = max(0, raw)
            if index > 0 {
                y += entryAir
                separators.append(CGRect(x: 0, y: y, width: width, height: separatorThickness))
                y += separatorThickness + entryAir
            }
            entries.append(CGRect(x: 0, y: y, width: width, height: height))
            y += height
        }
        return Arrangement(
            entryFrames: entries, separatorFrames: separators, contentHeight: y,
            documentHeight: max(y, viewportHeight),
            overflows: y > viewportHeight + overflowSlack)
    }

    /// Who a wheel event belongs to.
    enum WheelOwner: Equatable {
        /// The card's own inner scroll.
        case card
        /// The page — the event travels on up the responder chain exactly as
        /// if the pointer were over the bare gutter.
        case page
    }

    /// **The wheel's owner.** A card whose entries FIT has nothing to scroll,
    /// so the page owns every event (her page never sticks under a card).
    /// An overflowing card owns a vertical event it can actually move with —
    /// toward its top while it is scrolled down, toward its bottom while
    /// there is more below — and hands the rest to the page: a push past
    /// either end, and anything mostly horizontal (the card has no
    /// horizontal room). A touch that has not moved yet (zero deltas) goes to
    /// the overflowing card, which can move one way at least.
    ///
    /// **Decided per DISPATCHED event, at hit-testing** (`CommentCardView.
    /// hitTarget`): a wheel notch is hit-tested alone; a trackpad gesture
    /// belongs to whichever scroll view takes its first dispatched event,
    /// because that scroll view's own tracking loop then captures the rest of
    /// the gesture un-hit-tested (the 10.9 responsive-scrolling model;
    /// measured — a `.began` handed to an `NSScrollView` does not return
    /// until its gesture ends). So nothing can re-decide mid-gesture; a
    /// zero-delta first event is decided ONCE by the zero-delta row above
    /// (ladder R1-3's answer, the run record's U2 FIX LEG).
    ///
    /// `deltaY` is AppKit's `scrollingDeltaY`, already in content terms:
    /// positive reveals what is ABOVE (toward the document's top), whatever
    /// the trackpad's direction setting. `offset` is the clip's distance from
    /// the top of the (flipped) document.
    static func wheelOwner(
        contentHeight: CGFloat, viewportHeight: CGFloat, offset: CGFloat,
        deltaX: CGFloat, deltaY: CGFloat
    ) -> WheelOwner {
        guard contentHeight > viewportHeight + overflowSlack else { return .page }
        guard abs(deltaY) >= abs(deltaX) else { return .page }
        if deltaY == 0 { return .card }
        if deltaY > 0 { return offset > overflowSlack ? .card : .page }
        let maxOffset = contentHeight - viewportHeight
        return offset < maxOffset - overflowSlack ? .card : .page
    }

    /// What the count badge shows and how far its label is inset.
    struct BadgeFace: Equatable {
        var text: String
        var inset: CGFloat
    }

    /// **THE BADGE ALWAYS CARRIES ITS COUNT (VX-179 U2 FIX LEG — the walk's
    /// F-W-5).** The shipped inset, `min(6, max(2, (w − 16) / 2))`, was tuned
    /// to "#1": at Write's 28 pt floor the badge yields to 22 pt and its label
    /// to 16, where "#1" needs 15.74 and every other digit ~16.7–17.5, so a
    /// two-comment block read "…" beside its "#1" neighbours (measured, the
    /// run record's F-W-5 table). In order: the text with the SHIPPED inset
    /// where it fits (byte-identical — every badge that ever showed its count
    /// still does, the same way); else the inset yields to the count; else
    /// the "#" goes and the bare number takes the room the same two ways.
    /// `need` is the label cell's own width for a text (its padding
    /// included). A number too wide even bare keeps the bare number at zero
    /// inset — the last resort, never "…" first.
    static func badgeFace(
        text: String, width: CGFloat, need: (String) -> CGFloat
    ) -> BadgeFace {
        let shipped = min(6, max(2, (width - 16) / 2))
        var candidates = [text]
        if text.hasPrefix("#"), text.count > 1 { candidates.append(String(text.dropFirst())) }
        for candidate in candidates {
            let needed = need(candidate)
            if needed <= width - 2 * shipped + 0.01 {  // a hundredth for float noise
                return BadgeFace(text: candidate, inset: shipped)
            }
            if needed <= width {
                return BadgeFace(text: candidate, inset: max(0, (width - needed) / 2))
            }
        }
        return BadgeFace(text: candidates.last ?? text, inset: 0)
    }

    /// What an interactive stacked card answers to hit-testing.
    enum HitAnswer: Equatable {
        /// The card itself — the panel's door; a wheel answered here travels
        /// to the PAGE's scroll view (the card's nearest enclosing one).
        case door
        /// The card's own stack — inside its scroll view, which then takes
        /// the wheel natively.
        case contents
        /// The vertical scroller — a press on its lane drags it.
        case scroller
    }

    /// **THE HIT DECISION (VX-179 U2 FIX LEG — the walk's F-W-1 and F-W-2).**
    /// A WHEEL (`wheel` non-nil — its owner from `wheelOwner`) goes where its
    /// owner's scroll view is: the card's contents when the card takes it,
    /// the door (and so the page) when the page does — hit-testing, not a
    /// hand-delivered event, chooses the scroll view. A PRESS on the scroller
    /// lane of an overflowing card belongs to the scroller (faded or not);
    /// every other press is the door.
    static func hitAnswer(wheel: WheelOwner?, inScrollerLane: Bool, overflows: Bool) -> HitAnswer {
        if let wheel { return wheel == .card ? .contents : .door }
        return overflows && inScrollerLane ? .scroller : .door
    }

    /// The controller's pool plan: which existing card shows which block.
    struct Reconciled: Equatable {
        /// Per wanted block, the index of the existing card to reuse — nil
        /// means a new card must be made.
        var reuse: [Int?]
        /// Existing cards no wanted block needs (removed from the surface).
        var discard: [Int]
    }

    /// **Cards stay with their blocks.** The pool used to pair cards with the
    /// visible commented blocks by POSITION, which was harmless while a card
    /// held no state of its own. A card that scrolls does: pair by position
    /// and a page scroll that moves the visible set by one block hands every
    /// card to its neighbour's block, mid-scroll. So a block keeps the card
    /// that already shows it (and with it her inner scroll position); the
    /// remaining blocks take the free cards in pool order; new cards are made
    /// only when the pool runs out — still a pool, never a mint per pass.
    static func reconcile(current: [String?], wanted: [String]) -> Reconciled {
        var firstIndex: [String: Int] = [:]
        for (index, identity) in current.enumerated() {
            if let identity, firstIndex[identity] == nil { firstIndex[identity] = index }
        }
        var claimed = Set<Int>()
        var reuse: [Int?] = wanted.map { identity in
            guard let index = firstIndex[identity], !claimed.contains(index) else { return nil }
            claimed.insert(index)
            return index
        }
        var free = current.indices.filter { !claimed.contains($0) }[...]
        for slot in reuse.indices where reuse[slot] == nil {
            guard let next = free.first else { break }
            reuse[slot] = next
            free = free.dropFirst()
        }
        return Reconciled(reuse: reuse, discard: Array(free))
    }
}

// MARK: - The face

/// A comment face: margin card / inline strip / count badge. Always a
/// door — clicking opens the block's comments panel.
final class CommentCardView: NSView {
    enum Style: Equatable {
        case marginCard(rule: NSColor)
        case strip
        case badge
    }

    /// **Everything a margin card shows** — compared whole by
    /// `presentCard`, so the decoration pass that re-renders on every scroll,
    /// layout and caret move does no label work when nothing changed.
    struct CardContent: Equatable {
        /// Each comment's own text, in the panel's order (R-VX179-1).
        var entries: [String]
        /// The voice's comment mark, drawn PER ENTRY as a hanging mark
        /// ("// " in Terminal, nothing in Study) — the panel row's idiom
        /// (PROVISIONAL, VX-179 U2; the walk decides the taste).
        var prefix: String
        var ink: NSColor
        /// The card's leading rule (the shipped `commentTint`).
        var rule: NSColor
        /// The hairline between entries (the panel's `tokens.line`).
        var separator: NSColor
        /// The card's fill (clear for the margin card, as shipped).
        var fill: NSColor
        /// The tooltip — the shipped joined string, kept whole.
        var toolTip: String

        /// The comparison the budget stands on. The colours arrive freshly
        /// made from the voice tokens on EVERY pass (`NSColor(tokens.…)`),
        /// so they are compared by their sRGB components rather than by
        /// object equality — a conversion that hands back a new wrapper each
        /// time must still read as "unchanged", or every pass would rebuild
        /// every entry.
        static func == (a: CardContent, b: CardContent) -> Bool {
            a.entries == b.entries && a.prefix == b.prefix && a.toolTip == b.toolTip
                && sameColor(a.ink, b.ink) && sameColor(a.rule, b.rule)
                && sameColor(a.separator, b.separator) && sameColor(a.fill, b.fill)
        }

        static func sameColor(_ a: NSColor, _ b: NSColor) -> Bool {
            if a == b { return true }
            guard let x = a.usingColorSpace(.sRGB), let y = b.usingColorSpace(.sRGB)
            else { return false }
            return x.redComponent == y.redComponent && x.greenComponent == y.greenComponent
                && x.blueComponent == y.blueComponent && x.alphaComponent == y.alphaComponent
        }
    }

    var onClick: (() -> Void)?

    /// **The block this face belongs to** — the controller's reconcile key
    /// (`CommentCardLayout.reconcile`). When it changes, the card is showing
    /// a different block's comments, so its inner scroll returns to the top.
    var identity: String? {
        didSet { if identity != oldValue { didChangeIdentity() } }
    }

    /// The strip's and the badge's one line — the shipped label, unchanged.
    private let label = NSTextField(labelWithString: "")
    /// The badge's count text as presented ("#2") — `layout` chooses what the
    /// label shows from it (`CommentCardLayout.badgeFace`); nil off the badge.
    private var badgeText: String?

    // The margin card's parts (VX-179 U2) — hidden on the other two arms.
    private var stacked = false
    private let rule = NSView()
    private let scroller = NSScrollView()
    private let stack = CommentCardStackView()
    /// One label per entry, pooled inside the card (never minted per pass).
    private(set) var entryLabels: [NSTextField] = []
    private var separatorViews: [NSView] = []
    private var content: CardContent?
    private var measuredWidth: CGFloat = -1
    private var entryHeights: [CGFloat] = []
    /// A new block's (or new) content flashes the overlay scroller once when
    /// it overflows — AppKit's own "there is more here" cue.
    private var flashPending = false
    /// Whether the entries outgrow the card — the last arrangement's answer;
    /// the hit decision reads it (the scroller lane exists only then).
    private var overflows = false

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        label.font = .systemFont(ofSize: 11)
        label.lineBreakMode = .byTruncatingTail
        label.cell?.truncatesLastVisibleLine = true
        addSubview(label)

        rule.wantsLayer = true
        rule.isHidden = true
        addSubview(rule)
        scroller.drawsBackground = false
        scroller.borderType = .noBorder
        scroller.hasVerticalScroller = false  // `presentCard` grants it to a door
        scroller.hasHorizontalScroller = false
        scroller.autohidesScrollers = true
        scroller.scrollerStyle = .overlay
        scroller.horizontalScrollElasticity = .none
        scroller.documentView = stack
        scroller.isHidden = true
        addSubview(scroller)
    }

    required init?(coder: NSCoder) { nil }

    /// The strip and the badge (and a single-string card, for a caller that
    /// holds one text). The strip's and the badge's arms are the shipped
    /// ones, line for line.
    func present(text: String, tint: NSColor, ink: NSColor, style: Style) {
        if case .marginCard(let ruleColor) = style {
            presentCard(CardContent(
                entries: [text], prefix: "", ink: ink, rule: ruleColor,
                separator: .clear, fill: tint, toolTip: text))
            return
        }
        showStacked(false)
        if style == .badge {
            // The badge's words are layout's choice (`badgeFace`): set them
            // only when the count CHANGED, so the decoration pass that
            // re-presents every badge never undoes a fitted "12" back to a
            // truncated "#12".
            if badgeText != text {
                badgeText = text
                label.stringValue = text
                needsLayout = true
            }
        } else {
            badgeText = nil
            label.stringValue = text
        }
        label.textColor = ink
        layer?.backgroundColor = tint.cgColor
        layer?.cornerRadius = 5
        switch style {
        case .marginCard:
            break
        case .strip:
            label.maximumNumberOfLines = 1
            label.font = .systemFont(ofSize: 11)
        case .badge:
            label.maximumNumberOfLines = 1
            label.font = .systemFont(ofSize: 10, weight: .semibold)
        }
        toolTip = text
    }

    /// **THE MARGIN CARD — stacked entries** (R-VX179-1). Idempotent: an
    /// unchanged pass returns at the comparison.
    func presentCard(_ new: CardContent) {
        let switching = !stacked
        showStacked(true)
        // Only a card she can scroll carries a scroller: the read tier's
        // cards take no wheel (`hitTest`), so they hold no scroller view at
        // all. (The controller sets `onClick` before it presents.)
        let scrollable = onClick != nil
        if scroller.hasVerticalScroller != scrollable { scroller.hasVerticalScroller = scrollable }
        guard switching || new != content else { return }
        #if DEBUG
        contentApplications += 1
        #endif
        let textChanged = new.entries != content?.entries || new.prefix != content?.prefix
        content = new
        layer?.backgroundColor = new.fill.cgColor
        layer?.cornerRadius = 5
        rule.layer?.backgroundColor = new.rule.cgColor
        poolEntries(count: new.entries.count)
        for (entry, text) in zip(entryLabels, new.entries) {
            entry.attributedStringValue = Self.entryString(
                prefix: new.prefix, text: text, ink: new.ink)
        }
        for separator in separatorViews {
            separator.layer?.backgroundColor = new.separator.cgColor
        }
        toolTip = new.toolTip
        if textChanged {
            measuredWidth = -1
            flashPending = true
        }
        needsLayout = true
    }

    /// The type every entry is set in — the shipped card's 11 pt.
    static let entryFont = NSFont.systemFont(ofSize: 11)

    /// **One entry's text, with the voice's mark HANGING** (the panel row's
    /// idiom: the mark is a label beside the comment, so a wrapped line
    /// aligns after it, never under it). The mark is drawn at the panel's
    /// 0.75 of the comment ink. A newline inside a comment becomes a LINE
    /// separator so its later lines hang too (display only — the stored
    /// text is untouched). With no mark (Study) the text is the comment's own.
    static func entryString(prefix: String, text: String, ink: NSColor) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        let result = NSMutableAttributedString()
        var body = text
        if !prefix.isEmpty {
            let mark: [NSAttributedString.Key: Any] = [
                .font: entryFont, .foregroundColor: ink.withAlphaComponent(0.75),
            ]
            paragraph.headIndent = ceil((prefix as NSString).size(withAttributes: mark).width)
            result.append(NSAttributedString(string: prefix, attributes: mark))
            body = text
                .replacingOccurrences(of: "\r\n", with: "\u{2028}")
                .replacingOccurrences(of: "\n", with: "\u{2028}")
                .replacingOccurrences(of: "\r", with: "\u{2028}")
        }
        result.append(NSAttributedString(
            string: body, attributes: [.font: entryFont, .foregroundColor: ink]))
        result.addAttribute(
            .paragraphStyle, value: paragraph,
            range: NSRange(location: 0, length: result.length))
        return result
    }

    private func showStacked(_ on: Bool) {
        guard on != stacked else { return }
        stacked = on
        label.isHidden = on
        rule.isHidden = !on
        scroller.isHidden = !on
        if !on { overflows = false }
        needsLayout = true
    }

    private func poolEntries(count: Int) {
        while entryLabels.count < count {
            let entry = NSTextField(wrappingLabelWithString: "")
            entry.isSelectable = false
            entry.isEditable = false
            entry.isBordered = false
            entry.drawsBackground = false
            entry.font = Self.entryFont
            entry.lineBreakMode = .byWordWrapping
            entry.maximumNumberOfLines = 0
            entry.cell?.wraps = true
            entry.cell?.truncatesLastVisibleLine = false
            stack.addSubview(entry)
            entryLabels.append(entry)
        }
        while entryLabels.count > count {
            entryLabels.removeLast().removeFromSuperview()
        }
        let separators = max(0, count - 1)
        while separatorViews.count < separators {
            let separator = NSView()
            separator.wantsLayer = true
            stack.addSubview(separator)
            separatorViews.append(separator)
        }
        while separatorViews.count > separators {
            separatorViews.removeLast().removeFromSuperview()
        }
    }

    private func didChangeIdentity() {
        flashPending = true
        let clip = scroller.contentView
        guard clip.bounds.origin != .zero else { return }
        clip.scroll(to: .zero)
        scroller.reflectScrolledClipView(clip)
    }

    override func layout() {
        super.layout()
        if stacked {
            layoutCard()
        } else if let badgeText {
            // 13u3 UNIT A1: a BADGE may be narrower than the shipped 32 (it
            // yields to the gutter rather than standing on prose), so its
            // inset yields with it — a "#1" squeezed to "#" is not a count.
            // VX-179 U2 FIX LEG (F-W-5): and neither is "…" — the face keeps
            // the whole count (`badgeFace`), byte-identical wherever it fit.
            let face = CommentCardLayout.badgeFace(text: badgeText, width: bounds.width) {
                Self.cellWidth(of: $0, like: label)
            }
            if label.stringValue != face.text { label.stringValue = face.text }
            label.frame = bounds.insetBy(dx: face.inset, dy: 1)
        } else {
            // The inline strip — the shipped line, unchanged.
            label.frame = bounds.insetBy(dx: min(6, max(2, (bounds.width - 16) / 2)), dy: 1)
        }
    }

    /// The margin card: the shipped rule and text area, with the entries in
    /// a scroll view where the one label used to be.
    private func layoutCard() {
        rule.frame = CGRect(x: 0, y: 0, width: 2.5, height: bounds.height)
        let area = bounds.insetBy(dx: 4, dy: 1).offsetBy(dx: 5, dy: 0)
            .intersection(bounds.insetBy(dx: 1, dy: 1))
        scroller.frame = area.isNull ? .zero : area
        let viewport = scroller.contentSize
        guard viewport.width > 0, let content else { return }
        let count = content.entries.count
        // Text is measured only when the entries or the width change — a
        // height change (her block grew by a line) re-arranges, never
        // re-measures.
        if viewport.width != measuredWidth || entryHeights.count != count {
            entryHeights = entryLabels.prefix(count).map {
                Self.height(of: $0, width: viewport.width)
            }
            measuredWidth = viewport.width
            #if DEBUG
            measurements += 1
            #endif
        }
        let arrangement = CommentCardLayout.arrange(
            entryHeights: entryHeights, width: viewport.width,
            viewportHeight: viewport.height)
        for (entry, frame) in zip(entryLabels, arrangement.entryFrames) where entry.frame != frame {
            entry.frame = frame
        }
        for (separator, frame) in zip(separatorViews, arrangement.separatorFrames)
        where separator.frame != frame {
            separator.frame = frame
        }
        let document = CGRect(
            x: 0, y: 0, width: viewport.width, height: arrangement.documentHeight)
        if stack.frame != document { stack.frame = document }
        overflows = arrangement.overflows
        if flashPending, window != nil {
            flashPending = false
            // Only a card she can scroll advertises it (the read tier's
            // cards take no wheel — `hitTest`).
            if arrangement.overflows, onClick != nil { scroller.flashScrollers() }
        }
    }

    /// A wrapping label's height at a width — the cell's own measure, so it
    /// matches what the label draws (its internal padding included).
    static func height(of entry: NSTextField, width: CGFloat) -> CGFloat {
        guard let cell = entry.cell else { return 0 }
        return ceil(cell.cellSize(
            forBounds: NSRect(x: 0, y: 0, width: width, height: 100_000)).height)
    }

    /// A one-line label's own width for a text — a COPY of its cell (font,
    /// padding) measured, so the label shown is untouched.
    static func cellWidth(of text: String, like label: NSTextField) -> CGFloat {
        guard let cell = label.cell?.copy() as? NSCell else { return 0 }
        cell.stringValue = text
        return cell.cellSize.width
    }

    override func mouseDown(with event: NSEvent) {
        onClick?()
    }

    /// Round 3 (MINOR): a quiet card is CLICK-THROUGH — the read tier
    /// builds the controller with no comments door (`onClick == nil`), and
    /// without this a card/strip/badge was a dead zone over the text
    /// (swallowing click-to-focus). The DecorRectView/SeamLineView rule,
    /// applied conditionally: no door ⇒ no hit.
    ///
    /// **VX-179 U2: the margin card is ONE door** — a press anywhere opens the
    /// panel, the labels and the clip view never take it.
    ///
    /// **VX-179 U2 FIX LEG (the walk's F-W-1 and F-W-2) — HIT-TESTING CHOOSES
    /// THE SCROLL VIEW.** Traced offscreen against the real module (the run
    /// record's THE TRACES): the card's own wheel router was right whenever
    /// it was reached, but the live dispatch hands a wheel to the HIT VIEW's
    /// scroll view, and the card — answering itself — belongs to the PAGE's:
    /// the page took both directions and the card never moved. And a faded
    /// overlay scroller declines its own hit, so the lane fell through to the
    /// door and a press on it opened the panel. So the answer now depends on
    /// what is being dispatched (`NSApp.currentEvent`, which AppKit has set to
    /// that event): a wheel the card can take answers the card's own STACK
    /// (inside its scroll view, which then scrolls natively — measured), a
    /// wheel the page takes answers the card (whose scroll view is the page —
    /// the walk's own observed road), and a press on the scroller lane of an
    /// overflowing card answers the scroller even while it is faded. Every
    /// other press is the door. One pure decision: `CommentCardLayout.hitAnswer`.
    override func hitTest(_ point: NSPoint) -> NSView? {
        hitTarget(at: point, during: NSApp.currentEvent)
    }

    /// The hit decision with the dispatched event NAMED (`hitTest` passes
    /// `NSApp.currentEvent`; the pins pass a constructed one). The strip and
    /// badge arms keep the shipped answer exactly.
    func hitTarget(at point: NSPoint, during event: NSEvent?) -> NSView? {
        guard onClick != nil else { return nil }
        guard stacked else { return super.hitTest(point) }
        guard super.hitTest(point) != nil else { return nil }
        let wheel = event.flatMap { $0.type == .scrollWheel ? wheelOwner(for: $0) : nil }
        switch CommentCardLayout.hitAnswer(
            wheel: wheel, inScrollerLane: inScrollerLane(point), overflows: overflows) {
        case .contents: return stack
        case .scroller: return scroller.verticalScroller ?? self
        case .door: return self
        }
    }

    /// Whether a point (superview coordinates) is on the vertical scroller's
    /// lane — its frame, faded or not.
    private func inScrollerLane(_ point: NSPoint) -> Bool {
        guard let bar = scroller.verticalScroller, scroller.hasVerticalScroller,
              !bar.frame.isEmpty
        else { return false }
        return scroller.convert(bar.frame, to: self).contains(convert(point, from: superview))
    }

    private func wheelOwner(for event: NSEvent) -> CommentCardLayout.WheelOwner {
        let clip = scroller.contentView.bounds
        return CommentCardLayout.wheelOwner(
            contentHeight: stack.frame.height, viewportHeight: clip.height,
            offset: clip.minY, deltaX: event.scrollingDeltaX, deltaY: event.scrollingDeltaY)
    }

    #if DEBUG
    /// How many `presentCard` calls did entry work (the budget pin: an
    /// unchanged pass adds nothing here).
    private(set) var contentApplications = 0
    /// How many layouts measured the entries' text (a height-only change —
    /// her block grew a line — adds nothing here).
    private(set) var measurements = 0
    /// The pins' window into the stacked arm.
    var showsStackedEntries: Bool { stacked && !scroller.isHidden && label.isHidden }
    var shownEntryCount: Int { stacked ? (content?.entries.count ?? 0) : 0 }
    var entrySeparatorCount: Int { separatorViews.count }
    var shownLineText: String { label.stringValue }
    /// The strip's / badge's one label (the F-W-5 pin reads its frame + cell).
    var lineLabel: NSTextField { label }
    var innerScrollView: NSScrollView { scroller }
    #endif
}

/// The stacked card's document view — FLIPPED, so the first comment sits at
/// the top and the scroll's zero is the top of the stack.
final class CommentCardStackView: NSView {
    override var isFlipped: Bool { true }
}
