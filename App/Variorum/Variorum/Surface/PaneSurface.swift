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
        layoutManager.ensureLayout(for: layoutManager.documentRange)
        return layoutManager.usageBoundsForTextContainer.height
            + view.textContainerInset.height * 2
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

final class PaneTextView: NSTextView {
    /// A click that created no selection — the click-to-focus gesture, with
    /// the clicked UTF-16 offset (the read tier seeds the editor's caret
    /// from it; take panes ignore the value).
    var onPlainClick: ((Int) -> Void)?

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
    }

    var variorumMenu: (() -> [MenuItemSpec])?

    override func menu(for event: NSEvent) -> NSMenu? {
        let inherited = super.menu(for: event)
        guard let items = variorumMenu?(), !items.isEmpty else { return inherited }
        let menu = inherited ?? NSMenu()
        for (i, item) in items.enumerated() {
            menu.insertItem(Self.makeMenuItem(for: item), at: i)
        }
        menu.insertItem(NSMenuItem.separator(), at: items.count)
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
        if !spec.children.isEmpty {
            let submenu = NSMenu(title: spec.title)
            for child in spec.children {
                submenu.addItem(makeMenuItem(for: child))
            }
            menuItem.submenu = submenu
        }
        return menuItem
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
        super.mouseDown(with: event)  // the selection tracking loop runs first
        defer { fireConvergenceOccasion() }  // 13c 1G: a click is an occasion
        guard selectedRange().length == 0 else { return }
        let point = convert(event.locationInWindow, from: nil)
        onPlainClick?(characterIndexForInsertion(at: point))
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
    /// Surface identity for tests/soaks: the pane's role in its
    /// composition ("article", "card", "mini", …) and the variant it
    /// mirrors — carried on the NSView identifier, rendered nowhere.
    var role: String = "pane"
    var variantID: String? = nil
    /// A plain click on a read pane — the container migrates the live
    /// editor here.
    var onFocusRequest: (() -> Void)?
    /// A live pane's edit: the full new text (the model computes cost and
    /// routes autosave).
    var onEdit: ((String) -> Void)?
    /// 13b 1b: the live pane's selection, reported as it changes — the
    /// fire-and-DO choreography carries it into Write.
    var onSelectionChange: ((NSRange) -> Void)?
    /// 13b 1b (AD-4): the pane's Variorum context-menu items.
    var menuItems: (() -> [PaneTextView.MenuItemSpec])?
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
                onFocusRequest: onFocusRequest, onEdit: onEdit,
                onSelectionChange: onSelectionChange, menuItems: menuItems)
                // EXACT height, not a floor (13b 3F, AD-7): an
                // NSViewRepresentable ACCEPTS a tall proposal, so in any
                // composition whose row is taller than the text (the margin
                // grid's reserved rail) a `minHeight` pane STRETCHED to the
                // row and the wash rendered as a mostly-empty slab. The
                // pane is always its measured content height; the width
                // hook + publishes keep it converged (the batch-12 pin).
                .frame(height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: tokens == nil ? 3 : 6)
                        .stroke(strokeColor, lineWidth: isLive ? 1.5 : 0.5))
        }
    }

    private var strokeColor: Color {
        if let tokens { return isLive ? tokens.ring : .clear }
        return isLive ? Color.accentColor : Color.gray.opacity(0.25)
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
    var onEdit: ((String) -> Void)?
    var onSelectionChange: ((NSRange) -> Void)?
    var menuItems: (() -> [PaneTextView.MenuItemSpec])?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> PaneTextView {
        let view = PaneTextView.makeTakeSurface()
        view.delegate = context.coordinator
        context.coordinator.install(
            view: view,
            publishHeight: { height = max($0, 24) },
            publishCanary: { canaryMessage = $0 })
        context.coordinator.onEdit = onEdit
        view.onPlainClick = { [weak coordinator = context.coordinator] _ in
            coordinator?.onFocusRequest?()
        }
        context.coordinator.onFocusRequest = onFocusRequest
        context.coordinator.onSelectionChange = onSelectionChange
        view.variorumMenu = menuItems
        applyStyle(to: view)
        applyIdentity(to: view)
        spellcheck.apply(to: view)  // A24
        view.string = text
        view.isEditable = isLive
        context.coordinator.noteLiveness(isLive)
        context.coordinator.remeasure()
        return view
    }

    func updateNSView(_ view: PaneTextView, context: Context) {
        context.coordinator.onEdit = onEdit
        context.coordinator.onFocusRequest = onFocusRequest
        context.coordinator.onSelectionChange = onSelectionChange
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
                storage.endEditing()
            }
            context.coordinator.remeasure()
        }
        // The buffer is authoritative while live: a projection may lag the
        // keystroke; never clobber the surface under the caret. Read panes
        // adopt any change. (The view-level half of PaneTextAuthority's
        // isLive contract.)
        if !isLive, view.string != text {
            view.string = text
            context.coordinator.remeasure()
        }
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
        var onSelectionChange: ((NSRange) -> Void)?
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
            guard live, !was, let view else { return }
            if let window = view.window {
                window.makeFirstResponder(view)
            } else {
                view.claimsKeyboardOnAttach = true
            }
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
        }

        func textDidChange(_ notification: Notification) {
            guard let view else { return }
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
