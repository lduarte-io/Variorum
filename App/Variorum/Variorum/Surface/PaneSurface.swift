//
//  PaneSurface.swift
//  Variorum
//
//  Phase 13b, Stage 1a (P-3): the ONE pane surface — a TK2 text view with
//  read + live MODES, one measurement brain, and a RENDERED canary —
//  composed by every take pane (all four fan styles), the read tier's
//  view core, the takes article cell, the TOC's expanded rows, and the
//  Write takes panel. Replaces `TakePaneView`/`TakeTextView` and
//  `ReadPostTextView` (three private copies of the height brain and a
//  canary that wrote into a variable nothing rendered — N2).
//
//  The app deliberately keeps TWO surface kinds (the Stage 1a architect
//  precision): the FULL-DOCUMENT editor (`EditorTextView` + its identity
//  machinery) is the other kind and is NOT this component — both consult
//  the one authority (`PaneTextAuthority`) and the one per-post autosave.
//
//  Measurement discipline (the batch-12 clipped-take class, closed for
//  every composer): a pane measures through `PaneMeasurement` and
//  re-measures on the WIDTH-GATED layout hook — a zero-width install
//  cannot pin a pane at one line, whichever surface composes it. Since
//  13c 1F (A47) the discipline is BOTH-SIDED: same-width layout passes
//  run a divergence check, so a frame left TALLER than its text (the
//  stale class the width/string/font gates could never re-trigger on,
//  and the heal — which only chases a SHORT frame — could never shrink)
//  self-heals on the next pass instead of persisting for the pane's life.
//  Since 13c 1G (A47b — the void SURVIVED the 1F build) the check also
//  has PRODUCTION TRIGGERS and a REMEDY THAT CANNOT NO-OP: the census
//  proved clicks/scrolls/idle deliver zero layout passes to an idle card
//  (the 1F branch alone never ran), so scroll-end, clicks, and liveness
//  transitions fire the check as user-event occasions; and because an
//  equal-value @State write is a SwiftUI no-op (a dropped frame
//  application left the state right and the frame wrong — the publisher's
//  own mid-update class), the heal's chase now pulls the AppKit frame
//  directly on a divergent turn (the frame lever).
//
//  Why a full-document `ensureLayout` is legitimate HERE (ladder round 3,
//  NIT-A — verified P1-safe, not a violation): every composer of this
//  component passes ONE take's / one post-read's text, so "the document"
//  is pane-scale by construction and layout cost is bounded by the unit
//  on screen (P1's letter). The full-document EDITOR is the other surface
//  kind and uses its own coordinator and its own viewport-bounded layout
//  — nothing here touches it. The heal below therefore measures more than
//  once per settle deliberately; a repeat `ensureLayout` over already-laid
//  text is near-free, and the bound (`PanePublisher.healTurnBudget`) caps
//  it regardless.
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - The ONE measurement brain

@MainActor
enum PaneMeasurement {
    /// Content height of a TK2 surface at its current width: full-document
    /// layout (pane-scale by construction — a pane is one take / one post's
    /// read view) + the container inset. Every pane height in the app comes
    /// from here; a divergent private copy is the batch-12 bug class.
    static func height(of view: NSTextView) -> CGFloat {
        guard let layoutManager = view.textLayoutManager else { return 0 }
        return extent(of: layoutManager) + view.textContainerInset.height * 2
    }

    /// The laid-out text's own bottom — **deliberately not
    /// `usageBoundsForTextContainer`** (17o batch c, ledger row 16; her
    /// punchlist 13: *"delete a lot of text from a take… empty gap… until
    /// you switch modes"*).
    ///
    /// **MEASURED, not assumed** (the standing "measure before believing a
    /// number" rule; probe numbers in the batch record): on macOS 26,
    /// `usageBoundsForTextContainer` is a **HIGH-WATER MARK for the
    /// container's life**. A 30-line pane measured 1223; deleting 25 of
    /// those lines through the real edit path left the property at 1189
    /// and it stayed there for six main-queue turns — so a five-line take
    /// kept a 1201-pt frame and ~1000 pt of dead gap, exactly her report,
    /// until a remount built a fresh container. `ensureLayout(for:
    /// documentRange)` was already run on every measurement and does not
    /// move it; an explicit `invalidateLayout(for: documentRange)` ahead of
    /// it does not move it either (both measured). What tracks the text in
    /// BOTH directions is the fragments' own geometry: after the same
    /// deletion the last fragment's bottom read 198, and after typing ten
    /// lines back it read 608, while the property sat at 1189 throughout.
    ///
    /// At steady state the two agree EXACTLY — empty, one line, a trailing
    /// newline, two trailing newlines, blank lines between paragraphs, one
    /// long wrapping line, 30 lines and 400 lines all measured identical —
    /// so no converged pane's height moves by a point. The one shape that
    /// differs is the EMPTY document, which lays out no fragment at all
    /// while the property still reports one empty line's 17 pt; the
    /// fallback below keeps that shipped number, so an empty block's pane
    /// (18c's Return rule mints them; row 15's first block is one) is
    /// unchanged.
    ///
    /// Cost: `.ensuresLayout` does the layout the old call did, and the
    /// added work is one frame read per fragment — measured 0.58 ms vs
    /// 0.41 ms on a 400-line / 16,393-pt pane, 0.12 ms at 30 lines. P1
    /// holds for the reason this file already states: a pane's document is
    /// ONE take by construction, so the bound is the unit on screen.
    private static func extent(of layoutManager: NSTextLayoutManager) -> CGFloat {
        var bottom: CGFloat?
        layoutManager.enumerateTextLayoutFragments(
            from: nil, options: [.ensuresLayout]
        ) { fragment in
            bottom = max(bottom ?? 0, fragment.layoutFragmentFrame.maxY)
            return true
        }
        return bottom ?? layoutManager.usageBoundsForTextContainer.height
    }
}

// MARK: - The ONE publish door

/// Every state write a pane surface makes leaves through here (ladder
/// round 3, MINOR-D/E/F — the class-level fix over two hand-added
/// repairs, on the one component every pane composes, P-3).
///
/// The hole it closes: a pane publishes its measured height and its
/// canary message into SwiftUI `@State`, and both can fire MID view-update
/// (the width-gated layout hook runs inside SwiftUI's layout pass;
/// `updateNSView`'s text-adopt remeasure runs inside the update
/// transaction). SwiftUI may DROP a state write made during an update
/// ("Modifying state during view update … undefined behavior"), and a
/// dropped height write left a compare pane framed one line tall under two
/// lines of text with nothing left to re-publish.
///
/// The shape (why a helper, not two repairs): a publish added to this
/// coordinator later inherits the discipline STRUCTURALLY — there is no
/// second way out. Each publish (a) writes synchronously, the common
/// working path a deferred-only publish would starve under a busy main
/// queue, and (b) is re-made on a later main-queue turn, where a write
/// always lands. Deferred turns COALESCE (one per turn, however many
/// publishes of either kind fired — MINOR-F's un-coalesced canary echo
/// dies here), and the height re-publish is a real CONVERGENCE loop
/// (MINOR-E): it re-measures, compares against what the pane actually
/// renders, and re-schedules while the frame is short — BOUNDED, because
/// a shortfall that survives the budget is not a dropped write (a
/// composer deliberately constraining the frame would otherwise spin the
/// main queue for the pane's whole life).
@MainActor
final class PanePublisher {
    /// Deferred work runs on the next main-queue turn; tests inject a
    /// manual scheduler and drain it (no RunLoop pumping).
    typealias Scheduler = (@escaping () -> Void) -> Void

    /// Deferred turns a height publish may take to converge. One turn
    /// carries the ordinary case (the write lands, SwiftUI re-frames);
    /// three covers a second dropped write plus a layout settle. Beyond
    /// that the shortfall is structural, not a dropped write.
    static let healTurnBudget = 3
    /// How much shorter than its measured text a pane may render before
    /// the heal calls it un-converged (the compare soak's own tolerance).
    static let convergenceSlack: CGFloat = 3

    /// nil ⇒ the pane is gone; publishing stops.
    private var measure: (() -> CGFloat?)?
    private var renderedHeight: (() -> CGFloat?)?
    /// 13c 1G (A47b): the FRAME LEVER. The heal's only remedy used to be a
    /// height @State write — and when the state ALREADY holds the measured
    /// value while the rendered frame does not (a frame application dropped
    /// by SwiftUI: the same mid-update hazard this publisher exists for),
    /// an equal-value @State write invalidates nothing and the frame never
    /// moves — a heal that fires forever and heals nothing (her void, on
    /// the 1F build). A chase turn that still renders divergent now applies
    /// the frame DIRECTLY to the view (deferred turn — never inside a
    /// SwiftUI update); SwiftUI's next layout re-imposes the same value, so
    /// the two authorities agree instead of fighting.
    private var applyFrame: ((CGFloat) -> Void)?
    private var writeHeight: ((CGFloat) -> Void)?
    private var writeCanary: ((String) -> Void)?
    private let schedule: Scheduler

    private var turnScheduled = false
    private var pendingCanary: String?
    private var healTurnsLeft = 0
    /// Observation for the pins (and for a future soak): how many deferred
    /// turns this publisher has run.
    private(set) var deferredTurns = 0

    init(
        measure: @escaping () -> CGFloat?,
        renderedHeight: @escaping () -> CGFloat?,
        applyFrame: ((CGFloat) -> Void)? = nil,
        writeHeight: @escaping (CGFloat) -> Void,
        writeCanary: @escaping (String) -> Void,
        schedule: @escaping Scheduler = { work in DispatchQueue.main.async(execute: work) }
    ) {
        self.measure = measure
        self.renderedHeight = renderedHeight
        self.applyFrame = applyFrame
        self.writeHeight = writeHeight
        self.writeCanary = writeCanary
        self.schedule = schedule
    }

    /// Measure and publish the pane's height, then heal until the rendered
    /// frame agrees (or the budget runs out).
    func publishHeight() {
        guard let height = measure?() else { return }
        writeHeight?(height)
        healTurnsLeft = Self.healTurnBudget
        scheduleTurn()
    }

    /// Publish a canary message (sync) plus ONE coalesced echo next turn.
    func publishCanary(_ message: String) {
        writeCanary?(message)
        pendingCanary = message
        scheduleTurn()
    }

    /// The pane is going away: drop every closure and every pending duty.
    /// A turn already scheduled runs and finds nothing to do.
    func invalidate() {
        measure = nil
        renderedHeight = nil
        applyFrame = nil
        writeHeight = nil
        writeCanary = nil
        pendingCanary = nil
        healTurnsLeft = 0
    }

    private func scheduleTurn() {
        guard !turnScheduled else { return }
        turnScheduled = true
        schedule { [weak self] in self?.runTurn() }
    }

    private func runTurn() {
        turnScheduled = false
        deferredTurns += 1
        if let message = pendingCanary {
            pendingCanary = nil
            writeCanary?(message)
        }
        guard healTurnsLeft > 0 else { return }
        healTurnsLeft -= 1
        guard let height = measure?() else {
            healTurnsLeft = 0
            return
        }
        writeHeight?(height)
        // The convergence check: what does the pane actually RENDER? While
        // it disagrees with the measurement — in EITHER direction (13c 1G:
        // the short-only chase left a tall frame terminal) — the write did
        // not take: pull the frame itself (the lever; an equal-value state
        // write is a SwiftUI no-op, so the state alone cannot move it) and
        // try again until the budget is spent.
        let rendered = renderedHeight?() ?? height
        if abs(rendered - height) > Self.convergenceSlack, healTurnsLeft > 0 {
            applyFrame?(height)
            scheduleTurn()
        } else {
            healTurnsLeft = 0
        }
    }
}

// MARK: - The text view

final class PaneTextView: NSTextView, MarkdownFormattable {
    /// A click that created no selection — the click-to-focus gesture, with
    /// the clicked UTF-16 offset (the read tier seeds the editor's caret
    /// from it; take panes ignore the value).
    var onPlainClick: ((Int) -> Void)?

    /// **17o batch b's ladder, R1-2: the click has ALREADY placed the caret.**
    /// Set by the plain click-to-focus gesture, so the live transition that
    /// click causes leaves the selection where the click put it instead of
    /// landing the composition's remembered place over it (measured on the
    /// Lenses board: a click at offset 10 into another take of the current
    /// block went live at the first take's offset). Read and spent by the
    /// coordinator's liveness transition: a read→read render keeps it (the
    /// flip may take a render to arrive), a live render or any transition
    /// consumes it. Round 2 (R2-2), said exactly: it is spent by the NEXT
    /// transition or live render of THIS pane — so on a host whose click
    /// flips nothing (the workbench panel's read pane of a LOCKED take: the
    /// authority moves, the pane stays read) it stays armed until that pane
    /// next goes live, harmlessly — such a pane then lands at the click's own
    /// place, the better landing, and it reports nothing.
    var clickBroughtPlace = false

    /// The plain click-to-focus gesture as ONE road — `mouseDown`'s tail and
    /// the pins' door (a synthesized `NSEvent` would run AppKit's selection
    /// tracking loop, which waits on a mouse-up nobody sends).
    func plainClick(at offset: Int) {
        clickBroughtPlace = true
        onPlainClick?(offset)
    }

    /// **13e E3 — ⌘-CLICK, where a composition claims it** (her A18: *"⌘-click
    /// in Takes to select blocks to merge"*). Return true to CONSUME the
    /// click: no selection tracking, no click-to-focus. nil everywhere but
    /// the Takes board's article cells, so no other pane's behaviour moves.
    ///
    /// It is asked AFTER the link check, deliberately: 13g L10 gave ⌘-click a
    /// meaning where a LINK sits under the pointer, and a shipped ruling
    /// outranks a new gesture on the same chord. Off a link — which is the
    /// whole of an ordinary block — the chord was unclaimed (it fell through
    /// to plain selection tracking plus focus).
    ///
    /// 13e E2 (her A17) widened it to carry ONE fact — whether ⇧ was also
    /// held, i.e. "extend the run" rather than "toggle this one". A second
    /// closure would have made the two halves of one gesture two doors, and
    /// the modifier is genuinely part of the click, not a separate act.
    var onCommandClick: ((Bool) -> Bool)?

    /// 13b 1b (AD-4): the pane's Variorum context menu — right-clicking a
    /// take card used to show ONLY the stock text menu (the SwiftUI
    /// `.contextMenu` never fires inside an NSTextView); the composer now
    /// supplies registry-vocabulary items rendered ABOVE the standard edit
    /// items (the EditorTextView pattern).
    struct MenuItemSpec {
        let title: String
        var enabled = true
        var action: () -> Void = {}
        var children: [MenuItemSpec] = []
        /// 13e E1: a leading image for the row — today the callout palette's
        /// colour swatch (`CalloutMenu.swatchImage`). It rides the SPEC rather
        /// than being built here so the composing surface stays the only place
        /// that knows what a row means, and so the swatch is the same object
        /// the other two callout renderers draw.
        var image: NSImage?
    }

    var variorumMenu: (() -> [MenuItemSpec])?

    override func menu(for event: NSEvent) -> NSMenu? {
        let inherited = super.menu(for: event)
        let items = variorumMenu?() ?? []
        // 13g batch 3 (L8): the same formatting rows the full-document
        // editor offers, from the same builder — a live pane is a writing
        // surface, and a read one honestly has no Format submenu (P-2).
        let format = MarkdownActs.formatMenuItem(for: self)
        guard !items.isEmpty || format != nil else { return inherited }
        let menu = inherited ?? NSMenu()
        var at = 0
        for item in items {
            menu.insertItem(Self.makeMenuItem(for: item), at: at)
            at += 1
        }
        if let format {
            menu.insertItem(format, at: at)
            at += 1
        }
        menu.insertItem(NSMenuItem.separator(), at: at)
        return menu
    }

    private static func makeMenuItem(for spec: MenuItemSpec) -> NSMenuItem {
        let menuItem = NSMenuItem(
            title: spec.title,
            action: #selector(PaneMenuTrampoline.fire(_:)),
            keyEquivalent: "")
        let trampoline = PaneMenuTrampoline(enabled: spec.enabled, action: spec.action)
        menuItem.target = trampoline
        menuItem.representedObject = trampoline  // retains it for the menu's life
        menuItem.image = spec.image
        if !spec.children.isEmpty {
            let submenu = NSMenu(title: spec.title)
            for child in spec.children {
                submenu.addItem(makeMenuItem(for: child))
            }
            menuItem.submenu = submenu
        }
        return menuItem
    }

    /// 13k K5 — TRUE only while a SHIFT-Return keystroke's own insertion is
    /// running, exactly as `EditorTextView.isSoftNewline` is and for the
    /// same measured reason (AppKit dispatches `insertNewline:` for BOTH
    /// keys, so the event is the only place they differ). A pane has no
    /// structural semantics to protect — it exists here so a soft break
    /// inside a list item does not sprout a second bullet, which is the one
    /// thing the two surfaces should agree on.
    private(set) var isSoftNewline = false

    override func keyDown(with event: NSEvent) {
        guard EditorTextView.isSoftNewlineKey(event) else {
            super.keyDown(with: event)
            return
        }
        isSoftNewline = true
        defer { isSoftNewline = false }
        super.keyDown(with: event)
    }

    /// **Act 10 item 12 — typed arrows on the pane surface too.** A live
    /// take/lens pane is a writing surface (the formatting acts' own
    /// premise), so `->` earns its arrow here exactly as in the full editor;
    /// the trio routes through this pane's coordinator like every other
    /// formatting edit.
    override func insertText(_ string: Any, replacementRange: NSRange) {
        super.insertText(string, replacementRange: replacementRange)
        MarkdownActs.substituteTypedArrow(afterTyping: string, in: self)
    }

    /// **13k K5 — ⏎ continues a list**, through the one shared door. A
    /// pane's newline is ordinary text (no open tail, no crystallization),
    /// so the only thing this adds is the lead — and it adds it exactly the
    /// way the full-document editor does, so a list reads the same wherever
    /// she is typing (R118: Write is never privileged over Takes).
    override func insertNewline(_ sender: Any?) {
        guard !isSoftNewline else {
            super.insertNewline(sender)
            return
        }
        MarkdownActs.insertNewlineContinuingLists(in: self) {
            super.insertNewline(sender)
        }
    }

    /// **13k K8 — Tab indents a list line, ⇧Tab outdents it** (her ruling +
    /// sitting Q3). Outside a list line — and that includes a selection no
    /// list line touches — `super` runs and the key is byte-for-byte what it
    /// has always been, because `MarkdownActs.indentLists` acts ONLY when the
    /// plan is non-empty.
    override func insertTab(_ sender: Any?) {
        MarkdownActs.indentLists(MarkdownEditing.Act.indent, in: self) { super.insertTab(sender) }
    }

    override func insertBacktab(_ sender: Any?) {
        MarkdownActs.indentLists(MarkdownEditing.Act.outdent, in: self) { super.insertBacktab(sender) }
    }

    /// 13b 1b (N9's keyboard half): a pane that goes LIVE should hold the
    /// keyboard — set when liveness arrives before the view has a window
    /// (programmatic landings), honored at attach.
    var claimsKeyboardOnAttach = false

    /// 13c A47c: the last ink applyStyle wrote, so an update with the SAME
    /// ink writes nothing. `NSTextView.textColor`'s setter re-attributes
    /// the ENTIRE storage, and the A47c trace proved that full-range write
    /// — running unguarded on EVERY updateNSView — destroys the rendering
    /// surfaces above the tail of a tail-scrolled long pane (14 → 6 in the
    /// real board; the draw gap's production trigger). Styling is now
    /// change-gated, so the write survives only where it means something
    /// (a real voice/ink switch).
    var appliedInk: NSColor?

    /// 13c 1G (A47b): the PRODUCTION occasions for the divergence check.
    /// The 1F check rides `layout()` — and the 1G census proved production
    /// delivers NO layout passes to an idle, already-laid-out card: clicks,
    /// selections, scrolls, and idle set no `needsLayout` (counters frozen
    /// through every driven phase), so a divergence born without leaving
    /// layout dirt behind starved forever — her void, still present on the
    /// 1F build; the 1F pin drove the pass by hand (R3-4's class one layer
    /// up). Three USER-EVENT wires now fire the same check: the enclosing
    /// scroll view's end-of-live-scroll, a click on the pane, and a
    /// liveness transition (her "clicking into other blocks", verbatim).
    /// Termination: each occasion is a discrete user event that a height
    /// publish can never cause, the check publishes only on divergence,
    /// and the corrective publish's own layout pass measures equal and
    /// stays silent.
    var onConvergenceOccasion: (() -> Void)?
    /// Observation seam (the R3-4 pin-honesty lesson, applied here on day
    /// one): every occasion funnels through `fireConvergenceOccasion()`,
    /// so a pin can assert the WIRE fired — a heal alone can be satisfied
    /// by an incidental layout pass and proves nothing about the wire.
    private(set) var occasionsFired = 0
    /// …and the check itself counts its runs (the coordinator notes each
    /// execution), so a pin can assert wire → check without depending on a
    /// heal that incidental machinery could satisfy.
    private(set) var convergenceChecksRun = 0

    func fireConvergenceOccasion() {
        occasionsFired += 1
        onConvergenceOccasion?()
    }

    func noteConvergenceCheck() {
        convergenceChecksRun += 1
    }

    /// 13c A47c: how many deferred RENDER RESTORES (viewport re-layouts —
    /// the check's render half) have run. The R3-4 observation seam: a pin
    /// asserts the wire fired AND the restore ran, never only a heal that
    /// incidental machinery could satisfy.
    private(set) var renderRestoresRun = 0

    func noteRenderRestore() {
        renderRestoresRun += 1
    }

    private weak var observedScrollView: NSScrollView?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if claimsKeyboardOnAttach, let window {
            claimsKeyboardOnAttach = false
            window.makeFirstResponder(self)
        }
        observeEnclosingScrollView()
    }

    private func observeEnclosingScrollView() {
        if let observed = observedScrollView {
            NotificationCenter.default.removeObserver(
                self, name: NSScrollView.didEndLiveScrollNotification, object: observed)
            observedScrollView = nil
        }
        guard window != nil, let scrollView = enclosingScrollView else { return }
        NotificationCenter.default.addObserver(
            self, selector: #selector(enclosingScrollDidEndLiveScroll(_:)),
            name: NSScrollView.didEndLiveScrollNotification, object: scrollView)
        observedScrollView = scrollView
    }

    @objc private func enclosingScrollDidEndLiveScroll(_ note: Notification) {
        fireConvergenceOccasion()
    }
    /// Fires when layout gives the view a NEW width (batch 12 — the
    /// clipped-take fix's trigger; width-gated so height publishes can't
    /// loop through it).
    var onWidthChange: (() -> Void)?
    /// Fires on every SAME-WIDTH layout pass (13c 1F — A47, the take-card
    /// gap): the frame must hug the pane's CURRENT measurement from BOTH
    /// sides, and before this hook nothing ever re-checked it — every
    /// remeasure trigger was gated on a width/string/font CHANGE, and the
    /// publisher's heal re-schedules only while the frame renders SHORT of
    /// its measurement. So a frame left TALLER than the text's real extent
    /// (her ~450pt un-clickable void at the end of a take, born within a
    /// minute of launch on text unchanged for days) was TERMINAL: no event
    /// short of a width change, a text change, or a font switch would ever
    /// correct it — "the large open gap isn't going away", verbatim. The
    /// listener measures and re-publishes ONLY on divergence, so a
    /// converged pane costs one warm (already-laid-out) measurement and
    /// the loop terminates by construction: a corrective publish reframes
    /// the view to the measurement, and the next pass measures equal.
    var onLayoutPass: (() -> Void)?
    private var lastLaidOutWidth: CGFloat = -1
    /// Observation seams (13c 1G — A47b): how many layout passes this view
    /// has actually received, by branch. The 1F fix's trigger question is
    /// "does production ever deliver a same-width pass to an idle card?" —
    /// these counters are how a test asks the REAL composition instead of
    /// driving `needsLayout` by hand (the R3-4 lesson, applied to the pin
    /// one layer up).
    private(set) var widthPassesRun = 0
    private(set) var sameWidthPassesRun = 0
    /// Test seam (the N2 pin): the last canary message the surface
    /// PUBLISHED for rendering — proves the fire→render wiring without
    /// walking SwiftUI internals. Written only by the surface coordinator.
    private(set) var lastPublishedCanary: String?

    func notePublishedCanary(_ message: String) {
        lastPublishedCanary = message
    }

    override func layout() {
        super.layout()
        if bounds.width != lastLaidOutWidth {
            lastLaidOutWidth = bounds.width
            widthPassesRun += 1
            onWidthChange?()
        } else {
            // Same width: the divergence check (A47). A width pass already
            // remeasures unconditionally, so the two branches never double
            // a measurement in one pass.
            sameWidthPassesRun += 1
            onLayoutPass?()
        }
    }

    override func mouseDown(with event: NSEvent) {
        // 13g batch 3 (L9): a click ON a checkbox's box toggles it, and is
        // asked BEFORE `super` because `super.mouseDown` runs AppKit's
        // selection-tracking loop. Only a LIVE pane is editable, so a read
        // pane's click still falls through to click-to-focus exactly as
        // before — her ruling's letter ("first click focuses, as today").
        if event.clickCount == 1,
           event.modifierFlags.intersection([.command, .option, .control, .shift]).isEmpty,
           MarkdownActs.toggleCheckbox(
               at: convert(event.locationInWindow, from: nil), in: self) {
            fireConvergenceOccasion()  // 13c 1G: a click is an occasion
            return
        }
        // 13g batch 4 (L10): ⌘-click follows a link — on a READ pane too,
        // because opening a link is not an edit (the read tier is where she
        // does most of her reading, and its plain click is already spoken
        // for: it seeds the editor's caret).
        if MarkdownActs.isLinkClick(event),
           MarkdownActs.openLink(
               at: convert(event.locationInWindow, from: nil), in: self) {
            fireConvergenceOccasion()  // 13c 1G: a click is an occasion
            return
        }
        // 13e E3: ⌘-click, where a composition claims it (her A18's block
        // selection). After the link door by ruling; before selection
        // tracking, because a claimed chord must not also move the caret.
        if event.clickCount == 1, event.modifierFlags.contains(.command),
           onCommandClick?(event.modifierFlags.contains(.shift)) == true {
            fireConvergenceOccasion()  // 13c 1G: a click is an occasion
            return
        }
        super.mouseDown(with: event)  // the selection tracking loop runs first
        defer { fireConvergenceOccasion() }  // 13c 1G: a click is an occasion
        guard selectedRange().length == 0 else { return }
        let point = convert(event.locationInWindow, from: nil)
        plainClick(at: characterIndexForInsertion(at: point))
    }

    /// The one factory: explicit TK2 opt-in (TEXTKIT2 §4.1), content-sized
    /// inside its container's scroll, the shared rendering brain (base font
    /// + the uniform presentation-only paragraph gap).
    static func makeSurface(inset: CGFloat, allowsUndo: Bool) -> PaneTextView {
        let view = PaneTextView(usingTextLayoutManager: true)
        precondition(view.textLayoutManager != nil, "TK2 opt-in failed at construction")
        view.isEditable = false
        view.isSelectable = true
        view.isRichText = false
        view.textContainerInset = NSSize(width: inset, height: inset)
        view.isVerticallyResizable = false
        view.isHorizontallyResizable = false
        view.autoresizingMask = [.width]
        view.textContainer?.widthTracksTextView = true
        view.font = EditorDocument.baseFont
        view.defaultParagraphStyle = EditorDocument.baseParagraphStyle
        view.typingAttributes = EditorDocument.baseAttributes
        view.allowsUndo = allowsUndo
        // 13d batch 4 (A24): panes join the setting. Before this they set
        // NEITHER flag and inherited NSTextView's defaults, so the take
        // boards and the full-document editor could disagree about spelling
        // — one setting, every TK2 surface.
        SpellcheckLevel.current.apply(to: view)
        return view
    }
}

/// The read tier's historical name — its view core IS the pane surface now
/// (P-3). Kept as an alias so the read tier and its pins name their surface
/// meaningfully.
typealias ReadPostTextView = PaneTextView

/// The pane menu's target (the EditorTextView trampoline pattern): retained
/// by its NSMenuItem via representedObject; validates enablement.
private final class PaneMenuTrampoline: NSObject, NSMenuItemValidation {
    private let enabled: Bool
    private let action: () -> Void

    init(enabled: Bool, action: @escaping () -> Void) {
        self.enabled = enabled
        self.action = action
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool { enabled }

    @objc func fire(_ sender: NSMenuItem) {
        guard enabled else { return }
        action()
    }
}

extension PaneTextView {
    /// The read tier's configuration (non-editable always; the container
    /// sizes it; selection + plain-click per the ratified read contract).
    static func makeReadSurface() -> PaneTextView {
        makeSurface(inset: EditorTypography.inlineSurfaceInset, allowsUndo: false)
    }

    /// A take pane's configuration (live/read toggled by the composer).
    static func makeTakeSurface() -> PaneTextView {
        makeSurface(inset: 6, allowsUndo: true)
    }
}

// MARK: - Where a pane's caret lands when it takes the ring

/// **Where a pane's caret goes on a PROGRAMMATIC live transition** (17o
/// batch b's ladder — R1-3 and the sanity pass's RAISE-2). A click always
/// keeps the place the click brought; this is for the transitions no click
/// caused. `.leave` is the DEFAULT and the shipped behaviour: the selection
/// stays where AppKit's `string =` left it — the END — which is what every
/// host that passes nothing (the fan/stack cards, Compare, Canvas, the Write
/// panel, the Book Index's Act 10 row-22 landing) and every post-structural
/// ring landing (the survivor, the merged block, the divide successors, the
/// moved take) had before this ladder and keeps. The hosts whose panes
/// REPORT their caret to the note's memory pass an explicit landing, because
/// there an accidental END becomes "where she was" (R1-3): `.offset` when
/// the note remembers a place in that block, `.start` for the note's ENTRY
/// landings with nothing remembered (Write's own nil rule — QUESTIONS #97
/// carries START/END, START built PROVISIONAL), `.end` when the typewriter
/// room asks for it.
nonisolated enum PaneCaretLanding: Equatable, Sendable {
    case leave
    case start
    case end
    case offset(Int)

    /// **The note's ENTRY rule, pure — ONE copy for both models** (the
    /// ladder's round 2, R2-4; it was duplicated verbatim in
    /// `TakesViewModel` and `BlockTOCViewModel`, two places a future flip
    /// could miss). The landing a pane adopts when it takes the ring
    /// PROGRAMMATICALLY for `blockID`, given the note's current-block fact:
    /// the CURRENT block lands at its remembered place, else at its START
    /// (R1-3 — QUESTIONS #97's PROVISIONAL default; a ruling for the END is
    /// the one line here); any other block answers nil, which the models
    /// hand the pane as `.leave` — the shipped END (the post-structural ring
    /// landings; a click brings its own place anyway).
    static func entering(_ fact: FocusedBlock?, block blockID: String) -> PaneCaretLanding? {
        guard let fact, fact.blockID == blockID else { return nil }
        return fact.utf16Offset.map(PaneCaretLanding.offset) ?? .start
    }
}

// MARK: - The live pane's decoration (17o batch c, row 6 — her U-7)

/// **How a pane shows that it is the live one — ONE decision, for every
/// pane in the app** (her U-7: *"the take mode always shows a ring around
/// what piece you're editing — it doesn't follow the preference on cursor
/// being enough, wanting background wash, or ring"*; U-19 (5) confirms the
/// preference governs EVERY live pane).
///
/// **R22's reason for the ring is preserved, not overruled** — among many
/// editable surfaces the ring is how you find the one live editor, and it
/// remains the shipped look under `.outline`, which is what a pane renders
/// wherever the appearance push cannot reach. What her ruling changes is
/// that the pane no longer OVERRIDES her stated preference: the three
/// styles the Write surface has honoured since R14/R22 now mean the same
/// thing on every pane.
///
/// The three styles are the Write editor's own, read from `BlockDecor`'s
/// `renderIndicator` so the two surfaces can never drift:
/// - `.off` — the caret is enough: the live pane wears the same hairline it
///   wears at rest.
/// - `.outline` — today's ring (`tokens.ring`, 1.5 pt).
/// - `.background` — a wash fill inside the pane's own frame
///   (`tokens.wash`), the hairline at rest, no ring. Write fills the caret
///   block the same way, in the same token.
///
/// It is a PURE function of (live, style, tokens) so a pin asserts the
/// decision without measuring pixels, and so the three hosts that draw
/// their own frame around a live pane (`ReadEditPane`, `BookIndexView`,
/// `BlocksWorkbenchView`) can CONSUME it instead of keeping a second rule.
nonisolated struct PaneDecoration: Equatable {
    /// The frame stroke's colour (`.clear` where the composition supplies
    /// the paper and nothing is drawn at rest).
    var stroke: Color
    var lineWidth: CGFloat
    /// The wash inside the pane's frame — nil unless the live pane is
    /// wearing `.background`.
    var fill: Color?

    static func resolve(
        isLive: Bool, indicator: EditingIndicatorStyle, tokens: VoiceTokens?
    ) -> PaneDecoration {
        // The AT-REST look, byte-unchanged: voiced compositions draw
        // nothing (the card behind is the paper); the pre-13 call sites
        // (tokens nil — the tutorial samples and the pins) keep their grey
        // hairline.
        let rest = PaneDecoration(
            stroke: tokens == nil ? Color.gray.opacity(0.25) : .clear,
            lineWidth: 0.5, fill: nil)
        guard isLive else { return rest }
        switch indicator {
        case .off:
            return rest
        case .outline:
            return PaneDecoration(
                stroke: tokens?.ring ?? Color.accentColor, lineWidth: 1.5, fill: nil)
        case .background:
            var washed = rest
            // No tokens ⇒ no voice wash to borrow; the accent at low
            // opacity is the same gesture in the pre-13 look.
            washed.fill = tokens?.wash ?? Color.accentColor.opacity(0.12)
            return washed
        }
    }

    /// What a HOST that draws its OWN frame around the live pane should
    /// stroke with — nil means "draw the frame you draw at rest" (the ring
    /// is not this preference's mark). The three hosts that keep a frame of
    /// their own ask this instead of reaching for `tokens.ring`, so U-7 has
    /// exactly one rule in the app.
    static func hostRing(indicator: EditingIndicatorStyle, tokens: VoiceTokens) -> Color? {
        indicator == .outline ? tokens.ring : nil
    }
}

// MARK: - The SwiftUI pane (read + live modes)

/// One pane: a take's cell, a TOC row's body, a tutorial sample — EVERY
/// pane everywhere is an editing surface, but only the ONE focused pane is
/// LIVE (P3: the live editor migrates); everything else is a read-cheap,
/// selectable TK2 surface. Edits land in exactly this pane's variant.
/// The canary is RENDERED (N2): a TK1 fallback shows a banner right here,
/// in whatever composition the pane sits.
struct PaneSurfaceView: View {
    let text: String
    let isLive: Bool
    /// nil = the pre-13 look (BlockTOC/tutorial call sites); set =
    /// voice-token styling — a TRANSPARENT surface (the wrapping card or
    /// article provides the paper), ink from the voice, the LIVE ring in
    /// tokens.ring (R22: among many editable surfaces, the ring is how you
    /// find the one live editor).
    var tokens: VoiceTokens? = nil
    /// 17o batch c (her U-7 · U-19 (5)): which of the three editing
    /// indicators this pane wears when it is the live one. PUSHED like the
    /// tokens beside it — the appearance road `EditorAppearance` already
    /// takes into the Write surface (a View reads the store; a component
    /// never pulls a setting of its own). `.outline` is the shipped ring,
    /// so a call site the push has not reached — the pins, the tutorial
    /// samples — looks exactly as it did.
    var indicator: EditingIndicatorStyle = .outline
    /// Surface identity for tests/soaks: the pane's role in its
    /// composition ("article", "card", "mini", …) and the variant it
    /// mirrors — carried on the NSView identifier, rendered nowhere.
    var role: String = "pane"
    var variantID: String? = nil
    /// A plain click on a read pane — the container migrates the live
    /// editor here.
    var onFocusRequest: (() -> Void)?
    /// The sanity pass's RAISE-1: the plain click's PLACE (UTF-16), delivered
    /// AFTER `onFocusRequest` has moved the ring — the click's own selection
    /// change arrives while the ring is still on the old pane and the
    /// composition's live-pane guard rightly drops it, and R1-2's flag
    /// (rightly) moves nothing on the transition, so without this the first
    /// click into a pane was kept in the pane and never reported. Only the
    /// hosts that report a caret pass it.
    var onClickPlace: ((Int) -> Void)?
    /// A live pane's edit: the full new text (the model computes cost and
    /// routes autosave).
    var onEdit: ((String) -> Void)?
    /// 13e E3 (her A18): a ⌘-click this pane's composition claims — return
    /// true to consume it (see `PaneTextView.onCommandClick`). nil
    /// everywhere but the Takes board's article cells.
    var onCommandClick: ((Bool) -> Bool)?
    /// 13b 1b: the live pane's selection, reported as it changes — the
    /// fire-and-DO choreography carries it into Write.
    var onSelectionChange: ((NSRange) -> Void)?
    /// 17o batch b (her ruling U-20): where the caret goes when this pane
    /// TAKES THE RING — the note's remembered place inside that block, so a
    /// mode switch keeps her where she was instead of dropping her at the
    /// take's first character (and so the report the pane makes on going live
    /// is that same place, never the end of the text AppKit left the
    /// selection at). **The ladder's R1-2/R1-3:** it governs a PROGRAMMATIC
    /// transition only — a click keeps the place the click brought — and
    /// nil means the take's START (Write's nil rule; the END AppKit left was
    /// an artifact the pane then reported as her place — QUESTIONS #97).
    /// `Int.max` asks for the END explicitly (the room's gesture).
    /// **RAISE-2:** an explicit `PaneCaretLanding`, defaulting to `.leave`, so
    /// a host that passes nothing keeps the shipped END.
    var caretOnGoingLive: PaneCaretLanding = .leave
    /// 13b 1b (AD-4): the pane's Variorum context-menu items.
    var menuItems: (() -> [PaneTextView.MenuItemSpec])?
    /// QoL batch 2 (L3/L4 — the RULED measurement seam): the pane's
    /// MEASURED content height, for a composer that must size a wrapper
    /// around it. A second consumer of the ONE publish door (P-3), never a
    /// second measurement brain — and deliberately the MEASURED height,
    /// not a rendered one: a geometry sink reports what the composition
    /// already imposed, which is circular for "how tall does this want to
    /// be" the moment a cap exists. Delivered on a deferred turn (see
    /// `Coordinator.deliverMeasuredHeight`), so a composer's model write
    /// can never land inside a SwiftUI update.
    ///
    /// Only the two compositions that SIZE a wrapper subscribe (margin
    /// grid always; slot split for its drag clamp) — everywhere else this
    /// is nil and nothing changes, carousel's invalidation profile
    /// included.
    var onMeasuredHeight: ((CGFloat) -> Void)?
    /// **13f W7 — the takes room's landing.** A monotonic token: when it
    /// CHANGES while this pane is mounted, the pane puts its caret at the END
    /// of its text. Zero (the default) is "nobody is asking", and a pane
    /// adopts whatever the token is at construction as its baseline, so a
    /// remount never re-places a caret on its own.
    ///
    /// It is NOT a liveness mechanism and cannot become one (P-3): the
    /// authority alone decides which pane is live, this only says where the
    /// caret sits inside a pane that liveness already reached. Nothing but
    /// the takes board's room click sets it.
    var caretToEndToken: Int = 0
    @State private var height: CGFloat = 24
    @State private var canaryMessage: String?
    /// 13d batch 4 (A23/A24): the two this-Mac editor-behaviour settings.
    /// Held HERE so a change in the Settings window invalidates every
    /// mounted pane immediately (a bare `UserDefaults` read at update time
    /// would only land on the next unrelated redraw).
    @AppStorage(SpellcheckLevel.settingKey) private var spellcheck = SpellcheckLevel.off
    @AppStorage(ParagraphGap.settingKey) private var paragraphGap = ParagraphGap.standard

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let canaryMessage {
                // N2: the fallback SPEAKS wherever a pane renders — the
                // memo posture's visible in-app diagnostic, previously
                // swallowed by a variable nothing read.
                Text(canaryMessage)
                    .foregroundStyle(.white)
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .textSelection(.enabled)
            }
            PaneSurfaceRepresentable(
                text: text, isLive: isLive, height: $height, canaryMessage: $canaryMessage,
                ink: tokens.map { NSColor($0.ink) },
                role: role, variantID: variantID,
                spellcheck: spellcheck, paragraphGap: paragraphGap,
                onFocusRequest: onFocusRequest, onClickPlace: onClickPlace, onEdit: onEdit,
                onCommandClick: onCommandClick,
                onSelectionChange: onSelectionChange,
                caretOnGoingLive: caretOnGoingLive, menuItems: menuItems,
                onMeasuredHeight: onMeasuredHeight,
                caretToEndToken: caretToEndToken)
                // EXACT height, not a floor (13b 3F, AD-7): an
                // NSViewRepresentable ACCEPTS a tall proposal, so in any
                // composition whose row is taller than the text (the margin
                // grid's reserved rail) a `minHeight` pane STRETCHED to the
                // row and the wash rendered as a mostly-empty slab. The
                // pane is always its measured content height; the width
                // hook + publishes keep it converged (the batch-12 pin).
                .frame(height: height)
                // 17o batch c (row 6): the wash goes INSIDE the pane's own
                // frame — the same shape the stroke uses, so the two can
                // never disagree, and the composition's padding stays the
                // card's, not the indicator's.
                .background(
                    decoration.fill.map { fill in
                        RoundedRectangle(cornerRadius: cornerRadius).fill(fill)
                    })
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(decoration.stroke, lineWidth: decoration.lineWidth))
        }
    }

    private var cornerRadius: CGFloat { tokens == nil ? 3 : 6 }

    /// The ONE decision (row 6). Views render it; nothing re-derives it.
    private var decoration: PaneDecoration {
        .resolve(isLive: isLive, indicator: indicator, tokens: tokens)
    }
}

private struct PaneSurfaceRepresentable: NSViewRepresentable {
    let text: String
    let isLive: Bool
    @Binding var height: CGFloat
    @Binding var canaryMessage: String?
    /// Voice styling: non-nil ⇒ transparent background (the card/article
    /// behind provides the paper) + this ink.
    var ink: NSColor?
    var role: String
    var variantID: String?
    /// 13d batch 4 (A23/A24) — carried as values (not read from defaults
    /// inside the representable) so SwiftUI knows an update is due.
    var spellcheck: SpellcheckLevel = .off
    var paragraphGap: ParagraphGap = .standard
    var onFocusRequest: (() -> Void)?
    var onClickPlace: ((Int) -> Void)?
    var onEdit: ((String) -> Void)?
    var onCommandClick: ((Bool) -> Bool)?
    var onSelectionChange: ((NSRange) -> Void)?
    /// The landing place a pane adopts on going live (17o batch b; RAISE-2:
    /// `.leave` when the host passes nothing).
    var caretOnGoingLive: PaneCaretLanding = .leave
    var menuItems: (() -> [PaneTextView.MenuItemSpec])?
    var onMeasuredHeight: ((CGFloat) -> Void)?
    var caretToEndToken: Int = 0

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> PaneTextView {
        let view = PaneTextView.makeTakeSurface()
        view.delegate = context.coordinator
        context.coordinator.onMeasuredHeight = onMeasuredHeight
        context.coordinator.install(
            view: view,
            publishHeight: { [weak coordinator = context.coordinator] measured in
                let resolved = max(measured, 24)
                height = resolved
                // QoL batch 2: the composer's copy leaves on a DEFERRED
                // turn — this closure runs inside SwiftUI updates (the
                // width-gated layout hook, updateNSView's adopt-remeasure),
                // which is exactly the mid-update hazard `PanePublisher`
                // exists for. A composer writing an @Observable model here
                // would re-open it one layer out.
                coordinator?.deliverMeasuredHeight(resolved)
            },
            publishCanary: { canaryMessage = $0 })
        context.coordinator.onEdit = onEdit
        view.onPlainClick = { [weak coordinator = context.coordinator] offset in
            coordinator?.onFocusRequest?()
            // RAISE-1: the place is reported AFTER the ring has moved.
            coordinator?.onClickPlace?(offset)
        }
        // 13e E3: the claim goes through the COORDINATOR like every other
        // callback, so `updateNSView` keeps it current instead of capturing
        // a stale closure from the first render.
        view.onCommandClick = { [weak coordinator = context.coordinator] extending in
            coordinator?.onCommandClick?(extending) ?? false
        }
        context.coordinator.onCommandClick = onCommandClick
        context.coordinator.onFocusRequest = onFocusRequest
        context.coordinator.onClickPlace = onClickPlace
        context.coordinator.onSelectionChange = onSelectionChange
        context.coordinator.caretOnGoingLive = caretOnGoingLive
        view.variorumMenu = menuItems
        applyStyle(to: view)
        applyIdentity(to: view)
        spellcheck.apply(to: view)  // A24
        view.string = text
        // 13g batch 2 (L7): a pane wears the same dimmed-marker face as the
        // editors (F-2/F-5). Whole-pane is P1-clean here for the reason this
        // file already states about layout: a pane's "document" is ONE take
        // or one post-read by construction.
        if let storage = view.textStorage { MarkdownStyling.style(storage) }
        view.isEditable = isLive
        context.coordinator.noteLiveness(isLive)
        // 13f W7: adopt the CURRENT token as the baseline — a pane born while
        // a request is outstanding must not act on it (a remount is not a
        // click).
        context.coordinator.adoptCaretToEndBaseline(caretToEndToken)
        context.coordinator.remeasure()
        return view
    }

    func updateNSView(_ view: PaneTextView, context: Context) {
        context.coordinator.onEdit = onEdit
        context.coordinator.onCommandClick = onCommandClick
        context.coordinator.onFocusRequest = onFocusRequest
        context.coordinator.onClickPlace = onClickPlace
        context.coordinator.onSelectionChange = onSelectionChange
        context.coordinator.onMeasuredHeight = onMeasuredHeight
        context.coordinator.caretOnGoingLive = caretOnGoingLive
        view.variorumMenu = menuItems
        view.isEditable = isLive
        context.coordinator.noteLiveness(isLive)
        applyStyle(to: view)
        applyIdentity(to: view)
        spellcheck.apply(to: view)  // A24 — write-gated, so a same-level
                                    // update writes nothing at all
        // A voice switch changes the ONE global typography (C1's
        // EditorTypography); live-adopt it so open panes re-font without
        // reconstruction (an ordinary storage write, never §3 attributes).
        // 13d batch 4 (A23): a paragraph-GAP change moves no font, so the
        // font test alone could never notice it — the style test is the
        // second half of the same "our base attributes moved" question, and
        // the re-attribution below is exactly what a gap change needs.
        if view.font != EditorDocument.baseFont
            || view.defaultParagraphStyle?.paragraphSpacing
                != EditorDocument.baseParagraphStyle.paragraphSpacing {
            view.font = EditorDocument.baseFont
            view.defaultParagraphStyle = EditorDocument.baseParagraphStyle
            view.typingAttributes = EditorDocument.baseAttributes
            if let storage = view.textStorage, storage.length > 0 {
                storage.beginEditing()
                storage.addAttributes(
                    EditorDocument.baseAttributes,
                    range: NSRange(location: 0, length: storage.length))
                // 13g batch 2 (L7): the base refresh flattens the markdown
                // face; re-derive it in the same transaction, in the new voice.
                MarkdownStyling.style(storage)
                storage.endEditing()
            }
            context.coordinator.remeasure()
            // 13d batch 5 (the long-content-panes memo §6 item 5 — her
            // "Accept all"): THIS branch is the memo's edge 3, the
            // full-range invalidation class that has no user event behind
            // it. The `addAttributes` above is exactly the write A47c
            // traced as destroying a tail-scrolled pane's rendering
            // surfaces — and a voice or gap switch can land while she sits
            // idle on a scrolled card, where the occasion heals (click,
            // scroll-end, ring move) cannot reach it. Re-assert the render
            // tier on the same deferred turn the occasions use.
            context.coordinator.restoreRenderTier()
        }
        // The buffer is authoritative while live: a projection may lag the
        // keystroke; never clobber the surface under the caret. Read panes
        // adopt any change. (The view-level half of PaneTextAuthority's
        // isLive contract.)
        if !isLive, view.string != text {
            view.string = text
            // 13g batch 2 (L7): a fresh string carries only typing
            // attributes — the face is re-derived over the adopted text.
            if let storage = view.textStorage { MarkdownStyling.style(storage) }
            context.coordinator.remeasure()
        }
        // 13f W7: last, so the text above is settled before the caret is
        // placed against it.
        context.coordinator.applyCaretToEndIfRequested(caretToEndToken, in: view)
    }

    private func applyStyle(to view: PaneTextView) {
        if let ink {
            // 13c A47c: CHANGE-GATED. The unguarded `textColor` write was
            // the draw gap's production trigger — a full-range storage
            // attribute write on every SwiftUI update, which on a
            // tail-scrolled long pane destroys the rendering surfaces
            // above the tail (laid-out-but-undrawn; the 1G deception's
            // root). Same ink ⇒ no write of any kind.
            guard view.appliedInk != ink else { return }
            view.appliedInk = ink
            view.drawsBackground = false
            view.textColor = ink
            view.insertionPointColor = ink
            // 13g batch 2 (L7): `textColor` flattens every foreground the
            // markdown face applied — re-derive it against the NEW ink. Rides
            // the same change gate, so this is as rare as the write it
            // repairs, and text without markdown still writes nothing.
            if let storage = view.textStorage { MarkdownStyling.style(storage) }
        } else {
            view.appliedInk = nil
            view.drawsBackground = true
        }
    }

    private func applyIdentity(to view: PaneTextView) {
        view.identifier = NSUserInterfaceItemIdentifier(
            "pane:\(role)|\(variantID ?? "-")")
    }

    static func dismantleNSView(_ view: PaneTextView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var onEdit: ((String) -> Void)?
        var onFocusRequest: (() -> Void)?
        /// RAISE-1: the plain click's place, after the ring has moved.
        var onClickPlace: ((Int) -> Void)?
        /// 13e E3: the composition's ⌘-click claim (her A18's selection).
        var onCommandClick: ((Bool) -> Bool)?
        var onSelectionChange: ((NSRange) -> Void)?
        /// 17o batch b: the place this pane's caret takes when it goes live
        /// (`.leave` = the selection stays where it is). Refreshed on every
        /// render so the transition below acts on the current memory.
        var caretOnGoingLive: PaneCaretLanding = .leave
        /// QoL batch 2 (L3/L4): the composer's measured-height sink.
        var onMeasuredHeight: ((CGFloat) -> Void)?
        private weak var view: PaneTextView?
        /// The ONE publish door (round-3 MINOR-D/E/F). Nothing in this
        /// coordinator writes SwiftUI state except through it.
        private var publisher: PanePublisher?
        private let canary = FallbackCanary()
        private var wasLive = false

        /// 13b 1b (N9's keyboard half): a pane TRANSITIONING to live holds
        /// the keyboard — programmatic ring moves (the Takes landing, the
        /// add-block door, ⌃⌘←/→ steps) must make "just start typing"
        /// literal. A click-focused pane is already first responder (the
        /// claim is a no-op); read transitions never claim.
        func noteLiveness(_ live: Bool) {
            let was = wasLive
            defer { wasLive = live }
            // 13c 1G: a liveness TRANSITION (either direction) is a
            // convergence occasion — "clicking into other blocks" moves the
            // ring, and the stale card's live→read flip is the one event it
            // reliably receives. Transition-gated so ordinary read→read
            // updates cost nothing.
            if live != was { view?.fireConvergenceOccasion() }
            guard live, !was, let view else {
                // 17o batch b's ladder, R1-2: a click's flag is spent by a
                // live render (the pane already held the ring — nothing to
                // land) or by a live→read transition (the gesture is over);
                // a read→read render KEEPS it for the flip it asked for.
                if live || live != was { view?.clickBroughtPlace = false }
                return
            }
            let clickBroughtPlace = view.clickBroughtPlace
            view.clickBroughtPlace = false
            // 17o batch b (U-20): the ring arrives WHERE SHE WAS. Placed
            // before the responder claim, so the claim's own selection
            // notification reports this place — the note's one caret — rather
            // than the end of the text the read pane's `string` set left it
            // at (measured: a take pane going live reported its block's END,
            // which then became the note's remembered offset and landed Write
            // at the end of the paragraph she was standing in the middle of).
            //
            // The ladder's R1-2/R1-3 (round 1): this is the rule for a
            // PROGRAMMATIC transition only — the N9 and bloom landings, Read's
            // edit face, the room. A CLICK placed the caret itself and keeps
            // it (a click into another take of the current block was being
            // landed at the first take's offset). And with nothing
            // remembered the pane lands at the take's START — Write's own
            // nil rule (Act 10 rows 39/49), not the END AppKit's `string =`
            // left behind: that END was an artifact, and the live pane then
            // REPORTED it as "where she was", so Blocks' row → Takes → Write
            // landed at the end of the paragraph. QUESTIONS #97 carries the
            // START/END edge (START built, PROVISIONAL).
            //
            // The sanity pass's RAISE-2: the landing is an explicit
            // `PaneCaretLanding`, and `.leave` — the default for every host
            // that passes nothing, and what the models hand a pane whose
            // landing is not the note's own entry (the post-structural ring
            // landings) — moves nothing: the shipped END stays there.
            if !clickBroughtPlace {
                let length = (view.string as NSString).length
                switch caretOnGoingLive {
                case .leave:
                    break
                case .start:
                    view.setSelectedRange(NSRange(location: 0, length: 0))
                case .end:
                    view.setSelectedRange(NSRange(location: length, length: 0))
                case .offset(let landing):
                    view.setSelectedRange(
                        NSRange(location: min(max(0, landing), length), length: 0))
                }
            }
            if let window = view.window {
                window.makeFirstResponder(view)
            } else {
                view.claimsKeyboardOnAttach = true
            }
        }

        /// 13f W7: the last caret-to-end token this pane acted on.
        private var lastCaretToEndToken = 0

        func adoptCaretToEndBaseline(_ token: Int) {
            lastCaretToEndToken = token
        }

        /// Put the caret at the end of the pane's text when the composer's
        /// token moves. Live panes only — a read pane's selection is not a
        /// caret, and asking one to hold a caret would be the second liveness
        /// mechanism P-3 forbids.
        func applyCaretToEndIfRequested(_ token: Int, in view: PaneTextView) {
            guard token != lastCaretToEndToken else { return }
            lastCaretToEndToken = token
            guard token > 0, view.isEditable else { return }
            let end = (view.string as NSString).length
            view.setSelectedRange(NSRange(location: end, length: 0))
            view.scrollRangeToVisible(NSRange(location: end, length: 0))
        }

        func install(
            view: PaneTextView,
            publishHeight: @escaping (CGFloat) -> Void,
            publishCanary: @escaping (String) -> Void
        ) {
            self.view = view
            publisher = PanePublisher(
                measure: { [weak view] in
                    guard let view else { return nil }
                    return max(PaneMeasurement.height(of: view), 24)
                },
                renderedHeight: { [weak view] in view?.bounds.height },
                // 13c 1G (A47b): the frame lever — a chase turn that still
                // renders divergent pulls the AppKit frame itself, because
                // an equal-value state write cannot (see PanePublisher; the
                // F1 walk keeps SwiftUI's property wrappers out of this
                // coordinator, comments included).
                applyFrame: { [weak view] height in
                    guard let view, view.frame.height != height else { return }
                    view.setFrameSize(NSSize(width: view.frame.width, height: height))
                },
                writeHeight: publishHeight,
                // N2: the canary message is PUBLISHED into the rendered
                // banner (it used to land in a private var nothing read).
                writeCanary: { [weak view] message in
                    view?.notePublishedCanary(message)
                    publishCanary(message)
                })
            // Batch 12 (her clipped-take report): the pane measures once at
            // install, BEFORE SwiftUI hands it real width — the width-gated
            // layout hook re-measures when real layout arrives.
            view.onWidthChange = { [weak self] in self?.remeasure() }
            // 13c 1F (A47): same-width layout passes re-check convergence,
            // so a stale frame — in EITHER direction — self-heals on the
            // next pass instead of persisting until a width/text/font event.
            // Geometry only: a layout pass can be CAUSED by the render
            // restore below, so it must never schedule one (termination).
            view.onLayoutPass = { [weak self] in
                self?.reconvergeIfDiverged(restoreRender: false)
            }
            // 13c 1G (A47b): the PRODUCTION occasions — scroll-end, clicks,
            // and liveness transitions run the same check, because the 1G
            // census proved those events deliver NO layout passes at all
            // (the 1F branch alone was production-inert for an idle card).
            // 13c A47c: occasions ALSO restore the render tier — they are
            // discrete user events a viewport layout can never cause, so
            // the restore cannot loop by construction.
            view.onConvergenceOccasion = { [weak self] in
                self?.reconvergeIfDiverged(restoreRender: true)
            }
            canary.onFire = { [weak self] message in
                self?.publisher?.publishCanary(message)
            }
            canary.arm(for: view)
        }

        func uninstall() {
            canary.disarm()
            publisher?.invalidate()
            publisher = nil
            view = nil
            onMeasuredHeight = nil
            pendingMeasuredHeight = nil
        }

        // MARK: - The measured-height sink (QoL batch 2 — L3/L4)

        /// The last height handed to the composer, so a re-publish of the
        /// same measurement costs nothing at all (the publisher re-writes
        /// its height on every convergence turn; an @Observable model on
        /// the other end would re-render the board for each one).
        private var deliveredMeasuredHeight: CGFloat?
        private var pendingMeasuredHeight: CGFloat?

        /// Hand the composer this pane's measured content height on the
        /// NEXT main-queue turn. Deferred for the same reason
        /// `scheduleRenderRestore` is (and on the same latch): the publish
        /// this rides can fire inside a SwiftUI update, and a composer's
        /// model write there is the dropped/undefined-write class.
        /// Coalesced — a burst of publishes delivers once, with the last
        /// value — and equality-gated, so a converged pane goes silent.
        ///
        /// Termination: a height delivery can change only the composer's
        /// WRAPPER height. The pane's measurement is width-driven and its
        /// width is fixed by the card, so a delivery can never change the
        /// next measurement — the sequence reaches a fixed point and stops.
        func deliverMeasuredHeight(_ height: CGFloat) {
            guard onMeasuredHeight != nil else { return }
            if let delivered = deliveredMeasuredHeight, abs(delivered - height) <= 0.5 {
                return
            }
            let hadPending = pendingMeasuredHeight != nil
            pendingMeasuredHeight = height
            guard !hadPending else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self, let pending = self.pendingMeasuredHeight else { return }
                self.pendingMeasuredHeight = nil
                guard let sink = self.onMeasuredHeight else { return }
                if let delivered = self.deliveredMeasuredHeight, abs(delivered - pending) <= 0.5 {
                    return
                }
                self.deliveredMeasuredHeight = pending
                sink(pending)
            }
        }

        /// 13g batch 2 (L7): records where a live pane's keystroke will land
        /// so the markdown face can rescan the LINES it touched rather than
        /// the whole pane — the same P1 discipline the full-document editor
        /// keeps, on the surface kind that has no storage delegate of its own.
        /// It observes and never gates: the verdict is always the default.
        private var pendingEditRange: NSRange?

        func textView(
            _ textView: NSTextView,
            shouldChangeTextIn affectedCharRange: NSRange,
            replacementString: String?
        ) -> Bool {
            pendingEditRange = NSRange(
                location: affectedCharRange.location,
                length: (replacementString as NSString?)?.length ?? 0)
            return true
        }

        func textDidChange(_ notification: Notification) {
            guard let view else { return }
            if let storage = view.textStorage {
                // No recorded range (an edit that reached the storage by some
                // other path) falls back to the caret's own lines — still
                // scoped, never the pane.
                MarkdownStyling.restyle(
                    storage, range: pendingEditRange ?? view.selectedRange())
            }
            pendingEditRange = nil
            onEdit?(view.string)
            remeasure()
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let view else { return }
            onSelectionChange?(view.selectedRange())
        }

        /// Measure and publish, through the ONE door. The Stage 4 gate's
        /// clipped-pane failure (the batch-12/AD-7 class, one
        /// publish-timing hole over) is closed inside `PanePublisher`:
        /// synchronous write + a bounded, coalesced convergence heal. No
        /// loop — a height write triggers no remeasure (`updateNSView`
        /// remeasures only on string/font change; the layout hook is
        /// width-gated, and the same-width divergence check below
        /// publishes only when the frame and the measurement disagree).
        func remeasure() {
            publisher?.publishHeight()
        }

        /// 13c 1F (A47, the take-card gap): the BOTH-SIDES convergence
        /// law. A pane's frame is written only from exact measurements,
        /// but a measurement taken in a transient layout state can outlive
        /// the state it measured — and with every remeasure trigger gated
        /// on a width/string/font CHANGE, and the publisher's heal
        /// re-scheduling only while the frame renders SHORT, an over-tall
        /// frame had NO correction path at all (a ~450pt dead void at the
        /// end of a take card, stable across ring moves, scrolls, and
        /// clicks — her A47 report). Runs on every same-width layout
        /// pass: one warm measurement of already-laid-out pane-scale text;
        /// publishes ONLY on divergence, so a converged pane writes
        /// nothing and the pass chain terminates (a corrective publish
        /// reframes the view to the measurement; the next pass measures
        /// equal and stays silent). Composer-capped compositions never
        /// fire it: the capped wrapper is a ScrollView AROUND the pane
        /// (the rail's tall cards), so the pane's own bounds still equal
        /// its measurement inside.
        ///
        /// 13c 1G (A47b): also fired by the user-event OCCASIONS (scroll
        /// end, click, liveness transition) — production delivers no
        /// layout passes to an idle card, so `layout()` alone never ran
        /// this in the shipped app; and the corrective publish now rides
        /// the publisher's frame lever, so a divergence the state cannot
        /// move (the equal-value no-op) still heals.
        ///
        /// 13c A47c (the DRAW GAP — the check's RENDER half): geometry was
        /// only half of what an occasion must re-assert. TK2 draws a pane
        /// through per-fragment RENDERING SURFACES created by viewport
        /// layout — and the A47c trace proved a full-range storage
        /// attribute write on a tail-scrolled long pane DESTROYS the
        /// surfaces above the tail and nothing rebuilds them: the
        /// viewportBounds stay correct, `needsDisplay` is powerless (the
        /// surfaces are the unit of drawing, not the backing store), and
        /// idle delivers nothing — text that is laid out, measured exact,
        /// and selectable renders BLANK except its last lines, permanently
        /// (her four screenshots; 1G's deletion deception was this same
        /// state's first appearance). `layoutViewport()` rebuilds the
        /// surfaces for the ACTUAL viewport completely — measured
        /// empirically (surfaces 6 → 14, full ink, one call). So a
        /// convergence OCCASION now also restores the render tier, on a
        /// DEFERRED turn: inside updateNSView the liveness occasion fires
        /// BEFORE the style write that kills (the order in updateNSView),
        /// so a synchronous restore would lose the race; the next
        /// main-queue turn runs after the whole update. Occasion-gated for
        /// termination: occasions are discrete user events (click,
        /// scroll-end, ring move) that a viewport layout can never cause;
        /// layout passes deliberately keep restoreRender false because a
        /// viewport layout CAN queue a layout pass. Cost: one coalesced
        /// viewport-bounded pass per occasion burst — the region on
        /// screen, warm (P1's letter), zero at rest.
        func reconvergeIfDiverged(restoreRender: Bool) {
            guard let view, publisher != nil else { return }
            view.noteConvergenceCheck()
            let measured = max(PaneMeasurement.height(of: view), 24)
            if abs(view.bounds.height - measured) > PanePublisher.convergenceSlack {
                remeasure()
            }
            if restoreRender { scheduleRenderRestore() }
        }

        /// The render half alone, for a full-range invalidation that is NOT
        /// a user occasion (13d batch 5: the font/gap re-attribution — the
        /// memo's edge 3). Geometry is already handled there by the
        /// remeasure beside it, so this asks only for the drawing.
        /// Coalesced by the same latch, so a burst of updates is one pass.
        func restoreRenderTier() {
            guard view != nil, publisher != nil else { return }
            scheduleRenderRestore()
        }

        private var renderRestoreScheduled = false

        private func scheduleRenderRestore() {
            guard !renderRestoreScheduled else { return }
            renderRestoreScheduled = true
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.renderRestoreScheduled = false
                guard let view = self.view, self.publisher != nil,
                      view.window != nil else { return }
                view.textLayoutManager?.textViewportLayoutController.layoutViewport()
                view.noteRenderRestore()
            }
        }
    }
}
