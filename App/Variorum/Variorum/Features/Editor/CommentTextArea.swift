//
//  CommentTextArea.swift
//  Variorum (Mac)
//
//  VX-179 U3 — THE COMMENTS PANEL'S WRITING CONTROL (the F-U3-1 ruling,
//  2026-10-12: option (a), the panel-private home).
//
//  ── WHY THIS REPLACED A `TextEditor` ────────────────────────────────────
//  Her report: *"the comment pane's cursor to start typing in is misaligned"*
//  — the caret left of and taller than "Write a comment…". The trace
//  (MEASURED offscreen on macOS 27, the record's U3-b) found the mechanism:
//  the panel drew its placeholder as a SwiftUI overlay padded by a GUESS at
//  `TextEditor`'s private geometry (top 8 / leading 5). On this OS the text
//  view under `TextEditor` has `textContainerInset` (0, 0), so the
//  placeholder sat a full 8 pt below the line the caret blinks on and her
//  typing lands on — a line-high caret drawn 8 pt above the placeholder's
//  glyphs is exactly "left of and taller than". The leading 5 only matched
//  because it is `NSTextContainer`'s default padding. The same false 8 gave
//  every comment row 16 pt of dead air (its height ruler padded top AND
//  bottom) and dropped Terminal's `// ` mark 8 pt below its line.
//
//  A `TextEditor`'s geometry is not ours to know, so no constant placed
//  beside it can stay right. This control's geometry IS ours: the inset,
//  the padding and the typing attributes are set here, from ONE place
//  (`CommentsPanelMetrics` and `CommentTextStyle`), and everything that has
//  to sit on the text's first line is laid out by the SAME machinery:
//
//  - **The placeholder is a TWIN** — a non-editable TK2 text view with the
//    identical configuration (font, inset, padding, width), behind the
//    editable one, shown only while the area is empty. The same engine lays
//    the same font out under the same insets, so the placeholder's first
//    glyph sits where her first typed glyph will, on the caret's own line.
//    (The cheaper `draw(_:)` override was measured 0.5 pt high in Terminal —
//    string drawing uses the unrounded ascender, TK2 rounds the line — and
//    the ruling rejected it: close is not "by construction".)
//  - **The voice's mark is a twin too.** SwiftUI does not read a
//    representable's `firstBaselineOffsetFromTop` (measured — an HStack's
//    first-baseline alignment ignores it), so a SwiftUI label beside this
//    control could only match its baseline by coincidence of two engines'
//    line metrics. A twin beside the text has the text's own baseline.
//  - **A row's height is the real text view's** (`PaneMeasurement` — the one
//    measurement brain), never an invisible ruler's guess.
//
//  ── WHAT IS DELIBERATELY UNCHANGED ──────────────────────────────────────
//  The keys: this view claims none. ⏎ and ⇧⏎ are AppKit's own newline
//  (a comment is free prose); ⌘⏎ and ⎋ are the panel's local key monitor's,
//  which sees them first (`CommentPanelKeyMonitor`, byte-untouched). An ⎋
//  the panel does not handle falls through to `cancelOperation:` and up the
//  responder chain to the sheet's or popover's own close — MEASURED to be
//  exactly what SwiftUI's own `PlatformTextView` did (neither overrides it).
//  The focus SEMANTICS: the panel still opens with the caret in the add
//  area, and leaving an edited comment still saves it — the panel's own
//  `focus` value is fed by this view's first-responder reports instead of
//  `@FocusState`, and `.onChange(of: focus)` reads it exactly as before.
//
//  **Not a second text surface in P-3's sense** (`CaptureTextView`'s note,
//  which holds here word for word): a comment is in no block — no identity
//  attributes, no `BlockRangeIndex`, no `PaneTextAuthority`, no router
//  claim, no ring. `TextEditor` was an `NSTextView` too; what changed is who
//  owns its geometry. TEXTKIT2 §4's practices are kept: TK2 opted into at
//  init on every view, no TK1 API, the fallback canary armed.
//

import AppKit
import SwiftUI

// MARK: - The look (the voice, as AppKit values)

/// What a comment area wears — derived from the tokens its host resolved,
/// never chosen here, and ONE value so a host cannot half-dress it (the
/// `CaptureTextStyle` shape).
struct CommentTextStyle: Equatable {
    /// The voice's writing face — what `tokens.body` renders in both voices
    /// (Terminal: monospaced 14 · Study: Iowan Old Style 16), asked of the
    /// one typography brain.
    let font: NSFont
    let ink: NSColor
    let caret: NSColor
    let placeholderInk: NSColor
    /// The voice's comment mark's ink — the panel row's shipped 0.75 of the
    /// comment ink.
    let markInk: NSColor

    @MainActor
    init(tokens: VoiceTokens, ink: Color) {
        self.font = EditorTypography.resolve(voice: tokens.voice, inlineComments: false).font
        self.ink = NSColor(ink)
        self.caret = NSColor(tokens.accent)
        self.placeholderInk = NSColor(tokens.faint)
        self.markInk = NSColor(tokens.commentInk).withAlphaComponent(
            CommentsPanelMetrics.markInkOpacity)
    }

    /// **The typing attributes — OURS, stated, never inherited.** The trace
    /// found them already carrying the applied font on this OS; that was
    /// SwiftUI's behaviour, not a promise. Set at every style change and
    /// re-asserted whenever the area empties, so the caret of an empty area
    /// is this font's line by construction.
    var typingAttributes: [NSAttributedString.Key: Any] {
        [.font: font, .foregroundColor: ink, .paragraphStyle: NSParagraphStyle.default]
    }

    /// A twin's attributes: the same font and paragraph style as the text it
    /// stands in for — the line metrics ARE the font's — in its own ink.
    func twinAttributes(ink: NSColor) -> [NSAttributedString.Key: Any] {
        [.font: font, .foregroundColor: ink, .paragraphStyle: NSParagraphStyle.default]
    }
}

// MARK: - The control

/// **One comment's writing area** — a comment row (grows with its text,
/// never scrolls; the panel's list scrolls) or the add area (exactly the
/// room it is given, scrolling itself so a long draft follows the caret).
struct CommentTextArea: NSViewRepresentable {
    @Binding var text: String
    let style: CommentTextStyle
    /// Shown on the first line while the area is empty, by a configured twin.
    var placeholder: String?
    /// The voice's comment mark (`tokens.commentPrefix` — "// " in Terminal,
    /// "" in Study), drawn beside the text by a configured twin. Never part
    /// of the text: an editable area cannot hold the idiom without writing
    /// it into her prose.
    var mark: String?
    /// A ROW grows with its text and never scrolls; the ADD area (false)
    /// fills the height it is offered and scrolls itself.
    var growsWithText = true
    /// A counted focus REQUEST (`CaptureTextView`'s door): any change puts
    /// the caret here. A request that arrives before the area has a window
    /// is HELD and served on arrival (the panel's open-focused-on-add).
    var focusRequest = 0
    /// Where the caret is — reported from this area's own first-responder
    /// changes, on the next main-queue turn (never inside a view update).
    var onFocusChange: (Bool) -> Void = { _ in }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> CommentTextAreaView {
        let area = CommentTextAreaView(scrolls: !growsWithText)
        let view = area.textView
        view.delegate = context.coordinator
        view.onCaretChange = { [weak coordinator = context.coordinator] inArea in
            DispatchQueue.main.async {
                coordinator?.parent.onFocusChange(inArea)
            }
        }
        view.onMarkedTextChange = { [weak area] in area?.refreshPlaceholder() }
        // Spelling follows the app's ONE this-Mac setting, as every text
        // surface in the app does (`SpellcheckLevel`).
        SpellcheckLevel.current.apply(to: view)
        context.coordinator.area = area
        context.coordinator.lastFocusRequest = focusRequest
        if focusRequest > 0 { area.requestFocus() }
        context.coordinator.adopt(self, into: area)
        // TEXTKIT2 §4's third practice: a silent TK1 downgrade never passes
        // unnoticed — on the editable view and on each twin.
        for textView in area.allTextViews {
            let canary = FallbackCanary()
            canary.arm(for: textView)
            context.coordinator.canaries.append(canary)
        }
        return area
    }

    func updateNSView(_ area: CommentTextAreaView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.adopt(self, into: area)
        if focusRequest != context.coordinator.lastFocusRequest {
            context.coordinator.lastFocusRequest = focusRequest
            area.requestFocus()
        }
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize, nsView area: CommentTextAreaView, context: Context
    ) -> CGSize? {
        let width = proposal.width ?? area.bounds.width
        guard growsWithText else {
            // The add area takes exactly the room it is offered.
            return CGSize(width: width, height: proposal.height ?? area.bounds.height)
        }
        guard width > 0 else { return nil }
        return CGSize(width: width, height: area.rowHeight(forWidth: width))
    }

    static func dismantleNSView(_ area: CommentTextAreaView, coordinator: Coordinator) {
        for canary in coordinator.canaries { canary.disarm() }
        coordinator.canaries.removeAll()
        coordinator.stopObservingUndo()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CommentTextArea
        weak var area: CommentTextAreaView?
        var canaries: [FallbackCanary] = []
        var lastFocusRequest = 0
        private var appliedStyle: CommentTextStyle?
        private var appliedPlaceholder: String??
        private var appliedMark: String??

        /// **This area's own undo history** (VX-179 U3-g — a CRASH, found in
        /// self-review and measured offscreen in the shipped `TextEditor` as
        /// much as here: after she files a comment the panel clears the add
        /// area programmatically, and ⌘Z then replayed typing-undo actions
        /// naming ranges of the OLD text against the empty string —
        /// `NSRangeException`, uncaught). A programmatic replacement means
        /// the words that history described have left the box (filed,
        /// reverted, restored from the park, or replaced by the store), so
        /// the history ends with them. It has to be the area's OWN manager:
        /// `removeAllActions(withTarget:)` on the text view or its storage
        /// does not reach TK2's registrations (measured), and clearing the
        /// window's manager could reach other text's history. ⌘Z still
        /// arrives by AppKit's road — `undo:` travels to the window, which
        /// undoes through the first responder's `undoManager`, answered here.
        let undoHistory = UndoManager()
        private var undoObservers: [NSObjectProtocol] = []

        init(_ parent: CommentTextArea) {
            self.parent = parent
            super.init()
            // **An undo or redo is an edit the binding must hear** (U3-g's
            // second half, measured offscreen in the shipped `TextEditor`
            // too): AppKit does NOT call `textDidChange` for an undo or a
            // redo — TK2 and TK1 alike, while the storage does change — so
            // after ⌘Z the box showed one text and the panel's draft held
            // another, and ⌘⏎ filed the words she had just undone. This
            // area's manager is its own, so its two notifications are
            // exactly "this text was undone or redone".
            for name in [Notification.Name.NSUndoManagerDidUndoChange,
                         .NSUndoManagerDidRedoChange] {
                undoObservers.append(NotificationCenter.default.addObserver(
                    forName: name, object: undoHistory, queue: .main
                ) { [weak self] _ in
                    MainActor.assumeIsolated { self?.textChangedOutsideTyping() }
                })
            }
        }

        func stopObservingUndo() {
            for token in undoObservers { NotificationCenter.default.removeObserver(token) }
            undoObservers.removeAll()
        }

        func undoManager(for view: NSTextView) -> UndoManager? {
            view === area?.textView ? undoHistory : nil
        }

        /// The view's text moved without `textDidChange` (an undo or redo):
        /// the binding, the placeholder and the measured height follow it,
        /// exactly as after a keystroke.
        private func textChangedOutsideTyping() {
            guard let area else { return }
            if parent.text != area.textView.string {
                parent.text = area.textView.string
            }
            area.textDidChangeByTyping(style: parent.style)
        }

        /// Every write here is GATED (the A47c lesson — an unguarded write on
        /// a live text view is never free, and `updateNSView` runs often).
        func adopt(_ parent: CommentTextArea, into area: CommentTextAreaView) {
            if appliedStyle != parent.style {
                appliedStyle = parent.style
                area.apply(parent.style)
                // A style change re-sets the twins' words in the new face.
                appliedPlaceholder = nil
                appliedMark = nil
            }
            if appliedPlaceholder != .some(parent.placeholder) {
                appliedPlaceholder = .some(parent.placeholder)
                area.setPlaceholder(parent.placeholder, style: parent.style)
            }
            if appliedMark != .some(parent.mark) {
                appliedMark = .some(parent.mark)
                area.setMark(parent.mark, style: parent.style)
            }
            if area.textView.string != parent.text {
                area.adoptText(parent.text, style: parent.style)
                // The text she was undoing through is gone (U3-g).
                undoHistory.removeAllActions()
            }
        }

        func textDidChange(_ notification: Notification) {
            guard let area else { return }
            parent.text = area.textView.string
            area.textDidChangeByTyping(style: parent.style)
        }
    }
}

// MARK: - The view

/// The control's AppKit body: the editable text view (inside a scroll view
/// for the add area), with its twins — the placeholder BEHIND it at the same
/// frame, the mark BESIDE it.
@MainActor
final class CommentTextAreaView: NSView {
    let textView = CommentNSTextView(usingTextLayoutManager: true)
    private let scrollView: NSScrollView?
    private(set) var placeholderView: CommentTwinTextView?
    private(set) var markView: CommentTwinTextView?
    private var markWidth: CGFloat = 0

    override var isFlipped: Bool { true }

    /// Every TK2 view this area owns (the canary arms each).
    var allTextViews: [NSTextView] {
        [textView] + [placeholderView, markView].compactMap { $0 }
    }

    init(scrolls: Bool) {
        if scrolls {
            let scroll = NSScrollView()
            scroll.drawsBackground = false
            scroll.hasVerticalScroller = true
            scroll.autohidesScrollers = true
            scroll.hasHorizontalScroller = false
            // The area's insets are OURS: no automatic content inset may move
            // the text away from where its twin lays out.
            scroll.automaticallyAdjustsContentInsets = false
            scroll.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            scrollView = scroll
        } else {
            scrollView = nil
        }
        super.init(frame: .zero)
        Self.configure(textView, editable: true)
        textView.allowsUndo = true
        textView.isRichText = false
        if let scrollView {
            textView.isVerticallyResizable = true
            textView.autoresizingMask = [.width]
            textView.maxSize = NSSize(
                width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            scrollView.documentView = textView
            addSubview(scrollView)
        } else {
            // A row is sized by the panel from its measured text; the view
            // never resizes itself (and, outside a scroll view, never takes
            // the panel's wheel events — they go up the responder chain).
            textView.isVerticallyResizable = false
            addSubview(textView)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    /// The ONE configuration every view of the area shares — the editable
    /// text and both twins — which is what makes the twins land on the
    /// text's own line: the same inset, the same padding, the same container
    /// behaviour, laid out by the same engine.
    private static func configure(_ view: NSTextView, editable: Bool) {
        view.isEditable = editable
        view.isSelectable = editable
        view.drawsBackground = false
        view.isHorizontallyResizable = false
        view.textContainerInset = CommentsPanelMetrics.textInset
        view.textContainer?.lineFragmentPadding = CommentsPanelMetrics.lineFragmentPadding
        view.textContainer?.widthTracksTextView = true
        view.textContainer?.size = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        view.minSize = .zero
    }

    // MARK: Style, twins, text

    func apply(_ style: CommentTextStyle) {
        textView.font = style.font
        textView.textColor = style.ink
        textView.insertionPointColor = style.caret
        textView.typingAttributes = style.typingAttributes
    }

    func setPlaceholder(_ placeholder: String?, style: CommentTextStyle) {
        guard let placeholder, !placeholder.isEmpty else {
            placeholderView?.removeFromSuperview()
            placeholderView = nil
            return
        }
        let twin = placeholderView ?? makeTwin(below: true)
        placeholderView = twin
        twin.textStorage?.setAttributedString(NSAttributedString(
            string: placeholder, attributes: style.twinAttributes(ink: style.placeholderInk)))
        refreshPlaceholder()
        needsLayout = true
    }

    func setMark(_ mark: String?, style: CommentTextStyle) {
        guard let mark, !mark.isEmpty else {
            markView?.removeFromSuperview()
            markView = nil
            markWidth = 0
            needsLayout = true
            return
        }
        let twin = markView ?? makeTwin(below: false)
        markView = twin
        // The mark never wraps: its column is exactly its own width.
        twin.textContainer?.widthTracksTextView = false
        twin.textContainer?.size = NSSize(
            width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        twin.textStorage?.setAttributedString(NSAttributedString(
            string: mark, attributes: style.twinAttributes(ink: style.markInk)))
        markWidth = CommentsPanelMetrics.markColumn(
            measured: (mark as NSString).size(withAttributes: [.font: style.font]).width)
        needsLayout = true
        invalidateIntrinsicContentSize()
    }

    private func makeTwin(below: Bool) -> CommentTwinTextView {
        let twin = CommentTwinTextView(usingTextLayoutManager: true)
        Self.configure(twin, editable: false)
        if below {
            // BEHIND the text (and its caret): the twin only ever shows while
            // the area is empty, and the caret must draw over it.
            addSubview(twin, positioned: .below, relativeTo: nil)
        } else {
            addSubview(twin)
        }
        return twin
    }

    /// A programmatic adopt (the panel clears a filed draft, restores a
    /// parked one, reverts an edit) — the caret kept where it can be.
    func adoptText(_ text: String, style: CommentTextStyle) {
        let selected = textView.selectedRange()
        textView.string = text
        let length = (text as NSString).length
        textView.textStorage?.setAttributes(
            style.typingAttributes, range: NSRange(location: 0, length: length))
        textView.typingAttributes = style.typingAttributes
        textView.setSelectedRange(NSRange(location: min(selected.location, length), length: 0))
        refreshPlaceholder()
        invalidateIntrinsicContentSize()
        needsLayout = true
    }

    func textDidChangeByTyping(style: CommentTextStyle) {
        if textView.string.isEmpty {
            // Emptied by her hand: the typing attributes are re-stated, so
            // the empty area's caret is the font's line, always.
            textView.typingAttributes = style.typingAttributes
        }
        refreshPlaceholder()
        invalidateIntrinsicContentSize()
    }

    /// The placeholder shows only over an EMPTY area with no marked text in
    /// flight (an input method's composition is text she is writing).
    func refreshPlaceholder() {
        placeholderView?.isHidden = !textView.string.isEmpty || textView.hasMarkedText()
    }

    // MARK: Geometry

    /// A row's height at `width`: the real text view's measured content
    /// (`PaneMeasurement` — the laid-out text plus the inset, top and
    /// bottom), never an estimate.
    func rowHeight(forWidth width: CGFloat) -> CGFloat {
        let textWidth = max(1, width - markWidth)
        if textView.frame.width != textWidth {
            textView.frame.size.width = textWidth
        }
        textView.textContainer?.size = NSSize(
            width: max(1, textWidth - CommentsPanelMetrics.textInset.width * 2),
            height: .greatestFiniteMagnitude)
        return CommentsPanelMetrics.rowHeight(measured: PaneMeasurement.height(of: textView))
    }

    override func layout() {
        super.layout()
        let textFrame = NSRect(
            x: markWidth, y: 0, width: max(0, bounds.width - markWidth), height: bounds.height)
        markView?.frame = NSRect(x: 0, y: 0, width: markWidth, height: bounds.height)
        if let scrollView {
            scrollView.frame = textFrame
            // The add area: the text view is never shorter than the room, so
            // a click ANYWHERE in it lands the caret (§2 D's contract).
            let room = scrollView.contentSize
            textView.minSize = NSSize(width: 0, height: room.height)
            if textView.frame.height < room.height || textView.frame.width != room.width {
                textView.frame.size = NSSize(
                    width: room.width, height: max(textView.frame.height, room.height))
            }
        } else {
            textView.frame = textFrame
        }
        // The placeholder twin sits EXACTLY on the editable view's frame —
        // read from the view itself (its origin inside this area), never
        // re-derived — so the two lay the same font out from the same point.
        if let placeholderView {
            let origin = textView.convert(NSPoint.zero, to: self)
            placeholderView.frame = NSRect(
                x: origin.x, y: origin.y, width: textView.bounds.width,
                height: max(0, bounds.height - origin.y))
        }
    }

    // MARK: Focus and clicks

    private var focusOnArrival = false

    /// The counted request's act: the caret here now, or the moment the area
    /// reaches a window (served one turn later, when the window is settled).
    func requestFocus() {
        guard let window else {
            focusOnArrival = true
            return
        }
        guard window.firstResponder !== textView else { return }
        window.makeFirstResponder(textView)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard focusOnArrival, window != nil else { return }
        focusOnArrival = false
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window,
                  window.firstResponder !== self.textView else { return }
            window.makeFirstResponder(self.textView)
        }
    }

    /// Anywhere in the area is the text's — the mark's column, the gaps: a
    /// click there lands the caret in the text (the nearest place to it).
    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let hit = super.hitTest(point) else { return nil }
        if hit === self || hit is CommentTwinTextView { return textView }
        return hit
    }
}

// MARK: - The text views

/// The editable text: ONE behaviour added — it says where the caret is.
@MainActor
final class CommentNSTextView: NSTextView {
    var onCaretChange: ((Bool) -> Void)?
    /// An input method's composition started, changed or ended — the
    /// placeholder must hide while she composes.
    var onMarkedTextChange: (() -> Void)?

    override func becomeFirstResponder() -> Bool {
        let became = super.becomeFirstResponder()
        if became { onCaretChange?(true) }
        return became
    }

    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        if resigned { onCaretChange?(false) }
        return resigned
    }

    /// A focused row that leaves its window (its comment deleted, the panel
    /// closing) does not always hear `resignFirstResponder`; say it went.
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil, window?.firstResponder === self { onCaretChange?(false) }
        super.viewWillMove(toWindow: newWindow)
    }

    override func setMarkedText(
        _ string: Any, selectedRange: NSRange, replacementRange: NSRange
    ) {
        super.setMarkedText(string, selectedRange: selectedRange, replacementRange: replacementRange)
        onMarkedTextChange?()
    }

    override func unmarkText() {
        super.unmarkText()
        onMarkedTextChange?()
    }
}

/// A twin: words laid out exactly like the editable text, never touched.
@MainActor
final class CommentTwinTextView: NSTextView {
    override var acceptsFirstResponder: Bool { false }
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}
