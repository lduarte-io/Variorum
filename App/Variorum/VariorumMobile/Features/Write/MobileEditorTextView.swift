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

// MARK: - The keyboard bar shell (obligation 4; M11's acts land later)

@MainActor
enum MobileKeyboardBar {
    /// The 44 pt accessory bar that rides the keyboard — measured working
    /// in the spike (item 6). Batch 1 ships the SHELL only; the formatting
    /// acts (M11) land with the markdown batch.
    static func makeShell() -> UIView {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        bar.autoresizingMask = [.flexibleWidth]
        bar.items = [.flexibleSpace()]
        return bar
    }
}

// MARK: - The text view

@MainActor
final class MobileEditorTextView: UITextView {
    private let canary = MobileFallbackCanary()

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
        view.inputAccessoryView = MobileKeyboardBar.makeShell()
        return view
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
