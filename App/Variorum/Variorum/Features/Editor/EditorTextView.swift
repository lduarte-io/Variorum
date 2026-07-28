//
//  EditorTextView.swift
//  Variorum
//
//  The TK2 NSTextView + scroll view, configured exactly as the Phase 6 spike
//  proved out (explicit usingTextLayoutManager:true opt-in; nothing in this
//  target touches .layoutManager or any NSLayoutManager API — grep-audited
//  per the phase ground rule). Plain text: block text is the only content;
//  the block-ID attribute is bookkeeping, not styling.
//

import AppKit

@MainActor
final class EditorTextView: NSTextView {
    /// Set while a bulk-entry-classed insertion is being applied — a
    /// clipboard PASTE or a text DROP (author-ratified contract item 7,
    /// Phase 9: a drop into the open tail is bulk entry exactly like paste —
    /// segments on entry, closes the tail; a drop into an existing block is
    /// a content edit at the drop point, I4 — the flag arms nothing when the
    /// verdict isn't the tail, per Phase 7's MAJOR-3 fix).
    private(set) var isPasting = false

    /// 13d batch 4 (A15, ruled option B — rider 3): TRUE only while a
    /// SHIFT-Return keystroke's own text insertion is running, and while
    /// the model deliberately re-plays one. Never sticky: the only writer
    /// is `withSoftNewline`, whose `defer` clears it on every path — the
    /// exact shape `isPasting` already uses on this class.
    ///
    /// It exists because AppKit gives ⇧⏎ NO binding of its own: both keys
    /// dispatch `insertNewline:` and both type a plain LF (traced and
    /// pinned in `ReturnKeyTraceTests`), so the ONLY place the two can be
    /// told apart is the key event itself.
    private(set) var isSoftNewline = false

    /// Runs `body` with the soft-newline flag raised. The keystroke path
    /// uses it; so does the model's deliberate re-play after a B2 mint,
    /// which must reach the same verdict the keystroke would have.
    func withSoftNewline<T>(_ body: () -> T) -> T {
        isSoftNewline = true
        defer { isSoftNewline = false }
        return body()
    }

    /// SHIFT-Return exactly: Return (or keypad Enter) with shift and
    /// NOTHING else. Control-Return keeps its own `insertLineBreak:`
    /// binding untouched, ⌥⏎ keeps `insertNewlineIgnoringFieldEditor:`,
    /// and ⌘⇧⏎ is A14's menu key — none of them are this gesture.
    nonisolated static func isSoftNewlineKey(_ event: NSEvent) -> Bool {
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .shift
        else { return false }
        let characters = event.charactersIgnoringModifiers ?? ""
        return characters == "\r" || characters == "\u{3}"
    }

    override func keyDown(with event: NSEvent) {
        guard Self.isSoftNewlineKey(event) else {
            super.keyDown(with: event)
            return
        }
        withSoftNewline { super.keyDown(with: event) }
    }

    /// ⌘S — commit the caret block's variant (AppSpec §9 commit shortcut).
    var onCommitShortcut: (() -> Void)?

    /// N14 (13b Stage 3F) — the overlay family's LAYOUT-SETTLE trigger.
    /// Fragment-geometry consumers (badges, decor) that compute before
    /// TK2's first viewport layout read garbage frames, and no mount-time
    /// trigger runs after the layout pass — the cold-mount starve/collapse
    /// class. `viewWillDraw` runs once per display pass, on the pass that
    /// lays out whatever the storage now holds; the model coalesces this
    /// into one post-pass overlay refresh per storage generation.
    var onLayoutSettle: (() -> Void)?

    /// N14's WIDTH axis (13b Stage 3 ladder round 1, MINOR-2): a width
    /// change reflows every fragment with NO storage edit — the third
    /// geometry-generation input beside storage content and attach. The
    /// model bumps the overlay generation here so the next display pass's
    /// settle delivery reads post-reflow frames; without it the inline
    /// (book-view) editor's badges/decor sat at pre-reflow positions after
    /// a column resize (the detail editor's resize coverage is
    /// scrollView-only).
    var onWidthReflow: (() -> Void)?

    override func viewWillDraw() {
        super.viewWillDraw()
        onLayoutSettle?()
    }

    /// Phase 13, C1 (R9 — margins are sacred): the detail editor centers a
    /// bounded prose column by widening `textContainerInset` with the
    /// window; nil (the inline editor) keeps the fixed inset — its column
    /// is bounded by the book view's SwiftUI frame instead.
    var maxColumnWidth: CGFloat? {
        didSet { updateGutters() }
    }

    override func setFrameSize(_ newSize: NSSize) {
        let widthChanged = newSize.width != frame.size.width
        super.setFrameSize(newSize)
        updateGutters()
        if widthChanged { onWidthReflow?() }
    }

    private func updateGutters() {
        guard let maxColumnWidth else { return }
        let inset = EditorTypography.gutterInset(
            viewWidth: bounds.width, maxColumn: maxColumnWidth)
        if abs(textContainerInset.width - inset) > 0.5 {
            textContainerInset = NSSize(width: inset, height: textContainerInset.height)
        }
    }

    /// The pool-drag pasteboard type (Phase 10 Step 7): the payload is the
    /// pool block's ID and NOTHING else — the text copy happens inside
    /// `poolDragCopy`, the one deliberate operation (review focus 6: no
    /// text copy outside the op).
    nonisolated static let poolBlockType = NSPasteboard.PasteboardType("io.lduarte.variorum.poolblock")

    /// A pool drop: (blockID, insertion offset UTF-16, includeFan). Returns
    /// whether the drop was consumed.
    var onPoolDrop: ((String, Int, Bool) -> Bool)?

    private func poolBlockID(on pasteboard: NSPasteboard) -> String? {
        guard pasteboard.availableType(from: [Self.poolBlockType]) != nil,
              let data = pasteboard.data(forType: Self.poolBlockType)
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if poolBlockID(on: sender.draggingPasteboard) != nil { return .copy }
        return super.draggingEntered(sender)
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if poolBlockID(on: sender.draggingPasteboard) != nil { return .copy }
        return super.draggingUpdated(sender)
    }

    /// Text drops route through the same bulk-entry flag as paste
    /// (contract item 7 — resolves Phase 7's deferred PROVISIONAL as the
    /// author decided 2026-07-06). AppKit plumbing only: the routing lives
    /// in the flag + the verdict, tested through the seam paste shares.
    /// A POOL drop (Phase 10 Step 7) routes to `onPoolDrop` instead — the
    /// insertion offset comes from the drop point; holding ⌥ carries the
    /// whole fan (`includeFan` — the plan's at-build-time call: a modifier).
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let blockID = poolBlockID(on: sender.draggingPasteboard), let onPoolDrop {
            let point = convert(sender.draggingLocation, from: nil)
            let offset = characterIndexForInsertion(at: point)
            let includeFan = NSEvent.modifierFlags.contains(.option)
            return onPoolDrop(blockID, offset, includeFan)
        }
        return withPasteFlag { super.performDragOperation(sender) }
    }

    /// The context-menu door for structural gestures (Phase 9): the view
    /// model supplies items whose enablement came from THE planner — the
    /// same brain as the menu bar and shortcuts.
    struct StructuralMenuItem {
        let title: String
        let enabled: Bool
        let action: () -> Void
    }

    var structuralMenuItems: (() -> [StructuralMenuItem])?

    override func menu(for event: NSEvent) -> NSMenu? {
        let inherited = super.menu(for: event)
        guard let items = structuralMenuItems?(), !items.isEmpty else { return inherited }
        let menu = inherited ?? NSMenu()
        for (i, item) in items.enumerated() {
            let menuItem = NSMenuItem(
                title: item.title,
                action: #selector(StructuralMenuTrampoline.fire(_:)),
                keyEquivalent: "")
            let trampoline = StructuralMenuTrampoline(enabled: item.enabled, action: item.action)
            menuItem.target = trampoline
            menuItem.representedObject = trampoline  // retains it for the menu's life
            menu.insertItem(menuItem, at: i)
        }
        menu.insertItem(NSMenuItem.separator(), at: items.count)
        return menu
    }

    override func paste(_ sender: Any?) {
        withPasteFlag { pasteAsPlainText(sender) } // plain text: never import foreign styling
    }

    /// Runs `body` with the paste flag raised — the paste path itself, and a
    /// seam for tests to drive bulk entry without the global pasteboard.
    func withPasteFlag<T>(_ body: () -> T) -> T {
        isPasting = true
        defer { isPasting = false }
        return body()
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
           event.charactersIgnoringModifiers == "s",
           let onCommitShortcut {
            onCommitShortcut()
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    /// Builds the spike-proven editor stack. The precondition is the TK2
    /// opt-in guarantee; the canary guards the rest of the session.
    ///
    /// 13d batch 5 (A22): the scroll view is a `TypewriterScrollView`, so
    /// Write's full-document editor always carries about a viewport-page of
    /// room below the last line. The inline editor deliberately does NOT —
    /// it has no scroll view of its own (it lives in the book view's), and
    /// her ask and the A47b story are both about the POST editor.
    static func makeEditor() -> (scrollView: NSScrollView, textView: EditorTextView) {
        let textView = EditorTextView(usingTextLayoutManager: true)
        precondition(textView.textLayoutManager != nil, "TK2 opt-in failed at construction")

        // R9 (Phase 13 C1): generous top air + the centered bounded column
        // (the horizontal inset is dynamic — updateGutters).
        textView.textContainerInset = NSSize(width: EditorTypography.minGutter, height: 24)
        textView.maxColumnWidth = EditorTypography.maxColumnWidth
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.size = NSSize(
            width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.font = EditorDocument.baseFont
        // The uniform paragraph gap (2026-07-12 ruling, presentation
        // half): typed text carries the same style every surface write
        // applies — one look, stored nowhere.
        textView.defaultParagraphStyle = EditorDocument.baseParagraphStyle
        textView.typingAttributes = EditorDocument.baseAttributes
        // Substitutions rewrite text behind the caret; keep the surface
        // literal (they would also route through the edit pipeline, but the
        // author's prose should not be silently rewritten).
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        // Spell checking: 13d batch 4 (A24) makes the level a setting. The
        // DEFAULT is byte-identical to what shipped here before — both flags
        // off, spelling reachable via Edit ▸ Spelling and Grammar — so a
        // Mac that never opens Settings behaves exactly as it did.
        SpellcheckLevel.current.apply(to: textView)

        // Pool drags land here too (Phase 10 Step 7) — additive, never
        // replacing the text types NSTextView registers for itself.
        textView.registerForDraggedTypes(
            textView.registeredDraggedTypes + [poolBlockType])

        let scrollView = TypewriterScrollView()
        scrollView.contentView = TypewriterClipView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = textView
        return (scrollView, textView)
    }

    /// The INLINE editor variant (Phase 10 Step 3): the same spike-proven
    /// configuration with NO scroll view of its own — it lives inside the
    /// multi-post container's scroll, sized to content by its SwiftUI
    /// wrapper (the coordinator publishes layout height).
    static func makeInlineEditor() -> EditorTextView {
        let textView = EditorTextView(usingTextLayoutManager: true)
        precondition(textView.textLayoutManager != nil, "TK2 opt-in failed at construction")

        textView.textContainerInset = NSSize(
            width: EditorTypography.inlineSurfaceInset,
            height: EditorTypography.inlineSurfaceInset)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isVerticallyResizable = false  // the wrapper sizes the frame
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.size = NSSize(
            width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.font = EditorDocument.baseFont
        // The uniform paragraph gap (2026-07-12 ruling, presentation
        // half): typed text carries the same style every surface write
        // applies — one look, stored nowhere.
        textView.defaultParagraphStyle = EditorDocument.baseParagraphStyle
        textView.typingAttributes = EditorDocument.baseAttributes
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        SpellcheckLevel.current.apply(to: textView)  // A24 (default = off)
        textView.registerForDraggedTypes(
            textView.registeredDraggedTypes + [poolBlockType])
        return textView
    }
}

/// **TYPEWRITER ROOM — A22 (author ruling, 13d sitting 2026-07-28).**
/// Her ask, from the A47b sitting: *let me scroll into a page of empty space
/// so I can keep typing high on the screen.* She had been building that room
/// BY HAND out of typed newlines at the end of a post — which the ratified
/// edge rules never store (a whitespace-only open tail never mints), so it
/// looked durable and silently evaporated. Her ruling settled both halves:
/// the trimming rules STAY exactly as ratified, and the room is the real
/// answer — ALWAYS ON, no setting.
///
/// **The room is ALLOWANCE, never content.** It is `contentInsets.bottom` on
/// the scroll view: zero bytes stored, zero text written, `renderedText`,
/// export and the bridge byte-untouched, and the document itself unchanged —
/// which is also why it composes with the phantom heal for free (13c 1E lays
/// out one long block at a time and re-frames the text view; the room is
/// measured from the VIEWPORT and simply sits below whatever height that
/// leaves — the heal's law is untouched, and `LongBlockLayout` never learns
/// this exists).
///
/// **The mechanism was CHOSEN BY MEASUREMENT, and the first choice was
/// wrong** (13d batch 5, macOS 26.4.1 — the whole story, because it is the
/// kind of thing a future session would otherwise "simplify" back):
///
/// - `NSScrollView.contentInsets.bottom` was built first, and on the numbers
///   it looked ideal: a 300 pt bottom inset left the clip's height exactly
///   unchanged (400.0 → 400.0), extended the constrained scroll range by
///   exactly 300 (2406.5 → 2700.5), and made the vertical scroller reflect
///   the extra range (knobProportion 0.1425 → 0.1290). **It also broke
///   clicking into her own text.** Measured on the mounted editor: with the
///   inset set, everything below the top ~17 pt of the viewport hit-tested
///   to an AppKit backdrop view — at depths where her prose was VISIBLY
///   DRAWN (ink present, hit test wrong). AppKit lays a backdrop over the
///   inset region; the document still draws through it, so the failure is
///   invisible until you click. 13c 1C's dead-strip tripwire — written to
///   fire "if this class ever grows from a sliver into a band of page" — is
///   what caught it.
/// - So the room is an `NSClipView.constrainBoundsRect` allowance instead:
///   the same measured scroll range, no view added, no hit testing touched.
///   **Recorded cost:** the vertical scroller's knob does not cover the room
///   (AppKit sizes it from the document rect), so the room is reached by
///   ordinary scrolling — wheel, trackpad, keyboard — not by dragging the
///   knob to the very bottom. Flagged for her walk rather than hidden.
///
/// **The click had to be BUILT, and a pin is what found that out too.** The
/// room is covered by no view — `NSClipView` hit-tests transparently outside
/// its document — so a click there reached nothing at all and left the caret
/// where it was (measured, after a first reading that had mistaken a
/// pre-existing end-of-text selection for the click's work). Her ruling —
/// *a click in the room lands the caret at the end of the text* — is honoured
/// by claiming exactly that region in `hitTest` and answering with the text
/// view's OWN insertion-point arithmetic, which is what a click in the
/// phantom does (batch 1C).
@MainActor
final class TypewriterScrollView: NSScrollView {
    /// Off ⇒ byte-identical to a plain NSScrollView (nothing is written).
    var typewriterRoomEnabled = true

    /// The allowance the clip currently grants, in points.
    var typewriterRoom: CGFloat { (contentView as? TypewriterClipView)?.room ?? 0 }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateTypewriterRoom()
    }

    override func layout() {
        super.layout()
        updateTypewriterRoom()
    }

    /// Is `point` (this view's own coordinates) in the ROOM — over the
    /// viewport, below everything the document draws, and not on a scroller?
    private func isInRoom(_ point: NSPoint) -> Bool {
        guard typewriterRoomEnabled, typewriterRoom > 0,
              let document = documentView, contentView.frame.contains(point)
        else { return false }
        for scroller in [verticalScroller, horizontalScroller] {
            if let scroller, !scroller.isHidden, scroller.frame.contains(point) { return false }
        }
        let inClip = convert(point, to: contentView)
        return inClip.y > document.frame.maxY
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Only the room is claimed, and only when it is genuinely below the
        // document: everything else — her text, the scrollers — falls
        // through to AppKit untouched. (`super` answers nil in the room,
        // which is why the click needed claiming at all.)
        if isInRoom(convert(point, from: superview)) { return self }
        return super.hitTest(point)
    }

    override func mouseDown(with event: NSEvent) {
        let local = convert(event.locationInWindow, from: nil)
        guard isInRoom(local), let textView = documentView as? NSTextView else {
            super.mouseDown(with: event)
            return
        }
        window?.makeFirstResponder(textView)
        // The text view's own arithmetic, so the room behaves exactly like
        // the space below the last line always has: the nearest insertion
        // point, which for a point past every line IS the end.
        let inText = textView.convert(event.locationInWindow, from: nil)
        let offset = textView.characterIndexForInsertion(at: inText)
        textView.setSelectedRange(NSRange(location: offset, length: 0))
    }

    /// CHANGE-GATED (the A47c discipline): a same-value pass writes nothing,
    /// so this cannot chase its own layout — and the room is computed from
    /// the viewport, which the allowance does not move, so it converges in
    /// one pass.
    func updateTypewriterRoom() {
        guard let clip = contentView as? TypewriterClipView else { return }
        let room = typewriterRoomEnabled
            ? TypewriterRoom.height(
                viewport: clip.bounds.height,
                lineHeight: TypewriterRoom.lineHeight(of: EditorDocument.baseFont))
            : 0
        guard abs(clip.room - room) > 0.5 else { return }
        clip.room = room
    }
}

/// The room itself: scrolling may go `room` points past the document's end.
/// Nothing else changes — no view is added, no frame is inset, and hit
/// testing over the document is untouched (which the `contentInsets`
/// candidate could not say).
@MainActor
final class TypewriterClipView: NSClipView {
    var room: CGFloat = 0

    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var rect = super.constrainBoundsRect(proposedBounds)
        guard room > 0, let document = documentView, isFlipped else { return rect }
        let maxY = max(0, document.frame.height + room - rect.height)
        rect.origin.y = min(max(proposedBounds.origin.y, 0), maxY)
        return rect
    }
}

/// The room's arithmetic, pure (so the rule is pinned, not just observed).
nonisolated enum TypewriterRoom {
    /// About one viewport-page (her words), **less one line of prose** — so
    /// at the very bottom of the scroll the last line of her text sits at
    /// the top of the window rather than one pixel above it. Without that
    /// subtraction the maximum scroll puts the text entirely out of view,
    /// which is room she can't type into.
    static func height(viewport: CGFloat, lineHeight: CGFloat) -> CGFloat {
        max(0, viewport - max(0, lineHeight))
    }

    /// One line of a font, from the font's own metrics — never
    /// `NSLayoutManager.defaultLineHeight` (a TK1 API; TEXTKIT2 §4 rule 2).
    static func lineHeight(of font: NSFont) -> CGFloat {
        (font.ascender - font.descender + font.leading).rounded(.up)
    }
}

/// Target for the structural context-menu items: carries the action closure
/// and answers menu validation with the planner's verdict (NSMenu
/// auto-enablement asks the target, so the standard items keep their own
/// validation untouched).
@MainActor
private final class StructuralMenuTrampoline: NSObject, NSMenuItemValidation {
    private let enabled: Bool
    private let action: () -> Void

    init(enabled: Bool, action: @escaping () -> Void) {
        self.enabled = enabled
        self.action = action
    }

    @objc func fire(_ sender: Any?) {
        action()
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        enabled
    }
}
