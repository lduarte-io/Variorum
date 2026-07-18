//
//  BlockDecor.swift
//  Variorum
//
//  Phase 13, C1 — the writing surface's decoration layer, ALL of it
//  overlay views over the live TK2 editor (the ground rule: decorations
//  never ride rendering attributes — TEXTKIT2 §3; the Phase 7 badge
//  pattern, the A0 spike's measured ~0.04 ms budget):
//
//  - dotted SEAMS between blocks on the global toggle (R6/R42 — THE
//    boundary mechanism; the 9d pastel tint look is RETIRED, this layer
//    replaces `BlockTintOverlayController`);
//  - the EDITING INDICATOR (R14/R22 — a setting: off / outline ring /
//    background wash; off default, cursor-only is legitimate);
//  - CALLOUT frames (R16/R27) with the WHITE-GAP rule (R17: colored
//    blocks keep base-background breathing room — the 9d tint's diagnosed
//    defect, never repeated);
//  - COMMENT surfaces (R7: margin cards the default, inline tinted strips
//    as the setting; a narrow gutter degrades to a count badge — every
//    face opens the comments panel);
//  - block DRAG HANDLES + the Notion INSERTION BAR (R19) — drop lands as
//    ONE `reorder` operation.
//
//  Geometry is pure and tested (`BlockDecor`); the controller only owns
//  view pools. Everything renders from `BlockDecor.State`, which the view
//  model emits on every overlay refresh (scroll, layout, projection,
//  caret move, appearance change).
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - The appearance context (theme → editor)

/// What the editor surface needs to know from the theme environment —
/// pushed by the View (models never read SwiftUI environments).
nonisolated struct EditorAppearance: Equatable, Sendable {
    var voice: ThemeVoice = .terminal
    var dark = false
    var seamsVisible = false
    var indicator: EditingIndicatorStyle = .off
    var inlineComments = false

    init() {}

    init(_ settings: Queries.ThemeSettings, dark: Bool) {
        self.voice = settings.voice
        self.dark = dark
        self.seamsVisible = settings.seamsVisible
        self.indicator = settings.editingIndicator
        self.inlineComments = settings.inlineComments
    }

    @MainActor var tokens: VoiceTokens { .resolve(voice: voice, dark: dark) }
}

// MARK: - Pure geometry

nonisolated enum BlockDecor {
    /// One visible block's resolved geometry, view coordinates.
    struct Frame: Equatable {
        let entryIndex: Int
        let blockID: String
        let frame: CGRect
    }

    /// Everything one decoration pass renders from.
    struct State: Equatable {
        var frames: [Frame] = []
        var fannedBlockIDs: Set<String> = []
        var appearance = EditorAppearance()
        var caretBlockID: String?
        var presentations: [String: BlockPresentation] = [:]
        var comments: [String: [CommentBrief]] = [:]
        /// The prose column's edges + the surface's width (view coords).
        var textLeft: CGFloat = 0
        var textRight: CGFloat = 0
        var viewWidth: CGFloat = 0
        /// The total entry count (drop boundaries may exceed the visible
        /// window's last index).
        var entryCount = 0
    }

    struct CommentBrief: Equatable {
        let id: String
        let text: String
    }

    /// Seam Y positions — the midpoint of each gap between CONSECUTIVE
    /// visible blocks (a pruned neighbor draws no seam; §12's rest state
    /// is no seams at all).
    static func seamYs(_ frames: [Frame]) -> [CGFloat] {
        zip(frames, frames.dropFirst()).compactMap { a, b in
            guard b.entryIndex == a.entryIndex + 1, b.frame.minY >= a.frame.maxY - 1
            else { return nil }
            return ((a.frame.maxY + b.frame.minY) / 2).rounded()
        }
    }

    /// The white-gap rule (R17, BINDING): a callout card may pad beyond
    /// its text vertically only as far as leaves `minWhiteGap` of base
    /// background toward each neighbor. A nil gap (no adjacent block —
    /// document edge or pruned) allows the ideal pad.
    static func verticalPad(
        gap: CGFloat?, ideal: CGFloat = 5, minWhiteGap: CGFloat = 6
    ) -> CGFloat {
        guard let gap else { return ideal }
        return max(0, min(ideal, (gap - minWhiteGap) / 2))
    }

    /// The callout card's rect: the block's lines padded into a rounded
    /// frame — horizontal air into the gutters, vertical air capped by the
    /// white-gap rule against BOTH neighbors.
    static func calloutRect(
        block: CGRect, gapAbove: CGFloat?, gapBelow: CGFloat?,
        textLeft: CGFloat, textRight: CGFloat
    ) -> CGRect {
        let top = verticalPad(gap: gapAbove)
        let bottom = verticalPad(gap: gapBelow)
        let left = max(2, textLeft - 12)
        let right = textRight + 12
        return CGRect(
            x: left, y: block.minY - top,
            width: right - left, height: block.height + top + bottom)
    }

    /// The editing indicator's rect (outline ring or background wash):
    /// the block's lines with the round-2 mockup's air (outline-offset).
    static func indicatorRect(block: CGRect, textLeft: CGFloat, textRight: CGFloat) -> CGRect {
        CGRect(
            x: max(2, textLeft - 8), y: block.minY - 3,
            width: (textRight + 8) - max(2, textLeft - 8), height: block.height + 6)
    }

    /// The drop boundary nearest a drag Y: `index` = the entry the dragged
    /// block would land BEFORE (`entryCount` = the end); `barY` = where
    /// the insertion bar renders. Boundaries come from the VISIBLE frames
    /// (drag targets are on-screen by construction).
    static func dropBoundary(
        at y: CGFloat, frames: [Frame], entryCount: Int
    ) -> (index: Int, barY: CGFloat)? {
        guard let first = frames.first, let last = frames.last else { return nil }
        if y < first.frame.midY {
            return (first.entryIndex, first.frame.minY - 2)
        }
        for (a, b) in zip(frames, frames.dropFirst()) where y < b.frame.midY {
            return (b.entryIndex, ((a.frame.maxY + b.frame.minY) / 2).rounded())
        }
        let end = min(last.entryIndex + 1, entryCount)
        return (end, last.frame.maxY + 2)
    }

    /// Whether the right gutter is wide enough for margin comment CARDS;
    /// below this the margin presentation degrades to the count badge.
    static func gutterFitsCards(viewWidth: CGFloat, textRight: CGFloat) -> Bool {
        viewWidth - textRight >= 150
    }
}

// MARK: - The callout palette (token NAMES → colors; R1 forbids stored values)

nonisolated enum CalloutPalette {
    static let names = ["blue", "green", "sand", "violet", "rose"]
    static let defaultName = "blue"

    /// Soft washes with real breathing room (R17's spirit); dark keeps the
    /// fully-black room readable (R51).
    static func color(_ name: String?, dark: Bool) -> NSColor {
        let resolved = name ?? defaultName
        let hex: UInt32
        switch (resolved, dark) {
        case ("green", false): hex = 0xEAF3E7
        case ("green", true): hex = 0x17251A
        case ("sand", false): hex = 0xF7F1DE
        case ("sand", true): hex = 0x262012
        case ("violet", false): hex = 0xEFEAF6
        case ("violet", true): hex = 0x1F1A2A
        case ("rose", false): hex = 0xF8ECEC
        case ("rose", true): hex = 0x2A1A1C
        case (_, false): hex = 0xE8F1F8  // blue + unknown names (fail-open)
        case (_, true): hex = 0x14202B
        }
        return NSColor(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}

// MARK: - The overlay controller

/// Owns the decoration view pools over one TK2 surface — the LIVE editor
/// (comment doors + drag handles wired) or the READ tier (view-only:
/// callouts, seams, comment cards — nil doors hide the handles and mute
/// the clicks). Renders whatever `BlockDecor.State` its owner feeds it;
/// every view is either click-through (seams, washes, callouts, the bar)
/// or an explicit door.
@MainActor
final class BlockDecorOverlayController {
    private weak var textView: NSTextView?
    /// The comments door (nil = read-only faces).
    private let onOpenComments: ((String) -> Void)?
    /// The drop door: (fromEntry, toBoundary). nil = no handles at all.
    private let onMoveBlock: ((Int, Int) -> Void)?

    private var seamViews: [SeamLineView] = []
    private var calloutViews: [DecorRectView] = []
    private var emojiLabels: [NSTextField] = []
    private var indicatorView: DecorRectView?
    private var commentCards: [CommentCardView] = []
    private var handleViews: [DragHandleView] = []
    private var insertionBar: DecorRectView?
    private var state = BlockDecor.State()

    /// The live editor's controller: full doors.
    convenience init(model: EditorViewModel, textView: EditorTextView) {
        self.init(
            textView: textView,
            onOpenComments: { [weak model] blockID in model?.openComments(blockID: blockID) },
            onMoveBlock: { [weak model] from, to in
                Task { await model?.moveBlock(fromEntry: from, toBoundary: to) }
            })
        model.decorSink = { [weak self] state in self?.render(state) }
    }

    init(
        textView: NSTextView,
        onOpenComments: ((String) -> Void)?,
        onMoveBlock: ((Int, Int) -> Void)?
    ) {
        self.textView = textView
        self.onOpenComments = onOpenComments
        self.onMoveBlock = onMoveBlock
    }

    func uninstall() {
        for view in seamViews { view.removeFromSuperview() }
        for view in calloutViews { view.removeFromSuperview() }
        for label in emojiLabels { label.removeFromSuperview() }
        for card in commentCards { card.removeFromSuperview() }
        for handle in handleViews { handle.removeFromSuperview() }
        indicatorView?.removeFromSuperview()
        insertionBar?.removeFromSuperview()
        seamViews = []
        calloutViews = []
        emojiLabels = []
        commentCards = []
        handleViews = []
        indicatorView = nil
        insertionBar = nil
    }

    // MARK: Render

    func render(_ state: BlockDecor.State) {
        self.state = state
        guard let textView else { return }
        let tokens = state.appearance.tokens
        renderCallouts(state, tokens: tokens, in: textView)
        renderIndicator(state, tokens: tokens, in: textView)
        renderSeams(state, tokens: tokens, in: textView)
        renderComments(state, tokens: tokens, in: textView)
        renderHandles(state, in: textView)
    }

    private func renderSeams(
        _ state: BlockDecor.State, tokens: VoiceTokens, in textView: NSTextView
    ) {
        let ys = state.appearance.seamsVisible ? BlockDecor.seamYs(state.frames) : []
        pool(&seamViews, count: ys.count, in: textView, below: true) { SeamLineView() }
        for (view, y) in zip(seamViews, ys) {
            view.frame = CGRect(
                x: state.textLeft, y: y - 1,
                width: max(0, state.textRight - state.textLeft), height: 2)
            view.lineColor = NSColor(tokens.seam)
        }
    }

    private func renderCallouts(
        _ state: BlockDecor.State, tokens: VoiceTokens, in textView: NSTextView
    ) {
        var rects: [(frame: BlockDecor.Frame, presentation: BlockPresentation)] = []
        for frame in state.frames {
            if let presentation = state.presentations[frame.blockID],
               presentation.kind == BlockPresentation.calloutKind {
                rects.append((frame, presentation))
            }
        }
        pool(&calloutViews, count: rects.count, in: textView, below: true) { DecorRectView() }
        pool(&emojiLabels, count: rects.filter { $0.presentation.emoji?.isEmpty == false }.count,
             in: textView, below: false) {
            let label = NSTextField(labelWithString: "")
            label.font = .systemFont(ofSize: 13)
            return label
        }
        var emojiIndex = 0
        for (view, item) in zip(calloutViews, rects) {
            let index = item.frame.entryIndex
            let above = state.frames.first { $0.entryIndex == index - 1 }
            let below = state.frames.first { $0.entryIndex == index + 1 }
            view.frame = BlockDecor.calloutRect(
                block: item.frame.frame,
                gapAbove: above.map { item.frame.frame.minY - $0.frame.maxY },
                gapBelow: below.map { $0.frame.minY - item.frame.frame.maxY },
                textLeft: state.textLeft, textRight: state.textRight)
            view.configure(
                fill: CalloutPalette.color(item.presentation.color, dark: state.appearance.dark),
                border: nil, cornerRadius: 8)
            if let emoji = item.presentation.emoji, !emoji.isEmpty,
               emojiIndex < emojiLabels.count {
                let label = emojiLabels[emojiIndex]
                emojiIndex += 1
                label.stringValue = emoji
                label.sizeToFit()
                label.frame.origin = CGPoint(
                    x: max(2, state.textLeft - label.frame.width - 8),
                    y: item.frame.frame.minY)
            }
        }
    }

    private func renderIndicator(
        _ state: BlockDecor.State, tokens: VoiceTokens, in textView: NSTextView
    ) {
        let caretFrame = state.caretBlockID.flatMap { id in
            state.frames.first { $0.blockID == id }
        }
        guard state.appearance.indicator != .off, let caretFrame else {
            indicatorView?.removeFromSuperview()
            indicatorView = nil
            return
        }
        let view = indicatorView ?? {
            let view = DecorRectView()
            indicatorView = view
            return view
        }()
        if view.superview == nil {
            textView.addSubview(view, positioned: .below, relativeTo: nil)
        }
        view.frame = BlockDecor.indicatorRect(
            block: caretFrame.frame,
            textLeft: state.textLeft, textRight: state.textRight)
        switch state.appearance.indicator {
        case .outline:
            view.configure(fill: nil, border: NSColor(tokens.ring), cornerRadius: 4)
        case .background:
            view.configure(fill: NSColor(tokens.wash), border: nil, cornerRadius: 6)
        case .off:
            break
        }
    }

    private func renderComments(
        _ state: BlockDecor.State, tokens: VoiceTokens, in textView: NSTextView
    ) {
        var items: [(frame: BlockDecor.Frame, briefs: [BlockDecor.CommentBrief])] = []
        for frame in state.frames {
            if let briefs = state.comments[frame.blockID], !briefs.isEmpty {
                items.append((frame, briefs))
            }
        }
        let inline = state.appearance.inlineComments
        let fitsCards = BlockDecor.gutterFitsCards(
            viewWidth: state.viewWidth, textRight: state.textRight)
        pool(&commentCards, count: items.count, in: textView, below: false) {
            CommentCardView()
        }
        for (card, item) in zip(commentCards, items) {
            let text = item.briefs.map(\.text).joined(separator: "  ·  ")
            let blockID = item.frame.blockID
            card.onClick = onOpenComments.map { open in { open(blockID) } }
            if inline {
                // The inline strip (R7's setting): the tinted line in the
                // widened uniform gap under the block.
                card.present(
                    text: tokens.commentPrefix + text,
                    tint: NSColor(tokens.commentTint), ink: NSColor(tokens.commentInk),
                    style: .strip)
                card.frame = CGRect(
                    x: state.textLeft, y: item.frame.frame.maxY + 3,
                    width: max(40, state.textRight - state.textLeft),
                    height: EditorTypography.inlineCommentSpacing - 4)
            } else if fitsCards {
                // The margin card (R7's ruling — the round-2 mockup's
                // mcmt): the right gutter, aligned to the block's top;
                // nudged down when a fan badge holds the corner.
                let width = min(210, state.viewWidth - state.textRight - 24)
                let yNudge: CGFloat = state.fannedBlockIDs.contains(blockID) ? 22 : 0
                card.present(
                    text: tokens.commentPrefix + text,
                    tint: .clear, ink: NSColor(tokens.commentInk),
                    style: .marginCard(rule: NSColor(tokens.commentTint)))
                card.frame = CGRect(
                    x: state.textRight + 12, y: item.frame.frame.minY + yNudge,
                    width: width,
                    height: min(item.frame.frame.height + 24, 96))
            } else {
                // Narrow gutter: the count badge — still a door.
                card.present(
                    text: "#\(item.briefs.count)",
                    tint: NSColor(tokens.commentTint), ink: NSColor(tokens.commentInk),
                    style: .badge)
                let yNudge: CGFloat = state.fannedBlockIDs.contains(blockID) ? 20 : 0
                card.frame = CGRect(
                    x: max(state.textLeft, state.viewWidth - 40),
                    y: item.frame.frame.minY + yNudge,
                    width: 32, height: 16)
            }
        }
    }

    private func renderHandles(_ state: BlockDecor.State, in textView: NSTextView) {
        // Handles ride the seams-visible mode (the recorded build-time
        // call: the boundaries-shown state IS the working-with-blocks
        // state; at rest the surface stays calm — §12) — and exist only
        // where a drop door does (the read tier renders none).
        let frames = (state.appearance.seamsVisible && onMoveBlock != nil)
            ? state.frames : []
        pool(&handleViews, count: frames.count, in: textView, below: false) {
            DragHandleView()
        }
        for (handle, frame) in zip(handleViews, frames) {
            handle.frame = CGRect(
                x: max(0, state.textLeft - 22), y: frame.frame.minY + 1,
                width: 18, height: 18)
            handle.inkColor = NSColor(state.appearance.tokens.faint)
            let entryIndex = frame.entryIndex
            handle.onDragBegan = { [weak self] in self?.dragBegan(entryIndex: entryIndex) }
            handle.onDragMoved = { [weak self] point in self?.dragMoved(to: point) }
            handle.onDragEnded = { [weak self] point in self?.dragEnded(at: point) }
        }
    }

    /// Grows/shrinks a view pool in place.
    private func pool<V: NSView>(
        _ views: inout [V], count: Int, in textView: NSTextView,
        below: Bool, make: () -> V
    ) {
        while views.count < count {
            let view = make()
            if below {
                textView.addSubview(view, positioned: .below, relativeTo: nil)
            } else {
                textView.addSubview(view)
            }
            views.append(view)
        }
        while views.count > count {
            views.removeLast().removeFromSuperview()
        }
    }

    // MARK: Drag (R19 — the insertion bar)

    private var dragEntryIndex: Int?

    private func dragBegan(entryIndex: Int) {
        dragEntryIndex = entryIndex
    }

    private func dragMoved(to point: CGPoint) {
        guard dragEntryIndex != nil, let textView,
              let boundary = BlockDecor.dropBoundary(
                at: point.y, frames: state.frames, entryCount: state.entryCount)
        else { return }
        let bar = insertionBar ?? {
            let bar = DecorRectView()
            insertionBar = bar
            return bar
        }()
        if bar.superview == nil { textView.addSubview(bar) }
        bar.configure(
            fill: NSColor(state.appearance.tokens.ring), border: nil, cornerRadius: 1)
        bar.frame = CGRect(
            x: state.textLeft, y: boundary.barY - 1.25,
            width: max(0, state.textRight - state.textLeft), height: 2.5)
    }

    private func dragEnded(at point: CGPoint) {
        insertionBar?.removeFromSuperview()
        insertionBar = nil
        guard let from = dragEntryIndex else { return }
        dragEntryIndex = nil
        guard let boundary = BlockDecor.dropBoundary(
            at: point.y, frames: state.frames, entryCount: state.entryCount)
        else { return }
        onMoveBlock?(from, boundary.index)
    }
}

// MARK: - Overlay views

/// A click-through rectangle: fill and/or border, rounded.
final class DecorRectView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
    }

    required init?(coder: NSCoder) { nil }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    func configure(fill: NSColor?, border: NSColor?, cornerRadius: CGFloat) {
        layer?.backgroundColor = (fill ?? .clear).cgColor
        layer?.borderColor = border?.cgColor
        layer?.borderWidth = border == nil ? 0 : 1.5
        layer?.cornerRadius = cornerRadius
    }
}

/// A click-through dotted seam line (R6 — dotted, never a color band).
final class SeamLineView: NSView {
    var lineColor: NSColor = .separatorColor {
        didSet { needsDisplay = true }
    }

    override init(frame: NSRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { nil }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        path.line(to: CGPoint(x: bounds.width, y: bounds.midY))
        path.lineWidth = 1.5
        path.setLineDash([1.5, 4], count: 2, phase: 0)
        lineColor.setStroke()
        path.stroke()
    }
}

/// A comment face: margin card / inline strip / count badge. Always a
/// door — clicking opens the block's comments panel.
final class CommentCardView: NSView {
    enum Style: Equatable {
        case marginCard(rule: NSColor)
        case strip
        case badge
    }

    var onClick: (() -> Void)?
    private let label = NSTextField(labelWithString: "")
    private var rule: NSView?

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        label.font = .systemFont(ofSize: 11)
        label.lineBreakMode = .byTruncatingTail
        label.cell?.truncatesLastVisibleLine = true
        addSubview(label)
    }

    required init?(coder: NSCoder) { nil }

    func present(text: String, tint: NSColor, ink: NSColor, style: Style) {
        label.stringValue = text
        label.textColor = ink
        layer?.backgroundColor = tint.cgColor
        layer?.cornerRadius = 5
        rule?.removeFromSuperview()
        rule = nil
        switch style {
        case .marginCard(let ruleColor):
            label.maximumNumberOfLines = 4
            label.font = .systemFont(ofSize: 11)
            let ruleView = NSView()
            ruleView.wantsLayer = true
            ruleView.layer?.backgroundColor = ruleColor.cgColor
            addSubview(ruleView)
            rule = ruleView
        case .strip:
            label.maximumNumberOfLines = 1
            label.font = .systemFont(ofSize: 11)
        case .badge:
            label.maximumNumberOfLines = 1
            label.font = .systemFont(ofSize: 10, weight: .semibold)
        }
        toolTip = text
    }

    override func layout() {
        super.layout()
        if let rule {
            rule.frame = CGRect(x: 0, y: 0, width: 2.5, height: bounds.height)
            label.frame = bounds.insetBy(dx: 4, dy: 1).offsetBy(dx: 5, dy: 0)
                .intersection(bounds.insetBy(dx: 1, dy: 1))
        } else {
            label.frame = bounds.insetBy(dx: 6, dy: 1)
        }
    }

    override func mouseDown(with event: NSEvent) {
        onClick?()
    }
}

/// The block drag handle (R19): "⠿" in the left gutter; dragging reports
/// superview-space points so the controller can place the insertion bar
/// and land the drop.
final class DragHandleView: NSView {
    var inkColor: NSColor = .tertiaryLabelColor {
        didSet { needsDisplay = true }
    }
    var onDragBegan: (() -> Void)?
    var onDragMoved: ((CGPoint) -> Void)?
    var onDragEnded: ((CGPoint) -> Void)?

    override func draw(_ dirtyRect: NSRect) {
        let glyph = "⠿" as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12), .foregroundColor: inkColor,
        ]
        let size = glyph.size(withAttributes: attributes)
        glyph.draw(
            at: CGPoint(x: (bounds.width - size.width) / 2,
                        y: (bounds.height - size.height) / 2),
            withAttributes: attributes)
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .openHand)
    }

    override func mouseDown(with event: NSEvent) {
        onDragBegan?()
    }

    override func mouseDragged(with event: NSEvent) {
        guard let superview else { return }
        onDragMoved?(superview.convert(event.locationInWindow, from: nil))
    }

    override func mouseUp(with event: NSEvent) {
        guard let superview else { return }
        onDragEnded?(superview.convert(event.locationInWindow, from: nil))
    }
}
