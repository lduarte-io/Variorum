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

    /// SHIFT-Return exactly: Return (or keypad Enter) with shift and no
    /// other MEANING-BEARING modifier. Control-Return keeps its own
    /// `insertLineBreak:` binding untouched, ⌥⏎ keeps
    /// `insertNewlineIgnoringFieldEditor:`, and ⌘⇧⏎ is A14's menu key —
    /// none of them are this gesture.
    ///
    /// The mask is the four modifiers that DISTINGUISH gestures, not the
    /// whole device-independent word (13d cold review, F-2): AppKit sets
    /// `.capsLock` on every key event while caps lock is LATCHED and
    /// `.numericPad`/`.function` on every keypad key — state and hardware
    /// flags, not meaning. Testing for exactly-shift across the whole word
    /// made ⇧⏎ silently not-the-gesture with caps lock on (the tail opened
    /// as if plain ⏎ — a ruled gesture reading as a dead key), and made
    /// the keypad-Enter arm below unreachable from real hardware.
    nonisolated static func isSoftNewlineKey(_ event: NSEvent) -> Bool {
        let meaningful: NSEvent.ModifierFlags = [.shift, .command, .control, .option]
        guard event.modifierFlags.intersection(meaningful) == .shift
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

    /// **QoL batch 3 (L6) — TRUE only while a FIND-BAR replacement is being
    /// applied**, and only ever by `EditorFind`'s own application loop. Never
    /// sticky: the single writer is `withFindReplace`, whose `defer` clears it
    /// on every path — the exact shape `isPasting` and `isSoftNewline` already
    /// use on this class.
    ///
    /// It exists for ONE decision: a cross-block edit with a replacement does
    /// not refuse on this editor — it routes to `planCrossBlockEdit`, which
    /// MERGES the blocks (the ratified 2026-07-09 merge-then-edit, made for a
    /// deliberate hand-made selection). A find-driven replacement must never
    /// restructure her post, so under this flag the cross-block arm speaks
    /// instead of planning.
    private(set) var isFindReplacing = false

    func withFindReplace<T>(_ body: () -> T) -> T {
        isFindReplacing = true
        defer { isFindReplacing = false }
        return body()
    }

    /// The find bar's replacements, handed to the model (which pre-checks
    /// every range and then re-drives them through the ordinary input path).
    var onFindReplace: (([NSRange], [String]) -> Void)?

    /// **`NSTextFinderClient.shouldReplaceCharactersInRanges:withStrings:`,
    /// answered NO — always — and deliberately.**
    ///
    /// `NSTextView` implements this selector privately and declares no
    /// `NSTextFinderClient` conformance, so there is no visible method to
    /// override and no `super` to call; this implementation shadows the
    /// private one for our subclass. That is a documented, public PROTOCOL
    /// method, not private API, and the shadowing is the point:
    ///
    /// > *"Before a replace operation is performed, NSTextFinder calls the
    /// > first method to determine if a replacement should take place. If it
    /// > returns NO, then the characters in the given ranges will not be
    /// > replaced."* — `NSTextFinder.h`
    ///
    /// We say NO because MEASUREMENT (M1b, 26.5.2) showed AppKit applies an
    /// approved Replace All as ONE coalesced storage transaction spanning
    /// every match — `{4, 48}` across two block seams for three matches —
    /// which our block-routed pipeline can only read as a desync (it crashed
    /// the measurement outright). The replacements are re-driven one at a
    /// time by `EditorFind`, through the same path typing takes.
    @objc(shouldReplaceCharactersInRanges:withStrings:)
    func shouldReplaceCharactersForFinder(_ ranges: [NSValue], with strings: [String]) -> Bool {
        onFindReplace?(ranges.map(\.rangeValue), strings)
        return false
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

    /// **TYPEWRITER ROOM — A22, rebuilt (QoL round 2026-07-29, L5).** The
    /// scroll allowance she should be able to scroll into below her last line,
    /// carried ON THE DOCUMENT rather than as a clip-view allowance. Zero for
    /// every other surface (the inline/book editors and the pane surfaces),
    /// which keeps their frame path byte-identical.
    ///
    /// Why it lives on the document view: every limit `NSScrollView` computes
    /// — the scroller's knob, the elastic edge, the discrete-wheel clamp,
    /// `scrollToEndOfDocument:`, `JumpPrimitive.maxScroll`, the scroll
    /// anchor's restore — is derived from the DOCUMENT RECT, which comes from
    /// this view's frame. The shipped `NSClipView.constrainBoundsRect`
    /// allowance moved none of them, so the room existed and half the ways in
    /// could not see it. See `TypewriterScrollView` for the whole story.
    var typewriterRoom: CGFloat = 0 {
        didSet {
            guard typewriterRoom != oldValue else { return }
            if proposedHeight <= 0 { proposedHeight = frame.height }
            applyFrameHeight(width: frame.width)
        }
    }

    /// The height AppKit last asked for, BEFORE the room was added — so the
    /// room can be re-applied (or removed) without compounding on itself.
    private var proposedHeight: CGFloat = 0

    /// The height we last SET. AppKit hands the current frame size back to
    /// `setFrameSize` on some passes, and mistaking our own output for a fresh
    /// proposal made the room compound once per pass — measured: a two-line
    /// post reached a 1,007 pt frame (500 → 548 → 1,007) instead of 548, which
    /// is what left `theRoomNeverSwallowsAShortPostsText` red after the second
    /// cut of this fix.
    private var appliedHeight: CGFloat = 0

    override func setFrameSize(_ newSize: NSSize) {
        let isOurOwnOutput = typewriterRoom > 0
            && appliedHeight > 0
            && abs(newSize.height - appliedHeight) < 0.5
        if !isOurOwnOutput { proposedHeight = newSize.height }
        applyFrameHeight(width: newSize.width)
    }

    private func applyFrameHeight(width: CGFloat) {
        // Roomless surfaces take exactly the path they always took.
        guard typewriterRoom > 0 else {
            let widthChanged = width != frame.size.width
            super.setFrameSize(NSSize(width: width, height: proposedHeight))
            updateGutters()
            if widthChanged { onWidthReflow?() }
            return
        }
        let size = NSSize(
            width: width,
            height: max(proposedHeight, lastLineBottomForRoom() + typewriterRoom))
        // CHANGE-GATED (the A47c discipline): AppKit re-offers its own
        // content-derived height on every layout pass and we answer with the
        // same room-inclusive frame, so a same-value pass must write nothing
        // — otherwise the funnel would chase its own layout.
        guard size != frame.size else { return }
        let widthChanged = size.width != frame.size.width
        appliedHeight = size.height
        super.setFrameSize(size)
        updateGutters()
        if widthChanged { onWidthReflow?() }
    }

    /// **The bottom of her LAST LINE**, in this view's own coordinates —
    /// which is what her ruling measures the room from ("about one
    /// viewport-page of scrollable allowance below the last line"), and the
    /// arithmetic the two failing pins forced.
    ///
    /// Two measured facts decide the two cases:
    ///
    /// - **The tall case: AppKit's own proposed height is the honest one, and
    ///   `usageBoundsForTextContainer` is NOT.** On a 120-paragraph corpus the
    ///   usage bounds read 686 pt SHORT of the drawn text (2,235 + insets vs a
    ///   last line drawn at 2,897) because TK2 accounts un-laid-out fragments
    ///   differently. Measuring from usage would have put the room *inside*
    ///   the text and granted none. So: the frame AppKit asked for, less the
    ///   bottom container inset, which is exactly the drawn bottom (2,921 − 24
    ///   = 2,897, measured equal).
    /// - **The floored case: the frame says nothing at all.**
    ///   `isVerticallyResizable` floors the frame at the viewport, so a
    ///   three-line entry's frame is a page tall. The shipped mechanism
    ///   inherited that floor and would have scrolled her three lines 412 pt
    ///   off the top — "room that has swallowed the text", judgment call 7's
    ///   own forbidden outcome (measured RED). A floored post is shorter than
    ///   a page and therefore fully laid out, so the usage bounds ARE honest
    ///   there; the top inset puts them in view space.
    ///
    /// The tall case never reads the usage bounds, so no keystroke and no
    /// layout pass pays for layout anywhere (P1) — and `PhantomSpaceTests`'
    /// own premise ("the long block starts as an estimate") would fail if it
    /// did.
    private func lastLineBottomForRoom() -> CGFloat {
        let floorHeight = enclosingScrollView?.contentView.bounds.height ?? 0
        guard proposedHeight <= floorHeight + 1 else {
            return proposedHeight - textContainerInset.height
        }
        guard let usage = textLayoutManager?.usageBoundsForTextContainer.height, usage > 0
        else { return proposedHeight - textContainerInset.height }
        return min(proposedHeight - textContainerInset.height,
                   usage + textContainerInset.height)
    }

    /// Re-applies the room to the frame without the room's VALUE changing.
    ///
    /// Needed because the floored case above depends on the CLIP's height, and
    /// the clip is not its final size on the first passes of a mount — an
    /// early pass read a stale viewport, took the tall branch, and nothing
    /// re-proposed afterwards, so a short post kept a frame a page too tall
    /// (this is what left `theRoomNeverSwallowsAShortPostsText` red after the
    /// first cut of the fix). The scroll view calls this from its own layout;
    /// the change-gate makes a stable pass free.
    func reapplyTypewriterRoom() {
        guard typewriterRoom > 0 else { return }
        if proposedHeight <= 0 { proposedHeight = frame.height }
        applyFrameHeight(width: frame.width)
    }

    /// **β1 (HER RULING, 2026-07-29 — "Yes — keep ~2 lines").** Typing keeps
    /// about two lines of air below the caret instead of pinning its line to
    /// the viewport's bottom edge. `didChangeText` is the honest hook: it
    /// fires for typing, paste and delete but NOT for clicks or arrow keys,
    /// so a click near the bottom of the page never makes the view jump.
    override func didChangeText() {
        // Cold review F-8 (pin-confirmed red): a content change RETIRES the
        // own-output echo filter. `appliedHeight` exists to suppress AppKit
        // handing our own room-inclusive output back BETWEEN edits (the
        // measured compounding); after an edit, a proposal that happens to
        // equal it is a FRESH proposal and must be adopted, or the stale
        // `proposedHeight` silently eats the room until the next differing
        // proposal. Clearing here scopes the filter to exactly the interval
        // where suppression is provably right. (Projection-driven storage
        // rewrites don't route this hook — recorded residual; they re-propose
        // differing heights in practice, which the filter admits anyway.)
        appliedHeight = 0
        super.didChangeText()
        (enclosingScrollView as? TypewriterScrollView)?.keepCaretClearance(in: self)
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
        // QoL batch 3 (L6): in-post find & replace. The bar lives in the
        // ENCLOSING SCROLL VIEW (`NSScrollView` is an
        // `NSTextFinderBarContainer`), which is why only this editor gets it:
        // `makeInlineEditor` below has no scroll view of its own, and the
        // book/spread scroll view it sits inside is not its to hang a bar in.
        //
        // Incremental searching stays OFF in v1 (ruled): live match
        // highlighting is the per-range rendering-attributes family
        // TEXTKIT2_NOTES §3 flags as unreliable, and it is the one part of the
        // find UI the Phase 6 spike never exercised. A named, revisitable
        // limitation, not an oversight.
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = false

        // Pool drags land here too (Phase 10 Step 7) — additive, never
        // replacing the text types NSTextView registers for itself.
        textView.registerForDraggedTypes(
            textView.registeredDraggedTypes + [poolBlockType])

        let scrollView = TypewriterScrollView()
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

#if DEBUG
/// β1's activation counter: the clearance either does work she can feel or it
/// is dead code, and only a measurement can say which (the
/// `CanvasCardMaterialization` precedent).
@MainActor
enum TypewriterCaretClearance {
    static var applied = 0
}
#endif

/// **TYPEWRITER ROOM — A22 (author ruling, 13d sitting 2026-07-28), on its
/// THIRD mechanism (QoL round 2026-07-29, L5).**
/// Her ask, from the A47b sitting: *let me scroll into a page of empty space
/// so I can keep typing high on the screen.* She had been building that room
/// BY HAND out of typed newlines at the end of a post — which the ratified
/// edge rules never store (a whitespace-only open tail never mints), so it
/// looked durable and silently evaporated. Her ruling settled both halves:
/// the trimming rules STAY exactly as ratified, and the room is the real
/// answer — ALWAYS ON, no setting.
///
/// **The room is ALLOWANCE, never content:** zero bytes stored, zero text
/// written, `renderedText`, export and the bridge byte-untouched, and the
/// ratified edge-trimming rules unchanged. It is scroll extent, not paper —
/// pinned as such.
///
/// **THE MECHANISM HISTORY, kept because each choice failed differently and a
/// future session would otherwise "simplify" back into one of them.**
///
/// 1. `NSScrollView.contentInsets.bottom` (13d batch 5, built first) measured
///    ideally — clip height unchanged (400.0 → 400.0), scroll range extended
///    by exactly the room (2406.5 → 2700.5), and the scroller reflecting it
///    (knobProportion 0.1425 → 0.1290). **It broke clicking into her own
///    text:** everything below the top ~17 pt of the viewport hit-tested to an
///    AppKit backdrop at depths where her prose was VISIBLY DRAWN. 13c 1C's
///    dead-strip tripwire caught it at 483 pt.
/// 2. `NSClipView.constrainBoundsRect` (13d batch 5, shipped) fixed the hit
///    testing and kept the range — **but it widened only the CLIP's permitted
///    origin, and every limit AppKit computes comes from the DOCUMENT RECT,
///    which it never moved.** So the room existed and several ways in could
///    not see it. Her report — *"i still am not seeing the whitespace at the
///    bottom"* — is what that felt like. Measured, 2026-07-29 (the batch-5
///    record's claim that the room "is reached by ordinary scrolling — wheel,
///    trackpad, keyboard" had never been measured):
///      · ⇟ `scrollPageDown:` and a synthesized wheel DID reach it (origin
///        2,904 = frame 2,921 + room 483 − viewport 500, exactly);
///      · ⌘↓ `scrollToEndOfDocument:` did NOT (30 pt of air, not 483);
///      · the scroller knob did NOT (documentRect 2,235 = the text alone) —
///        recorded at batch 5 as an accepted cost, and the likeliest door she
///        was actually using;
///      · `JumpPrimitive.maxScroll` did NOT (a jump to the last block landed
///        1,431 units short of its top);
///      · the scroll anchor did NOT — `topVisibleOffset()` answered **nil**
///        inside the room, so a width reflow restored her out of it;
///      · a short post's room was measured from a viewport-FLOORED document,
///        so a full scroll carried three lines of text 412 pt off the top;
///      · the trackpad's elastic snap-back could not be synthesized in this
///        host and remains an honestly untested path (batch 5's mouse-down
///        class).
/// 3. **GROW THE DOCUMENT (this one).** The room rides on
///    `EditorTextView.typewriterRoom`, i.e. on the document view's own frame,
///    measured from where the TEXT ends. Then the room is ordinary scrollable
///    extent: the knob covers it, the elastic edge is not involved at all,
///    every clamp and reveal and jump and anchor is honest by construction
///    rather than by a patch per path, and the `hitTest`/`mouseDown` claims
///    this class used to need are GONE — a click in the room is an ordinary
///    click past the last line, which `NSTextView` answers with
///    `characterIndexForInsertion`, i.e. the end of the text. That is her
///    ruling's second half, delivered by AppKit (and already the measured
///    behaviour of the phantom — 13c 1C).
///
/// **Recorded consequences** (stated, not hidden): a post shorter than the
/// page now has genuinely more scroll extent than page, so its scroller can
/// appear; there is no visual seam, because the text view's background and the
/// scroll view's are both `chrome.paper`; and while a long block's phantom is
/// uncollapsed the room sits below the ESTIMATED bottom and settles when the
/// heal lands (`LongBlockLayout` still never learns this exists).
@MainActor
final class TypewriterScrollView: NSScrollView {
    /// Off ⇒ byte-identical to a plain NSScrollView (nothing is written).
    var typewriterRoomEnabled = true

    /// How many lines of air β1 keeps below the caret while she types (HER
    /// ruling, 2026-07-29: *"Yes — keep ~2 lines"*).
    static let caretClearanceLines: CGFloat = 2

    /// The room the document currently carries, in points.
    var typewriterRoom: CGFloat { (documentView as? EditorTextView)?.typewriterRoom ?? 0 }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateTypewriterRoom()
    }

    override func layout() {
        super.layout()
        updateTypewriterRoom()
        // The room's FRAME arithmetic depends on the clip height (the floored
        // short-post branch), which is not final on a mount's first passes —
        // so re-apply every layout, change-gated on the far side.
        (documentView as? EditorTextView)?.reapplyTypewriterRoom()
    }

    /// CHANGE-GATED (the A47c discipline): a same-value pass writes nothing,
    /// so this cannot chase its own layout — and the room is computed from the
    /// viewport, which growing the document does not move, so it converges in
    /// one pass.
    func updateTypewriterRoom() {
        guard let textView = documentView as? EditorTextView else { return }
        let room = typewriterRoomEnabled
            ? TypewriterRoom.height(
                viewport: contentView.bounds.height,
                lineHeight: TypewriterRoom.lineHeight(of: EditorDocument.baseFont))
            : 0
        guard abs(textView.typewriterRoom - room) > 0.5 else { return }
        textView.typewriterRoom = room
    }

    /// **β1 (HER RULING, 2026-07-29 — "Yes — keep ~2 lines").** Keeps about
    /// two lines of air below the caret's line while she types.
    ///
    /// **Why this needed building at all, measured:** a minimal reveal leaves
    /// ZERO scroll clearance. The 30 pt that sits below her last line on the
    /// shipped build is fixed geometry — the container's bottom inset (24 pt)
    /// plus AppKit's own ~6 pt strip — not air the reveal chose. So the
    /// clearance is asked for on top of that inset, and it is only reachable
    /// because the room is now real scroll extent.
    ///
    /// Only ever scrolls DOWN, never up: an upward caret move is the reveal's
    /// business, and yanking the page toward the caret would be a second
    /// scrolling authority. Reads the caret fragment's ALREADY-AVAILABLE
    /// layout (`options: []`) and bails when TK2 has only estimated it, so no
    /// keystroke ever pays for layout (P1).
    func keepCaretClearance(in textView: NSTextView) {
        guard typewriterRoomEnabled, typewriterRoom > 0,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else { return }
        let caret = textView.selectedRange().location
        // The fragment lookup starts one unit INSIDE the document when the
        // caret sits at its very end: enumerating from the end location yields
        // no fragment at all, which is precisely where she types, and it is why
        // the first cut of this clearance never once ran (measured: applied 0
        // times). The line resolution below still uses the real caret offset —
        // `FragmentLines` answers the last line for an offset past its ranges.
        let docLength = contentManager.offset(
            from: contentManager.documentRange.location,
            to: contentManager.documentRange.endLocation)
        guard docLength > 0 else { return }
        guard let location = contentManager.location(
            contentManager.documentRange.location,
            offsetBy: max(0, min(caret, docLength - 1)))
        else { return }

        var lineBottom: CGFloat?
        // `.ensuresLayout` over the ONE caret fragment. `options: []` was
        // tried first and never produced a geometry: at `didChangeText` time
        // the just-edited fragment's layout is INVALID, so its state is not
        // `.layoutAvailable` and the clearance bailed every time (measured:
        // entered 1, noFragment 1, applied 0). This is the `JumpPrimitive`
        // idiom — a single fragment, the one she is looking at — and it pulls
        // forward layout AppKit must redo on the next display pass anyway, so
        // it adds no work that was not already owed (P1).
        layoutManager.enumerateTextLayoutFragments(
            from: location, options: [.ensuresLayout]
        ) { fragment in
            guard fragment.state == .layoutAvailable else { return false }
            let start = contentManager.offset(
                from: contentManager.documentRange.location,
                to: fragment.rangeInElement.location)
            let lines = fragment.textLineFragments
            if let i = FragmentLines.lineIndex(
                atLocalOffset: max(0, caret - start),
                lineRanges: lines.map(\.characterRange)) {
                lineBottom = fragment.layoutFragmentFrame.minY
                    + lines[i].typographicBounds.maxY
            } else {
                lineBottom = fragment.layoutFragmentFrame.maxY
            }
            return false
        }
        guard let lineBottom else { return }

        // Fragment geometry is TEXT-CONTAINER-relative; the scroll offset is
        // VIEW-relative (the 13c 1A conversion lesson — the same one
        // `topVisibleOffset` and `JumpPrimitive` learned).
        let inView = lineBottom + textView.textContainerOrigin.y
        let line = TypewriterRoom.lineHeight(of: EditorDocument.baseFont)
        let wanted = inView + textView.textContainerInset.height
            + Self.caretClearanceLines * line - contentView.bounds.height
        guard wanted > contentView.bounds.origin.y + 0.5 else { return }
        #if DEBUG
        TypewriterCaretClearance.applied += 1
        #endif
        contentView.scroll(to: NSPoint(x: contentView.bounds.origin.x, y: wanted))
        reflectScrolledClipView(contentView)
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
