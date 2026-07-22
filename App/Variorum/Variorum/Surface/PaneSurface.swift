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
//  cannot pin a pane at one line, whichever surface composes it.
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
        writeHeight: @escaping (CGFloat) -> Void,
        writeCanary: @escaping (String) -> Void,
        schedule: @escaping Scheduler = { work in DispatchQueue.main.async(execute: work) }
    ) {
        self.measure = measure
        self.renderedHeight = renderedHeight
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
        // it renders short of its text, the write did not take — try again
        // until the budget is spent.
        let rendered = renderedHeight?() ?? height
        if rendered + Self.convergenceSlack < height, healTurnsLeft > 0 {
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

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if claimsKeyboardOnAttach, let window {
            claimsKeyboardOnAttach = false
            window.makeFirstResponder(self)
        }
    }
    /// Fires when layout gives the view a NEW width (batch 12 — the
    /// clipped-take fix's trigger; width-gated so height publishes can't
    /// loop through it).
    var onWidthChange: (() -> Void)?
    private var lastLaidOutWidth: CGFloat = -1
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
            onWidthChange?()
        }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)  // the selection tracking loop runs first
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
        makeSurface(inset: 8, allowsUndo: false)
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
        // A voice switch changes the ONE global typography (C1's
        // EditorTypography); live-adopt it so open panes re-font without
        // reconstruction (an ordinary storage write, never §3 attributes).
        if view.font != EditorDocument.baseFont {
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
            view.drawsBackground = false
            view.textColor = ink
            view.insertionPointColor = ink
        } else {
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
            defer { wasLive = live }
            guard live, !wasLive, let view else { return }
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
        /// width-gated).
        func remeasure() {
            publisher?.publishHeight()
        }
    }
}
