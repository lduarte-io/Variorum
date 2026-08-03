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

// MARK: - The text view

@MainActor
final class MobileEditorTextView: UITextView {
    private let canary = MobileFallbackCanary()

    /// The keyboard bar's acts controller + the checkbox tap's router —
    /// retained here because `UIBarButtonItem` targets and gesture-recognizer
    /// targets are held weakly (batch 2).
    private var keyboardBarController: MobileKeyboardBarController?
    private var checkboxRouter: MobileCheckboxTapRouter?

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
        view.typingAttributes = MobileEditorStyle.baseAttributes
        view.backgroundColor = .systemBackground

        // Batch 2: the bar's six live acts (LK8 minus ⑂/⋯ per P-2) replace
        // the batch-1 shell.
        let barController = MobileKeyboardBarController(textView: view)
        view.keyboardBarController = barController
        view.inputAccessoryView = barController.makeBar()

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
