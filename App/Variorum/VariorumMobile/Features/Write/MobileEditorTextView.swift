//
//  MobileEditorTextView.swift
//  VariorumMobile
//
//  Mobile Stage 1, batch 1 (M1 — the Write-true editor core): the phone's
//  ONE continuous TK2 text surface. TK2-explicit construction plus the
//  CHECKPOINT canary the platform demands (the Stage 0 memo, item 1 +
//  obligation 2): UIKit has NO analog of AppKit's
//  `willSwitchToNSLayoutManager` notifications — the only public downgrade
//  signal is `textLayoutManager` reading nil — so the canary POLLS at
//  checkpoints (after every editor-shaped mutation, and on a low-frequency
//  idle tick) instead of subscribing. The spike's positive control proved
//  the poll detects a real downgrade synchronously at the next checkpoint.
//
//  Posture (the Mac FallbackCanary's, adopted by the memo): debug builds
//  assertionFailure (stop the world); release builds os_log fault + a
//  visible in-app diagnostic. Any firing is a P1-class bug — fallback is
//  NOT a normal event on this stack.
//
//  Also here: the `isPasting` flag (the bulk-entry hint, the Mac
//  EditorTextView's exact shape) and the `inputAccessoryView` keyboard-bar
//  SHELL (the M11 toolbar's home per the memo's obligation 4 — its acts
//  land in a later batch).
//

import UIKit
import VariorumCore
import os

// MARK: - The checkpoint canary (obligation 2)

@MainActor
final class MobileFallbackCanary {
    private static let log = Logger(subsystem: "io.lduarte.Variorum", category: "tk2-canary-ios")

    private(set) var fired = false
    private var idleTimer: Timer?

    /// Called on the main actor when the canary fires (release builds reach
    /// this; debug builds stop at the assertion first).
    var onFire: ((String) -> Void)?

    /// Test seam (the Mac FallbackCanary's N2 pattern): debug builds stop
    /// the world on fire BY DESIGN, which makes the fire→diagnostic path
    /// untestable through the real assertion. A pin injects a no-op here
    /// for exactly one test's scope and restores it; production code never
    /// touches this.
    static var assertionHandler: @MainActor (String) -> Void = { assertionFailure($0) }

    /// Arms the idle tick for ONE text view and takes an immediate
    /// checkpoint (a construction-time downgrade must not wait 30 s).
    func arm(for textView: UITextView, idleInterval: TimeInterval = 30) {
        checkpoint(textView, context: "arm")
        guard idleTimer == nil else { return }
        idleTimer = Timer.scheduledTimer(
            withTimeInterval: idleInterval, repeats: true
        ) { [weak self, weak textView] _ in
            // Timers fire on the main run loop; the closure is nonisolated
            // by signature only.
            MainActor.assumeIsolated {
                guard let self, let textView else { return }
                self.checkpoint(textView, context: "idle tick")
            }
        }
    }

    func disarm() {
        idleTimer?.invalidate()
        idleTimer = nil
    }

    /// The poll: TK2 alive ⇔ `textLayoutManager` non-nil (the one public
    /// signal on iOS; compatibility mode is permanent for the instance, so
    /// firing once is firing truthfully).
    func checkpoint(_ textView: UITextView, context: String) {
        guard !fired, textView.textLayoutManager == nil else { return }
        fired = true
        let message = "TextKit 2 -> TextKit 1 fallback detected (\(context)). "
            + "A TK1 API or OS change downgraded the editor; P1-class bug "
            + "(TEXTKIT2_NOTES §0/§4; mobile spike memo item 1)."
        Self.log.fault("\(message, privacy: .public)")
        Self.assertionHandler(message) // debug: stop the world
        onFire?(message)               // release: visible in-app diagnostic
    }
}

// MARK: - Typewriter room (P24, parity A3 — her ruled requirement)

/// P24, her words: *"make sure i can still have whitespace at the bottom
/// of the note - a nicety from the mac i want preserved."* The arithmetic
/// MIRRORS the Mac's `TypewriterRoom` (EditorTextView.swift, the 13d A22
/// ruling: about one viewport-page LESS ONE LINE, so at maximum scroll
/// the last line sits at the top rather than one pixel above it) —
/// mirrored, never changed (the S2 guard-order precedent; the brain is
/// one `max` expression, hoisting it would mean Mac-source churn outside
/// this batch's scope — recorded in the batch record). The MECHANISM is
/// the phone's own: `textContainerInset.bottom` (AppKit's inset broke
/// hit-testing behind a backdrop view — the 13d record — but on iOS the
/// inset region belongs to the text view itself, so a tap there lands
/// the caret at the document's end for free, which IS the Mac's
/// click-in-the-room rule).
nonisolated enum MobileTypewriterRoom {
    /// One viewport-page less one line (the Mac's exact expression).
    static func height(viewport: CGFloat, lineHeight: CGFloat) -> CGFloat {
        max(0, viewport - max(0, lineHeight))
    }

    /// One line of a font, from the font's own metrics (the Mac's rule,
    /// UIFont-spelled).
    static func lineHeight(of font: UIFont) -> CGFloat {
        (font.ascender - font.descender + font.leading).rounded(.up)
    }
}

// MARK: - The text view

@MainActor
final class MobileEditorTextView: UITextView {
    private let canary = MobileFallbackCanary()

    /// The keyboard bar's acts controller + the checkbox tap's router —
    /// retained here because `UIBarButtonItem` targets and gesture-recognizer
    /// targets are held weakly (batch 2).
    private var keyboardBarController: MobileKeyboardBarController?
    private var checkboxRouter: MobileCheckboxTapRouter?

    /// The takes chrome (S2 batch 1: ⑂ badge + LK10 gutter, peek marker,
    /// the LK6 pill) and the M5 swipe-peek's pan router — retained here
    /// like the checkbox router (gesture targets are weak). Installed by
    /// the VM at attach; headless storage-only attaches never create them.
    private(set) var takesChrome: MobileTakesChromeController?
    private(set) var takesPanRouter: MobileTakesPanRouter?
    /// The takes BROWSER's pixels (S2 batch 2 — the LK4 sheet-over-page)
    /// and the model back-reference the keyboard bar's ⑂ routes through.
    private(set) var takesBrowserView: MobileTakesBrowserView?
    /// The block DECOR (S4 batch 1: callout frames + comment markers) and
    /// the comments sheet's pixels — the S2 pattern's siblings.
    private(set) var blockDecor: MobileBlockDecorController?
    private(set) var commentsSheetView: MobileCommentsSheetView?
    private(set) weak var editorModel: MobileEditorViewModel?

    /// Wires the takes surface onto this view (called from
    /// `MobileEditorViewModel.attach(textView:)`).
    func installTakes(model: MobileEditorViewModel) {
        editorModel = model
        // S4 ordering kept (decor before chrome): since B3 the two
        // controllers compose their first-paragraph reservations by
        // read-modify-write on ONE style object (decor's head field,
        // chrome's tail field), so a stable order keeps a both-decorated
        // block's writes deterministic.
        let decor = MobileBlockDecorController(textView: self, model: model)
        blockDecor = decor
        let chrome = MobileTakesChromeController(textView: self, model: model)
        takesChrome = chrome
        let router = MobileTakesPanRouter(textView: self, model: model)
        let pan = UIPanGestureRecognizer(
            target: router, action: #selector(MobileTakesPanRouter.handlePan(_:)))
        pan.delegate = router
        addGestureRecognizer(pan)
        takesPanRouter = router
        model.takes.onPeekChanged = { [weak chrome] blockID in
            chrome?.peekDidChange(blockID)
        }
        refreshChrome()
        // S2 batch 2: the browser sheet (attaches itself over the page at
        // first open; the controller's onChanged drives every render).
        let browserView = MobileTakesBrowserView(textView: self, model: model)
        takesBrowserView = browserView
        model.takesBrowser.onChanged = { [weak browserView] in
            browserView?.render()
        }
        // S4: the comments sheet (the browser sheet's pattern — an
        // overlay in the same screen; the controller's onChanged drives
        // every render).
        let commentsView = MobileCommentsSheetView(textView: self, model: model)
        commentsSheetView = commentsView
        model.comments.onChanged = { [weak commentsView] in
            commentsView?.render()
        }
    }

    /// The ONE chrome refresh door (S4; B3 retired the exclusion
    /// assembly): the decor re-anchors frames/emoji and maintains its
    /// head reservations, then the takes chrome does the same for
    /// badges/markers/pill and its tail reservations. Every
    /// content/geometry input axis routes here with its honest scope —
    /// and both controllers read ONE shared ranges index per event
    /// (FIX-B2: `blockRangesByID` is an O(entries) walk, and it was
    /// built twice per keystroke/scroll tick, once per controller,
    /// unconditionally — the round-1 reviewer's measured residual).
    func refreshChrome(scope: MobileTakesChromeController.RefreshScope = .document) {
        guard blockDecor != nil || takesChrome != nil, let model = editorModel
        else { return }
        // Pre-layout there is nothing to place, and the first real
        // layout escalates to a full pass via the width change — so a
        // zero-width event must not pay the O(entries) index build
        // (Stage B ladder R2-3).
        guard bounds.width > 0 else { return }
        let ranges = model.blockRangesByID()
        blockDecor?.refresh(scope: scope, ranges: ranges)
        takesChrome?.refresh(scope: scope, ranges: ranges)
    }

    /// Scrolling and width changes both land here (UIScrollView lays out
    /// on every content-offset tick) — the chrome re-anchors its overlays;
    /// equality gates inside keep the steady state write-free, so this
    /// cannot loop layout. NEAR-VIEWPORT scope (S2 ladder round 1, MINOR
    /// 3 — P-8): a tick forces geometry only for blocks near the TK2
    /// viewport, never the whole post; a width change escalates to a full
    /// pass inside the refresh itself.
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTypewriterRoom()
        refreshChrome(scope: .nearViewport)
    }

    /// P24: the bottom inset IS the typewriter room, recomputed from the
    /// live viewport (the container pins this view's bottom to the
    /// keyboard guide, so `bounds.height` is exactly the visible page —
    /// the room follows the keyboard for free). EQUALITY-GATED like every
    /// per-layout write (the chrome discipline), so the steady state is
    /// write-free and this cannot loop layout.
    private func updateTypewriterRoom() {
        let room = MobileTypewriterRoom.height(
            viewport: bounds.height,
            lineHeight: MobileTypewriterRoom.lineHeight(of: MobileEditorStyle.baseFont))
        guard abs(textContainerInset.bottom - room) > 0.5 else { return }
        textContainerInset.bottom = room
    }

    // MARK: Chrome geometry (S4 — the ONE implementation both chrome
    // controllers consult; moved here from the S2 chrome, move-only)

    /// The current TK2 viewport as a character range, padded by one
    /// viewport length each side — the `.nearViewport` band (the S2
    /// MINOR-3 scope). nil ⇒ unavailable; callers treat everything near.
    func nearViewportBand() -> NSRange? {
        guard let tlm = textLayoutManager,
              let cm = tlm.textContentManager,
              let viewport = tlm.textViewportLayoutController.viewportRange
        else { return nil }
        let start = cm.offset(from: tlm.documentRange.location, to: viewport.location)
        let end = cm.offset(from: tlm.documentRange.location, to: viewport.endLocation)
        guard start >= 0, end >= start else { return nil }
        let pad = max(end - start, 512)
        let lower = max(start - pad, 0)
        return NSRange(location: lower, length: (end + pad) - lower)
    }

    /// The first layout fragment at a surface offset (container coords),
    /// with its first line's height — `.ensuresLayout` on exactly that
    /// fragment (the hybrid-jump primitive's cost class).
    func firstLineGeometry(
        atOffset offset: Int
    ) -> (fragmentMinY: CGFloat, firstLineHeight: CGFloat)? {
        guard let tlm = textLayoutManager,
              let cm = tlm.textContentManager,
              let location = cm.location(tlm.documentRange.location, offsetBy: offset)
        else { return nil }
        var result: (CGFloat, CGFloat)?
        tlm.enumerateTextLayoutFragments(from: location, options: [.ensuresLayout]) { frag in
            result = (
                frag.layoutFragmentFrame.minY,
                frag.textLineFragments.first?.typographicBounds.height
                    ?? frag.layoutFragmentFrame.height)
            return false
        }
        return result
    }

    /// The union of a block range's fragment frames (container coords) —
    /// the spike's `fragmentRects` shape.
    func blockRectsUnion(range: NSRange) -> CGRect? {
        guard let tlm = textLayoutManager,
              let cm = tlm.textContentManager,
              let start = cm.location(tlm.documentRange.location, offsetBy: range.location),
              let end = cm.location(
                tlm.documentRange.location, offsetBy: range.location + range.length)
        else { return nil }
        var union: CGRect?
        tlm.enumerateTextLayoutFragments(from: start, options: [.ensuresLayout]) { frag in
            if frag.rangeInElement.location.compare(end) != .orderedAscending,
               range.length > 0 {
                return false
            }
            let frame = frag.layoutFragmentFrame
            union = union.map { $0.union(frame) } ?? frame
            // A zero-length block lives inside one fragment — stop there.
            return range.length > 0
        }
        return union
    }

    /// The END of a block range's LAST line (container coords): where the
    /// text's final glyph run stops — the comment marker's anchor (S4).
    func lastLineEnd(
        range: NSRange
    ) -> (x: CGFloat, lineMinY: CGFloat, lineHeight: CGFloat)? {
        guard let tlm = textLayoutManager,
              let cm = tlm.textContentManager,
              let start = cm.location(tlm.documentRange.location, offsetBy: range.location),
              let end = cm.location(
                tlm.documentRange.location, offsetBy: range.location + range.length)
        else { return nil }
        var last: NSTextLayoutFragment?
        tlm.enumerateTextLayoutFragments(from: start, options: [.ensuresLayout]) { frag in
            if frag.rangeInElement.location.compare(end) != .orderedAscending,
               range.length > 0 {
                return false
            }
            last = frag
            return range.length > 0
        }
        guard let last else { return nil }
        let frame = last.layoutFragmentFrame
        guard let line = last.textLineFragments.last else {
            return (frame.maxX, frame.minY, frame.height)
        }
        let bounds = line.typographicBounds
        return (
            frame.minX + bounds.maxX,
            frame.minY + bounds.minY,
            bounds.height)
    }

    // MARK: First-paragraph reservations (parity B3 — FB2-1's mechanism)

    /// THE GUTTER'S MECHANISM since B3: a PARAGRAPH-STYLE indent on the
    /// block's first paragraph, replacing `textContainer.exclusionPaths`
    /// entirely. Why (the B3 probe, recorded in the batch record):
    /// container exclusion paths make TK2's post-edit relayout
    /// DOCUMENT-scale by PRESENCE alone — ~160 ms per keystroke at 100k
    /// words with even ONE rect installed, position-independent, and
    /// ~0.5 ms with zero — and they inflate the height estimate ~1.4×
    /// (the scroll walk's contentSize thrash). No write-gating can fix a
    /// presence cost. Paragraph indents are layout-position-INDEPENDENT,
    /// so relayout stays incremental: a reservation write invalidates
    /// exactly one paragraph (P-8: invalidation ∝ what changed), and the
    /// measured keystroke returns to the bare-TK2 class. Both chrome
    /// controllers write through these two doors (the S4 one-
    /// implementation rule): each owns ONE field — the takes chrome the
    /// tail (⑂ gutter + P38's comment-mark room), the decor the leading
    /// first line (the callout emoji gap) — read-modify-write, so the
    /// two compose on a block that carries both. Equality-gated against
    /// STORAGE TRUTH at the paragraph's governing (first) character —
    /// never a cached record, so a materialization or voice re-base that
    /// dropped the style heals at the next pass (the overlay law's
    /// wire-time-delivery discipline), and a steady-state pass writes
    /// nothing.
    ///
    /// FIX-B1 (Stage B ladder round 1, MINOR 1 — the reservation-style
    /// leak, both roads).
    /// **(a) The split residue:** a mid-paragraph Enter (I4: content)
    /// used to strand the reservation on the continuation paragraph —
    /// the governing-character gate reads only the first paragraph, so
    /// no pass could ever heal what it never governed. Every reservation
    /// call now walks the block's REMAINING paragraphs and zeroes its
    /// own field where stranded (equality-gated per paragraph: a clean
    /// continuation paragraph costs one attribute read, zero writes).
    /// **(b) The separator inheritance:** the styled paragraph range
    /// includes the block's trailing separator "\n", and UIKit
    /// re-derives `typingAttributes` from the character before the
    /// caret — so tails typed after a one-paragraph fanned block (and
    /// every block crystallized from them, and the next block's first
    /// characters) inherited a permanent dent in paragraphs the
    /// reservation walk never visits. The separator itself CANNOT be
    /// kept clean: NSTextStorage attribute FIXING re-propagates the
    /// paragraph's governing style across the whole paragraph,
    /// terminator included (measured — a write clamped to exclude the
    /// terminator reads back styled; the fix-session probe pinned it
    /// cold on a bare storage). So the fix heals the LANDING instead:
    /// `healReservationResidue` runs edit-scoped after each
    /// controller's reservation walk, zeroing that door's field in
    /// every edited paragraph the walk does not govern. O(paragraphs
    /// in the edit) — P-8 clean; the derived dent never survives its
    /// own storageDidEdit pass.

    /// Reserve `width` points of first-paragraph TRAILING room (0 clears).
    /// Returns whether storage changed (the caller's invalidation record).
    @discardableResult
    func setTailReservation(
        _ width: CGFloat, blockRange: NSRange, healContinuations: Bool = true
    ) -> Bool {
        setReservation(
            blockRange: blockRange,
            healContinuations: healContinuations,
            mutate: { style in
                let target = width <= 0 ? 0 : -width
                guard abs(style.tailIndent - target) > 0.01 else { return false }
                style.tailIndent = target
                return true
            },
            heal: { style in
                guard abs(style.tailIndent) > 0.01 else { return false }
                style.tailIndent = 0
                return true
            })
    }

    /// Reserve `width` points of first-LINE leading room (0 clears) —
    /// `firstLineHeadIndent` is exactly the emoji gap's first-line-only
    /// shape.
    @discardableResult
    func setLeadingFirstLineReservation(
        _ width: CGFloat, blockRange: NSRange, healContinuations: Bool = true
    ) -> Bool {
        setReservation(
            blockRange: blockRange,
            healContinuations: healContinuations,
            mutate: { style in
                let target = max(width, 0)
                guard abs(style.firstLineHeadIndent - target) > 0.01 else { return false }
                style.firstLineHeadIndent = target
                return true
            },
            heal: { style in
                guard abs(style.firstLineHeadIndent) > 0.01 else { return false }
                style.firstLineHeadIndent = 0
                return true
            })
    }

    /// One walk over the paragraphs that BEGIN inside the block: the
    /// FIRST gets `mutate` (the reservation's own equality gate inside),
    /// every later one gets `heal` (zero this door's field if stranded —
    /// FIX-B1 road a). Writes cover the full paragraph range — attribute
    /// fixing re-propagates the governing style across each paragraph
    /// either way (the header's measured truth). Each closure touches
    /// ONLY its own field on a copy of the current style, so the two
    /// doors still compose on a block carrying both.
    /// `healContinuations: false` visits ONLY the first paragraph —
    /// the per-scroll-tick road's shape (Stage B ladder R2-1): strands
    /// are only born by edits, so the continuation heal belongs to the
    /// `.edit`/`.document` roads, and a tick pays O(first paragraph),
    /// never O(block bytes).
    private func setReservation(
        blockRange: NSRange,
        healContinuations: Bool = true,
        mutate: (NSMutableParagraphStyle) -> Bool,
        heal: (NSMutableParagraphStyle) -> Bool
    ) -> Bool {
        guard blockRange.length > 0, let storage = textStorage as NSTextStorage?,
              blockRange.location < storage.length else { return false }
        let text = storage.mutableString
        let blockEnd = min(blockRange.location + blockRange.length, storage.length)
        var changed = false
        var isFirst = true
        var location = blockRange.location
        while location < blockEnd {
            var pStart = 0
            var pEnd = 0
            var cEnd = 0
            text.getParagraphStart(
                &pStart, end: &pEnd, contentsEnd: &cEnd,
                for: NSRange(location: location, length: 0))
            let writeRange = NSRange(location: pStart, length: pEnd - pStart)
            if writeRange.length > 0,
               applyReservation(writeRange, isFirst ? mutate : heal, storage) {
                changed = true
            }
            if isFirst, !healContinuations { break }
            isFirst = false
            guard pEnd > location else { break }
            location = pEnd
        }
        return changed
    }

    /// FIX-B1 road (b) — the typing-inheritance heal (edit-scoped; the
    /// FIX-B1 header has the full mechanism): zeroes ONE reservation
    /// field across every paragraph the range TOUCHES — the paragraph
    /// containing `range.location` included (R2-2) — EXCEPT the
    /// paragraphs whose starts the calling walk currently governs (a
    /// reserved block's first paragraph). The chrome controllers call
    /// their field's door after the reservation walk on the `.edit`
    /// road, so a derived dent — the open tail, a next block's first
    /// characters — never survives the keystroke's own pass.
    /// Equality-gated per paragraph; a clean edit reads one attribute
    /// per paragraph and writes nothing.
    @discardableResult
    func healTailReservationResidue(
        in range: NSRange, skippingParagraphsAt governedStarts: Set<Int>
    ) -> Bool {
        healReservationResidue(in: range, skippingParagraphsAt: governedStarts) { style in
            guard abs(style.tailIndent) > 0.01 else { return false }
            style.tailIndent = 0
            return true
        }
    }

    /// The leading door's twin (the callout emoji gap's field).
    @discardableResult
    func healLeadingReservationResidue(
        in range: NSRange, skippingParagraphsAt governedStarts: Set<Int>
    ) -> Bool {
        healReservationResidue(in: range, skippingParagraphsAt: governedStarts) { style in
            guard abs(style.firstLineHeadIndent) > 0.01 else { return false }
            style.firstLineHeadIndent = 0
            return true
        }
    }

    private func healReservationResidue(
        in range: NSRange, skippingParagraphsAt governedStarts: Set<Int>,
        heal: (NSMutableParagraphStyle) -> Bool
    ) -> Bool {
        guard let storage = textStorage as NSTextStorage?, storage.length > 0,
              range.location < storage.length else { return false }
        let text = storage.mutableString
        let end = min(range.location + range.length, storage.length)
        var changed = false
        var location = range.location
        while location < storage.length {
            var pStart = 0
            var pEnd = 0
            var cEnd = 0
            text.getParagraphStart(
                &pStart, end: &pEnd, contentsEnd: &cEnd,
                for: NSRange(location: location, length: 0))
            if !governedStarts.contains(pStart),
               applyReservation(NSRange(location: pStart, length: pEnd - pStart), heal, storage) {
                changed = true
            }
            guard pEnd < end, pEnd > location else { break }
            location = pEnd
        }
        return changed
    }

    /// The one write shape both walks share: copy the paragraph's
    /// governing style, let the closure mutate its field, write only on
    /// real change.
    private func applyReservation(
        _ paragraphRange: NSRange,
        _ mutate: (NSMutableParagraphStyle) -> Bool,
        _ storage: NSTextStorage
    ) -> Bool {
        guard paragraphRange.length > 0 else { return false }
        let current = storage.attribute(
            .paragraphStyle, at: paragraphRange.location, effectiveRange: nil)
            as? NSParagraphStyle ?? MobileEditorStyle.baseParagraphStyle
        let style = current.mutableCopy() as! NSMutableParagraphStyle
        guard mutate(style) else { return false }
        storage.addAttribute(.paragraphStyle, value: style, range: paragraphRange)
        return true
    }

    /// The bulk-entry hint (the Mac EditorTextView's exact shape): bulk
    /// paste at the tail segments on entry (AppSpec §7); a paste routed
    /// into an existing block is a content edit and must not arm anything.
    private(set) var isPasting = false

    /// The explicit TK2 stack's owners. REQUIRED strong references:
    /// `NSTextContainer.textLayoutManager` and
    /// `NSTextLayoutManager.textContentManager` are weak back-pointers, so
    /// without this the content storage (and its NSTextStorage) would
    /// deallocate under the view.
    private var tk2Stack: (NSTextContentStorage, NSTextLayoutManager)?

    /// TK2-explicit construction (TEXTKIT2_NOTES §4.1's iOS reading) plus
    /// the surface configuration every Write instance shares.
    ///
    /// MEASURED TRAP (batch 1, crash report VariorumMobile-2026-08-03):
    /// `UITextView(usingTextLayoutManager:)` is a bridged ObjC FACTORY
    /// (`+textViewUsingTextLayoutManager:`) — invoked on a Swift SUBCLASS
    /// it returns an instance whose Swift stored properties were NEVER
    /// initialized (first `canary` access → SIGSEGV at the ivar offset).
    /// The explicit stack through the true designated
    /// `init(frame:textContainer:)` is the documented custom-TK2
    /// construction and runs the normal Swift init chain; a container
    /// already associated with an NSTextLayoutManager puts the view in
    /// TK2 mode (the canary checkpoints prove it stays there).
    static func make() -> MobileEditorTextView {
        let contentStorage = NSTextContentStorage()
        let layoutManager = NSTextLayoutManager()
        let container = NSTextContainer(size: CGSize(width: 0, height: 1_000_000_000))
        container.widthTracksTextView = true
        layoutManager.textContainer = container
        contentStorage.addTextLayoutManager(layoutManager)
        contentStorage.primaryTextLayoutManager = layoutManager
        let view = MobileEditorTextView(frame: .zero, textContainer: container)
        view.tk2Stack = (contentStorage, layoutManager)
        view.adjustsFontForContentSizeCategory = true
        view.alwaysBounceVertical = true
        view.keyboardDismissMode = .interactive
        // The prose margins (parity A3 spacing floor — the LK canon's
        // `.prose padding:8px 20px`; her "more padding generally"): 15 pt
        // insets + the container's default 5 pt fragment padding = the
        // canon's 20 pt visual margin each side. The default near-zero
        // margins were the floor's headline finding. Bottom is managed by
        // the typewriter room (P24) at every layout.
        view.textContainerInset = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)

        // Batch 2: the bar's six live acts (LK8 minus ⑂/⋯ per P-2) replace
        // the batch-1 shell. Batch 3: chrome + bar resolve from the live
        // voice (`applyVoiceChrome` styles both; the VM's
        // `applyVoiceChange` re-invokes it at the switch).
        let barController = MobileKeyboardBarController(textView: view)
        view.keyboardBarController = barController
        view.applyVoiceChrome()

        // Batch 2: the checkbox tap-toggle. The router's `shouldReceive`
        // decision means a tap anywhere but strictly inside a box is never
        // consumed — ordinary caret taps proceed untouched.
        let router = MobileCheckboxTapRouter(textView: view)
        let tap = UITapGestureRecognizer(
            target: router, action: #selector(MobileCheckboxTapRouter.handleTap(_:)))
        tap.delegate = router
        view.addGestureRecognizer(tap)
        view.checkboxRouter = router
        return view
    }

    // MARK: Voice chrome (batch 3 — the look canon on the surface)

    /// Applies the live voice's chrome to the view + its keyboard bar:
    /// the room background (dark rides the dynamic colors — R51), the
    /// accent caret/selection tint, the voice typing attributes, and a
    /// freshly styled bar. Called at construction and by the VM's
    /// `applyVoiceChange` (the LK2 switch).
    func applyVoiceChrome() {
        let face = MobileEditorStyle.face
        backgroundColor = face.room
        tintColor = face.accent
        typingAttributes = MobileEditorStyle.baseAttributes
        if let keyboardBarController {
            inputAccessoryView = keyboardBarController.makeBar()
            reloadInputViews()
        }
    }

    // MARK: The ⏎ door (13k K5/K8 on the phone — batch 2)

    /// **⏎ continues a list.** The keystroke itself is untouched:
    /// `super.insertText("\n")` runs exactly as it always did (so the
    /// open-tail gesture, `one_block`'s newlines-don't-mint, the idle mint
    /// and every refusal see the same single `"\n"`), and the lead is a
    /// second ordinary policed insertion afterwards — see
    /// `MobileMarkdownActs.handleReturnKey`. `insertText` is the honest iOS
    /// intercept: the software keyboard's return, hardware Return, and the
    /// tests' typing proxy all arrive here; marked-text composition stays
    /// ordinary (committing a composition is not the list gesture).
    ///
    /// Known limit, recorded (the batch-1 deliberate absence carried): the
    /// phone has no soft-newline ⇧⏎ story yet, so a hardware ⇧⏎ reaches
    /// this door like any ⏎ — when the soft-newline gesture lands, it must
    /// gain the Mac's ⇧⏎ exclusion.
    override func insertText(_ text: String) {
        if text == "\n", markedTextRange == nil {
            MobileMarkdownActs.handleReturnKey(in: self) { super.insertText("\n") }
            return
        }
        super.insertText(text)
    }

    // MARK: Tab / ⇧Tab (13k K8 — batch 2)

    /// **The Tab door** — hardware Tab and the bar's ⇥ share it. A list
    /// line indents (the shared brain's plan); everywhere else the key is
    /// byte-for-byte what it has always been: one ordinary policed `"\t"`
    /// (an empty plan is exactly the signal that no list line was touched —
    /// the Mac `indentLists` shape).
    @objc func performTabKey() {
        guard isEditable else { return }
        if MobileMarkdownActs.apply(.indent, to: self) { return }
        guard MobileMarkdownActs.gateAllows(self, range: selectedRange, replacement: "\t")
        else { return }
        super.insertText("\t")
    }

    /// **The ⇧Tab door** — outdent through the ONE shared unit (the ⏎
    /// door's `.outdentItem` shares it). Outside a list there is no
    /// ordinary backtab character, so an empty plan does nothing — the
    /// Mac's `insertBacktab` parity.
    @objc func performShiftTabKey() {
        guard isEditable else { return }
        _ = MobileMarkdownActs.apply(.outdent, to: self)
    }

    override var keyCommands: [UIKeyCommand]? {
        let tab = UIKeyCommand(
            input: "\t", modifierFlags: [], action: #selector(performTabKey))
        tab.wantsPriorityOverSystemBehavior = true
        let backtab = UIKeyCommand(
            input: "\t", modifierFlags: .shift, action: #selector(performShiftTabKey))
        backtab.wantsPriorityOverSystemBehavior = true
        return (super.keyCommands ?? []) + [tab, backtab]
    }

    // MARK: Canary forwards

    var onCanaryFired: ((String) -> Void)? {
        get { canary.onFire }
        set { canary.onFire = newValue }
    }
    var canaryFired: Bool { canary.fired }

    func armCanary() { canary.arm(for: self) }
    func disarmCanary() { canary.disarm() }

    /// The assert-after-mutation half of obligation 2 — the view model
    /// calls this after every processed storage edit.
    func canaryCheckpointAfterMutation() {
        canary.checkpoint(self, context: "after mutation")
    }

    // MARK: Paste

    override func paste(_ sender: Any?) {
        isPasting = true
        defer { isPasting = false }
        super.paste(sender)
    }
}

// MARK: - The surface container (keyboard avoidance, obligation 4)

/// The Write surface's UIKit container: the text view fills it, and its
/// BOTTOM edge is pinned to `keyboardLayoutGuide` — the spike measured that
/// UITextView does NOT auto-adjust its insets for the keyboard (item 6:
/// `autoAdjusted=NO`), so avoidance is explicit, exactly this constraint.
@MainActor
final class MobileWriteSurfaceView: UIView {
    let textView: MobileEditorTextView

    init() {
        textView = MobileEditorTextView.make()
        super.init(frame: .zero)
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            keyboardLayoutGuide.topAnchor.constraint(equalTo: textView.bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }
}
