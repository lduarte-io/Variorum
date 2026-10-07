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
    /// The scheduled tick. `private(set)` rather than `private` because the
    /// deinit pin needs a handle that OUTLIVES this object: once the canary
    /// is gone there is no other way to ask whether its timer is still on
    /// the run loop, which is the leak itself (round-2 ladder round 1,
    /// MINOR 3).
    private(set) var idleTimer: Timer?

    /// Whether the idle tick is scheduled — the teardown pin's oracle
    /// (round 2, M2e).
    var isArmed: Bool { idleTimer != nil }

    /// The tick dies with its canary, whatever road got us here (round-2
    /// ladder round 1, MINOR 3). `teardown()` disarms explicitly and does
    /// it first — but the only production path is a NavigationStack pop,
    /// where SwiftUI can release the surface concurrently, and a text view
    /// released without a teardown at all (a failed load, a cancelled push)
    /// never had one. `Timer.scheduledTimer` hands ownership to the run
    /// loop, so an un-invalidated tick outlives everything that referenced
    /// it and keeps waking the main thread every 30 s for the process's
    /// life, doing nothing.
    /// `isolated` because `Timer.invalidate()` must run on the run loop
    /// that scheduled it; a plain deinit runs wherever the last reference
    /// happens to drop.
    isolated deinit {
        idleTimer?.invalidate()
        idleTimer = nil
    }

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

// MARK: - The scroll authority (VM-10 — her rule, the brain)

/// **VM-10, her rule verbatim (2026-10-06):** *"showing empty space should be
/// allowed if you scroll there but it shouldn't be forced."*
///
/// THE TRACED MECHANISM (`notes/plans/fixes/vm-10-the-write-scroll-authority.md`
/// has the stacks and numbers): UIKit's own `-[UITextView
/// _scrollToSelectionIfNeeded]` reveals the selection's LINE rect through
/// `scrollRectToVisible(_:animated:)`, and when the caret sits on the empty
/// line after a trailing newline that rect is padded by the bottom
/// `textContainerInset` — which on this surface IS the typewriter room, a
/// page tall. Taller than the viewport, it is bottom-aligned, so the caret's
/// line lands at the TOP over a page of room. It fires after a typed ⏎
/// (`textInputDidChange:` — arm 2) and on every relayout while she holds the
/// keyboard, the keyboard's placement animation above all (arm 3's fight —
/// her drag engages `.interactive` dismissal, the keyboard springs back, and
/// the reveal throws her onto the room again). No line of ours issues those
/// scrolls; every one of them passes through `scrollRectToVisible`, so that
/// is where the authority sits.
///
/// Two rules, both pure so they are pinned without a window:
/// 1. **A reveal never reaches past the text** — the requested rect is
///    clamped at the text's bottom edge, so revealing the last line is the
///    same minimal reveal as revealing any other line. The room's EXISTENCE
///    is untouched (P24, her ruled shape (c)): it stays real scrollable
///    range, reachable by her scroll and only by her scroll.
/// 2. **Her gesture wins** — while her pan is live (dragging or decelerating)
///    and for `userScrollQuiet` after her finger last moved the page, no
///    programmatic reveal moves it. A TAP is not a pan (the caret reveal of a
///    tap-to-type still runs); typing after the quiet window reveals the
///    caret's line minimally, which is the ruled shape.
nonisolated enum MobileScrollAuthority {
    /// How long after her last pan movement (or her finger's release) the
    /// page stays hers. PROVISIONAL (QUESTIONS #200(a)) — long enough to cover
    /// the keyboard's spring-back animation after an `.interactive` drag
    /// (~0.25–0.4 s on the device class), short enough that a deliberate tap
    /// to type a moment later is never swallowed.
    static let userScrollQuiet: CFTimeInterval = 0.6

    /// Rule 1: the rect UIKit asked to reveal, never reaching past the text's
    /// bottom edge. A rect wholly below the text (not produced by any traced
    /// road — the caret always sits on a text line) collapses to a one-point
    /// rect AT the text's foot rather than into the room.
    static func revealRect(_ requested: CGRect, textBottom: CGFloat) -> CGRect {
        guard requested.maxY > textBottom else { return requested }
        guard requested.minY < textBottom else {
            return CGRect(x: requested.minX, y: max(0, textBottom - 1), width: requested.width, height: 1)
        }
        var clamped = requested
        clamped.size.height = textBottom - requested.minY
        return clamped
    }

    /// Rule 2: is the page still hers?
    static func herGestureHolds(
        now: CFTimeInterval, lastUserScroll: CFTimeInterval,
        dragging: Bool, decelerating: Bool
    ) -> Bool {
        dragging || decelerating || now - lastUserScroll < userScrollQuiet
    }
}

/// **The page's PLACE, content-anchored** (VM-10, her ruled shape (2): the
/// page's offset remembered per note for the session and restored on
/// re-entry). Never a raw pixel offset — TK2 estimates every fragment it has
/// not laid out, so the same y means a different paragraph on the way back
/// (the Mac's measured lesson, `EditorRouter.scrollPlaces`). The anchor is the
/// character offset where the layout fragment at the viewport's top begins;
/// `inset` is how far below that fragment's top the viewport's top edge sat.
/// The caret rides along so a focus arrival reveals HER line, minimally
/// (PROVISIONAL — QUESTIONS #200(b)).
struct MobileWritePlace: Equatable, Sendable {
    let anchor: Int
    let inset: CGFloat
    let caret: NSRange
}

// MARK: - The text view

@MainActor
final class MobileEditorTextView: UITextView {
    private let canary = MobileFallbackCanary()

    // MARK: The scroll authority's state (VM-10)

    /// When her own pan last moved the page (or her finger lifted from it) —
    /// rule 2's clock. Stamped by the scroll view's own pan recognizer and by
    /// every decelerating layout tick.
    private(set) var lastUserScroll: CFTimeInterval = -.infinity

    /// The clock — a test seam and nothing else (the pins step it past the
    /// quiet window instead of sleeping on the main actor).
    var clock: () -> CFTimeInterval = { CACurrentMediaTime() }

    /// Called as the view leaves its window with the page's place at that
    /// moment — the VM's road into the session memory (VM-10). Leaving the
    /// window is the one moment the layout still answers; after it the
    /// representable may be released concurrently with the screen.
    var onLeavingWindow: ((MobileWritePlace) -> Void)?

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
    /// The BLOCK HISTORY sheet's pixels (parity C4a's sibling, widened at
    /// round 2 batch 6a to her four regions).
    private(set) var blockHistorySheetView: MobileBlockHistorySheetView?
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
        // C4a, widened at 6a: the Block History sheet (comments' pattern).
        let historyView = MobileBlockHistorySheetView(textView: self, model: model)
        blockHistorySheetView = historyView
        model.blockHistory.onChanged = { [weak historyView] in
            historyView?.render()
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
        // VM-10 rule 2: a fling's frames are hers too. Stamped BEFORE super,
        // because `super.layoutSubviews` is where UIKit's `_layoutText` runs
        // `_scrollToSelectionIfNeeded` (the arm-3 trace's own frame).
        if isDecelerating { lastUserScroll = clock() }
        super.layoutSubviews()
        updateTypewriterRoom()
        refreshChrome(scope: .nearViewport)
        notePlaceIfMoved()
    }

    /// The page's place as of the last layout pass that MOVED it (VM-10).
    /// Kept because the leaving moment cannot always answer: measured, a
    /// surface whose window is going away no longer resolves its viewport's
    /// positions, so `currentPlace()` there returns nil. Equality-gated on
    /// the offset — a pass that did not move the page computes nothing — and
    /// viewport-local when it does (one position + one fragment lookup at the
    /// viewport's top edge; never the document).
    private var lastPlace: (offsetY: CGFloat, place: MobileWritePlace)?

    private func notePlaceIfMoved() {
        guard lastPlace?.offsetY != contentOffset.y, let place = currentPlace() else { return }
        lastPlace = (contentOffset.y, place)
    }

    // MARK: The scroll authority (VM-10 — the one choke point)

    /// Every reveal UIKit makes on this surface — the caret after a keystroke
    /// (`_scrollToCaretIfNeeded`), the selection's line after an edit or a
    /// relayout (`_scrollToSelectionIfNeeded`), `scrollRangeToVisible` —
    /// arrives here (traced: the record's initiator stacks). The two rules
    /// are `MobileScrollAuthority`'s; this only feeds them the live facts.
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        if herGestureHolds() { return }
        if isFirstResponder { revealGrantedAt = clock() }
        super.scrollRectToVisible(
            MobileScrollAuthority.revealRect(rect, textBottom: textBottom()), animated: animated)
    }

    /// **The second layer, for the road that bypasses the first** (traced,
    /// intermittently: the keyboard's tracking-element road —
    /// `UITrackingElementWindowController moveFromPlacement:…` — was seen
    /// reaching UIScrollView's `scrollRectToVisible` WITHOUT this subclass's
    /// override, its 376-pt room-padded rect unclamped, landing on the room).
    /// Every reveal ends in an ANIMATED `setContentOffset`; so a programmatic
    /// animated move may never carry the page past the point where the
    /// text's foot meets the viewport's foot — unless she is already past it,
    /// in which case it may not push her further. Her own scrolling is never
    /// this call (pans and flings set the offset frame by frame, unanimated),
    /// and neither are the deliberate jumps (`jumpToBlock`, `restore`), which
    /// are unanimated by design: the room remains a legitimate target there.
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        guard animated else {
            super.setContentOffset(contentOffset, animated: false)
            return
        }
        if herGestureHolds() { return }
        let foot = textBottom() - bounds.height + adjustedContentInset.bottom
        var target = contentOffset
        target.y = min(target.y, max(self.contentOffset.y, foot))
        super.setContentOffset(target, animated: true)
    }

    private func herGestureHolds() -> Bool {
        MobileScrollAuthority.herGestureHolds(
            now: clock(), lastUserScroll: lastUserScroll,
            dragging: isDragging, decelerating: isDecelerating)
    }

    /// When a reveal was last granted while she held the keyboard — the
    /// one-shot verify's window (below).
    private var revealGrantedAt: CFTimeInterval = -.infinity

    /// **TK2's estimates can move the caret after a reveal is computed**
    /// (TEXTKIT2 §2's class, measured here: a far caret jump's minimal
    /// reveal computed at the caret's ESTIMATED y, then real layout moved it
    /// ~128 pt lower, leaving it under the viewport). Before this unit the
    /// room-padded overshoot masked that for the last line by accident. So
    /// once a reveal's animation ends (the gate delegate forwards
    /// `scrollViewDidEndScrollingAnimation`), the caret's now-laid-out rect
    /// is checked once and, if it fell off the page, revealed once more —
    /// minimally, through both layers. Bounded: one verify per grant, only
    /// within a second of it, never during her gesture.
    func revealCaretIfLostToEstimates() {
        guard clock() - revealGrantedAt < 1.0 else { return }
        revealGrantedAt = -.infinity
        guard isFirstResponder, !herGestureHolds(), let selection = selectedTextRange else { return }
        let caret = caretRect(for: selection.end)
        guard !caret.isNull, !caret.isInfinite else { return }
        let top = contentOffset.y + adjustedContentInset.top
        let bottom = contentOffset.y + bounds.height - adjustedContentInset.bottom
        guard caret.minY < top || caret.maxY > bottom else { return }
        // The minimal offset, computed here rather than through UIKit's
        // `scrollRectToVisible` — measured: that call declines to move when
        // TK2's ESTIMATED `contentSize` still ends above the laid-out caret
        // (the very drift this verify exists for), so it leaves her caret
        // under the keyboard. Not bounded by that estimate, for the reason
        // `jumpToBlock` records; still through this view's animated
        // `setContentOffset`, so the room clamp and her-gesture rule hold.
        let margin: CGFloat = 4
        let target = caret.maxY > bottom
            ? caret.maxY + margin - bounds.height + adjustedContentInset.bottom
            : caret.minY - margin - adjustedContentInset.top
        setContentOffset(CGPoint(x: contentOffset.x, y: max(0, target)), animated: true)
    }

    /// The text's bottom edge in content coordinates — the lower of two
    /// readings, floored at the caret's own line.
    ///
    /// · `contentSize` less the room alone is NOT enough, measured: during the
    ///   keyboard's placement the room (this view's inset, re-derived from its
    ///   height) and `contentSize` (UIKit's, re-derived a pass later) were
    ///   seen to DISAGREE for an instant — room 323 against a keyboard-down
    ///   size of 3165 — putting the "text bottom" 350 pt into the room, so the
    ///   tracking road's room-padded reveal passed both clamps and landed on
    ///   empty page. TK2's own used extent (`usageBoundsForTextContainer`)
    ///   never contains the room, so the lower of the two is the honest edge.
    /// · Floored at the caret's line: an estimate may trail the layout right
    ///   after an edit, and a clamp must still reveal the line she is on.
    private func textBottom() -> CGFloat {
        var bottom = contentSize.height - textContainerInset.bottom
        if let tlm = textLayoutManager {
            bottom = min(bottom, tlm.usageBoundsForTextContainer.maxY + textContainerInset.top)
        }
        guard let selection = selectedTextRange else { return bottom }
        let caret = caretRect(for: selection.end)
        guard !caret.isNull, !caret.isInfinite else { return bottom }
        return max(bottom, caret.maxY)
    }

    /// Rule 2's other half: the scroll view's OWN pan recognizer reports her
    /// drag (began · changed · ended — the release itself is the moment the
    /// keyboard's spring-back animation starts). Installed in `make()`.
    @objc func herPanMoved(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began, .changed, .ended, .cancelled:
            noteHerScroll()
        default:
            break
        }
    }

    /// Stamps rule 2's clock (the pan target's body, and the pins' seam —
    /// a pan cannot be synthesized in process).
    func noteHerScroll() {
        lastUserScroll = clock()
    }

    // MARK: The page's place (VM-10 — her ruled shape (2))

    /// Where the page is: the layout fragment at the viewport's top, and how
    /// far into it the viewport's edge sits. `.ensuresLayout`-free — the top
    /// of the viewport is laid out by definition. nil before any text.
    func currentPlace() -> MobileWritePlace? {
        guard textStorage.length > 0,
              let tlm = textLayoutManager,
              let cm = tlm.textContentManager
        else { return nil }
        let caret = selectedRange
        guard contentOffset.y > 0.5 else {
            return MobileWritePlace(anchor: 0, inset: 0, caret: caret)
        }
        let top = CGPoint(x: textContainerInset.left + 1, y: contentOffset.y + 1)
        guard let position = closestPosition(to: top) else { return nil }
        let offset = self.offset(from: beginningOfDocument, to: position)
        guard let location = cm.location(tlm.documentRange.location, offsetBy: offset),
              let fragment = tlm.textLayoutFragment(for: location)
        else { return nil }
        let fragmentStart = cm.offset(
            from: tlm.documentRange.location, to: fragment.rangeInElement.location)
        return MobileWritePlace(
            anchor: fragmentStart,
            inset: contentOffset.y - (fragment.layoutFragmentFrame.minY + textContainerInset.top),
            caret: caret)
    }

    /// Puts the page back at a remembered place: the caret first (clamped to
    /// today's text — the note may have changed since), then the offset from
    /// the anchor's fragment, laid out on exactly that fragment (the
    /// hybrid-jump cost class — `jumpToBlock`'s primitive). Not clamped
    /// against `contentSize`, for `jumpToBlock`'s recorded reason: TK2's
    /// estimate can run under the real layout at the target.
    func restore(_ place: MobileWritePlace) {
        let length = textStorage.length
        let caretLocation = min(place.caret.location, length)
        selectedRange = NSRange(
            location: caretLocation, length: min(place.caret.length, length - caretLocation))
        let anchor = min(place.anchor, length)
        guard anchor > 0 || place.inset > 0.5,
              let geometry = firstLineGeometry(atOffset: anchor)
        else {
            setContentOffset(.zero, animated: false)
            return
        }
        let target = geometry.fragmentMinY + textContainerInset.top + place.inset
        setContentOffset(CGPoint(x: 0, y: max(0, target)), animated: false)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil, window != nil, let place = leavingPlace() {
            onLeavingWindow?(place)
        }
        super.willMove(toWindow: newWindow)
    }

    /// The place to remember as the page leaves: the live answer when the
    /// layout still gives one, else the last place a layout pass recorded
    /// (with the caret as it stands NOW — the selection needs no layout).
    private func leavingPlace() -> MobileWritePlace? {
        if let live = currentPlace() { return live }
        guard let cached = lastPlace?.place else { return nil }
        return MobileWritePlace(anchor: cached.anchor, inset: cached.inset, caret: selectedRange)
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
        // FIND IN NOTE (parity C4b item 3 — the Mac ⌘F family's phone
        // face, the matrix's own shape: iOS's OWN find interaction, the
        // system navigator over UITextView's native UITextSearching
        // adoption). The TEXTKIT2 §3 care, held by construction: this
        // code draws NO highlight of its own — match decoration is the
        // system interaction's internal business, never a rendering
        // attribute of ours — and nothing here touches spell-checking
        // (no `spellCheckingType` change, no UITextChecker; the §3
        // crash pairing is left exactly alone). Hardware ⌘F rides the
        // system's own find key commands once the interaction is on.
        view.isFindInteractionEnabled = true
        // The prose margins (parity A3 spacing floor — the LK canon's
        // `.prose padding:8px 20px`; her "more padding generally"): 15 pt
        // insets + the container's default 5 pt fragment padding = the
        // canon's 20 pt visual margin each side. The default near-zero
        // margins were the floor's headline finding. Bottom is managed by
        // the typewriter room (P24) at every layout.
        view.textContainerInset = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
        // VM-10 rule 2: the scroll view's own pan recognizer tells the
        // authority when the page is hers (an added target — UIScrollView's
        // own handling is untouched).
        view.panGestureRecognizer.addTarget(
            view, action: #selector(MobileEditorTextView.herPanMoved(_:)))

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

    // MARK: Find in note (parity C4b item 3)

    /// **REPLACE IS STRUCTURALLY OFF — find only (PROVISIONAL, C4b).**
    /// The Mac's find-replace exists only because two measured facts
    /// (EditorFind's M1/M1b) forced a whole custom gate: the system
    /// finder applies Replace All as ONE coalesced multi-block storage
    /// transaction that bypasses the per-block edit police, so the Mac
    /// answers the finder NO and re-drives every match through the
    /// ordinary input path itself. iOS's system replace road is exactly
    /// as unmeasured here as AppKit's was there — whether it consults
    /// the delegate gate per match is undocumented — and a machine-
    /// driven sweep that could cross block seams unpoliced is the class
    /// the Mac refused outright. So the phone ships FIND whole and
    /// declines replacement at the protocol's own switch: the system
    /// never offers a replace field. The in-note replace face lands
    /// when it can ride the policed path (the Mac's deferred-
    /// application shape, UIKit-spelled); the takes-aware replace
    /// family is 13e's either way.
    override var supportsTextReplacement: Bool { false }

    // MARK: Canary forwards

    var onCanaryFired: ((String) -> Void)? {
        get { canary.onFire }
        set { canary.onFire = newValue }
    }
    var canaryFired: Bool { canary.fired }

    func armCanary() { canary.arm(for: self) }
    func disarmCanary() { canary.disarm() }
    /// Test/teardown oracle (round 2, M2e).
    var canaryIsArmed: Bool { canary.isArmed }

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
