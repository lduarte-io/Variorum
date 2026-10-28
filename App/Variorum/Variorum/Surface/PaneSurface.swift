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
    /// **Cost, and the true CALL-SITE SET** (17o c/d/e round 1, MINOR-1 —
    /// the first version of this paragraph justified the walk with "a
    /// pane's document is ONE take by construction", which is false for
    /// half the brain's callers and told the next reader the wrong thing).
    /// `PaneMeasurement.height` has FOUR production call sites, named by
    /// the FUNCTION each sits in and never by line (round 2's NIT-1: the
    /// first version of this list quoted line numbers that its own added
    /// lines had already pushed down by 25 — a doc that re-types a number
    /// instead of naming the thing goes stale by being written):
    /// - two are PANES, both in this file's `Coordinator` — the
    ///   `PanePublisher`'s `measure` closure built in `install(view:
    ///   publishHeight:publishCanary:)`, and `reconvergeIfDiverged(
    ///   restoreRender:)`'s own read — where the document really is one
    ///   take and the P1 bound is the unit on screen;
    /// - two are WHOLE-POST surfaces — `ReadPostViewModel.remeasure` (the
    ///   read tier, one post) and `InlineEditorSurface.remeasure` in
    ///   `Features/Editor/EditorView.swift` (the book view's inline
    ///   editor), and the second runs **once per keystroke** (it is wired
    ///   to `NSTextStorage.didProcessEditing`).
    ///
    /// That per-keystroke site is why the walk's cost was MEASURED at
    /// post scale rather than argued (the numbers are in the round-1 fix
    /// record). Against the road this replaced — `ensureLayout(for:
    /// documentRange)` then one property read — timed INTERLEAVED so
    /// neither benefits from running first, on a bare TK2 view at 640 pt:
    /// **200 blocks / 42k chars → 0.191 ms old vs 0.186 ms new per edit;
    /// 800 blocks / 169k chars → 0.591 ms vs 0.574 ms.** The `ensureLayout`
    /// revalidation dominates at both scales and the added frame reads do
    /// not surface above noise, so the walk costs these two sites nothing
    /// measurable. Neither site is a NEW P1 class either: the old body
    /// already laid out the whole document there.
    ///
    /// What 13u2 inherits (its pane-stability item, whose trace this batch
    /// deliberately did not extend to the other surface kind): these two
    /// whole-post sites by name, and the fact that their per-edit cost is
    /// `ensureLayout` over the post — not this walk.
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

final class PaneTextView: NSTextView, MarkdownFormattable, ProseGutterSurface {
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

    /// **13u2 item 11 — ⇧⌘V here too**, for the reason the arrow trio is
    /// here: a live take/lens pane is a writing surface, and a chord she can
    /// use in Write and not in Takes is exactly the privilege R118 forbids.
    /// The RULE is `PlainPaste.flattened` in `Shared/` — the same one the
    /// full editor and, when its face lands, the phone consume. A pane has
    /// no open tail, so there is no bulk flag to raise: the flattened text
    /// is ordinary content here.
    @objc func pasteWithoutNewlines(_ sender: Any?) {
        guard isEditable, let raw = NSPasteboard.general.string(forType: .string) else { return }
        let flattened = PlainPaste.flattened(raw)
        guard !flattened.isEmpty else { return }
        insertText(flattened, replacementRange: selectedRange())
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

    /// **18g ladder round 1, the sanity pass's raise: the last markdown
    /// FACE this pane was styled with** — the palette-dependent half of the
    /// storage (a link's `.foregroundColor` is `tokens.accent`, the
    /// PALETTE's). The two gates above and below — the ink, the base
    /// attributes — are what a VOICE switch moves, and before 18g nothing
    /// could change the link's colour without moving the ink; a PALETTE
    /// click moves the accent alone, so a mounted pane kept the old link
    /// colour until it re-materialized. Change-gated exactly like the ink:
    /// the same face writes nothing.
    var appliedFace: MarkdownStyling.Palette?

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
    /// **18l-b U3 (the TK2 §3 rider):** how far the render restore's
    /// `layoutViewport()` moved any CLIP this pane sits inside — the last
    /// restore's, and the largest seen. macOS 27 measured
    /// `layoutViewport()` moving the full-document editor's clip by the
    /// height change its own pass causes (18k C6); this restore is the other
    /// caller, and these two numbers are how a pin — and the next point
    /// release's re-verify (TK2 §5) — ask whether it ever does the same to a
    /// pane.
    private(set) var lastRenderRestoreClipShift: CGFloat = 0
    private(set) var largestRenderRestoreClipShift: CGFloat = 0

    func noteRenderRestore(clipShift: CGFloat) {
        renderRestoresRun += 1
        lastRenderRestoreClipShift = clipShift
        largestRenderRestoreClipShift = max(largestRenderRestoreClipShift, clipShift)
    }

    /// **18l-c U7 — the find paint this pane's storage carries** (observation
    /// seam, the `renderRestoresRun` precedent): what the read tier painted,
    /// and how many times the paint actually WROTE — so a pin can assert both
    /// the shape and that an unchanged face writes nothing.
    private(set) var findPaint: PaneFindFace.Paint?
    private(set) var findPaintWrites = 0

    func noteFindPaint(_ paint: PaneFindFace.Paint?) {
        findPaint = paint
        findPaintWrites += 1
    }

    /// The vertical bounds origin of every clip view this pane sits inside,
    /// innermost first — a pane is never a scroll view's document itself;
    /// it rides inside SwiftUI scroll views (and, on the rail's tall cards,
    /// a capped wrapper inside one).
    func enclosingClipOrigins() -> [CGFloat] {
        var origins: [CGFloat] = []
        var ancestor = superview
        while let view = ancestor {
            if let clip = view as? NSClipView { origins.append(clip.bounds.origin.y) }
            ancestor = view.superview
        }
        return origins
    }

    private weak var observedScrollView: NSScrollView?

    /// **18l-c U7 — the keyboard survives a RE-PARENT.** True while a LIVE
    /// pane that held the keyboard is detached from its window.
    ///
    /// Traced on the find's own road (a step onto a row the landing reveals —
    /// the `TakesFindBoardTests` ⌘G pin, instrumented): the pane is born live,
    /// its attach-claim below takes the keyboard (`become ok`), and then
    /// SwiftUI DETACHES and re-attaches the same view during the reveal's
    /// layout pass (`willMove(toWindow: nil)` while first responder). AppKit
    /// drops a detached first responder to the WINDOW, and the attach-claim is
    /// one-shot — so the take stayed live, selected and on screen with no
    /// keyboard: the ledger-row-7 shape (*"tapping keys won't make you edit"*)
    /// by a second road. A re-parent is not her hand moving the keyboard, so
    /// the pane takes back what it held — and ONLY when nothing else has taken
    /// it meanwhile (the window itself holds it), and only while it is still
    /// the live pane.
    private var heldKeyboardWhenDetached = false

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil, isEditable, let window, window.firstResponder === self {
            heldKeyboardWhenDetached = true
        }
        super.viewWillMove(toWindow: newWindow)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if claimsKeyboardOnAttach, let window {
            claimsKeyboardOnAttach = false
            heldKeyboardWhenDetached = false
            window.makeFirstResponder(self)
        } else if heldKeyboardWhenDetached, let window {
            heldKeyboardWhenDetached = false
            if isEditable, window.firstResponder === window || window.firstResponder == nil {
                window.makeFirstResponder(self)
            }
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
    // MARK: - The prose gutter (13u3 UNIT A1 — her R-13u-9 / item 20)

    /// **THIS SURFACE'S HORIZONTAL PLACEMENT — the SAME rule the editor
    /// holds** (`Surface/ProseGutter.swift`), because the book Outline shows
    /// an expanded-but-unfocused note through THIS surface
    /// (`makeReadSurface`) and the focused one through the editor, and two
    /// copies of the arithmetic would be the drift class.
    ///
    /// Written by the HOST (`ReadPostView`'s `gutter`, handed down through
    /// `PaneSurfaceView`), because only the host knows what whitespace it is
    /// handing the frame. A TAKE pane hosts no decoration controller at all,
    /// so it simply carries its own shipped 6 pt.
    var proseGutter: ProseGutter = .contained {
        didSet {
            guard proseGutter != oldValue else { return }
            applyProseGutter()
        }
    }

    private var placement = ProseGutterPlacement()

    func applyProseGutter() {
        guard let mean = placement.place(gutter: proseGutter, viewWidth: bounds.width)
        else { return }
        if abs(textContainerInset.width - mean) > 0.01 {
            textContainerInset = NSSize(width: mean, height: textContainerInset.height)
        }
    }

    /// Overridden once a real width has been placed (see the editor's twin
    /// for why this is not a TextKit 1 downgrade trigger).
    override var textContainerOrigin: NSPoint {
        guard placement.isPlaced else { return super.textContainerOrigin }
        return NSPoint(x: placement.originX, y: super.textContainerOrigin.y)
    }

    /// The prose column — ONE derivation, and a pure function of the view's
    /// width since 13u3: no decoration can move either edge.
    var proseLeft: CGFloat { textContainerOrigin.x }

    var proseRight: CGFloat {
        placement.isPlaced
            ? placement.proseRight(bounds: bounds.width)
            : bounds.width - textContainerInset.width
    }

    /// Fires when layout gives the view a NEW MEASURE — the prose
    /// CONTAINER's width, not the view's frame (batch 12 — the clipped-take
    /// fix's trigger; width-gated so height publishes can't loop through it).
    ///
    /// **13u3 UNIT A1 — the gate moved from the frame to the container**
    /// (the memo §2 A rider). A gutter-placed surface's frame now spans its
    /// host's whole width while the prose column is capped, so at any window
    /// wider than the column a resize moves the FRAME and not the MEASURE:
    /// gating on the frame would re-measure (a full `ensureLayout` over the
    /// post) on every drag of a window edge for text that cannot have
    /// re-wrapped. What such a resize DOES move is where the prose starts —
    /// that is `onGutterChange` below, which costs no layout.
    var onWidthChange: (() -> Void)?
    /// Fires when the prose column MOVED without changing width — the
    /// gutter grew or shrank around an unchanged measure. Every decoration's
    /// rect is computed from `textLeft`, so they must be re-read; nothing
    /// re-wrapped, so nothing is re-measured.
    var onGutterChange: (() -> Void)?
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
    /// The prose column this view last laid out at — `(leading edge, width)`
    /// in the view's own space. `-1` is "never laid out".
    private var lastLaidOutColumn: (left: CGFloat, width: CGFloat) = (-1, -1)
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
        // 13u3 UNIT A1: the container is placed for THIS width before the
        // pass lays anything out, so the pass never measures against a
        // stale column. Change-gated inside the placement.
        applyProseGutter()
        super.layout()
        let column = (left: proseLeft, width: max(0, proseRight - proseLeft))
        if abs(column.width - lastLaidOutColumn.width) > 0.01 {
            lastLaidOutColumn = column
            widthPassesRun += 1
            onWidthChange?()
        } else if abs(column.left - lastLaidOutColumn.left) > 0.01 {
            // The gutter moved around an unchanged measure: the decorations
            // are stale, the wrapping is not (13u3 UNIT A1).
            lastLaidOutColumn = column
            sameWidthPassesRun += 1
            onGutterChange?()
        } else {
            // Same column: the divergence check (A47). A measure pass already
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
        // VX-429 (her report: a drag from the caret's own place did nothing in
        // Takes): on AppKit's classic road — this override puts every pane on it
        // — a settled caret covers the character after it, and a held press
        // there drags the EMPTY selection instead of selecting. Moved silently
        // off the pressed character first, the press is AppKit's ordinary one
        // (`Surface/CaretPress.swift` carries the measured mechanism).
        CaretPress.clearPressedCharacter(in: self, for: event)
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
        // 13u3 UNIT A1: the shipped symmetric inset, expressed as the one
        // rule — byte-identical for every surface this factory makes, and
        // the host overwrites it where it has whitespace to hand over.
        view.proseGutter = ProseGutter(maxColumn: nil, minGutter: inset, centred: false)
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
        // 13u3 UNIT A1: born `.contained` (the shipped 8 pt each side); the
        // HOST hands it a placement with real gutter room where it has
        // whitespace to give — `ReadPostView`'s `gutter`, per host cell.
        makeSurface(inset: EditorTypography.inlineSurfaceInset, allowsUndo: false)
    }

    /// How far a take pane insets its text from its own frame. **Named
    /// because a second surface has to line up with it** (17p batch a, row 2 —
    /// her R-Q2: the Takes article's ＋ new block door aligns to the PROSE's
    /// left edge, not the cell's), and two copies of a number that must agree
    /// is how a face drifts.
    static let takeSurfaceInset: CGFloat = 6

    /// A take pane's configuration (live/read toggled by the composer).
    /// Undoable — and the history is the PANE's own, never the window's
    /// (VX-421: `PaneSurfaceRepresentable.Coordinator.undoHistory`).
    static func makeTakeSurface() -> PaneTextView {
        makeSurface(inset: takeSurfaceInset, allowsUndo: true)
    }

    /// **WHERE A PANE'S PROSE STARTS, from the pane's own leading edge**
    /// (13u2 UNIT B — her item 19: *"the text indents in index mode where
    /// you're editing it, which should not be happening the second you click
    /// into a block."*).
    ///
    /// A `PaneSurfaceView`'s first glyph does NOT sit at its SwiftUI frame's
    /// edge: the text container is inset by `takeSurfaceInset`, and AppKit's
    /// text container adds its own `lineFragmentPadding` on top. A host that
    /// renders the SAME block two ways — read-cheap `Text` at rest, a live
    /// pane on click — has to pay that difference back in its own padding or
    /// the text visibly jumps sideways the moment the block goes live.
    ///
    /// **MEASURED, never assumed**: both terms are read off a real surface,
    /// so a change to either (an inset tweak, a container configured
    /// differently) moves the hosts that line up with it instead of silently
    /// re-opening the defect. Computed once, on the main actor, from a throwaway
    /// surface — the same construction every pane makes.
    static let proseLeadingInset: CGFloat = takeSurfaceInset + appKitLineFragmentPadding

    /// AppKit's own default padding inside a text container, MEASURED rather
    /// than looked up (`IndexProseColumnTests` constructs a real surface and
    /// fails if this number or the inset above ever stops describing it — a
    /// TEXTKIT2 §5 point-release fact, held where a pin can see it). It is a
    /// plain constant here rather than a probe because these are read inside
    /// SwiftUI bodies, and a body is not where a text view should be built.
    static let appKitLineFragmentPadding: CGFloat = 5

    /// The same fact on the VERTICAL axis — where a pane's first LINE starts
    /// below its own top edge. No fragment padding on this axis; the
    /// container inset alone.
    static let proseTopInset: CGFloat = takeSurfaceInset

    /// **18l-c U5 — the same two facts on the OTHER two edges**, which 13u2 B
    /// did not need and nobody paid back: where a pane's prose ENDS, short of
    /// its own trailing edge, and how far its last line's bottom sits above
    /// its own bottom edge. A take pane's placement is SYMMETRIC (its
    /// `ProseGutter` is `minGutter: takeSurfaceInset` both sides, and AppKit's
    /// fragment padding pads both ends of a line), so these are the leading
    /// and top numbers again — named, so a host that must line up with an
    /// edge reads THAT edge's name, and pinned against a real surface
    /// (`IndexProseColumnTests`).
    static let proseTrailingInset: CGFloat = proseLeadingInset
    static let proseBottomInset: CGFloat = proseTopInset
}

// MARK: - Where a pane's caret lands when it takes the ring

/// **Where a pane's caret goes on a PROGRAMMATIC live transition** (17o
/// batch b's ladder — R1-3 and the sanity pass's RAISE-2). A click always
/// keeps the place the click brought; this is for the transitions no click
/// caused. `.leave` is the DEFAULT and the shipped behaviour: the selection
/// stays where AppKit's `string =` left it — the END — which is what every
/// host that passes nothing (the fan/stack cards, Compare, Canvas, the Write
/// panel; the Book Index's Act 10 row-22 landing too, until 18l-b U4 moved it
/// to `.start` — QUESTIONS #153) and every post-structural
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
    /// **18l-c U7 — a find step's landing: the match, SELECTED** (the design
    /// brief's decision 6 — *"the current match's take goes LIVE with the
    /// match SELECTED"*, find's native semantics). Clamped to the text like
    /// `.offset`. Only the Takes board's find controller asks for it.
    case select(NSRange)

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

// MARK: - The pane's FIND face (18l-c U7 — search in Takes)

/// **What a find running on this pane's HOST asks of the pane** (18l-c U7 —
/// her R-18l-6, *"we should add a search in takes mode"*; the design brief's
/// decisions 6 and 7). ONE parameter, nil for every host but the Takes board,
/// so every other pane is byte-unchanged (pinned — `PaneFindFaceScopeTests`).
/// Three duties, each the smallest the find needs and none a second liveness
/// mechanism (P-3 — the authority alone decides which pane is live):
///
/// 1. **The matches, painted on the READ tier only** — as `.backgroundColor`
///    runs in the read pane's attributed string (TEXTKIT2_NOTES §3's own
///    guidance: highlight on the read-only tier, never through rendering
///    attributes on a live editor). A LIVE pane is never painted: the
///    selection IS its current-match affordance, and the live editor stays
///    clean (decision 7). Change-gated and range-scoped, never a full-range
///    write (the A47c class), with the occasion restore as the belt.
/// 2. **A step's REQUEST to a pane that is ALREADY live** — select the match
///    (and take the keyboard when asked): the next match in the take the ring
///    is already in has no liveness transition to ride. A monotonic token, and
///    a pane adopts the token it is born with as its baseline (a remount is
///    not a step — the room token's `caretToEndToken` precedent). A pane
///    that goes live FOR the step is landed by `PaneCaretLanding.select`.
/// 3. **The find field holds the keyboard** — a pane going live on a step
///    driven FROM the field must not take the keyboard from it, or the next
///    ⏎ would type a newline into her take instead of stepping (the Write
///    bar's own convention: ⏎ in the find field selects in the text and keeps
///    the field; Esc hands the keyboard back — decision 1).
nonisolated struct PaneFindFace: Equatable {
    /// The matches in this pane's text, UTF-16.
    var matches: [NSRange] = []
    /// The current match, when it is in this pane — the stronger emphasis
    /// (visible on the read tier: a sealed note, or the ring moved away).
    var current: NSRange? = nil
    var matchTint: NSColor = .clear
    var currentTint: NSColor = .clear
    var request: Request? = nil
    var fieldHoldsKeyboard = false

    struct Request: Equatable {
        /// Monotonic per host; a change is "asked again".
        var token: Int
        /// The match to select (nil: keep the selection — Esc's hand-back).
        var select: NSRange?
        var claimsKeyboard: Bool
    }

    /// What the read tier paints — nil when there is nothing to paint.
    var paint: Paint? {
        guard !matches.isEmpty || current != nil else { return nil }
        return Paint(
            matches: matches, current: current,
            matchTint: matchTint, currentTint: currentTint)
    }

    struct Paint: Equatable {
        var matches: [NSRange]
        var current: NSRange?
        var matchTint: NSColor
        var currentTint: NSColor
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
        // hairline. (Not `tokens == nil`: Swift 6.4 resolves that through
        // `VoiceTokens`'s main-actor-isolated Equatable — a compile error here.)
        let rest = PaneDecoration(
            stroke: tokens.map { _ in Color.clear } ?? Color.gray.opacity(0.25),
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
    ///
    /// **`variantID` is also the take the pane is BOUND to** (VX-248): when
    /// a host hands the same mounted pane ANOTHER take, the pane re-binds —
    /// it adopts that take's text even while live, its typing history ends,
    /// and a live pane lands its caret in the new text
    /// (`Coordinator.rebindIfTakeChanged`). Every host passes the take whose
    /// edit closure it hands down beside it.
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
    /// transition only — a click keeps the place the click brought.
    /// **RAISE-2 (and the cap's R3-2, which found these sentences still
    /// quoting the retired `Int?`):** the type is `PaneCaretLanding` —
    /// `.offset` for a place the note remembers inside this take, `.start`
    /// for the note's entry with nothing remembered (QUESTIONS #97,
    /// PROVISIONAL), `.end` when the room asks for it, and `.leave` (the
    /// default, so a host that passes nothing keeps the shipped END) moves
    /// nothing.
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
    /// **18l-c U5 — HOW THIS PANE SPACES ITS LINES, when its HOST says**
    /// (her report: *"when you click onto text to edit, the whitespace around
    /// it moves around"*). nil — every host but two, and the default — is the
    /// Write editor's base paragraph style (`EditorDocument.baseParagraphStyle`),
    /// byte for byte as before: the Takes cards and article, the lenses,
    /// Compare, the Write takes panel, Canvas, the Blocks workbench. The two
    /// index-like hosts (the book Index, the note's Read ▸ edit) render a block
    /// at rest as read-cheap `Text` and swap in THIS pane on a click, so they
    /// hand it their read tier's own metrics (`IndexProseColumn.lines`) and the
    /// block goes live without re-spacing under her pointer. A surface's
    /// metrics are its host's call, through this one parameter — never a
    /// global, never a per-view guess.
    var lineMetrics: ProseLineMetrics? = nil
    /// **18l-c U7 — the pane's FIND face** (`PaneFindFace`): nil everywhere
    /// but the Takes board while its find runs, so every other pane is
    /// byte-unchanged.
    var findFace: PaneFindFace? = nil
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
                // 18j ladder round 1 (R1-1): the voice's ONE dynamic ink —
                // the same object the editor's base attributes and the face
                // palette below carry — so a light/dark change moves nothing
                // here (`applyStyle`'s gate compares the same object to
                // itself) and the pane's clear and its prose agree in kind.
                ink: tokens.map { EditorTypography.ink(for: $0.voice) },
                face: tokens.map { MarkdownStyling.Palette(tokens: $0) },
                role: role, variantID: variantID,
                spellcheck: spellcheck, paragraphGap: paragraphGap,
                onFocusRequest: onFocusRequest, onClickPlace: onClickPlace, onEdit: onEdit,
                onCommandClick: onCommandClick,
                onSelectionChange: onSelectionChange,
                caretOnGoingLive: caretOnGoingLive, menuItems: menuItems,
                onMeasuredHeight: onMeasuredHeight,
                caretToEndToken: caretToEndToken,
                lineMetrics: lineMetrics,
                findFace: findFace)
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
    /// The markdown face's colours from the SAME tokens (18g ladder round 1,
    /// the sanity pass's raise): the link's colour is the palette's accent,
    /// which moves without the ink — pushed beside it so a palette click
    /// re-derives a mounted pane's faces (`applyFace`). nil (no tokens) ⇒
    /// the global palette as before.
    var face: MarkdownStyling.Palette?
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
    /// 18l-c U5: the host's line metrics (nil = the Write editor's base
    /// style — every host but the two index-like tiers).
    var lineMetrics: ProseLineMetrics?
    /// 18l-c U7: the host's find face (nil = no find — every host but the
    /// Takes board while its find runs).
    var findFace: PaneFindFace?

    /// The paragraph style this pane lays out with — the host's, or the ONE
    /// base style every other surface shares.
    private var paragraphStyle: NSParagraphStyle {
        lineMetrics?.paragraphStyle ?? EditorDocument.baseParagraphStyle
    }

    /// The base attributes this pane writes — `EditorDocument.baseAttributes`
    /// exactly, with the paragraph style swapped only when the host set one.
    private var baseAttributes: [NSAttributedString.Key: Any] {
        var attributes = EditorDocument.baseAttributes
        if lineMetrics != nil { attributes[.paragraphStyle] = paragraphStyle }
        return attributes
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> PaneTextView {
        let view = PaneTextView.makeTakeSurface()
        // 18l-c U5: the host's line metrics, BEFORE the string arrives — the
        // text takes the typing attributes, so every character (and every one
        // she types later) carries them. No host metrics ⇒ nothing written:
        // the factory's base style stands byte for byte.
        if lineMetrics != nil {
            view.defaultParagraphStyle = paragraphStyle
            view.typingAttributes = baseAttributes
        }
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
        applyFace(to: view)  // before any `style` below reads the palette
        applyStyle(to: view)
        applyIdentity(to: view)
        spellcheck.apply(to: view)  // A24
        context.coordinator.boundVariantID = variantID  // VX-248: the take it is born bound to
        view.string = text
        context.coordinator.adoptedText = text  // TRACE 1a: the record starts here
        // 13g batch 2 (L7): a pane wears the same dimmed-marker face as the
        // editors (F-2/F-5). Whole-pane is P1-clean here for the reason this
        // file already states about layout: a pane's "document" is ONE take
        // or one post-read by construction.
        if let storage = view.textStorage { MarkdownStyling.style(storage) }
        // 18l-c U7: the find face — the request it is born with is its
        // BASELINE (a remount is not a step; a pane born live FOR a step is
        // landed by `caretOnGoingLive`'s `.select`), and a READ pane wears
        // its matches from the first frame. Before the liveness note, which
        // reads the face's keyboard rule.
        context.coordinator.find = findFace
        context.coordinator.adoptFindBaseline()
        context.coordinator.paintFind(live: isLive, in: view)
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
        context.coordinator.find = findFace
        view.variorumMenu = menuItems
        // VX-248 (her ruled bend of P-3): a RE-BIND first — the take this pane
        // is bound to changed under it, so the new take's words are written in
        // BEFORE the liveness note places a caret against them, and the pane is
        // a fresh mount for that take: the find's and the room's requests it
        // arrives under are its baselines (a re-bind is not a step).
        let rebound = context.coordinator.rebindIfTakeChanged(
            to: variantID, text: text, live: isLive, in: view)
        if rebound {
            context.coordinator.adoptFindBaseline()
            context.coordinator.adoptCaretToEndBaseline(caretToEndToken)
        }
        // 18l-c U7: a pane about to go live sheds its painted matches FIRST,
        // so the liveness note's selection (and the caret she types at) never
        // sits in a painted run.
        context.coordinator.paintFind(live: isLive, in: view)
        view.isEditable = isLive
        context.coordinator.noteLiveness(isLive, rebound: rebound)
        let faceBefore = view.appliedFace
        applyFace(to: view)  // before `applyStyle`: its `style` reads the palette
        // 18l-c U7: a face change re-derives the faced lines, whose clear owns
        // `.backgroundColor` there — the painted record no longer holds.
        if view.appliedFace != faceBefore { context.coordinator.findPaintWasReset() }
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
        //
        // 18l-c U5: the test is against THIS pane's style — the host's line
        // metrics where it set them, else the base — and it now asks the line
        // spacing too (the index hosts' style carries 4; every other pane's is
        // the base's 0 on both sides, so for them this is the same decision it
        // always was). A host's style changing is the same "our base
        // attributes moved" question, and takes the same road.
        let style = paragraphStyle
        if view.font != EditorDocument.baseFont
            || view.defaultParagraphStyle?.paragraphSpacing != style.paragraphSpacing
            || view.defaultParagraphStyle?.lineSpacing != style.lineSpacing {
            let attributes = baseAttributes
            view.font = EditorDocument.baseFont
            view.defaultParagraphStyle = style
            view.typingAttributes = attributes
            if let storage = view.textStorage, storage.length > 0 {
                storage.beginEditing()
                storage.addAttributes(
                    attributes,
                    range: NSRange(location: 0, length: storage.length))
                // 13g batch 2 (L7): the base refresh flattens the markdown
                // face; re-derive it in the same transaction, in the new voice.
                MarkdownStyling.style(storage)
                storage.endEditing()
                // 18l-c U7: the whole-pane restyle owns every run it rewrote.
                context.coordinator.findPaintWasReset()
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
        // isLive contract.) The ONE exception is VX-248's, ruled and written
        // above: a live pane takes the projection's text when — and only
        // when — the take it is BOUND to changes (a re-key is a re-bind, not
        // an edit; `rebindIfTakeChanged`).
        //
        // **TRACE 1a (13u2 UNIT D, routed here by RULING A-1).** This line
        // used to read `view.string != text`, and `view.string` on an
        // `NSTextView` is the storage's `NSString`, LAZILY BRIDGED — a
        // foreign `__NSCFString`, never a native Swift string. Swift's `==`
        // cannot take its memcmp fast path against a foreign operand, so the
        // comparison dropped to `_stringCompareSlow`: full NFC normalization
        // of both sides with one `-[__NSCFString characterAtIndex:]` ObjC
        // message per UTF-16 unit — and the EQUAL case, which is the common
        // one, is the WORST case, because proving equality means scanning to
        // the end. Paid per read pane per SwiftUI update pass; on the Takes
        // margin grid that is the whole board. UNIT A found it as the only
        // Variorum leaf in the 13l hang capture (51 of 2,551 samples).
        //
        // The repair is the trace's own second suggestion: the coordinator
        // REMEMBERS what it last wrote here, and the question is asked of
        // that native string instead. It is authoritative because exactly
        // three sites ever write a pane's characters — `makeNSView`, this
        // one and VX-248's re-bind (which keeps the record itself) — and a
        // read pane is `isEditable == false`, so no input path can touch it
        // (nor ⌘Z since VX-421: a read pane answers an empty history,
        // `Coordinator.undoManager(for:)`). While the pane is LIVE the
        // record is dropped: her buffer is the truth there, and what we last
        // wrote says nothing about what the view now holds. That leaves the
        // first read pass after liveness with nothing to consult, and it
        // takes the old foreign comparison — correct, and rare.
        // **Byte-for-byte the same decision as before; only the road to it
        // is cheap.**
        if isLive {
            context.coordinator.adoptedText = nil
        } else if context.coordinator.readPaneNeedsText(text, in: view) {
            view.string = text
            // VX-421: the words this pane's typing history described have
            // left it — the history ends with them (VX-179 U3-g's rule).
            context.coordinator.endUndoHistory(in: view)
            // 13g batch 2 (L7): a fresh string carries only typing
            // attributes — the face is re-derived over the adopted text.
            if let storage = view.textStorage { MarkdownStyling.style(storage) }
            // 18l-c U7: a fresh string carries no paint either.
            context.coordinator.findPaintWasReset()
            context.coordinator.remeasure()
        }
        // 18l-c U7: re-paint over whatever the two roads above re-wrote
        // (change-gated — a pane whose paint still holds writes nothing).
        context.coordinator.paintFind(live: isLive, in: view)
        // 13f W7: last, so the text above is settled before the caret is
        // placed against it.
        context.coordinator.applyCaretToEndIfRequested(caretToEndToken, in: view)
        // 18l-c U7: a find step addressed to this (already live) pane — after
        // the text is settled, like the room's caret.
        context.coordinator.applyFindRequestIfAsked(in: view)
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

    /// **18g ladder round 1, the sanity pass's raise — CHANGE-GATED like
    /// the ink.** The markdown face's colours live in the storage and the
    /// link's is the PALETTE's accent, which a palette click moves without
    /// moving the ink or the base attributes — the two gates that used to
    /// be the only roads to a re-style. With the host's face pushed beside
    /// its ink: the first application only adopts it (the materialization's
    /// own `style` follows and reads it); a CHANGED face re-derives the
    /// faced lines — one line-scoped edit per faced line
    /// (`restyleFacedLines`), never a whole-pane union write. The global
    /// palette is set from the pushed face first, so every `style` this
    /// file runs reads the same colours the host resolved — the third
    /// writer of that global, and it writes what the other two write, all
    /// three resolving from the one settings → tokens road.
    private func applyFace(to view: PaneTextView) {
        guard let face, view.appliedFace != face else { return }
        let first = view.appliedFace == nil
        view.appliedFace = face
        MarkdownStyling.palette = face
        guard !first, let storage = view.textStorage else { return }
        MarkdownStyling.restyleFacedLines(storage)
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

        /// **TRACE 1a (13u2 UNIT D):** the text this pane last ADOPTED —
        /// a native Swift string, so asking "has the projection changed?"
        /// costs a native comparison (usually a pointer-identity hit, since
        /// the projection hands the same instance back) instead of a
        /// normalizing walk over a bridged `__NSCFString`. Nil means "we do
        /// not know what the view holds" — set on every live render, because
        /// a live pane's characters are hers, not ours.
        var adoptedText: String?

        /// Does this READ pane need the projection's text written into it?
        /// Answered from the record where there is one; otherwise by the old
        /// foreign comparison, which is correct and now rare (the first read
        /// pass after a pane was live). **It records either way** — after
        /// this pass the view holds `text` whichever answer came back, and a
        /// road that recorded only on adoption would leave the record empty
        /// (and the foreign comparison hot) for a pane whose text had not
        /// moved across a liveness episode.
        func readPaneNeedsText(_ text: String, in view: PaneTextView) -> Bool {
            defer { adoptedText = text }
            if let adopted = adoptedText { return adopted != text }
            #if DEBUG
            PaneSurfaceAudit.foreignTextComparisons += 1
            #endif
            return view.string != text
        }

        // MARK: - The bound take (VX-248 — her ruled bend of P-3)

        /// The take this pane is BOUND to — the host's `variantID`: the take
        /// whose words it shows and whose edit closure its keystrokes reach.
        /// nil when the host names none (the tutorial samples, the pins).
        /// Written at the mount, and by `rebindIfTakeChanged` only.
        var boundVariantID: String?

        /// **A RE-KEY IS A RE-BIND, NOT AN EDIT** (VX-248 — her ruling, the
        /// root fix QUESTIONS #217 asked for: *"I think that we should probably
        /// fix it"*; seated R-601-6). A stable-identity cell (the Takes
        /// article, a Lenses column, Canvas, the workbench, Read ▸ edit) keeps
        /// ONE pane while the take it shows can change (a choose, a step, a
        /// mint), and its host hands the new take's edit closure down on the
        /// same render. A LIVE pane never took projection text, so a pane
        /// re-keyed while live — or in the render that turned it live, VX-222's
        /// revival — kept the OLD take's words under the NEW take's closure,
        /// and her next keystroke saved them over the new take (silently: one
        /// writer, never a sync conflict). VX-222's end-rule and VX-227's
        /// parked follow keep every road the boards know of from re-keying a
        /// live cell; this closes the class at the one component, whatever
        /// road arrives (those two stay, now redundant by construction).
        ///
        /// So when the bound take CHANGES the pane takes the new take's text
        /// — the one exception to "a live pane never adopts projection text",
        /// hers — and is, from here, a fresh pane for that take:
        /// - the characters are written only where they differ (a branch
        ///   arrives identical, and a needless full write is the A47c class);
        /// - the old take's typing history ENDS (VX-421 meets VX-248 here —
        ///   ⌘Z must never replay one take's typing into another), even when
        ///   the characters happen to agree;
        /// - a LIVE re-bind lands its caret in the NEW text, after the write,
        ///   and claims the keyboard, exactly as a programmatic going-live
        ///   does (`noteLiveness(_:rebound:)`) — a `string =` leaves AppKit's
        ///   END, so a landing made before the write was lost.
        /// Nothing is handed up: adoption is not her typing (`string =` posts
        /// no `textDidChange`), so no autosave follows. The keystrokes she
        /// typed into the old take were handed up as she typed them (every
        /// `textDidChange`) — the re-bind drops only their on-screen mirror.
        /// Returns whether the pane was re-bound.
        func rebindIfTakeChanged(
            to variantID: String?, text: String, live: Bool, in view: PaneTextView
        ) -> Bool {
            guard variantID != boundVariantID else { return false }
            boundVariantID = variantID
            // TRACE 1a's record answers for a read pane; a live one is asked
            // directly (rare — once per re-bind, never per update pass).
            let holds = adoptedText.map { $0 == text } ?? (view.string == text)
            if !holds {
                view.string = text
                // A fresh string carries only typing attributes — the face is
                // re-derived caret-blind over it, so no line carries a caret's
                // honour (the ledger starts over), and no paint either.
                if let storage = view.textStorage { MarkdownStyling.style(storage) }
                markdownCaret = MarkdownCaretRescue.Ledger()
                findPaintWasReset()
                remeasure()
            }
            endUndoHistory(in: view)
            adoptedText = live ? nil : text
            return true
        }

        /// 13b 1b (N9's keyboard half): a pane TRANSITIONING to live holds
        /// the keyboard — programmatic ring moves (the Takes landing, the
        /// add-block door, ⌃⌘←/→ steps) must make "just start typing"
        /// literal. A click-focused pane is already first responder (the
        /// claim is a no-op); read transitions never claim.
        ///
        /// VX-248: a LIVE pane `rebound` to another take arrives exactly as a
        /// pane going live does — the landing, then the claim — because the
        /// ring is now on a take this pane did not hold a moment ago. Called
        /// AFTER `rebindIfTakeChanged`, so the landing is placed in the new
        /// take's text.
        func noteLiveness(_ live: Bool, rebound: Bool = false) {
            let was = wasLive
            defer { wasLive = live }
            // VX-296: a pane going READ keeps its selection but holds no
            // caret of hers any more — the line it honoured is re-read
            // caret-blind (the host has set `isEditable` already, so the
            // settle reads no selection). Before the convergence occasion
            // below, which measures what italics may have rewrapped.
            if !live, was, let view { settleMarkdownCaret(in: view) }
            // 13c 1G: a liveness TRANSITION (either direction) is a
            // convergence occasion — "clicking into other blocks" moves the
            // ring, and the stale card's live→read flip is the one event it
            // reliably receives. Transition-gated so ordinary read→read
            // updates cost nothing. VX-248: a live pane re-bound in place is
            // the same discrete event (its whole text was rewritten — the
            // occasion's render restore is the A47c belt); a READ re-bind
            // keeps the read adoption's own road, a remeasure only.
            if live != was || (live && rebound) { view?.fireConvergenceOccasion() }
            guard live, !was || rebound, let view else {
                // 17o batch b's ladder, R1-2: a click's flag is spent by a
                // live render (the pane already held the ring — nothing to
                // land) or by a live→read transition (the gesture is over);
                // a read→read render KEEPS it for the flip it asked for.
                if live || live != was { view?.clickBroughtPlace = false }
                return
            }
            // VX-248: a click's place was made in the text a re-bind just
            // replaced — the landing decides.
            let clickBroughtPlace = view.clickBroughtPlace && !rebound
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
                case .select(let range):
                    // 18l-c U7: a find step's landing — the match, selected.
                    view.setSelectedRange(Self.clamped(range, to: length))
                }
            }
            // 18l-c U7: a step driven FROM the find field leaves the keyboard
            // in the field (the Write bar's convention — ⏎ keeps stepping; Esc
            // hands it back). The pane is live all the same: ring, selection.
            if find?.fieldHoldsKeyboard == true { return }
            if let window = view.window {
                window.makeFirstResponder(view)
            } else {
                view.claimsKeyboardOnAttach = true
            }
        }

        // MARK: - The find face (18l-c U7)

        /// The host's find face, refreshed on every render (nil = no find).
        var find: PaneFindFace?
        /// What the storage CARRIES now — the change gate's other half. Reset
        /// by every road that rewrites the storage's attributes.
        private var paintedFind: PaneFindFace.Paint?
        /// The last find-request token this pane acted on (or was born with).
        private var lastFindToken = 0

        /// A pane born while a request is outstanding must not act on it: a
        /// remount is not a step.
        func adoptFindBaseline() {
            lastFindToken = find?.request?.token ?? 0
        }

        /// The storage's attributes were rewritten under the paint (a fresh
        /// string, a whole-pane restyle, a face change): nothing is painted.
        func findPaintWasReset() {
            paintedFind = nil
        }

        /// **Paint the matches — the READ tier only** (decision 7). The paint
        /// is `.backgroundColor` runs in this pane's own attributed string,
        /// scoped to the match ranges (never a full-range write — the A47c
        /// class), change-gated against what the storage carries, and removed
        /// the moment the pane goes live (the selection is the live pane's
        /// affordance). Removing a run can take a code chip's tint with it, so
        /// the touched lines are handed back to the markdown face, which owns
        /// that tint. The text is never touched — the paint can never reach
        /// the store (`onEdit` hands up the string, and a read pane has none
        /// to hand).
        func paintFind(live: Bool, in view: PaneTextView) {
            let wanted = live ? nil : find?.paint
            guard wanted != paintedFind, let storage = view.textStorage else { return }
            let length = storage.length
            storage.beginEditing()
            if let old = paintedFind {
                var touched: [NSRange] = []
                for range in old.matches + [old.current].compactMap({ $0 }) {
                    let run = Self.clamped(range, to: length)
                    guard run.length > 0 else { continue }
                    storage.removeAttribute(.backgroundColor, range: run)
                    touched.append(run)
                }
                for run in touched { MarkdownStyling.restyle(storage, range: run) }
            }
            if let paint = wanted {
                for range in paint.matches {
                    let run = Self.clamped(range, to: length)
                    guard run.length > 0 else { continue }
                    storage.addAttribute(.backgroundColor, value: paint.matchTint, range: run)
                }
                if let current = paint.current {
                    let run = Self.clamped(current, to: length)
                    if run.length > 0 {
                        storage.addAttribute(.backgroundColor, value: paint.currentTint, range: run)
                    }
                }
            }
            storage.endEditing()
            paintedFind = wanted
            view.noteFindPaint(wanted)
            // The typing attributes follow the selection's run: a pane going
            // live must never type in a match's colour.
            if view.typingAttributes[.backgroundColor] != nil {
                view.typingAttributes.removeValue(forKey: .backgroundColor)
            }
            // The occasion's belt (A47c): an attribute write on a scrolled
            // pane is re-drawn on a deferred turn, viewport-bounded.
            scheduleRenderRestore()
        }

        /// A find step addressed to this pane while it is ALREADY live: select
        /// the match, take the keyboard when asked. Read panes consume the
        /// token without acting — liveness is the authority's (P-3), and the
        /// pane that goes live for a step is landed by `.select` instead.
        func applyFindRequestIfAsked(in view: PaneTextView) {
            guard let request = find?.request, request.token != lastFindToken else { return }
            lastFindToken = request.token
            guard view.isEditable else { return }
            if let select = request.select {
                view.setSelectedRange(Self.clamped(select, to: (view.string as NSString).length))
            }
            if request.claimsKeyboard, let window = view.window, window.firstResponder !== view {
                window.makeFirstResponder(view)
            }
        }

        /// A range held inside a text of `length` UTF-16 units.
        nonisolated static func clamped(_ range: NSRange, to length: Int) -> NSRange {
            let location = min(max(0, range.location), length)
            return NSRange(location: location, length: min(max(0, range.length), length - location))
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
            // VX-421: the history goes with the pane — said here rather than
            // left to whenever SwiftUI lets this coordinator go.
            undoHistory.removeAllActions()
            view = nil
            onMeasuredHeight = nil
            pendingMeasuredHeight = nil
        }

        // MARK: - The pane's own undo history (VX-421 — her R-601-1)

        /// **This pane's typing history is ITS OWN** (VX-421 — her report: ⌘Z
        /// after deleting a take in Takes crashed the app; R-601-1, the
        /// per-pane arm). Every pane is built `allowsUndo: true`, and while
        /// nothing answered `undoManager(for:)` its typing and pastes went onto
        /// the WINDOW's manager — so a pane torn down with its take left actions
        /// there aimed at a view `NSUndoManager` does not retain, and the next
        /// ⌘Z messaged a freed pane (`EXC_BAD_ACCESS` in `popAndInvoke`) or
        /// edited one no longer on screen. Every host of this one component
        /// shared it: the Takes cards and article, Lenses, Compare, Write's
        /// take panel, Canvas, the Blocks workbench, and Read ▸ edit and the
        /// book Index, which dismantle their pane on every going-read.
        ///
        /// It has to be the pane's OWN manager (the `CommentTextArea` /
        /// `CaptureTextView` road, VX-179 U3-g and VX-193):
        /// `removeAllActions(withTarget:)` on the view or its storage does not
        /// reach TK2's registrations (measured at U3-g), and clearing the
        /// window's manager would reach other text's history. ⌘Z still arrives
        /// by AppKit's road — `undo:` travels to the window, which undoes
        /// through the first responder's `undoManager`, answered here — so ⌘Z
        /// undoes only the pane the caret is in, and the history goes with
        /// the pane: this coordinator's life is the representable's (it
        /// survives a detach and re-attach — TEXTKIT2_NOTES §3's re-parent —
        /// untouched), and `uninstall` empties it besides.
        ///
        /// The rule the precedents keep, kept here: the history describes
        /// only the characters the pane holds, so every PROGRAMMATIC write of
        /// them ends it (`endUndoHistory`) — a read pane's adoption of the
        /// projection, a re-bind to another take. Typing is the pane's; what
        /// arrives from outside it is not undone into.
        let undoHistory = UndoManager()

        /// **What a READ pane answers: a history nothing is ever registered
        /// on.** A read pane can still hold the keyboard (a drag-selection, or
        /// the moment a parked follow's blur leaves it holding it), and AppKit
        /// applies an undo to a NON-EDITABLE text view (measured offscreen on
        /// 27: the characters revert, no `textDidChange`) — so ⌘Z there would
        /// move a projection-authoritative pane off its take's text
        /// (`PaneTextAuthority`'s read contract; TRACE 1a's record would go
        /// stale with it). ⌘Z undoes the pane her CARET is in, and a read pane
        /// holds no caret of hers (VX-296's line): its own history waits,
        /// untouched, for the pane's next going-live over the same
        /// characters. Never nil — nil falls back to the window's manager
        /// (measured), the cross-pane history this fix ends.
        private let readHistory = UndoManager()

        func undoManager(for view: NSTextView) -> UndoManager? {
            guard view === self.view else { return nil }
            return view.isEditable ? undoHistory : readHistory
        }

        /// The pane's characters were written from outside her typing: the
        /// history that named the old characters ends, and the next keystroke
        /// starts a fresh entry rather than coalescing into one just removed.
        func endUndoHistory(in view: PaneTextView) {
            view.breakUndoCoalescing()
            undoHistory.removeAllActions()
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
        /// VX-296: the same keystroke as the PRE-edit range it replaces and
        /// the length of what replaces it — what moves the face's caret claim
        /// with the text. Set and cleared beside `pendingEditRange`.
        private var pendingEditReplaced: (old: NSRange, newLength: Int)?
        /// VX-296: which line the markdown face last styled honouring this
        /// pane's caret (the shared `MarkdownCaretRescue.Ledger`).
        private var markdownCaret = MarkdownCaretRescue.Ledger()

        func textView(
            _ textView: NSTextView,
            shouldChangeTextIn affectedCharRange: NSRange,
            replacementString: String?
        ) -> Bool {
            pendingEditRange = NSRange(
                location: affectedCharRange.location,
                length: (replacementString as NSString?)?.length ?? 0)
            pendingEditReplaced = (
                affectedCharRange,
                (replacementString as NSString?)?.length ?? affectedCharRange.length)
            return true
        }

        func textDidChange(_ notification: Notification) {
            guard let view else { return }
            if let replaced = pendingEditReplaced {
                markdownCaret.noteEdit(replacing: replaced.old, newLength: replaced.newLength)
            }
            if let storage = view.textStorage {
                // No recorded range (an edit that reached the storage by some
                // other path) falls back to the caret's own lines — still
                // scoped, never the pane.
                MarkdownStyling.restyle(
                    storage, range: pendingEditRange ?? view.selectedRange())
            }
            pendingEditRange = nil
            pendingEditReplaced = nil
            // VX-296: the keystroke's restyle above is caret-blind (byte-
            // unchanged); the selection has landed by now (measured: AppKit
            // posts the selection change, then this), so the caret's honour
            // settles here — before the remeasure, since italics can rewrap.
            settleMarkdownCaret(in: view)
            onEdit?(view.string)
            remeasure()
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let view else { return }
            // VX-296: a caret move settles the face's honour of it. Mid-
            // keystroke this notification PRECEDES `textDidChange`, whose own
            // caret-blind restyle would undo a settle made here — so a pending
            // edit leaves the settle to it.
            if pendingEditReplaced == nil, settleMarkdownCaret(in: view) { remeasure() }
            onSelectionChange?(view.selectedRange())
        }

        /// VX-296 — the shared caret settle on this pane: its selection while
        /// it is LIVE (editable), none while it reads (a read pane honours no
        /// caret — a find step's selection, a click on its way to a focus
        /// request). Returns whether a line was restyled.
        @discardableResult
        private func settleMarkdownCaret(in view: PaneTextView) -> Bool {
            guard let storage = view.textStorage else { return false }
            let restyled = MarkdownStyling.settleCaret(
                &markdownCaret,
                selection: view.isEditable ? view.selectedRange() : nil,
                in: storage)
            // VX-282 R1-1: the face's line restyle OWNS `.backgroundColor` on
            // every face run it re-derives — a find match painted inside the
            // honoured span goes with it. A pane going read paints its matches
            // BEFORE the liveness note's settle runs (`updateNSView`), so the
            // record must learn what the settle rewrote, or the change-gated
            // repaint at the update's end writes nothing and the match stays
            // unpainted. The same rule every other road that rewrites the
            // storage's attributes keeps (`findPaintWasReset`'s other callers).
            if restyled { findPaintWasReset() }
            return restyled
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
                // 18l-b U3 (the TK2 §3 rider): the clips are read on both
                // sides of the viewport layout — the observation only; the
                // exam's verdict and its mechanism are in the U3 record.
                let clipsBefore = view.enclosingClipOrigins()
                view.textLayoutManager?.textViewportLayoutController.layoutViewport()
                let clipsAfter = view.enclosingClipOrigins()
                // A clip COUNT change across the call would be a hierarchy
                // change the pass should be incapable of (it builds rendering
                // surfaces BELOW the text view, and both reads share this one
                // main-queue block) — recorded LOUD, never zip-truncated into
                // a silent 0, so the pins' == 0 arms catch it (ladder round 1,
                // NIT-2).
                view.noteRenderRestore(
                    clipShift: clipsBefore.count == clipsAfter.count
                        ? (zip(clipsBefore, clipsAfter).map { abs($1 - $0) }.max() ?? 0)
                        : .infinity)
            }
        }
    }
}

#if DEBUG
/// **TRACE 1a's oracle (13u2 UNIT D).** How many times a read pane had to
/// ask the VIEW what it holds — the bridged-`NSString` comparison whose
/// `_stringCompareSlow` leaf UNIT A found in the 13l hang capture. The claim
/// this counter carries is a SHAPE, not a stopwatch: after a pane has
/// adopted its text once, no number of further SwiftUI update passes over
/// unchanged text may reach that road again.
@MainActor
enum PaneSurfaceAudit {
    static var foreignTextComparisons = 0

    static func reset() { foreignTextComparisons = 0 }
}
#endif
